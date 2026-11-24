import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pesanan.dart';
import '../../utils/app_colors.dart';
import '../../utils/formatters.dart';
import '../../widgets/stat_card.dart';

class LaporanScreen extends StatefulWidget {
  final List<Pesanan> pesanan;
  const LaporanScreen({super.key, required this.pesanan});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  int _hari = 7;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final mulai = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: _hari - 1));

    final selesai = widget.pesanan
        .where((p) => p.status == 'selesai' && !p.tanggalMasuk.isBefore(mulai))
        .toList();

    final omzet = selesai.fold<int>(0, (s, p) => s + p.total);
    final jumlah = selesai.length;
    final rata = jumlah == 0 ? 0 : omzet ~/ jumlah;

    // Omzet per hari
    final tanggalList =
        List.generate(_hari, (i) => mulai.add(Duration(days: i)));
    final omzetHari = tanggalList
        .map((d) => selesai
            .where((p) => sameDay(p.tanggalMasuk, d))
            .fold<int>(0, (s, p) => s + p.total))
        .toList();
    final maks = omzetHari.fold<int>(0, (a, b) => b > a ? b : a);

    // Menu terlaris
    final porsi = <String, int>{};
    for (final p in selesai) {
      for (final i in p.items) {
        porsi[i.nama] = (porsi[i.nama] ?? 0) + i.jumlah;
      }
    }
    final terlaris = porsi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final teratas = terlaris.take(5).toList();
    final maksPorsi = teratas.isEmpty ? 1 : teratas.first.value;

    final fmt = DateFormat('d MMM', 'id_ID');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [7, 30].map((h) {
            final aktif = _hari == h;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text('$h Hari'),
                selected: aktif,
                showCheckmark: false,
                selectedColor: AppColors.dark,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: aktif ? Colors.white : AppColors.dark,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => _hari = h),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                ikon: Icons.payments_outlined,
                nilai: formatRupiah(omzet),
                label: 'Total pendapatan',
                warna: AppColors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                ikon: Icons.check_circle_outline,
                nilai: '$jumlah',
                label: 'Pesanan selesai',
                warna: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatCard(
          ikon: Icons.trending_up,
          nilai: formatRupiah(rata),
          label: 'Rata-rata per pesanan',
          warna: const Color(0xFF3D85C6),
        ),
        const SizedBox(height: 20),
        const Text(
          'Pendapatan per Hari',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.light),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 130,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(_hari, (i) {
                    final v = omzetHari[i];
                    final tinggi = maks == 0 ? 4.0 : 4 + (v / maks) * 100;
                    final tertinggi = v > 0 && v == maks;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: _hari == 7 ? 4 : 1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: tinggi,
                              decoration: BoxDecoration(
                                color: tertinggi
                                    ? AppColors.primary
                                    : AppColors.accent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            if (_hari == 7) ...[
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('E', 'id_ID')
                                    .format(tanggalList[i]),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(fmt.format(tanggalList.first),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                  Text(fmt.format(tanggalList.last),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Menu Terlaris',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        const SizedBox(height: 10),
        if (teratas.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'Belum ada pesanan selesai pada periode ini.\n'
                'Tandai pesanan sebagai "Selesai" agar masuk laporan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.light),
            ),
            child: Column(
              children: List.generate(teratas.length, (i) {
                final e = teratas[i];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i == teratas.length - 1 ? 0 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${i + 1}. ${e.key}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                          Text(
                            '${e.value} porsi',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: e.value / maksPorsi,
                          minHeight: 8,
                          backgroundColor: AppColors.light,
                          color: i == 0 ? AppColors.primary : AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}