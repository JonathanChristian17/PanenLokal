import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

/// UPDATE PASSWORD LANGSUNG
static Future<String> updatePassword({
  required String email,
  required String newPassword,
}) async {
  try {
    final url = Uri.parse("$baseUrl/reset-password");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "new_password": newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["message"] ?? "Password berhasil diubah";
    } else if (response.statusCode == 404) {
      return "Email tidak terdaftar";
    } else {
      return "Gagal mengubah password";
    }
  } catch (e) {
    return "Terjadi kesalahan: $e";
  }
}

  /// LOGIN
  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/login");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );

      print("LOGIN STATUS: ${response.statusCode}");
      print("LOGIN BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = UserModel.fromJson(data);

        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("token", user.token);
        await pref.setString("user", jsonEncode(data["user"]));

        print("✅ LOGIN BERHASIL - TOKEN TERSIMPAN");
        return user;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// REGISTER
  static Future<UserModel?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/register");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "full_name": name,
          "email": email,
          "phone": phone,
          "password": password,
          "address": "-"
        }),
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER BODY: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = UserModel.fromJson(data);

        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setString("token", user.token);
        await pref.setString("user", jsonEncode(data["user"]));

        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// GET USER DATA
  static Future<UserModel?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");


      if (token == null || token.isEmpty) {
        return null;
      }

      print("📡 REQUEST GET PROFILE...");
      final response = await http.get(
        Uri.parse("$baseUrl/profile"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print("⏱️ REQUEST TIMEOUT");
          throw Exception("Request timeout");
        },
      );

      print("GET PROFILE STATUS: ${response.statusCode}");
      print("GET PROFILE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Simpan raw user dari API
        await prefs.setString("user", jsonEncode(data));

        // Bangun user model dari data langsung
        final user = UserModel.fromJson({
          "user": data,
          "token": token,
        });
        return user;
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// CHECK IF USER IS LOGGED IN
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// GET LOCAL USER (Tanpa Internet/API Call)
  static Future<UserModel?> getLocalUser() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? userString = pref.getString("user"); // Ambil string JSON yang disimpan saat login

      if (userString != null && userString.isNotEmpty) {
        // Decode JSON string menjadi Map
        final userData = jsonDecode(userString);
        // Ubah menjadi Object UserModel
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// GET TOKEN
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString("token");
    } catch (e) {
      return null;
    }
  }

  /// LOGOUT
  static Future<void> logout() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.remove("token");
      await pref.remove("user");
    } catch (e) {
    }
  }
}