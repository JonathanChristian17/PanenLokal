import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'request_screen.dart';
// import 'farmer/verification_flow_screen.dart'; 
// import 'farmer/listing_flow_screen.dart'; 
import 'market_screen.dart'; 
import 'listing_form_screen.dart'; 

// --- MODEL COMMODITY POST (DIBIARKAN DI TOP-LEVEL) ---
class CommodityPost {
  final String id;
  final String commodity; 
  final String location; 
  final String area; 
  final int price; // Represents Price/Kg OR Total Borong Price depending on type
  final double quantityTons; 
  final String contactName; 
  final String contactInfo;
  final String type; // "Borong" or "Timbang"
  bool isSold;
  int? soldPrice;

  CommodityPost({
    required this.id,
    required this.commodity,
    required this.location,
    required this.area,
    required this.price,
    required this.quantityTons,
    required this.contactName,
    required this.contactInfo,
    this.type = "Timbang", // Default
    this.isSold = false,
    this.soldPrice,
    this.rating,      // New Field
    this.reviewText,  // New Field
  });
  
  // Rating Properties
  final double? rating;
  final String? reviewText;
}

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key, required this.title});
  final String title;

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _selectedIndex = 0; 
  bool _showHistory = false; // Toggle for Active vs History
  
  // Data dummy (Stateful List)
  final List<CommodityPost> myCommodityPosts = [
    CommodityPost(
      id: '1',
      commodity: 'Cabai Rawit Merah',
      location: 'Ciwidey, Bandung',
      area: '5 Hektar',
      price: 35000,
      contactName: 'Agus Sutanto',
      contactInfo: 'WA: 0812xxxx',
      quantityTons: 15.0,
      type: "Timbang",
    ),
    CommodityPost(
      id: '2',
      commodity: 'Wortel Brastagi',
      location: 'Kec. Brastagi',
      area: '2 Hektar',
      price: 75000000, // Borongan
      contactName: 'Agus Sutanto',
      contactInfo: 'WA: 0812xxxx',
      quantityTons: 10.0,
      type: "Borong",
      isSold: true, // Mock as sold for history view
      soldPrice: 70000000,
      rating: 5.0,
      reviewText: "Deal cepat, barang mantap.",
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Callback to add new post (Tidak digunakan lagi karena pakai API, tapi dibiarkan untuk menjaga dummy data)
  void _addNewPost(CommodityPost post) {
    setState(() {
      myCommodityPosts.insert(0, post); // Add to top
      _selectedIndex = 0; // Redirect to Home/Lapak
    });
  }

  // --- ACTIONS ---

  void _markAsSold(CommodityPost post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tandai Laku?"),
        content: Text("Iklan \"${post.commodity}\" akan dipindahkan ke riwayat."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDealPrice_Dialog(post);
            }, 
            child: const Text("Ya, Sudah Laku")
          ),
        ],
      ),
    );
  }

  void _showDealPrice_Dialog(CommodityPost post) {
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
                hintText: "Contoh: 34000"
              ),
            )
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (dealPriceController.text.isNotEmpty) {
                setState(() {
                  post.isSold = true;
                  post.soldPrice = int.tryParse(dealPriceController.text.replaceAll('.', '')) ?? 0;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selamat! Iklan ditandai laku.")));
              }
            }, 
            child: const Text("Simpan")
          ),
        ],
      ),
    );
  }

  void _updateOfferPrice(CommodityPost post) {
    final newPriceController = TextEditingController(text: post.price.toString());
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
            )
          ],
        ),
        actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
           ElevatedButton(
             onPressed: () {
                // Confirm Update
                showDialog(
                  context: context,
                  builder: (ctx2) => AlertDialog(
                    title: const Text("Konfirmasi"),
                    content: const Text("Simpan perubahan harga ini?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text("Tidak")),
                      ElevatedButton(
                        onPressed: () {
                          // Apply Change
                          setState(() {
                            final index = myCommodityPosts.indexOf(post);
                            if (index != -1) {
                                myCommodityPosts[index] = CommodityPost(
                                  id: post.id,
                                  commodity: post.commodity,
                                  location: post.location,
                                  area: post.area,
                                  price: int.tryParse(newPriceController.text) ?? post.price,
                                  quantityTons: post.quantityTons,
                                  contactName: post.contactName,
                                  contactInfo: post.contactInfo,
                                  type: post.type,
                                  isSold: post.isSold,
                                  soldPrice: post.soldPrice
                                );
                            }
                          });
                          Navigator.pop(ctx2); // Close Confirm
                          Navigator.pop(ctx); // Close Edit Dialog
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harga berhasil diperbarui!")));
                        },
                        child: const Text("Ya, Simpan"),
                      )
                    ],
                  ),
                );
             },
             child: const Text("Perbarui")
           )
        ],
      ),
    );
  }

  void _editListing(CommodityPost post) {
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
               const Text("Harga tidak dapat diubah di sini.", style: TextStyle(color: Colors.grey, fontSize: 12)),
               const SizedBox(height: 16),
               TextField(
                 controller: locController,
                 decoration: const InputDecoration(labelText: "Lokasi", prefixIcon: Icon(Icons.pin_drop)),
               ),
               const SizedBox(height: 12),
               TextField(
                 controller: areaController,
                 decoration: const InputDecoration(labelText: "Luas Lahan", prefixIcon: Icon(Icons.square_foot)),
               ),
               const SizedBox(height: 12),
                TextField(
                 controller: contactController,
                 decoration: const InputDecoration(labelText: "Kontak", prefixIcon: Icon(Icons.phone)),
               ),
             ],
           ),
         ),
         actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
           ElevatedButton(
             onPressed: () {
                setState(() {
                    final index = myCommodityPosts.indexOf(post);
                    if (index != -1) {
                        myCommodityPosts[index] = CommodityPost(
                          id: post.id,
                          commodity: post.commodity,
                          location: locController.text,
                          area: areaController.text,
                          price: post.price,
                          quantityTons: post.quantityTons,
                          contactName: post.contactName,
                          contactInfo: contactController.text,
                          type: post.type,
                          isSold: post.isSold,
                        );
                    }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Info Iklan diperbarui.")));
             },
             child: const Text("Simpan Perubahan")
           )
         ],
       ),
     );
  }


  @override
  Widget build(BuildContext context) {
    // Filter Data
    final activePosts = myCommodityPosts.where((p) => !p.isSold).toList();
    final soldPosts = myCommodityPosts.where((p) => p.isSold).toList();
    final displayPosts = _showHistory ? soldPosts : activePosts;

    // Unified Scroll Refactor for "Lapak Saya"
    final Widget lapakSaya = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120), // Space for Navbar
        child: Column(
          children: [
             // 1. HEADER (Unified Style)
             Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 25),
                child: Column(
                  children: [
                    const Text(
                      "Manajemen Listing",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF1B5E20)
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Toggle Switch (Moved inside Header)
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green)),
                      child: Row(
                         mainAxisSize: MainAxisSize.min, // Wrap content
                         children: [
                           InkWell(
                             onTap: () => setState(() => _showHistory = false),
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               decoration: BoxDecoration(
                                 color: !_showHistory ? Colors.green : Colors.transparent,
                                 borderRadius: BorderRadius.circular(20)
                               ),
                               child: Text("Aktif", style: TextStyle(color: !_showHistory ? Colors.white : Colors.green, fontWeight: FontWeight.bold)),
                             ),
                           ),
                           InkWell(
                             onTap: () => setState(() => _showHistory = true),
                             child: Container(
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               decoration: BoxDecoration(
                                 color: _showHistory ? Colors.green : Colors.transparent,
                                 borderRadius: BorderRadius.circular(20)
                               ),
                               child: Text("Riwayat", style: TextStyle(color: _showHistory ? Colors.white : Colors.green, fontWeight: FontWeight.bold)),
                             ),
                           ),
                         ],
                       ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // 2. LIST CONTENT
            displayPosts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(_showHistory ? "Belum ada riwayat penjualan." : 'Belum ada iklan aktif.', style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const NeverScrollableScrollPhysics(), // Scroll handled by Parent
                  shrinkWrap: true,
                  itemCount: displayPosts.length,
                  itemBuilder: (context, index) {
                    final post = displayPosts[index];
                    return Stack(
                      children: [
                        Container(
                          // 1. Layer Shadow: Outer Container with Margin
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
                          // 2. Inner Content Layer with Stroke & Clip
                          child: Material(
                            color: Colors.white,
                            elevation: 0,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: Colors.grey.shade300, width: 2.0),
                            ),
                            child: Column(
                              children: [
                                // Header (Colored Strip)
                                Container(
                                  padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                                  decoration: BoxDecoration(
                                    color: post.type == "Borong" ? Colors.green.shade50 : Colors.orange.shade50,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                                    border: Border(bottom: BorderSide(color: post.type == "Borong" ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2)))
                                  ),
                                  child: Row(
                                    children: [
                                      // Tag Type
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: post.type == "Borong" ? const Color(0xFF1B5E20) : Colors.deepOrange,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [BoxShadow(color: (post.type == "Borong" ? Colors.green : Colors.orange).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3))]
                                        ),
                                        child: Text(post.type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                      ),
                                      const Spacer(),
                                      
                                      // Grouped Action Buttons
                                       if (_showHistory)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(8)),
                                          child: const Text("TERJUAL", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                        )
                                      else 
                                        Row(
                                          children: [
                                            // Update Price
                                            if (post.type == "Borong") ...[
                                                InkWell(
                                                  onTap: () => _updateOfferPrice(post),
                                                  child: Container(
                                                    width: 36, height: 36,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(10),
                                                      boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
                                                    ),
                                                    child: const Icon(Icons.price_check, size: 18, color: Colors.green),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                            ],
                                            
                                            // Edit Action
                                            InkWell(
                                              onTap: () => _editListing(post),
                                              child: Container(
                                                width: 36, height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
                                                ),
                                                child: const Icon(Icons.edit, size: 18, color: Colors.blue),
                                              ),
                                            ),
                                          ],
                                        )
                                    ],
                                  ),
                                ),
                                
                                // Body Content
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Image
                                      Container(
                                        width: 90, height: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.grey.shade200),
                                          image: const DecorationImage(
                                            image: NetworkImage("https://via.placeholder.com/150"), 
                                            fit: BoxFit.cover,
                                            opacity: 0.8
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(Icons.add_a_photo, color: Colors.grey.shade400, size: 30),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(post.commodity, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF212121))),
                                            const SizedBox(height: 6),
                                            
                                            // Attributes
                                            Row(
                                              children: [
                                                Icon(Icons.scale, size: 14, color: Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text("${post.quantityTons} Ton", style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                                const SizedBox(width: 12),
                                                Icon(Icons.aspect_ratio, size: 14, color: Colors.grey.shade600),
                                                const SizedBox(width: 4),
                                                Text(post.area, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                              ],
                                            ),
                                            
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F8E9),
                                                borderRadius: BorderRadius.circular(6)
                                              ),
                                              child: Text(
                                                _showHistory 
                                                  ? "Deal: Rp ${_formatNumber(post.soldPrice ?? 0)}" 
                                                  : "Rp ${_formatNumber(post.price)} ${post.type == 'Borong' ? '(Total)' : '/ Kg'}", 
                                                style: TextStyle(
                                                  color: _showHistory ? Colors.grey.shade700 : const Color(0xFF1B5E20), 
                                                  fontWeight: FontWeight.w800, 
                                                  fontSize: 15
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Footer Button
                                if (!_showHistory)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                    child: InkWell(
                                      onTap: () => _markAsSold(post),
                                      child: Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.red.shade100, width: 1.5),
                                          color: Colors.red.shade50
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle_outline, size: 20, color: Colors.red.shade700),
                                            const SizedBox(width: 8),
                                            Text("Tandai Laku / Terjual", style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),

                        // 3. RATING OVERLAY (If Reviewed)
                        if (_showHistory && post.rating != null)
                          Positioned(
                            top: 10, right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text("${post.rating}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                                ],
                              ),
                            ),
                          )
                      ],
                    );
                  },
                ),
          ],
        ),
      ),
    );


    final Widget hargaPasar = const MarketScreen(); 
    // PERBAIKAN: Hapus parameter onSubmit
    final Widget buatIklan = const ListingFormScreen(); 
    final Widget profil = const ProfileScreen();

    final List<Widget> pages = [lapakSaya, hargaPasar, buatIklan, profil];
    
    return Scaffold(
        resizeToAvoidBottomInset: false, // Prevents navbar from floating up with keyboard
        backgroundColor: Theme.of(context).colorScheme.background,
        // Make body extend behind navbar if needed, but Stack handles it.
        body: Stack(
          children: [
            // Content Area
            Positioned.fill(
               // Standard page content, handled by specific widgets
              child: pages[_selectedIndex]
            ),

            // Unified PS5 Navbar Widget
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Ps5Navbar(
                selectedIndex: _selectedIndex,
                onItemTapped: _onItemTapped,
              ),
            ),
          ],
        ),
    );
  }

  // Helper for Thousand Separator (e.g. 1000000 -> 1.000.000)
  String _formatNumber(num number) {
    if (number == 0) return "0";
    String s = number.toString();
    // Regex to insert dots every 3 digits
    return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }
}

