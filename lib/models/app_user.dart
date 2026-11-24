class AppUser {
  final String uid;
  final String nama;
  final String email;
  final String noHp;
  final String alamat;
  final String foto; // gambar base64, boleh kosong
  final String role; // 'pelanggan' atau 'admin'

  AppUser({
    required this.uid,
    required this.nama,
    required this.email,
    required this.noHp,
    this.alamat = '',
    this.foto = '',
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() => {
        'nama': nama,
        'email': email,
        'noHp': noHp,
        'alamat': alamat,
        'foto': foto,
        'role': role,
      };

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) => AppUser(
        uid: uid,
        nama: map['nama'] ?? '',
        email: map['email'] ?? '',
        noHp: map['noHp'] ?? '',
        alamat: map['alamat'] ?? '',
        foto: map['foto'] ?? '',
        role: map['role'] ?? 'pelanggan',
      );
}