import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/pesanan.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_badge.dart';

class PesananMasukScreen extends StatefulWidget {
  final List<Pesanan> pesanan;
  const PesananMasukScreen({super.key, required this.pesanan});

  @override
  State<PesananMasukScreen> createState() => _PesananMasukScreenState();
}

class _PesananMasukScreenState extends State<PesananMasukScreen> {
  String _filter = 'semua';
  static const _filters = [
    'semua',
    'menunggu',
    'diproses',
    'diantar',
    'selesai',
    'dibatalkan',
  ];

  String _label(String f) => f == 'semua' ? 'Semua' : StatusBadge.label(f);

  int _hitung(String f) => f == 'semua'
      ? widget.pesanan.length
      : widget.pesanan.where((p) => p.status == f).length;

  void _buka(Pesanan p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _DetailAdmin(pesanan: p),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filter == 'semua'
        ? widget.pesanan
        : widget.pesanan.where((p) => p.status == _filter).toList();

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: _filters.map((f) {
              final aktif = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('${_label(f)} (${_hitung(f)})'),
                  selected: aktif,
                  showCheckmark: false,
                  selectedColor: AppColors.dark,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: aktif ? Colors.white : AppColors.dark,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _filter = f),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada pesanan',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return Material(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: p.status == 'menunggu'
                              ? const Color(0xFFD98A12)
                              : AppColors.light,
                          width: p.status == 'menunggu' ? 1.5 : 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _buka(p),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${p.nomor} • ${p.namaPelanggan}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.dark,
                                      ),
                                    ),
                                  ),
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
                                    'Antar: ${formatTanggal(p.tanggalAntar)}',
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
                ),
        ),
      ],
    );
  }
}

class _DetailAdmin extends StatelessWidget {
  final Pesanan pesanan;
  const _DetailAdmin({required this.pesanan});

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

  Future<void> _ubah(BuildContext context, String status, String pesan) async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    try {
      await OrderService().ubahStatus(pesanan.id, status);
      nav.pop();
      messenger.showSnackBar(SnackBar(content: Text(pesan)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  Future<void> _tolak(BuildContext context) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak pesanan?'),
        content: Text('Pesanan ${pesanan.nomor} akan dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, tolak',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ya == true && context.mounted) {
      await _ubah(context, 'dibatalkan', 'Pesanan ditolak');
    }
  }

  Widget _aksi(BuildContext context) {
    switch (pesanan.status) {
      case 'menunggu':
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _tolak(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade700,
                  minimumSize: const Size(0, 48),
                ),
                child: const Text('Tolak'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green),
                onPressed: () =>
                    _ubah(context, 'diproses', 'Pesanan diterima'),
                child: const Text('Terima'),
              ),
            ),
          ],
        );
      case 'diproses':
        return ElevatedButton(
          onPressed: () => _ubah(context, 'diantar', 'Status: sedang diantar'),
          child: const Text('Tandai Diantar'),
        );
      case 'diantar':
        return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
          onPressed: () => _ubah(context, 'selesai', 'Pesanan selesai'),
          child: const Text('Tandai Selesai'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pesanan;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
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
          _info('Pelanggan', p.namaPelanggan),
          Row(
            children: [
              Expanded(child: _info('No. HP / WhatsApp', p.noHp)),
              IconButton(
                tooltip: 'Salin nomor',
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: p.noHp));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No. HP disalin')),
                  );
                },
              ),
            ],
          ),
          _info('Tanggal antar', formatTanggal(p.tanggalAntar)),
          _info('Alamat', p.alamat),
          _info('Metode pembayaran', p.metodeBayar),
          if (p.catatan.isNotEmpty) _info('Catatan', p.catatan),
          const Divider(),
          ...p.items.map((i) =>
              _baris('${i.jumlah}x ${i.nama}', formatRupiah(i.subtotal))),
          const Divider(),
          _baris('Subtotal', formatRupiah(p.subtotal)),
          _baris('Ongkos kirim', formatRupiah(p.ongkir)),
          _baris('Total', formatRupiah(p.total), tebal: true),
          const SizedBox(height: 20),
          _aksi(context),
        ],
      ),
    );
  }
}