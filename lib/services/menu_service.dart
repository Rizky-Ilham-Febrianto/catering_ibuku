import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/makanan.dart';

class MenuService {
  final _col = FirebaseFirestore.instance.collection('menus');

  Stream<List<Makanan>> semuaMenu() {
    return _col.orderBy('nama').snapshots().map(
          (snap) => snap.docs
              .map((d) => Makanan.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  Future<void> tambah(Makanan m) =>
      _col.add({...m.toMap(), 'createdAt': FieldValue.serverTimestamp()});

  Future<void> ubah(Makanan m) => _col.doc(m.id).update(m.toMap());

  Future<void> hapus(String id) => _col.doc(id).delete();

  Future<void> setTersedia(String id, bool nilai) =>
      _col.doc(id).update({'tersedia': nilai});
}