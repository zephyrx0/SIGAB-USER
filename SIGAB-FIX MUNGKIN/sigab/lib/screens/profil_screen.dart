import 'package:flutter/material.dart';
import '../api_service.dart';

import 'ubah_profil_screen.dart';
import 'ubah_password_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String? nama;
  String? nomorWa;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initialTokenCheckAndLoadProfile();
  }

  Future<void> _initialTokenCheckAndLoadProfile() async {
    debugPrint('DEBUG: _initialTokenCheckAndLoadProfile started');
    final token = await ApiService.getToken();
    debugPrint('DEBUG: Token retrieved: $token');
    if (!mounted) {
      debugPrint('DEBUG: _initialTokenCheckAndLoadProfile: Widget not mounted');
      return;
    }

    if (token == null || token.isEmpty) {
      debugPrint('DEBUG: Token is null or empty, redirecting to /login');
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
    }

    debugPrint('DEBUG: Token exists, loading profile...');
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    debugPrint('DEBUG: _loadProfile started');
    try {
      final data = await ApiService.viewProfile();
      if (!mounted) {
        debugPrint('DEBUG: _loadProfile: Widget not mounted after API call');
        return;
      }
      setState(() {
        nama = data['data']?['nama'];
        nomorWa = data['data']?['nomor_wa'];
        isLoading = false;
        error = null;
      });
      debugPrint('DEBUG: Profile loaded successfully');
    } catch (e) {
      debugPrint('DEBUG: Error in _loadProfile: $e');
      if (!mounted) {
        debugPrint(
            'DEBUG: _loadProfile: Widget not mounted during error handling');
        return;
      }

      if (e.toString().contains('Token tidak ditemukan') ||
          e.toString().contains('Invalid token') ||
          e.toString().contains('Tidak ada token yang diberikan')) {
        debugPrint('DEBUG: Token-related error, redirecting to /login');
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
        return;
      }

      setState(() {
        error = e.toString();
        isLoading = false;
      });
      debugPrint('DEBUG: Error state set: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 72,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat profil: $error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nama',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    nama ?? '-',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Nomor WhatsApp',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          nomorWa ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                                context, '/ubah-profil');
                            if (result == true) {
                              _loadProfile();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Ubah Data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/ubah-password');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Ubah Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () async {
                            final parentContext = context;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 32, 24, 24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.logout,
                                          size: 40,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Logout',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Apakah anda yakin akan keluar?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Poppins',
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                height: 40,
                                                child: OutlinedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    side: const BorderSide(
                                                        color:
                                                            Color(0xFFFFA726)),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Kembali',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Poppins',
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: SizedBox(
                                                height: 40,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    debugPrint(
                                                        'DEBUG Logout: Dialog closed, delaying...');
                                                    await Future.delayed(
                                                        const Duration(
                                                            milliseconds: 100));
                                                    debugPrint(
                                                        'DEBUG Logout: Delay finished, calling ApiService.logout()...');
                                                    try {
                                                      await ApiService.logout();
                                                      debugPrint(
                                                          'DEBUG Logout: ApiService.logout() finished, navigating...');
                                                    } catch (e) {
                                                      if (e.toString().contains(
                                                          'Logged out successfully')) {
                                                        debugPrint(
                                                            'DEBUG Logout: Logout successful, proceeding with navigation');
                                                      } else {
                                                        debugPrint(
                                                            'DEBUG Logout: Unexpected error during logout: \$e');
                                                      }
                                                    }

                                                    if (!mounted) return;
                                                    debugPrint(
                                                        'DEBUG Logout: Navigating to /login using parentContext');
                                                    Navigator.of(parentContext,
                                                            rootNavigator: true)
                                                        .pushNamedAndRemoveUntil(
                                                      '/login',
                                                      (route) => false,
                                                    );
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFFFA726),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    'Ya, Keluar',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Poppins',
                                                      color: Colors.white,
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
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFFFA726)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
