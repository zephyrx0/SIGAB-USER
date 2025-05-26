import 'package:flutter/material.dart';
import 'detail_tips_mitigasi_screen.dart';
import '../api_service.dart';

class TipsMitigasiScreen extends StatefulWidget {
  const TipsMitigasiScreen({super.key});

  @override
  State<TipsMitigasiScreen> createState() => _TipsMitigasiScreenState();
}

class _TipsMitigasiScreenState extends State<TipsMitigasiScreen> {
  bool isLoading = true;
  Map<String, List<Map<String, dynamic>>> groupedTips = {};
  String? error;

  @override
  void initState() {
    super.initState();
    _loadTipsData();
  }

  Future<void> _loadTipsData() async {
    try {
      final List<dynamic> tipsList = await ApiService.getTipsMitigasi();

      // Group tips by title (category)
      final Map<String, List<Map<String, dynamic>>> tempGroupedTips = {};
      for (var tip in tipsList) {
        if (tip is Map<String, dynamic>) {
          final String title = tip['judul']?.toString() ?? 'Unknown Category';
          if (!tempGroupedTips.containsKey(title)) {
            tempGroupedTips[title] = [];
          }
          tempGroupedTips[title]!.add(tip);
        }
      }

      setState(() {
        groupedTips = tempGroupedTips;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildLinksOutIcon({double size = 20}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Transform.translate(
              offset: const Offset(3, -3),
              child: const Icon(
                Icons.arrow_outward,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(String title, String? imageUrl,
      List<Map<String, dynamic>> tips, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail-tips-mitigasi',
          arguments: {
            'title': title,
            'imagePath': imageUrl,
            'tipsList': tips,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey),
                    ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: _buildLinksOutIcon(),
                      ),
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Tips Mitigasi',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: $error',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadTipsData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: groupedTips.entries.map((entry) {
                          final categoryTitle = entry.key;
                          final tipsInCategory = entry.value;
                          final imageUrl = tipsInCategory.isNotEmpty
                              ? tipsInCategory[0]['media']?.toString()
                              : null;

                          return _buildTipsCard(
                            categoryTitle,
                            imageUrl,
                            tipsInCategory,
                            context,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
      ),
    );
  }
}
