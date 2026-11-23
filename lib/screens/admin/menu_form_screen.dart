import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/makanan.dart';
import '../../services/menu_service.dart';
import '../../utils/app_colors.dart';
import '../../widgets/menu_image.dart';

class MenuFormScreen extends StatefulWidget {
  final Makanan? makanan; // null = tambah baru, ada isi = ubah
  const MenuFormScreen({super.key, this.makanan});

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaC;
  late final TextEditingController _hargaC;
  late final TextEditingController _deskC;
  late final TextEditingController _minC;
  late String _kategori;
  late bool _tersedia;
  late String _foto;
  bool _loading = false;

  bool get _edit => widget.makanan != null;

  @override
  void initState() {
    super.initState();
    final m = widget.makanan;
    _namaC = TextEditingController(text: m?.nama ?? '');
    _hargaC = TextEditingController(text: m != null ? '${m.harga}' : '');
    _deskC = TextEditingController(text: m?.deskripsi ?? '');
    _minC = TextEditingController(text: m != null ? '${m.minPorsi}' : '1');
    _kategori = m?.kategori ?? Makanan.kategoriList.first;
    _tersedia = m?.tersedia ?? true;
    _foto = m?.foto ?? '';
  }

  @override
  void dispose() {
    _namaC.dispose();
    _hargaC.dispose();
    _deskC.dispose();
    _minC.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      imageQuality: 60,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    final b64 = base64Encode(bytes);
    if (b64.length > 700000) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto terlalu besar, pilih foto lain')),
      );
      return;
    }
    setState(() => _foto = b64);
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final m = Makanan(
        id: widget.makanan?.id ?? '',
        nama: _namaC.text.trim(),
        harga: int.parse(_hargaC.text),
        deskripsi: _deskC.text.trim(),
        kategori: _kategori,
        foto: _foto,
        minPorsi: int.parse(_minC.text),
        tersedia: _tersedia,
      );
      final service = MenuService();
      if (_edit) {
        await service.ubah(m);
      } else {
        await service.tambah(m);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_edit ? 'Menu diperbarui' : 'Menu ditambahkan')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_edit ? 'Ubah Menu' : 'Tambah Menu'),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pilihFoto,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        MenuImage(
                          foto: _foto,
                          width: 140,
                          height: 140,
                          radius: 20,
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: _pilihFoto,
                    child: Text(_foto.isEmpty ? 'Pilih foto' : 'Ganti foto'),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _namaC,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Nama makanan'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _hargaC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'Harga per porsi',
                    prefixText: 'Rp ',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Harga wajib diisi';
                    if (int.parse(v) <= 0) return 'Harga harus lebih dari 0';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _kategori,
                  decoration: const InputDecoration(),
                  items: Makanan.kategoriList
                      .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                      .toList(),
                  onChanged: (v) => setState(() => _kategori = v!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _minC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    hintText: 'Minimal pesanan',
                    suffixText: 'porsi',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    if (int.parse(v) < 1) return 'Minimal 1';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _deskC,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Deskripsi (isi, rasa, lauk pendamping)',
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tersedia untuk dipesan'),
                  value: _tersedia,
                  activeThumbColor: AppColors.green,
                  onChanged: (v) => setState(() => _tersedia = v),
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
                      : Text(_edit ? 'Simpan Perubahan' : 'Simpan Menu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}