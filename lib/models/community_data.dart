import 'package:flutter/material.dart';

class Post {
  Post(this.content, {this.likes = 0});
  final String content;
  int likes;
}

class EventItem {
  EventItem(this.title, this.subtitle, {this.rsvp = false});
  final String title;
  final String subtitle;
  bool rsvp;
}

class Plant {
  Plant({required this.name, required this.note, required this.imageAsset});
  final String name;
  final String note;
  final String imageAsset;
}

class CommunityData {
  CommunityData._();
  static final CommunityData instance = CommunityData._();

  final ValueNotifier<List<Post>> posts = ValueNotifier([]);
  final ValueNotifier<List<EventItem>> events = ValueNotifier([]);
  final ValueNotifier<List<Plant>> plants = ValueNotifier([]);

  void addPost(String content) {
    posts.value = [Post(content), ...posts.value];
  }

  void likePost(int index) {
    final list = posts.value;
    if (index < 0 || index >= list.length) return;
    list[index].likes++;
    posts.value = List.from(list);
  }

  void toggleRsvp(int index) {
    final list = events.value;
    if (index < 0 || index >= list.length) return;
    list[index].rsvp = !list[index].rsvp;
    events.value = List.from(list);
  }
}
