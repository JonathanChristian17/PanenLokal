import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io'; 
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:image_picker/image_picker.dart'; 
import 'package:panen_lokal/services/listing_service.dart';

// --- FORMATTER CLASS ---
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) { return newValue; }
    String oldText = oldValue.text.replaceAll('.', '');
    String newText = newValue.text.replaceAll('.', '');
    String newString = newText.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class PickedImageItem {
  final File? file;
  final XFile xFile;
  PickedImageItem({this.file, required this.xFile});
}

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({super.key});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ListingService _listingService = ListingService();
  bool _isLoading = false;

  final TextEditingController _commodityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); 
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _areaController = TextEditingController(); 
  String _selectedCategory = "sayur"; 
  String _salesMethod = "Timbang"; 
  final TextEditingController _priceController = TextEditingController(); 
  final TextEditingController _stockController = TextEditingController(); 
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  List<PickedImageItem> _pickedImageItems = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _commodityController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _contactNameController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (xFile != null) {
      File? file;
      if (!kIsWeb) {
        file = File(xFile.path);
      }
      setState(() {
        _pickedImageItems.add(PickedImageItem(file: file, xFile: xFile));
      });
    }
  }

  void _handlePublish() {
    if (_formKey.currentState!.validate() && _pickedImageItems.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Konfirmasi Listing"),
          content: Text(_pickedImageItems.isEmpty ? "Anda belum memilih foto. Apakah data sudah sesuai?" : "Apakah data ladang dan harga sudah sesuai? Listing akan dipublikasikan ke pembeli."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
            ElevatedButton(
              onPressed: _pickedImageItems.isEmpty ? null : () {
                Navigator.pop(ctx);
                _finalizeSubmission();
              }, 
              child: const Text("Ya, Publikasikan")
            ),
          ],
        ),
      );
    } else if (_pickedImageItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Minimal harus ada satu foto dokumentasi.")));
    }
  }

