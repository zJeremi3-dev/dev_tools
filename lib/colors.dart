import 'package:flutter/material.dart';

Color kBgColor = Color(0xFF0F0F13);
Color kSurfaceColor = Color(0xFF1C1B22);
Color kAccent = Color(0xFF7C3AED);
Color kAccentLight = Color(0xFFAB6CF5);
Color kTextPrimary = Color(0xFFF1F0F5);
Color kTextSecondary = Color(0xFF8B8A96);

int selectedScheme = 1;

class ColorSchemeData {
  final int id;
  final String name;
  final Color bg, surface, accent, accentLight, textPrimary, textSecondary;
  const ColorSchemeData({
    required this.id,
    required this.name,
    required this.bg,
    required this.surface,
    required this.accent,
    required this.accentLight,
    required this.textPrimary,
    required this.textSecondary,
  });
}

const List<ColorSchemeData> kColorSchemes = [
  ColorSchemeData(
    id: 1,
    name: "Violet",
    bg: Color(0xFF0F0F13),
    surface: Color(0xFF1C1B22),
    accent: Color(0xFF7C3AED),
    accentLight: Color(0xFFAB6CF5),
    textPrimary: Color(0xFFF1F0F5),
    textSecondary: Color(0xFF8B8A96),
  ),
  ColorSchemeData(
    id: 2,
    name: "Ocean Blue",
    bg: Color(0xFF0B0F14),
    surface: Color(0xFF161C24),
    accent: Color(0xFF2563EB),
    accentLight: Color(0xFF60A5FA),
    textPrimary: Color(0xFFEEF2F6),
    textSecondary: Color(0xFF8792A2),
  ),
  ColorSchemeData(
    id: 3,
    name: "Emerald Green",
    bg: Color(0xFF0C1210),
    surface: Color(0xFF17201C),
    accent: Color(0xFF10B981),
    accentLight: Color(0xFF6EE7B7),
    textPrimary: Color(0xFFEDF5F1),
    textSecondary: Color(0xFF869489),
  ),
  ColorSchemeData(
    id: 4,
    name: "Crimson Rose",
    bg: Color(0xFF130E10),
    surface: Color(0xFF211A1D),
    accent: Color(0xFFE11D48),
    accentLight: Color(0xFFFB7185),
    textPrimary: Color(0xFFF6EEF0),
    textSecondary: Color(0xFF948689),
  ),
  ColorSchemeData(
    id: 5,
    name: "Amber Sunset",
    bg: Color(0xFF14100A),
    surface: Color(0xFF221C13),
    accent: Color(0xFFF59E0B),
    accentLight: Color(0xFFFBBF6C),
    textPrimary: Color(0xFFF6F0E8),
    textSecondary: Color(0xFF95897A),
  ),
  ColorSchemeData(
    id: 6,
    name: "Magenta Pulse",
    bg: Color(0xFF130D14),
    surface: Color(0xFF211A23),
    accent: Color(0xFFD946EF),
    accentLight: Color(0xFFF0ABFC),
    textPrimary: Color(0xFFF6EEF7),
    textSecondary: Color(0xFF948994),
  ),
  ColorSchemeData(
    id: 7,
    name: "Cyan Frost",
    bg: Color(0xFF0A1314),
    surface: Color(0xFF152123),
    accent: Color(0xFF06B6D4),
    accentLight: Color(0xFF67E8F9),
    textPrimary: Color(0xFFEBF5F6),
    textSecondary: Color(0xFF829698),
  ),
  ColorSchemeData(
    id: 8,
    name: "Monochrome Slate",
    bg: Color(0xFF101113),
    surface: Color(0xFF1D1F22),
    accent: Color(0xFF64748B),
    accentLight: Color(0xFF94A3B8),
    textPrimary: Color(0xFFF0F1F3),
    textSecondary: Color(0xFF8A8D93),
  ),
  ColorSchemeData(
    id: 9,
    name: "Indigo Night",
    bg: Color(0xFF0D0E1A),
    surface: Color(0xFF191B2E),
    accent: Color(0xFF4F46E5),
    accentLight: Color(0xFF818CF8),
    textPrimary: Color(0xFFEEEEF9),
    textSecondary: Color(0xFF8A8AA3),
  ),
  ColorSchemeData(
    id: 10,
    name: "Lime Punch",
    bg: Color(0xFF0F1208),
    surface: Color(0xFF1B2012),
    accent: Color(0xFF84CC16),
    accentLight: Color(0xFFBEF264),
    textPrimary: Color(0xFFF2F6E9),
    textSecondary: Color(0xFF8D967F),
  ),
  ColorSchemeData(
    id: 11,
    name: "Copper Bronze",
    bg: Color(0xFF140F0A),
    surface: Color(0xFF231A11),
    accent: Color(0xFFC2703D),
    accentLight: Color(0xFFE0A870),
    textPrimary: Color(0xFFF6EFE7),
    textSecondary: Color(0xFF988A79),
  ),
  ColorSchemeData(
    id: 12,
    name: "Rose Gold",
    bg: Color(0xFF140D10),
    surface: Color(0xFF241A1F),
    accent: Color(0xFFE8A0BF),
    accentLight: Color(0xFFF3C6D8),
    textPrimary: Color(0xFFF7EEF2),
    textSecondary: Color(0xFF988A91),
  ),
  ColorSchemeData(
    id: 13,
    name: "Turquoise Wave",
    bg: Color(0xFF091412),
    surface: Color(0xFF13221E),
    accent: Color(0xFF14B8A6),
    accentLight: Color(0xFF5EEAD4),
    textPrimary: Color(0xFFEAF6F4),
    textSecondary: Color(0xFF7F958F),
  ),
  ColorSchemeData(
    id: 14,
    name: "Sunflower Yellow",
    bg: Color(0xFF141208),
    surface: Color(0xFF232012),
    accent: Color(0xFFEAB308),
    accentLight: Color(0xFFFDE047),
    textPrimary: Color(0xFFF7F5E9),
    textSecondary: Color(0xFF97927F),
  ),
  ColorSchemeData(
    id: 15,
    name: "Deep Ocean Navy",
    bg: Color(0xFF080B12),
    surface: Color(0xFF121722),
    accent: Color(0xFF1E40AF),
    accentLight: Color(0xFF60A5FA),
    textPrimary: Color(0xFFE9EDF5),
    textSecondary: Color(0xFF7E879B),
  ),
  ColorSchemeData(
    id: 16,
    name: "Berry Wine",
    bg: Color(0xFF120A10),
    surface: Color(0xFF20141C),
    accent: Color(0xFF9F1239),
    accentLight: Color(0xFFE11D48),
    textPrimary: Color(0xFFF5EBEF),
    textSecondary: Color(0xFF937F8A),
  ),
];

void applyColorScheme(int id) {
  final scheme = kColorSchemes.firstWhere(
    (s) => s.id == id,
    orElse: () => kColorSchemes.first,
  );
  kBgColor = scheme.bg;
  kSurfaceColor = scheme.surface;
  kAccent = scheme.accent;
  kAccentLight = scheme.accentLight;
  kTextPrimary = scheme.textPrimary;
  kTextSecondary = scheme.textSecondary;
  selectedScheme = scheme.id;
}
