import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color navy = Color(0xFF022B3A);
  static const Color yellow = Color(0xFFF7B32B);
  static const Color bg = Color(0xFFF5F5F0);
  static const Color grey = Color(0xFF817F75);
  static const Color cardWhite = Color(0xFFFFFFFF);

  static TextStyle playfair({
    double size = 16,
    FontWeight weight = FontWeight.w700,
    Color color = navy,
  }) => GoogleFonts.playfairDisplay(
    fontSize: size,
    fontWeight: weight,
    color: color,
  );

  static TextStyle inter({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = navy,
  }) => GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);
}
