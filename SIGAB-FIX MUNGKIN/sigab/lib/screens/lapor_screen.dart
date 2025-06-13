import 'package:flutter/material.dart';
import 'package:sigab/api_service.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:permission_handler/permission_handler.dart';
import 'laporan_banjir_screen.dart';
import 'laporan_infrastruktur_screen.dart';

class LaporScreen extends StatelessWidget {
  const LaporScreen({super.key});

  Future<void> _makePhoneCall(BuildContext context) async {
    try {
      // Request phone permission
      final status = await Permission.phone.request();
      if (status.isGranted) {
        final Uri url = Uri.parse('tel://119'); // Using tel:// format
        debugPrint('DEBUG: Attempting to launch URL: $url');

        if (await launcher.canLaunchUrl(url)) {
          debugPrint('DEBUG: Can launch URL, proceeding...');
          await launcher.launchUrl(url);
          debugPrint('DEBUG: URL launched successfully');
        } else {
          debugPrint('DEBUG: Cannot launch URL');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tidak dapat membuka aplikasi telepon'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Izin telepon diperlukan untuk melakukan panggilan'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('DEBUG: Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showKASIDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade50,
                  ),
                  child: const Icon(
                    Icons.phone,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Telpon KASI Kesejahteraan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Anda akan diarahkan ke kontak\nKASI Kesejahteraan untuk melakukan pelaporan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Kembali',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _makePhoneCall(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA726),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'OK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF62B8F6), Color(0xFF2C79C1)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkTokenAndNavigate(
      BuildContext context, String routeName) async {
    debugPrint(
        'DEBUG LaporScreen: _checkTokenAndNavigate started for route: $routeName');
    final token = await ApiService.getToken();
    debugPrint('DEBUG LaporScreen: Token retrieved: $token');
    if (token == null || token.isEmpty) {
      debugPrint(
          'DEBUG LaporScreen: Token is null or empty, redirecting to /login');
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      debugPrint('DEBUG LaporScreen: Token exists, navigating to: $routeName');
      Navigator.pushNamed(context, routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            const Center(
              child: Text(
                'Lapor',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionCard(
              title: 'Buat Laporan Banjir',
              description:
                  'Buat laporan terkait banjir atau bencana banjir untuk direspon pihak desa',
              onTap: () => _checkTokenAndNavigate(context, '/laporan_banjir'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Buat Laporan Kerusakan',
              description:
                  'Buat laporan terkait kerusakan infrastruktur untuk direspon pihak desa',
              onTap: () =>
                  _checkTokenAndNavigate(context, '/laporan_infrastruktur'),
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Hubungi KASI Kesejahteraan',
              description:
                  'Menuju ke telepon saat membutuhkan tim KASI Kesejahteraan, atau dalam keadaan darurat',
              onTap: () => _showKASIDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
