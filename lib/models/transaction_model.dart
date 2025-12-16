import 'transaction_status.dart';

class TransactionModel {
  final String id;
  final String buyerId;
  final String farmerId;
  final String listingId;
  final TransactionStatus status;
  final DateTime? contactedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ✅ Data listing (opsional, jika butuh info produk)
  final String? productName;
  final String? productImage;
  final double? price;

  TransactionModel({
    required this.id,
    required this.buyerId,
    required this.farmerId,
    required this.listingId,
    required this.status,
    this.contactedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.productName,
    this.productImage,
    this.price,
  });

  // ✅ Factory method untuk parsing dari API Laravel
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      buyerId: json['buyer_id'].toString(),
      farmerId: json['farmer_id'].toString(),
      listingId: json['listing_id'].toString(),
      status: TransactionStatusExtension.fromString(json['status'] ?? 'negotiating'),
      contactedAt: json['contacted_at'] != null 
          ? DateTime.parse(json['contacted_at']) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      // Jika API mengirim data listing
      productName: json['listing']?['title'],
      productImage: json['listing']?['images']?[0],
      price: json['listing']?['price'] != null 
          ? double.tryParse(json['listing']['price'].toString()) 
          : null,
    );
  }

  // ✅ Convert ke JSON (untuk kirim ke API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'farmer_id': farmerId,
      'listing_id': listingId,
      'status': status.value,
      'contacted_at': contactedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}