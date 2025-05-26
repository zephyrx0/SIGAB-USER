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

    final List<dynamic> allHourlyForecasts =
        firstDataItem['cuaca'] as List<dynamic>;

    if (allHourlyForecasts.isEmpty) {
      return const SizedBox
          .shrink(); // Handle case with no forecast data periods
    }

    final dateFormatDisplay = DateFormat('MMM, d', 'id_ID');
    final dateFormatGrouping = DateFormat(
        'yyyy-MM-dd'); // Format untuk mengelompokkan berdasarkan tanggal

    // Mengelompokkan perkiraan per jam dari struktur List bersarang berdasarkan hari
    Map<String, Map<String, dynamic>> dailyForecasts = {};
    // Loop melalui setiap daftar perkiraan (misal per hari atau periode)
    for (var periodForecasts in allHourlyForecasts) {
      // Tambahkan pengecekan tipe data untuk setiap daftar periode
      if (periodForecasts is! List) {
        debugPrint(
            'DEBUG Daily: Period forecasts item is not a List: $periodForecasts');
        continue; // Lewati item yang tidak sesuai tipe
      }

      // Loop melalui setiap perkiraan cuaca (per jam) di dalam daftar periode
      for (var forecast in periodForecasts) {
        // Tambahkan pengecekan tipe data untuk setiap item forecast
        if (forecast is! Map<String, dynamic>) {
          debugPrint('DEBUG Daily: Forecast item is not a Map: $forecast');
          continue; // Lewati item yang tidak sesuai tipe
        }

        final localTimeStr = forecast['local_datetime']?.toString() ?? '';
        final localTime = DateTime.tryParse(localTimeStr);
        if (localTime == null) continue; // Skip if date is invalid

        final dateKey = dateFormatGrouping.format(localTime);
        // Ambil perkiraan pertama untuk setiap hari sebagai representasi harian
        if (!dailyForecasts.containsKey(dateKey)) {
          dailyForecasts[dateKey] = forecast;
        }
      }
    }

    // Menampilkan baris untuk setiap hari
    final dailyForecastRows = dailyForecasts.entries.map((entry) {
      final forecast =
          entry.value; // Gunakan 'entry.value' yang sudah divalidasi Map
      // Tambahkan pengecekan tambahan di sini jika diperlukan untuk mengakses properti 'forecast'
      final dateKey = entry.key; // Gunakan dateKey yang sudah valid
      final date = DateTime.tryParse(dateKey); // Parse dateKey to DateTime
      if (date == null)
        return const SizedBox.shrink(); // Skip if dateKey is invalid

      return _buildDailyWeatherRow(
        dateFormatDisplay.format(date),
        getWeatherIcon(
            forecast['weather_desc'] ?? ''), // Add null check for weather_desc
        '${forecast['t'] ?? '--'}°', // Add null check for temperature
      );
    }).toList();

    // Tambahkan pengecekan jika dailyForecastRows kosong setelah diproses
    if (dailyForecastRows.isEmpty) {
      return const SizedBox.shrink();
    }

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
        ...dailyForecastRows, // Menggunakan daftar baris perkiraan harian yang sudah diproses
      ],
    );
  }
}
