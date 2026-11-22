import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> register({
    required String nama,
    required String email,
    required String password,
    required String noHp,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = AppUser(
      uid: cred.user!.uid,
      nama: nama,
      email: email,
      noHp: noHp,
      role: 'pelanggan', // pendaftar baru selalu pelanggan
    );
    await _db.collection('users').doc(user.uid).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() => _auth.signOut();

  Stream<AppUser?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.data()!, doc.id);
    });
  }

  static String pesanError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (minimal 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email atau kata sandi salah';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      default:
        return 'Terjadi kesalahan (${e.code})';
    }
  }
}