import 'package:flutter/material.dart';

/// Savanna Fibre colour tokens.
///
/// The palette pairs the brand's sunset orange with a deep "night sky" ink
/// used for the plan card and navigation. Orange is reserved for actions and
/// the fibre-light motif, so it keeps its meaning across the app.
@immutable
class SfPalette extends ThemeExtension<SfPalette> {
  const SfPalette({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.accent,
    required this.accentDeep,
    required this.accentSoft,
    required this.onAccent,
    required this.hero,
    required this.heroRaised,
    required this.heroInk,
    required this.heroMuted,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
  });

  final Color bg, surface, surfaceAlt, line, ink, inkMuted;
  final Color accent, accentDeep, accentSoft, onAccent;
  final Color hero, heroRaised, heroInk, heroMuted;
  final Color success, successSoft, warning, warningSoft, danger, dangerSoft;

  /// Light gold to sunset orange to ember: the colour of light in the fibre.
  List<Color> get fibreLight => const [Color(0xFFE2601C), Color(0xFFF7901E), Color(0xFFFFC46B)];

  static const light = SfPalette(
    bg: Color(0xFFF3F3F1),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEDECE8),
    line: Color(0xFFE4E3DE),
    ink: Color(0xFF1B1A24),
    inkMuted: Color(0xFF686775),
    accent: Color(0xFFF7901E),
    accentDeep: Color(0xFFC9620A),
    accentSoft: Color(0xFFFDEBD5),
    onAccent: Color(0xFF1B1A24),
    hero: Color(0xFF17162C),
    heroRaised: Color(0xFF26244A),
    heroInk: Color(0xFFFFFFFF),
    heroMuted: Color(0xFFA9A7C6),
    success: Color(0xFF23845A),
    successSoft: Color(0xFFDDF2E7),
    warning: Color(0xFF9A6700),
    warningSoft: Color(0xFFFBF0D2),
    danger: Color(0xFFC53A30),
    dangerSoft: Color(0xFFFBE3E1),
  );

  static const dark = SfPalette(
    bg: Color(0xFF0F0E1C),
    surface: Color(0xFF1A1930),
    surfaceAlt: Color(0xFF232240),
    line: Color(0xFF2E2D4A),
    ink: Color(0xFFF2F1F7),
    inkMuted: Color(0xFFA3A2B8),
    accent: Color(0xFFF7901E),
    accentDeep: Color(0xFFFFB25C),
    accentSoft: Color(0xFF3A2A1A),
    onAccent: Color(0xFF1B1A24),
    hero: Color(0xFF211F42),
    heroRaised: Color(0xFF2E2C58),
    heroInk: Color(0xFFFFFFFF),
    heroMuted: Color(0xFFADABCB),
    success: Color(0xFF4CC38A),
    successSoft: Color(0xFF16352A),
    warning: Color(0xFFE8B23A),
    warningSoft: Color(0xFF3A3016),
    danger: Color(0xFFF0675D),
    dangerSoft: Color(0xFF3D1E1D),
  );

  @override
  SfPalette copyWith() => this;

  @override
  SfPalette lerp(ThemeExtension<SfPalette>? other, double t) {
    if (other is! SfPalette) return this;
    return t < 0.5 ? this : other;
  }
}

extension SfContext on BuildContext {
  SfPalette get sf => Theme.of(this).extension<SfPalette>()!;
  TextTheme get text => Theme.of(this).textTheme;
}
