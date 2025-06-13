import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigab/services/notification_service.dart';
import 'package:sigab/services/twilio_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // Import jwt_decoder
import 'package:flutter/foundation.dart';

class ApiService {
  /// URL dasar untuk API endpoint
  static const String baseUrl =
      'https://d3d2-2a09-bac5-3a11-18c8-00-278-61.ngrok-free.app/api'; // Ubah menjadi base API saja
  // 'http://localhost:3000/api'; // Ubah menjadi base API saja
  static const String userUrl = '$baseUrl/users'; // Tambah endpoint khusus user
  static const String appUrl = '$baseUrl/app'; // Tambah endpoint khusus app

  /// Fungsi untuk mendapatkan token dari penyimpanan lokal
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      if (JwtDecoder.isExpired(token)) {
        // Token kedaluwarsa, hapus dari penyimpanan
        await removeToken();
        return null;
      } else {
        return token;
      }
    }
    return null;
  }

  /// Fungsi untuk menyimpan token ke penyimpanan lokal
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  /// Fungsi untuk menghapus token dari penyimpanan lokal
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  /// Fungsi untuk memeriksa token yang tersimpan
  static Future<void> checkStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      print('Token tersimpan: $token');
    } else {
      print('Tidak ada token yang tersimpan');
    }
  }

  /// Fungsi untuk mendaftarkan pengguna baru
  static Future<void> registerUser(
      String nomorWa, String password, String nama) async {
    try {
      final response = await http.post(
        Uri.parse('$userUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomor_wa': nomorWa,
          'password': password,
          'nama': nama,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['status'] == 'success') {
        return;
      } else {
        throw data['message'] ?? 'Registrasi gagal';
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk melakukan login pengguna
  static Future<Map<String, dynamic>> login(
      String nomorWa, String password) async {
    try {
      // Menghapus karakter '+62' jika ada di awal nomor
      String phoneNumber = nomorWa.trim();
      if (phoneNumber.startsWith('+62')) {
        phoneNumber = phoneNumber.substring(3);
      }

      final client = http.Client();
      final response = await client.post(
        Uri.parse('$userUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomor_wa': phoneNumber,
          'password': password,
        }),
      );
      client.close();

      debugPrint('DEBUG ApiService.login: Request URL: $userUrl/login');
      debugPrint(
          'DEBUG ApiService.login: Response status code: ${response.statusCode}');
      debugPrint('DEBUG ApiService.login: Response body: ${response.body}');
      debugPrint(
          'DEBUG ApiService.login: Response headers: ${response.headers}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final userData = data['data'];
        if (userData == null || userData['token'] == null) {
          throw 'Token tidak ditemukan dalam response';
        }
        await setToken(userData['token']);
        return data;
      } else {
        throw data['message'] ?? 'Login gagal';
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk melakukan logout pengguna
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token == null) {
        await removeToken();
        return;
      }

      final response = await http.post(
        Uri.parse('$userUrl/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        await removeToken();
      } else {
        throw data['message'] ?? 'Logout gagal';
      }
    } catch (e) {
      await removeToken();
      if (e is String) {
        rethrow;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mendapatkan data cuaca
  static Future<Map<String, dynamic>> getWeather() async {
    try {
      final response = await http.get(
        Uri.parse('$appUrl/cuaca'), // Pindah ke appUrl karena ini data aplikasi
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'data': data, // Use the defined 'data' variable
        };
      } else {
        throw data['message'] ?? 'Gagal mengambil data cuaca';
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mendapatkan data banjir
  static Future<Map<String, dynamic>> getFloodData() async {
    try {
      final response = await http.get(
        Uri.parse('$appUrl/informasi-banjir'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Gagal mengambil data banjir';
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mendapatkan data riwayat banjir
  static Future<List<dynamic>> getRiwayatBanjir() async {
    try {
      final response = await http.get(
        Uri.parse('$appUrl/riwayat-banjir'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] as List<dynamic>;
      } else {
        throw data['message'] ?? 'Gagal mengambil data riwayat banjir';
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mendapatkan ID pengguna dari token
  static Future<String?> getUserIdFromToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      // Split the token into its parts
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode the payload (second part)
      String normalizedPayload = base64Url.normalize(parts[1]);
      final payloadMap =
          json.decode(utf8.decode(base64Url.decode(normalizedPayload)));

      return payloadMap['id_user']?.toString();
    } catch (e) {
      print('Error decoding token: $e');
      return null;
    }
  }

  /// Fungsi untuk mengirim laporan ke server (Updated for file upload)
  static Future<Map<String, dynamic>> submitLaporan({
    required String idUser,
    required String tipeLaporan,
    required String lokasi,
    required String waktu,
    required String deskripsi,
    Uint8List? fotoBytes, // Accepts file bytes
    String? filename, // Accepts filename
    required String titikLokasi,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '$appUrl/laporan'), // Ensure this matches your backend upload endpoint
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        // 'Content-Type': 'multipart/form-data' is usually added automatically by http.MultipartRequest
      });

      request.fields.addAll({
        'id_user': idUser,
        'tipe_laporan': tipeLaporan,
        'lokasi': lokasi,
        'waktu': waktu,
        'deskripsi': deskripsi,
        'titik_lokasi': titikLokasi,
      });

      // Attach the file to the request if bytes and filename are available
      if (fotoBytes != null && filename != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'foto', // Make sure 'foto' matches the field name expected by your backend Multer setup
          fotoBytes,
          filename: filename,
        ));
      } else {
        // Handle cases where photo is required but not available
        // Depending on your backend validation, you might throw an error here
        print(
            'Warning: Photo bytes or filename are missing. Submitting without photo.');
        // If backend requires photo, the backend should return an error.
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final dynamic responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Check if backend returned the photoUrl and potentially return it
        return responseData; // Or return specific data you need
      } else {
        // Handle backend errors, which might include the 'foto' required error
        throw Exception(responseData['message'] ??
            'Terjadi kesalahan saat mengirim laporan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Fungsi untuk melihat profil pengguna
  static Future<Map<String, dynamic>> viewProfile() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$userUrl/profile'), // Gunakan userUrl
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Gagal mengambil data profil';
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mengubah profil pengguna
  static Future<Map<String, dynamic>> changeProfile({
    String? nama,
    String? nomorWa,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.put(
        Uri.parse('$userUrl/profile'), // Gunakan userUrl
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          if (nama != null) 'nama': nama,
          if (nomorWa != null) 'nomor_wa': nomorWa,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Gagal mengubah profil';
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mengubah password
  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.put(
        Uri.parse('$userUrl/password'), // Gunakan userUrl
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_new_password': confirmNewPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Gagal mengubah password';
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk request reset password
  static Future<Map<String, dynamic>> requestResetPassword(
      String nomorWa) async {
    try {
      // Generate OTP
      final otp = TwilioService.generateOTP();

      // Send OTP via WhatsApp
      final messageSent = await TwilioService.sendWhatsAppMessage(
        to: nomorWa,
        message:
            'Kode OTP untuk reset password SIGAB Anda adalah: $otp\n\nKode ini akan kadaluarsa dalam 5 menit.',
      );

      if (!messageSent) {
        throw 'Gagal mengirim kode OTP';
      }

      // Store OTP in backend
      final response = await http.post(
        Uri.parse('$userUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomor_wa': nomorWa,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Gagal request reset password';
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk reset password
  static Future<Map<String, dynamic>> resetPassword({
    required String nomorWa,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$userUrl/reset-password'), // Gunakan userUrl
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomor_wa': nomorWa,
          'otp': otp,
          'new_password': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Gagal reset password';
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mendapatkan data tempat evakuasi
  static Future<Map<String, dynamic>> getEvacuationPlaces() async {
    try {
      final response = await http.get(
        Uri.parse('$appUrl/tempat-evakuasi'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Gagal mengambil data tempat evakuasi';
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mengecek laporan banjir dan notifikasi
  static Future<Map<String, dynamic>> checkFloodReports() async {
    try {
      final response = await http.get(
        Uri.parse('$appUrl/check-flood-reports'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? 'Gagal mengecek laporan banjir';
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mendapatkan riwayat notifikasi
  static Future<List<dynamic>> getNotificationHistory() async {
    try {
      final installDate = await NotificationService().getInstallDate();
      final response = await http.get(
        Uri.parse(
            '$appUrl/notification-history?installed_at=${installDate.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['data'] as List<dynamic>;
      } else {
        throw data['message'] ?? 'Gagal mengambil riwayat notifikasi';
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk mendapatkan informasi banjir terbaru
  static Future<Map<String, dynamic>?> getLatestFloodInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$appUrl/latest-flood-info'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data[
            'data']; // Mengembalikan objek data informasi banjir terbaru
      } else if (response.statusCode == 404) {
        // Tidak ada informasi banjir ditemukan, ini kondisi normal jika belum ada data
        return null;
      } else {
        final data = jsonDecode(response.body);
        throw data['message'] ?? 'Gagal mengambil informasi banjir terbaru';
      }
    } catch (e) {
      if (e is String) {
        rethrow;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  // Tips Mitigasi
  static Future<List<dynamic>> getTipsMitigasi() async {
    try {
      final response = await http.get(
        Uri.parse('$appUrl/tips-mitigasi'),
        // Headers might not be needed for a public endpoint, removing _getHeaders call
        // headers: await _getHeaders(), // Removed
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Ensure 'data' key exists and is a list
        if (data['data'] is List) {
          return data['data']; // Return the list inside 'data' key
        } else {
          throw Exception('Invalid data format received for tips mitigasi');
        }
      } else {
        // Handle API errors based on status code and message
        throw Exception(data['message'] ??
            'Failed to load tips mitigasi (Status: ${response.statusCode})');
      }
    } catch (e) {
      // General error during fetch or decoding
      throw Exception('Error fetching tips: ${e.toString()}');
    }
  }

  /// Fungsi untuk mengecek peringatan cuaca (hujan hari ini)
  static Future<Map<String, dynamic>> checkWeatherWarning() async {
    try {
      final response = await http.get(
        Uri.parse('$appUrl/check-weather-warning'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return data; // Expected to contain 'should_notify': bool and possibly 'message': String
      } else {
        throw Exception(data['message'] ?? 'Gagal mengecek peringatan cuaca');
      }
    } catch (e) {
      throw e.toString().replaceAll('Exception: ', '');
    }
  }
}

// Hapus variabel global ini karena seharusnya berada dalam state widget
// bool _isLoading = true;
// String _error = '';
// Map<String, dynamic>? _floodData;

// Hapus variabel global ini karena seharusnya berada dalam state widget
// bool _isLoading = true;
// String _error = '';
// Map<String, dynamic>? _floodData;
