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
import 'package:sigab/utils/wave_painter.dart';
import 'package:sigab/widgets/unified_weather_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  Position? _userLocation;

  final List<Widget> _screens = [
    const HomeContent(),
    const CuacaScreen(),
    const LaporScreen(),
    const BanjirScreen(),
    const LainnyaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF016FB9),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined),
              activeIcon: Icon(Icons.wb_sunny),
              label: 'Cuaca',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedIndex == 2
                      ? const Color(0xFF016FB9)
                      : Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              label: 'Lapor',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: WavePainter(
                    color: _selectedIndex == 3
                        ? const Color(0xFF016FB9)
                        : Colors.grey,
                  ),
                ),
              ),
              label: 'Banjir',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Lainnya',
            ),
          ],
        ),
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) => _fetchWeatherData());
    _fetchFloodData();
    _getUserLocation();
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
      });
    } catch (e) {
      print('Error fetching latest flood data: $e');
    }
  }

  Future<void> _getUserLocation() async {
    try {
      _userLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {});
    } catch (e) {
      print('Error getting user location: $e');
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
                  getWeatherIcon: _getWeatherIcon,
                  warningMessage: _buildWarningMessage(),
                )
              else if (!_isLoading && _error.isEmpty)
                const SizedBox.shrink(),
              const SizedBox(height: 16),

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
                center: (_floodData != null)
                    ? LatLng(_floodData!['koordinat_lokasi']['y'],
                        _floodData!['koordinat_lokasi']['x'])
                    : const LatLng(-6.975353, 107.629601),
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
                  if (_floodData != null)
                    Marker(
                      point: LatLng(_floodData!['koordinat_lokasi']['y'],
                          _floodData!['koordinat_lokasi']['x']),
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
                zoom: 14,
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

    final dynamic weatherDataOuter = _weatherData!['data'];
    if (weatherDataOuter == null ||
        weatherDataOuter['data'] is! List ||
        weatherDataOuter['data'].isEmpty) return '';

    final dynamic locationData = weatherDataOuter['data'][0];
    if (locationData == null ||
        locationData['cuaca'] is! List ||
        locationData['cuaca'].isEmpty) return '';

    final dynamic hourlyForecastsListRaw = locationData['cuaca'][0];
    if (hourlyForecastsListRaw is! List) return '';

    final List<dynamic> todayForecast = hourlyForecastsListRaw;

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
