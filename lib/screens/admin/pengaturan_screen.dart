import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/pengaturan.dart';
import '../../services/settings_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_helper.dart';
import '../../widgets/konfirmasi_keluar.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  late final Future<Pengaturan> _future = SettingsService().ambil();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pengaturan>(
      future: _future,
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Gagal memuat: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return _FormPengaturan(awal: snap.data!);
      },
    );
  }
}

class _FormPengaturan extends StatefulWidget {
  final Pengaturan awal;
  const _FormPengaturan({required this.awal});

  @override
  State<_FormPengaturan> createState() => _FormPengaturanState();
}

class _FormPengaturanState extends State<_FormPengaturan> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaC;
  late final TextEditingController _tentangC;
  late final TextEditingController _alamatC;
  late final TextEditingController _waC;
  late final TextEditingController _bankC;
  late final TextEditingController _rekC;
  late final TextEditingController _atasNamaC;
  late Set<int> _hari;
  late String _jamBuka;
  late String _jamTutup;
  late String _qris;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.awal;
    _namaC = TextEditingController(text: p.namaUsaha);
    _tentangC = TextEditingController(text: p.tentang);
    _alamatC = TextEditingController(text: p.alamatUsaha);
    _waC = TextEditingController(text: p.noWa);
    _bankC = TextEditingController(text: p.namaBank);
    _rekC = TextEditingController(text: p.noRekening);
    _atasNamaC = TextEditingController(text: p.atasNama);
    _hari = p.hariBuka.toSet();
    _jamBuka = p.jamBuka;
    _jamTutup = p.jamTutup;
    _qris = p.qris;
  }

  @override
  void dispose() {
    _namaC.dispose();
    _tentangC.dispose();
    _alamatC.dispose();
    _waC.dispose();
    _bankC.dispose();
    _rekC.dispose();
    _atasNamaC.dispose();
    super.dispose();
  }

  TimeOfDay _parse(String s) {
    final p = s.split(':');
    return TimeOfDay(
      hour: int.tryParse(p[0]) ?? 8,
      minute: int.tryParse(p.length > 1 ? p[1] : '0') ?? 0,
    );
  }

  Future<void> _pilihJam(bool buka) async {
    final t = await showTimePicker(
      context: context,
      initialTime: _parse(buka ? _jamBuka : _jamTutup),
    );
    if (t == null) return;
    final s =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (buka) {
        _jamBuka = s;
      } else {
        _jamTutup = s;
      }
    });
  }

  Future<void> _pilihQris() async {
    final g = await pilihGambarBase64(
      context,
      maxWidth: 800,
      quality: 80,
      batas: 700000,
    );
    if (g != null) setState(() => _qris = g);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_hari.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu hari buka')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      await SettingsService().simpan(
        Pengaturan(
          namaUsaha: _namaC.text.trim(),
          tentang: _tentangC.text.trim(),
          alamatUsaha: _alamatC.text.trim(),
          noWa: _waC.text.trim(),
          hariBuka: _hari.toList()..sort(),
          jamBuka: _jamBuka,
          jamTutup: _jamTutup,
          namaBank: _bankC.text.trim(),
          noRekening: _rekC.text.trim(),
          atasNama: _atasNamaC.text.trim(),
          qris: _qris,
        ),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Pengaturan disimpan')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _judul(String teks, IconData ikon) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Row(
          children: [
            Icon(ikon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              teks,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
      );

  Widget _kolomJam(String label, String nilai, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.access_time),
          ),
          child: Text(nilai),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          _judul('Info Usaha', Icons.storefront_outlined),
          TextFormField(
            controller: _namaC,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Nama usaha'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Nama usaha wajib diisi'
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _tentangC,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Cerita singkat usaha (tampil di beranda)',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _alamatC,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Alamat dapur / usaha',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          _judul('Jam Operasional', Icons.schedule),
          Wrap(
            spacing: 6,
            children: List.generate(7, (i) {
              final hari = i + 1;
              final aktif = _hari.contains(hari);
              return FilterChip(
                label: Text(Pengaturan.namaHari[i]),
                selected: aktif,
                showCheckmark: false,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: aktif ? Colors.white : AppColors.dark,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (v) => setState(() {
                  if (v) {
                    _hari.add(hari);
                  } else {
                    _hari.remove(hari);
                  }
                }),
              );
            }),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _kolomJam('Jam buka', _jamBuka, () => _pilihJam(true)),
              const SizedBox(width: 12),
              _kolomJam('Jam tutup', _jamTutup, () => _pilihJam(false)),
            ],
          ),
          _judul('Kontak WhatsApp', Icons.chat_outlined),
          TextFormField(
            controller: _waC,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Contoh: 081234567890',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Nomor WhatsApp wajib diisi';
              }
              if (v.trim().length < 9) return 'Nomor tidak valid';
              return null;
            },
          ),
          _judul('Pembayaran', Icons.account_balance_wallet_outlined),
          TextFormField(
            controller: _bankC,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              hintText: 'Nama bank (contoh: BCA, BRI, Mandiri)',
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _rekC,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'Nomor rekening'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _atasNamaC,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Atas nama pemilik rekening',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gambar QRIS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 8),
          if (_qris.isNotEmpty)
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.light),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.memory(
                    base64Decode(_qris),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Center(child: Text('Gambar rusak')),
                  ),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _pilihQris,
                icon: const Icon(Icons.qr_code_2),
                label: Text(_qris.isEmpty ? 'Pilih gambar QRIS' : 'Ganti'),
              ),
              if (_qris.isNotEmpty)
                TextButton.icon(
                  onPressed: () => setState(() => _qris = ''),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Hapus'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loading ? null : _simpan,
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan Perubahan'),
          ),
          const SizedBox(height: 28),
          const Divider(),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => konfirmasiKeluar(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade700),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ),
        ],
      ),
    );
  }
}