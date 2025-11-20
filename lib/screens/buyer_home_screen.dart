import 'dart:math';
import 'package:flutter/material.dart';
import '../models/community_data.dart';
import 'profile_screen.dart';
import 'request_screen.dart';
import 'notification_screen.dart';

// Definisi model CommodityPost
class CommodityPost {
  final String commodity;
  final String location;
  final String area;
  final int priceKg;
  final double quantityTons;
  final String contactName;
  final String contactInfo;
  final String imagePath;

  const CommodityPost({
    required this.commodity,
    required this.location,
    required this.area,
    required this.priceKg,
    required this.quantityTons,
    required this.contactName,
    required this.contactInfo,
    required this.imagePath,
  });
}

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key, required this.title});
  final String title;

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Data Tawaran Komoditas Contoh
 final List<CommodityPost> commodityPosts = const [
    CommodityPost(
      commodity: 'Wortel Kualitas A',
      location: 'Bandungan, Semarang',
      area: '2 Hektar',
      priceKg: 4000,
      quantityTons: 17.0,
      contactName: 'Pak Budi (Penjual)',
      contactInfo: 'WA: 0812xxxxxx',
      imagePath: 'assets/images/wortel.jpg',
    ),
    CommodityPost(
      commodity: 'Tomat Cherry Organik',
      location: 'Pangalengan, Bandung',
      area: '5000 m²',
      priceKg: 12000,
      quantityTons: 5.5,
      contactName: 'Tani Jaya (Grup)',
      contactInfo: 'IG: @tanijaya_fresh',
      imagePath: 'assets/images/tomat.jpg',
    ),
    CommodityPost(
      commodity: 'Bawang Merah Brebes',
      location: 'Brebes',
      area: '1 Hektar',
      priceKg: 25000,
      quantityTons: 10.0,
      contactName: 'Ibu Siti',
      contactInfo: 'WA: 0813xxxxxx',
      imagePath: 'assets/images/bawang.jpg',
    ),
    CommodityPost(
      commodity: 'Cabai Merah Keriting',
      location: 'Magelang, Jawa Tengah',
      area: '0.5 Hektar',
      priceKg: 30000,
      quantityTons: 3.0,
      contactName: 'Petani Sejahtera',
      contactInfo: 'Telp: 0857xxxxxx',
      imagePath: 'assets/images/cabai.jpg',
    ),
  ];
  
  Widget _buildCommodityCard(BuildContext context, CommodityPost post) {
    return Card(
      color: const Color(0xFFF5F7F8),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Melihat detail: ${post.commodity}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              Container(
                width: 120,
                height: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(post.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.commodity,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          post.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Harga/Kg:',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              'Rp ${post.priceKg}/kg',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Kuantitas:',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              '${post.quantityTons} Ton',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Logika hubungi penjual
                        },
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Hubungi',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6B93B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = CommunityData.instance; 

    final filteredPosts = commodityPosts.where((post) {
      final searchLower = _searchController.text.toLowerCase();
      if (searchLower.isNotEmpty && 
          !(post.commodity.toLowerCase().contains(searchLower) ||
            post.location.toLowerCase().contains(searchLower))) {
        return false;
      }
      if (_selectedCategory != 'Semua') {
        if (_selectedCategory == 'Sayur' && !['Wortel Kualitas A', 'Tomat Cherry Organik', 'Bawang Merah Brebes', 'Cabai Merah Keriting'].contains(post.commodity)) return false;
        if (_selectedCategory == 'Lelang' && !post.commodity.toLowerCase().contains('lelang')) return false; // Placeholder for actual "Lelang" tag
        if (_selectedCategory == 'Organik' && !post.commodity.toLowerCase().contains('organik')) return false;
      }
      return true;
    }).toList();


    final Widget berandaContent = SafeArea( 
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.background, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator( // Tambahkan RefreshIndicator
          onRefresh: () async {
            setState(() {
              // Logika refresh data
            });
            await Future.delayed(const Duration(seconds: 1)); // Simulasikan loading
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Selalu bisa di-scroll untuk refresh
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
                    child: Text(
                      'Halo, Pembeli!', 
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Temukan komoditas segar langsung dari petani terbaik.', 
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari Komoditas atau Lokasi...',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchController.text.isNotEmpty 
                            ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey), onPressed: () { _searchController.clear(); setState(() {}); })
                            : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), // Lebih rounded
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChoiceChip('Semua'),
                          _buildChoiceChip('Sayur'),
                          _buildChoiceChip('Buah'),
                          _buildChoiceChip('Organik'),
                          _buildChoiceChip('Lelang'),
                          _buildChoiceChip('Cepat Habis'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                    child: Text('Tawaran Terbaru (${filteredPosts.length})', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)),
                  ),

                  // Daftar Kartu Listing
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        return _buildCommodityCard(context, filteredPosts[index]);
                      },
                    ),
                  ),
                  
                  // Bagian Diskusi Komunitas
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
                    child: Text('Diskusi Komunitas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ValueListenableBuilder<List<Post>>(
                      valueListenable: data.posts,
                      builder: (context, posts, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: posts.map((post) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.content, style: const TextStyle(fontSize: 15)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('❤️ ${post.likes} Suka', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                    TextButton.icon(
                                      icon: const Icon(Icons.comment, size: 16),
                                      label: const Text('Lihat Komentar', style: TextStyle(fontSize: 13)),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Melihat komentar untuk: ${post.content}')));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 88), // Memberi ruang untuk bottom nav bar
                ],
              ),
            ),
          ),
        ),
      ),
    );
    
    final List<Widget> pagesWithHome = <Widget>[
      berandaContent, 
      const NotificationScreen(), 
      const RequestScreen(), 
      const ProfileScreen(), 
    ];

    return Scaffold(
      body: pagesWithHome[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorit'), 
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Harga Pasar'), 
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedCategory == label,
        onSelected: (bool selected) {
          setState(() {
            _selectedCategory = selected ? label : 'Semua';
          });
        },
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        labelStyle: TextStyle(
          color: _selectedCategory == label ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
          fontWeight: _selectedCategory == label ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: _selectedCategory == label ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}