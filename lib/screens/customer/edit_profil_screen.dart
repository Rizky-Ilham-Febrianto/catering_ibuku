import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class EditProfilScreen extends StatefulWidget {
  final AppUser user;
  const EditProfilScreen({super.key, required this.user});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaC;
  late final TextEditingController _hpC;
  late final TextEditingController _alamatC;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.user.nama);
    _hpC = TextEditingController(text: widget.user.noHp);
    _alamatC = TextEditingController(text: widget.user.alamat);
  }

  @override
  void dispose() {
    _namaC.dispose();
    _hpC.dispose();
    _alamatC.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => _loading = true);
    try {
      await AuthService().ubahProfil(
        uid: widget.user.uid,
        nama: _namaC.text.trim(),
        noHp: _hpC.text.trim(),
        alamat: _alamatC.text.trim(),
      );
      nav.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Profil diperbarui')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      messenger.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Data Diri'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _namaC,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Nama lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hpC,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'No. HP / WhatsApp',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'No. HP wajib diisi';
                    }
                    if (v.trim().length < 9) return 'No. HP tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _alamatC,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Alamat rumah (jalan, nomor, patokan)',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Isi alamat dengan lengkap'
                      : null,
                ),
                const SizedBox(height: 24),
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
                      : const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}