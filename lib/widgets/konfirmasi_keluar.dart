import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

Future<void> konfirmasiKeluar(
  BuildContext context, {
  VoidCallback? sebelumKeluar,
}) async {
  final ya = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: const Icon(Icons.logout, size: 32, color: AppColors.primary),
      title: const Text('Keluar dari akun?'),
      content: const Text(
        'Anda perlu masuk lagi untuk memakai aplikasi.',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            'Ya, keluar',
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
  if (ya == true) {
    sebelumKeluar?.call();
    await AuthService().logout();
  }
}