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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) => _fetchWeatherData());
  }

  Future<void> _fetchWeatherData() async {
    try {
      final data = await ApiService.getWeather();
      setState(() {
        if (!mounted) return;
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      case 'cerah':
        return 'sunny';
      default:
        return 'cloudy';
    }
  }

  String _buildWarningMessage() {
    if (_weatherData == null) return '';

    final todayForecast = _weatherData!['data'][0]['cuaca'][0];
    final List<String> warnings = [];

    // Cek kondisi hujan sedang
    for (var forecast in todayForecast) {
      if (forecast['weather_desc'].toString().toLowerCase() == 'hujan sedang') {
        final localTime = DateTime.parse(forecast['local_datetime']).toLocal();
        final timeFormat = DateFormat('HH:mm');
        final formattedTime = timeFormat.format(localTime);

        warnings.add(
            'Bawalah payung, hujan dengan intensitas sedang mungkin terjadi pada pukul $formattedTime WIB');
      }
    }

    return warnings.join('\n');
  }

  @override
  Widget build(BuildContext context) {
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
              // Use UnifiedWeatherCard for current weather and warning
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
              const SizedBox(height: 24),
              // Hourly forecast section
              HourlyForecastSection(
                weatherData: _weatherData,
                isLoading: _isLoading,
                error: _error,
                getWeatherIcon: _getWeatherIcon,
              ),
              const SizedBox(height: 24),
              // Daily forecast section
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
