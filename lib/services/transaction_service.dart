import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:panen_lokal/models/transaction_model.dart';
import 'package:panen_lokal/services/auth_service.dart';

class TransactionService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// Get auth token dari storage
  Future<String?> _getToken() async {
    return await AuthService.getToken();
  }

  /// ✅ Get buyer's transactions
  Future<List<TransactionModel>> getMyTransactions() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List transactions = data['data'];
        return transactions.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Gagal memuat transaksi');
      }
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode}');
    }
  }

  /// ✅ Get farmer's transactions (untuk penjual)
  Future<List<TransactionModel>> getFarmerTransactions() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/farmer/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final List transactions = data['data'];
        return transactions.map((json) => TransactionModel.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Gagal memuat transaksi');
      }
    } else {
      throw Exception('Failed to load farmer transactions: ${response.statusCode}');
    }
  }

  /// ✅ Create new transaction (saat klik "Hubungi Penjual")
  /// ✅ Create new transaction (saat klik "Hubungi Penjual")
Future<Map<String, dynamic>> createTransaction(String listingId) async {
  final token = await _getToken();

  final response = await http.post(
    Uri.parse('$baseUrl/transactions'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'listing_id': listingId,
    }),
  );

  final data = json.decode(response.body);

  if (response.statusCode == 201 || response.statusCode == 200) {
    if (data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal membuat transaksi');
    }
    return data; // ✅ Return data
  } else if (response.statusCode == 400) {
    throw Exception(data['message'] ?? 'Anda sudah menghubungi penjual ini');
  } else {
    throw Exception(data['message'] ?? 'Gagal membuat transaksi');
  }
}

  /// ✅ Update status transaksi (untuk farmer)
  Future<void> updateTransactionStatus({
    required String transactionId,
    required String status, // success, failed, pending, negotiating
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/transactions/$transactionId/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Gagal update status');
      }
    } else if (response.statusCode == 403) {
      throw Exception(data['message'] ?? 'Anda tidak memiliki akses');
    } else {
      throw Exception(data['message'] ?? 'Gagal update status');
    }
  }

  /// ✅ Update semua transaksi berdasarkan listing_id (untuk farmer)
  Future<int> updateTransactionsByListing({
    required String listingId,
    required String status, // success atau failed
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/transactions/listing/$listingId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'status': status,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      if (data['success'] == true) {
        return data['updated_count'] ?? 0;
      } else {
        throw Exception(data['message'] ?? 'Gagal update transaksi');
      }
    } else {
      throw Exception(data['message'] ?? 'Gagal update transaksi');
    }
  }

  /// ✅ Submit review untuk transaksi
  Future<void> submitReview({
    required String transactionId,
    required int rating,
    String? comment,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'transaction_id': transactionId,
        'rating': rating,
        'comment': comment,
      }),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Gagal mengirim ulasan');
      }
    } else if (response.statusCode == 400) {
      throw Exception(data['message'] ?? 'Anda sudah memberikan ulasan');
    } else if (response.statusCode == 403) {
      throw Exception(data['message'] ?? 'Anda tidak bisa mengulas transaksi ini');
    } else {
      throw Exception(data['message'] ?? 'Gagal mengirim ulasan');
    }
  }
}