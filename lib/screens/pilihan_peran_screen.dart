import 'package:flutter/material.dart';
import 'login_screen.dart'; 

class PilihanPeranScreen extends StatelessWidget {
  const PilihanPeranScreen({super.key});

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
                image: AssetImage('assets/images/panenlokal.png'), 
                width: 150, 
                height: 150,
              ),
              const SizedBox(height: 20),
              Text(
                'Selamat Datang di Panen Lokal!',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Pilih peran Anda untuk melanjutkan:',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _RoleSelectionButton(
                icon: Icons.shopping_basket,
                label: 'Saya Pembeli',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen(role: 'pembeli')),
                  );
                },
              ),
              const SizedBox(height: 20),
              _RoleSelectionButton(
                icon: Icons.agriculture,
                label: 'Saya Petani',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen(role: 'petani')),
                  );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 8, // Tambah elevasi
          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        ),
      ),
    );
  }
}