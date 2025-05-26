import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class UnifiedWeatherCard extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final String warningMessage;
  final String Function(String) getWeatherIcon;
  final bool isLoading;
  final String error;

  const UnifiedWeatherCard({
    Key? key,
    required this.weatherData,
    required this.warningMessage,
    required this.getWeatherIcon,
    this.isLoading = false,
    this.error = '',
  }) : super(key: key);

  Widget _buildWeatherInfo(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the correct list of weather data: weatherData['data']['data']
    final dynamic dataInnerListRaw = weatherData?['data']?['data'];

    if (isLoading ||
        error.isNotEmpty ||
        weatherData == null ||
        dataInnerListRaw is! List ||
        dataInnerListRaw.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<dynamic> dataList = dataInnerListRaw as List<dynamic>;
    final dynamic firstDataItem = dataList.isNotEmpty ? dataList.first : null;

    if (firstDataItem == null ||
        firstDataItem is! Map ||
        firstDataItem['cuaca'] is! List) {
      return const SizedBox.shrink();
    }

    final List<dynamic> todayForecasts =
        firstDataItem['cuaca'] as List<dynamic>;

    if (todayForecasts.isEmpty) {
      return const SizedBox.shrink(); // Handle case with no forecast data
    }
    final dynamic firstPeriodForecasts =
        todayForecasts.isNotEmpty ? todayForecasts[0] : null;
    if (firstPeriodForecasts is! List || firstPeriodForecasts.isEmpty) {
      return const SizedBox
          .shrink(); // Handle jika list pertama tidak valid atau kosong
    }
    final dynamic weatherInfo = firstPeriodForecasts.isNotEmpty
        ? firstPeriodForecasts[0]
        : null; // Ambil objek Map pertama dari List tersebut

    if (weatherInfo == null || weatherInfo is! Map) {
      return const SizedBox.shrink(); // Handle jika weatherInfo tidak valid
    }

    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');
    final formattedDate = dateFormat.format(now);
    final windSpeedKmh = (weatherInfo['ws'] * 3.6).round();

    return Column(
      children: [
        // Current Weather Card
        Container(
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
                    '${weatherInfo['t']}',
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
                    'assets/images/weather/${getWeatherIcon(weatherInfo['weather_desc'])}.svg',
                    width: 80,
                    height: 80,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  ),
                ],
              ),
              Text(
                weatherInfo['weather_desc'],
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
                  _buildWeatherInfo(Icons.air, 'Kec. Angin',
                      '$windSpeedKmh km/jam', Colors.white),
                  const SizedBox(width: 24),
                  _buildWeatherInfo(Icons.water_drop_outlined, 'Kelembapan',
                      '${weatherInfo['hu']} %', Colors.white),
                ],
              ),
            ],
          ),
        ),
        // Warning Card (if warning message is not empty)
        if (warningMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
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
                            text: warningMessage,
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
            ),
          ),
      ],
    );
  }
}
