import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';

class AuthService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  /// LOGIN
  static Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data);

      // Simpan session
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString("token", user.token);
      await pref.setString("user", user.toJsonString());

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
      headers: {"Content-Type": "application/json"},
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
      await pref.setString("user", user.toJsonString());
      return user;
    }
    return null;
  }

  /// GET USER DATA DARI TOKEN
  static Future<UserModel?> getUserData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token");
    final userString = pref.getString("user");

    if (token == null || userString == null) return null;

    final userMap = jsonDecode(userString);
    return UserModel.fromJson(userMap);
  }

 static Future<void> logout(BuildContext context) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.clear();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
}
