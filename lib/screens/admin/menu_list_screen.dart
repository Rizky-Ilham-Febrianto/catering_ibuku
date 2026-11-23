import 'package:flutter/material.dart';
import '../../models/makanan.dart';
import '../../services/menu_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/menu_image.dart';
import 'menu_form_screen.dart';

class MenuListScreen extends StatelessWidget {
  const MenuListScreen({super.key});

  Future<void> _hapus(BuildContext context, Makanan m) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus menu?'),
        content: Text('"${m.nama}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ya == true) {
      await MenuService().hapus(m.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu dihapus')),
        );
      }
    }
  }

  void _bukaForm(BuildContext context, [Makanan? m]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MenuFormScreen(makanan: m)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = MenuService();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(context),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Menu'),
      ),
      body: StreamBuilder<List<Makanan>>(
        stream: service.semuaMenu(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Gagal memuat: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Belum ada menu.\nTekan "Tambah Menu" untuk mulai.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final m = list[i];
              return Card(
                margin: EdgeInsets.zero,
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.light),
                ),
                child: ListTile(
                  onTap: () => _bukaForm(context, m),
                  leading: MenuImage(foto: m.foto),
                  title: Text(
                    m.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${formatRupiah(m.harga)}  •  ${m.kategori}'
                    '${m.tersedia ? '' : '  •  Habis'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: m.tersedia,
                        activeThumbColor: AppColors.green,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        onChanged: (v) => service.setTersedia(m.id, v),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'edit') _bukaForm(context, m);
                          if (v == 'hapus') _hapus(context, m);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('Ubah')),
                          PopupMenuItem(value: 'hapus', child: Text('Hapus')),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}