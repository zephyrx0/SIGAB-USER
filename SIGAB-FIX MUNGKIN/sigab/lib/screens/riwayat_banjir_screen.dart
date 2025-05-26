import 'package:flutter/material.dart';
import 'package:sigab/api_service.dart';
import 'detail_riwayat_banjir_screen.dart' hide WavePainter;
import 'main_screen.dart';
import 'cuaca_screen.dart';
import 'lapor_screen.dart';
import 'lainnya_screen.dart';
import 'package:sigab/utils/wave_painter.dart';

class RiwayatBanjirScreen extends StatefulWidget {
  const RiwayatBanjirScreen({super.key});

  @override
  State<RiwayatBanjirScreen> createState() => _RiwayatBanjirScreenState();
}

class _RiwayatBanjirScreenState extends State<RiwayatBanjirScreen> {
  final bool _isBanjirTerkini = false;
  bool _isLoading = true;
  String _error = '';
  List<dynamic>? _riwayatBanjir;

  @override
  void initState() {
    super.initState();
    _fetchRiwayatBanjir();
  }

  Future<void> _fetchRiwayatBanjir() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final data = await ApiService.getRiwayatBanjir();
      setState(() {
        _riwayatBanjir = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String kategori) {
    switch (kategori.toLowerCase()) {
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

  Widget _buildFloodCard(Map<String, dynamic> riwayat) {
    final waktu = DateTime.parse(riwayat['waktu_kejadian']);
    final formattedDate = '${waktu.day}-${waktu.month}-${waktu.year}';
    final formattedTime =
        '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}';
    final statusColor = _getStatusColor(riwayat['kategori_kedalaman']);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail-riwayat-banjir',
          arguments: {
            'date': formattedDate,
            'time': formattedTime,
            'location': riwayat['wilayah_banjir'],
            'depth': riwayat['tingkat_kedalaman'],
            'statusColor': statusColor,
            'status': riwayat['kategori_kedalaman'],
            'coordinates': riwayat['koordinat_lokasi'],
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
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
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${riwayat['wilayah_banjir'] ?? 'N/A'} (${riwayat['koordinat_lokasi']['y'] ?? 'N/A'} LS, ${riwayat['koordinat_lokasi']['x'] ?? 'N/A'} BT)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Banjir',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$formattedDate, $formattedTime WIB',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Kedalaman Banjir: ${riwayat['kategori_kedalaman']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.height, color: Colors.orange, size: 24),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Kedalaman Banjir',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          riwayat['tingkat_kedalaman'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.swap_horiz, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jarak',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Text(
                      '10 Km dari lokasi anda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wilayah Banjir',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        riwayat['wilayah_banjir'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Riwayat Laporan Banjir',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 72,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Riwayat Banjir',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              // Tab buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          'Banjir Terkini',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA726),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Riwayat Banjir',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error.isNotEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(_error),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchRiwayatBanjir,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              else if (_riwayatBanjir == null || _riwayatBanjir!.isEmpty)
                const Center(
                  child: Text(
                    'Tidak ada data riwayat banjir',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: _riwayatBanjir!
                        .map((riwayat) => _buildFloodCard(riwayat))
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: 3,
          onTap: (index) {
            if (index != 3) {
              String targetRoute;
              switch (index) {
                case 0:
                  targetRoute = '/';
                  break;
                case 1:
                  targetRoute = '/cuaca';
                  break;
                case 2:
                  targetRoute = '/lapor';
                  break;
                case 4:
                  targetRoute = '/lainnya';
                  break;
                default:
                  targetRoute = '/'; // Default to home if index is unexpected
              }
              // Navigate to MainScreen (root route) passing the targetRoute as argument
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => route.settings.name == '/',
                arguments: targetRoute,
              );
            }
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
                decoration: const BoxDecoration(
                  color: Colors.blue,
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
                    color: const Color(0xFF016FB9),
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
