import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sigab/api_service.dart';
import 'package:camera/camera.dart';
import 'detail_laporan_infrastruktur_screen.dart';

class LaporanInfrastrukturScreen extends StatefulWidget {
  const LaporanInfrastrukturScreen({super.key});

  @override
  State<LaporanInfrastrukturScreen> createState() =>
      _LaporanInfrastrukturScreenState();
}

class _LaporanInfrastrukturScreenState
    extends State<LaporanInfrastrukturScreen> {
  CameraController? _cameraController;
  String? _currentAddress;
  bool _isCameraInitialized = false;
  List<CameraDescription>? cameras;
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkTokenAndLoad();
    _getCurrentLocation();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![_selectedCameraIndex],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _checkTokenAndLoad() async {
    try {
      await ApiService.viewProfile();
    } catch (e) {
      debugPrint(
          'DEBUG LaporanInfrastrukturScreen: Token validation failed: $e');
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      return;
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

  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailLaporanInfrastrukturScreen(
            location: _currentAddress ??
                '2JCH+82V, Jl. Babakan Leuvi Bandung, RT.02/RW.03, Citeureup, Kec. Dayeuhkolot, Kabupaten Bandung, Jawa Barat 40255',
            imagePath: photo.path,
          ),
        ),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras!.length;

    // Dispose of the current controller
    await _cameraController?.dispose();

    // Initialize the new controller
    _cameraController = CameraController(
      cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
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
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              bottom: 80, // Leave space for the button
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        if (_isCameraInitialized)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CameraPreview(_cameraController!),
                            ),
                          )
                        else
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
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
                                  _currentAddress ??
                                      '2JCH+82V, Jl. Babakan Leuvi Bandung, RT.02/RW.03, Citeureup, Kec. Dayeuhkolot, Kabupaten Bandung, Jawa Barat 40255',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16.0,
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
            Positioned(
              bottom: 24.0, // Adjust position as needed
              right: 24.0, // Adjust position as needed
              child: IconButton(
                icon: const Icon(Icons.switch_camera,
                    color: Colors.black, size: 30), // Adjust color and size
                onPressed: _switchCamera,
              ),
            ),
          ],
        ),
      );
    }
  }
}
