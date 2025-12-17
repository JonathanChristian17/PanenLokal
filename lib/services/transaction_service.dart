import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final Dio _dio = Dio();
  static const String _baseUrl = "http://10.0.2.2:8000/api";

  TransactionService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
  }

  Future<List<TransactionModel>> getFarmerTransactions() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await _dio.get(
    '/farmer/transactions',
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );

  return (response.data['data'] as List)
      .map((e) => TransactionModel.fromJson(e))
      .toList();
}

// ✅ Update semua transaksi berdasarkan listing_id
Future<void> updateTransactionsByListing(String listingId, String status) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    throw Exception("Token tidak ditemukan. Silakan login kembali.");
  }

  try {
    await _dio.put(
      '/listings/$listingId/transactions/status',
      data: {
        'status': status, // success | failed
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal mengubah status transaksi',
      );
    } else {
      throw Exception('Koneksi ke server gagal');
    }
  }
}

   Future<List<TransactionModel>> getMyTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await _dio.get(
      '/transactions',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    final List data = response.data['data'];

    return data.map((e) => TransactionModel.fromJson(e)).toList();
  }

    Future<void> submitReview({
    required String transactionId,
    required int rating,
    String? comment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await _dio.post(
      '/reviews',
      data: {
        'transaction_id': transactionId,
        'rating': rating,
        'comment': comment,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }


  Future<void> updateStatus(String transactionId, String status) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    throw Exception("Token tidak ditemukan. Silakan login kembali.");
  }

  try {
    await _dio.put(
      '/transactions/$transactionId/status',
      data: {
        'status': status, // success | failed
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
  } on DioException catch (e) {
    if (e.response != null) {
      throw Exception(
        e.response?.data['message'] ?? 'Gagal mengubah status transaksi',
      );
    } else {
      throw Exception('Koneksi ke server gagal');
    }
  }
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