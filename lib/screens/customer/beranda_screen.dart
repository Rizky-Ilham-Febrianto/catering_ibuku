import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/makanan.dart';
import '../../services/menu_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/menu_image.dart';
import 'detail_screen.dart';

class BerandaScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onLihatMenu;
  const BerandaScreen({
    super.key,
    required this.user,
    required this.onLihatMenu,
  });

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final Stream<List<Makanan>> _stream = MenuService().semuaMenu();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Halo, ${widget.user.nama}! 👋',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        const Text(
          'Mau pesan apa hari ini?',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pesan catering untuk acara Anda',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Dimasak sendiri oleh Ibu, dengan cinta.',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Text('🍱', style: TextStyle(fontSize: 52)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Menu Andalan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onLihatMenu,
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        StreamBuilder<List<Makanan>>(
          stream: _stream,
          builder: (context, snap) {
            if (snap.hasError) {
              return Text('Gagal memuat: ${snap.error}');
            }
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final list = snap.data!.where((m) => m.tersedia).take(6).toList();
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Belum ada menu tersedia',
                      style: TextStyle(color: AppColors.muted)),
                ),
              );
            }
            return SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final m = list[i];
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(makanan: m),
                      ),
                    ),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MenuImage(
                            foto: m.foto,
                            width: 150,
                            height: 100,
                            radius: 14,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          Text(
                            formatRupiah(m.harga),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}