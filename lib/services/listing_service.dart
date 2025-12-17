import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ListingService {
  final Dio _dio = Dio();
  static const String _baseUrl = "http://10.0.2.2:8000/api";
  
    ListingService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
  }

  // CREATE LISTING
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
    required List<XFile> images,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final Map<String, dynamic> dataMap = {
        'title': title,
        'location': location,
        'area': area,
        'price': price.toString(),
        'stock': stock.toString(),
        'category': category,
        'type': type,
        'contact_name': contactName,
        'contact_number': contactNumber,
      };

      if (description != null && description.isNotEmpty) {
        dataMap['description'] = description;
      }

      final formData = FormData.fromMap(dataMap);

      for (final image in images) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          formData.files.add(
            MapEntry(
              'images[]',
              MultipartFile.fromBytes(
                bytes,
                filename: image.name,
              ),
            ),
          );
        } else {
          formData.files.add(
            MapEntry(
              'images[]',
              await MultipartFile.fromFile(
                image.path,
                filename: image.name,
              ),
            ),
          );
        }
      }

      final response = await _dio.post(
        '/listings',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return {'success': true, 'data': response.data};
      
    } on DioException catch (e) {
      print("DioException: ${e.response?.data}");
      print("Status: ${e.response?.statusCode}");
      
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        return {
          'success': false, 
          'message': 'Validasi gagal: ${errors?.toString() ?? e.response?.data['message']}'
        };
      }
      
      return {
        'success': false, 
        'message': e.response?.data['message'] ?? 'Terjadi kesalahan'
      };
    } catch (e) {
      print("Exception: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // FETCH MY LISTINGS
  Future<Map<String, dynamic>> getMyListings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      print("📡 Fetching listings with token: ${token.substring(0, 20)}...");

      final response = await _dio.get(
        '/listings',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print("✅ Response status: ${response.statusCode}");
      print("📦 Response data: ${response.data}");

      return {'success': true, 'data': response.data};
      
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.data}");
      print("Status: ${e.response?.statusCode}");
      print("Message: ${e.message}");
      
      return {
        'success': false, 
        'message': e.response?.data['message'] ?? 'Gagal mengambil data'
      };
    } catch (e) {
      print("❌ Exception: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // GET ALL ACTIVE LISTINGS (untuk buyer)
  Future<Map<String, dynamic>> getAllActiveListings() async {
    try {
      print("📡 Fetching all active listings...");

      final response = await _dio.get(
        '/listings/active',
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print("✅ Response status: ${response.statusCode}");
      print("📊 Active listings count: ${response.data['data']?.length ?? 0}");

      return {'success': true, 'data': response.data};
      
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.data}");
      print("Status: ${e.response?.statusCode}");
      
      return {
        'success': false, 
        'message': e.response?.data['message'] ?? 'Gagal mengambil data'
      };
    } catch (e) {
      print("❌ Exception: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // UPDATE LISTING
  Future<Map<String, dynamic>> updateListing({
    required String listingId,
    String? location,
    String? area,
    String? contactNumber,
    double? price,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final Map<String, dynamic> dataMap = {};
      if (location != null) dataMap['location'] = location;
      if (area != null) dataMap['area'] = area;
      if (contactNumber != null) dataMap['contact_number'] = contactNumber;
      if (price != null) dataMap['price'] = price.toString();

      print("🔄 Updating listing $listingId with data: $dataMap");

      final response = await _dio.put(
        '/listings/$listingId',
        data: dataMap,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return {'success': true, 'data': response.data};
      
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.data}");
      print("Status: ${e.response?.statusCode}");
      
      return {
        'success': false, 
        'message': e.response?.data['message'] ?? 'Gagal update'
      };
    } catch (e) {
      print("❌ Exception: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // MARK AS SOLD
  Future<Map<String, dynamic>> markAsSold({
    required String listingId,
    required double soldPrice,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      print("💰 Marking listing $listingId as sold with price: $soldPrice");

      final response = await _dio.post(
        '/listings/$listingId/mark-sold',
        data: {
          'sold_price': soldPrice.toString(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return {'success': true, 'data': response.data};
      
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.data}");
      print("Status: ${e.response?.statusCode}");
      
      return {
        'success': false, 
        'message': e.response?.data['message'] ?? 'Gagal tandai laku'
      };
    } catch (e) {
      print("❌ Exception: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // DELETE LISTING
  Future<Map<String, dynamic>> deleteListing(String listingId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await _dio.delete(
        '/listings/$listingId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return {'success': true, 'data': response.data};
      
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.data}");
      return {
        'success': false, 
        'message': e.response?.data['message'] ?? 'Gagal hapus listing'
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}