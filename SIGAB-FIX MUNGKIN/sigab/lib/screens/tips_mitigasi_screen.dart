import 'package:flutter/material.dart';
import 'detail_tips_mitigasi_screen.dart';

class TipsMitigasiScreen extends StatelessWidget {
  const TipsMitigasiScreen({super.key});

  List<TipsMitigasiItem> _getBanjirTips() {
    return [
      const TipsMitigasiItem(
        title: 'Pengelolaan Tata Ruang dan Lingkungan',
        description:
            'Pengelolaan tata ruang yang baik adalah kunci dalam mitigasi banjir. Ini melibatkan perencanaan penggunaan lahan yang bijaksana dengan memperhatikan pembangunan di daerah rawan banjir, seperti di sekitar sungai dan dataran rendah. Pemerintah harus menetapkan zona-zona khusus yang tidak boleh digunakan kawasan permukiman atau industri.',
      ),
      const TipsMitigasiItem(
        title: 'Sistem Peringatan Dini',
        description:
            'Pemasangan sistem peringatan dini yang efektif sangat penting untuk memberikan informasi tepat waktu kepada masyarakat tentang kemungkinan terjadinya banjir. Teknologi seperti sensor curah hujan, pemantauan sungai, dan prakiraan cuaca dapat membantu mendeteksi potensi banjir lebih awal. Informasi ini kemudian dapat disebarkan melalui radio, televisi, SMS, dan aplikasi smartphone.',
      ),
      const TipsMitigasiItem(
        title: 'Persiapan Menghadapi Banjir',
        description:
            'Siapkan tas darurat yang berisi barang-barang penting seperti dokumen, obat-obatan, makanan tahan lama, air minum, senter, dan radio portable. Kenali rute evakuasi dan tempat pengungsian terdekat. Pastikan seluruh anggota keluarga mengetahui prosedur evakuasi.',
      ),
    ];
  }

  List<TipsMitigasiItem> _getGempaTips() {
    return [
      const TipsMitigasiItem(
        title: 'Identifikasi Tempat Aman',
        description:
            'Kenali tempat-tempat aman di dalam ruangan seperti di bawah meja yang kokoh, di sudut ruangan, atau di bawah kusen pintu. Hindari area dekat jendela, lemari, atau benda-benda yang bisa jatuh.',
      ),
      const TipsMitigasiItem(
        title: 'Persiapkan Tas Darurat',
        description:
            'Siapkan tas darurat yang berisi perlengkapan penting seperti air minum, makanan tahan lama, obat-obatan, senter, radio portable, dan dokumen penting. Pastikan semua anggota keluarga tahu lokasi tas darurat.',
      ),
      const TipsMitigasiItem(
        title: 'Latihan Evakuasi Rutin',
        description:
            'Lakukan latihan evakuasi secara rutin bersama keluarga. Kenali rute evakuasi dan titik kumpul yang telah ditentukan. Pastikan setiap anggota keluarga memahami apa yang harus dilakukan saat terjadi gempa.',
      ),
    ];
  }

  List<TipsMitigasiItem> _getCuacaEkstremTips() {
    return [
      const TipsMitigasiItem(
        title: 'Pantau Informasi Cuaca',
        description:
            'Selalu pantau informasi cuaca dari sumber resmi seperti BMKG. Perhatikan peringatan dini cuaca ekstrem dan ikuti petunjuk dari otoritas setempat.',
      ),
      const TipsMitigasiItem(
        title: 'Amankan Rumah dan Lingkungan',
        description:
            'Pastikan atap rumah dalam kondisi baik dan kuat. Bersihkan saluran air dan selokan dari sampah. Pangkas dahan pohon yang berpotensi patah dan membahayakan.',
      ),
      const TipsMitigasiItem(
        title: 'Persiapkan Kebutuhan Darurat',
        description:
            'Siapkan persediaan makanan, air minum, obat-obatan, dan kebutuhan darurat lainnya yang cukup untuk beberapa hari. Siapkan senter dan baterai cadangan untuk mengantisipasi pemadaman listrik.',
      ),
    ];
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

  Widget _buildTipsCard(String title, String imagePath,
      List<TipsMitigasiItem> tips, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail-tips-mitigasi',
          arguments: {
            'title': title,
            'imagePath': imagePath,
            'tipsList': tips,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
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
              // Image
              Image.asset(
                imagePath,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              // Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
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
                _buildTipsCard(
                  'Tips Mitigasi Bencana Banjir',
                  'assets/images/m_banjir.jpeg',
                  _getBanjirTips(),
                  context,
                ),
                _buildTipsCard(
                  'Tips Mitigasi Gempa Bumi',
                  'assets/images/m_gempa.jpeg',
                  _getGempaTips(),
                  context,
                ),
                _buildTipsCard(
                  'Tips Menghadapi Cuaca Ekstrem',
                  'assets/images/m_cuaca_ekstrem.jpeg',
                  _getCuacaEkstremTips(),
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
