import 'package:panen_lokal/models/user_model.dart';
import 'dart:convert';

class VerificationSubmission {
  final int id;
  final int userId;
  final String fullName;
  final String nik;
  final String address;
  final String ktpImage; // Path/URL gambar KTP
  final String status; // 'pending', 'verified', 'rejected'
  final String? note;
  final DateTime submittedAt;
  final UserModel? user; // Data user yang mengajukan

  VerificationSubmission({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.nik,
    required this.address,
    required this.ktpImage,
    required this.status,
    required this.submittedAt,
    this.note,
    this.user,
  });

  factory VerificationSubmission.fromJson(Map<String, dynamic> json) {
    return VerificationSubmission(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String,
      nik: json['nik'] as String,
      address: json['address'] as String,
      ktpImage: json['ktp_image'] as String,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submitted_at']),
      note: json['note'],
      user: json['user'] != null ? UserModel.fromJson({'user': json['user']}) : null,
    );
  }
}