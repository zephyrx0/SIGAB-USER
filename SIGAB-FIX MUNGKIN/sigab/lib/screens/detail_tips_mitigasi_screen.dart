import 'package:flutter/material.dart';

class DetailTipsMitigasiScreen extends StatelessWidget {
  final String title;
  final String? imagePath;
  final List<Map<String, dynamic>> tipsList;

  const DetailTipsMitigasiScreen({
    super.key,
    required this.title,
    required this.imagePath,
    required this.tipsList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imagePath != null && imagePath!.isNotEmpty
                    ? Image.network(
                        imagePath!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          height: 200,
                          child: const Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        height: 200,
                        child: const Icon(Icons.image_not_supported,
                            size: 50, color: Colors.grey),
                      ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tipsList.length,
                        itemBuilder: (context, index) {
                          final tip = tipsList[index];
                          final String tipTitle =
                              tip['judul']?.toString() ?? 'Unknown Tip';
                          final String tipDescription =
                              tip['deskripsi']?.toString() ??
                                  'No description available.';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. $tipTitle',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tipDescription,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TipsMitigasiItem {
  final String title;
  final String description;

  const TipsMitigasiItem({
    required this.title,
    required this.description,
  });
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
