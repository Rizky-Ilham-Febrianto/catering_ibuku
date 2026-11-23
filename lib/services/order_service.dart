import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/pesanan.dart';
import '../providers/cart_provider.dart';

class OrderService {
  static const ongkir = 10000; // ubah sesuai kebutuhan, 0 jika gratis
  final _col = FirebaseFirestore.instance.collection('orders');

  Future<void> buat({
    required AppUser user,
    required List<CartItem> items,
    required String alamat,
    required DateTime tanggalAntar,
    required String catatan,
    required String metodeBayar,
  }) async {
    final subtotal = items.fold<int>(0, (s, i) => s + i.subtotal);
    await _col.add({
      'userId': user.uid,
      'namaPelanggan': user.nama,
      'noHp': user.noHp,
      'items': items
          .map((i) => ItemPesanan(
                menuId: i.makanan.id,
                nama: i.makanan.nama,
                harga: i.makanan.harga,
                jumlah: i.jumlah,
              ).toMap())
          .toList(),
      'subtotal': subtotal,
      'ongkir': ongkir,
      'total': subtotal + ongkir,
      'alamat': alamat,
      'tanggalAntar': Timestamp.fromDate(tanggalAntar),
      'catatan': catatan,
      'metodeBayar': metodeBayar,
      'status': 'menunggu',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Diurutkan di aplikasi (bukan di Firestore) supaya tidak perlu membuat index
  Stream<List<Pesanan>> pesananSaya(String uid) {
    return _col.where('userId', isEqualTo: uid).snapshots().map((snap) {
      final list =
          snap.docs.map((d) => Pesanan.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now()));
      return list;
    });
  }

  Future<void> batalkan(String id) =>
      _col.doc(id).update({'status': 'dibatalkan'});
}