import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const NotificationItem({required this.title, required this.subtitle, required this.icon, required this.color});
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  final List<NotificationItem> notifications = const [
    NotificationItem(
      title: 'Listing Disukai',
      subtitle: 'Wortel Kualitas A dari Pak Budi ditambahkan ke favorit Anda.',
      icon: Icons.favorite,
      color: Colors.pink,
    ),
    NotificationItem(
      title: 'Listing Favorit Diperbarui',
      subtitle: 'Harga Bawang Merah Brebes telah turun.',
      icon: Icons.notifications_active,
      color: Colors.orange,
    ),
    NotificationItem(
      title: 'Notifikasi Komunitas',
      subtitle: 'Postingan Tomat Cherry Organik telah melewati batas waktu.',
      icon: Icons.timer_off,
      color: Colors.red,
    ),
     NotificationItem(
      title: 'Pesanan Baru',
      subtitle: 'Anda memiliki pesanan baru untuk Cabai Merah Keriting.',
      icon: Icons.local_shipping,
      color: Colors.blue,
    ),
    NotificationItem(
      title: 'Pembayaran Diterima',
      subtitle: 'Pembayaran untuk listing Kentang Granola telah dikonfirmasi.',
      icon: Icons.payment,
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Favorit & Notifikasi'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Tandai Semua Dibaca'), backgroundColor: Theme.of(context).colorScheme.primary,)
              );
            },
            tooltip: 'Tandai Semua Dibaca',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Melihat detail item: ${item.title}'), backgroundColor: Theme.of(context).colorScheme.primary,)
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: item.color, size: 28),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                          const SizedBox(height: 5),
                          Text(item.subtitle, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}