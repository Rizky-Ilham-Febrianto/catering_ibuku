import 'package:flutter/foundation.dart';
import '../models/makanan.dart';

class CartItem {
  final Makanan makanan;
  int jumlah;
  CartItem({required this.makanan, required this.jumlah});

  int get subtotal => makanan.harga * jumlah;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get totalItem => _items.values.fold(0, (s, i) => s + i.jumlah);
  int get totalHarga => _items.values.fold(0, (s, i) => s + i.subtotal);
  bool get kosong => _items.isEmpty;

  void tambah(Makanan m, int jumlah) {
    if (_items.containsKey(m.id)) {
      _items[m.id]!.jumlah += jumlah;
    } else {
      _items[m.id] = CartItem(makanan: m, jumlah: jumlah);
    }
    notifyListeners();
  }

  void ubahJumlah(String id, int jumlah) {
    if (_items.containsKey(id) && jumlah > 0) {
      _items[id]!.jumlah = jumlah;
      notifyListeners();
    }
  }

  void hapus(String id) {
    _items.remove(id);
    notifyListeners();
  }

  void kosongkan() {
    _items.clear();
    notifyListeners();
  }
}