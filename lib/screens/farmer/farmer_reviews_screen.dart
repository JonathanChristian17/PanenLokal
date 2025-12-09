import 'package:flutter/material.dart';

class FarmerReviewsScreen extends StatelessWidget {
  const FarmerReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Reviews
    final List<Map<String, dynamic>> reviews = [
      {
        "name": "Budi Santoso",
        "rating": 5.0,
        "date": "10 Des 2024",
        "comment": "Sayurannya seger banget! Respon cepat, mantap.",
        "item": "Sawi Hijau 10kg"
      },
      {
        "name": "Siti Aminah",
        "rating": 4.5,
        "date": "08 Des 2024",
        "comment": "Kualitas bagus, tapi pengiriman agak lama sedikit.",
        "item": "Cabai Merah 5kg"
      },
      {
        "name": "Warung Makan Barokah",
        "rating": 5.0,
        "date": "05 Des 2024",
        "comment": "Langganan terus tiap minggu. Harga bersahabat.",
        "item": "Tomat 20kg"
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Ulasan Pembeli", style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Rating Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [CustomColors.darkGreen, CustomColors.lightGreen], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Rating Rata-rata", style: TextStyle(color: Colors.white70)),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text("4.8", style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                          Padding(
                            padding: EdgeInsets.only(bottom: 10, left: 8),
                            child: Text("/ 5.0", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.amber, size: 20)),
                      )
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                 Text("Ulasan Terbaru (${reviews.length})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 const Spacer(),
                 const Icon(Icons.sort, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),

            // Review List
            ...reviews.map((review) => _buildReviewCard(review)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Text(review["name"][0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(review["date"], style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(review["rating"].toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(review["comment"], style: TextStyle(color: Colors.grey.shade800, height: 1.4)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(review["item"], style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Helper for colors
class CustomColors {
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF43A047);
}
