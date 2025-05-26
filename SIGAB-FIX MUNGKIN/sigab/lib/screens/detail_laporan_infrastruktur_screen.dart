import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../api_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';
// Import Uint8List

class DetailLaporanInfrastrukturScreen extends StatefulWidget {
  final String location;
  final Uint8List? photoBytes;
  final String? photoFilename;
  final String? imagePath;

  const DetailLaporanInfrastrukturScreen({
    super.key,
    required this.location,
    this.photoBytes,
    this.photoFilename,
    this.imagePath,
  });

  @override
  State<DetailLaporanInfrastrukturScreen> createState() =>
      _DetailLaporanInfrastrukturScreenState();
}

class _DetailLaporanInfrastrukturScreenState
    extends State<DetailLaporanInfrastrukturScreen> {
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
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
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

  Future<void> _submitReport() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId == null) {
        throw Exception('User ID tidak ditemukan');
      }

      // Get current time in ISO 8601 format
      final now = DateTime.now();
      final waktu = now.toIso8601String();

      // Read image file
      if (widget.imagePath == null) {
        throw Exception('Image path is null');
      }
      final file = File(widget.imagePath!);
      final fotoBytes = await file.readAsBytes();
      final filename = widget.imagePath!.split('/').last;

      final response = await ApiService.submitLaporan(
        idUser: userId,
        tipeLaporan: 'Infrastruktur', // Set tipe laporan ke Infrastruktur
        lokasi: widget.location,
        titikLokasi:
            '(${_currentLocation!.longitude},${_currentLocation!.latitude})',
        waktu: waktu,
        deskripsi: _descriptionController.text,
        fotoBytes: fotoBytes,
        filename: filename,
      );

      if (!mounted) return;

      if (response['status'] == 'success') {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Gagal mengirim laporan')),
        );
      }
    } catch (e) {
      print('Error submitting report: $e');
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

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print('Posisi didapat: ${position.latitude}, ${position.longitude}');

      setState(() {
        _currentLocation = position;
      });

      try {
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
          'Buat Laporan Kerusakan',
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
                                      widget.imagePath!,
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
                                      File(widget.imagePath!),
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
                    onTap: _isSubmitting ? null : _submitReport,
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
    _getCurrentLocation();
  }
}
