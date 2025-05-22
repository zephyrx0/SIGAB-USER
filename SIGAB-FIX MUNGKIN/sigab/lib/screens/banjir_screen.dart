import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter_map/flutter_map.dart';
import 'dart:ui' show Path;
import 'riwayat_banjir_screen.dart';
import '../api_service.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchFloodData();
  }

  Future<void> _fetchFloodData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final data = await ApiService.getFloodData();
      
      // Sort data berdasarkan waktu kejadian
      final List sortedData = (data['data'] as List).toList()
        ..sort((a, b) => DateTime.parse(b['waktu_kejadian'])
            .compareTo(DateTime.parse(a['waktu_kejadian'])));

      setState(() {
        _floodData = sortedData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
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

  Widget _buildFloodList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_error),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchFloodData,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_floodData == null || _floodData!.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada data banjir',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _floodData!.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final flood = _floodData![index];
        final DateTime waktu = DateTime.parse(flood['waktu_kejadian']);
        
        return _buildFloodCard(
          date: '${waktu.day}-${waktu.month}-${waktu.year}',
          time: '${waktu.hour}:${waktu.minute}',
          location: flood['wilayah_banjir'],
          depth: flood['tingkat_kedalaman'],
          statusColor: _getStatusColor(flood['kategori_kedalaman']),
          status: flood['kategori_kedalaman'],
          coordinates: flood['koordinat_lokasi'], // Tambah parameter koordinat
        );
      },
    );
  }
  Widget _buildFloodCard({
    required String date,
    required String time,
    required String location,
    required String depth,
    required Color statusColor,
    required String status,
    required Map<String, dynamic> coordinates, // Tambah parameter koordinat
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // Share logic
                },
                icon: const Icon(Icons.share, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Banjir',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$date, $time WIB',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Kedalaman Banjir: $status',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.height, color: Colors.orange, size: 24),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Kedalaman Banjir',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        depth,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.swap_horiz, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jarak',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    _calculateDistance(
                      double.parse(coordinates['y'].toString()),
                      double.parse(coordinates['x'].toString())
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.flag, color: Colors.orange, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wilayah Banjir',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Header with title
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
            // Map Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _floodData != null && _floodData!.isNotEmpty
                    ? FlutterMap(
                        options: MapOptions(
                          center: LatLng(
                            _floodData![0]['koordinat_lokasi']['y'],
                            _floodData![0]['koordinat_lokasi']['x'],
                          ),
                          zoom: 14,
                          minZoom: 5,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.sigab.app',
                          ),
                          // Tambah marker untuk lokasi user
                          if (_userLocation != null) MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  _userLocation!.latitude,
                                  _userLocation!.longitude,
                                ),
                                width: 80,
                                height: 80,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_pin_circle,
                                    color: Colors.blue,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          MarkerLayer(
                            markers: _floodData!.map<Marker>((flood) {
                              return Marker(
                                point: LatLng(
                                  double.parse(flood['koordinat_lokasi']['y'].toString()),
                                  double.parse(flood['koordinat_lokasi']['x'].toString()),
                                ),
                                width: 80,
                                height: 80,
                                child: Icon(
                                  Icons.location_on,
                                  color: _getStatusColor(flood['kategori_kedalaman']),
                                  size: 40,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      )
                    : const Center(child: Text('Tidak ada data lokasi banjir')),
              ),
            ),
            const SizedBox(height: 16),
            // Flood cards from API data
            if (!_isLoading && _floodData != null && _floodData!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildFloodList(),
              )
            else if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              const Center(child: Text('Tidak ada data banjir terkini')),
          ] else ...[
            // Riwayat Banjir dari API
            if (!_isLoading && _floodData != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildFloodList(),
              )
            else if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              const Center(child: Text('Tidak ada data riwayat banjir')),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
  try {
    // Cek permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    
    // Dapatkan posisi saat ini
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    
    setState(() {
      _userLocation = position;
    });
  } catch (e) {
    print('Error mendapatkan lokasi: $e');
  }
}

String _calculateDistance(double lat, double lng) {
  if (_userLocation == null) return 'Lokasi tidak tersedia';
  
  double distanceInMeters = Geolocator.distanceBetween(
    _userLocation!.latitude,
    _userLocation!.longitude,
    lat,
    lng
  );
  
  if (distanceInMeters < 1000) {
    return '${distanceInMeters.toStringAsFixed(0)} meter';
  } else {
    double distanceInKm = distanceInMeters / 1000;
    return '${distanceInKm.toStringAsFixed(1)} km';
  }
}
}

class WavePainter extends CustomPainter {
  final Color color;

  WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    // First wave
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.25,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.5,
    );

    // Second wave
    path.cubicTo(
      size.width * 0.75,
      size.height * 0.25,
      size.width * 0.75,
      size.height * 0.75,
      size.width,
      size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}





