import 'package:flutter/material.dart';
// import 'package:panen_lokal/models/community_data.dart'; // Jika CommodityPost di file ini
import 'buyer_home_screen.dart'; // Import untuk CommodityPost\
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _contactFarmer(BuildContext context) async {
  String cleanedNumber =
      widget.post.contactInfo.replaceAll(RegExp(r'[^0-9]'), '');

  if (cleanedNumber.startsWith('0')) {
    cleanedNumber = '62${cleanedNumber.substring(1)}';
  }

  final message = Uri.encodeComponent(
      "Halo, saya tertarik dengan ${widget.post.commodity} di PanenLokal.");

  final Uri whatsappUri =
      Uri.parse("https://wa.me/$cleanedNumber?text=$message");

  await launchUrl(
    whatsappUri,
    mode: LaunchMode.externalApplication,
  );

  // 🔔 Trigger callback ke BuyerHomeScreen
  if (widget.onContacted != null) {
    widget.onContacted!();
  }
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
                  Image.network(
                    widget.post.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  
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