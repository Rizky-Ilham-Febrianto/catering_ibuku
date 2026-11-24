class Pengaturan {
  final String namaUsaha;
  final String tentang;
  final String alamatUsaha;
  final String noWa;
  final List<int> hariBuka; // 1 = Senin ... 7 = Minggu
  final String jamBuka; // format 'HH:mm'
  final String jamTutup;
  final String namaBank;
  final String noRekening;
  final String atasNama;
  final String qris; // gambar base64, boleh kosong

  const Pengaturan({
    this.namaUsaha = 'Catering Ibuku',
    this.tentang = '',
    this.alamatUsaha = '',
    this.noWa = '',
    this.hariBuka = const [1, 2, 3, 4, 5, 6],
    this.jamBuka = '08:00',
    this.jamTutup = '20:00',
    this.namaBank = '',
    this.noRekening = '',
    this.atasNama = '',
    this.qris = '',
  });

  static const namaHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  String get ringkasHari {
    final h = [...hariBuka]..sort();
    if (h.length == 7) return 'Setiap hari';
    if (h.isEmpty) return 'Belum diatur';
    return h.map((d) => namaHari[d - 1]).join(', ');
  }

  Map<String, dynamic> toMap() => {
        'namaUsaha': namaUsaha,
        'tentang': tentang,
        'alamatUsaha': alamatUsaha,
        'noWa': noWa,
        'hariBuka': hariBuka,
        'jamBuka': jamBuka,
        'jamTutup': jamTutup,
        'namaBank': namaBank,
        'noRekening': noRekening,
        'atasNama': atasNama,
        'qris': qris,
      };

  factory Pengaturan.fromMap(Map<String, dynamic> m) => Pengaturan(
        namaUsaha: m['namaUsaha'] ?? 'Catering Ibuku',
        tentang: m['tentang'] ?? '',
        alamatUsaha: m['alamatUsaha'] ?? '',
        noWa: m['noWa'] ?? '',
        hariBuka: ((m['hariBuka'] ?? [1, 2, 3, 4, 5, 6]) as List)
            .map((e) => (e as num).toInt())
            .toList(),
        jamBuka: m['jamBuka'] ?? '08:00',
        jamTutup: m['jamTutup'] ?? '20:00',
        namaBank: m['namaBank'] ?? '',
        noRekening: m['noRekening'] ?? '',
        atasNama: m['atasNama'] ?? '',
        qris: m['qris'] ?? '',
      );
}