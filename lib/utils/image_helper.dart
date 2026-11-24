import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Memilih gambar dari galeri, mengecilkannya, lalu mengembalikannya
/// dalam bentuk base64. Mengembalikan null jika dibatalkan atau terlalu besar.
Future<String?> pilihGambarBase64(
  BuildContext context, {
  double maxWidth = 600,
  int quality = 60,
  int batas = 700000,
}) async {
  final x = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: maxWidth,
    imageQuality: quality,
  );
  if (x == null) return null;
  final b64 = base64Encode(await x.readAsBytes());
  if (b64.length > batas) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar terlalu besar, pilih gambar lain')),
      );
    }
    return null;
  }
  return b64;
}