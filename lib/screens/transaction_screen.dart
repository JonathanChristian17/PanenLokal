import 'package:flutter/material.dart';
import 'package:panen_lokal/models/transaction_model.dart';
import 'package:panen_lokal/models/transaction_status.dart'; // ✅ Import status juga

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = _dummyTransactions();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBE7),
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text(
                'Belum ada transaksi',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return _TransactionCard(item: transactions[index]);
              },
            ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel item;
  const _TransactionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    // ✅ LENGKAPI semua case enum
    switch (item.status) {
      case TransactionStatus.success:
        statusColor = Colors.green;
        statusText = 'Berhasil';
        statusIcon = Icons.check_circle;
        break;
      case TransactionStatus.failed:
        statusColor = Colors.red;
        statusText = 'Gagal';
        statusIcon = Icons.cancel;
        break;
      case TransactionStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        statusIcon = Icons.access_time;
        break;
      case TransactionStatus.negotiating:
        statusColor = Colors.blue;
        statusText = 'Negosiasi';
        statusIcon = Icons.chat_bubble;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF4CAF50),
                    radius: 16,
                    child: Icon(Icons.storefront, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "PanenLokal",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          /// PRODUK INFO
          Row(
            children: [
              // ✅ Tampilkan gambar produk jika ada
              if (item.productImage != null)
                Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.productImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName ?? 'Produk Tidak Diketahui',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (item.price != null)
                      Text(
                        "Harga: Rp ${_formatCurrency(item.price!)}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.contactedAt ?? item.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// TOMBOL AKSI
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Tombol Detail
              OutlinedButton.icon(
                onPressed: () {
                  _showTransactionDetail(context, item);
                },
                icon: const Icon(Icons.info_outline, size: 16),
                label: const Text("Detail"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Tombol Ulas (hanya jika success)
              if (item.status == TransactionStatus.success)
                ElevatedButton.icon(
                  onPressed: () {
                    _showReviewDialog(context, item);
                  },
                  icon: const Icon(Icons.rate_review, size: 16),
                  label: const Text("Ulas"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  // ✅ Helper untuk format currency
  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // ✅ Helper untuk format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} menit lalu';
      }
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ✅ Dialog Detail Transaksi
void _showTransactionDetail(BuildContext context, TransactionModel item) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Detail Transaksi"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow("ID Transaksi", item.id),
            _buildDetailRow("Produk", item.productName ?? '-'),
            if (item.price != null)
              _buildDetailRow("Harga", "Rp ${item.price!.toStringAsFixed(0)}"),
            _buildDetailRow("Status", item.status.displayName),
            _buildDetailRow("Dihubungi", 
              item.contactedAt != null 
                ? "${item.contactedAt!.day}/${item.contactedAt!.month}/${item.contactedAt!.year}"
                : "-"),
            if (item.completedAt != null)
              _buildDetailRow("Selesai", 
                "${item.completedAt!.day}/${item.completedAt!.month}/${item.completedAt!.year}"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Tutup"),
        ),
      ],
    ),
  );
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const Text(": "),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    ),
  );
}

// ✅ Dialog Review
void _showReviewDialog(BuildContext context, TransactionModel item) {
  double rating = 5.0;
  final reviewController = TextEditingController();

  showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Beri Ulasan"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.productName ?? 'Produk',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text("Rating:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
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
                      setState(() => rating = index + 1.0);
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tulis ulasanmu...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Ulasan terkirim! Terima kasih 🎉"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text("Kirim"),
          ),
        ],
      ),
    ),
  );
}

// ✅ DUMMY DATA (sesuai dengan TransactionModel yang benar)
List<TransactionModel> _dummyTransactions() {
  return [
    TransactionModel(
      id: '1',
      buyerId: '10',
      farmerId: '5',
      listingId: '101',
      status: TransactionStatus.success,
      contactedAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      productName: 'Brokoli Segar',
      productImage: 'https://example.com/brokoli.jpg',
      price: 197100,
    ),
    TransactionModel(
      id: '2',
      buyerId: '10',
      farmerId: '6',
      listingId: '102',
      status: TransactionStatus.negotiating,
      contactedAt: DateTime.now().subtract(const Duration(hours: 3)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
      productName: 'Tomat Merah 5 Kg',
      productImage: 'https://example.com/tomat.jpg',
      price: 193100,
    ),
    TransactionModel(
      id: '3',
      buyerId: '10',
      farmerId: '7',
      listingId: '103',
      status: TransactionStatus.failed,
      contactedAt: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      productName: 'Cabai Merah Keriting',
      price: 193100,
    ),
  ];
}