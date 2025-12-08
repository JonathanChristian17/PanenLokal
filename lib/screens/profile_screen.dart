import 'edit_profile_screen.dart';
import 'verification_form_screen.dart';
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'login_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  final bool isBuyer;
  const ProfileScreen({super.key, this.isBuyer = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock Data
  bool _isVerified = false; // Status Verifikasi
  
  // Reusable Layered Card
  // (Method moved to bottom for better organization)
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
               Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false, 
              );
            }, 
            child: const Text("Log Out", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // Reverted to Theme
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // Space for Navbar
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             // 1. AESTHETIC HEADER
             Container(
               padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                 boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
               ),
               child: Column(
                 children: [
                   // Avatar with Status Badge
                   Stack(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(4),
                         decoration: BoxDecoration(
                           shape: BoxShape.circle,
                           border: Border.all(color: _isVerified ? Colors.blue : Colors.green, width: 3),
                         ),
                         child: const CircleAvatar(
                           radius: 50,
                           backgroundImage: NetworkImage("https://cdn-icons-png.flaticon.com/512/3135/3135715.png"), // Placeholder Avatar
                           backgroundColor: Color(0xFFE8F5E9),
                         ),
                       ),
                       if (_isVerified)
                         Positioned(
                           bottom: 0, right: 0,
                           child: Container(
                             padding: const EdgeInsets.all(6),
                             decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                             child: const Icon(Icons.verified, color: Colors.white, size: 20),
                           ),
                         ),
                     ],
                   ),
                   const SizedBox(height: 16),
                   
                   // Name & Creative Bio
                   const Text("Agus Tani Makmur", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                   const SizedBox(height: 4),
                   Text("Petani Sayur Organik • Sejak 2018", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                   const SizedBox(height: 8),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     decoration: BoxDecoration(color: const Color(0xFFF1F8E9), borderRadius: BorderRadius.circular(20)),
                     child: Text(
                       '"Menanam dengan hati, memanen br/kualitas."',
                       style: TextStyle(fontStyle: FontStyle.italic, color: Colors.green.shade800, fontSize: 12),
                       textAlign: TextAlign.center,
                     ),
                   ),
                 ],
               ),
             ),

             const SizedBox(height: 20),

             // 2. VERIFICATION STATUS BOX
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(colors: _isVerified ? [Colors.blue.shade50, Colors.blue.shade100] : [Colors.orange.shade50, Colors.orange.shade100]),
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: _isVerified ? Colors.blue.shade200 : Colors.orange.shade200),
                 ),
                 child: Row(
                   children: [
                     Icon(_isVerified ? Icons.verified_user : Icons.gpp_maybe_rounded, color: _isVerified ? Colors.blue.shade700 : Colors.orange.shade800, size: 36),
                     const SizedBox(width: 16),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             _isVerified ? "Akun Terverifikasi" : "Belum Terverifikasi",
                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _isVerified ? Colors.blue.shade900 : Colors.orange.shade900),
                           ),
                           const SizedBox(height: 4),
                           Text(
                             _isVerified ? "Anda adalah penjual terpercaya." : "Ajukan verifikasi untuk meningkatkan kepercayaan.",
                             style: TextStyle(fontSize: 12, color: _isVerified ? Colors.blue.shade800 : Colors.orange.shade900),
                           ),
                         ],
                       ),
                     ),
                     if (!_isVerified)
                       InkWell(
                         onTap: () {
                            showDialog(context: context, builder: (ctx) => AlertDialog(
                              title: const Text("Manfaat Verifikasi"),
                              content: const Text("✅ Tanda Centang Biru\n✅ Prioritas Listing\n✅ Kepercayaan Meningkat\n✅ Proteksi Akun"),
                              actions: [TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("OK"))],
                            ));
                         },
                         child: const Icon(Icons.info_outline, color: Colors.orange),
                       )
                   ],
                 ),
               ),
             ),
             
             const SizedBox(height: 20),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: Text("MENU AKUN", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
             ),
             const SizedBox(height: 8),

             // 3. MENU ITEMS
             _buildMenuCard(
               icon: Icons.person_outline,
               title: "Edit Profil",
               subtitle: "Ubah foto, nama, slogan, dan biodata",
               onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(isBuyer: widget.isBuyer))),
             ),

             _buildMenuCard(
               icon: Icons.verified_outlined, 
               title: "Ajukan Verifikasi",
               subtitle: "Upload KTP & Data Diri",
               iconColor: Colors.blue,
               onTap: () async {
                 final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const VerificationFormScreen()));
                 if (result == true) {
                   setState(() { });
                 }
               },
             ),

             // REMOVED "Alamat & Lokasi" as requested

             const SizedBox(height: 10),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: Text("LAINNYA", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
             ),
             const SizedBox(height: 8),

             _buildMenuCard(
               icon: Icons.settings_outlined,
               title: "Pengaturan Aplikasi",
               onTap: () {},
             ),
             
             _buildMenuCard(
               icon: Icons.help_outline,
               title: "Pusat Bantuan",
               onTap: () {},
             ),

             _buildMenuCard(
               icon: Icons.logout,
               title: "Log Out",
               isDestructive: true,
               onTap: _handleLogout,
             ),
           ],
        ),
      ),
    );
  }

  // UPDATED WITH LAYERED SHADOW ARCHITECTURE (Shadow + Stroke)
  Widget _buildMenuCard({
    required IconData icon, 
    required String title, 
    String? subtitle, 
    required VoidCallback onTap,
    Color? iconColor,
    bool isDestructive = false
  }) {
    return Container(
      // 1. Shadow Layer (Outer)
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Shadow 1: Darker, tighter (Deep depth)
          BoxShadow(
            color: Colors.black.withOpacity(0.20), 
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0, 
          ),
          // Shadow 2: Softer, wider (Ambient)
          BoxShadow(
            color: Colors.black.withOpacity(0.12), 
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2, 
          ),
        ],
      ),
      // 2. Stroke & Content Layer (Inner)
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300, width: 2.0), // THICK STROKE
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: (isDestructive ? Colors.red : Colors.green).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDestructive ? Colors.red : (iconColor ?? const Color(0xFF1B5E20))).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: isDestructive ? Colors.red : (iconColor ?? const Color(0xFF1B5E20)), size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDestructive ? Colors.red : Colors.black87)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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

