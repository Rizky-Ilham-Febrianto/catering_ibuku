import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pengaturan.dart';

class SettingsService {
  final _doc = FirebaseFirestore.instance.collection('settings').doc('usaha');

  Future<Pengaturan> ambil() async {
    final d = await _doc.get();
    return d.exists ? Pengaturan.fromMap(d.data()!) : const Pengaturan();
  }

  Stream<Pengaturan> stream() => _doc.snapshots().map(
        (d) => d.exists ? Pengaturan.fromMap(d.data()!) : const Pengaturan(),
      );

  Future<void> simpan(Pengaturan p) => _doc.set(p.toMap());
}