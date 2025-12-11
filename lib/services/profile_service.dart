import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String _baseUrl = "http://127.0.0.1:8000/api"; 

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? slogan,
    required String phone,
    String? latitude,
    String? longitude,
    File? profileImage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 🔥 PASTIKAN MENGGUNAKAN KUNCI YANG SAMA ('token')
    final token = prefs.getString('token'); 

    if (token == null || token.isEmpty) {
      // Perbaikan: Jika token null atau kosong, kembalikan pesan error yang jelas.
      return {'success': false, 'message': 'Token autentikasi tidak ditemukan. Harap login ulang.'};
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/profile/update'),
    );

    // 🔥 PASTIKAN HEADER DIKIRIM DENGAN BENAR
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      // 'Content-Type': 'multipart/form-data', // Opsional, tapi baik untuk kejelasan
    });

    // Menambahkan field teks
    request.fields['full_name'] = fullName;
    request.fields['phone'] = phone;
    if (slogan != null) request.fields['slogan'] = slogan;
    if (latitude != null) request.fields['latitude'] = latitude;
    if (longitude != null) request.fields['longitude'] = longitude;

    // Menambahkan file gambar jika ada
    if (profileImage != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image', 
          profileImage.path,
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Profil berhasil diperbarui.'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Autentikasi gagal. Token kadaluarsa/tidak valid.'};
      } else {
        return {'success': false, 'message': 'Gagal memperbarui profil: Status ${response.statusCode}, ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi error koneksi: $e'};
    }
  }
}