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
  int _selectedIndex = 0;

  static const List<String> _titles = <String>[
    'Beranda',
    'Keranjang',
    'Notifikasi',
    'Profil'
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = CommunityData.instance;

    // Sample product model for Beranda
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Tomat Organik',
        'price': 12000,
        'unit': 'kg',
      },
      {
        'name': 'Cabe Rawit',
        'price': 25000,
        'unit': 'kg',
      },
      {
        'name': 'Bayam Segar',
        'price': 8000,
        'unit': 'ikat',
      },
      {
        'name': 'Kangkung',
        'price': 6000,
        'unit': 'ikat',
      },
    ];

    // Beranda: scrollable content (greeting + responsive product grid + posts)
    final Widget beranda = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 8.0),
              child: Text(
                'Produk Pilihan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxWidth = constraints.maxWidth;
                  int columns = (maxWidth / 180).floor();
                  if (columns < 1) columns = 1;
                  if (columns > 3) columns = 3;

                  return GridView.count(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: products.map((item) {
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.image, size: 48, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${item['price'].toString()} / ${item['unit']}',
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('${item['name']} ditambahkan ke keranjang')),
                                        );
                                      },
                                      child: const Text('Tambah'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Favorite: ${item['name']}')),
                                      );
                                    },
                                    icon: Icon(Icons.favorite_border, color: Theme.of(context).colorScheme.primary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            // Posts list below (non-scrollable list inside the single scroll view)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: ValueListenableBuilder<List<Post>>(
                valueListenable: data.posts,
                builder: (context, posts, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Postingan Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            ),
          ],
        ),
      ),
    );

    final List<Widget> pages = <Widget>[
      beranda,
      const Center(child: Text('Keranjang', style: TextStyle(fontSize: 18))),
      const Center(child: Text('Notifikasi', style: TextStyle(fontSize: 18))),
      const Center(child: Text('Profil', style: TextStyle(fontSize: 18))),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => LoginScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            // ...existing code...
          ),
        ),
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
