import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/menu_image.dart';
import 'checkout_screen.dart';

class KeranjangScreen extends StatelessWidget {
  final AppUser user;
  final VoidCallback onPesananDibuat;
  const KeranjangScreen({
    super.key,
    required this.user,
    required this.onPesananDibuat,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.kosong) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🛒', style: TextStyle(fontSize: 56)),
            SizedBox(height: 8),
            Text(
              'Keranjang masih kosong',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final item = cart.items[i];
              final m = item.makanan;
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.light),
                ),
                child: Row(
                  children: [
                    MenuImage(foto: m.foto, width: 64, height: 64),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            formatRupiah(item.subtotal),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: item.jumlah > m.minPorsi
                                    ? () => cart.ubahJumlah(
                                        m.id, item.jumlah - 1)
                                    : null,
                                icon: const Icon(Icons.remove_circle_outline),
                                color: AppColors.primary,
                              ),
                              Text(
                                '${item.jumlah}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                onPressed: () =>
                                    cart.ubahJumlah(m.id, item.jumlah + 1),
                                icon: const Icon(Icons.add_circle_outline),
                                color: AppColors.primary,
                              ),
                              const Spacer(),
                              Text(
                                'Min. ${m.minPorsi}',
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => cart.hapus(m.id),
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.shade700,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.light)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Subtotal',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  Text(
                    formatRupiah(cart.totalHarga),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final berhasil = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(user: user),
                      ),
                    );
                    if (berhasil == true) onPesananDibuat();
                  },
                  child: const Text('Checkout'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}