import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; // 🔥 TAMBAH: Untuk bytes di Web
import 'package:flutter/foundation.dart' show kIsWeb; // 🔥 TAMBAH: Untuk kIsWeb
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart'; // 🔥 TAMBAH: Untuk XFile

class VerificationService {

 static Future<bool> uploadVerification({
  required String fullName,
  required String nik,
  required String address,
  required XFile ktpImageXFile, // 🔥 GANTI: Menerima XFile
 }) async {

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) {
   print("Tidak ada token -> user belum login");
   return false;
  }

  // 🔥 PERBAIKAN URL: Gunakan 127.0.0.1 untuk development lokal
  var url = Uri.parse("http://127.0.0.1:8000/api/verification/submit");

  var request = http.MultipartRequest("POST", url);
  request.headers['Authorization'] = "Bearer $token";

  request.fields['full_name'] = fullName;
  request.fields['nik'] = nik;
  request.fields['address'] = address;

    String fieldName = 'ktp_image';
    
    // 🔥 LOGIKA KONDISIONAL UNTUK UPLOAD FILE
    if (kIsWeb) {
        // WEB: Gunakan fromBytes
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
        // MOBILE/DESKTOP: Gunakan fromPath
        request.files.add(
            await http.MultipartFile.fromPath(
                fieldName,
                ktpImageXFile.path,
                contentType: MediaType('image', 'jpeg'),
            ),
        );
    }

  var response = await request.send();

  print("STATUS: ${response.statusCode}");
  print(await response.stream.bytesToString());

  return response.statusCode == 200;
 }

 // 🔥 PERBAIKAN URL: Menggunakan 127.0.0.1 untuk konsistensi di Web/Mobile debugging
 static Future<String> getStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");

  if (token == null) return "none";

  // 🔥 GANTI URL KE 127.0.0.1 (atau 10.0.2.2 jika Anda menggunakan Android Emulator)
  var url = Uri.parse("http://127.0.0.1:8000/api/verification/status");

  var response = await http.get(
   url,
   headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token",
   },
  );

  print("STATUS RESPONSE: ${response.statusCode}");
  
  if (response.statusCode != 200) return "none";

  final data = jsonDecode(response.body);

  return data["status"] ?? "none";
 }
}