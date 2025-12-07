import 'package:flutter/material.dart';
import 'farmer_home_screen.dart'; // Import for CommodityPost model

class ListingFormScreen extends StatefulWidget {
  final Function(CommodityPost) onSubmit;

  const ListingFormScreen({super.key, required this.onSubmit});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Commodity Dropdown
  final List<String> commodityOptions = [
    "Ercis Berastagi", "Brokoli", "Buncis", "Cabai Hijau", "Cabai Merah",
    "Cabai Rawit Kasar", "Cabai Rawit Kecil", "Daun Sop / Seledri", "Daun Prey",
    "Jagung Manis", "Kentang Kuning", "Kentang Merah", "Kol / Kubis",
    "Kol Bunga", "Labu / Jambe", "Sayur Pahit", "Sayur Putih", 
    "Terong Antaboga", "Tomat", "Wortel Karo", "Jipang Besar", 
    "Anak Jipang", "Selada", "Sayur Botol", "Terong Belanda"
  ];
  String? _selectedCommodity;

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
        finalQty = double.tryParse(_estTonsController.text) ?? 0.0;
        // For Borong, we store the Total Price directly
        finalPriceKg = int.tryParse(_totalPriceController.text.replaceAll('.', '')) ?? 0;
    } else {
        finalPriceKg = int.tryParse(_pricePerKgController.text.replaceAll('.', '')) ?? 0;
         finalQty = double.tryParse(_estTonsController.text) ?? 0.0;
    }

    final newPost = CommodityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Generate simplified ID
      commodity: _selectedCommodity!,
      location: _locationController.text,
      area: "${_areaController.text} m²",
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Buat Iklan Ladang", style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 130), // More padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Commodity Type
              _buildSectionLabel("Jenis Tanaman"),
              _buildShadowedInput(
                child: DropdownButtonFormField<String>(
                  decoration: _inputDecoration(icon: Icons.grass_rounded, hint: "Pilih Komoditas"),
                  value: _selectedCommodity,
                  items: commodityOptions.map((String val) {
                    return DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontWeight: FontWeight.w600)));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCommodity = val),
                   validator: (val) => val == null ? "Wajib dipilih" : null,
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
              
              // Map Button (Styled)
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                  border: Border.all(color: Colors.white, width: 2),
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
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
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
                  decoration: _inputDecoration(icon: Icons.aspect_ratio_rounded, hint: "Contoh: 5000", suffix: "m²"),
                  validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
                ),
              ),

              const SizedBox(height: 20),

              // 4. Sales Method (Card Style)
              _buildSectionLabel("Metode Penjualan"),
              Container(
                 padding: const EdgeInsets.all(4),
                 decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: Colors.green.withOpacity(0.2)),
                 ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildRadioOption("Timbang", "Harga per Kg", Icons.scale_rounded),
                    ),
                    Expanded(
                      child: _buildRadioOption("Borong", "Harga Total", Icons.account_balance_wallet_rounded),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // DYNAMIC PRICE FIELDS (Highlighted Box)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, child: child)),
                child: Container(
                  key: ValueKey(_salesMethod),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _salesMethod == "Borong" ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0), // Green vs Orange Tint
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
                 child: Container(
                   height: 160,
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(20),
                     border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid), // Dashed effect simulated style
                     boxShadow: [
                       BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
                     ]
                   ),
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF1B5E20).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 8)),
                  ],
                  gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF43A047)])
                ),
                child: ElevatedButton.icon(
                  onPressed: _handlePublish, 
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text("PUBLIKASIKAN IKLAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent, // Shadow handled by Container
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
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
      decoration: BoxDecoration(
        // Outer Decoration: Shadow Only
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), 
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 1
          ),
        ],
      ),
      child: Material(
        // Use Material for proper InkWell support if needed, but mainly for layering
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade400, width: 1.2), // Slightly thicker stroke
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15), // Slightly smaller to fit inside border
            child: child
          ),
        ),
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

  // Inner inputs (for inside the colored box) - simpler style
  Widget _buildInnerInput(TextEditingController controller, String label, IconData icon, {bool isCurrency = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
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
