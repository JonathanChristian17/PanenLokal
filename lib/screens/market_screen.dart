import 'package:flutter/material.dart';


class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic: Harga reset pukul 20:00 (8 Malam).
    // Jika jam < 20:00, tampilkan harga/tanggal "Kemarin".
    // Jika jam >= 20:00, tampilkan harga/tanggal "Hari Ini".
    
    DateTime displayDate = DateTime.now();
    if (displayDate.hour < 20) {
       // Belum jam 8 malam, gunakan data kemarin
       displayDate = displayDate.subtract(const Duration(days: 1));
    }

    // Manual Formatting (Bypassing intl package)
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final String formattedDate = "${displayDate.day.toString().padLeft(2, '0')} ${months[displayDate.month - 1]} ${displayDate.year}";

    // 25 Daftar Harga Komoditas Pertanian Karo (Sumber Data: User/Karosatuklik)
    final List<MarketItem> marketItems = [
      MarketItem(name: "Ercis Berastagi", priceRange: "17.000 - 22.000", unit: "KG", icon: "🫛", trend: PriceTrend.up),
      MarketItem(name: "Brokoli", priceRange: "6.000 - 7.000", unit: "KG", icon: "🥦", trend: PriceTrend.up),
      MarketItem(name: "Buncis", priceRange: "14.000 - 15.000", unit: "KG", icon: "🫛", trend: PriceTrend.stable),
      MarketItem(name: "Cabai Hijau", priceRange: "25.000 - 28.000", unit: "KG", icon: "🌶️", trend: PriceTrend.up),
      MarketItem(name: "Cabai Merah", priceRange: "60.000 - 52.000", unit: "KG", icon: "🌶️", trend: PriceTrend.down),
      MarketItem(name: "Cabai Rawit Kasar", priceRange: "52.000 - 53.000", unit: "KG", icon: "🌶️", trend: PriceTrend.up),
      MarketItem(name: "Cabai Rawit Kecil", priceRange: "55.000", unit: "KG", icon: "🌶️", trend: PriceTrend.stable),
      MarketItem(name: "Daun Sop / Seledri", priceRange: "4.000 - 5.000", unit: "KG", icon: "🌿", trend: PriceTrend.up),
      MarketItem(name: "Daun Prey", priceRange: "5.000 - 6.000", unit: "KG", icon: "🧅", trend: PriceTrend.up),
      MarketItem(name: "Jagung Manis", priceRange: "2.500 - 3.500", unit: "KG", icon: "🌽", trend: PriceTrend.stable),
      MarketItem(name: "Kentang Kuning", priceRange: "6.000 - 7.000", unit: "KG", icon: "🥔", trend: PriceTrend.stable),
      MarketItem(name: "Kentang Merah", priceRange: "6.500 - 7.000", unit: "KG", icon: "🥔", trend: PriceTrend.up),
      MarketItem(name: "Kol / Kubis", priceRange: "2.000 - 2.500", unit: "KG", icon: "🥬", trend: PriceTrend.down),
      MarketItem(name: "Kol Bunga", priceRange: "4.500 - 5.500", unit: "KG", icon: "🥦", trend: PriceTrend.up),
      MarketItem(name: "Labu / Jambe", priceRange: "3.500", unit: "KG", icon: "🎃", trend: PriceTrend.stable),
      MarketItem(name: "Sayur Pahit", priceRange: "6.000 - 8.000", unit: "KG", icon: "🥬", trend: PriceTrend.up),
      MarketItem(name: "Sayur Putih", priceRange: "2.500 - 3.500", unit: "KG", icon: "🥬", trend: PriceTrend.down),
      MarketItem(name: "Terong Antaboga", priceRange: "100.000 - 110.000", unit: "BAL", icon: "🍆", trend: PriceTrend.up),
      MarketItem(name: "Tomat", priceRange: "6.500 - 7.500", unit: "KG", icon: "🍅", trend: PriceTrend.up),
      MarketItem(name: "Wortel Karo", priceRange: "7.000 - 8.000", unit: "KG", icon: "🥕", trend: PriceTrend.up),
      MarketItem(name: "Jipang Besar", priceRange: "45.000 - 55.000", unit: "RAJUT", icon: "🥒", trend: PriceTrend.up),
      MarketItem(name: "Anak Jipang", priceRange: "4.000", unit: "RAJUT", icon: "🥒", trend: PriceTrend.stable),
      MarketItem(name: "Selada", priceRange: "15.000 - 18.000", unit: "KG", icon: "🥬", trend: PriceTrend.up),
      MarketItem(name: "Sayur Botol", priceRange: "6.000 - 7.000", unit: "KG", icon: "🥒", trend: PriceTrend.stable),
      MarketItem(name: "Terong Belanda", priceRange: "20.000 - 23.000", unit: "KG", icon: "🍆", trend: PriceTrend.up),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Cream
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Daftar Harga Komoditas",
              style: TextStyle(
                color: Color(0xFF1B5E20), // Dark Green
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              "Data Tanggal: $formattedDate",
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner / Highlight
              Container(
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
                    BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pantau Harga Tani Karo", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text("Update setiap hari pukul 20:00 WIB.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // GRID LIST
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85, 
                ),
                itemCount: marketItems.length,
                itemBuilder: (context, index) {
                  return _buildMarketCard(context, marketItems[index]);
                },
              ),

              const SizedBox(height: 30),

              // SOURCE CITATION
              Container(
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
                        Text(
                          "Sumber Data Resmi: Karosatuklik",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      "https://karosatuklik.com/topic/daftar-harga-komoditas/",
                      style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Space for Navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketCard(BuildContext context, MarketItem item) {
    Color trendColor;
    IconData trendIcon;
    
    switch (item.trend) {
      case PriceTrend.up:
        trendColor = Colors.red;
        trendIcon = Icons.trending_up;
        break;
      case PriceTrend.down:
        trendColor = Colors.green; // Price down is usually bad for farmers but let's stick to standard market indicators: red for up (inflation), green for down? 
        // Actually for farmers, price UP is GOOD (Green), Price DOWN is BAD (Red).
        // Let's assume Farmer perspective: High price = Green.
        trendColor = const Color(0xFF1B5E20);
        trendIcon = Icons.trending_up;
        break;
      case PriceTrend.stable:
        trendColor = Colors.orange;
        trendIcon = Icons.remove;
        break;
    }
    // Correcting logic: The item just holds the enum. Overriding visuals: 
    // Usually Red = Price Increase (Expensive for buyer), Green = Cheap.
    // But this is Farmer App. High price = Profit. 
    // Let's just use: Arrow Up = Green, Arrow Down = Red, Line = Orange.
    
    if (item.trend == PriceTrend.up) {
        trendColor = const Color(0xFF2E7D32); // Green
        trendIcon = Icons.arrow_upward;
    } else if (item.trend == PriceTrend.down) {
        trendColor = const Color(0xFFC62828); // Red
        trendIcon = Icons.arrow_downward;
    } else {
        trendColor = Colors.grey;
        trendIcon = Icons.remove;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background, // Cream bg
              shape: BoxShape.circle,
            ),
            child: Text(item.icon, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 12),
          
          // Name
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          // Price
          Text(
            "Rp ${item.priceRange}",
            style: const TextStyle(
              color: Color(0xFF1B5E20), 
              fontWeight: FontWeight.w800, 
              fontSize: 14
            ),
          ),
          Text(
            "per ${item.unit}",
            style: TextStyle(color: Colors.grey[600], fontSize: 10),
          ),
          
          const SizedBox(height: 8),
          
          // Trend Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(trendIcon, size: 12, color: trendColor),
                const SizedBox(width: 4),
                Text(
                  item.trend == PriceTrend.up ? "Naik" : (item.trend == PriceTrend.down ? "Turun" : "Stabil"),
                  style: TextStyle(fontSize: 10, color: trendColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

enum PriceTrend { up, down, stable }

class MarketItem {
  final String name;
  final String priceRange;
  final String unit;
  final String icon;
  final PriceTrend trend;

  MarketItem({required this.name, required this.priceRange, required this.unit, required this.icon, required this.trend});
}
