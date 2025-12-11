import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 🔥 TAMBAH INI
import 'profile_screen.dart';
import '../services/verification_service.dart';



 class VerificationFormScreen extends StatefulWidget {
  const VerificationFormScreen({super.key});

  @override
  State<VerificationFormScreen> createState() => _VerificationFormScreenState();
 }

 class _VerificationFormScreenState extends State<VerificationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
    // 🔥 GANTI: Simpan sebagai XFile agar bisa dibaca bytes-nya di Web, atau File di Mobile
  File? _ktpImage; // Tetap File untuk Image.file di build
    XFile? _ktpImageXFile; // 🔥 Simpan XFile yang sebenarnya

  // Reusable Shadow Input (Copied for consistency, or extract later)
  Widget _buildShadowedInput({required Widget child}) {
   // ... (Kode _buildShadowedInput tetap sama)
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
   // ... (Kode _inputDecoration tetap sama)
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
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
  }

  Future<void> _pickKtpImage() async {
   final picker = ImagePicker();
   final picked = await picker.pickImage(source: ImageSource.gallery);
   if (picked != null) {
    setState(() {
          _ktpImageXFile = picked; // 🔥 SIMPAN XFILE
          // Jika tidak di Web, buat File untuk ditampilkan secara lokal
          if (!kIsWeb) {
            _ktpImage = File(picked.path);
          }
        });
   }
  }

  void _submitVerification() {
      // 🔥 Periksa XFile, bukan File.
   if (_formKey.currentState!.validate() && _ktpImageXFile != null) {
    showDialog(
     context: context,
     builder: (ctx) => AlertDialog(
      title: const Text("Konfirmasi Pengajuan"),
      content: const Text("Pastikan data Anda benar. Data akan diverifikasi dalam 1x24 jam."),
      actions: [
       TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
       ElevatedButton(
        onPressed: () async {
         Navigator.pop(ctx); // tutup dialog

                    // 🔥 KIRIM XFile ke service
         bool success = await VerificationService.uploadVerification(
           fullName: _nameController.text,
           nik: _nikController.text,
           address: _addressController.text,
           ktpImageXFile: _ktpImageXFile!, // 🔥 GANTI PARAMETER
         );

         if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Pengajuan Berhasil Dikirim!")),
          );

          Navigator.pushReplacement(
           context,
           MaterialPageRoute(builder: (_) => const ProfileScreen()),
          );
         } else {
          ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Gagal mengirim ke server!")),
          );
         }
        },
        child: const Text("Kirim Pengajuan"),
       )
      ],
     ),
    );
   } else if (_ktpImageXFile == null) { // 🔥 Periksa XFile
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto KTP Wajib Diupload!")));
   }
  }
    // ... (Metode build)
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.background,
    body: SafeArea(
     child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
       key: _formKey,
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
         // Custom Scrollable Header
                  // ... (Header Row remains the same)
         Row(
          children: [
            IconButton(
             icon: const Icon(Icons.arrow_back, color: Colors.black),
             onPressed: () {
              Navigator.pushReplacement(
               context,
               MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
             },
            ),

           
           const Expanded(
            child: Text(
             "Form Verifikasi",
             textAlign: TextAlign.center,
             style: TextStyle(fontSize: 20, color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
            ),
           ),
           const SizedBox(width: 48), // Balance BackButton
           
          ],
         ),
         const SizedBox(height: 24),
        // Info Box
                  // ... (Info box remains the same)
        Container(
         padding: const EdgeInsets.all(16),
         decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade200),
         ),
         child: Row(
          children: [
           Icon(Icons.verified_user, color: Colors.blue.shade700, size: 32),
           const SizedBox(width: 12),
           Expanded(
            child: Text(
             "Verifikasi meningkatkan kepercayaan dan membuka fitur eksklusif.",
             style: TextStyle(color: Colors.blue.shade900, fontSize: 13),
            ),
           )
          ],
         ),
        ),
        const SizedBox(height: 24),
        
        _buildShadowedInput(
         child: TextFormField(
          controller: _nameController,
          decoration: _inputDecoration(icon: Icons.person, hint: "Nama Lengkap Sesuai KTP"),
          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
         ),
        ),
        _buildShadowedInput(
         child: TextFormField(
          controller: _nikController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(icon: Icons.badge, hint: "Nomor Induk Kependudukan (NIK)"),
          validator: (val) => val!.length != 16 ? "NIK harus 16 digit" : null,
         ),
        ),
        _buildShadowedInput(
         child: TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: _inputDecoration(icon: Icons.home, hint: "Alamat Lengkap"),
          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
         ),
        ),
        
        const SizedBox(height: 12),
        const Text("Foto KTP Sesuai Identitas", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 8),
        
        GestureDetector(
         onTap: _pickKtpImage,
         child: _buildShadowedInput(
          child: Container(
           height: 180,
           width: double.infinity,
           color: Colors.grey.shade50,
           alignment: Alignment.center,
                      // 🔥 KONDISIONAL UNTUK MENAMPILKAN GAMBAR
           child: _ktpImageXFile != null
                        ? kIsWeb
                          ? Image.network(_ktpImageXFile!.path, fit: BoxFit.cover, width: double.infinity)
                          : Image.file(_ktpImage!, fit: BoxFit.cover, width: double.infinity) // Gunakan _ktpImage yang sudah diinisialisasi
            : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade400),
               const SizedBox(height: 8),
               Text("Tap untuk Upload KTP", style: TextStyle(color: Colors.grey.shade500)),
              ],
             ),
          ),
         ),
        ),
        
        const SizedBox(height: 30),
        
        // Submit Button (Layered)
        Container(
         decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
           BoxShadow(color: const Color(0xFF1B5E20).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
          ],
         ),
         child: ElevatedButton(
          onPressed: _submitVerification,
          style: ElevatedButton.styleFrom(
           backgroundColor: const Color(0xFF1B5E20),
           padding: const EdgeInsets.symmetric(vertical: 16),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
           elevation: 0,
          ),
          child: const Text("KIRIM PENGAJUAN", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
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