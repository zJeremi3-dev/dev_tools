import 'package:flutter/material.dart';
import 'colors.dart';

int selectedOwnScheme = 0;

class OwnColorSchemeData {
  final int id;
  String name;
  final Color bg, surface, accent, accentLight, textPrimary, textSecondary;

  OwnColorSchemeData({
    required this.id,
    required this.name,
    required this.bg,
    required this.surface,
    required this.accent,
    required this.accentLight,
    required this.textPrimary,
    required this.textSecondary,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bg': bg.toARGB32(),
    'surface': surface.toARGB32(),
    'accent': accent.toARGB32(),
    'accentLight': accentLight.toARGB32(),
    'textPrimary': textPrimary.toARGB32(),
    'textSecondary': textSecondary.toARGB32(),
  };
  factory OwnColorSchemeData.fromJson(Map<String, dynamic> json) {
    return OwnColorSchemeData(
      id: json['id'] as int,
      name: json['name'] as String,
      bg: Color(json['bg'] as int),
      surface: Color(json['surface'] as int),
      accent: Color(json['accent'] as int),
      accentLight: Color(json['accentLight'] as int),
      textPrimary: Color(json['textPrimary'] as int),
      textSecondary: Color(json['textSecondary'] as int),
    );
  }
}

const List<OwnColorSchemeData> kOwnColorSchemes = [];

void applyOwnColorScheme(int id, List<OwnColorSchemeData> schemes) {
  if (schemes.isEmpty) return;

  final scheme = schemes.firstWhere(
    (s) => s.id == id,
    orElse: () => schemes.first,
  );

  kBgColor = scheme.bg;
  kSurfaceColor = scheme.surface;
  kAccent = scheme.accent;
  kAccentLight = scheme.accentLight;
  kTextPrimary = scheme.textPrimary;
  kTextSecondary = scheme.textSecondary;
  selectedScheme = 0;
  selectedOwnScheme = scheme.id;
}

void applyTestScheme(String color, Color value) {
  if (color == "BackGround") kBgColor = value;
  if (color == "Surface") kSurfaceColor = value;
  if (color == "Accent") kAccent = value;
  if (color == "Accent Light") kAccentLight = value;
  if (color == "Text Primary") kTextPrimary = value;
  if (color == "Text Secondary") kTextSecondary = value;
}
