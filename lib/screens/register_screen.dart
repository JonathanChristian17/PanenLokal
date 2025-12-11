import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'buyer_home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMsg("Semua field harus diisi!", true);
      return;
    }

    if (password != confirmPassword) {
      _showMsg("Password tidak cocok!", true);
      return;
    }

    setState(() => loading = true);

    UserModel? user = await AuthService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    setState(() => loading = false);

    if (user != null) {
      _showMsg("Register Berhasil!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BuyerHomeScreen(title: "Beranda Pembeli"),
        ),
      );
    } else {
      _showMsg("Register gagal, cek kembali data Anda!", true);
    }
  }

  void _showMsg(String msg, [bool error = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [

                Image.asset('assets/images/panenlokal_logo.png', height: 100),
                const SizedBox(height: 20),

                _input("Nama Lengkap", Icons.person, nameController),
                const SizedBox(height: 15),
                _input("Email", Icons.email, emailController),
                const SizedBox(height: 15),
                _input("Nomor HP", Icons.phone, phoneController, type: TextInputType.phone),
                const SizedBox(height: 15),
                _input("Password", Icons.lock, passwordController, hidden: true, obscurePassword: obscurePassword, onTogglePassword: () => setState(() => obscurePassword = !obscurePassword)),
                const SizedBox(height: 15),
                _input("Konfirmasi Password", Icons.lock_outline, confirmPasswordController, hidden: true, obscurePassword: obscurePassword, onTogglePassword: () => setState(() => obscurePassword = !obscurePassword)),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: loading ? null : _register,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Daftar Sekarang", style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: Text("Login",
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _input(String label, IconData icon, TextEditingController c,
      {bool hidden = false, TextInputType type = TextInputType.text, bool obscurePassword = false, VoidCallback? onTogglePassword}) {
    return TextField(
      controller: c,
      obscureText: obscurePassword,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: hidden && onTogglePassword != null
            ? IconButton(
                icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: onTogglePassword,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  }