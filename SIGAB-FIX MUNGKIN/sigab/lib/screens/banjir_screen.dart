import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter_map/flutter_map.dart';
import 'dart:ui' show Path;
import 'riwayat_banjir_screen.dart';

class BanjirScreen extends StatefulWidget {
  const BanjirScreen({super.key});

  @override
  State<BanjirScreen> createState() => _BanjirScreenState();
}

class _BanjirScreenState extends State<BanjirScreen> {
  bool _isBanjirTerkini = true;

  Widget _buildFloodCard({
    required String date,
    required String time,
    required String location,
    required String depth,
    required Color statusColor,
    required String status,
  }) {
    return Container(
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
              Text(
                'Citeureup (0.07 LS, 109.37 BT)',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              const Icon(Icons.share, size: 20),
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
                      '$date, $time WIB',
                      style: TextStyle(
                        color: Colors.grey[600],
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
                        'Kedalaman Banjir: $status',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Poppins',
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
                        depth,
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
              Column(
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
                    location,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Header with title
          const Center(
            child: Text(
              'Banjir',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Tab buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isBanjirTerkini = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isBanjirTerkini
                          ? const Color(0xFFFFA726)
                          : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(
                        color: _isBanjirTerkini
                            ? const Color(0xFFFFA726)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      'Banjir Terkini',
                      style: TextStyle(
                        color: _isBanjirTerkini
                            ? Colors.white
                            : Colors.grey.shade600,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RiwayatBanjirScreen(),
                        ),
                      );
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
                      'Riwayat Banjir',
                      style: TextStyle(
                        color: Colors.grey.shade600,
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
          // Content based on selected tab
          if (_isBanjirTerkini) ...[
            // Map Container
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  options: MapOptions(
                    center: const LatLng(-6.983004, 107.628411),
                    zoom: 14,
                    minZoom: 5,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sigab.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: const LatLng(-6.983004, 107.628411),
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Current flood card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildFloodCard(
                date: 'Senin, 10 Maret 2025',
                time: '23.33',
                location: 'Jl. Radio Palasari, Sebagian hulu sungai Cigede',
                depth: '125 cm',
                statusColor: Colors.red,
                status: 'Tinggi',
              ),
            ),
          ] else ...[
            // Riwayat Banjir cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildFloodCard(
                    date: 'Senin, 7 April 2025',
                    time: '12.27',
                    location: 'Jl. Sukabirus, sebagian Jl. Radio Palasari',
                    depth: '10 cm',
                    statusColor: Colors.green,
                    status: 'Rendah',
                  ),
                  _buildFloodCard(
                    date: 'Senin, 24 Maret 2025',
                    time: '12.56',
                    location: 'Jl. Radio Palasari, Sebagian hulu sungai Cigede',
                    depth: '50 cm',
                    statusColor: Colors.orange,
                    status: 'Sedang',
                  ),
                  _buildFloodCard(
                    date: 'Senin, 10 Maret 2025',
                    time: '23.33',
                    location: 'Jl. Radio Palasari, Sebagian hulu sungai Cigede',
                    depth: '125 cm',
                    statusColor: Colors.red,
                    status: 'Tinggi',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
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
