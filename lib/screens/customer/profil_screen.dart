import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/image_helper.dart';
import '../../widgets/konfirmasi_keluar.dart';
import 'edit_profil_screen.dart';

class ProfilScreen extends StatelessWidget {
  final AppUser user;
  const ProfilScreen({super.key, required this.user});

  Future<void> _gantiFoto(BuildContext context) async {
    final foto = await pilihGambarBase64(
      context,
      maxWidth: 300,
      quality: 70,
      batas: 150000,
    );
    if (foto == null) return;
    try {
      await AuthService().ubahFoto(user.uid, foto);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil diperbarui')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan foto: $e')),
      );
    }
  }

  Widget _baris(IconData ikon, String label, String isi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted)),
                Text(
                  isi.isEmpty ? 'Belum diisi' : isi,
                  style: TextStyle(
                    color: isi.isEmpty ? AppColors.muted : AppColors.dark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inisial = user.nama.isEmpty ? '?' : user.nama[0].toUpperCase();
    final ImageProvider? foto =
        user.foto.isEmpty ? null : MemoryImage(base64Decode(user.foto));

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: GestureDetector(
            onTap: () => _gantiFoto(context),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: AppColors.primary,
                  backgroundImage: foto,
                  child: foto == null
                      ? Text(
                          inisial,
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.cream, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 16, color: AppColors.dark),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            user.nama,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
        ),
        const Center(
          child: Text(
            'Ketuk foto untuk mengganti',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ),
        const SizedBox(height: 20),
        _baris(Icons.email_outlined, 'Email', user.email),
        _baris(Icons.phone_outlined, 'No. HP / WhatsApp', user.noHp),
        _baris(Icons.home_outlined, 'Alamat rumah', user.alamat),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EditProfilScreen(user: user),
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            foregroundColor: AppColors.primary,
          ),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Ubah Data Diri'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
          ),
          onPressed: () => konfirmasiKeluar(
            context,
            sebelumKeluar: () => context.read<CartProvider>().kosongkan(),
          ),
          child: const Text('Keluar'),
        ),
      ],
    );
  }
}