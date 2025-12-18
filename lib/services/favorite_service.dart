import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class FavoriteService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Toggle favorite status (add or remove)
  Future<Map<String, dynamic>> toggleFavorite(String listingId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
        };
      }

      print('🔄 Toggling favorite for listing: $listingId');

      final response = await http.post(
        Uri.parse('$baseUrl/favorites/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'listing_id': listingId,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Favorite toggled successfully');
        return data;
      } else {
        final error = json.decode(response.body);
        print('❌ Failed to toggle favorite: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Gagal mengubah status favorit',
        };
      }
    } catch (e) {
      print('❌ Error toggling favorite: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get all favorites for current user
  Future<Map<String, dynamic>> getFavorites() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
        };
      }

      print('🔄 Loading favorites...');

      final response = await http.get(
        Uri.parse('$baseUrl/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Favorites loaded: ${data['data'].length} items');
        return data;
      } else {
        final error = json.decode(response.body);
        print('❌ Failed to load favorites: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Gagal memuat favorit',
        };
      }
    } catch (e) {
      print('❌ Error loading favorites: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Get favorite IDs only (for checking if listings are favorited)
  Future<Map<String, dynamic>> getFavoriteIds() async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'favorite_ids': <String>[],
        };
      }

      print('🔄 Loading favorite IDs...');

      final response = await http.get(
        Uri.parse('$baseUrl/favorites/ids'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Favorite IDs loaded: ${data['favorite_ids'].length} items');
        return data;
      } else {
        final error = json.decode(response.body);
        print('❌ Failed to load favorite IDs: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Gagal memuat favorite IDs',
          'favorite_ids': <String>[],
        };
      }
    } catch (e) {
      print('❌ Error loading favorite IDs: $e');
      return {
        'success': false,
        'message': 'Error: $e',
        'favorite_ids': <String>[],
      };
    }
  }

  // Check if a specific listing is favorited
  Future<Map<String, dynamic>> checkFavorite(String listingId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
          'is_favorited': false,
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/favorites/check/$listingId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Gagal memeriksa status favorit',
          'is_favorited': false,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
        'is_favorited': false,
      };
    }
  }

  // Remove a favorite
  Future<Map<String, dynamic>> removeFavorite(String listingId) async {
    try {
      final token = await AuthService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan. Silakan login kembali.',
        };
      }

      print('🔄 Removing favorite: $listingId');

      final response = await http.delete(
        Uri.parse('$baseUrl/favorites/$listingId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Favorite removed successfully');
        return data;
      } else {
        final error = json.decode(response.body);
        print('❌ Failed to remove favorite: ${error['message']}');
        return {
          'success': false,
          'message': error['message'] ?? 'Gagal menghapus favorit',
        };
      }
    } catch (e) {
      print('❌ Error removing favorite: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}