import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  /// LOGIN
  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final user = UserModel.fromJson(data);

      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("token", user.token);
      await pref.setString("user", jsonEncode(data));

      return user;
    }
    return null;
  }

  /// REGISTER
  static Future<UserModel?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
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

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      final user = UserModel.fromJson(data);

      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("token", user.token);
      await pref.setString("user", jsonEncode(data));

      return user;
    }
    return null;
  }

  /// GET USER DATA DARI TOKEN (PROFILE)
  static Future<UserModel?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    if (token == null) return null;

    final response = await http.get(
      Uri.parse("$baseUrl/profile"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson({"user": data, "token": token});
    }

    return null;
  }

  /// LOGOUT — HAPUS TOKEN DI DEVICE
  static Future<void> logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove("token");
    await pref.remove("user");
  }
}
