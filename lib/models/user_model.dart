import 'dart:convert';

class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String? slogan;
  final String? latitude;
  final String? longitude;
  final String? avatarUrl;
  final String address;
  final bool verified; // 🔥 DIBACA DARI LARAVEL
  final String token;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.address,
    this.slogan,
    this.latitude,
    this.longitude,
    this.avatarUrl,
    this.verified = false,
    this.token = "",
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final u = json["user"] ?? json;
    
    // 🔥 PERBAIKAN: Larave Accessor 'verified' mengembalikan boolean
    final isVerified = u["verified"] == true;

    return UserModel(
      id: u["id"] ?? 0,
      fullName: u["full_name"] ?? "",
      email: u["email"] ?? "",
      phone: u["phone"] ?? "",
      role: u["role"] ?? "buyer",
      address: u["address"] ?? "-",
      slogan: u["slogan"],
      latitude: u["latitude"]?.toString(),
      longitude: u["longitude"]?.toString(),
      avatarUrl: u["avatar_url"],
      verified: isVerified, // 🔥 MENGGUNAKAN NILAI DARI LARAVEL
      token: json["token"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "role": role,
        "address": address,
        "slogan": slogan,
        "latitude": latitude,
        "longitude": longitude,
        "avatar_url": avatarUrl,
        "verified": verified,
        "token": token,
      };

  String toJsonString() => jsonEncode(toJson());
}