import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
 final String _baseUrl = "http://10.0.2.2:8000/api";

 Future<Map<String, dynamic>> updateProfile({
  required String fullName,
  String? slogan,
  required String phone,
  String? latitude,
  String? longitude,
  File? profileImage,
 }) async {
  final prefs = await SharedPreferences.getInstance();
  // Pastikan ini menggunakan kunci 'token' sesuai AuthService Anda
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
  
  // Pastikan lat/long dikirim hanya jika ada isinya
  if (latitude != null && latitude.isNotEmpty) request.fields['latitude'] = latitude;
  if (longitude != null && longitude.isNotEmpty) request.fields['longitude'] = longitude;

  if (profileImage != null) {
   print("MENGIRIM FILE DARI PATH: ${profileImage.path}");
   request.files.add(
    await http.MultipartFile.fromPath(
     // Nama field harus SAMA dengan yang diterima Laravel (profile_image)
     'profile_image', 
     profileImage.path,
    ),
   );
  }

  try {
   var streamedResponse = await request.send();
   var response = await http.Response.fromStream(streamedResponse);
   
   print("UPDATE PROFILE STATUS: ${response.statusCode}");
   print("UPDATE PROFILE BODY: ${response.body}");


   final data = jsonDecode(response.body);

   if (response.statusCode == 200) {
    // SIMPAN USER BARU KE LOCAL
    await prefs.setString("user", jsonEncode(data["user"]));

    return {
     'success': true,
     'message': data["message"] ?? 'Profil berhasil diperbarui.'
    };
   }

   // Handle Validation Errors (422) dan error lainnya
   if (response.statusCode == 422) {
    String validationMessage = "Validasi Gagal.";
    if (data['errors'] != null && data['errors'] is Map) {
     validationMessage = data['errors'].values.first[0] ?? validationMessage;
    }
    return {
     'success': false,
     'message': validationMessage
    };
   }
      
   return {
    'success': false,
    'message': data["message"] ?? "Gagal memperbarui profil (Status: ${response.statusCode})"
   };

  } catch (e) {
   return {'success': false, 'message': 'Terjadi error koneksi atau parsing data: $e'};
  }
 }
}