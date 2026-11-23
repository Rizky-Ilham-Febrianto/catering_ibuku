import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/makanan.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/menu_image.dart';

class DetailScreen extends StatefulWidget {
  final Makanan makanan;
  const DetailScreen({super.key, required this.makanan});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late int _jumlah;

  @override
  void initState() {
    super.initState();
    _jumlah = widget.makanan.minPorsi;
  }

  void _tambahKeranjang() {
    final messenger = ScaffoldMessenger.of(context);
    context.read<CartProvider>().tambah(widget.makanan, _jumlah);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('$_jumlah porsi ${widget.makanan.nama} masuk keranjang'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.makanan;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Makanan'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuImage(
              foto: m.foto,
              width: double.infinity,
              height: 240,
              radius: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.nama,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                      Text(
                        formatRupiah(m.harga),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        label: Text(m.kategori),
                        backgroundColor: AppColors.light,
                        side: BorderSide.none,
                      ),
                      Chip(
                        label: Text('Min. ${m.minPorsi} porsi'),
                        backgroundColor: AppColors.light,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.deskripsi.isEmpty
                        ? 'Masakan rumahan buatan Ibu.'
                        : m.deskripsi,
                    style: const TextStyle(color: AppColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Jumlah porsi',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.dark),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.light,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _jumlah > m.minPorsi
                              ? () => setState(() => _jumlah--)
                              : null,
                          icon: const Icon(Icons.remove_circle),
                          color: AppColors.primary,
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '$_jumlah',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _jumlah++),
                          icon: const Icon(Icons.add_circle),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                  Text(
                    formatRupiah(m.harga * _jumlah),
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
                  onPressed: m.tersedia ? _tambahKeranjang : null,
                  child: Text(
                      m.tersedia ? 'Tambah ke Keranjang' : 'Sedang Habis'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}