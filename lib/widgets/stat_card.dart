import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class StatCard extends StatelessWidget {
  final IconData ikon;
  final String nilai;
  final String label;
  final Color warna;

  const StatCard({
    super.key,
    required this.ikon,
    required this.nilai,
    required this.label,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.light),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, color: warna, size: 20),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              nilai,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}