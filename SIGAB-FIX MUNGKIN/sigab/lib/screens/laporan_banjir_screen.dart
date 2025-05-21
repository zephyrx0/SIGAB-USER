import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sigab/api_service.dart';
import 'dart:io';
import 'detail_laporan_banjir_screen.dart';

class LaporanBanjirScreen extends StatefulWidget {
  const LaporanBanjirScreen({super.key});

  @override
  State<LaporanBanjirScreen> createState() => _LaporanBanjirScreenState();
}

class _LaporanBanjirScreenState extends State<LaporanBanjirScreen> {
  File? _image;
  String? _currentAddress;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _checkToken();
    _getCurrentLocation();
  }

  Future<void> _checkToken() async {
    final token = await ApiService.getToken();
    if (token == null) {
      if (!mounted) return;
      // Redirect ke halaman login jika tidak ada token
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street}, ${place.subLocality}, ${place.locality}, '
              '${place.subAdministrativeArea}, ${place.administrativeArea} ${place.postalCode}';
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void _takePicture() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailLaporanBanjirScreen(
          location: _currentAddress ?? '2JCH+82V, Jl. Babakan Leuvi Bandung, RT.02/RW.03, Citeureup, Kec. Dayeuhkolot, Kabupaten Bandung, Jawa Barat 40255',
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
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 4 / 3,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                if (_image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
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
                        const Text(
                          '2JCH+82V, Jl. Babakan Leuvi Bandung, RT.02/RW.03, Citeureup, Kec. Dayeuhkolot, Kabupaten Bandung, Jawa Barat 40255',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFA726),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
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