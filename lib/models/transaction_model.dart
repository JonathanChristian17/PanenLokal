import 'package:panen_lokal/models/transaction_status.dart'; // ✅ TAMBAHKAN INI

class TransactionModel {
  final String id;
  final String? buyerId;
  final String? farmerId;
  final String? listingId;
  final String? productName;
  final String? productImage;
  final double? price;
  final TransactionStatus status;
  final DateTime? contactedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool hasReviewed; // ✅ TAMBAHKAN INI
  
  // Buyer info
  final String? buyerName;
  final String? buyerPhone;
  
  // Farmer info (untuk buyer view)
  final String? farmerName;
  final String? farmerPhone;

  TransactionModel({
    required this.id,
    this.buyerId,
    this.farmerId,
    this.listingId,
    this.productName,
    this.productImage,
    this.price,
    required this.status,
    this.contactedAt,
    this.completedAt,
    required this.createdAt,
    this.updatedAt,
    this.hasReviewed = false, // ✅ DEFAULT false
    this.buyerName,
    this.buyerPhone,
    this.farmerName,
    this.farmerPhone,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      buyerId: json['buyer_id']?.toString(),
      farmerId: json['farmer_id']?.toString(),
      listingId: json['listing_id']?.toString(),
      productName: _extractProductName(json),
      productImage: _extractProductImage(json),
      price: _extractPrice(json),
      status: _parseStatus(json['status']),
      contactedAt: _parseDateTime(json['contacted_at']),
      completedAt: _parseDateTime(json['completed_at']),
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at']),
      hasReviewed: json['has_reviewed'] == true, // ✅ TAMBAHKAN INI
      buyerName: json['buyer']?['name'],
      buyerPhone: json['buyer']?['phone'],
      farmerName: json['farmer']?['name'],
      farmerPhone: json['farmer']?['phone'],
    );
  }

  // Helper: Extract product name dari nested listing
  static String? _extractProductName(Map<String, dynamic> json) {
    // ✅ FIXED: Cek listing.title dulu
    if (json['listing'] != null && json['listing']['title'] != null) {
      return json['listing']['title'];
    }
    if (json['listing'] != null && json['listing']['name'] != null) {
      return json['listing']['name'];
    }
    return json['product_name'];
  }

  static String? _extractProductImage(Map<String, dynamic> json) {
  // ✅ Cek listing.images (nested dari backend)
  if (json['listing'] != null && json['listing']['images'] != null) {
    final images = json['listing']['images'] as List;
    if (images.isNotEmpty) {
      final firstImage = images[0];
      
      // ✅ Coba beberapa field
      String? imageUrl = firstImage['url'] ?? 
                        firstImage['image_url'] ?? 
                        firstImage['path'];
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        print('✅ Found image URL: $imageUrl'); // Debug
        return imageUrl;
      }
    }
  }
  
  // ✅ Fallback ke product_image langsung
  if (json['product_image'] != null && json['product_image'].toString().isNotEmpty) {
    print('✅ Using product_image: ${json['product_image']}');
    return json['product_image'];
  }
  
  print('❌ No image found in: ${json['listing']?['images']}');
  return null;
}

  // Helper: Extract price dari nested listing
  static double? _extractPrice(Map<String, dynamic> json) {
    if (json['listing'] != null && json['listing']['price'] != null) {
      return double.tryParse(json['listing']['price'].toString());
    }
    if (json['price'] != null) {
      return double.tryParse(json['price'].toString());
    }
    return null;
  }

  // Helper: Parse status string to enum
  static TransactionStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'success':
        return TransactionStatus.success;
      case 'failed':
        return TransactionStatus.failed;
      case 'pending':
        return TransactionStatus.pending;
      case 'negotiating':
      default:
        return TransactionStatus.negotiating;
    }
  }

  // Helper: Parse datetime string
  static DateTime? _parseDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'farmer_id': farmerId,
      'listing_id': listingId,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'status': status.name,
      'contacted_at': contactedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'has_reviewed': hasReviewed,
    };
  }
}