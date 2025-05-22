import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../api_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Tambahkan import ini

class CuacaScreen extends StatefulWidget {
  const CuacaScreen({super.key});

  @override
  State<CuacaScreen> createState() => _CuacaScreenState();
}

class _CuacaScreenState extends State<CuacaScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _weatherData;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) => _fetchWeatherData());
  }

  Future<void> _fetchWeatherData() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.appUrl}/cuaca'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _weatherData = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Gagal mengambil data cuaca');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getWeatherIcon(String condition) {
    // Map BMKG weather conditions to our icon assets
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

  Widget _buildCurrentWeather() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Text(
          _error,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final locationData = _weatherData!['lokasi'];
    final weatherData = _weatherData!['data'][0]['cuaca'][0][0];
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');
    final formattedDate = dateFormat.format(now);

    // Convert wind speed from m/s to km/h (1 m/s = 3.6 km/h)
    final windSpeedKmh = (weatherData['ws'] * 3.6).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF62B8F6), Color(0xFF2C79C1)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weatherData['t']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '°C',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              SvgPicture.asset(
                'assets/images/weather/${_getWeatherIcon(weatherData['weather_desc'])}.svg',
                width: 80,
                height: 80,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ],
          ),
          Text(
            weatherData['weather_desc'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWeatherInfo(
                  Icons.air, 'Kec. Angin', '$windSpeedKmh km/jam'),
              const SizedBox(width: 24),
              _buildWeatherInfo(Icons.water_drop_outlined, 'Kelembapan',
                  '${weatherData['hu']} %'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningCard() {
    if (_isLoading || _error.isNotEmpty) {
      return const SizedBox.shrink();
    }

    final todayForecast = _weatherData!['data'][0]['cuaca'][0];
    final List<String> warnings = [];

    // Cek kondisi hujan sedang
    for (var forecast in todayForecast) {
      if (forecast['weather_desc'].toString().toLowerCase() == 'hujan sedang') {
        final localTime = DateTime.parse(forecast['local_datetime']).toLocal();
        final timeFormat = DateFormat('HH:mm');
        final formattedTime = timeFormat.format(localTime);
        
        warnings.add('Bawalah payung, hujan dengan intensitas sedang mungkin terjadi pada pukul $formattedTime WIB');
      }
    }

    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Peringatan dini!\n',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: warnings.join('\n'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast() {
    if (_isLoading || _error.isNotEmpty) {
      return const SizedBox.shrink();
    }

    final todayForecast = _weatherData!['data'][0]['cuaca'][0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hari Ini',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: todayForecast.map<Widget>((forecast) {
              final localTime =
                  DateTime.parse(forecast['local_datetime']).toLocal();
              final timeFormat = DateFormat('HH:mm');
              return _buildHourlyWeatherCard(
                timeFormat.format(localTime),
                '${forecast['t']}°C',
                _getWeatherIcon(forecast['weather_desc']),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyWeatherCard(String time, String temp, String icon) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF979797)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          SvgPicture.asset(
            'assets/images/weather/$icon.svg',
            width: 32,
            height: 32,
          ),
          const SizedBox(height: 8),
          Text(
            temp,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyForecast() {
    if (_isLoading || _error.isNotEmpty) {
      return const SizedBox.shrink();
    }

    final allForecasts = _weatherData!['data'][0]['cuaca'];
    final dateFormat = DateFormat('MMM, d', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hari Berikutnya',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...allForecasts.map((dayForecast) {
          final firstForecast = dayForecast[0];
          final date =
              DateTime.parse(firstForecast['local_datetime']).toLocal();
          return _buildDailyWeatherRow(
            dateFormat.format(date),
            _getWeatherIcon(firstForecast['weather_desc']),
            '${firstForecast['t']}°',
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDailyWeatherRow(String date, String icon, String temp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SvgPicture.asset(
                'assets/images/weather/$icon.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              temp,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Cuaca',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCurrentWeather(),
              const SizedBox(height: 16),
              _buildWarningCard(),
              const SizedBox(height: 24),
              _buildHourlyForecast(),
              const SizedBox(height: 24),
              _buildDailyForecast(),
            ],
          ),
        ),
      ),
    );
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
