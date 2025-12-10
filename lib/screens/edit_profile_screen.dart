import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:panen_lokal/services/profile_service.dart';
import 'package:panen_lokal/services/auth_service.dart';
import 'package:panen_lokal/models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isBuyer;
  const EditProfileScreen({super.key, this.isBuyer = false});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;
  String? _currentAvatarUrl; // URL avatar dari server
  final ProfileService _profileService = ProfileService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController waController = TextEditingController();
  final TextEditingController sloganController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  
  bool _isSaving = false;
  bool _isLoading = true; // 🔥 Tambahan: Status loading data

  @override
  void initState() {
    super.initState();
    _loadUserData(); // 🔥 Load data user saat halaman dibuka
  }

  // 🔥 FUNGSI BARU: Load data user dari API
  Future<void> _loadUserData() async {
    try {
      final UserModel? user = await AuthService.getUserData();
      
      if (user != null && mounted) {
        setState(() {
          usernameController.text = user.fullName;
          waController.text = user.phone;
          sloganController.text = user.slogan ?? '';
          
          // Format lokasi jika ada
          if (user.latitude != null && user.longitude != null && 
              user.latitude!.isNotEmpty && user.longitude!.isNotEmpty) {
            locationController.text = "${user.latitude}, ${user.longitude}";
          }
          
          _currentAvatarUrl = user.avatarUrl;
          _isLoading = false;
        });
        
        // 🔥 DEBUG: Print untuk cek data
        print('✅ Data loaded:');
        print('Name: ${user.fullName}');
        print('Phone: ${user.phone}');
        print('Slogan: ${user.slogan}');
        print('Avatar: ${user.avatarUrl}');
        print('Lat: ${user.latitude}, Long: ${user.longitude}');
      } else {
        print('❌ User data is null');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e")),
        );
      }
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> getLocation() async {
    setState(() {
      locationController.text = "Mengambil lokasi...";
    });
    
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Izin lokasi ditolak.")),
          );
          setState(() {
            locationController.text = "";
          });
        }
        return;
      }
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );

      setState(() {
        locationController.text = "${pos.latitude}, ${pos.longitude}";
      });
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal mendapatkan lokasi: $e")),
        );
        setState(() {
          locationController.text = "";
        });
      }
    }
  }

  void saveProfile() async {
    if (_isSaving) return;
    
    if (usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama Lengkap tidak boleh kosong!")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    String? lat, long;
    final locationText = locationController.text;
    if (locationText.isNotEmpty && !locationText.contains("Mengambil")) {
      try {
        final parts = locationText.split(', ');
        if (parts.length == 2) {
          lat = parts[0].trim();
          long = parts[1].trim();
        }
      } catch (e) {
        // Ignore parsing errors
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Menyimpan profil..."), duration: Duration(seconds: 30))
    );

    final response = await _profileService.updateProfile(
      fullName: usernameController.text,
      slogan: sloganController.text.isNotEmpty ? sloganController.text : null,
      phone: waController.text,
      latitude: lat,
      longitude: long,
      profileImage: _image,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message']), backgroundColor: Colors.green),
      );
      
      // 🔥 Reload data setelah berhasil update
      await _loadUserData();
      
      // Kembali ke halaman sebelumnya
      if (mounted) {
        Navigator.pop(context, true); // true = data berubah
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Terjadi kesalahan tidak dikenal.'), 
          backgroundColor: Colors.red
        ),
      );
    }

    setState(() {
      _isSaving = false;
    });
  }

  Widget _buildShadowedInput({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 4, offset: const Offset(0, 2)),
          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 15, offset: const Offset(0, 8), spreadRadius: 2),
        ],
      ),
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300, width: 2.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }

  InputDecoration _inputDecoration({required IconData icon, required String hint}) {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF1B5E20), size: 20),
        ),
      ),
      hintText: hint,
      labelText: hint,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Tampilkan loading saat data sedang dimuat
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  const BackButton(color: Colors.black),
                  Expanded(
                    child: Text(
                      widget.isBuyer ? "Edit Profil" : "Edit Profil Petani",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48), 
                ],
              ),
              const SizedBox(height: 20),

              // Avatar Section - 🔥 Tampilkan avatar dari server atau yang baru dipilih
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, 
                        border: Border.all(color: Colors.green, width: 2)
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.green.shade50,
                        backgroundImage: _image != null 
                          ? FileImage(_image!) // Gambar baru yang dipilih
                          : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                              ? NetworkImage(_currentAvatarUrl!) // Gambar dari server
                              : null),
                        child: (_image == null && (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty))
                          ? Icon(Icons.person, size: 60, color: Colors.green.shade200)
                          : null,
                      ),
                    ),
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF1B5E20), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildShadowedInput(
                child: TextFormField(
                  controller: usernameController,
                  decoration: _inputDecoration(icon: Icons.person, hint: "Nama Lengkap / Username"),
                ),
              ),

              _buildShadowedInput(
                child: TextFormField(
                  controller: sloganController,
                  decoration: _inputDecoration(icon: Icons.chat_bubble_outline, hint: "Slogan / Caption Profil"),
                ),
              ),
              
              _buildShadowedInput(
                child: TextFormField(
                  controller: waController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(icon: Icons.phone_android, hint: "Nomor WhatsApp"),
                ),
              ),

              _buildShadowedInput(
                child: TextFormField(
                  controller: locationController,
                  readOnly: true,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.location_on, color: Color(0xFF1B5E20), size: 20),
                      ),
                    ),
                    labelText: "Lokasi Anda (Latitude, Longitude)",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      onPressed: getLocation,
                      icon: const Icon(Icons.gps_fixed, color: Colors.blue),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF1B5E20).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isSaving ? null : saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isSaving 
                    ? const SizedBox(
                        width: 24, height: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                      )
                    : const Text("SIMPAN PERUBAHAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    waController.dispose();
    sloganController.dispose();
    locationController.dispose();
    super.dispose();
  }
}