import 'package:flutter/material.dart';
import 'buyer_home_screen.dart';
import 'farmer_home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role; 
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  void _register() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Semua field harus diisi'), backgroundColor: Theme.of(context).colorScheme.error,),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Password tidak cocok'), backgroundColor: Theme.of(context).colorScheme.error,),
      );
      return;
    }
    
    Widget nextScreen;
    if (widget.role == 'pembeli') {
      nextScreen = const BuyerHomeScreen(title: 'Beranda Pembeli');
    } else {
      nextScreen = const FarmerHomeScreen(title: 'Lapak Saya');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => nextScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Daftar Akun ${widget.role == 'pembeli' ? 'Pembeli' : 'Petani'}'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onBackground),
          onPressed: () => Navigator.pop(context), // Kembali ke LoginScreen
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.role == 'pembeli' ? Icons.person_add_alt_1_outlined : Icons.nature_people_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Daftar sebagai ${widget.role == 'pembeli' ? 'Pembeli' : 'Petani'}',
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.bold, 
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Cth: Budi Santoso',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Cth: email@contoh.com',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'Min. 8 karakter',
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    hintText: 'Ulangi password',
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: _register,
                    child: const Text(
                      'Daftar',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen(role: widget.role)),
                    );
                  },
                  child: const Text(
                    'Sudah punya akun? Login di sini',
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