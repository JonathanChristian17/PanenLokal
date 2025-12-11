import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class VerificationService {

  static Future<bool> uploadVerification({
    required String fullName,
    required String nik,
    required String address,
    required File ktpImage,
  }) async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) {
      print("Tidak ada token -> user belum login");
      return false;
    }

    var url = Uri.parse("http://127.0.0.1:8000/api/verification/submit");

    var request = http.MultipartRequest("POST", url);
    request.headers['Authorization'] = "Bearer $token";

    request.fields['full_name'] = fullName;
    request.fields['nik'] = nik;
    request.fields['address'] = address;

    request.files.add(
      await http.MultipartFile.fromPath(
        'ktp_image',
        ktpImage.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    var response = await request.send();

    print("STATUS: ${response.statusCode}");
    print(await response.stream.bytesToString());

    return response.statusCode == 200;
  }

  // 🔥 Tambahkan ini supaya ProfileScreen bisa membaca status
  static Future<String> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return "none";

    var url = Uri.parse("http://10.0.2.2:8000/api/verification/status");

    var response = await http.get(
      url,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("STATUS RESPONSE: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode != 200) return "none";

    final data = jsonDecode(response.body);

    return data["status"] ?? "none";
  }
}
