import 'package:flutter/material.dart';
import '../models/community_data.dart';
import 'login_screen.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key, required this.title});
  final String title;

  @override
  State<MyHomeScreen> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomeScreen> {

  @override
  Widget build(BuildContext context) {
    final data = CommunityData.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) =>  LoginScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            // children: [
            //   DrawerHeader(
            //     decoration: BoxDecoration(color: Colors.green),
            //     child: const Text('Menu Komunitas',
            //         style: TextStyle(color: Colors.white, fontSize: 20)),
            //   ),
            // //   ListTile(
            // //     leading: const Icon(Icons.forum_outlined),
            // //     title: const Text('Diskusi'),
            // //     onTap: () => _openPage(const DiscussionPage()),
            // //   ),
            // //   ListTile(
            // //     leading: const Icon(Icons.photo_library_outlined),
            // //     title: const Text('Galeri Tanaman'),
            // //     onTap: () => _openPage(const GalleryPage()),
            // //   ),
            // //   ListTile(
            // //     leading: const Icon(Icons.event_outlined),
            // //     title: const Text('Acara'),
            // //     onTap: () => _openPage(const EventsPage()),
            // //   ),
            // //   ListTile(
            // //     leading: const Icon(Icons.add_box_outlined),
            // //     title: const Text('Tambah Postingan'),
            // //     onTap: () => _openPage(const CreatePostPage()),
            // //   ),
            // // ],
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Post>>(
        valueListenable: data.posts,
        builder: (context, posts, _) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Postingan Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final post in posts)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(post.content),
                  subtitle: Text('Likes: ${post.likes}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
