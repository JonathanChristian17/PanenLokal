import 'package:flutter/material.dart';

class CommodityRequest {
  final String commodity;
  final double quantityTons;
  final String location;
  final int maxPriceKg;
  final String deadline;
  final bool isTrendingUp; // Indikator tren

  const CommodityRequest({
    required this.commodity,
    required this.quantityTons,
    required this.location,
    required this.maxPriceKg,
    required this.deadline,
    this.isTrendingUp = true, // Default tren naik
  });
}

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  final List<CommodityRequest> requests = const [
    CommodityRequest(
      commodity: 'Wortel Kualitas A',
      quantityTons: 20.0,
      location: 'Jakarta (Gudang Blok A)',
      maxPriceKg: 4200,
      deadline: '17 Oktober',
      isTrendingUp: true,
    ),
    CommodityRequest(
      commodity: 'Bawang Merah Jumbo',
      quantityTons: 10.0,
      location: 'Surabaya (Cold Storage)',
      maxPriceKg: 24000,
      deadline: '25 Oktober',
      isTrendingUp: false, // Tren turun
    ),
    CommodityRequest(
      commodity: 'Kentang Granola',
      quantityTons: 15.0,
      location: 'Bandung (Pasar Induk)',
      maxPriceKg: 6000,
      deadline: '30 November',
      isTrendingUp: true,
    ),
    CommodityRequest(
      commodity: 'Cabai Rawit Merah',
      quantityTons: 5.0,
      location: 'Yogyakarta (Gudang Pasar)',
      maxPriceKg: 45000,
      deadline: '10 November',
      isTrendingUp: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Harga Pasar & Permintaan'), 
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Halaman Buat Permintaan Baru'), backgroundColor: Theme.of(context).colorScheme.primary,)
              );
            },
            tooltip: 'Buat Permintaan Baru',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
            child: Text(
              'Tren dan daftar kebutuhan komoditas dari berbagai wilayah.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${req.commodity} (${req.quantityTons} Ton)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(req.location, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                            const Spacer(),
                            // Indikator tren harga
                            Icon(
                              req.isTrendingUp ? Icons.arrow_upward : Icons.arrow_downward,
                              color: req.isTrendingUp ? Colors.green.shade600 : Colors.red.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              req.isTrendingUp ? 'Naik' : 'Turun',
                              style: TextStyle(
                                color: req.isTrendingUp ? Colors.green.shade600 : Colors.red.shade600,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Harga Penawaran Max/Kg:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                Text('Rp ${req.maxPriceKg}', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Deadline Penawaran:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                                Text(req.deadline, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.show_chart, color: Colors.white),
                            label: const Text('Lihat Tren Lebih Lanjut', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Melihat tren harga ${req.commodity}'), backgroundColor: Theme.of(context).colorScheme.primary,)
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              elevation: 5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}