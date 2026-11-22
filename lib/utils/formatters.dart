import 'package:intl/intl.dart';

String formatRupiah(num nilai) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  ).format(nilai);
}

String formatTanggal(DateTime tanggal) {
  return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(tanggal);
}