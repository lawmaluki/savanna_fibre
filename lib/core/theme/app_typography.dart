import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Sora carries numbers and headings (balances, speeds, days left).
/// Figtree handles everything people read in sentences.
TextTheme buildTextTheme(Color ink, Color muted) {
  TextStyle sora(double size, FontWeight weight, {double height = 1.2, double spacing = 0, Color? color}) =>
      GoogleFonts.sora(fontSize: size, fontWeight: weight, height: height, letterSpacing: spacing, color: color ?? ink);

  TextStyle figtree(double size, FontWeight weight, {double height = 1.4, double spacing = 0, Color? color}) =>
      GoogleFonts.figtree(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
        color: color ?? ink,
      );

  return TextTheme(
    displayLarge: sora(44, FontWeight.w700, height: 1.05, spacing: -1.4),
    displayMedium: sora(36, FontWeight.w700, height: 1.1, spacing: -1.1),
    displaySmall: sora(30, FontWeight.w700, height: 1.12, spacing: -0.8),
    headlineLarge: sora(28, FontWeight.w600, height: 1.15, spacing: -0.6),
    headlineMedium: sora(25, FontWeight.w600, height: 1.2, spacing: -0.5),
    headlineSmall: sora(20, FontWeight.w600, height: 1.25, spacing: -0.3),
    titleLarge: sora(17, FontWeight.w600, height: 1.3, spacing: -0.2),
    titleMedium: figtree(16, FontWeight.w600, height: 1.3),
    titleSmall: figtree(14.5, FontWeight.w600, height: 1.3),
    bodyLarge: figtree(16, FontWeight.w400, height: 1.5),
    bodyMedium: figtree(14.5, FontWeight.w400, height: 1.45),
    bodySmall: figtree(13, FontWeight.w400, height: 1.4, color: muted),
    labelLarge: figtree(15, FontWeight.w600, height: 1.2),
    labelMedium: figtree(13, FontWeight.w500, height: 1.2, color: muted),
    labelSmall: figtree(11.5, FontWeight.w500, height: 1.2, spacing: 0.1, color: muted),
  );
}
