import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class ListingService {
  final Dio _dio = Dio();
  // 🔥 SAMAKAN dengan AuthService
  static const String _baseUrl = "http://127.0.0.1:8000/api";

  ListingService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
  }

  Future<Map<String, dynamic>> createListing({
    required String title,
    String? description,
    required String location,
    required String area,
    required double price,
    required double stock,
    required String category,
    required String type,
    required String contactName,
    required String contactNumber,
    required List<File> images,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // 🔥 PERBAIKAN: Gunakan 'token', bukan 'auth_token'
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      return {'success': false, 'message': 'Token tidak ditemukan. Silakan login ulang.'};
    }

    FormData formData = FormData.fromMap({
      'title': title,
      'description': description ?? '',
      'location': location,
      'area': area,
      'price': price,
      'stock': stock,
      'category': category,
      'type': type,
      'contact_name': contactName,
      'contact_number': contactNumber,
    });

    // Tambahkan gambar
    for (int i = 0; i < images.length; i++) {
      formData.files.add(MapEntry(
        'images[$i]', 
        await MultipartFile.fromFile(
          images[i].path,
          filename: 'listing_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        ),
      ));
    }

    try {
      print('📤 Sending listing to: ${_dio.options.baseUrl}/listings');
      print('🔑 Token: ${token.substring(0, 20)}...');
      
      final response = await _dio.post(
        '/listings',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ Response: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Listing berhasil dipublikasikan!', 'data': response.data};
      } else {
        return {'success': false, 'message': 'Status ${response.statusCode}: ${response.data}'};
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      
      String errorMessage = 'Terjadi kesalahan jaringan.';
      if (e.response != null) {
        if(e.response!.statusCode == 422) {
           errorMessage = "Validasi Gagal: ${e.response!.data['message'] ?? 'Periksa kembali form Anda'}";
        } else if(e.response!.statusCode == 401) {
           errorMessage = "Token expired atau tidak valid. Silakan login ulang.";
        } else {
           errorMessage = e.response!.data['message'] ?? 'Server Error: ${e.response!.statusCode}';
        }
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      print('❌ Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}