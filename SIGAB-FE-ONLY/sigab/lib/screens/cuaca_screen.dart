import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CuacaScreen extends StatelessWidget {
  const CuacaScreen({super.key});

  Widget _buildCurrentWeather() {
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
            'Rabu, 9 April 2025',
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
              const Text(
                '23',
                style: TextStyle(
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
                'assets/images/weather/cloudy_rain.svg',
                width: 80,
                height: 80,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ],
          ),
          const Text(
            'Hujan Deras',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWeatherInfo(Icons.air, 'Kec. Angin', '15 km/jam'),
              const SizedBox(width: 24),
              _buildWeatherInfo(
                  Icons.water_drop_outlined, 'Kelembapan', '25 %'),
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
                    text:
                        '(Bawalah payung, badai berpetir mungkin terjadi pada pukul 13.00 WIB)',
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
            children: [
              _buildHourlyWeatherCard('14.00', '22°C', 'cloudy_rain'),
              _buildHourlyWeatherCard('15.00', '22°C', 'cloudy_rain'),
              _buildHourlyWeatherCard('16.00', '21°C', 'cloudy_rain'),
              _buildHourlyWeatherCard('17.00', '21°C', 'cloudy'),
              _buildHourlyWeatherCard('18.00', '21°C', 'cloudy'),
              _buildHourlyWeatherCard('19.00', '22°C', 'cloudy'),
            ],
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
        _buildDailyWeatherRow('Apr, 10', 'cloudy_rain', '21°'),
        _buildDailyWeatherRow('Apr, 11', 'sunny', '26°'),
        _buildDailyWeatherRow('Apr, 12', 'cloudy', '25°'),
        _buildDailyWeatherRow('Apr, 13', 'rainy', '21°'),
        _buildDailyWeatherRow('Apr, 14', 'cloudy_rain', '21°'),
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
