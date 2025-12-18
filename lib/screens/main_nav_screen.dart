import 'package:flutter/material.dart';
import 'package:panen_lokal/models/user_model.dart';
import 'package:panen_lokal/services/auth_service.dart';

import 'buyer_home_screen.dart';
import 'farmer_home_screen.dart';
import 'listing_form_screen.dart';
import 'profile_screen.dart';
import 'admin_verification_screen.dart';
import 'transaction_screen.dart';
import 'admin_user_management_screen.dart';

class NavPageContent {
  final String label;
  final IconData icon;
  final Widget page;

  const NavPageContent({required this.label, required this.icon, required this.page});
}

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserAndConfig();
  }

  Future<void> _loadUserAndConfig() async {
    final user = await AuthService.getUserData();

    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoading = false;

        if (user != null) {
          final config = _getNavConfig(user.role, user.verified);
          if (_selectedIndex >= config.length) {
            _selectedIndex = 0;
          }
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> refreshUserData() async {
    await _loadUserAndConfig();
  }

  List<NavPageContent> _getNavConfig(String role, bool isVerified) {
    // Inisialisasi semua halaman
    final Widget berandaPage = const BuyerHomeScreen(title: 'Beranda');
    final Widget lapakSayaPage = const FarmerHomeScreen(title: 'Lapak Saya');
    final Widget listingPage = const ListingFormScreen();
    final Widget transaksiPage = const TransactionScreen();
    final Widget verifikasiPage = const AdminVerificationScreen();
    final Widget kelolaUserPage = const AdminUserManagementScreen();
    final Widget profilPage = ProfileScreen(onVerificationChanged: refreshUserData);

    if (role == 'admin') {
      // ✅ ADMIN: 4 Menu (BERANDA, VERIFIKASI, KELOLA USER, PROFIL)
      // Market & Favorit dihapus dari navbar, diakses via icons di header
      return [
        NavPageContent(label: 'BERANDA', icon: Icons.home, page: berandaPage),
        NavPageContent(label: 'VERIFIKASI', icon: Icons.verified_user, page: verifikasiPage),
        NavPageContent(label: 'KELOLA USER', icon: Icons.people, page: kelolaUserPage),
        NavPageContent(label: 'PROFIL', icon: Icons.person, page: profilPage),
      ];
    } else if (role == 'farmer' && isVerified) {
      // ✅ FARMER VERIFIED: 5 Menu (BERANDA, LAPAK SAYA, IKLAN, TRANSAKSI, PROFIL)
      // Market & Favorit dihapus dari navbar, diakses via icons di header
      return [
        NavPageContent(label: 'BERANDA', icon: Icons.home, page: berandaPage),
        NavPageContent(label: 'LAPAK SAYA', icon: Icons.store, page: lapakSayaPage),
        NavPageContent(label: 'IKLAN', icon: Icons.add_box, page: listingPage),
        NavPageContent(label: 'TRANSAKSI', icon: Icons.receipt_long, page: transaksiPage),
        NavPageContent(label: 'PROFIL', icon: Icons.person, page: profilPage),
      ];
    } else {
      // ✅ BUYER atau FARMER belum verified: 3 Menu (BERANDA, TRANSAKSI, PROFIL)
      // Market & Favorit dihapus dari navbar, diakses via icons di header
      return [
        NavPageContent(label: 'BERANDA', icon: Icons.home, page: berandaPage),
        NavPageContent(label: 'TRANSAKSI', icon: Icons.receipt_long, page: transaksiPage),
        NavPageContent(label: 'PROFIL', icon: Icons.person, page: profilPage),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final role = _currentUser!.role;
    final isVerified = _currentUser!.verified;
    final config = _getNavConfig(role, isVerified);

    final List<Widget> pages = config.map((c) => c.page).toList();
    final List<String> labels = config.map((c) => c.label).toList();
    final List<IconData> icons = config.map((c) => c.icon).toList();
    final int itemCount = pages.length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF9FBE7),
      body: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: pages[_selectedIndex],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Ps5Navbar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              labels: labels,
              icons: icons,
              itemCount: itemCount,
            ),
          ),
        ],
      ),
    );
  }
}

class Ps5Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<String> labels;
  final List<IconData> icons;
  final int itemCount;

  const Ps5Navbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.labels,
    required this.icons,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<double> itemXPercents = List.generate(itemCount, (index) => (index + 0.5) / itemCount);
    final Color navBgColor = const Color(0xFF1B5E20);
    final Color selectedColor = Colors.white;
    final Color unselectedColor = Colors.white60;

    double getIconCurveY(double xPercent) {
      return 80 * (xPercent - 0.5) * (xPercent - 0.5) + 10;
    }

    double getInnerCurveY(double xPercent) {
      return 60 * (xPercent * xPercent - xPercent) + 90;
    }

    double getDashAngle(double xPercent) {
      return (60.0 / screenWidth) * (2 * xPercent - 1);
    }

    final double selectedXPercent = itemXPercents[selectedIndex];
    final double selectedIconY = getIconCurveY(selectedXPercent);
    final double selectedDashY = getInnerCurveY(selectedXPercent);
    final double selectedAngle = getDashAngle(selectedXPercent);

    return SizedBox(
      height: 110,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomPaint(
            size: Size(screenWidth, 110),
            painter: DualCurvePainter(color: navBgColor),
          ),

          Positioned(
            bottom: 8,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                labels[selectedIndex],
                key: ValueKey<int>(selectedIndex),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuad,
            left: (screenWidth * selectedXPercent) - 30,
            top: selectedIconY - 5,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 20, spreadRadius: 1),
                ],
              ),
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuad,
            left: (screenWidth * selectedXPercent) - 15,
            top: selectedDashY - 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
              transform: Matrix4.rotationZ(selectedAngle),
              alignment: Alignment.center,
              child: CustomPaint(
                size: const Size(30, 4),
                painter: CurvedDashPainter(),
              ),
            ),
          ),

          ...List.generate(itemCount, (index) {
            final double xPercent = itemXPercents[index];
            final double yOffset = getIconCurveY(xPercent);
            final bool isSelected = selectedIndex == index;

            return Positioned(
              left: (screenWidth * xPercent) - 30,
              top: yOffset - 5,
              child: GestureDetector(
                onTap: () => onItemTapped(index),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  child: AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      icons[index],
                      color: isSelected ? selectedColor : unselectedColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DualCurvePainter extends CustomPainter {
  final Color color;
  DualCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill..color = color;
    canvas.drawShadow(
      Path()
        ..moveTo(0, size.height)
        ..lineTo(0, 30)
        ..quadraticBezierTo(size.width / 2, -10, size.width, 30)
        ..lineTo(size.width, size.height)
        ..close(),
      Colors.black.withOpacity(0.5),
      8,
      true,
    );

    final mainPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 30)
      ..quadraticBezierTo(size.width / 2, -10, size.width, 30)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(mainPath, paint);

    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    final innerPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height - 20)
      ..quadraticBezierTo(size.width / 2, size.height - 50, size.width, size.height - 20)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(innerPath, innerPaint);
    canvas.drawPath(
        innerPath,
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CurvedDashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, 2.5, size.width, size.height);
    canvas.drawPath(
        path,
        Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}