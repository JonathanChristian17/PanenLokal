import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // --- ANIMATION CONTROLLERS ---
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  // --- STATE ---
  // 0 = Initial (Center Logo)
  // 1 = Moved (Left Logo)
  int _layoutState = 0; 
  
  // Teks konten
  String _title = "";
  String _desc = "";
  
  final String _targetTitle = "Panen Lokal";
  final String _targetDesc = "Segar dari lahan,\nlangsung ke tangan.";

  @override
  void initState() {
    super.initState();
    // Precache logic could be here but usually usually handled by flutter. 
    
    // Setup Ripple (500ms snappy)
    _rippleController = AnimationController(
        vsync: this, 
        duration: const Duration(milliseconds: 500)
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _rippleController, curve: Curves.easeInOutQuart)
    );

    // Start Flow
    _runFlow();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache agar saat render pertama kali tidak kedip
    precacheImage(const AssetImage('assets/images/panenlokal_logo.png'), context);
  }

  Future<void> _runFlow() async {
    // 1. PHASE IDLE (3 Detik)
    // Logo diam di tengah.
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    // 2. PHASE MOVE (0.5 Detik)
    // Logo geser, background ripple.
    setState(() {
      _layoutState = 1; 
    });
    _rippleController.forward();

    // Tunggu transisi selesai (500ms) + Jeda Stabilisasi (200ms)
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // 3. PHASE TYPEWRITER
    // Logo sudah di kiri. Mulai ketik teks di kanan.
    
    // a. Ketik Judul (Cepat: 80ms)
    for (int i = 1; i <= _targetTitle.length; i++) {
       if (!mounted) return;
       setState(() {
         _title = _targetTitle.substring(0, i);
       });
       await Future.delayed(const Duration(milliseconds: 80));
    }

    // b. Ketik Deskripsi (Sangat Cepat: 40ms)
    for (int i = 1; i <= _targetDesc.length; i++) {
       if (!mounted) return;
       setState(() {
         _desc = _targetDesc.substring(0, i);
       });
       await Future.delayed(const Duration(milliseconds: 40));
    }

    // 4. PHASE END HOLD (1.5 Detik)
    await Future.delayed(const Duration(milliseconds: 1500));

    // 5. NAVIGASI
    if (mounted) {
       Navigator.of(context).pushReplacement(
           MaterialPageRoute(builder: (_) => const LoginScreen())
       );
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double maxRadius = size.longestSide * 1.5;

    // LOGIC LAYOUT (DECLARATIVE)
    // Default (State 0): Alignment Center (0,0)
    // Moved (State 1): Alignment Left-ish (-0.6, 0.0) -> Geser sedikit lebih ke kiri biar teks muat
    final Alignment logoAlign = _layoutState == 0 
        ? Alignment.center 
        : const Alignment(-0.6, 0.0);
    
    // Logo Size: Sedikit mengecil saat geser (Opsional, tapi bagus untuk 'push back')
    final double logoSize = _layoutState == 0 ? 150 : 100;

    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Stack(
        children: [
           // 1. RIPPLE BACKGROUND
           AnimatedBuilder(
             animation: _rippleAnimation,
             builder: (context, child) {
               return CustomPaint(
                 painter: RipplePainter(
                   radius: _rippleAnimation.value * maxRadius,
                   color: const Color(0xFFF9FBE7), 
                   center: Offset(size.width / 2, size.height / 2),
                 ),
                 child: Container(),
               );
             },
           ),
           
           // 2. LOGO (Animated Align)
           AnimatedAlign(
             duration: const Duration(milliseconds: 500),
             curve: Curves.easeInOutQuart,
             alignment: logoAlign,
             child: AnimatedContainer( // Untuk resize smooth
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutQuart,
                width: logoSize,
                height: logoSize,
                child: Image.asset('assets/images/panenlokal_logo.png'),
             ),
           ),

           // 3. TEXT AREA (Align Right)
           // Kita taruh di Alignment(0.6, 0.0) -> Sebelah kanan
           // Gunakan Visibility agar tidak mengganggu layout saat awal
           Align(
             alignment: const Alignment(0.6, 0.0), // Kanan Center
             child: SizedBox(
               width: size.width * 0.5, // Lebar area teks 50% layar
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   // JUDUL
                   Text(
                     _title,
                     style: GoogleFonts.poppins(
                       fontSize: 24,
                       fontWeight: FontWeight.w700, // Bold tapi aesthetic
                       color: const Color(0xFF2E7D32),
                       height: 1.0,
                       letterSpacing: 0.5,
                     ),
                   ),
                   const SizedBox(height: 8),
                   // DESKRIPSI
                   Text(
                     _desc,
                     style: GoogleFonts.inter(
                       fontSize: 14,
                       fontWeight: FontWeight.w500,
                       color: Colors.grey.shade800,
                       height: 1.4, // Sedikit lebih renggang biar rapi
                       letterSpacing: 0.2,
                     ),
                   ),
                 ],
               ),
             ),
           )
        ],
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double radius;
  final Color color;
  final Offset center;

  RipplePainter({required this.radius, required this.color, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) {
     return oldDelegate.radius != radius;
  }
}
