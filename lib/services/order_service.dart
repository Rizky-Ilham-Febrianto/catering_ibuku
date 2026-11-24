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

  List<Pesanan> _urutkan(QuerySnapshot<Map<String, dynamic>> snap) {
    final list =
        snap.docs.map((d) => Pesanan.fromMap(d.data(), d.id)).toList();
    list.sort((a, b) => b.tanggalMasuk.compareTo(a.tanggalMasuk));
    return list;
  }

  // Sisi pelanggan: hanya pesanan miliknya
  Stream<List<Pesanan>> pesananSaya(String uid) {
    return _col
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(_urutkan);
  }

  // Sisi admin: semua pesanan
  Stream<List<Pesanan>> semuaPesanan() {
    return _col.snapshots().map(_urutkan);
  }

  Future<void> ubahStatus(String id, String status) =>
      _col.doc(id).update({'status': status});

  Future<void> batalkan(String id) => ubahStatus(id, 'dibatalkan');
}