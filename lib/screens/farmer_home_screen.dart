import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'request_screen.dart';
import 'market_screen.dart';
import 'listing_form_screen.dart';
import 'listing_detail_screen.dart';
import 'package:panen_lokal/services/listing_service.dart';
import '../widgets/notification_button.dart';
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
  final String type;
  final String category;
  bool isSold;
  double? soldPrice;
  final double? rating;
  final String? reviewText;
  final List<String>? images;
  final String? transactionId;

  CommodityPost({
    required this.id,
    required this.commodity,
    required this.location,
    required this.area,
    required this.price,
    required this.quantityTons,
    required this.contactName,
    required this.contactInfo,
    required this.category,
    this.type = 'Timbang',
    this.isSold = false,
    this.soldPrice,
    this.rating,
    this.reviewText,
    this.images,
    this.transactionId,
  });

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
      category: json['category'] ?? '',
      type: json['type'] ?? 'Timbang',
      isSold: json['is_sold'] == true || json['is_sold'] == 1 || json['is_sold'] == '1',
      soldPrice: json['sold_price'] != null ? double.tryParse(json['sold_price'].toString()) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      transactionId: json['transaction_id']?.toString(),
    );
  }
}

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key, required this.title});
  final String title;

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  bool _showHistory = false;
  bool _isLoading = true;
  List<CommodityPost> myCommodityPosts = [];
  final ListingService _listingService = ListingService();
  List<TransactionModel> farmerTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadMyListings();
  }

  Future<void> _loadFarmerTransactions() async {
    try {
      final data = await TransactionService().getFarmerTransactions();
      setState(() {
        farmerTransactions = data;
        _isLoading = false;
      });
    } catch (e) {
      _isLoading = false;
      debugPrint("Error: $e");
    }
  }

  Future<void> _loadMyListings() async {
    setState(() => _isLoading = true);

    try {
      final result = await _listingService.getMyListings();

      if (result['success']) {
        final dynamic responseData = result['data'];
        final List<dynamic> data =
            responseData is Map && responseData.containsKey('data')
            ? responseData['data']
            : responseData;

        setState(() {
          myCommodityPosts = data
              .map((item) => CommodityPost.fromJson(item))
              .toList();
          _isLoading = false;
        });

        print("Loaded ${myCommodityPosts.length} listings");
        print("Active: ${myCommodityPosts.where((p) => !p.isSold).length}");
        print("Sold: ${myCommodityPosts.where((p) => p.isSold).length}");
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal memuat data')),
          );
        }
      }
    } catch (e) {
      print("Error loading listings: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _openListingForm() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ListingFormScreen()),
    );

    if (result == true) {
      print("Listing created successfully, reloading data...");
      _loadMyListings();
    }
  }

  void _onItemTapped(int index) {}

  void _addNewPost(CommodityPost post) {
    setState(() {
      myCommodityPosts.insert(0, post);
    });
  }

  String _formatNumber(num number) {
    if (number == 0) return "0";
    String s = number.toString();
    return s.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _markAsSold(CommodityPost post) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tandai Laku?"),
        content: Text(
          "Iklan \"${post.commodity}\" akan dipindahkan ke riwayat.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDealPriceDialog(post);
            },
            child: const Text("Ya, Sudah Laku"),
          ),
        ],
      ),
    );
  }

  Future<void> _showDealPriceDialog(CommodityPost post) async {
    final dealPriceController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Feedback Harga Deal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Berapa harga kesepakatan akhirnya?"),
            const SizedBox(height: 12),
            TextField(
              controller: dealPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: "Rp ",
                border: OutlineInputBorder(),
                hintText: "Contoh: 34000",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (dealPriceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Harga tidak boleh kosong"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(ctx);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              final soldPrice = double.tryParse(
                dealPriceController.text.replaceAll('.', ''),
              ) ?? 0;

              try {
                print("🔄 Marking listing ${post.id} as sold with price: $soldPrice");
                
                final result = await _listingService.markAsSold(
                  listingId: post.id,
                  soldPrice: soldPrice,
                );

                print("✅ Result: ${result['success']}");

                if (mounted) Navigator.pop(context);

                if (result['success']) {
                  print("✅ Listing marked as sold successfully");
                  
                  await _loadMyListings();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Selamat! Iklan ditandai laku & transaksi diselesaikan."),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ?? 'Gagal menandai laku',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                print("❌ Error: $e");
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOfferPrice(CommodityPost post) async {
    final newPriceController = TextEditingController(
      text: post.price.toString(),
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Perbarui Harga Penawaran"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ubah harga total borongan:"),
            const SizedBox(height: 12),
            TextField(
              controller: newPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: "Rp ",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx2) => AlertDialog(
                  title: const Text("Konfirmasi"),
                  content: const Text("Simpan perubahan harga ini?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx2),
                      child: const Text("Tidak"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx2);
                        Navigator.pop(ctx);

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        final newPrice =
                            double.tryParse(newPriceController.text) ??
                            post.price;
                        final result = await _listingService.updateListing(
                          listingId: post.id,
                          price: newPrice,
                        );

                        if (mounted) Navigator.pop(context);

                        if (result['success']) {
                          await _loadMyListings();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Harga berhasil diperbarui!"),
                              ),
                            );
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result['message'] ?? 'Gagal update harga',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Ya, Simpan"),
                    ),
                  ],
                ),
              );
            },
            child: const Text("Perbarui"),
          ),
        ],
      ),
    );
  }

  Future<void> _editListing(CommodityPost post) async {
    final areaController = TextEditingController(text: post.area);
    final locController = TextEditingController(text: post.location);
    final contactController = TextEditingController(text: post.contactInfo);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit Informasi Iklan"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Harga tidak dapat diubah di sini.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locController,
                decoration: const InputDecoration(
                  labelText: "Lokasi",
                  prefixIcon: Icon(Icons.pin_drop),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: areaController,
                decoration: const InputDecoration(
                  labelText: "Luas Lahan",
                  prefixIcon: Icon(Icons.square_foot),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(
                  labelText: "Kontak",
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) =>
                    const Center(child: CircularProgressIndicator()),
              );

              final result = await _listingService.updateListing(
                listingId: post.id,
                location: locController.text,
                area: areaController.text,
                contactNumber: contactController.text,
              );

              if (mounted) Navigator.pop(context);

              if (result['success']) {
                await _loadMyListings();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Info Iklan diperbarui.")),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Gagal update'),
                    ),
                  );
                }
              }
            },
            child: const Text("Simpan Perubahan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePosts = myCommodityPosts.where((p) => !p.isSold).toList();
    final soldPosts = myCommodityPosts.where((p) => p.isSold).toList();
    final displayPosts = _showHistory ? soldPosts : activePosts;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMyListings,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 25, left: 20, right: 20),
                    child: Column(
                      children: [
                        const Text(
                          "Manajemen Listing",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () =>
                                    setState(() => _showHistory = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: !_showHistory
                                        ? Colors.green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Aktif",
                                    style: TextStyle(
                                      color: !_showHistory
                                          ? Colors.white
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    setState(() => _showHistory = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _showHistory
                                        ? Colors.green
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Riwayat",
                                    style: TextStyle(
                                      color: _showHistory
                                          ? Colors.white
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (displayPosts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showHistory
                                ? "Belum ada riwayat penjualan."
                                : 'Belum ada iklan aktif.',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: displayPosts.length,
                    itemBuilder: (context, index) {
                      final post = displayPosts[index];
                      final imageUrl =
                          (post.images != null && post.images!.isNotEmpty)
                          ? post.images!.first
                          : "https://via.placeholder.com/150";
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.20),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.white,
                              elevation: 0,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                  width: 2.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      12,
                                      12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: post.type == "Borong"
                                          ? Colors.green.shade50
                                          : Colors.orange.shade50,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(19),
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: post.type == "Borong"
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.orange.withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: post.type == "Borong"
                                                ? const Color(0xFF1B5E20)
                                                : Colors.deepOrange,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    (post.type == "Borong"
                                                            ? Colors.green
                                                            : Colors.orange)
                                                        .withOpacity(0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            post.type.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),

                                        if (_showHistory)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade700,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              "TERJUAL",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              if (post.type == "Borong") ...[
                                                InkWell(
                                                  onTap: () =>
                                                      _updateOfferPrice(post),
                                                  child: Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.green
                                                              .withOpacity(0.2),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                      Icons.price_check,
                                                      size: 18,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],

                                              InkWell(
                                                onTap: () => _editListing(post),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.blue
                                                            .withOpacity(0.2),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    print(
                                                      "❌ Error loading image: $imageUrl",
                                                    );
                                                    print(
                                                      "Error detail: $error",
                                                    );
                                                    return Container(
                                                      color:
                                                          Colors.grey.shade300,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .broken_image_outlined,
                                                            size: 32,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            "No Image",
                                                            style: TextStyle(
                                                              fontSize: 9,
                                                              color: Colors
                                                                  .grey
                                                                  .shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null)
                                                  return child;
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    value:
                                                        loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post.commodity,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 18,
                                                  color: Color(0xFF212121),
                                                ),
                                              ),
                                              const SizedBox(height: 6),

                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.scale,
                                                    size: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "${post.quantityTons} Ton",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(
                                                    Icons.aspect_ratio,
                                                    size: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    post.area,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(height: 12),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF1F8E9,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  _showHistory
                                                      ? "Deal: Rp ${_formatNumber(post.soldPrice ?? 0)}"
                                                      : "Rp ${_formatNumber(post.price)} ${post.type == 'Borong' ? '(Total)' : '/ Kg'}",
                                                  style: TextStyle(
                                                    color: _showHistory
                                                        ? Colors.grey.shade700
                                                        : const Color(
                                                            0xFF1B5E20,
                                                          ),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (!_showHistory)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text("Konfirmasi"),
                                                    content: const Text("Tandai semua transaksi listing ini gagal/tidak jadi?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(ctx, false),
                                                        child: const Text("Batal"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () => Navigator.pop(ctx, true),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Colors.red,
                                                        ),
                                                        child: const Text("Ya, Tidak Jadi"),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirm == true) {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (ctx) => const Center(
                                                      child: CircularProgressIndicator(),
                                                    ),
                                                  );

                                                  try {
                                                    print("🔄 Updating transactions for listing ${post.id} to failed");
                                                    
                                                    await TransactionService().updateTransactionsByListing(
                                                      listingId: post.id,
                                                      status: 'failed',
                                                    );

                                                    if (mounted) Navigator.pop(context);
                                                    await _loadMyListings();

                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(
                                                          content: Text("Semua transaksi ditandai gagal"),
                                                          backgroundColor: Colors.orange,
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    print("❌ Error: $e");
                                                    if (mounted) Navigator.pop(context);
                                                    if (mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text("Error: $e"),
                                                          backgroundColor: Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(color: Colors.red),
                                              ),
                                              child: const Text("Tidak Jadi"),
                                            ),
                                          ),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed: () => _markAsSold(post),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text("Tandai Laku"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          if (_showHistory && post.rating != null)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${post.rating}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openListingForm,
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Buat Listing",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ✅ QUICK ACCESS CARD WIDGET
  Widget _buildQuickAccessCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}