// 🎮 UNIFIED PS5 NAVBAR COMPONENT (DIPINDAHKAN KE LUAR _FarmerHomeScreenState)
class Ps5Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Ps5Navbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<double> itemXPercents = [0.125, 0.375, 0.625, 0.875];
    final Color navBgColor = const Color(0xFF1B5E20); 
    final Color selectedColor = Colors.white;
    final Color unselectedColor = Colors.white60;

    // --- CURVE MATHEMATICS ---
    // 1. Icon Curve (Top Layer)
    double getIconCurveY(double xPercent) {
      return 80 * (xPercent - 0.5) * (xPercent - 0.5) + 10;
    }

    // 2. Inner/Bottom Curve (Divider Layer)
    double getInnerCurveY(double xPercent) {
      return 60 * (xPercent * xPercent - xPercent) + 90;
    }
    
    // 3. Dash Rotation (Calculated from Derivative)
    // Left (x < 0.5) => Slope is Negative. Rotation should be Negative (CCW).
    // Right (x > 0.5) => Slope is Positive. Rotation should be Positive (CW).
    double getDashAngle(double xPercent) {
        // (60.0 / Width) * (2x - 1)
        // Note: Using a fixed reference width for consistent rotation feel across devices
        // or using actual screenWidth for physical exactness. Using screenWidth is usage correct.
        return (60.0 / screenWidth) * (2 * xPercent - 1);
    }

    final double selectedXPercent = itemXPercents[selectedIndex];
    final double selectedIconY = getIconCurveY(selectedXPercent);
    final double selectedDashY = getInnerCurveY(selectedXPercent);
    final double selectedAngle = getDashAngle(selectedXPercent);

    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. DUAL CURVE BACKGROUND
          CustomPaint(
            size: Size(screenWidth, 110),
            painter: DualCurvePainter(color: navBgColor),
          ),

          // 2. DYNAMIC TEXT (Inside Bottom Curve)
          Positioned(
            bottom: 8, 
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
                  child: child,
                ));
              },
              child: Text(
                _getLabelForIndex(selectedIndex),
                key: ValueKey<int>(selectedIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // 3. GLOW LIGHT (Under Icons)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuad,
            left: (screenWidth * selectedXPercent) - 30, 
            top: selectedIconY - 5, 
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                    BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20, spreadRadius: 1),
                ]
              ),
            ),
          ),
          
          // 4. CURVED LED DASH (Follows Tangent & Shape)
          AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
              left: (screenWidth * selectedXPercent) - 15, 
              top: selectedDashY - 2, 
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuad,
                transform: Matrix4.rotationZ(selectedAngle),
                alignment: Alignment.center,
                child: CustomPaint(
                  size: const Size(30, 4), 
                  painter: CurvedDashPainter(),
                ),
              ),
          ),

          // 5. ICONS
          ...List.generate(4, (index) {
            final double xPercent = itemXPercents[index];
            final double yOffset = getIconCurveY(xPercent);
            final bool isSelected = selectedIndex == index;

            return Positioned(
              left: (screenWidth * xPercent) - 30, 
              top: yOffset - 5,
              child: GestureDetector(
                onTap: () => onItemTapped(index),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 60, height: 60,
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _getIconForIndex(index),
                      color: isSelected ? selectedColor : unselectedColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0: return Icons.store;
      case 1: return Icons.trending_up;
      case 2: return Icons.add_box;
      case 3: return Icons.person;
      default: return Icons.circle;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0: return "LAPAK SAYA";
      case 1: return "PASAR";
      case 2: return "IKLAN";
      case 3: return "PROFIL";
      default: return "";
    }
  }
}


// 🎨 DUAL CURVE PAINTER (DIPINDAHKAN KE LUAR)
class DualCurvePainter extends CustomPainter {
  final Color color;
  DualCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // 1. LAYER BAWAH (Utama, Hijau Gelap) - Curve Besar
    paint.color = color;
    // Shadow
    canvas.drawShadow(
      Path()
        ..moveTo(0, size.height)
        ..lineTo(0, 30)
        ..quadraticBezierTo(size.width/2, -10, size.width, 30)
        ..lineTo(size.width, size.height)
        ..close(), 
      Colors.black.withOpacity(0.5), 8, true
    );

    final mainPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 30)
      ..quadraticBezierTo(size.width/2, -10, size.width, 30)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(mainPath, paint);

    // 2. LAYER ATAS/DEPAN (Glassy/Lighter) - Curve Bawah untuk Teks
    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.05) 
      ..style = PaintingStyle.fill;

    final innerPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height - 20)
      ..quadraticBezierTo(size.width/2, size.height - 50, size.width, size.height - 20)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(innerPath, innerPaint);
    
    // Optional: Border line for inner curve to make it pop
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(innerPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 🎨 CURVED DASH PAINTER (DIPINDAHKAN KE LUAR)
class CurvedDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2); 

    final path = Path();
    path.moveTo(0, size.height);
    // Flat curve (almost straight but convex)
    path.quadraticBezierTo(size.width / 2, 2.5, size.width, size.height);

    // Also draw shadow
    final shadowPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}