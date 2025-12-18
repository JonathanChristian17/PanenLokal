import 'package:flutter/material.dart';
import '../services/market_service.dart';
import '../models/market_price.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _service = MarketService();
  late Future<List<MarketPrice>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = _service.getMarketPrices();
  }

  @override
  Widget build(BuildContext context) {
    DateTime displayDate = DateTime.now();
    if (displayDate.hour < 20) {
      displayDate = displayDate.subtract(const Duration(days: 1));
    }

    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    final String formattedDate =
        "${displayDate.day.toString().padLeft(2, '0')} ${months[displayDate.month - 1]} ${displayDate.year}";

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: FutureBuilder<List<MarketPrice>>(
          future: futureItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.hasError) {
              return const Center(
                child: Text("Gagal memuat data harga."),
              );
            }

            final List<MarketPrice> marketItems = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 25, left: 20, right: 20),
                      child: Column(
                        children: [
                          const Text(
                            "Daftar Harga Komoditas",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Data Tanggal: $formattedDate",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5)),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pantau Harga Tani Tanah Karo",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          SizedBox(height: 4),
                          Text("Update setiap hari pukul 20:00 WIB.",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // GRID
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: marketItems.length,
                      itemBuilder: (context, index) {
                        return _buildMarketCard(context, marketItems[index]);
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Citation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.link, size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Text("Sumber Data Resmi: Karosatuklik",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.black87)),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            "https://karosatuklik.com/topic/daftar-harga-komoditas/",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMarketCard(BuildContext context, MarketPrice item) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _buildCommodityImage(item),
                    ),
                    const SizedBox(height: 12),
                    // Nama komoditas
                    Text(
                      item.commodity,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B5E20),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Harga
                    Text(
                      "Rp ${item.price}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Satuan
                    Text(
                      item.unit,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Badge contoh: harga naik/turun (statis)
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Naik",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommodityImage(MarketPrice item) {
    final Map<String, String> imageMap = {
      'brokoli': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQoZibA23ib5SuJNRALc1XaRwYcGhLMWASI-Q&s',
      'buncis': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR_X-tzbbZ2-qWVWZ5HYikXYInPt96gpKcXFw&s',
      'cabe hijau': 'https://tribratanews.polri.go.id/web/image/blog.post/65587/image',
      'cabai hijau': 'https://tribratanews.polri.go.id/web/image/blog.post/65587/image',
      'cabe merah': 'https://image.astronauts.cloud/product-images/2024/12/CabeMerahKeriting1_1ee33114-5322-4f80-ab7b-3f6013c585d5_900x900.jpg',
      'cabai merah': 'https://image.astronauts.cloud/product-images/2024/12/CabeMerahKeriting1_1ee33114-5322-4f80-ab7b-3f6013c585d5_900x900.jpg',
      'cabai rawit kasar': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTgsidARD2fph8fxMLJhGsbW3LceDWYVTS27Q&s',
      'cabai rawit kecil': 'https://image.astronauts.cloud/product-images/2024/12/CabeRawit2_5f19172c-f8d4-4a81-b45e-f15fde938349_900x900.jpg',
      'daun prey': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSwht1xG9adGTeOaGxMnyH-tRF30GEDBWUiw&s',
      'daun sop': 'https://img-cdn.medkomtek.com/-I_5HiTizAH_rdGu7qmppL2kjfc=/0x0/smart/filters:quality(100):format(webp)/article/JGO9ltUqCUUf8iQa3qrZ_/original/042653600_1502179311-4-Manfaat-Daun-Seledri-yang-Belum-Anda-Ketahui.jpg',
      'ercis brastagi': 'https://media.istockphoto.com/id/504313024/id/foto/gula-snap-kacang-polong.jpg?s=612x612&w=0&k=20&c=i0OWiOL7c-Wsfwnv6ZZq3T2iExJANlTO7T0M4XCdLcc=',
      'ercis': 'https://media.istockphoto.com/id/504313024/id/foto/gula-snap-kacang-polong.jpg?s=612x612&w=0&k=20&c=i0OWiOL7c-Wsfwnv6ZZq3T2iExJANlTO7T0M4XCdLcc=',
      'jagung manis': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSSU7ZqgX_952IFs29F1Hnp_J9q1uI1KAUHPA&s',
      'jipang besar': 'https://img.lazcdn.com/g/p/7b6888adbb25d6bcf5cbaa27f528bae9.jpg_720x720q80.jpg',
      'kentang kuning': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQPqHFrT3tIz9CBrCbxAsPsNgPT_F-fTs7SFQ&s',
      'kentang merah': 'https://www.static-src.com/wcsstore/Indraprastha/images/catalog/full/catalog-image/103/MTA-178650803/no-brand_kentang-merah_full01.jpg',
      'kol bulat': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwpaa9tR-6mpvVAsc38OdujuFloIz4q8qfAA&s',
      'kubis': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwpaa9tR-6mpvVAsc38OdujuFloIz4q8qfAA&s',
      'kol bunga': 'https://raisa.aeonstore.id/wp-content/uploads/2023/04/801621.jpeg',
      'labu': 'https://pasarternate.com/wp-content/uploads/2025/06/Labu-kuning.jpg',
      'sayur botol': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQzibjdrgDIgQ9pqkcSyhS0JBbMZWC-xbOG8w&s',
      'sayur pahit': 'https://segarpagi.com/wp-content/uploads/2023/02/Sawi-Pahit-1.jpg',
      'sayur putih': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQDfyQ3tKLbbHhAt2OiXA-TrHYNixD63jHIfQ&s',
      'selada': 'https://d1vbn70lmn1nqe.cloudfront.net/prod/wp-content/uploads/2023/09/06014959/Kandungan-Nutrisi-yang-Terdapat-dalam-Daun-Selada.jpg',
      'terong antaboga': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSA5Cf20HBBaTzJgCw3uNCXpFLc4ujI_tIghw&s',
      'terong belanda': 'https://images.tokopedia.net/blog-tokopedia-com/uploads/2021/08/Featured_Manfaat-Terong-Belanda.jpg',
      'tomat': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/1200px-Tomato_je.jpg',
      'wortel': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRba3x5cGZnr5uC2xWOoq3EVBtT12f-YsanHQ&s',
      'anak jipang': 'https://www.shutterstock.com/image-photo/closeup-small-chayote-sicyos-edule-600nw-2480192811.jpg',
    };

    String? imageUrl;
    String name = item.commodity.toLowerCase();

    // Find first key that matches the commodity name partial match
    for (var key in imageMap.keys) {
      if (name.contains(key)) {
        imageUrl = imageMap[key];
        break;
      }
    }

    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Image.network(
          imageUrl,
          height: 90,
          width: 90,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              item.icon,
              style: const TextStyle(fontSize: 48),
            );
          },
        ),
      );
    } else {
      return Text(
        item.icon,
        style: const TextStyle(fontSize: 48),
      );
    }
  }
}