// File baru: lib/screens/farmer/verification_flow_screen.dart

import 'package:flutter/material.dart';

class VerificationFlowScreen extends StatefulWidget {
  const VerificationFlowScreen({super.key});

  @override
  State<VerificationFlowScreen> createState() => _VerificationFlowScreenState();
}

class _VerificationFlowScreenState extends State<VerificationFlowScreen> {
  int _currentStep = 0;

  final List<String> _steps = ['Manfaat Verifikasi', 'Formulir Detail', 'Konfirmasi Pengajuan'];

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildManfaatVerifikasi(); // ➡️ Manfaat Verifikasi
      case 1:
        return _buildFormVerifikasi(); // ➡️ FORM VERIFIKASI
      case 2:
        return _buildKonfirmasiKirim(); // ➡️ KONFIRMASI KIRIM
      default:
        return Container();
    }
  }

  // Isi: Manfaat Verifikasi
  Widget _buildManfaatVerifikasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mengapa Verifikasi Penting?',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 15),
        const Text('1. Kepercayaan Pembeli Tinggi', style: TextStyle(fontSize: 16)),
        const Text('2. Akses ke Fitur Lelang Premium', style: TextStyle(fontSize: 16)),
        const Text('3. Prioritas Tampilan di Beranda', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentStep = 1; // ➡️ Lanjut ke Form
            });
          },
          child: const Text('Mulai Verifikasi'), // ➡️ 'Mulai Verifikasi'
        ),
      ],
    );
  }

  // Isi: Form Verifikasi
Widget _buildFormVerifikasi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Detail Ladang dan Legalitas',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),

        // Hapus 'const' dan pastikan TextField tidak error
        TextField(decoration: const InputDecoration(labelText: 'Nama Ladang/Usaha')),
        const SizedBox(height: 15),
        
        TextField(decoration: const InputDecoration(labelText: 'Nomor Izin Usaha/KTP')),
        const SizedBox(height: 15),
        
        // ✅ PERBAIKAN UTAMA: Pindahkan maxLines keluar dari InputDecoration
        TextField(
          decoration: const InputDecoration(labelText: 'Alamat Lengkap Ladang'), 
          maxLines: 3, // <<< PARAMETER maxLines YANG BENAR
        ), 
        
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            // Logika validasi dan Kirim Pengajuan
            setState(() {
              _currentStep = 2; // ➡️ Lanjut ke Konfirmasi
            });
          },
          child: const Text('Kirim Pengajuan'), // ➡️ 'Kirim Pengajuan'
        ),
      ],
    );
}

  // Isi: Konfirmasi Kirim
  Widget _buildKonfirmasiKirim() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 100, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          const Text(
            'Pengajuan Berhasil Dikirim!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Pengajuan Anda akan ditinjau dalam 1-3 hari kerja.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Kembali ke Profil Status
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status profil diperbarui: Menunggu Verifikasi'))
              );
            },
            child: const Text('Kembali ke Profil'), // ➡️ 'Kembali ke Profil'
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alur Verifikasi Petani'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Gunakan Stepper untuk visualisasi alur
            Stepper(
              physics: const NeverScrollableScrollPhysics(), 
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              controlsBuilder: (context, details) {
                // Sembunyikan kontrol default Stepper
                return Container();
              },
              steps: _steps.map((title) {
                int index = _steps.indexOf(title);
                return Step(
                  title: Text(title),
                  content: _getStepContent(),
                  isActive: _currentStep >= index,
                  state: _currentStep > index ? StepState.complete : StepState.indexed,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}