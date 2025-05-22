import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// URL dasar untuk API endpoint
  static const String baseUrl =
      // 'https://e686-36-69-143-197.ngrok-free.app/api'; // Ubah menjadi base API saja
      'http://localhost:3000/api'; // Ubah menjadi base API saja
  static const String userUrl = '$baseUrl/users'; // Tambah endpoint khusus user
  static const String appUrl = '$baseUrl/app'; // Tambah endpoint khusus app

  /// Fungsi untuk mendapatkan token dari penyimpanan lokal
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
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
        throw e;
      }
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Fungsi untuk melakukan login pengguna
  static Future<Map<String, dynamic>> login(
      String nomorWa, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$userUrl/login'), // Gunakan userUrl
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomor_wa': nomorWa,
          'password': password,
        }),
      );

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
        throw e;
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
        throw e;
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
        print('Weather response: ${response.body}');
        return data;
      } else {
        throw data['message'] ?? 'Gagal mengambil data cuaca';
      }
    } catch (e) {
      if (e is String) {
        throw e;
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
        throw e;
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
        throw e;
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

  /// Fungsi untuk mengirim laporan ke server
  static Future<Map<String, dynamic>> submitLaporan({
    required String idUser,
    required String tipeLaporan,
    required String lokasi,
    required String waktu,
    required String deskripsi,
    required String foto,
    required String titikLokasi, // Tambahkan parameter baru
  }) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('$appUrl/laporan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_user': idUser,
          'tipe_laporan': tipeLaporan,
          'lokasi': lokasi,
          'waktu': waktu,
          'deskripsi': deskripsi,
          'foto': foto,
          'titik_lokasi': titikLokasi, // Tambahkan titik lokasi ke body request
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(jsonDecode(response.body)['message'] ??
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
      final response = await http.post(
        Uri.parse('$userUrl/forgot-password'), // Gunakan userUrl
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomor_wa': nomorWa,
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
        throw e;
      }
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
