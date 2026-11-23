import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import 'menu_list_screen.dart';

class AdminHome extends StatefulWidget {
  final AppUser user;
  const AdminHome({super.key, required this.user});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;
  static const _judul = ['Dashboard', 'Kelola Menu', 'Pesanan Masuk', 'Laporan'];

  @override
  Widget build(BuildContext context) {
    final halaman = [
      _Dashboard(user: widget.user),
      const MenuListScreen(),
      const _Segera(nama: 'Pesanan Masuk'),
      const _Segera(nama: 'Laporan'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_judul[_index]),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: halaman[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        indicatorColor: AppColors.light,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_menu), label: 'Menu'),
          NavigationDestination(
              icon: Icon(Icons.notifications_outlined), label: 'Pesanan'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart), label: 'Laporan'),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  final AppUser user;
  const _Dashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Halo, ${user.nama}! 👩‍🍳',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Segera extends StatelessWidget {
  final String nama;
  const _Segera({required this.nama});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$nama\n(segera hadir)',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted, fontSize: 16),
      ),
    );
  }
}