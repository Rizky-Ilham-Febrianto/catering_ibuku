import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'models/app_user.dart';
import 'screens/admin/admin_home.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_home.dart';
import 'services/auth_service.dart';
import 'utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('id_ID', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const CateringIbuku(),
    ),
  );
}

class CateringIbuku extends StatelessWidget {
  const CateringIbuku({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catering Ibuku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return StreamBuilder<User?>(
      stream: auth.authChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }
        final firebaseUser = snap.data;
        if (firebaseUser == null) return const LoginScreen();

        return StreamBuilder<AppUser?>(
          stream: auth.userStream(firebaseUser.uid),
          builder: (context, userSnap) {
            final user = userSnap.data;
            if (user == null) return const _Loading();
            return user.isAdmin
                ? AdminHome(user: user)
                : CustomerHome(user: user);
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}