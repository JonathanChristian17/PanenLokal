import 'edit_profile_screen.dart';
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:permission_handler/permission_handler.dart'; 
import 'login_screen.dart'; 
import 'pilihan_peran_screen.dart'; // Untuk log out ke pilihan peran

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;

  // --- LOGIKA PERIZINAN DAN PEMILIHAN GAMBAR (Dilewati untuk keringkasan) ---
  // Pastikan Anda mengimplementasikan ini dengan benar di aplikasi nyata
  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      _showPermissionDeniedDialog(context);
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPermissionDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Ditolak'),
          content: const Text('Aplikasi memerlukan akses ke kamera atau galeri Anda untuk mengganti foto profil.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Pengaturan'),
              onPressed: () {
                openAppSettings(); // Buka pengaturan aplikasi
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // --- END LOGIKA PERIZINAN DAN PEMILIHAN GAMBAR ---

  Widget _buildProfileAvatar(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 40, // Lebih besar
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2), // Warna disesuaikan
            backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
            child: _selectedImage == null ?
              Icon(Icons.person, size: 48, color: Theme.of(context).colorScheme.primary) : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                _showImageSourceActionSheet(context);
              },
              child: CircleAvatar(
                radius: 15, // Sedikit lebih besar
                backgroundColor: Theme.of(context).colorScheme.secondary, // Warna aksen
                child: const Icon(Icons.edit, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profil Saya'), 
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            onPressed: () {
              // Tampilkan dialog konfirmasi logout
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Konfirmasi Log Out'),
                    content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(), // Tutup dialog (Batal)
                        child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                          
                          // Navigasi ke LoginScreen
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false, // Hapus semua route sebelumnya agar tidak bisa back
                          );
                        },
                        child: const Text('Log Out'),
                      ),
                    ],
                  );
                },
              );
            },
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildProfileAvatar(context), 
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Agus Tani Makmur', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('ID: 12345 | Lokasi: Bandungan', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                        const SizedBox(height: 6),
                        Text('Menjual wortel dan sayuran organik. Aktif sejak 2020.', 
                             style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.primary), 
                             maxLines: 2, 
                             overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildProfileMenuItem(
            context,
            icon: Icons.edit_note,
            title: 'Edit Profil & Verifikasi Bio',
            subtitle: 'Perbarui foto, informasi kontak (WA/IG/FB) dan lokasi Anda.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),

            _buildProfileMenuItem(
              context,
              icon: Icons.settings,
              title: 'Pengaturan Aplikasi',
              subtitle: 'Atur notifikasi lelang, preferensi wilayah, dan privasi.',
              onTap: () {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Halaman Pengaturan'), backgroundColor: Theme.of(context).colorScheme.primary,));}
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.history,
              title: 'Riwayat Penawaran & Transaksi',
              subtitle: 'Lihat daftar lelang/tawaran yang berhasil dan gagal.',
              onTap: () {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Halaman Riwayat'), backgroundColor: Theme.of(context).colorScheme.primary,));}
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.help_outline,
              title: 'Bantuan & Dukungan',
              onTap: () {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Halaman Bantuan'), backgroundColor: Theme.of(context).colorScheme.primary,));}
            ),
            _buildProfileMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              onTap: () {ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Halaman Tentang Aplikasi'), backgroundColor: Theme.of(context).colorScheme.primary,));}
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, {required IconData icon, required String title, String? subtitle, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)) : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}