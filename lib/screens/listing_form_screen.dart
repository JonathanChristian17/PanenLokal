import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io'; 
// Import ini penting untuk kIsWeb
import 'package:flutter/foundation.dart' show kIsWeb; 
import 'package:image_picker/image_picker.dart'; 
import 'package:panen_lokal/services/listing_service.dart';

// --- FORMATTER CLASS (Tidak Berubah) ---
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
// --- AKHIR FORMATTER CLASS ---

// Class ini akan menyimpan XFile (sebagai rujukan untuk web) dan File (untuk mobile/desktop)
class PickedImageItem {
  final File? file; // Hanya ada di non-web
  final XFile xFile; // Selalu ada

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

  // 1. Data Listing
  final TextEditingController _commodityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController(); 
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _areaController = TextEditingController(); 
  String _selectedCategory = "sayur"; 

  // 2. Sales Method
  String _salesMethod = "Timbang"; 

  // 3. Price Logic
  final TextEditingController _priceController = TextEditingController(); 
  final TextEditingController _stockController = TextEditingController(); 

  // 4. Contact
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();

  // 5. Images (Berubah ke PickedImageItem)
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

  // Pick Image (Diperbarui untuk menangani Web)
  Future<void> _pickImage() async {
    final XFile? xFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (xFile != null) {
      // Di web, kita hanya punya XFile. Di non-web, kita buat File dari path.
      File? file;
      if (!kIsWeb) {
        file = File(xFile.path);
      }
      
      setState(() {
        _pickedImageItems.add(PickedImageItem(file: file, xFile: xFile));
      });
    }
  }

  // Proses Submit
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
                Navigator.pop(ctx); // Close Alert
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

    // Bersihkan nilai dari titik (separator ribuan)
    final double finalStock = double.tryParse(_stockController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0; 
    final double finalPrice = double.tryParse(_priceController.text.replaceAll('.', '')) ?? 0.0; 
    final String finalArea = _areaController.text.replaceAll('.', '');

    // Kumpulkan List<File> dari PickedImageItem
    final List<File> finalImages = _pickedImageItems.map((item) => File(item.xFile.path)).toList();
    
    // PENTING: Untuk DIO di Web, path tidak berfungsi, kita harus kirim XFile/MultipartFile langsung dari bytes.
    // Namun di service, kita sudah menggunakan MultipartFile.fromFile(image.path) yang hanya berfungsi
    // jika `image.path` adalah path file nyata (mobile/desktop) atau file temporer (web, walau sering bermasalah).
    // Solusi terbaik untuk Dio di web: Kumpulkan XFile dan kirim bytes-nya.

    List<File> filesToSend = [];
    if (kIsWeb) {
      // Di web, kita tidak bisa kirim File, kita perlu mengubah ListingService untuk menerima XFile atau List<Uint8List>.
      // UNTUK KONSISTENSI, KITA GANTI ARGUMEN DI LISTING SERVICE menjadi List<XFile>
      // Tapi untuk saat ini, kita akan coba kirim File(xFile.path) yang harusnya sudah benar di Dart 3+ untuk web.
      // Kita asumsikan XFile.path di web dapat diubah menjadi MultipartFile.
      // Jika masih error, kita harus memodifikasi ListingService dan _finalizeSubmission.
      
      // Mengirim List<File> (sebenarnya List<XFile> yang di cast)
      filesToSend = _pickedImageItems.map((item) => File(item.xFile.path)).toList(); 

    } else {
      // Mobile/Desktop: Kirim List<File> biasa
      filesToSend = _pickedImageItems.map((item) => item.file!).toList();
    }


    try {
      final result = await _listingService.createListing(
        title: _commodityController.text,
        description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
        location: _locationController.text,
        area: "$finalArea m²",
        price: finalPrice,
        stock: finalStock, // Ton
        category: _selectedCategory,
        type: _salesMethod,
        contactName: _contactNameController.text,
        contactNumber: _contactNumberController.text,
        // Kirim list of File/XFile path
        images: finalImages, 
      );

      if (result['success'] == true) {
        // SUKSES
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            title: const Text("Berhasil Dipublikasikan!"),
            content: const Text("Iklan ladang Anda kini aktif dan dapat dilihat oleh pembeli."),
            actions: [
              ElevatedButton(
                onPressed: () {
                    Navigator.pop(ctx); 
                    Navigator.pop(context); // Kembali ke layar sebelumnya (Home Petani)
                },
                child: const Text("Selesai")
              )
            ],
          ),
        );
      } else {
        // GAGAL
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

  // Pick Image (Diperbarui untuk menangani Web)
  Widget _buildImageWidget(PickedImageItem item) {
    if (kIsWeb) {
      // Solusi Web: Menggunakan Image.network atau HTML IMG element
      // Karena XFile.path di Web adalah URL blob (yang hanya berlaku selama halaman terbuka), 
      // kita harus menggunakan NetworkImage dengan path tersebut.
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
      // Mobile/Desktop: Menggunakan Image.file (yang sebelumnya error di Web)
      return Image.file(
        item.file!, 
        width: 80, height: 80, fit: BoxFit.cover,
      );
    }
  }


  // Perubahan utama di sini: menggunakan PickedImageItem dan _buildImageWidget
  Widget _buildImagePicker() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // ➡️ Perubahan List: Gunakan _pickedImageItems
          children: _pickedImageItems.map((item) => Padding(
            padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  // ➡️ Perubahan Widget: Gunakan kondisional _buildImageWidget
                  child: _buildImageWidget(item), 
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => setState(() => _pickedImageItems.remove(item)), // Hapus item
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
            ),
          )).toList(),
        ),
        // ➡️ Perubahan Count: Gunakan _pickedImageItems.length
        _pickedImageItems.length < 5 ? 
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
        ) : Container(),
      ],
    );
  }
  
  // Kategori Dropdown
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
    // KODE INI TIDAK BERUBAH
    return Scaffold(
      // ... (Bagian Scaffold dan Header tetap sama)
      body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120), // Bottom padding for scrolling space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. HEADER
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 25), 
                        child: const Text(
                          "Publikasikan Hasil Ladang",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20), // Spacing between header and form

                    // 2. FORM CONTENT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Commodity Type & Category
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
                            
                            // 2. Description
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

                            // 3. Location
                            _buildSectionLabel("Lokasi Ladang"),
                            _buildShadowedInput(
                              child: TextFormField(
                                controller: _locationController,
                                decoration: _inputDecoration(icon: Icons.location_on_rounded, hint: "Alamat Lengkap"),
                                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Map Button 
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

                            // 4. Area
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

                            // 5. Sales Method
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

                            // DYNAMIC PRICE FIELDS
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
                            
                            // 6. Image Picker
                            _buildSectionLabel("Foto Dokumentasi"),
                            _buildImagePicker(),
                            
                            const SizedBox(height: 24),
                            
                            // 7. Contact
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

                            const SizedBox(height: 40),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Floating Submit Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5, offset: const Offset(0, -5))],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePublish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text("PUBLIKASIKAN IKLAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
                          ],
                        ),
                  ),
                ),
              )
            ],
          ),
        ),
      // Metode build lain di luar build() tidak berubah
      // ... (Kode untuk _buildSectionLabel, _buildRadioOption, _buildShadowedInput, _inputDecoration, _buildInnerInput)
      // *Catatan: Pastikan Anda menyertakan semua metode yang tidak diubah di bagian bawah kode Anda.*
    );
  }
  
  // Custom Input Decoration - Pastikan ini ada
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

  // Inner inputs - Pastikan ini ada
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