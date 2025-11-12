import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'request_screen.dart';
// Import screen flow yang baru (Asumsi ada di folder farmer)
import 'farmer/verification_flow_screen.dart'; 
import 'farmer/listing_flow_screen.dart'; 

// --- MODEL COMMODITY POST (TETAP SAMA) ---

class CommodityPost {
  final String commodity; 
  final String location; 
  final String area; 
  final int priceKg; 
  final double quantityTons; 
  final String contactName; 
  final String contactInfo; 

  const CommodityPost({
    required this.commodity,
    required this.location,
    required this.area,
    required this.priceKg,
    required this.quantityTons,
    required this.contactName,
    required this.contactInfo,
  });
}

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key, required this.title});
  final String title;

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  // Index: 0=Lapak Saya, 1=Iklankan (+), 2=Harga Pasar, 3=Permintaan Beli, 4=Profil
  int _selectedIndex = 0; 

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

  // Data dummy (Contoh postingan milik petani ini)
  final List<CommodityPost> myCommodityPosts = [
    const CommodityPost(
      commodity: 'Cabai Rawit Merah',
      location: 'Ciwidey, Bandung',
      area: '5 Hektar',
      priceKg: 35000,
      contactName: 'Agus Sutanto',
      contactInfo: 'WA: 0812xxxx',
      quantityTons: 15.0,
    ),
    const CommodityPost(
      commodity: 'Wortel Brastagi',
      location: 'Kec. Brastagi',
      area: '2 Hektar',
      priceKg: 4000,
      contactName: 'Agus Sutanto',
      contactInfo: 'WA: 0812xxxx',
      quantityTons: 8.0,
    ),
  ];

  // Widget Bantu untuk Item Navigasi (DISESUAIKAN UNTUK POSISI MELENGKUNG)
  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, double verticalOffset) {
    final bool isSelected = _selectedIndex == index;
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

  @override
  Widget build(BuildContext context) {
    // --- Index 0: Lapak Saya ---
    final Widget lapakSaya = Scaffold(
      appBar: AppBar(
        title: const Text('Lapak Saya (Listing Aktif)'),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: myCommodityPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  const Text('Belum ada postingan aktif.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const Text('Mulai iklan di tombol tengah (+)'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: myCommodityPosts.length,
              itemBuilder: (context, index) {
                final post = myCommodityPosts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  elevation: 4, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(post.commodity, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('Kuantitas: ${post.quantityTons} Ton', style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('Harga: Rp ${post.priceKg} / Kg', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w600)),
                        Text('Lokasi: ${post.location}'),
                      ],
                    ),
                    trailing: const Icon(Icons.edit_note, color: Colors.blue),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mengedit postingan ${post.commodity}')));
                    },
                  ),
                );
              },
            ),
    );

    // --- Index 1: Iklankan (+) (Tampilan untuk memulai Listing/Verifikasi) ---
    final Widget buatIklan = const NewListingFormScreen();
    
    // --- Index 2: Harga Pasar ---
    final Widget hargaPasar = const Center(child: Text("Harga Pasar Komoditas")); 

    // --- Index 3: Permintaan Beli ---
    final Widget permintaanBeli = const RequestScreen();
    
    // --- Index 4: Profil ---
    final Widget profil = const ProfileScreen();


    // Daftar halaman yang dimuat di Body (sesuai urutan index)
    final List<Widget> pages = <Widget>[
      lapakSaya, // Index 0: Lapak Saya
      buatIklan, // Index 1: Iklankan (+) (FAB)
      hargaPasar, // Index 2: Harga Pasar
      permintaanBeli, // Index 3: Permintaan Beli
      profil, // Index 4: Profil
    ];
    
    // Widget bantu untuk FAB (Iklankan - Index 1)
    Widget _buildFarmerFAB(BuildContext context) {
        return FloatingActionButton(
          onPressed: () {
            _onItemTapped(1); // Navigasi ke Iklankan (+) (Index 1)
          },
          tooltip: 'Iklankan Komoditas',
          backgroundColor: Theme.of(context).colorScheme.secondary, 
          foregroundColor: Colors.white,
          elevation: 12, 
          shape: const CircleBorder(),
          child: const Icon(Icons.add_box_outlined, size: 30), 
        );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: Text(widget.title), backgroundColor: Theme.of(context).colorScheme.background, elevation: 0),
      body: pages[_selectedIndex],
      
      // 🎯 IMPLEMENTASI NAVIGASI BAWAH MELENGKUNG
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter, 
        children: [
          // 1. CustomPainter untuk Bentuk Melengkung (Background Navbar)
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 80), // Tinggi total navbar
            painter: CustomNavbarPainter(color: const Color(0xFF1B5E20)), // 🟢 Warna Hijau Gelap
            child: SizedBox(
              height: 70, // Tinggi efektif area ikon menu
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // Offsets Y disesuaikan agar ikon mengikuti kelengkungan
                  _buildNavItem(context, Icons.store, 'Lapak Saya', 0, 15), // Rendah (Tepi)
                  _buildNavItem(context, Icons.trending_up, 'Harga Pasar', 2, 0), // Agak Tinggi (Samping lengkungan)
                  
                  // Ruang kosong untuk Floating Action Button (FAB)
                  const SizedBox(width: 60), 

                  _buildNavItem(context, Icons.search, 'Permintaan', 3, 0), // Agak Tinggi
                  _buildNavItem(context, Icons.person, 'Profil', 4, 15), // Rendah (Tepi)
                ],
              ),
            ),
          ),
          
          // 2. Floating Action Button (FAB) diposisikan di atas puncak busur
          Positioned(
            top: 0,
            child: _buildFarmerFAB(context),
          ),
        ],
      ),
    );
  }
}

// 🎯 NewListingFormScreen (Hub untuk Listing dan Verifikasi - Ditempatkan di sini)
class NewListingFormScreen extends StatelessWidget {
  const NewListingFormScreen({super.key});

  void _startListingFlow(BuildContext context) {
    // Navigasi ke ListingFlowScreen (Asumsi file sudah dibuat)
  }
  
  void _startVerificationFlow(BuildContext context) {
    // Navigasi ke VerificationFlowScreen (Asumsi file sudah dibuat)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iklankan Komoditas'), backgroundColor: Theme.of(context).colorScheme.background),
      body: Center(child: Padding(padding: const EdgeInsets.all(30.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Icon(Icons.post_add, size: 80, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(height: 20),
        Text('Siap Iklankan Komoditas Anda?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground), textAlign: TextAlign.center),
        const SizedBox(height: 40),
        SizedBox(height: 55, child: FilledButton.icon(icon: const Icon(Icons.add_box_outlined, size: 28, color: Colors.white), label: const Text('Buat Listing Baru', style: TextStyle(fontSize: 18, color: Colors.white)), onPressed: () => _startListingFlow(context), style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary, elevation: 8))),
        const SizedBox(height: 30),
        const Text('--- Tingkatkan Kepercayaan ---', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        SizedBox(height: 55, child: OutlinedButton.icon(icon: Icon(Icons.verified_user, color: Theme.of(context).colorScheme.primary), label: Text('Cek/Ajukan Verifikasi', style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary)), onPressed: () => _startVerificationFlow(context))),
      ]))),
    );
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