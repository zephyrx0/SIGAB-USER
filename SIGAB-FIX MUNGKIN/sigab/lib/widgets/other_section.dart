import 'package:flutter/material.dart';

class OtherSection extends StatelessWidget {
  final VoidCallback onEvakuasiTap;
  final VoidCallback onMitigasiTap;
  final VoidCallback onResetTap;

  const OtherSection({
    Key? key,
    required this.onEvakuasiTap,
    required this.onMitigasiTap,
    required this.onResetTap,
  }) : super(key: key);

  Widget _buildLinksOutIcon({double size = 20, Color color = Colors.black54}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Transform.translate(
              offset: const Offset(3, -3),
              child: Icon(
                Icons.arrow_outward,
                size: size * 0.8,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 140,
          margin: EdgeInsets.only(
            right: title == 'Tempat Evakuasi' ? 8 : 0,
            left: title == 'Mitigasi Bencana' ? 8 : 0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  imagePath,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(0),
                      Colors.black.withAlpha(180),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: _buildLinksOutIcon(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lainnya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildMenuItem(
              title: 'Tempat Evakuasi',
              imagePath: 'assets/images/tempat_evakuasi.jpg',
              onTap: onEvakuasiTap,
            ),
            _buildMenuItem(
              title: 'Mitigasi Bencana',
              imagePath: 'assets/images/tips_mitigasi.jpeg',
              onTap: onMitigasiTap,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: onResetTap,
            child: const Text('Reset Notifikasi Banjir Testing'),
          ),
        ),
      ],
    );
  }
}
