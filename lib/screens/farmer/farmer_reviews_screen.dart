import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:panen_lokal/models/review_model.dart';
import 'package:panen_lokal/services/review_service.dart';

// --- SCREEN UTAMA ---
class FarmerReviewsScreen extends StatefulWidget {
  final String farmerId;
  final String farmerName;

  const FarmerReviewsScreen({
    super.key, 
    required this.farmerId, 
    required this.farmerName
  });

  @override
  State<FarmerReviewsScreen> createState() => _FarmerReviewsScreenState();
}

class _FarmerReviewsScreenState extends State<FarmerReviewsScreen> {
  List<ReviewModel> _reviews = [];
  bool _isLoading = true;
  double _avgRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

 Future<void> _fetchReviews() async {
  setState(() => _isLoading = true);

  // 🔥 SELALU panggil tanpa sellerId
  final result = await ReviewService().getReviews();

  if (result['success'] == true) {
    final List data = result['data'];

    setState(() {
      _reviews = data
          .map((e) => ReviewModel.fromJson(e))
          .toList();

      _avgRating = _reviews.isEmpty
          ? 0
          : _reviews
              .map((e) => e.rating)
              .reduce((a, b) => a + b) /
              _reviews.length;

      _isLoading = false;
    });
  } else {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("Ulasan ${widget.farmerName}", 
          style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchReviews,
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: CustomColors.darkGreen))
        : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingSummaryCard(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text("Ulasan Terbaru (${_reviews.length})", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    const Icon(Icons.sort, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),
                _reviews.isEmpty 
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) => _buildReviewCard(_reviews[index]),
                    ),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildRatingSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CustomColors.darkGreen, CustomColors.lightGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Rating Rata-rata", style: TextStyle(color: Colors.white70)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_avgRating.toStringAsFixed(1), 
                    style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10, left: 8),
                    child: Text("/ 5.0", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star, 
                  color: index < _avgRating.round() ? Colors.amber : Colors.white24, 
                  size: 20
                )),
              )
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.stars_rounded, color: Colors.white, size: 40),
          )
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      review.reviewerName,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    ),
    const SizedBox(height: 2),
    Text(
      "Petani: ${review.sellerName}",
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    ),
  


          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (i) => Icon(
              Icons.star, 
              size: 14, 
              color: i < review.rating ? Colors.amber : Colors.grey.shade300
            )),
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.4)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Text(review.itemTitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Belum ada ulasan", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class CustomColors {
  static const Color darkGreen = Color(0xFF1B5E20);
  static const Color lightGreen = Color(0xFF43A047);
}