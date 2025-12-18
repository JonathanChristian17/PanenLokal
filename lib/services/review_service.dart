import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // pastikan ini ada


class ReviewService {
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<Map<String, dynamic>> getReviews({String? sellerId}) async {
    try {
      final token = await AuthService.getToken();

      final uri = sellerId == null
          ? Uri.parse('$baseUrl/reviews')
          : Uri.parse('$baseUrl/reviews/$sellerId');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        return {
          'success': true,
          'data': decoded['data'],
          'total': decoded['total'],
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data ulasan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
