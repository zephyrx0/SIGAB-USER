import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'cuaca_screen.dart';
import 'lapor_screen.dart';
import 'banjir_screen.dart';
import 'lainnya_screen.dart';
import 'package:sigab/utils/wave_painter.dart'; // Assuming WavePainter is used here for the icon

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to Home tab
  DateTime? _lastExitTime;

  final List<Widget> _screens = [
    const HomeContent(), // HomeContent is the body of HomeScreen
    const CuacaScreen(),
    const LaporScreen(),
    const BanjirScreen(),
    const LainnyaScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Read route arguments if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? targetRoute =
          ModalRoute.of(context)?.settings.arguments as String?;
      if (targetRoute != null) {
        // Map route name to tab index
        int newIndex;
        switch (targetRoute) {
          case '/cuaca':
            newIndex = 1;
            break;
          case '/lapor':
            newIndex = 2;
            break;
          case '/banjir': // Assuming /banjir is the route for Riwayat Banjir/Banjir Terkini
            newIndex = 3;
            break;
          case '/lainnya':
            newIndex = 4;
            break;
          case '/': // Home is default, but handle explicitly if needed
          default:
            newIndex = 0;
        }
        if (newIndex != _selectedIndex) {
          setState(() {
            _selectedIndex = newIndex;
          });
        }
      }
    });
  }

  // This is similar to the build method from the old HomeScreen
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
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
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2
                        ? const Color(0xFF016FB9)
                        : Colors.blue,
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
                      color: _selectedIndex == 3
                          ? const Color(0xFF016FB9)
                          : Colors.grey,
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
      ),
    );
  }

  Future<bool> _onWillPop() async {
    // Jika bukan di tab Home, kembali ke tab Home
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return false; // Jangan izinkan pop default
    }

    // Jika di tab Home, cek waktu terakhir menekan tombol kembali
    final now = DateTime.now();
    if (_lastExitTime == null ||
        now.difference(_lastExitTime!) > const Duration(seconds: 2)) {
      // Tampilkan pesan konfirmasi jika belum pernah atau sudah lebih dari 2 detik
      _lastExitTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tekan sekali lagi untuk keluar'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Jangan izinkan pop default
    } else {
      // Keluar dari aplikasi jika tombol kembali ditekan lagi dalam 2 detik
      return true; // Izinkan pop default (akan keluar aplikasi)
    }
  }
}
