import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:panen_lokal/models/verification_submission.dart';

class AdminVerificationService {
  final String _baseUrl = "http://127.0.0.1:8000/api";

  Future<List<VerificationSubmission>> fetchPendingSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return [];

    final url = Uri.parse('$_baseUrl/admin/verifications/pending');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] is List) {
          return (data['data'] as List)
              .map((json) => VerificationSubmission.fromJson(json))
              .toList();
        }
      }
      print('Failed to fetch pending verifications: Status ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error fetching pending verifications: $e');
      return [];
    }
  }

  Future<bool> updateVerificationStatus(int userId, String status, {String? note}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return false;

    final url = Uri.parse('$_baseUrl/admin/verifications/status/$userId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'status': status, 'note': note}),
      );

      print('Update Status Response: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }
}