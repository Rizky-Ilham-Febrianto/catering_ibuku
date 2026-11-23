import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import 'beranda_screen.dart';
import 'keranjang_screen.dart';
import 'menu_screen.dart';
import 'pesanan_screen.dart';
import 'profil_screen.dart';

class CustomerHome extends StatefulWidget {
  final AppUser user;
  const CustomerHome({super.key, required this.user});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _index = 0;
  static const _judul = [
    'Catering Ibuku',
    'Daftar Menu',
    'Keranjang',
    'Pesanan Saya',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final halaman = [
      BerandaScreen(
        user: widget.user,
        onLihatMenu: () => setState(() => _index = 1),
      ),
      const MenuScreen(),
      KeranjangScreen(
        user: widget.user,
        onPesananDibuat: () => setState(() => _index = 3),
      ),
      PesananScreen(user: widget.user),
      ProfilScreen(user: widget.user),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_judul[_index]),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: IndexedStack(index: _index, children: halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: AppColors.light,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined), label: 'Beranda'),
          const NavigationDestination(
              icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          NavigationDestination(
            icon: Badge(
              label: Text('${cart.totalItem}'),
              isLabelVisible: cart.totalItem > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Keranjang',
          ),
          const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Pesanan'),
          const NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}