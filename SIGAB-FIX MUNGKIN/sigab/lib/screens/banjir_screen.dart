import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter_map/flutter_map.dart';
import 'riwayat_banjir_screen.dart';
import '../api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sigab/widgets/map_widget.dart';
import 'package:sigab/widgets/flood_info_card.dart';

class BanjirScreen extends StatefulWidget {
  const BanjirScreen({super.key});

  @override
  State<BanjirScreen> createState() => _BanjirScreenState();
}

class _BanjirScreenState extends State<BanjirScreen> {
  Position? _userLocation;
  bool _isBanjirTerkini = true;
  bool _isLoading = true;
  String _error = '';
  List<dynamic>? _floodData;
  LatLng _mapCenter =
      const LatLng(-6.914744, 107.609810); // Default Bandung center
  double _mapZoom = 12.0; // Default zoom

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchFloodData();
  }

  // Fungsi untuk menghitung pusat dan zoom peta berdasarkan lokasi pengguna dan data banjir
  void _calculateMapCenterAndZoom() {
    List<LatLng> points = [];

    if (_userLocation != null) {
      points.add(LatLng(_userLocation!.latitude, _userLocation!.longitude));
    }

    if (_floodData != null) {
      for (var flood in _floodData!) {
        if (flood['koordinat_lokasi'] != null &&
            flood['koordinat_lokasi']['x'] != null &&
            flood['koordinat_lokasi']['y'] != null) {
          try {
            final double floodLat =
                double.parse(flood['koordinat_lokasi']['y'].toString());
            final double floodLng =
                double.parse(flood['koordinat_lokasi']['x'].toString());
            points.add(LatLng(floodLat, floodLng));
          } catch (e) {
            print('Error parsing flood coordinate: $e for flood data: $flood');
          }
        }
      }
    }

    if (points.isEmpty) {
      // Jika tidak ada data, gunakan pusat Bandung default
      _mapCenter = const LatLng(-6.914744, 107.609810);
      _mapZoom = 12.0;
    } else if (points.length == 1) {
      // Jika hanya ada satu titik (user atau banjir),
      // pusat di titik itu dengan zoom sedang
      _mapCenter = points[0];
      _mapZoom = 14.0; // Zoom in sedikit
    } else {
      // Jika ada lebih dari satu titik,
      // hitung bounding box yang mencakup semua titik
      final bounds = LatLngBounds.fromPoints(points);
      _mapCenter = bounds.center;

      // Hitung zoom level yang mencakup semua titik. Ini pendekatan sederhana,
      // zoom yang lebih akurat butuh perhitungan jarak terluas dan ukuran layar.
      // Menggunakan LatLngBounds.getCenterZoom() mungkin lebih baik jika tersedia

      // Pendekatan kasar berdasarkan rentang koordinat:
      final latDelta = bounds.north - bounds.south;
      final lngDelta = bounds.east - bounds.west;

      // Sesuaikan zoom berdasarkan delta koordinat. Nilai ini mungkin perlu tuning.
      // Semakin besar delta, semakin kecil zoom levelnya.
      if (latDelta < 0.01 && lngDelta < 0.01) {
        // Area sangat kecil
        _mapZoom = 15.0;
      } else if (latDelta < 0.05 && lngDelta < 0.05) {
        // Area kecil
        _mapZoom = 13.0;
      } else if (latDelta < 0.1 && lngDelta < 0.1) {
        // Area sedang
        _mapZoom = 12.0;
      } else {
        // Area luas
        _mapZoom = 11.0;
      }
      // Pastikan zoom tidak melebihi maxZoom MapWidget (default 18)
      _mapZoom =
          _mapZoom.clamp(5.0, 18.0); // Sesuaikan min/max dengan MapWidget
    }
  }

  Future<void> _fetchFloodData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final data = await ApiService.getFloodData();
      print('Flood data received: $data'); // Debug print

      // Sort data berdasarkan waktu kejadian
      final List sortedData = (data['data'] as List).toList()
        ..sort((a, b) => DateTime.parse(b['waktu_kejadian'])
            .compareTo(DateTime.parse(a['waktu_kejadian'])));

      setState(() {
        _floodData = sortedData;
        _isLoading = false;
        // Setelah data banjir didapat, hitung ulang pusat dan zoom peta
        _calculateMapCenterAndZoom();
      });
    } catch (e) {
      print('Error fetching flood data: $e'); // Debug print
      setState(() {
        _error = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
        _calculateMapCenterAndZoom(); // Tetap hitung jika hanya user location yang ada
      });
    }
  }

  // Tambahkan fungsi untuk retry loading map tiles
  Future<void> _retryLoadMapTiles() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(
        const Duration(seconds: 2)); // Tunggu 2 detik sebelum retry
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  // Tambahkan error handler untuk map tile loading
  void _handleMapTileError(dynamic error) {
    print('Map tile loading error: $error');
    if (error.toString().contains('Connection closed')) {
      _retryLoadMapTiles();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Cek permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return; // Atau tampilkan pesan ke user
        }
      }

      // Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _userLocation = position;
        _calculateMapCenterAndZoom(); // Setelah lokasi user didapat, hitung ulang pusat dan zoom peta
      });
    } catch (e) {
      print('Error mendapatkan lokasi: $e');
      setState(() {
        _calculateMapCenterAndZoom(); // Tetap hitung jika hanya flood data yang ada
      });
    }
  }

  Color _getStatusColor(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'tinggi':
        return Colors.red;
      case 'sedang':
        return Colors.orange;
      case 'rendah':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              const Center(
                child: Text(
                  'Banjir',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tab buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isBanjirTerkini = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBanjirTerkini
                              ? const Color(0xFFFFA726)
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: _isBanjirTerkini
                                ? const Color(0xFFFFA726)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          'Banjir Terkini',
                          style: TextStyle(
                            color: _isBanjirTerkini
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RiwayatBanjirScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          'Riwayat Banjir',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Content based on selected tab
              if (_isBanjirTerkini) ...[
                // Map Container using MapWidget
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error.isNotEmpty
                            ? Center(child: Text(_error))
                            : _floodData == null || _floodData!.isEmpty
                                ? const Center(
                                    child: Text('Tidak ada data lokasi banjir'))
                                : MapWidget(
                                    // Menggunakan pusat dan zoom yang dihitung
                                    center: _mapCenter,
                                    zoom: _mapZoom,
                                    markers: [
                                      // Tambah marker untuk lokasi user
                                      if (_userLocation != null)
                                        Marker(
                                          point: LatLng(
                                            _userLocation!.latitude,
                                            _userLocation!.longitude,
                                          ),
                                          width: 80,
                                          height: 80,
                                          child: Container(
                                            child: const Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                          rotate: true,
                                        ),
                                      // Marker untuk lokasi banjir
                                      if (_floodData != null)
                                        ..._floodData!.map<Marker>((flood) {
                                          final statusColor = _getStatusColor(
                                              flood['kategori_kedalaman']);
                                          return Marker(
                                            point: LatLng(
                                              double.parse(
                                                  flood['koordinat_lokasi']['y']
                                                      .toString()),
                                              double.parse(
                                                  flood['koordinat_lokasi']['x']
                                                      .toString()),
                                            ),
                                            width: 40,
                                            height: 40,
                                            rotate: true,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: statusColor
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                Center(
                                                  child: Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: statusColor,
                                                    ),
                                                    child: const Icon(
                                                      Icons.water,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                    ],
                                    height: 300,
                                  ),
                  ),
                ),
                const SizedBox(height: 16),
                // Flood cards from API data using FloodInfoCard
                if (!_isLoading &&
                    _floodData != null &&
                    _floodData!.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _floodData!.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final flood = _floodData![index];
                        return FloodInfoCard(
                          floodData: flood,
                          userLocation: _userLocation,
                          getStatusColor: _getStatusColor,
                        );
                      },
                    ),
                  ),
                ] else if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  const Center(child: Text('Tidak ada data banjir terkini')),
              ] else ...[
                // Riwayat Banjir dari API (still using old flood list for now)
                if (!_isLoading && _floodData != null) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    // This part still uses the old approach, will update if needed
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _floodData!.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final flood = _floodData![index];
                        return FloodInfoCard(
                          floodData: flood,
                          userLocation: _userLocation,
                          getStatusColor: _getStatusColor,
                        );
                      },
                    ),
                  ),
                ] else if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  const Center(child: Text('Tidak ada data riwayat banjir')),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDistance(double lat, double lng) {
    if (_userLocation == null) return 'Lokasi tidak tersedia';

    double distanceInMeters = Geolocator.distanceBetween(
        _userLocation!.latitude, _userLocation!.longitude, lat, lng);

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} meter';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} Km dari lokasi anda';
    }
  }
}
