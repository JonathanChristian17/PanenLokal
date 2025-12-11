class MarketPrice {
  final String commodity;
  final String price;
  final String unit;
  final String icon;

  MarketPrice({
    required this.commodity,
    required this.price,
    required this.unit,
    required this.icon,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      commodity: json['commodity'] ?? '',
      price: json['price'] ?? '',
      unit: json['unit'] ?? 'KG',
      icon: json['icon'] ?? '🥬',
    );
  }
}
