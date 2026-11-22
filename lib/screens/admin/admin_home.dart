import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class AdminHome extends StatelessWidget {
  final AppUser user;
  const AdminHome({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Catering Ibuku'),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Halo, ${user.nama}! 👩‍🍳',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('Role: Admin'),
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