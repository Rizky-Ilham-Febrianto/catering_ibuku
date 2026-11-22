import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class CustomerHome extends StatelessWidget {
  final AppUser user;
  const CustomerHome({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catering Ibuku'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Halo, ${user.nama}! 👋',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Role: Pelanggan'),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => AuthService().logout(),
                child: const Text('Keluar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}