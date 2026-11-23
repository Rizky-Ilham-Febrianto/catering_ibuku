class Makanan {
  final String id;
  final String nama;
  final int harga;
  final String deskripsi;
  final String kategori;
  final String foto; // gambar dalam bentuk base64, boleh kosong
  final int minPorsi;
  final bool tersedia;

  static const kategoriList = [
    'Nasi Kotak',
    'Snack',
    'Tumpeng',
    'Minuman',
    'Lainnya',
  ];

  Makanan({
    required this.id,
    required this.nama,
    required this.harga,
    required this.deskripsi,
    required this.kategori,
    required this.foto,
    required this.minPorsi,
    required this.tersedia,
  });

  Map<String, dynamic> toMap() => {
        'nama': nama,
        'harga': harga,
        'deskripsi': deskripsi,
        'kategori': kategori,
        'foto': foto,
        'minPorsi': minPorsi,
        'tersedia': tersedia,
      };

  factory Makanan.fromMap(Map<String, dynamic> map, String id) => Makanan(
        id: id,
        nama: map['nama'] ?? '',
        harga: (map['harga'] ?? 0).toInt(),
        deskripsi: map['deskripsi'] ?? '',
        kategori: map['kategori'] ?? 'Lainnya',
        foto: map['foto'] ?? '',
        minPorsi: (map['minPorsi'] ?? 1).toInt(),
        tersedia: map['tersedia'] ?? true,
      );
}