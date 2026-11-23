import 'package:flutter/material.dart';
import '../models/makanan.dart';
import '../utils/app_colors.dart';
import '../utils/formatters.dart';
import 'menu_image.dart';

class FoodCard extends StatelessWidget {
  final Makanan makanan;
  final VoidCallback onTap;
  const FoodCard({super.key, required this.makanan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final m = makanan;
    return Opacity(
      opacity: m.tersedia ? 1 : 0.5,
      child: Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.light),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                MenuImage(foto: m.foto, width: 76, height: 76),
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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.deskripsi.isEmpty ? m.kategori : m.deskripsi,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.muted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            formatRupiah(m.harga),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            m.tersedia ? 'Min. ${m.minPorsi} porsi' : 'Habis',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: m.tersedia
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: m.tersedia
                                  ? AppColors.muted
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}