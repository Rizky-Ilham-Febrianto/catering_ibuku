class AppUser {
  final String uid;
  final String nama;
  final String email;
  final String noHp;
  final String role; // 'pelanggan' atau 'admin'

  AppUser({
    required this.uid,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  Map<String, dynamic> toMap() => {
        'nama': nama,
        'email': email,
        'noHp': noHp,
        'role': role,
      };

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) => AppUser(
        uid: uid,
        nama: map['nama'] ?? '',
        email: map['email'] ?? '',
        noHp: map['noHp'] ?? '',
        role: map['role'] ?? 'pelanggan',
      );
}