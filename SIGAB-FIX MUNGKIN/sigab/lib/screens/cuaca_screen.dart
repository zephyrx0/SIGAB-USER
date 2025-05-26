// cuaca_screen.dart

import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sigab/widgets/unified_weather_card.dart';
import 'package:sigab/widgets/hourly_forecast_section.dart';
import 'package:sigab/widgets/daily_forecast_section.dart';

class CuacaScreen extends StatefulWidget {
  const CuacaScreen({super.key});

  @override
  State<CuacaScreen> createState() => _CuacaScreenState();
}

class _CuacaScreenState extends State<CuacaScreen> {
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _weatherData;
  bool _hasRainForecastToday = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) => _fetchWeatherData());
  }

  Future<void> _fetchWeatherData() async {
    try {
      final data = await ApiService.getWeather();
      if (!mounted) return;

      // debugPrint('DEBUG Cuaca: Weather data received: $data');

      setState(() {
        _weatherData = data;
        _isLoading = false;
      });

      _checkRainForecast();

      debugPrint(
          'DEBUG Cuaca: After _checkRainForecast, _hasRainForecastToday: $_hasRainForecastToday');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _hasRainForecastToday = false;
      });
    }
  }

  void _checkRainForecast() {
    debugPrint('DEBUG Cuaca: Starting rain forecast check');

    if (_weatherData == null) {
      debugPrint('DEBUG Cuaca: _weatherData is null');
      setState(() {
        _hasRainForecastToday = false;
      });
      return;
    }

    debugPrint(
        'DEBUG Cuaca: _weatherData structure: ${_weatherData!.keys.toList()}');

    final data = _weatherData!['data'];
    if (data == null || !(data is List) || data.isEmpty) {
      debugPrint('DEBUG Cuaca: data is null or empty: $data');
      setState(() {
        _hasRainForecastToday = false;
      });
      return;
    }

    debugPrint('DEBUG Cuaca: data length: ${data.length}');
    final firstItem = data.first;
    debugPrint('DEBUG Cuaca: First item keys: ${firstItem.keys.toList()}');

    final cuaca = firstItem['cuaca'];
    if (cuaca == null || !(cuaca is List) || cuaca.isEmpty) {
      debugPrint('DEBUG Cuaca: cuaca is null or not a list: $cuaca');
      setState(() {
        _hasRainForecastToday = false;
      });
      return;
    }

    debugPrint('DEBUG Cuaca: Processing ${cuaca.length} forecast periods');
    bool rainFound = false;
    final now = DateTime.now();
    debugPrint('DEBUG Cuaca: Current time: $now');

    // Get the first period's forecasts (today's forecasts)
    final todayForecasts = cuaca[0];
    if (!(todayForecasts is List)) {
      debugPrint(
          'DEBUG Cuaca: Today\'s forecasts is not a list: $todayForecasts');
      setState(() {
        _hasRainForecastToday = false;
      });
      return;
    }

    debugPrint(
        'DEBUG Cuaca: Processing ${todayForecasts.length} forecasts for today');

    for (var forecast in todayForecasts) {
      if (!(forecast is Map)) {
        debugPrint('DEBUG Cuaca: Forecast is not a map: $forecast');
        continue;
      }

      final weatherDesc =
          forecast['weather_desc']?.toString().toLowerCase() ?? '';
      final weatherCode = forecast['weather'];
      final localDatetimeStr = forecast['local_datetime']?.toString() ?? '';

      debugPrint(
          'DEBUG Cuaca: Checking forecast - desc: $weatherDesc, code: $weatherCode, datetime: $localDatetimeStr');

      final forecastDate = DateTime.tryParse(localDatetimeStr);
      if (forecastDate == null) {
        debugPrint('DEBUG Cuaca: Failed to parse date: $localDatetimeStr');
        continue;
      }

      final duration = forecastDate.difference(now);
      final isWithinNext24Hours =
          duration.inHours >= 0 && duration.inHours <= 24;

      debugPrint(
          'DEBUG Cuaca: Forecast time difference: ${duration.inHours} hours');

      if (isWithinNext24Hours &&
          (weatherDesc.contains('hujan') ||
              (weatherCode is int && weatherCode >= 60))) {
        debugPrint(
            'DEBUG Cuaca: Rain found for next 24 hours! Description: $weatherDesc, Code: $weatherCode');
        rainFound = true;
        break;
      }
    }

    debugPrint('DEBUG Cuaca: Final rain forecast result: $rainFound');
    setState(() {
      _hasRainForecastToday = rainFound;
    });
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

  Widget _buildRainWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Peringatan: Diperkirakan terjadi hujan hari ini. Siapkan payung Anda!',
              style: TextStyle(
                color: Colors.white,
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
    debugPrint(
        'DEBUG Cuaca Build: Checking rain warning condition. _hasRainForecastToday: $_hasRainForecastToday, _isLoading: $_isLoading, _error.isEmpty: ${_error.isEmpty}');

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
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
                  warningMessage: '',
                  getWeatherIcon: _getWeatherIcon,
                ),
              if (_hasRainForecastToday && !_isLoading && _error.isEmpty)
                Column(
                  children: [
                    _buildRainWarningCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              const SizedBox(height: 24),
              HourlyForecastSection(
                weatherData: _weatherData,
                isLoading: _isLoading,
                error: _error,
                getWeatherIcon: _getWeatherIcon,
              ),
              const SizedBox(height: 24),
              DailyForecastSection(
                weatherData: _weatherData,
                isLoading: _isLoading,
                error: _error,
                getWeatherIcon: _getWeatherIcon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
