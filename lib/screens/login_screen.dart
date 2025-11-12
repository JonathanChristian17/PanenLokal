import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'buyer_home_screen.dart';
import 'farmer_home_screen.dart';
import 'pilihan_peran_screen.dart'; 

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final String role; 

  LoginScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    Widget nextScreen;
    if (role == 'pembeli') {
      nextScreen = const BuyerHomeScreen(title: 'Beranda Pembeli');
    } else {
      nextScreen = const FarmerHomeScreen(title: 'Lapak Saya');
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Gunakan warna background dari tema
      appBar: AppBar(
        title: Text('Login ${role == 'pembeli' ? 'Pembeli' : 'Petani'}'),
        backgroundColor: Theme.of(context).colorScheme.background, // Sesuaikan warna latar belakang body
        elevation: 0, 
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onBackground), // Ikon dan warna disesuaikan
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PilihanPeranScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Pusatkan secara vertikal
              children: [
                Icon(
                  role == 'pembeli' ? Icons.shopping_bag_outlined : Icons.agriculture_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Masuk sebagai ${role == 'pembeli' ? 'Pembeli' : 'Petani'}',
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'Masukkan email Anda',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    hintText: 'Masukkan password Anda',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55, // Sedikit lebih tinggi
                  child: FilledButton(
                    onPressed: () {
                      if (emailController.text.isNotEmpty &&
                          passwordController.text.isNotEmpty) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => nextScreen,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: const Text('Email dan Password wajib diisi'),
                              backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegisterScreen(role: role)),
                    );
                  },
                  child: const Text(
                    "Belum punya akun? Daftar di sini",
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}