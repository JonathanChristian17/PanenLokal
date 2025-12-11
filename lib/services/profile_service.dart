import 'dart:io';
import 'dart:convert';
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
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Token autentikasi tidak ditemukan. Harap login ulang.'
      };
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/profile/update'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['full_name'] = fullName;
    request.fields['phone'] = phone;
    if (slogan != null) request.fields['slogan'] = slogan;
    if (latitude != null) request.fields['latitude'] = latitude;
    if (longitude != null) request.fields['longitude'] = longitude;

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // SIMPAN USER BARU KE LOCAL
        await prefs.setString("user", jsonEncode(data["user"]));

        return {
          'success': true,
          'message': data["message"] ?? 'Profil berhasil diperbarui.'
        };
      }

      return {
        'success': false,
        'message': data["message"] ?? "Gagal memperbarui profil"
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi error koneksi: $e'};
    }
  }
}
