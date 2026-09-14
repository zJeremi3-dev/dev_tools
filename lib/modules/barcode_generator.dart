import '../colors.dart';
import '../widgets/widgets.dart';

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:barcode_widget/barcode_widget.dart';

class BarcodeGenDialog extends StatefulWidget {
  const BarcodeGenDialog({super.key});

  @override
  State<BarcodeGenDialog> createState() => _BarcodeGenDialogState();
}

class _BarcodeGenDialogState extends State<BarcodeGenDialog> {
  final TextEditingController _stringController = TextEditingController();
  String _text = "";
  String _selectedType = "Code128";
  String? _error;
  final GlobalKey _barcodeKey = GlobalKey();

  static final Map<String, Barcode> _types = {
    "Code128": Barcode.code128(),
    "Code39": Barcode.code39(),
    "EAN-13": Barcode.ean13(),
    "EAN-8": Barcode.ean8(),
    "UPC-A": Barcode.upcA(),
    "ITF-14": Barcode.itf14(),
    "Codabar": Barcode.codabar(),
  };

  @override
  void dispose() {
    _stringController.dispose();
    super.dispose();
  }

  void _generator() {
    if (_text.trim().isEmpty) {
      setState(() => _error = null);
      return;
    }
    final barcode = _types[_selectedType]!;
    try {
      barcode.verify(_text);
      setState(() => _error = null);
    } catch (e) {
      setState(() => _error = 'Invalid for $_selectedType: $e');
    }
  }

  Future<Uint8List?> _captureBarcodeBytes() async {
    final boundary =
        _barcodeKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 4);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _copyImage() async {
    final bytes = await _captureBarcodeBytes();
    if (bytes == null) return;

    final clipboard = SystemClipboard.instance;
    if (clipboard == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Clipboard is not supported here")),
      );
      return;
    }

    final item = DataWriterItem();
    item.add(Formats.png(bytes));
    await clipboard.write([item]);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Barcode copied")));
  }

  Future<void> _downloadBarcode() async {
    final bytes = await _captureBarcodeBytes();
    if (bytes == null) return;

    if (kIsWeb) {
      final path = await FilePicker.platform.saveFile(
        fileName: 'barcode.png',
        bytes: bytes,
      );
      if (path != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved: $path')));
      }
      return;
    }

    final path = await FilePicker.platform.saveFile(fileName: 'barcode.png');
    if (path == null) return;

    final file = File(path.endsWith('.png') ? path : '$path.png');
    await file.writeAsBytes(bytes);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved: ${file.path}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final barcode = _types[_selectedType]!;
    final showBarcode = _text.trim().isNotEmpty && _error == null;

    return ResponsiveDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Barcode Generator',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: kTextSecondary, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Text Input
          buildSection(
            label: 'Text',
            children: [
              TextField(
                controller: _stringController,
                autofocus: true,
                decoration: fieldDecoration(''),
                style: TextStyle(color: kTextPrimary, fontSize: 14),
                onChanged: (value) {
                  setState(() => _text = value);
                  _generator();
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Enter the text/number the barcode should contain.',
                style: TextStyle(color: kTextSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Type-Choice
          buildSection(
            label: 'Type',
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: fieldDecoration('Barcode-Type'),
                dropdownColor: kSurfaceColor,
                style: TextStyle(color: kTextPrimary, fontSize: 13),
                items: _types.keys
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedType = v);
                  _generator();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Preview
          Container(
            width: double.infinity,
            height: 160,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAccent.withAlpha(40)),
            ),
            child: !showBarcode
                ? Text(
                    _error ?? 'Enter Text …',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kTextSecondary, fontSize: 12),
                  )
                : RepaintBoundary(
                    key: _barcodeKey,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: BarcodeWidget(
                        barcode: barcode,
                        data: _text,
                        drawText: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                        ),
                        errorBuilder: (context, error) => Center(
                          child: Text(
                            error,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 14),

          // Copy / Download
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: showBarcode ? _copyImage : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.copy, size: 16),
                        SizedBox(width: 6),
                        Text('Copy'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: showBarcode ? _downloadBarcode : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.download, size: 16),
                        SizedBox(width: 6),
                        Text('Download'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Close Button
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: kAccent.withAlpha(30),
                foregroundColor: kAccentLight,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Close',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
