import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter_map/flutter_map.dart';
import 'package:sigab/widgets/map_widget.dart';
import 'lapor_screen.dart' hide WavePainter;
import 'banjir_screen.dart' hide WavePainter;
import 'cuaca_screen.dart' hide WavePainter;
import 'lainnya_screen.dart';
import 'tempat_evakuasi_screen.dart' hide WavePainter;
import 'tips_mitigasi_screen.dart' hide WavePainter;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sigab/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigab/widgets/flood_info_card.dart';
import 'package:sigab/widgets/notification_dialog.dart';
import 'package:sigab/widgets/other_section.dart';
import 'package:sigab/widgets/unified_weather_card.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _weatherData;
  Map<String, dynamic>? _floodData;
  Position? _userLocation;
  LatLng _mapCenter =
      const LatLng(-6.914744, 107.609810); // Default Bandung center
  double _mapZoom = 12.0; // Default zoom

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) => _fetchWeatherData());
    _fetchFloodData();
    _getUserLocation();
  }

  // Fungsi untuk menghitung pusat dan zoom peta berdasarkan lokasi pengguna dan data banjir
  void _calculateMapCenterAndZoom() {
    List<LatLng> points = [];

    if (_userLocation != null) {
      points.add(LatLng(_userLocation!.latitude, _userLocation!.longitude));
    }

    if (_floodData != null &&
        _floodData!['koordinat_lokasi'] != null &&
        _floodData!['koordinat_lokasi']['x'] != null &&
        _floodData!['koordinat_lokasi']['y'] != null) {
      try {
        final double floodLat =
            double.parse(_floodData!['koordinat_lokasi']['y'].toString());
        final double floodLng =
            double.parse(_floodData!['koordinat_lokasi']['x'].toString());
        points.add(LatLng(floodLat, floodLng));
      } catch (e) {
        print('Error parsing flood coordinates: $e');
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
      // Jika ada dua titik (user dan banjir),
      // hitung bounding box dan pusatnya
      final bounds = LatLngBounds.fromPoints(points);
      _mapCenter = bounds.center;

      // Hitung zoom level agar kedua titik terlihat. Ini pendekatan sederhana,
      // zoom yang lebih akurat butuh perhitungan jarak dan ukuran layar.
      final distance =
          const Distance().as(LengthUnit.Kilometer, points[0], points[1]);
      if (distance < 1) {
        // Jika jarak kurang dari 1 km
        _mapZoom = 15.0;
      } else if (distance < 5) {
        // Jika jarak 1-5 km
        _mapZoom = 14.0;
      } else if (distance < 10) {
        // Jika jarak 5-10 km
        _mapZoom = 13.0;
      } else {
        // Jika jarak lebih dari 10 km
        _mapZoom = 12.0;
      }
    }
  }

  Future<void> _fetchWeatherData() async {
    try {
      final data = await ApiService.getWeather();
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFloodData() async {
    try {
      final latestInfo = await ApiService.getLatestFloodInfo();
      setState(() {
        _floodData = latestInfo;
        // Setelah data banjir didapat, hitung ulang pusat dan zoom peta
        _calculateMapCenterAndZoom();
      });
    } catch (e) {
      print('Error fetching latest flood data: $e');
      setState(() {
        _calculateMapCenterAndZoom(); // Tetap hitung jika hanya user location yang ada
      });
    }
  }

  Future<void> _getUserLocation() async {
    try {
      _userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        // Setelah lokasi user didapat, hitung ulang pusat dan zoom peta
        _calculateMapCenterAndZoom();
      });
    } catch (e) {
      print('Error getting user location: $e');
      setState(() {
        _calculateMapCenterAndZoom(); // Tetap hitung jika hanya flood data yang ada
      });
    }
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'hujan lebat':
      case 'hujan deras':
        return 'rainy';
      case 'hujan ringan':
      case 'hujan':
        return 'cloudy_rain';
      case 'berawan':
        return 'cloudy';
      case 'cerah berawan':
        return 'partly_cloudy';
      case 'cerah':
        return 'sunny';
      default:
        return 'cloudy';
    }
  }

  Widget _buildLinksOutIcon({double size = 20, Color color = Colors.black54}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Transform.translate(
              offset: const Offset(3, -3),
              child: Icon(
                Icons.arrow_outward,
                size: size * 0.8,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> resetFloodNotificationDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastFloodNotificationDateReports');
    await prefs.remove('lastFloodInfoNotificationTimestamp');

    final verifyReports = prefs.getString('lastFloodNotificationDateReports');
    final verifyInfo = prefs.getString('lastFloodInfoNotificationTimestamp');
    debugPrint(
        'DEBUG Reset: After reset, lastFloodNotificationDateReports: $verifyReports');
    debugPrint(
        'DEBUG Reset: After reset, lastFloodInfoNotificationTimestamp: $verifyInfo');

    debugPrint(
        'DEBUG: All flood notification dates/timestamps reset in SharedPreferences.');
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
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    const Expanded(
                      child: Text(
                        'Beranda',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, size: 28),
                      padding: const EdgeInsets.all(8),
                      onPressed: () async {
                        try {
                          final notifications = await NotificationService()
                              .getNotificationHistory();
                          if (!mounted) return;

                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return NotificationDialog(
                                notifications: notifications,
                              );
                            },
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal memuat notifikasi: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weather Card
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error.isNotEmpty)
                Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (_weatherData != null)
                UnifiedWeatherCard(
                  weatherData: _weatherData,
                  warningMessage: _buildWarningMessage(),
                  getWeatherIcon: _getWeatherIcon,
                ),
              const SizedBox(height: 16),

              // Warning Card
              // Note: The warning is now part of UnifiedWeatherCard,
              // so we remove the separate WarningCard here.
              // if (_buildWarningMessage().isNotEmpty)
              //   WarningCard(message: _buildWarningMessage()),
              // const SizedBox(height: 24),
              const SizedBox(height: 24),

              // Banjir Terkini Section
              const Text(
                'Banjir Terkini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              MapWidget(
                // Menggunakan pusat dan zoom yang dihitung
                center: _mapCenter,
                zoom: _mapZoom,
                markers: [
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
                  if (_floodData != null &&
                      _floodData!['koordinat_lokasi'] != null &&
                      _floodData!['koordinat_lokasi']['x'] != null &&
                      _floodData!['koordinat_lokasi']['y'] != null)
                    Marker(
                      point: LatLng(
                          double.parse(
                              _floodData!['koordinat_lokasi']['y'].toString()),
                          double.parse(
                              _floodData!['koordinat_lokasi']['x'].toString())),
                      width: 40,
                      height: 40,
                      rotate: true,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStatusColor(
                                      _floodData!['kategori_kedalaman'] ?? '')
                                  .withOpacity(0.3),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _getStatusColor(
                                    _floodData!['kategori_kedalaman'] ?? ''),
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
                    ),
                ],
                height: 200,
              ),
              const SizedBox(height: 24),

              // Banjir Info Card
              if (_floodData != null)
                FloodInfoCard(
                  floodData: _floodData,
                  userLocation: _userLocation,
                  getStatusColor: _getStatusColor,
                )
              else if (!_isLoading)
                const Center(
                  child: Text(
                    'Tidak ada data banjir terbaru',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Other Section
              OtherSection(
                onEvakuasiTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TempatEvakuasiScreen(),
                    ),
                  );
                },
                onMitigasiTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TipsMitigasiScreen(),
                    ),
                  );
                },
                onResetTap: () async {
                  await resetFloodNotificationDate();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Semua notifikasi banjir testing reset!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildWarningMessage() {
    if (_weatherData == null) return '';

    final todayForecast = _weatherData!['data'][0]['cuaca'][0];
    int consecutiveRainHours = 0;
    DateTime? rainStartTime;
    String? rainType;
    DateTime? lastRainTime;

    for (var forecast in todayForecast) {
      final weatherDesc = forecast['weather_desc'].toString().toLowerCase();
      final localTime = DateTime.parse(forecast['local_datetime']).toLocal();

      if (weatherDesc.contains('hujan')) {
        if (rainStartTime == null) {
          rainStartTime = localTime;
          rainType = weatherDesc;
        }
        lastRainTime = localTime;
        consecutiveRainHours++;
      } else {
        rainStartTime = null;
        consecutiveRainHours = 0;
        lastRainTime = null;
      }
    }

    if (consecutiveRainHours >= 3 &&
        rainStartTime != null &&
        lastRainTime != null) {
      final timeFormat = DateFormat('HH:mm');
      final startTime = timeFormat.format(rainStartTime);
      final endTime = timeFormat.format(lastRainTime);
      return 'Hujan $rainType diperkirakan terjadi selama $consecutiveRainHours jam dari pukul $startTime hingga $endTime WIB. Lakukan mitigasi banjir.';
    }

    return '';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
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
}
