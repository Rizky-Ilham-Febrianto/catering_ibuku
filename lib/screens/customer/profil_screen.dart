import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class ProfilScreen extends StatelessWidget {
  final AppUser user;
  const ProfilScreen({super.key, required this.user});

  Widget _baris(IconData ikon, String teks) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light),
      ),
      child: Row(
        children: [
          Icon(ikon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(teks)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inisial =
        user.nama.isEmpty ? '?' : user.nama[0].toUpperCase();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary,
            child: Text(
              inisial,
              style: const TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
        const SizedBox(height: 24),
        _baris(Icons.email_outlined, user.email),
        _baris(Icons.phone_outlined, user.noHp),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: () {
            context.read<CartProvider>().kosongkan();
            AuthService().logout();
          },
          child: const Text('Keluar'),
        ),
      ],
    );
  }
}