import 'dart:math';
import 'dart:ui' as ui; 
import 'package:flutter/material.dart';
import '../models/community_data.dart';
import 'profile_screen.dart';
import 'request_screen.dart';
import 'notification_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'market_screen.dart'; 
import 'package:panen_lokal/models/user_model.dart';
import 'package:panen_lokal/services/auth_service.dart';
import 'listing_detail_screen.dart';
import 'package:panen_lokal/services/listing_service.dart';
import 'package:panen_lokal/services/transaction_service.dart';
import 'package:panen_lokal/models/transaction_model.dart';

class CommodityPost {
  final String id;
  final String commodity;
  final String location;
  final String area;
  final double price; 
  final double quantityTons;
  final String contactName;
  final String contactInfo;
  final String imagePath;
  final String description;
  final String pricingType;
  final String category;
  final List<String>? images;

  const CommodityPost({
    required this.id,
    required this.commodity,
    required this.location,
    required this.area,
    required this.price,
    required this.quantityTons,
    required this.contactName,
    required this.contactInfo,
    required this.imagePath,
    required this.category,
    this.description = "Deskripsi belum ditambahkan oleh petani.",
    this.pricingType = 'kg',
    this.images,
  });

  // Factory method untuk convert dari API response
  factory CommodityPost.fromJson(Map<String, dynamic> json) {
    return CommodityPost(
      id: json['id'].toString(),
      commodity: json['title'] ?? '',
      location: json['location'] ?? '',
      area: json['area'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantityTons: double.tryParse(json['stock'].toString()) ?? 0.0,
      contactName: json['contact_name'] ?? '',
      contactInfo: json['contact_number'] ?? '',
      category: json['category'] ?? 'sayur',
      description: json['description'] ?? 'Deskripsi belum ditambahkan oleh petani.',
      pricingType: json['type'] == 'Borong' ? 'total' : 'kg',
      imagePath: json['images'] != null && (json['images'] as List).isNotEmpty 
          ? json['images'][0] 
          : 'assets/images/placeholder.jpg',
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }
}

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key, required this.title});
  final String title;

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> with TickerProviderStateMixin { 
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteIds = {}; 
  final ListingService _listingService = ListingService();
  bool _showDealConfirmation = false;
  CommodityPost? _contactedPost;


  String _userName = "User";
  bool _isLoading = true;
  List<CommodityPost> commodityPosts = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadAllListings();
  }

  final TransactionService _transactionService = TransactionService();

 // ✅ DIPERBAIKI: Create Transaction dengan error handling
  Future<void> _createTransaction(CommodityPost post) async {
    try {
      final result = await _transactionService.createTransaction(post.id);
      
      if (result['success'] == true) {
        if (mounted) {
          setState(() {
            _showDealConfirmation = true;
            _contactedPost = post;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? "Gagal memulai transaksi")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


 Future<void> _openWhatsApp(String phoneNumber, String commodity) async {
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedNumber.startsWith('0')) {
      cleanedNumber = '62${cleanedNumber.substring(1)}';
    }

    final message = Uri.encodeComponent(
      "Halo, saya tertarik dengan $commodity di PanenLokal."
    );

    final whatsappUrl = Uri.parse("https://wa.me/$cleanedNumber?text=$message");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }


  void _loadCurrentUser() async {
    UserModel? user = await AuthService.getLocalUser();
    
    if (user != null) {
      if (mounted) {
        setState(() {
          _userName = user.fullName.split(" ")[0]; 
        });
      }
    }
  }

  // ✅ DIPERBAIKI: Konfirmasi kontak dengan loading indicator
  void _confirmContact(BuildContext context, CommodityPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hubungi Penjual"),
        content: const Text(
          "Anda akan menghubungi penjual melalui WhatsApp.\n"
          "Transaksi akan dicatat sebagai sedang negosiasi."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // ✅ Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                await _createTransaction(post); // ✅ INSERT DB
                
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  await _openWhatsApp(post.contactInfo, post.commodity); // ✅ WA
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
            ),
            child: const Text("Hubungi"),
          ),
        ],
      ),
    );
  }

  // Load semua listing aktif dari database
  Future<void> _loadAllListings() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _listingService.getAllActiveListings();
      
      if (result['success']) {
        final dynamic responseData = result['data'];
        final List<dynamic> data = responseData is Map && responseData.containsKey('data') 
            ? responseData['data'] 
            : responseData;
        
        setState(() {
          commodityPosts = data.map((item) => CommodityPost.fromJson(item)).toList();
          _isLoading = false;
        });
        
        print("Loaded ${commodityPosts.length} active listings");
        
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal memuat data'))
          );
        }
      }
    } catch (e) {
      print("Error loading listings: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
        );
      }
    }
  }

  bool _waitingForReview = false;
  CommodityPost? _pendingReviewPost;

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
  }

  Widget _buildTrendCard(String title, String trendType, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
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
        // ✅ KONFIRMASI SETELAH HUBUNGI

      ),
    );
  }

    Widget _buildDealConfirmationCard() {
    if (!_showDealConfirmation || _contactedPost == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.question_answer, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Apakah transaksi sudah selesai?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showDealConfirmation = false;
                        _contactedPost = null;
                      });
                    },
                    child: const Text("Belum"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showDealConfirmation = false;
                        _waitingForReview = true;
                        _pendingReviewPost = _contactedPost;
                        _contactedPost = null;
                      });
                    },
                    child: const Text("Sudah"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


  Widget _buildHorizontalCommodityCard(BuildContext context, CommodityPost post) {
    bool isFav = _favoriteIds.contains(post.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListingDetailScreen( 
            post: post, 
             isFavorite: isFav,
             onToggleFavorite: () => _toggleFavorite(post.id),
             onContacted: () {
                 setState(() {
                    _showDealConfirmation = true;
                    _contactedPost = post;
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
                Container(
                  width: 120, height: 160,
                  decoration: BoxDecoration(
                     borderRadius: const BorderRadius.horizontal(left: Radius.circular(19)),
                     border: Border(right: BorderSide(color: Colors.grey.shade200)),  
                  ),
                  
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(19)),
                    child: post.images != null && post.images!.isNotEmpty
                        ? Image.network(
                            post.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              color: Colors.grey.shade200, 
                              child: const Icon(Icons.image, color: Colors.grey, size: 40)
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, color: Colors.grey, size: 40),
                          ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0B2), 
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.deepOrange, width: 2),
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
                              onPressed: () {
                                _confirmContact(context, post);
                              },

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
            
            Positioned(
              top: 8, right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleFavorite(post.id),
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
              subtitle: Text(post.contactInfo),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Membuka WhatsApp..."), backgroundColor: Colors.green));
                
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

  void _showReviewDialog(CommodityPost post) {
    showDialog(
      context: context,
      builder: (ctx) {
        String? dealStatus;
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

    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: RefreshIndicator(
          onRefresh: _loadAllListings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                        Row(
                          children: [
                            Image.asset('assets/images/panenlokal_logo.png', height: 40, errorBuilder: (c,o,s)=>const Icon(Icons.storefront, size: 30, color: Colors.green)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('PanenLokal.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5)),
                                  Text('Halo, $_userName!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary, letterSpacing: 0.5)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8), 
                        Text('Dapatkan hasil panen segar langsung dari ladang.\nHarga terbaik, kualitas terjamin!', style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5)),
                        const SizedBox(height: 24),
                        
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green.shade700, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
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
                              filled: true, fillColor: Colors.transparent,
                              border: InputBorder.none,
                              errorBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text("Tren Harga Pasar Saat Ini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        ),

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

                  // Kartu ulasan pending (jika ada negosiasi selesai)
                  // ✅ KONFIRMASI SETELAH HUBUNGI
                  _buildDealConfirmationCard(),

                  // ✅ ULASAN (SETELAH KLIK "SUDAH")
                  _buildPendingReviewCard(),

                  
                  // Header List Rekomendasi
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
                  
                  // List Item (Dengan handling Loading State dari kode pertama)
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : filteredPosts.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Center(child: Text("Belum ada data komoditas.")),
                            )
                          : ListView.builder(
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
  }
  
}
