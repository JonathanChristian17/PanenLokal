import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isBuyer;
  const EditProfileScreen({super.key, this.isBuyer = false});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController waController = TextEditingController();
  final TextEditingController igController = TextEditingController();
  final TextEditingController fbController = TextEditingController();
  final TextEditingController sloganController = TextEditingController(); // New Field
  final TextEditingController locationController = TextEditingController();

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
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition();

    setState(() {
      locationController.text = "${pos.latitude}, ${pos.longitude}";
    });
  }

  void saveProfile() {
    if (usernameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username tidak boleh kosong!")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profil berhasil disimpan!")),
    );
  }

  void submitVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pengajuan verifikasi dikirim!")),
    );
  }

  // Reusable Shadow Input
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(widget.isBuyer ? "Edit Profil" : "Edit Profil Petani", style: const TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar Section
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                   Container(
                     padding: const EdgeInsets.all(4),
                     decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 2)),
                     child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green.shade50,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
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

            // Slogan Field (New)
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
                controller: igController,
                decoration: _inputDecoration(icon: Icons.camera_alt_outlined, hint: "Instagram (Opsional)"),
              ),
            ),
             
            _buildShadowedInput(
              child: TextFormField(
                controller: fbController,
                decoration: _inputDecoration(icon: Icons.facebook, hint: "Facebook (Opsional)"),
              ),
            ),

            _buildShadowedInput(
              child: TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                   prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.location_on, color: Color(0xFF1B5E20), size: 20),
                    ),
                  ),
                  labelText: "Lokasi Anda",
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

            // Save Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1B5E20).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: ElevatedButton(
                onPressed: saveProfile,
                 style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                child: const Text("SIMPAN PERUBAHAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

