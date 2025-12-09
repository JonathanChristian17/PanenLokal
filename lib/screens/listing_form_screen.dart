import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'farmer_home_screen.dart'; // Import for CommodityPost model

class ListingFormScreen extends StatefulWidget {
  final Function(CommodityPost) onSubmit;

  const ListingFormScreen({super.key, required this.onSubmit});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Commodity Controller (Replaced Dropdown)
  final TextEditingController _commodityController = TextEditingController();

  // 2. Location & Area
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _areaController = TextEditingController(); // m2

  // 3. Sales Method
  String _salesMethod = "Timbang"; // "Borong" or "Timbang"

  // 4. Price Logic
  final TextEditingController _totalPriceController = TextEditingController();
  final TextEditingController _estTonsController = TextEditingController(); // For Borong
  final TextEditingController _pricePerKgController = TextEditingController(); // For Timbang

  // 5. Contact
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();

  void _handlePublish() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Konfirmasi Listing"),
          content: const Text("Apakah data ladang dan harga sudah sesuai? Listing akan dipublikasikan ke pembeli."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), 
              child: const Text("Batal")
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close Alert
                _finalizeSubmission();
              }, 
              child: const Text("Ya, Publikasikan")
            ),
          ],
        ),
      );
    }
  }

  void _finalizeSubmission() {
    int finalPriceKg = 0;
    double finalQty = 0.0;

    if (_salesMethod == "Borong") {
        finalQty = double.tryParse(_estTonsController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0; 
        finalPriceKg = int.tryParse(_totalPriceController.text.replaceAll('.', '')) ?? 0;
    } else {
        finalPriceKg = int.tryParse(_pricePerKgController.text.replaceAll('.', '')) ?? 0;
        finalQty = double.tryParse(_estTonsController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
    }

    final newPost = CommodityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate simplified ID
      commodity: _commodityController.text,
      location: _locationController.text,
      area: "${_areaController.text.replaceAll('.', '')} m²",
      price: finalPriceKg, // This variable holds the calculated price
      quantityTons: finalQty,
      contactName: _contactNameController.text,
      contactInfo: _contactNumberController.text,
      type: _salesMethod, // "Borong" or "Timbang"
    );

    widget.onSubmit(newPost);

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
            },
            child: const Text("Lihat Iklan Saya")
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 130), // Bottom padding for scrolling space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. HEADER (Now part of the scrollable column)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 25), // SafeArea taken care of by body wrapper
                  child: const Text(
                    "Publikasikan Hasil Ladang",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFF1B5E20)
                    ),
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
                      // 1. Commodity Type
                      _buildSectionLabel("Jenis Tanaman"),
                      _buildShadowedInput(
                        child: TextFormField(
                          controller: _commodityController,
                          decoration: _inputDecoration(icon: Icons.grass_rounded, hint: "Contoh: Cabai Merah"),
                          validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 2. Location
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

                      // 3. Area
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

                      // 4. Sales Method
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
                                  _buildInnerInput(_estTonsController, "Estimasi Panen (Ton)", Icons.line_weight_rounded),
                                  const SizedBox(height: 12), 
                                  _buildInnerInput(_totalPriceController, "Total Harga (Rp)", Icons.payments_rounded, isCurrency: true),
                                ]
                              : [
                                  Text("Detail Timbangan", style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 12),
                                  _buildInnerInput(_estTonsController, "Ketersediaan (Ton)", Icons.warehouse_rounded),
                                  const SizedBox(height: 12),
                                  _buildInnerInput(_pricePerKgController, "Harga per Kg (Rp)", Icons.price_change_rounded, isCurrency: true),
                                ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      
                       // 5. Image & Contact
                       _buildSectionLabel("Foto Dokumentasi"),
                       InkWell(
                         onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image Picker Placeholder"))),
                         child: _buildShadowedInput(
                           child: SizedBox(
                             height: 160,
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Container(
                                   padding: const EdgeInsets.all(16),
                                   decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                                   child: Icon(Icons.add_a_photo_rounded, size: 36, color: Colors.green.shade700),
                                 ),
                                 const SizedBox(height: 12),
                                 Text("Tap untuk Upload Foto", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                               ],
                             ),
                           ),
                         ),
                       ),
                       
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

                      const SizedBox(height: 40),

                      // Submit Button
                      Container(
                        margin: const EdgeInsets.only(bottom: 24, top: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF1B5E20).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6), spreadRadius: 0),
                            BoxShadow(color: const Color(0xFF1B5E20).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10), spreadRadius: 2),
                          ],
                        ),
                        child: Material(
                          borderRadius: BorderRadius.circular(16),
                          elevation: 0,
                          color: Colors.transparent, 
                          clipBehavior: Clip.antiAlias,
                          child: Ink(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                                begin: Alignment.topLeft, end: Alignment.bottomRight
                              ),
                            ),
                            child: InkWell(
                              onTap: _handlePublish,
                              splashColor: Colors.white.withOpacity(0.3), 
                              highlightColor: Colors.white.withOpacity(0.1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.check_circle, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text("PUBLIKASIKAN IKLAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 4.0, left: 4),
      child: Text(
        label.toUpperCase(), 
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.grey.shade700, letterSpacing: 0.5)
      ),
    );
  }

  // Stylish Radio Button Option
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

  // Consistent shadowed input wrapper
  Widget _buildShadowedInput({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), 
      decoration: BoxDecoration(
        color: Colors.transparent, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2, 
          ),
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
  
  // Custom Input Decoration
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

  // Inner inputs
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
}

// 🔢 FORMATTER CLASS
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String oldText = oldValue.text.replaceAll('.', '');
    String newText = newValue.text.replaceAll('.', '');

    int value = int.tryParse(newText) ?? 0;
    
    String newString = _formatNumber(newText);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(
        offset: newString.length, 
      ),
    );
  }

  String _formatNumber(String s) {
    if (s.length > 3) {
      return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
    }
    return s;
  }
}
