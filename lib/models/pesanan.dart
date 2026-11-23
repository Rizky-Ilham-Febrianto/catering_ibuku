import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPesanan {
  final String menuId;
  final String nama;
  final int harga;
  final int jumlah;

  ItemPesanan({
    required this.menuId,
    required this.nama,
    required this.harga,
    required this.jumlah,
  });

  int get subtotal => harga * jumlah;

  Map<String, dynamic> toMap() => {
        'menuId': menuId,
        'nama': nama,
        'harga': harga,
        'jumlah': jumlah,
      };

  factory ItemPesanan.fromMap(Map<String, dynamic> m) => ItemPesanan(
        menuId: m['menuId'] ?? '',
        nama: m['nama'] ?? '',
        harga: (m['harga'] ?? 0).toInt(),
        jumlah: (m['jumlah'] ?? 0).toInt(),
      );
}

class Pesanan {
  final String id;
  final String userId;
  final String namaPelanggan;
  final String noHp;
  final List<ItemPesanan> items;
  final int subtotal;
  final int ongkir;
  final int total;
  final String alamat;
  final DateTime tanggalAntar;
  final String catatan;
  final String metodeBayar;
  final String status; // menunggu, diproses, diantar, selesai, dibatalkan
  final DateTime? createdAt;

  Pesanan({
    required this.id,
    required this.userId,
    required this.namaPelanggan,
    required this.noHp,
    required this.items,
    required this.subtotal,
    required this.ongkir,
    required this.total,
    required this.alamat,
    required this.tanggalAntar,
    required this.catatan,
    required this.metodeBayar,
    required this.status,
    required this.createdAt,
  });

  String get nomor =>
      '#${id.substring(0, id.length < 5 ? id.length : 5).toUpperCase()}';

  String get ringkasan =>
      items.map((i) => '${i.jumlah}x ${i.nama}').join(', ');

  factory Pesanan.fromMap(Map<String, dynamic> map, String id) => Pesanan(
        id: id,
        userId: map['userId'] ?? '',
        namaPelanggan: map['namaPelanggan'] ?? '',
        noHp: map['noHp'] ?? '',
        items: ((map['items'] ?? []) as List)
            .map((e) => ItemPesanan.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        subtotal: (map['subtotal'] ?? 0).toInt(),
        ongkir: (map['ongkir'] ?? 0).toInt(),
        total: (map['total'] ?? 0).toInt(),
        alamat: map['alamat'] ?? '',
        tanggalAntar:
            (map['tanggalAntar'] as Timestamp?)?.toDate() ?? DateTime.now(),
        catatan: map['catatan'] ?? '',
        metodeBayar: map['metodeBayar'] ?? '',
        status: map['status'] ?? 'menunggu',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      );
}