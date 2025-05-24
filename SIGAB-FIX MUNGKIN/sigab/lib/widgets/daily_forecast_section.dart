import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class DailyForecastSection extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final bool isLoading;
  final String error;
  final String Function(String) getWeatherIcon;

  const DailyForecastSection({
    Key? key,
    required this.weatherData,
    required this.isLoading,
    required this.error,
    required this.getWeatherIcon,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    if (isLoading || error.isNotEmpty || weatherData == null) {
      return const SizedBox.shrink();
    }

    final allForecasts = weatherData!['data'][0]['cuaca'];
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
            getWeatherIcon(firstForecast['weather_desc']),
            '${firstForecast['t']}°',
          );
        }).toList(),
      ],
    );
  }
}
