import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:panen_lokal/models/verification_submission.dart'; // Tambahkan ini

class VerificationService {

 static Future<bool> uploadVerification({
  required String fullName,
  required String nik,
  required String address,
  required XFile ktpImageXFile, 
 }) async {

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) {
   print("Tidak ada token -> user belum login");
   return false;
  }

  var url = Uri.parse("http://10.0.2.2:8000/api/verification/submit");

  var request = http.MultipartRequest("POST", url);
  request.headers['Authorization'] = "Bearer $token";
  request.headers['Accept'] = "application/json"; 

  request.fields['full_name'] = fullName;
  request.fields['nik'] = nik;
  request.fields['address'] = address;

  String fieldName = 'ktp_image';
  
  if (kIsWeb) {
    Uint8List bytes = await ktpImageXFile.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: ktpImageXFile.name,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
  } else {
    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        ktpImageXFile.path, 
        contentType: MediaType('image', 'jpeg'),
      ),
    );
  }

  var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    final responseBody = response.body;

 print("VERIF SUBMIT STATUS: ${response.statusCode}");
 print("VERIF SUBMIT BODY: $responseBody");

    if (response.statusCode == 200) {
        return true;
    } else {
        try {
            final data = jsonDecode(responseBody);
            print("Server Error: ${data['message']}");
        } catch (e) {
            print("Failed to decode response body.");
        }
        return false;
    }
}

// Mengambil status verifikasi user
static Future<String> getStatus() async {
 final prefs = await SharedPreferences.getInstance();
 final token = prefs.getString("token");

 if (token == null) return "none";

 // 🔥 URL Diperbaiki ke 127.0.0.1
 var url = Uri.parse("http://127.0.0.1:8000/api/verification/status");

 var response = await http.get(
 url,
 headers: {
  "Accept": "application/json",
  "Authorization": "Bearer $token",
 },
 );

 print("VERIF STATUS RESPONSE: ${response.statusCode}");
 
 if (response.statusCode != 200) return "none";

 final data = jsonDecode(response.body);

 return data["status"] ?? "none";
}
}