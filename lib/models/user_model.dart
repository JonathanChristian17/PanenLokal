import 'dart:convert';

class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final String avatarUrl;
  final bool verified;
  final String token;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.avatarUrl,
    this.verified = false,
    this.token = "",
  });

factory UserModel.fromJson(Map<String, dynamic> json) {
  final u = json["user"] ?? json; 
  return UserModel(
    id: u["id"] ?? 0,
    fullName: u["full_name"] ?? "",
    email: u["email"] ?? "",
    phone: u["phone"] ?? "",
    role: u["role"] ?? "buyer",
    avatarUrl: u["avatar_url"] ?? "",
    verified: u["verified"] ?? false,
    token: json["token"] ?? "",
  );
}


  Map<String, dynamic> toJson() => {
        "id": id,
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "role": role,
        "avatar_url": avatarUrl,
        "verified": verified,
        "token": token,
      };

  String toJsonString() => jsonEncode(toJson());
}