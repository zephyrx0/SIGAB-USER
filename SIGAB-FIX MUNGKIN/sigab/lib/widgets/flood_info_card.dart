import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class FloodInfoCard extends StatelessWidget {
  final Map<String, dynamic>? floodData;
  final Position? userLocation;
  final Color Function(String status) getStatusColor;

  const FloodInfoCard({
    Key? key,
    required this.floodData,
    required this.userLocation,
    required this.getStatusColor,
  }) : super(key: key);

  String _calculateDistance(double lat, double lng) {
    if (userLocation == null) return 'Lokasi tidak tersedia';

    double distanceInMeters = Geolocator.distanceBetween(
        userLocation!.latitude, userLocation!.longitude, lat, lng);
    return '${(distanceInMeters / 1000).toStringAsFixed(1)} Km dari lokasi anda';
  }

  @override
  Widget build(BuildContext context) {
    if (floodData == null) {
      return const SizedBox.shrink(); // Jangan tampilkan apapun jika data null
    }

    // Salin kode UI kartu informasi banjir dari home_screen.dart di sini
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
                  '${floodData!['wilayah_banjir'] ?? 'N/A'} (${floodData!['koordinat_lokasi']['y']?.toStringAsFixed(2) ?? 'N/A'} LS, ${floodData!['koordinat_lokasi']['x']?.toStringAsFixed(2) ?? 'N/A'} BT)',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                onPressed: () {
                  if (floodData != null) {
                    final floodData = this.floodData!;
                    final location = floodData['wilayah_banjir'] ?? 'N/A';
                    final dateTime =
                        DateTime.parse(floodData['waktu_kejadian']).toLocal();
                    final formattedDate =
                        DateFormat('EEEE, d MMMM y', 'id_ID').format(dateTime);
                    final formattedTime = DateFormat('HH:mm').format(dateTime);

                    final message =
                        '''📢 Pemberitahuan Banjir Terkini\n\nTelah terdeteksi banjir dengan kedalaman ${floodData['kategori_kedalaman']} di wilayah $location pada:\n\n📅 $formattedDate\n🕐 $formattedTime WIB\n\nDiharapkan masyarakat untuk meningkatkan kewaspadaan, menghindari area terdampak, dan mengikuti arahan dari pihak berwenang.\n\nTerima kasih.''';

                    final whatsappUrl = Uri.parse(
                        'https://wa.me/?text=${Uri.encodeComponent(message)}');

                    launchUrl(whatsappUrl,
                        mode: LaunchMode.externalApplication);
                  }
                },
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
                      floodData!['waktu_kejadian'] != null
                          ? '${DateFormat('EEEE, d MMMM y, HH:mm', 'id_ID').format(DateTime.parse(floodData!['waktu_kejadian']).toLocal())} WIB'
                          : 'N/A',
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
                        color: getStatusColor(
                            floodData!['kategori_kedalaman'] ?? ''),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Kedalaman Banjir: ${floodData!['kategori_kedalaman'] ?? 'N/A'}',
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
                        '${floodData!['tingkat_kedalaman'] ?? 'N/A'} cm',
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
              Expanded(
                child: Column(
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
                    Text(
                      _calculateDistance(floodData!['koordinat_lokasi']['y'],
                          floodData!['koordinat_lokasi']['x']),
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
                      floodData!['wilayah_banjir'] ?? 'N/A',
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
    );
  }
}