void _finalizeSubmission() async {
    if (_isLoading) return;

    setState(() { _isLoading = true; });

    // Parse dan validasi data
    final String stockText = _stockController.text.replaceAll('.', '').replaceAll(',', '.');
    final String priceText = _priceController.text.replaceAll('.', '');
    final String areaText = _areaController.text.replaceAll('.', '');
    
    final double finalStock = double.tryParse(stockText) ?? 0.0; 
    final double finalPrice = double.tryParse(priceText) ?? 0.0; 
    
    // Validasi data sebelum kirim
    if (finalStock <= 0 || finalPrice <= 0 || areaText.isEmpty) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pastikan semua data harga dan stok terisi dengan benar"), backgroundColor: Colors.red),
      );
      return;
    }

    // Prepare images
    final List<XFile> finalImages = _pickedImageItems.map((item) => item.xFile).toList();

    try {
      // Debug: Print data yang akan dikirim
      print("=== DATA YANG DIKIRIM ===");
      print("Title: ${_commodityController.text}");
      print("Description: ${_descriptionController.text.trim().isEmpty ? 'NULL' : _descriptionController.text.trim()}");
      print("Category: $_selectedCategory");
      print("Type: $_salesMethod");
      print("Location: ${_locationController.text}");
      print("Area: $areaText m²");
      print("Stock: $finalStock");
      print("Price: $finalPrice");
      print("Contact: ${_contactNameController.text}");
      print("Phone: ${_contactNumberController.text}");
      print("Images: ${finalImages.length}");
      
      final result = await _listingService.createListing(
        title: _commodityController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        area: areaText,
        price: finalPrice,
        stock: finalStock,
        category: _selectedCategory,
        type: _salesMethod,
        contactName: _contactNameController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
        images: finalImages, 
      );

          if (result['success'] == true) {
            if (!mounted) return;
            
            // Reset form dulu
            _formKey.currentState?.reset();
            _commodityController.clear();
            _descriptionController.clear();
            _locationController.clear();
            _areaController.clear();
            _priceController.clear();
            _stockController.clear();
            _contactNameController.clear();
            _contactNumberController.clear();
            setState(() {
              _pickedImageItems.clear();
              _selectedCategory = "sayur";
              _salesMethod = "Timbang";
            });
            
            // Tampilkan dialog sukses
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
                title: const Text("Berhasil Dipublikasikan!"),
                content: const Text("Iklan ladang Anda kini aktif dan dapat dilihat oleh pembeli."),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(); // Hanya tutup dialog
                    },
                    child: const Text("Oke")
                  )
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Gagal: ${result['message']}"), backgroundColor: Colors.red),
            );
          }

      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }
  Widget _buildImageWidget(PickedImageItem item) {
    if (kIsWeb) {
      return Image.network(
        item.xFile.path, 
        width: 80, height: 80, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
            width: 80, height: 80,
            color: Colors.grey.shade200,
            child: const Icon(Icons.warning, color: Colors.red),
        ),
      );
    } else {
      return Image.file(
        item.file!, 
        width: 80, height: 80, fit: BoxFit.cover,
      );
    }
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _pickedImageItems.map((item) => Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImageWidget(item), 
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => setState(() => _pickedImageItems.remove(item)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5)
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              )
            ],
          )).toList(),
        ),
        if (_pickedImageItems.length < 5) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickImage,
            child: _buildShadowedInput(
              child: SizedBox(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                      child: Icon(Icons.add_a_photo_rounded, size: 30, color: Colors.green.shade700),
                    ),
                    const SizedBox(height: 8),
                    Text("Tap untuk Upload Foto (${_pickedImageItems.length}/5)", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }
  
  Widget _buildCategoryDropdown() {
    return _buildShadowedInput(
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: _inputDecoration(icon: Icons.local_florist_rounded, hint: "Pilih Kategori"),
        items: const [
          DropdownMenuItem(value: "sayur", child: Text("Sayur")),
          DropdownMenuItem(value: "buah", child: Text("Buah")),
          DropdownMenuItem(value: "organik", child: Text("Organik")),
        ],
        onChanged: (value) {
          setState(() {
            _selectedCategory = value!;
          });
        },
        validator: (val) => val == null ? "Kategori wajib dipilih" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 25), 
                  child: Text(
                    "Publikasikan Hasil Ladang",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // FORM
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionLabel("Jenis & Kategori Tanaman"),
                      _buildShadowedInput(
                        child: TextFormField(
                          controller: _commodityController,
                          decoration: _inputDecoration(icon: Icons.grass_rounded, hint: "Contoh: Cabai Merah Keriting"),
                          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCategoryDropdown(), 

                      const SizedBox(height: 20),
                      
                      _buildSectionLabel("Deskripsi Listing (Opsional)"),
                      _buildShadowedInput(
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          minLines: 1,
                          decoration: _inputDecoration(icon: Icons.description_rounded, hint: "Informasi tambahan (Kualitas, Waktu Panen, dll.)"),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildSectionLabel("Lokasi Ladang"),
                      _buildShadowedInput(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: _inputDecoration(icon: Icons.location_on_rounded, hint: "Alamat Lengkap"),
                          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildShadowedInput(
                        child: Container(
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: NetworkImage("https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/Google_Earth_icon.svg/2048px-Google_Earth_icon.svg.png"), 
                                fit: BoxFit.cover, 
                                opacity: 0.8
                            )
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)]
                              )
                            ),
                            child: Center(
                              child: ElevatedButton.icon(
                                onPressed: () { 
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Google Maps Picker Placeholder")));
                                  }, 
                                icon: const Icon(Icons.map_outlined, color: Colors.green), 
                                label: const Text("Pilih Titik Lokasi", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0, 
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildSectionLabel("Luas Lahan"),
                      _buildShadowedInput(
                        child: TextFormField(
                          controller: _areaController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
                          decoration: _inputDecoration(icon: Icons.aspect_ratio_rounded, hint: "Contoh: 5000", suffix: "m²"),
                          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ),
                      
                      const SizedBox(height: 20),

                      _buildSectionLabel("Metode Penjualan"),
                      _buildShadowedInput(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(child: _buildRadioOption("Timbang", "Harga per Kg", Icons.scale_rounded)),
                                Expanded(child: _buildRadioOption("Borong", "Harga Total", Icons.account_balance_wallet_rounded)),
                              ],
                            ),
                          ),
                      ),

                      const SizedBox(height: 16),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, child: child)),
                        child: Container(
                          key: ValueKey(_salesMethod),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _salesMethod == "Borong" ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _salesMethod == "Borong" ? Colors.green.shade300 : Colors.orange.shade300,
                              width: 1.5
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _salesMethod == "Borong" 
                              ? [
                                  Text("Detail Borongan", style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 12),
                                  _buildInnerInput(_stockController, "Estimasi Panen (Ton)", Icons.line_weight_rounded),
                                  const SizedBox(height: 12), 
                                  _buildInnerInput(_priceController, "Total Harga Borongan (Rp)", Icons.payments_rounded, isCurrency: true),
                                ]
                              : [
                                  Text("Detail Timbangan", style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 12),
                                  _buildInnerInput(_stockController, "Ketersediaan (Ton)", Icons.warehouse_rounded),
                                  const SizedBox(height: 12),
                                  _buildInnerInput(_priceController, "Harga per Kg (Rp)", Icons.price_change_rounded, isCurrency: true),
                                ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildSectionLabel("Foto Dokumentasi"),
                      _buildImagePicker(),
                      
                      const SizedBox(height: 24),
                      
                      _buildSectionLabel("Kontak Person"),
                      _buildShadowedInput(
                        child: TextFormField(
                          controller: _contactNameController,
                          decoration: _inputDecoration(icon: Icons.person_rounded, hint: "Nama Pemilik"),
                          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildShadowedInput(
                        child: TextFormField(
                          controller: _contactNumberController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(icon: Icons.phone_in_talk_rounded, hint: "Nomor WhatsApp"),
                          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ===== TOMBOL PUBLIKASI IKLAN =====
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handlePublish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            disabledBackgroundColor: Colors.grey.shade400,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading 
                            ? const SizedBox(
                                height: 26, 
                                width: 26, 
                                child: CircularProgressIndicator(
                                  color: Colors.white, 
                                  strokeWidth: 3
                                )
                              ) 
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 26),
                                  SizedBox(width: 12),
                                  Text(
                                    "PUBLIKASIKAN IKLAN", 
                                    style: TextStyle(
                                      fontSize: 17, 
                                      fontWeight: FontWeight.bold, 
                                      letterSpacing: 0.8, 
                                      color: Colors.white
                                    )
                                  ),
                                ],
                              ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  InputDecoration _inputDecoration({required IconData icon, required String hint, String? suffix, bool isCurrency = false}) {
     return InputDecoration(
        prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF1B5E20), size: 20),
            ),
        ),
        hintText: hint,
        prefixText: isCurrency ? "Rp " : null,
        suffixText: suffix,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildInnerInput(TextEditingController controller, String label, IconData icon, {bool isCurrency = false}) {
     return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
        ),
        child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, ThousandsSeparatorInputFormatter()],
            decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, size: 20, color: Colors.grey[700]),
                prefixText: isCurrency ? "Rp " : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.white,
            ),
            validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
        ),
    );
  }
  
  Widget _buildSectionLabel(String label) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10.0, top: 4.0, left: 4),
        child: Text(
            label.toUpperCase(), 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey.shade700, letterSpacing: 0.5)
        ),
    );
  }
  
  Widget _buildRadioOption(String value, String subtitle, IconData icon) {
    final bool isSelected = _salesMethod == value;
    final Color color = isSelected ? const Color(0xFF1B5E20) : Colors.grey;
    
    return GestureDetector(
      onTap: () => setState(() => _salesMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.green : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
            Text(subtitle, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildShadowedInput({required Widget child}) {
    return Container(
        margin: const EdgeInsets.only(bottom: 12), 
        decoration: BoxDecoration(
            color: Colors.transparent, 
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 4, offset: const Offset(0, 2), spreadRadius: 0),
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
}