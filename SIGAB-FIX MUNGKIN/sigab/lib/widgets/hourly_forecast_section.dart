import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class HourlyForecastSection extends StatelessWidget {
  final Map<String, dynamic>? weatherData;
  final bool isLoading;
  final String error;
  final String Function(String) getWeatherIcon;

  const HourlyForecastSection({
    Key? key,
    required this.weatherData,
    required this.isLoading,
    required this.error,
    required this.getWeatherIcon,
  }) : super(key: key);

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

    final List<dynamic> rawForecasts = firstDataItem['cuaca'] as List<dynamic>;

    if (rawForecasts.isEmpty) {
      return const SizedBox
          .shrink(); // Handle case with no forecast data periods
    }

    // Ambil hanya daftar perkiraan per jam untuk hari pertama
    final dynamic todayHourlyForecastsRaw =
        rawForecasts.isNotEmpty ? rawForecasts[0] : null;
    if (todayHourlyForecastsRaw is! List || todayHourlyForecastsRaw.isEmpty) {
      debugPrint(
          'DEBUG Hourly: Today hourly forecasts item is not a List or is empty: $todayHourlyForecastsRaw');
      return const SizedBox
          .shrink(); // Handle jika data tidak sesuai atau kosong
    }
    final List<dynamic> todayHourlyForecasts =
        todayHourlyForecastsRaw as List<dynamic>; // Cast ke List<dynamic>

    // debugPrint('DEBUG Hourly: Data for hourly cards: $todayHourlyForecasts');

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Hari Ini',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: todayHourlyForecasts.map<Widget>((forecast) {
                if (forecast is! Map<String, dynamic>) {
                  debugPrint(
                      'DEBUG Hourly: Forecast item is not a Map: $forecast');
                  return const SizedBox
                      .shrink(); // Kembalikan widget kosong jika tipe tidak sesuai
                }

                final localTime =
                    DateTime.parse(forecast['local_datetime']).toLocal();
                final timeFormat = DateFormat('HH:mm');

                return _buildHourlyWeatherCard(
                  timeFormat.format(localTime),
                  '${forecast['t']}°C',
                  getWeatherIcon(forecast['weather_desc']),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
