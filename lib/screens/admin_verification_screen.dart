import 'package:flutter/material.dart';
import 'package:panen_lokal/models/verification_submission.dart';
import 'package:panen_lokal/services/admin_verification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminVerificationScreen extends StatefulWidget {
 const AdminVerificationScreen({super.key});

 @override
 State<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends State<AdminVerificationScreen> {
 final AdminVerificationService _service = AdminVerificationService();
 List<VerificationSubmission> _submissions = [];
 bool _isLoading = true;

 @override
 void initState() {
  super.initState();
  _fetchData();
 }

 Future<void> _fetchData() async {
  setState(() => _isLoading = true);
  try {
   final data = await _service.fetchPendingSubmissions();
   if (mounted) {
    setState(() {
     _submissions = data.where((s) => s.status == 'pending').toList();
     _isLoading = false;
    });
   }
  } catch (e) {
   if (mounted) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
   }
  }
 }

 Future<void> _handleAction(VerificationSubmission submission, String status) async {
  final bool isVerified = status == 'verified';
  String? note;
  
  if (!isVerified) {
    note = await _showNoteDialog(context);
    if (note == null) return; // Aksi dibatalkan
  }
  
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${isVerified ? "Memverifikasi" : "Menolak"} ${submission.fullName}...')));

  final success = await _service.updateVerificationStatus(
    submission.userId, 
    status, 
    note: note
  );

  if (mounted) {
   ScaffoldMessenger.of(context).hideCurrentSnackBar();
   if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status ${submission.fullName} berhasil diperbarui.'), backgroundColor: Colors.green)
    );
    _fetchData(); // Muat ulang data
   } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aksi gagal! Cek konsol atau koneksi.'), backgroundColor: Colors.red)
    );
   }
  }
 }

  // 🔥 FUNGSI UNTUK MEMBUKA URL KTP
  Future<void> _launchKtpUrl(String ktpImagePath) async {
    final Uri url = Uri.parse('http://127.0.0.1:8000/storage/$ktpImagePath');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) { // Gunakan externalApplication agar dibuka di browser baru
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal membuka URL: $url'))
            );
        }
    }
  }


 Future<String?> _showNoteDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
   context: context,
   builder: (ctx) => AlertDialog(
    title: const Text("Alasan Penolakan"),
    content: TextField(
     controller: controller,
     decoration: const InputDecoration(labelText: "Masukkan alasan (Wajib)"),
     maxLines: 3,
    ),
    actions: [
     TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text("Batal")),
     ElevatedButton(
      onPressed: () {
       if (controller.text.trim().isEmpty) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Alasan harus diisi!")));
       } else {
        Navigator.of(ctx).pop(controller.text.trim());
       }
      }, 
      child: const Text("Kirim Penolakan")
     ),
    ],
   ),
  );
 }

  // 🔥 WIDGET PEMBANTU UNTUK BARIS DETAIL
  Widget _buildDetailRow(String label, String value, {IconData? icon, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ),
          const Text(': ', style: TextStyle(color: Colors.black)),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: valueColor ?? Colors.black87))),
        ],
      ),
    );
  }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   backgroundColor: const Color(0xFFF9FBE7),
   appBar: AppBar(
    title: const Text("Verifikasi Petani Pending"),
    backgroundColor: Colors.white,
    elevation: 1,
    toolbarHeight: 60,
   ),
   body: _isLoading
     ? const Center(child: CircularProgressIndicator(color: Colors.blue))
     : _submissions.isEmpty
       ? Center(
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Icon(Icons.check_circle_outline, size: 60, color: Colors.green.shade400),
           const SizedBox(height: 16),
           const Text("Tidak ada pengajuan verifikasi pending.", style: TextStyle(fontSize: 16, color: Colors.grey)),
           const SizedBox(height: 16),
           ElevatedButton.icon(
            onPressed: _fetchData, 
            icon: const Icon(Icons.refresh, color: Colors.white), 
            label: const Text("Refresh", style: TextStyle(color: Colors.white))
           )
          ],
         ),
        )
       : ListView.builder( // 🔥 Gunakan ListView.builder untuk tampilan kartu yang rapi
         padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 100),
         itemCount: _submissions.length,
         itemBuilder: (context, index) {
          final sub = _submissions[index];
          return Card(
           elevation: 4,
           margin: const EdgeInsets.symmetric(vertical: 8),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
           child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
              Row(
               children: [
                const Icon(Icons.assignment_turned_in, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Expanded(
                 child: Text(
                  "Pengajuan #${index + 1}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                 ),
                ),
                Text("ID: ${sub.userId}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
               ],
              ),
              const Divider(height: 24),
              
              // DETAIL DATA
              _buildDetailRow("Nama Lengkap", sub.fullName, icon: Icons.person),
              _buildDetailRow("NIK", sub.nik, icon: Icons.badge),
              _buildDetailRow("Alamat", sub.address, icon: Icons.location_on),
              _buildDetailRow(
               "Email", 
               sub.user?.email ?? 'N/A', 
               icon: Icons.email,
               valueColor: Colors.blue.shade700
              ),
              const Divider(height: 24),

              // AKSI DAN KTP
              Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                ElevatedButton.icon(
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                 onPressed: () => _launchKtpUrl(sub.ktpImage),
                 icon: const Icon(Icons.file_copy, size: 18),
                 label: const Text('Lihat KTP', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Row(
                 children: [
                  OutlinedButton(
                   style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                   onPressed: () => _handleAction(sub, 'rejected'),
                   child: const Text('Tolak', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                   style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                   onPressed: () => _handleAction(sub, 'verified'),
                   child: const Text('Verifikasi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                 ],
                ),
               ],
              )
             ],
            ),
           ),
          );
         },
        ),
  );
 }
}