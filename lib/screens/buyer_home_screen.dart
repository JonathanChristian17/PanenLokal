import 'dart:math';
import 'dart:ui' as ui; 
import 'package:flutter/material.dart';
import '../models/community_data.dart';
import 'profile_screen.dart';
import 'request_screen.dart';
import 'notification_screen.dart';
import 'market_screen.dart'; 


// Definisi model CommodityPost (Updated with all requested fields)
class CommodityPost {
  final String commodity;
  final String location;
  final String area;
  final int price; 
  final double quantityTons;
  final String contactName;
  final String contactInfo;
  final String imagePath;
  final String description;
  final String pricingType; // 'kg' or 'total'

  const CommodityPost({
    required this.commodity,
    required this.location,
    required this.area,
    required this.price,
    required this.quantityTons,
    required this.contactName,
    required this.contactInfo,
    required this.imagePath,
    this.description = "Deskripsi belum ditambahkan oleh petani.",
    this.pricingType = 'kg', // Default
  });
}

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key, required this.title});
  final String title;

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> with TickerProviderStateMixin { 
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteIds = {}; 

  // State for Review Flow
  bool _waitingForReview = false;
  CommodityPost? _pendingReviewPost;

  // Format Currency
  String _formatCurrency(num value) {
    return value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  void _toggleFavorite(String id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Dihapus dari Favorit"), duration: Duration(seconds: 1)));
      } else {
        _favoriteIds.add(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ditandai sebagai Favorit ❤️"), 
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.pink,
            duration: Duration(seconds: 1)
          )
        );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Data Dummy
  final List<CommodityPost> commodityPosts = const [
    CommodityPost(
      commodity: 'Cabai Merah',
      location: 'Berastagi',
      area: '1 Hektar',
      price: 52000,
      quantityTons: 2.5,
      contactName: 'Pak Ginting',
      contactInfo: 'WA: 0812xxxxxx',
      imagePath: 'assets/images/cabai.jpg', 
      pricingType: 'kg',
      description: "Cabai merah kualitas super, pedas dan segar. Panen raya minggu ini. Cocok untuk suplai pasar induk atau pabrik saos.",
    ),
    CommodityPost(
      commodity: 'Tomat Merah',
      location: 'Garut',
      area: '1.5 Hektar',
      price: 7500,
      quantityTons: 8.0,
      contactName: 'Agro Makmur',
      contactInfo: 'Telp: 0821xxxxxx',
      imagePath: 'assets/images/tomat.jpg',
      pricingType: 'kg',
      description: "Tomat sayur merah merona. Daging tebal, kadar air pas. Tahan simpan 1 minggu.",
    ),
     CommodityPost(
      commodity: 'Kentang Dieng',
      location: 'Dieng',
      area: '2 Hektar',
      price: 12000,
      quantityTons: 15.0,
      contactName: 'Bu Ani',
      contactInfo: 'WA: 0813xxxxxx',
      imagePath: 'assets/images/kentang.jpg',
      pricingType: 'kg',
      description: "Kentang kuning ukuran besar (Super). Bebas penyakit, kulit mulus. Hubungi untuk negosiasi partai besar.",
    ),
    CommodityPost(
      commodity: 'Jagung Manis',
      location: 'Lamongan',
      area: '3 Hektar',
      price: 45000000, 
      quantityTons: 20.0, 
      contactName: 'Pak Budi',
      contactInfo: 'WA: 0815xxxxxx',
      imagePath: 'assets/images/jagung_borongan.jpg', 
      pricingType: 'total',
      description: "Jual borongan satu ladang jagung hibrida. Kondisi tongkol besar, siap panen dalam 3 hari. Harga borongan bersih di tempat.",
    ),
    CommodityPost(
      commodity: 'Jeruk Medan',
      location: 'Kabanjahe',
      area: '5000 m²',
      price: 25000000, 
      quantityTons: 4.0,
      contactName: 'Simalem Farm',
      contactInfo: 'WA: 0813xxxxxx',
      imagePath: 'assets/images/jeruk_lahan.jpg', 
      pricingType: 'total',
      description: "Oper kebun jeruk siap petik. Estimasi 4 Ton. Kualitas manis air banyak. Harga nego ditempat sampai jadi.",
    ),
  ];

  // --- CARD 1: TREN HARGA ---
  Widget _buildTrendCard(String title, String trendType, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          // High Contrast Stroke & Shadow for Trend Cards
          border: Border.all(color: color.withOpacity(0.8), width: 1.5),
          boxShadow: [
             BoxShadow(color: color.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))
          ]
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(trendType, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  // --- CARD 2: HORIZONTAL LISTING CARD (Enhanced Stroke & Shadow) ---
  Widget _buildHorizontalCommodityCard(BuildContext context, CommodityPost post) {
    bool isFav = _favoriteIds.contains(post.commodity);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListingDetailScreen(
            post: post, 
             isFavorite: isFav,
             onToggleFavorite: () => _toggleFavorite(post.commodity),
             onContacted: () {
                 setState(() {
                   _waitingForReview = true;
                   _pendingReviewPost = post;
                 });
             },
          )),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 160, 
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          // High Contrast Stroke & Shadow (Requested)
          border: Border.all(color: Colors.black.withOpacity(0.4), width: 1.5), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25), 
              blurRadius: 10, 
              offset: const Offset(0, 6), 
              spreadRadius: 0
            )
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // 1. IMAGE
                Container(
                  width: 120, height: 160, // Match new height
                  decoration: BoxDecoration(
                     borderRadius: const BorderRadius.horizontal(left: Radius.circular(19)), // Match outer radius minus border
                     border: Border(right: BorderSide(color: Colors.grey.shade200)),  
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(19)),
                    child: Image.asset(
                      post.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                ),
                // 2. DETAILS
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         // Top Section: Name, Location, Ton
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.commodity, 
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87)
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Expanded(child: Text(post.location, style: TextStyle(fontSize: 12, color: Colors.grey.shade600), maxLines: 1)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // ESTIMASI TON (Enhanced Visibility)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0B2), 
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.deepOrange, width: 2), // Thicker Border
                                boxShadow: [
                                  BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))
                                ]
                              ),
                              child: Text(
                                "ESTIMASI: ${post.quantityTons} TON", 
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.deepOrange, letterSpacing: 0.5)
                              ),
                            )
                          ],
                        ),

                        // Bottom Section: Price & Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: post.pricingType == 'total' ? Colors.blue[700] : Colors.orange[700],
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))]
                                    ),
                                    child: Text(
                                      post.pricingType == 'total' ? "BORONGAN" : "PER KG",
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                                    ),
                                  ),
                                  Text(
                                    "Rp ${_formatCurrency(post.price)}",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _contactFarmer(context, post),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32), 
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                elevation: 0,
                              ),
                              child: const Text("HUBUNGI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Heart Icon
            Positioned(
              top: 8, right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleFavorite(post.commodity),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border, 
                      color: isFav ? Colors.red : Colors.grey.shade400, 
                      size: 22
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- LOGIC: CONTACT ---
  void _contactFarmer(BuildContext context, CommodityPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
             const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.person, color: Colors.white)),
             const SizedBox(width: 12),
             Expanded(child: Text("Hubungi ${post.contactName}", style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih metode komunikasi:", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ListTile(
              leading: Image.asset('assets/images/whatsapp_logo.png', width: 24, errorBuilder: (c,o,s)=>const Icon(Icons.message, color: Colors.green)), 
              title: const Text("WhatsApp"),
              subtitle: const Text("Chat langsung untuk nego"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Membuka WhatsApp..."), backgroundColor: Colors.green));
                
                // Trigger Review Flow
                setState(() {
                  _waitingForReview = true;
                  _pendingReviewPost = post;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- REVIEW FLOW ---
  void _showReviewDialog(CommodityPost post) {
    showDialog(
      context: context,
      builder: (ctx) {
        String? dealStatus; // "success", "cancelled", "pending"
        double rating = 5.0;
        TextEditingController reviewController = TextEditingController();
        
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.all(20),
              title: const Text("Bagaimana hasil negosiasi?", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dealStatus == null) ...[
                      const Text("Bantu pengguna lain dengan ulasanmu!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 20),
                      _buildReviewOption("Deal Berhasil", Icons.check_circle, Colors.green, () {
                        setStateDialog(() => dealStatus = "success");
                      }),
                      _buildReviewOption("Tidak Jadi", Icons.cancel, Colors.red, () {
                        setStateDialog(() => dealStatus = "cancelled");
                      }),
                      _buildReviewOption("Masih Menunggu", Icons.access_time_filled, Colors.orange, () {
                        setStateDialog(() => dealStatus = "pending");
                      }),
                    ] else if (dealStatus == "success") ...[
                      const Icon(Icons.check_circle, size: 60, color: Colors.green),
                      const SizedBox(height: 10),
                      const Text("Selamat! Transaksi Berhasil", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 20),
                      const Text("Beri Bintang untuk Penjual:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 32,
                            ),
                            onPressed: () {
                              setStateDialog(() => rating = index + 1.0);
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: reviewController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Tulis ulasan pengalamanmu...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleSubmitReview(post, rating, reviewController.text);
                          },
                          child: const Text("Kirim Ulasan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ] else ...[
                       // Cancelled or Pending
                       Icon(dealStatus == "cancelled" ? Icons.cancel : Icons.access_time_filled, 
                            size: 60, 
                            color: dealStatus == "cancelled" ? Colors.red : Colors.orange),
                       const SizedBox(height: 16),
                       Text(
                         dealStatus == "cancelled" ? "Transaksi Dibatalkan" : "Menunggu Konfirmasi",
                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 8),
                        Text(
                         dealStatus == "cancelled" ? "Terima kasih atas informasinya." : "Semoga segera ada kabar baik!",
                         textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            // Clear state
                            setState(() {
                              _waitingForReview = false;
                              _pendingReviewPost = null;
                            });
                          },
                          child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          }
        );
      }
    );
  }

  Widget _buildReviewOption(String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.8), fontSize: 16)),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmitReview(CommodityPost post, double rating, String review) {
    setState(() {
      _waitingForReview = false;
      _pendingReviewPost = null;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, size: 60, color: Colors.green),
        title: const Text("Ulasan Terkirim!"),
        content: const Text("Terima kasih telah membantu komunitas PanenLokal."),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))]
      ),
    );
  }

  // --- REVIEW CARD WIDGET ---
  Widget _buildPendingReviewCard() {
    if (!_waitingForReview || _pendingReviewPost == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade300),
          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.rate_review, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Gimana negosiasinya?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown)),
                      Text("Berikan ulasan untuk membantu yang lain!", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () => _showReviewDialog(_pendingReviewPost!),
                child: const Text("Beri Ulasan Sekarang"),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = commodityPosts.where((post) {
      final searchLower = _searchController.text.toLowerCase();
      if (searchLower.isNotEmpty && 
          !(post.commodity.toLowerCase().contains(searchLower) ||
            post.location.toLowerCase().contains(searchLower))) {
        return false;
      }
      return true;
    }).toList();

    // 1. BERANDA CONTENT
    final Widget berandaContent = SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.background, // Match Market Screen Background
        child: RefreshIndicator(
          onRefresh: () async { setState(() {}); await Future.delayed(const Duration(seconds: 1)); },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   // HEADER (White Block)
                   Container(
                     padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                     decoration: const BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                       boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         // Branding
                         Row(
                           children: [
                             Image.asset('assets/images/panenlokal_logo.png', height: 40, errorBuilder: (c,o,s)=>const Icon(Icons.storefront, size: 30, color: Colors.green)),
                             const SizedBox(width: 12),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Text('PanenLokal.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),
                                   Text('Halo, User!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary, letterSpacing: 0.5)),
                                 ],
                               ),
                             )
                           ],
                         ),
                         const SizedBox(height: 8), 
                         Text('Dapatkan hasil panen segar langsung dari ladang.\nHarga terbaik, kualitas terjamin!', style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5)),
                         const SizedBox(height: 24),
                         
                         // Search (Enhanced Shadow & Stroke)
                         Container(
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(15),
                             border: Border.all(color: Colors.green.shade700, width: 1.5), // Prominent Stroke
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.2), // Prominent Shadow
                                 blurRadius: 10,
                                 offset: const Offset(0, 5),
                               )
                             ]
                           ),
                           child: TextField(
                             controller: _searchController,
                             decoration: InputDecoration(
                               hintText: 'Cari hasil panen...',
                               prefixIcon: const Icon(Icons.search, color: Colors.green),
                               filled: true, fillColor: Colors.transparent, // Transparent to show container color
                               border: InputBorder.none,
                               errorBorder: InputBorder.none,
                               enabledBorder: InputBorder.none,
                               focusedBorder: InputBorder.none,
                               contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                             ),
                             onChanged: (_) => setState(() {}),
                           ),
                         ),
                         
                         const SizedBox(height: 16), // Reduced spacing
                         
                         // TREN HARGA TITLE
                         const Padding(
                           padding: EdgeInsets.only(bottom: 12),
                           child: Text("Tren Harga Pasar Saat Ini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                         ),

                         // TREN HARGA
                         Row(
                           children: [
                              _buildTrendCard("Cabai Merah", "NAIK HARGA", Colors.red, Icons.trending_up),
                              _buildTrendCard("Bawang Merah", "STABIL", Colors.blue, Icons.remove),
                              _buildTrendCard("Tomat", "TURUN HARGA", Colors.green, Icons.trending_down),
                           ],
                         )
                       ],
                     ),
                   ),

                   // PENDING REVIEW CARD
                   _buildPendingReviewCard(),
                   
                   Padding(
                     padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Text('Rekomendasi Terbaik', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                         Text('Lihat Semua', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                       ],
                     ),
                   ),
                   
                   ListView.builder(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     itemCount: filteredPosts.length,
                     itemBuilder: (context, index) {
                       return _buildHorizontalCommodityCard(context, filteredPosts[index]);
                     },
                   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // 2. PASAR
    final Widget pasarContent = const MarketScreen();

    // 3. FAVORIT
    final favoriteList = commodityPosts.where((p) => _favoriteIds.contains(p.commodity)).toList();
    final Widget favoritContent = Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(title: const Text("Favorit Saya"), backgroundColor: Theme.of(context).colorScheme.background, elevation: 0, foregroundColor: Colors.black),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              // A. BANNER "CREATIVE"
              Container(
                 margin: const EdgeInsets.all(20),
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(colors: [Colors.green.shade800, Colors.green.shade500], begin: Alignment.topLeft, end: Alignment.bottomRight),
                   borderRadius: BorderRadius.circular(20),
                   boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))]
                 ),
                 child: Row(
                   children: [
                     const Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text("Simpanan Impian!", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                           SizedBox(height: 4),
                           Text("Pantau harga komoditas favoritmu disini sebelum membeli.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                         ],
                       ),
                     ),
                     Container(
                       padding: const EdgeInsets.all(10),
                       decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                       child: const Icon(Icons.bookmark_added, color: Colors.white, size: 30),
                     )
                   ],
                 ),
              ),

              // B. FAVORITES LIST
              if (favoriteList.isEmpty)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.favorite_border, size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text("Belum ada favorit", style: TextStyle(color: Colors.grey.shade500)),
                      const SizedBox(height: 30),
                    ],
                  ),
                )
              else 
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: favoriteList.length,
                  itemBuilder: (context, index) => _buildHorizontalCommodityCard(context, favoriteList[index]),
                ),

              const SizedBox(height: 10),
              
              // C. RECOMMENDATIONS (Creative Fill)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Text("Mungkin Anda Suka", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                    const Spacer(),
                    const Icon(Icons.auto_awesome, color: Colors.orange, size: 18),
                  ],
                ),
              ),
              
              // Randomly showing top 2 items as suggestions (excluding favorites logic for simplicity of generic suggestions)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 2, // Just show 2 suggestions
                itemBuilder: (context, index) {
                   // Just taking the first 2 items from the main list as recommendations
                   if (index < commodityPosts.length) {
                     return _buildHorizontalCommodityCard(context, commodityPosts[index]);
                   }
                   return const SizedBox();
                },
              ),
            ],
          ),
        ),
      )
    );

    // 4. PROFIL
    final Widget profilContent = ProfileScreen();

    final List<Widget> pages = [berandaContent, pasarContent, favoritContent, profilContent];

    // NAVBAR
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<double> itemXPercents = [0.125, 0.375, 0.625, 0.875];
    final Color navBgColor = const Color(0xFF1B5E20); 
    final Color selectedColor = Colors.white;
    final Color unselectedColor = Colors.white60;

    double getIconCurveY(double xPercent) { return 80 * (xPercent - 0.5) * (xPercent - 0.5) + 10; }
    double getInnerCurveY(double xPercent) { return 60 * (xPercent * xPercent - xPercent) + 90; }
    double getDashAngle(double xPercent) { return (60.0 / screenWidth) * (2 * xPercent - 1); }

    final double selectedXPercent = itemXPercents[_selectedIndex];
    final double selectedIconY = getIconCurveY(selectedXPercent);
    final double selectedDashY = getInnerCurveY(selectedXPercent);
    final double selectedAngle = getDashAngle(selectedXPercent);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: pages[_selectedIndex]),
          Positioned(
            left: 0, right: 0, bottom: 0, height: 110,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CustomPaint(size: Size(screenWidth, 110), painter: DualCurvePainter(color: navBgColor)),
                Positioned(bottom: 8, child: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: Text(_getLabelForIndex(_selectedIndex), key: ValueKey<int>(_selectedIndex), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)))),
                AnimatedPositioned(duration: const Duration(milliseconds: 300), curve: Curves.easeOutQuad, left: (screenWidth * selectedXPercent) - 30, top: selectedIconY - 5, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20, spreadRadius: 1)]))),
                AnimatedPositioned(duration: const Duration(milliseconds: 300), curve: Curves.easeOutQuad, left: (screenWidth * selectedXPercent) - 15, top: selectedDashY - 2, child: AnimatedContainer(duration: const Duration(milliseconds: 300), curve: Curves.easeOutQuad, transform: Matrix4.rotationZ(selectedAngle), alignment: Alignment.center, child: CustomPaint(size: const Size(30, 4), painter: CurvedDashPainter()))),
                ...List.generate(4, (index) {
                   final double xPercent = itemXPercents[index];
                   final double yOffset = getIconCurveY(xPercent);
                   final bool isSelected = _selectedIndex == index;
                   IconData icon = Icons.home;
                   if (index == 1) icon = Icons.trending_up;
                   if (index == 2) icon = Icons.favorite;
                   if (index == 3) icon = Icons.person;
                   return Positioned(left: (screenWidth * xPercent) - 30, top: yOffset - 5, child: GestureDetector(onTap: () => _onItemTapped(index), behavior: HitTestBehavior.opaque, child: Container(width: 60, height: 60, alignment: Alignment.center, child: AnimatedScale(scale: isSelected ? 1.2 : 1.0, duration: const Duration(milliseconds: 200), child: Icon(icon, color: isSelected ? selectedColor : unselectedColor, size: 28)))));
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  String _getLabelForIndex(int index) {
    switch (index) {
      case 0: return "BERANDA";
      case 1: return "PASAR";
      case 2: return "FAVORIT"; 
      case 3: return "PROFIL";
      default: return "";
    }
  }
}

class DualCurvePainter extends CustomPainter {
  final Color color;
  DualCurvePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill..color = color;
    canvas.drawShadow(Path()..moveTo(0, size.height)..lineTo(0, 30)..quadraticBezierTo(size.width/2, -10, size.width, 30)..lineTo(size.width, size.height)..close(), Colors.black.withOpacity(0.5), 8, true);
    canvas.drawPath(Path()..moveTo(0, size.height)..lineTo(0, 30)..quadraticBezierTo(size.width/2, -10, size.width, 30)..lineTo(size.width, size.height)..close(), paint);
    final innerPaint = Paint()..color = Colors.white.withOpacity(0.05)..style = PaintingStyle.fill;
    final innerPath = Path()..moveTo(0, size.height)..lineTo(0, size.height - 20)..quadraticBezierTo(size.width/2, size.height - 50, size.width, size.height - 20)..lineTo(size.width, size.height)..close();
    canvas.drawPath(innerPath, innerPaint);
    canvas.drawPath(innerPath, Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 1);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    final path = Path(); path.moveTo(0, size.height); path.quadraticBezierTo(size.width / 2, 2.5, size.width, size.height);
    canvas.drawPath(path, Paint()..color = Colors.white.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 6..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 📄 LISTING DETAIL SCREEN (Fully Enhanced)
class ListingDetailScreen extends StatefulWidget {
  final CommodityPost post;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onContacted; // Callback to trigger review on Home

  const ListingDetailScreen({super.key, required this.post, this.isFavorite = false, this.onToggleFavorite, this.onContacted});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late bool _isFav;

  // State for Review Flow
  bool _waitingForReview = false;
  CommodityPost? _pendingReviewPost;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorite;
  }

  void _handleToggle() {
    setState(() {
      _isFav = !_isFav;
    });
    if (widget.onToggleFavorite != null) {
      widget.onToggleFavorite!();
    }
  }

  String _formatCurrency(num value) {
    return value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  void _contactFarmer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hubungi Petani"),
        content: Text("Buka WhatsApp ke ${widget.post.contactInfo}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () { 
               Navigator.pop(ctx);
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Membuka WhatsApp..."), backgroundColor: Colors.green));
               // Trigger Callback
               if (widget.onContacted != null) {
                 widget.onContacted!();
               }
            }, 
            child: const Text("Lanjut")
          ),
        ],
      )
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 15, color: Colors.black87), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.post.imagePath, fit: BoxFit.cover),
                  Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.6)]))),
                  Positioned(
                    bottom: 20, left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                      child: const Text("Petani Terverifikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  )
                ],
              ),
            ),
            leading: IconButton(icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back, color: Colors.black)), onPressed: () => Navigator.pop(context)),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Heart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(widget.post.commodity, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                        IconButton(onPressed: _handleToggle, icon: Icon(_isFav ? Icons.favorite : Icons.favorite_border, color: _isFav ? Colors.red : Colors.grey, size: 32)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Price Big
                    Text(
                      widget.post.pricingType == 'total' ? "Rp ${_formatCurrency(widget.post.price)} (Total)" : "Rp ${_formatCurrency(widget.post.price)} / Kg", 
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)
                    ),
                    const SizedBox(height: 24),
                    
                    // 🗺️ MAPS PLACEHOLDER
                    Container(
                      height: 150,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200, 
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300)
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map, size: 40, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(widget.post.location, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text("(Google Maps Preview)", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 📋 DETAIL INFO TABLE
                    const Text("Informasi Detail", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.grass, "Jenis Tanaman", widget.post.commodity, isBold: true),
                          const Divider(),
                          _buildInfoRow(Icons.square_foot, "Luas Lahan", widget.post.area),
                          const Divider(),
                          _buildInfoRow(Icons.scale, "Estimasi Hasil", "${widget.post.quantityTons} Ton"),
                          const Divider(),
                          _buildInfoRow(Icons.local_offer, "Metode Jual", widget.post.pricingType == 'total' ? "Borongan (Semua)" : "Timbangan (Per Kg)", isBold: true),
                          const Divider(),
                          _buildInfoRow(Icons.person, "Nama Pemilik", widget.post.contactName),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // DESKRIPSI
                    const Text("Deskripsi Lengkap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(widget.post.description, style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey.shade800)),
                    
                    const SizedBox(height: 40),
                    
                    // BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _contactFarmer(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700, 
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 5
                        ),
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text("Hubungi Penjual (WhatsApp)", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
