class ReviewModel {
  final String id;
  final String reviewerName;
  final String sellerName; 
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String itemTitle;

  ReviewModel({
    required this.id,
    required this.reviewerName,
    required this.sellerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.itemTitle,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'].toString(),
      reviewerName: json['reviewer']['full_name'],
      sellerName: json['seller']?['full_name'] ?? '-', 
      rating: json['rating'],
      comment: json['comment'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      itemTitle: json['item']['title'] ?? '-',
    );
  }
}
