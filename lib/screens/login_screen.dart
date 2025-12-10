import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'register_screen.dart';
import 'buyer_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> handleLogin() async {
    String email = emailController.text.trim();
    String pass = passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email dan password wajib diisi")));
      return;
    }

    setState(() => isLoading = true);

    try {
      UserModel? user =
          await AuthService.login(email: email, password: pass);

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email / Password salah")));
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const BuyerHomeScreen(title: "Beranda Pembeli")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/panenlokal_logo.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (_, __, ___) => Icon(Icons.storefront_rounded,
                      size: 100, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 25),
                Text("Selamat Datang 👋",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor)),
                Text("Masuk untuk melanjutkan",
                    style:
                        TextStyle(fontSize: 15, color: Colors.grey[600])),
                const SizedBox(height: 40),

                /// EMAIL
                inputField(
                  controller: emailController,
                  icon: Icons.email_outlined,
                  label: "Email",
                  hint: "email@contoh.com",
                ),
                const SizedBox(height: 15),

                /// PASSWORD
                inputField(
                  controller: passwordController,
                  icon: Icons.lock_outline,
                  label: "Password",
                  hint: "•••••••••",
                  isPassword: true,
                  obscureText: obscurePassword,
                  togglePassword: () =>
                      setState(() => obscurePassword = !obscurePassword),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor:
                            Theme.of(context).primaryColor),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text("Masuk",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen())),
                      child: Text("Daftar",
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold)),
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

  Widget inputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hint,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? togglePassword,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscureText ?? true : false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon((obscureText ?? true)
                    ? Icons.visibility_off
                    : Icons.visibility),
                onPressed: togglePassword,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
