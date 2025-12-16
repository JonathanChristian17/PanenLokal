import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionService {
  final Dio _dio = Dio();
  static const String _baseUrl = "http://127.0.0.1:8000/api";

  TransactionService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
  }

  /// ✅ Membuat transaksi baru ketika buyer menghubungi seller
  Future<Map<String, dynamic>> createTransaction(String listingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception("Token tidak ditemukan. Silakan login kembali.");
      }

      final response = await _dio.post(
        '/transactions',
        data: {
          'listing_id': listingId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // ✅ Return response data
      return {
        'success': response.data['success'] ?? true,
        'message': response.data['message'] ?? 'Transaksi berhasil dibuat',
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      // ✅ Handle error dari backend
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Gagal membuat transaksi');
      } else {
        throw Exception('Koneksi ke server gagal');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}