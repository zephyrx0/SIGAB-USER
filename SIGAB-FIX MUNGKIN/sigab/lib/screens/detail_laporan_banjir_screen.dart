import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'main_screen.dart';

class DetailLaporanBanjirScreen extends StatefulWidget {
  final String location;
  final String imagePath; // Tambahkan properti imagePath

  const DetailLaporanBanjirScreen({
    super.key,
    required this.location,
    required this.imagePath, // Tambahkan parameter required
  });

  @override
  State<DetailLaporanBanjirScreen> createState() =>
      _DetailLaporanBanjirScreenState();
}

class _DetailLaporanBanjirScreenState extends State<DetailLaporanBanjirScreen> {
  Position? _currentLocation;
  String? _currentAddress;
  bool _isLoadingLocation = false;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Terkirim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Laporan anda telah terkirim',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitLaporan() async {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mohon tunggu, sedang mendapatkan lokasi...')),
      );
      await _getCurrentLocation(); // Coba dapatkan lokasi lagi
      if (_currentLocation == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal mendapatkan lokasi. Mohon cek izin lokasi')),
        );
        return;
      }
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi deskripsi laporan')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = await ApiService.getUserIdFromToken();
      if (userId == null) throw Exception('User ID tidak ditemukan');

      final now = DateTime.now();
      final waktu = now.toIso8601String();

      print(
          'Lokasi saat submit: ${_currentLocation?.latitude}, ${_currentLocation?.longitude}'); // Tambahkan log

      // Baca bytes dari file foto
      Uint8List? fotoBytes;
      String? filename;

      if (widget.imagePath.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Path foto tidak tersedia.')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return; // Stop submission if imagePath is not available
      }

      if (!kIsWeb) {
        // Untuk mobile/desktop, baca dari File path menggunakan dart:io
        try {
          final File imageFile = File(widget.imagePath);
          if (await imageFile.exists()) {
            fotoBytes = await imageFile.readAsBytes();
            filename =
                imageFile.path.split('/').last; // Ambil nama file dari path
          } else {
            throw Exception('File not found at path: ${widget.imagePath}');
          }
        } catch (e) {
          print('Error reading image file: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membaca file foto: ${e.toString()}')),
          );
          setState(() {
            _isSubmitting = false;
          });
          return; // Stop submission if file reading fails
        }
      } else {
        // Untuk web, widget.imagePath kemungkinan adalah path sementara atau identifier dari file picker
        print(
            'WARNING: File upload on web is not fully implemented. Skipping file upload.');
        // For web, we might need a different approach if foto is required.
        // If foto is always required by backend, web upload must be implemented.
        // For now, if web upload is not implemented and foto is required, we should prevent submission.
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unggah foto dari web belum diimplementasikan.')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return; // Stop submission if web upload is not implemented and foto is required
      }

      // Add logging before submission
      print('Debug: imagePath: ${widget.imagePath}');
      print('Debug: fotoBytes is null: ${fotoBytes == null}');
      print('Debug: filename: $filename');

      await ApiService.submitLaporan(
        idUser: userId,
        tipeLaporan: 'Banjir',
        lokasi: widget.location,
        waktu: waktu,
        deskripsi: _descriptionController.text,
        fotoBytes: fotoBytes,
        filename: filename,
        titikLokasi: _currentLocation != null
            ? '(${_currentLocation!.longitude},${_currentLocation!.latitude})'
            : '(0,0)',
      );

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Cek permission lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen');
      }

      // Dapatkan posisi
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print('Posisi didapat: ${position.latitude}, ${position.longitude}');

      // Simpan posisi terlebih dahulu
      setState(() {
        _currentLocation = position;
      });

      try {
        // Dapatkan alamat dari koordinat dalam blok try terpisah
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);

        if (!mounted) return;

        setState(() {
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            final street = placemark.street ?? '';
            final subLocality = placemark.subLocality ?? '';
            final locality = placemark.locality ?? '';

            _currentAddress = [street, subLocality, locality]
                .where((e) => e.isNotEmpty)
                .join(', ');
          }
          _isLoadingLocation = false;
        });
      } catch (geocodeError) {
        print('Error saat mendapatkan alamat: $geocodeError');
        // Tetap set loading false meski gagal dapat alamat
        if (!mounted) return;
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      print('Error mendapatkan lokasi: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Buat Laporan Banjir',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lokasi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isLoadingLocation
                                  ? 'Mendapatkan lokasi...'
                                  : _currentAddress ?? widget.location,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(
                                      widget.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 48,
                                          ),
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(widget.imagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.6,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 48,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Deskripsi/Keterangan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2196F3)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration.collapsed(
                    hintText: 'Masukkan deskripsi laporan',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFFA726),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isSubmitting ? null : _submitLaporan,
                    child: Center(
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Kirim Laporan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Panggil fungsi saat widget diinisialisasi
  }
}
