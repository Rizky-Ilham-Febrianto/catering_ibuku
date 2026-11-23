import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';

class CheckoutScreen extends StatefulWidget {
  final AppUser user;
  const CheckoutScreen({super.key, required this.user});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _alamatC = TextEditingController();
  final _catatanC = TextEditingController();
  DateTime? _tanggal;
  String _metode = 'Transfer Bank';
  bool _loading = false;

  static const _metodeList = ['Transfer Bank', 'QRIS', 'Bayar di Tempat'];

  @override
  void dispose() {
    _alamatC.dispose();
    _catatanC.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final besok = DateTime.now().add(const Duration(days: 1));
    final tgl = await showDatePicker(
      context: context,
      initialDate: _tanggal ?? besok,
      firstDate: DateTime(besok.year, besok.month, besok.day),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (tgl == null || !mounted) return;
    final jam = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (jam == null) return;
    setState(() {
      _tanggal = DateTime(tgl.year, tgl.month, tgl.day, jam.hour, jam.minute);
    });
  }

  Future<void> _pesan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal dan jam antar dulu')),
      );
      return;
    }
    final cart = context.read<CartProvider>();
    if (cart.kosong) return;

    setState(() => _loading = true);
    try {
      await OrderService().buat(
        user: widget.user,
        items: cart.items,
        alamat: _alamatC.text.trim(),
        tanggalAntar: _tanggal!,
        catatan: _catatanC.text.trim(),
        metodeBayar: _metode,
      );
      cart.kosongkan();
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibuat 🎉')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat pesanan: $e')),
      );
    }
  }

  Widget _judul(String teks) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(
          teks,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.dark,
          ),
        ),
      );

  Widget _baris(String kiri, String kanan, {bool tebal = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(
              child: Text(
                kiri,
                style: TextStyle(
                  color: tebal ? AppColors.dark : AppColors.muted,
                  fontWeight: tebal ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            Text(
              kanan,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: tebal ? 17 : 14,
                color: tebal ? AppColors.primary : AppColors.dark,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final subtotal = cart.totalHarga;
    const ongkir = OrderService.ongkir;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _judul('Alamat pengantaran'),
                TextFormField(
                  controller: _alamatC,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Alamat lengkap (jalan, nomor, patokan)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Isi alamat dengan lengkap'
                      : null,
                ),
                _judul('Tanggal dan jam antar'),
                InkWell(
                  onTap: _pilihTanggal,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.event_outlined),
                    ),
                    child: Text(
                      _tanggal == null
                          ? 'Pilih tanggal dan jam'
                          : formatTanggal(_tanggal!),
                      style: TextStyle(
                        color:
                            _tanggal == null ? AppColors.muted : AppColors.dark,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Pemesanan minimal H-1 (besok).',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ),
                _judul('Catatan (opsional)'),
                TextFormField(
                  controller: _catatanC,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Misalnya: sambal dipisah, tanpa pedas',
                    prefixIcon: Icon(Icons.edit_note),
                  ),
                ),
                _judul('Metode pembayaran'),
                Wrap(
                  spacing: 8,
                  children: _metodeList.map((m) {
                    final aktif = _metode == m;
                    return ChoiceChip(
                      label: Text(m),
                      selected: aktif,
                      showCheckmark: false,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: aktif ? Colors.white : AppColors.dark,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _metode = m),
                    );
                  }).toList(),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Detail pembayaran akan dikonfirmasi Ibu lewat WhatsApp.',
                    style: TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ),
                _judul('Ringkasan pesanan'),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.light),
                  ),
                  child: Column(
                    children: [
                      ...cart.items.map((i) => _baris(
                            '${i.jumlah}x ${i.makanan.nama}',
                            formatRupiah(i.subtotal),
                          )),
                      const Divider(),
                      _baris('Subtotal', formatRupiah(subtotal)),
                      _baris('Ongkos kirim', formatRupiah(ongkir)),
                      const Divider(),
                      _baris('Total', formatRupiah(subtotal + ongkir),
                          tebal: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loading ? null : _pesan,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Buat Pesanan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}