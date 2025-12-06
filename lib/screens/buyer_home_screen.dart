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
  // Index: 0=Beranda, 1=Keranjang/Favorit (+), 2=Harga Pasar, 3=Riwayat, 4=Profil
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';

  void _onItemTapped(int index) {
      if (index == 1) {
      setState(() {
         _selectedIndex = 1; // Menandai FAB sebagai aktif jika ditekan
      });
      return; 
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  // Widget Bantu untuk Item Navigasi (DISESUAIKAN UNTUK POSISI MELENGKUNG)
  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, double verticalOffset) {
    final bool isSelected = _selectedIndex == index;
    // Menggunakan warna putih/kuning agar kontras dengan background hijau
    final Color itemColor = isSelected ? Theme.of(context).colorScheme.secondary : Colors.white70;

    return Transform.translate(
      offset: Offset(0, verticalOffset), 
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _onItemTapped(index),
          customBorder: const CircleBorder(), 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  color: itemColor,
                  size: 26,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: itemColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (Kode Data Tawaran Komoditas & _buildCommodityCard TETAP SAMA) ...
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
    
    // --- Index 1: Keranjang (FAB) ---
    // Sementara menggunakan RequestScreen atau layar Kosong
    final Widget keranjangScreen = const Center(child: Text('Keranjang Belanja'));

     // --- Index 2: Riwayat / Harga Pasar ---
    final Widget hargaPasar = const Center(child: Text("Harga Pasar Komoditas")); 

    // --- Index 3: Notifikasi / Search --- (Menggantikan Request di navbar farmer)
    // Di Navbar Farmer: 0=Store, 1=FAB, 2=Trending, 3=Search, 4=Person
    // Di Navbar Buyer Kita akan buat:
    // 0=Beranda (Store), 1=FAB (Keranjang), 2=Harga Pasar (Trending), 3=Notifikasi (Search icon?), 4=Profil

    final List<Widget> pages = <Widget>[
      berandaContent, // Index 0
      keranjangScreen, // Index 1: FAB
      hargaPasar, // Index 2
      const NotificationScreen(), // Index 3
      const ProfileScreen(), // Index 4
    ];

    // Widget bantu untuk FAB (Keranjang/Beli - Index 1)
    Widget _buildBuyerFAB(BuildContext context) {
        return FloatingActionButton(
          onPressed: () {
            _onItemTapped(1); // Navigasi ke Keranjang (Index 1)
          },
          tooltip: 'Keranjang Belanja',
          backgroundColor: Theme.of(context).colorScheme.secondary, 
          foregroundColor: Colors.white,
          elevation: 12, 
          shape: const CircleBorder(),
          child: const Icon(Icons.shopping_cart, size: 30), 
        );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: pages[_selectedIndex],
      
      // 🎯 IMPLEMENTASI NAVIGASI BAWAH MELENGKUNG (SAMA PERSIS STRUKTURNYA)
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter, 
        children: [
          // 1. CustomPainter untuk Bentuk Melengkung (Background Navbar)
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80), // Tinggi total navbar
            painter: CustomNavbarPainter(color: const Color(0xFF1B5E20)), // 🟢 Warna Hijau Gelap SAMA
            child: SizedBox(
              height: 70, // Tinggi efektif area ikon menu
              child: Row(
                children: <Widget>[
                  // Sisi Kiri
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(context, Icons.home, 'Beranda', 0, 15), 
                        _buildNavItem(context, Icons.trending_up, 'Pasar', 2, 0), 
                      ],
                    ),
                  ),

                  // Ruang kosong FAB (Fixed Center)
                  const SizedBox(width: 60), 

                  // Sisi Kanan
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(context, Icons.notifications, 'Notifikasi', 3, 0),
                        _buildNavItem(context, Icons.person, 'Profil', 4, 15), 
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 2. Floating Action Button (FAB) diposisikan di atas puncak busur
          Positioned(
            top: 0,
            child: _buildBuyerFAB(context),
          ),
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

// 📐 CUSTOM PAINTER UNTUK BENTUK MELENGKUNG PRESISI (Disalin di sini)
class CustomNavbarPainter extends CustomPainter {
  final Color color;
  CustomNavbarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color 
      ..style = PaintingStyle.fill;

    final path = Path();
    
    final double curveRadius = 35; 
    final double notchDepth = 45; 
    final double sideCurveHeight = 20; 
    final double center = size.width / 2;

    // 1. Titik Awal: Kiri Bawah
    path.moveTo(0, size.height);
    
    // 2. Tarik ke atas di sisi kiri (garis lurus ke titik awal lengkungan)
    path.lineTo(0, sideCurveHeight); 
    
    // 3. Busur Pertama (Kiri-Tengah) - Melengkung ke arah atas
    path.quadraticBezierTo(
        size.width * 0.35, sideCurveHeight - 10, 
        size.width * 0.35, sideCurveHeight - 10 
    );

    // 4. Notch Melengkung (Area FAB) - Cubic Bezier To untuk bentuk yang mulus dan presisi
    path.cubicTo(
        size.width * 0.35 + 10, sideCurveHeight - 10, 
        center - curveRadius, -notchDepth + 20, 
        center, -notchDepth + 20 
    );
    path.cubicTo(
        center + curveRadius, -notchDepth + 20, 
        size.width * 0.65 - 10, sideCurveHeight - 10, 
        size.width * 0.65, sideCurveHeight - 10 
    );
    
    // 5. Busur Kedua (Tengah-Kanan) - Melengkung ke arah tepi
    path.quadraticBezierTo(
        size.width * 0.85, sideCurveHeight - 10, 
        size.width, sideCurveHeight 
    );

    // 6. Garis ke Kanan Bawah
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height); 
    path.close();
    
    // Memberi bayangan
    canvas.drawShadow(path, Colors.black.withOpacity(0.3), 10.0, true);
    
    // Menggambar bentuk
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomNavbarPainter oldDelegate) {
    return true; 
  }
}
