import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import 'beranda_screen.dart';
import 'menu_screen.dart';
import 'profil_screen.dart';

class CustomerHome extends StatefulWidget {
  final AppUser user;
  const CustomerHome({super.key, required this.user});

  @override
  State<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends State<CustomerHome> {
  int _index = 0;
  static const _judul = ['Catering Ibuku', 'Daftar Menu', 'Keranjang', 'Profil'];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final halaman = [
      BerandaScreen(
        user: widget.user,
        onLihatMenu: () => setState(() => _index = 1),
      ),
      const MenuScreen(),
      const _KeranjangSementara(),
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
              icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}

// Tampilan sementara, akan diganti layar keranjang + checkout di tahap berikutnya
class _KeranjangSementara extends StatelessWidget {
  const _KeranjangSementara();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.kosong) {
      return const Center(
        child: Text(
          'Keranjang masih kosong',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: cart.items
                .map((i) => ListTile(
                      title: Text(i.makanan.nama),
                      subtitle: Text('${i.jumlah} x ${formatRupiah(i.makanan.harga)}'),
                      trailing: Text(
                        formatRupiah(i.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ))
                .toList(),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Total', style: TextStyle(fontSize: 16)),
              const Spacer(),
              Text(
                formatRupiah(cart.totalHarga),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}