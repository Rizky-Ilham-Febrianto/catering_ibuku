import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/pesanan.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import 'dashboard_screen.dart';
import 'laporan_screen.dart';
import 'menu_list_screen.dart';
import 'pengaturan_screen.dart';
import 'pesanan_masuk_screen.dart';

class AdminHome extends StatefulWidget {
  final AppUser user;
  const AdminHome({super.key, required this.user});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;
  late final Stream<List<Pesanan>> _stream;
  static const _judul = [
    'Dashboard',
    'Kelola Menu',
    'Pesanan Masuk',
    'Laporan',
    'Pengaturan',
  ];

  @override
  void initState() {
    super.initState();
    _stream = OrderService().semuaPesanan();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Pesanan>>(
      stream: _stream,
      builder: (context, snap) {
        final list = snap.data ?? [];
        final menunggu = list.where((p) => p.status == 'menunggu').length;
        final perluPesanan = _index == 0 || _index == 2 || _index == 3;

        Widget body;
        if (perluPesanan && snap.hasError) {
          body = Center(child: Text('Gagal memuat: ${snap.error}'));
        } else if (perluPesanan && !snap.hasData) {
          body = const Center(child: CircularProgressIndicator());
        } else {
          body = IndexedStack(
            index: _index,
            children: [
              DashboardScreen(
                user: widget.user,
                pesanan: list,
                onLihatPesanan: () => setState(() => _index = 2),
              ),
              const MenuListScreen(),
              PesananMasukScreen(pesanan: list),
              LaporanScreen(pesanan: list),
              const PengaturanScreen(),
            ],
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_judul[_index]),
            backgroundColor: AppColors.dark,
            foregroundColor: Colors.white,
          ),
          body: body,
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: const WidgetStatePropertyAll(
                TextStyle(fontSize: 11),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _index,
              indicatorColor: AppColors.light,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: [
                const NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                const NavigationDestination(
                    icon: Icon(Icons.restaurant_menu), label: 'Menu'),
                NavigationDestination(
                  icon: Badge(
                    label: Text('$menunggu'),
                    isLabelVisible: menunggu > 0,
                    child: const Icon(Icons.notifications_outlined),
                  ),
                  label: 'Pesanan',
                ),
                const NavigationDestination(
                    icon: Icon(Icons.bar_chart), label: 'Laporan'),
                const NavigationDestination(
                    icon: Icon(Icons.settings_outlined), label: 'Pengaturan'),
              ],
            ),
          ),
        );
      },
    );
  }
}