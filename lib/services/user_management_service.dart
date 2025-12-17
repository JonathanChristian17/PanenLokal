import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserManagementService {
  final String _baseUrl = "http://10.0.2.2:8000/api";

  /// Get all users (Admin only)
  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Harap login ulang.'
        };
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("GET ALL USERS STATUS: ${response.statusCode}");
      print("GET ALL USERS BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'] ?? []
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal memuat data user'
      };
      
    } catch (e) {
      print("ERROR GET ALL USERS: $e");
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  /// Delete user (Admin only)
  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Harap login ulang.'
        };
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("DELETE USER STATUS: ${response.statusCode}");
      print("DELETE USER BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'User berhasil dihapus'
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal menghapus user'
      };
      
    } catch (e) {
      print("ERROR DELETE USER: $e");
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }
}