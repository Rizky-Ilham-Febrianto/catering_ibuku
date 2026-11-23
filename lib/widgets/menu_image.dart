import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class MenuImage extends StatelessWidget {
  final String foto;
  final double width;
  final double height;
  final double radius;

  const MenuImage({
    super.key,
    required this.foto,
    this.width = 56,
    this.height = 56,
    this.radius = 12,
  });

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: AppColors.light,
        alignment: Alignment.center,
        child: Text('🍱', style: TextStyle(fontSize: height * 0.45)),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: foto.isEmpty
          ? _placeholder()
          : Image.memory(
              base64Decode(foto),
              width: width,
              height: height,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => _placeholder(),
            ),
    );
  }
}