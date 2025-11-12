// File baru: lib/screens/farmer/listing_flow_screen.dart

import 'package:flutter/material.dart';

class ListingFlowScreen extends StatefulWidget {
  const ListingFlowScreen({super.key});

  @override
  State<ListingFlowScreen> createState() => _ListingFlowScreenState();
}

class _ListingFlowScreenState extends State<ListingFlowScreen> {
  int _currentStep = 0;
  String _selectedMethod = 'Per-KG'; // Default: Harga (Per-KG)

  final List<String> _steps = ['Info Komoditas', 'Metode Jual', 'Konfirmasi Listing'];

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildFormIklanInfo(); // ➡️ FORM IKLAN (INFO)
      case 1:
        return _buildFormMetodeJual(); // ➡️ FORM (METODE JUAL)
      case 2:
        return _buildKonfirmasiListing(); // ➡️ KONFIRMASI LISTING
      default:
        return Container();
    }
  }

  // Isi: Form Iklan (INFO)
  Widget _buildFormIklanInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Detail Produk', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const TextField(decoration: InputDecoration(labelText: 'Nama Komoditas (Cth: Bawang Merah Brebes)')),
        const SizedBox(height: 15),
        const TextField(decoration: InputDecoration(labelText: 'Kuantitas Tersedia (Ton/Kg)')),
        const SizedBox(height: 15),
        const TextField(decoration: InputDecoration(labelText: 'Lokasi Panen')),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentStep = 1; // ➡️ Lanjut
            });
          },
          child: const Text('Lanjut'), // ➡️ 'Lanjut'
        ),
      ],
    );
  }

  // Isi: Form Metode Jual
  Widget _buildFormMetodeJual() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Pilih Metode Penjualan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        // ➡️ Pilih Metode Jual?
        RadioListTile<String>(
          title: const Text('Harga (Per-KG)'), // ➡️ Harga (Per-KG)
          subtitle: const Text('Penjualan ritel atau dalam jumlah kecil.'),
          value: 'Per-KG',
          groupValue: _selectedMethod,
          onChanged: (val) {
            setState(() {
              _selectedMethod = val!;
            });
          },
        ),
        RadioListTile<String>(
          title: const Text('Harga Borongan'), // ➡️ Harga Borongan
          subtitle: const Text('Penjualan seluruh hasil panen sekaligus.'),
          value: 'Borongan',
          groupValue: _selectedMethod,
          onChanged: (val) {
            setState(() {
              _selectedMethod = val!;
            });
          },
        ),
        const SizedBox(height: 20),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Isi Harga (${_selectedMethod == 'Per-KG' ? 'per Kg' : 'Total Borongan'})',
          ),
        ), // ➡️ Isi Harga & Lanjut
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentStep = 2; // ➡️ Lanjut ke Konfirmasi Listing
            });
          },
          child: const Text('Lanjut ke Konfirmasi'),
        ),
      ],
    );
  }

  // Isi: Konfirmasi Listing
  Widget _buildKonfirmasiListing() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 20),
          const Text(
            'Konfirmasi Listing Anda',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Metode Jual: $_selectedMethod',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Logika Publikasikan
              _showSuccessPopup(context);
            },
            child: const Text('Publikasikan Sekarang'), // ➡️ 'Publikasikan'
          ),
        ],
      ),
    );
  }

  void _showSuccessPopup(BuildContext context) {
    // ➡️ Pop-up Sukses
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sukses!'),
        content: const Text('Listing Anda berhasil dipublikasikan dan kini tayang di beranda pembeli.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(); // Selesai
            },
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posting Listing Komoditas'),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 1,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) => setState(() => _currentStep = step),
        controlsBuilder: (context, details) {
          return Container(); // Sembunyikan kontrol Stepper default
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
    );
  }
}