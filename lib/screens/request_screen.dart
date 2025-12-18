import 'package:flutter/material.dart';
import 'package:panen_lokal/services/favorite_service.dart';
import 'buyer_home_screen.dart';
import 'listing_detail_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  List<CommodityPost> _favoritePosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await _favoriteService.getFavorites();

      if (result['success']) {
        final List<dynamic> data = result['data'] ?? [];
        
        setState(() {
          _favoritePosts = data.map((item) {
            // --- PERBAIKAN HANDLING GAMBAR ---
            // Memastikan data images diproses sebagai List<String> yang valid
            List<String> imgList = [];
            if (item['images'] != null && item['images'] is List) {
              for (var img in item['images']) {
                if (img is String) {
                  imgList.add(img);
                } else if (img is Map && img.containsKey('url')) {
                  imgList.add(img['url'].toString());
                }
              }
            }

            return CommodityPost(
              id: item['id'].toString(),
              commodity: item['title'] ?? '',
              location: item['location'] ?? '',
              area: item['area'] ?? '',
              price: double.tryParse(item['price'].toString()) ?? 0.0,
              quantityTons: double.tryParse(item['stock'].toString()) ?? 0.0,
              contactName: item['contact_name'] ?? '',
              contactInfo: item['contact_number'] ?? '',
              category: item['category'] ?? 'sayur',
              description: item['description'] ?? 'Deskripsi belum ditambahkan oleh petani.',
              pricingType: item['type'] == 'Borong' ? 'total' : 'kg',
              // Gunakan index pertama jika ada, jika tidak gunakan placeholder
              imagePath: imgList.isNotEmpty
                  ? imgList[0]
                  : 'assets/images/placeholder.jpg',
              images: imgList,
            );
          }).toList();
          _isLoading = false;
        });

        print('✅ Loaded ${_favoritePosts.length} favorites');
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal memuat favorit')),
          );
        }
      }
    } catch (e) {
      print('❌ Error loading favorites: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing data: $e')),
        );
      }
    }
  }

  String _formatCurrency(num value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _removeFavorite(String listingId) async {
    try {
      final result = await _favoriteService.removeFavorite(listingId);
      
      if (result['success']) {
        await _loadFavorites(); // Reload list setelah hapus
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dihapus dari favorit'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menghapus favorit'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFavorites,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 25, left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B5E20), size: 24),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Favorit Saya",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 36), // Balance for back button
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // CONTENT
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isLoading && _favoritePosts.isNotEmpty)
                        Text(
                          'Anda memiliki ${_favoritePosts.length} listing favorit',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                        ),
                      const SizedBox(height: 20),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 50),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_favoritePosts.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: Column(
                              children: [
                                Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada listing favorit',
                                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tandai listing dengan ❤️ untuk menyimpannya di sini',
                                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _favoritePosts.length,
                          itemBuilder: (context, index) {
                            return _buildFavoriteCard(_favoritePosts[index]);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(CommodityPost post) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailScreen(
              post: post,
              isFavorite: true,
              onToggleFavorite: () async => await _removeFavorite(post.id),
            ),
          ),
        );
        
        if (result == true) _loadFavorites();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.pink.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.pink.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Image Section
                Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(19)),
                    border: Border(right: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(19)),
                    child: Image.network(
                      post.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey, size: 40),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                      },
                    ),
                  ),
                ),

                // Text Content Section
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    post.location,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0B2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.deepOrange, width: 1),
                              ),
                              child: Text(
                                "ESTIMASI: ${post.quantityTons} TON",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.deepOrange),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Rp ${_formatCurrency(post.price)}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Remove Favorite Icon
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _removeFavorite(post.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 22),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}