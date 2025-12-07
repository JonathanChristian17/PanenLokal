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
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  int _layoutState = 0; 
  
  String _title = "";
  String _desc = "";
  
  final String _targetTitle = "Panen Lokal";
  final String _targetDesc = "Segar dari lahan,\nlangsung ke tangan.";

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
        vsync: this, 
        duration: const Duration(milliseconds: 500)
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _rippleController, curve: Curves.easeInOutQuart)
    );

    _runFlow();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/panenlokal_logo.png'), context);
  }

  Future<void> _runFlow() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    setState(() {
      _layoutState = 1; 
    });
    _rippleController.forward();

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    for (int i = 1; i <= _targetTitle.length; i++) {
       if (!mounted) return;
       setState(() {
         _title = _targetTitle.substring(0, i);
       });
       await Future.delayed(const Duration(milliseconds: 80));
    }

    for (int i = 1; i <= _targetDesc.length; i++) {
       if (!mounted) return;
       setState(() {
         _desc = _targetDesc.substring(0, i);
       });
       await Future.delayed(const Duration(milliseconds: 40));
    }

    await Future.delayed(const Duration(milliseconds: 1500));

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

    final Alignment logoAlign = _layoutState == 0 
        ? Alignment.center 
        : const Alignment(-0.6, 0.0);
    
    final double logoSize = _layoutState == 0 ? 150 : 100;

    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Stack(
        children: [
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
           
           AnimatedAlign(
             duration: const Duration(milliseconds: 500),
             curve: Curves.easeInOutQuart,
             alignment: logoAlign,
             child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutQuart,
                width: logoSize,
                height: logoSize,
                child: Image.asset('assets/images/panenlokal_logo.png'),
             ),
           ),

           Align(
             alignment: const Alignment(0.6, 0.0),
             child: SizedBox(
               width: size.width * 0.5,
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     _title,
                     style: GoogleFonts.poppins(
                       fontSize: 24,
                       fontWeight: FontWeight.w700,
                       color: const Color(0xFF2E7D32),
                       height: 1.0,
                       letterSpacing: 0.5,
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     _desc,
                     style: GoogleFonts.inter(
                       fontSize: 14,
                       fontWeight: FontWeight.w500,
                       color: Colors.grey.shade800,
                       height: 1.4,
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
