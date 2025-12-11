import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'verification_form_screen.dart';
import 'buyer_home_screen.dart';
import 'farmer_home_screen.dart';
import 'farmer/farmer_reviews_screen.dart';
import '../services/verification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String verificationStatus = "loading";
  UserModel? user;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await AuthService.getUserData();      
      if (data == null) {
        throw Exception("User data is null");
      }
      String status = "none";
      try {
        status = await VerificationService.getStatus();
      } catch (e) {
        print("⚠️ ERROR GET VERIFICATION STATUS: $e");
      }

      if (mounted) {
        setState(() {
          user = data;
          verificationStatus = status;
          isLoading = false;
          errorMessage = null;
        });
      }
      
      print("✅ LOAD USER DATA BERHASIL");
    } catch (e) {
      print("❌ ERROR LOAD USER DATA: $e");
      
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = e.toString();
        });

        // Tampilkan dialog error sebelum redirect
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text("Sesi Berakhir"),
            content: const Text(
              "Sesi login Anda telah berakhir. Silakan login kembali.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tidak"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("Ya"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                "Gagal memuat data user",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? "Terjadi kesalahan",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                  });
                  _loadUserData();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Coba Lagi"),
              ),
            ],
          ),
        ),
      );
    }

    bool isBuyer = user!.role == "buyer";

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildVerificationBox(),
              const SizedBox(height: 20),
              if (isBuyer) _buildRoleSwitchCard(context, isBuyer),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "MENU AKUN",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildMenuItems(isBuyer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    const String defaultAvatar =
        "https://cdn-icons-png.flaticon.com/512/3135/3135715.png";

    final String avatarUrl = (user!.avatarUrl?.isNotEmpty == true)
        ? user!.avatarUrl!
        : defaultAvatar;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: user!.verified ? Colors.blue : Colors.green,
                      width: 3),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(avatarUrl),
                  backgroundColor: const Color(0xFFE8F5E9),
                ),
              ),
              if (user!.verified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4)
                      ],
                    ),
                    child: const Icon(Icons.verified,
                        color: Colors.white, size: 20),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(user!.fullName,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20))),
          const SizedBox(height: 4),
          Text(
              user!.slogan ??
                  (user!.role == "farmer"
                      ? "Petani • Sejak 2018"
                      : "Pembeli"),
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildVerificationBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: user!.verified
                  ? [Colors.blue.shade50, Colors.blue.shade100]
                  : [Colors.orange.shade50, Colors.orange.shade100]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: user!.verified
                  ? Colors.blue.shade200
                  : Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(
                user!.verified
                    ? Icons.verified_user
                    : Icons.gpp_maybe_rounded,
                color: user!.verified
                    ? Colors.blue.shade700
                    : Colors.orange.shade800,
                size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      user!.verified
                          ? "Akun Terverifikasi"
                          : "Belum Terverifikasi",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: user!.verified
                              ? Colors.blue.shade900
                              : Colors.orange.shade900)),
                  const SizedBox(height: 4),
                  Text(
                      user!.verified
                          ? "Anda adalah penjual terpercaya."
                          : "Ajukan verifikasi untuk meningkatkan kepercayaan.",
                      style: TextStyle(
                          fontSize: 12,
                          color: user!.verified
                              ? Colors.blue.shade800
                              : Colors.orange.shade900)),
                ],
              ),
            ),
            if (!user!.verified)
              InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: const Text("Manfaat Verifikasi"),
                            content: const Text(
                                "✅ Tanda Centang Biru\n✅ Prioritas Listing\n✅ Kepercayaan Meningkat\n✅ Proteksi Akun"),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("OK"))
                            ],
                          ));
                },
                child: const Icon(Icons.info_outline, color: Colors.orange),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSwitchCard(BuildContext context, bool isBuyer) {
    String title = "Mulai Jualan Sebagai Petani";
    String subtitle = "Pasarkan hasil panenmu ke ribuan pembeli!";
    IconData icon = Icons.agriculture;
    List<Color> gradientColors = [
      const Color(0xFF2E7D32),
      const Color(0xFF43A047)
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: gradientColors[0].withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const VerificationFormScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.5), width: 1.5),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItems(bool isBuyer) {
    return Column(
      children: [
        _buildMenuCard(
          icon: Icons.person_outline,
          title: "Edit Profil",
          subtitle: "Ubah foto, nama, bio",
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditProfileScreen(isBuyer: isBuyer)),
            );

            if (result == true && mounted) {
              setState(() {
                isLoading = true;
              });
              await _loadUserData();
            }
          },
        ),
        if (!isBuyer)
          _buildMenuCard(
            icon: Icons.star_half_rounded,
            title: "Ulasan Pembeli",
            subtitle: "Lihat rating & komentar pelanggan",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FarmerReviewsScreen())),
          ),
        _buildMenuCard(
          icon: Icons.verified_outlined,
          title: "Ajukan Verifikasi",
          subtitle: "Upload KTP & Data Diri",
          iconColor: Colors.blue,
          onTap: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const VerificationFormScreen()));
            // Reload setelah kembali dari form verifikasi
            if (mounted) {
              setState(() {
                isLoading = true;
              });
              await _loadUserData();
            }
          },
        ),
        _buildMenuCard(
            icon: Icons.settings_outlined,
            title: "Pengaturan Aplikasi",
            onTap: () {}),
        _buildMenuCard(
            icon: Icons.help_outline, title: "Pusat Bantuan", onTap: () {}),
        _buildMenuCard(
            icon: Icons.logout,
            title: "Log Out",
            isDestructive: true,
            onTap: _handleLogout),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 4,
              offset: const Offset(0, 2)),
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: 2),
        ],
      ),
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300, width: 2.0),
        ),
        child: InkWell(
          onTap: onTap,
          splashColor:
              (isDestructive ? Colors.red : Colors.green).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDestructive
                            ? Colors.red
                            : (iconColor ?? const Color(0xFF1B5E20)))
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon,
                      color: isDestructive
                          ? Colors.red
                          : (iconColor ?? const Color(0xFF1B5E20)),
                      size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDestructive
                                  ? Colors.red
                                  : Colors.black87)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle,
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}