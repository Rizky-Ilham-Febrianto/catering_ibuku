import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/pesanan.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  final AppUser user;
  final List<Pesanan> pesanan;
  final VoidCallback onLihatPesanan;

  const DashboardScreen({
    super.key,
    required this.user,
    required this.pesanan,
    required this.onLihatPesanan,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final menunggu = pesanan.where((p) => p.status == 'menunggu').toList();
    final aktif = pesanan
        .where((p) => p.status == 'diproses' || p.status == 'diantar')
        .length;
    final hariIni = pesanan
        .where((p) => sameDay(p.tanggalMasuk, now) && p.status != 'dibatalkan')
        .length;
    final pendapatan = pesanan
        .where((p) => p.status == 'selesai' && sameDay(p.tanggalMasuk, now))
        .fold<int>(0, (s, p) => s + p.total);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Halo, ${user.nama}! 👩‍🍳',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        Text(
          formatTanggal(now).split(',').first,
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                ikon: Icons.hourglass_top,
                nilai: '${menunggu.length}',
                label: 'Menunggu konfirmasi',
                warna: const Color(0xFFD98A12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                ikon: Icons.local_shipping_outlined,
                nilai: '$aktif',
                label: 'Diproses / diantar',
                warna: const Color(0xFF3D85C6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                ikon: Icons.receipt_long,
                nilai: '$hariIni',
                label: 'Pesanan masuk hari ini',
                warna: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                ikon: Icons.payments_outlined,
                nilai: formatRupiah(pendapatan),
                label: 'Pendapatan hari ini',
                warna: AppColors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Pendapatan dihitung dari pesanan berstatus Selesai.',
          style: TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Perlu Dikonfirmasi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
            ),
            TextButton(
              onPressed: onLihatPesanan,
              child: const Text('Lihat semua'),
            ),
          ],
        ),
        if (menunggu.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Tidak ada pesanan baru 🎉',
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          )
        else
          ...menunggu.take(5).map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.light),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onLihatPesanan,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${p.nomor} • ${p.namaPelanggan}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    p.ringkasan,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formatRupiah(p.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}