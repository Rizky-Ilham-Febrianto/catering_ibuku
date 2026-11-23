import 'package:flutter/material.dart';
import '../../models/makanan.dart';
import '../../services/menu_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/food_card.dart';
import 'detail_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final Stream<List<Makanan>> _stream = MenuService().semuaMenu();
  String _query = '';
  String _kategori = 'Semua';

  @override
  Widget build(BuildContext context) {
    final kategori = ['Semua', ...Makanan.kategoriList];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            decoration: const InputDecoration(
              hintText: 'Cari makanan...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: kategori.map((k) {
              final aktif = _kategori == k;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(k),
                  selected: aktif,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: aktif ? Colors.white : AppColors.dark,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _kategori = k),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Makanan>>(
            stream: _stream,
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(child: Text('Gagal memuat: ${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snap.data!
                  .where((m) =>
                      (_kategori == 'Semua' || m.kategori == _kategori) &&
                      m.nama.toLowerCase().contains(_query))
                  .toList()
                ..sort((a, b) =>
                    (b.tersedia ? 1 : 0) - (a.tersedia ? 1 : 0));

              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'Menu tidak ditemukan',
                    style: TextStyle(color: AppColors.muted),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => FoodCard(
                  makanan: list[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(makanan: list[i]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}