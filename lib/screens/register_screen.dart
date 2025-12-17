import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'main_nav_screen.dart';
import '../services/notification_service.dart';
import '../services/local_notification_service.dart';

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
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
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
      await LocalNotificationService.showNotification(
        title: "Selamat Datang 🎉",
        body: "Hai ${user.fullName}, selamat bergabung di Panen Lokal!",
      );
      // Tambahkan notifikasi selamat datang ke list
       NotificationService.addNotification(
        userKey: user.email,
        title: "Selamat Datang",
        message: "Hai ${user.fullName}, selamat bergabung!",
      );

      // Tampilkan pop-up langsung
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Selamat Datang!"),
          content: Text("Hai ${user.fullName}, selamat bergabung!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      // Tampilkan snack bar
      _showMsg("Register Berhasil!");

      // Navigasi ke halaman utama
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
      );
    } else {
      _showMsg("Register gagal, cek kembali data Anda!", true);
    }
  }

  void _showMsg(String msg, [bool error = false]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : Colors.green,
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
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onBackground,
          ),
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
                _input(
                  "Nomor HP",
                  Icons.phone,
                  phoneController,
                  type: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                _input(
                  "Password",
                  Icons.lock,
                  passwordController,
                  hidden: true,
                  obscurePassword: obscurePassword,
                  onTogglePassword: () =>
                      setState(() => obscurePassword = !obscurePassword),
                ),
                const SizedBox(height: 15),
                _input(
                  "Konfirmasi Password",
                  Icons.lock_outline,
                  confirmPasswordController,
                  hidden: true,
                  obscurePassword: obscurePassword,
                  onTogglePassword: () =>
                      setState(() => obscurePassword = !obscurePassword),
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: loading ? null : _register,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Daftar Sekarang",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    String label,
    IconData icon,
    TextEditingController c, {
    bool hidden = false,
    TextInputType type = TextInputType.text,
    bool obscurePassword = false,
    VoidCallback? onTogglePassword,
  }) {
    return TextField(
      controller: c,
      obscureText: obscurePassword,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: hidden && onTogglePassword != null
            ? IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
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
