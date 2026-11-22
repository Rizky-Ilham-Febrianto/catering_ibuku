import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const CateringIbuku());
}

class CateringIbuku extends StatelessWidget {
  const CateringIbuku({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catering Ibuku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const LoginScreen(),
    );
  }
}