import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/pesanan.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_badge.dart';

class PesananScreen extends StatefulWidget {
  final AppUser user;
  const PesananScreen({super.key, required this.user});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  late final Stream<List<Pesanan>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = OrderService().pesananSaya(widget.user.uid);
  }

  void _lihatDetail(Pesanan p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailPesanan(pesanan: p),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Pesanan>>(
      stream: _stream,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('📦', style: TextStyle(fontSize: 56)),
                SizedBox(height: 8),
                Text(
                  'Belum ada pesanan',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final p = list[i];
            return Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.light),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _lihatDetail(p),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            p.nomor,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          const Spacer(),
                          StatusBadge(status: p.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.ringkasan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.event,
                              size: 14, color: AppColors.muted),
                          const SizedBox(width: 4),
                          Text(
                            formatTanggal(p.tanggalAntar),
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.muted),
                          ),
                          const Spacer(),
                          Text(
                            formatRupiah(p.total),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailPesanan extends StatelessWidget {
  final Pesanan pesanan;
  const _DetailPesanan({required this.pesanan});

  Widget _info(String label, String isi) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            Text(isi, style: const TextStyle(color: AppColors.dark)),
          ],
        ),
      );

  Widget _baris(String kiri, String kanan, {bool tebal = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(kiri)),
            Text(
              kanan,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: tebal ? AppColors.primary : AppColors.dark,
              ),
            ),
          ],
        ),
      );

  Future<void> _batalkan(BuildContext context) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan pesanan?'),
        content: Text('Pesanan ${pesanan.nomor} akan dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, batalkan',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ya != true) return;
    await OrderService().batalkan(pesanan.id);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final p = pesanan;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Text(
                'Pesanan ${p.nomor}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const Spacer(),
              StatusBadge(status: p.status),
            ],
          ),
          const SizedBox(height: 16),
          _info('Tanggal antar', formatTanggal(p.tanggalAntar)),
          _info('Alamat', p.alamat),
          _info('Metode pembayaran', p.metodeBayar),
          if (p.catatan.isNotEmpty) _info('Catatan', p.catatan),
          const Divider(),
          ...p.items.map(
              (i) => _baris('${i.jumlah}x ${i.nama}', formatRupiah(i.subtotal))),
          const Divider(),
          _baris('Subtotal', formatRupiah(p.subtotal)),
          _baris('Ongkos kirim', formatRupiah(p.ongkir)),
          _baris('Total', formatRupiah(p.total), tebal: true),
          if (p.status == 'menunggu') ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => _batalkan(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Batalkan Pesanan'),
            ),
          ],
        ],
      ),
    );
  }
}