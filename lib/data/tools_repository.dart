import '../models/tool_module.dart';
import '../modules/modules.dart';
import 'package:flutter/material.dart';

final List<ToolModule> kTools = [
  ToolModule(
    id: 1,
    name: "Password Generator",
    description: "Generate a Strong PW",
    icon: Icons.vpn_key,
    category: "Generator",
    dialogBuilder: (context) => const PasswordGenDialog(),
  ), // 1 // Password Generator
  ToolModule(
    id: 2,
    name: "PW-Strength-Test",
    description: "Shows the strength of your PW",
    icon: Icons.shield,
    category: "Security",
    dialogBuilder: (context) => const PWStrengthDialog(),
  ), // 2 // PW Strength
  ToolModule(
    id: 3,
    name: "QR-Code Generator",
    description: "Generate a QR-Code",
    icon: Icons.qr_code_2,
    category: "Generator",
    dialogBuilder: (context) => const QRGenDialog(),
  ), // 3 // QR-Code Generator
  ToolModule(
    id: 4,
    name: "Barcode Generator",
    description: "Generate a Barcode",
    icon: Icons.receipt_long,
    category: "Generator",
    dialogBuilder: (context) => const BarcodeGenDialog(),
  ), // 4 // Barcode Generator
  ToolModule(
    id: 5,
    name: "Bin ↔ Dec",
    description: "Convert between binary and decimal",
    icon: Icons.swap_horiz,
    category: "Converter",
    dialogBuilder: (context) => const BinDecConverterDialog(),
  ), // 5 // Bin Dec Converter
  ToolModule(
    id: 6,
    name: "Randomizer",
    description: "Gives a random Number",
    icon: Icons.casino_outlined,
    category: "Generator",
    dialogBuilder: (context) => const RandomNumberDialog(),
  ), // 6 // Randomizer
  ToolModule(
    id: 7,
    name: "Hash Generator",
    description: "Compute SHA-256, MD5 and more",
    icon: Icons.tag,
    category: "Security",
    dialogBuilder: (context) => const HashGenDialog(),
  ), // 7 // Hash Generator
  ToolModule(
    id: 8,
    name: "Base64",
    description: "Encode and decode Base64",
    icon: Icons.code,
    category: "Converter",
    dialogBuilder: (context) => const Base64Dialog(),
  ), // 8 // Base64
  ToolModule(
    id: 9,
    name: "URL Encoder",
    description: "Encode and decode URLs",
    icon: Icons.link,
    category: "Converter",
    dialogBuilder: (context) => const UrlEncodeDialog(),
  ), // 9 // URL Encoder
  ToolModule(
    id: 10,
    name: "JSON Formatter",
    description: "Format and minify JSON",
    icon: Icons.data_object,
    category: "Text",
    dialogBuilder: (context) => const JsonFormatDialog(),
  ), // 10 // JSON formatter
  ToolModule(
    id: 11,
    name: "Color Picker",
    description: "Pick a color and get its hex code",
    icon: Icons.palette,
    category: "Design",
    dialogBuilder: (context) => const ColorPickerDialog(),
  ), // 11 // Color Picker
  ToolModule(
    id: 12,
    name: "Unix-Timestamp",
    description: "Convert between Unix timestamp and date",
    icon: Icons.schedule,
    category: "Converter",
    dialogBuilder: (context) => const UnixTimestampDialog(),
  ), // 12 // Unix-Timestamp Converter
  ToolModule(
    id: 13,
    name: "Regex Tester",
    description: "Test regular expressions against a string",
    icon: Icons.manage_search,
    category: "Text",
    dialogBuilder: (context) => const RegexTesterDialog(),
  ), // 13 // Regex Tester
  ToolModule(
    id: 14,
    name: "UUID Generator",
    description: "Generate random UUIDs (v4)",
    icon: Icons.fingerprint,
    category: "Generator",
    dialogBuilder: (context) => const UuidGenDialog(),
  ), // 14 // UUID Generator
  ToolModule(
    id: 15,
    name: "RSA Key-Pair",
    description: "Generate and test RSA Key-Pairs",
    icon: Icons.key,
    category: "Security",
    dialogBuilder: (context) => const RSADialog(),
  ), // 15 // RSA Key Pair
];
final List<String> kCategories = [
  "Generator",
  "Converter",
  "Security",
  "Text",
  "Design",
];
