import 'package:flutter/material.dart';
import 'buyer_home_screen.dart'; 
import 'farmer_home_screen.dart'; 

class PilihanPeranScreen extends StatelessWidget {
  const PilihanPeranScreen({super.key});

  // Fungsi untuk menampilkan dialog konfirmasi
  void _showConfirmationDialog(BuildContext context, String role, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Peran'),
          content: Text('Apakah kamu ingin menjadi "$role"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Tutup dialog (Batal)
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                onConfirm(); // Jalankan navigasi
              },
              child: const Text('Ya, Lanjutkan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.background.withOpacity(0.8), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('assets/images/panenlokal_logo.png'), 
                width: 150, 
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Pilih peran Anda untuk mulai bertransaksi:',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _RoleSelectionButton(
                icon: Icons.shopping_basket,
                label: 'Saya Pembeli',
                onPressed: () {
                  _showConfirmationDialog(context, 'Pembeli', () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const BuyerHomeScreen(title: 'Beranda Pembeli')),
                    );
                  });
                },
              ),
              const SizedBox(height: 20),
              _RoleSelectionButton(
                icon: Icons.agriculture,
                label: 'Saya Petani',
                onPressed: () {
                  _showConfirmationDialog(context, 'Petani', () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const FarmerHomeScreen(title: 'Lapak Saya')),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget bantu untuk tombol pilihan peran
class _RoleSelectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _RoleSelectionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 8, 
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        ),
      ),
    );
  }
}