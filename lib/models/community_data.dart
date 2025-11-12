// File: lib/models/community_data.dart

import 'package:flutter/material.dart';

class Post {
  final String content;
  int likes;

  Post({required this.content, this.likes = 0});
}

class CommunityData {
  // Singleton pattern
  static final CommunityData _instance = CommunityData._internal();
  factory CommunityData() => _instance;
  CommunityData._internal();
  static CommunityData get instance => _instance;

  // Data komunitas (ValueNotifier untuk Reaktif)
  final ValueNotifier<List<Post>> posts = ValueNotifier<List<Post>>([
    Post(content: 'Ada yang tahu harga tomat hari ini di Brebes?', likes: 12),
    Post(content: 'Saya cari supplier cabe rawit 5 ton per minggu.', likes: 5),
    Post(content: 'Tips ampuh mengusir hama wereng!', likes: 25),
    Post(content: 'Lelang 10 ton singkong dengan harga terbaik!', likes: 8),
    Post(content: 'Bagaimana cara mencegah busuk akar pada tanaman?', likes: 15),
  ]);
}