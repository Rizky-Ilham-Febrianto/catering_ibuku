import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  static Color warna(String s) {
    switch (s) {
      case 'diproses':
        return const Color(0xFF3D85C6);
      case 'diantar':
        return AppColors.primary;
      case 'selesai':
        return AppColors.green;
      case 'dibatalkan':
        return Colors.grey;
      default:
        return const Color(0xFFD98A12); // menunggu
    }
  }

  static String label(String s) {
    switch (s) {
      case 'diproses':
        return 'Diproses';
      case 'diantar':
        return 'Diantar';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: warna(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label(status),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}