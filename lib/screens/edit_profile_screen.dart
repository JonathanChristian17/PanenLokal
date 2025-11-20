import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _image;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController waController = TextEditingController();
  final TextEditingController igController = TextEditingController();
  final TextEditingController fbController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                TextButton(
                  onPressed: pickImage,
                  child: const Text("Ubah Foto"),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Username
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: "Username",
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 15),

          // WA
          TextField(
            controller: waController,
            decoration: const InputDecoration(
              labelText: "Nomor WhatsApp",
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          const SizedBox(height: 15),

          // IG
          TextField(
            controller: igController,
            decoration: const InputDecoration(
              labelText: "Instagram",
              prefixIcon: Icon(Icons.camera_alt),
            ),
          ),
          const SizedBox(height: 15),

          // FB
          TextField(
            controller: fbController,
            decoration: const InputDecoration(
              labelText: "Facebook",
              prefixIcon: Icon(Icons.facebook),
            ),
          ),
          const SizedBox(height: 15),

          // Lokasi
          TextField(
            controller: locationController,
            decoration: InputDecoration(
              labelText: "Lokasi Anda",
              prefixIcon: const Icon(Icons.location_on),
              suffixIcon: IconButton(
                onPressed: getLocation,
                icon: const Icon(Icons.gps_fixed),
              ),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: saveProfile,
            child: const Text("Simpan Perubahan"),
          ),
          const SizedBox(height: 15),


        ],
      ),
    );
  }
}
