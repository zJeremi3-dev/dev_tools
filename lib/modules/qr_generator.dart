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
import 'package:qr/qr.dart';

class QRGenDialog extends StatefulWidget {
  const QRGenDialog({super.key});

  @override
  State<QRGenDialog> createState() => _QRGenDialogState();
}

class _QRGenDialogState extends State<QRGenDialog> {
  final TextEditingController _stringController = TextEditingController();
  String _text = "";
  int _selectedSize = 4;
  int _selectedQuality = QrErrorCorrectLevel.M;
  QrImage? _qrImage;
  String? _error;
  final GlobalKey _qrKey = GlobalKey();
  static const Map<int, String> _qualityLabels = {
    QrErrorCorrectLevel.L: 'L - Low (~7%)',
    QrErrorCorrectLevel.M: 'M - Medium (~15%)',
    QrErrorCorrectLevel.Q: 'Q - Quartile (~25%)',
    QrErrorCorrectLevel.H: 'H - High (~30%)',
  };
  int? _minVersion;
  int _effectiveSize = 4;

  @override
  void dispose() {
    _stringController.dispose();
    super.dispose();
  }

  bool _fits(int typeNumber, int errorLevel, String text) {
    try {
      final qrCode = QrCode(typeNumber, errorLevel)..addData(text);
      QrImage(qrCode).moduleCount;
      return true;
    } catch (_) {
      return false;
    }
  }

  int? _minVersionFor(int errorLevel, String text) {
    if (text.isEmpty) return null;
    for (int v = 1; v <= 40; v++) {
      if (_fits(v, errorLevel, text)) return v;
    }
    return null;
  }

  void _generator() {
    if (_text.trim().isEmpty) {
      setState(() {
        _qrImage = null;
        _error = null;
        _minVersion = null;
      });
      return;
    }

    final minVersion = _minVersionFor(_selectedQuality, _text);
    if (minVersion == null) {
      setState(() {
        _qrImage = null;
        _error =
            'Text is too long – doesn\'t fit at any size (max. version 40).';
        _minVersion = null;
      });
      return;
    }

    final effectiveSize = _selectedSize < minVersion
        ? minVersion
        : _selectedSize;

    try {
      final qrCode = QrCode(effectiveSize, _selectedQuality)..addData(_text);
      final qrImage = QrImage(qrCode);
      setState(() {
        _qrImage = qrImage;
        _error = null;
        _minVersion = minVersion;
        _effectiveSize = effectiveSize;
      });
    } catch (e) {
      setState(() {
        _qrImage = null;
        _error = 'Error generating QR code: $e';
        _minVersion = minVersion;
      });
    }
  }

  Future<void> _copyImage() async {
    final bytes = await _captureQrBytes();
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
    ).showSnackBar(const SnackBar(content: Text("QR code copied")));
  }

  Future<Uint8List?> _captureQrBytes() async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 4);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _downloadQr() async {
    final bytes = await _captureQrBytes();
    if (bytes == null) return;

    final path = await FilePicker.platform.saveFile(
      fileName: 'qrcode.png',
      bytes: kIsWeb ? bytes : null,
    );

    if (path == null) return;

    if (!kIsWeb) {
      final file = File(path.endsWith('.png') ? path : '$path.png');
      await file.writeAsBytes(bytes);
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved: $path')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'QR-Code Generator',
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
                'Enter the text to encode in the QR code.',
                style: TextStyle(color: kTextSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Options
          Row(
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kBgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kAccent.withAlpha(40)),
                    ),
                    child: _qrImage == null
                        ? Text(
                            _error ?? 'Enter text …',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextSecondary,
                              fontSize: 12,
                            ),
                          )
                        : RepaintBoundary(
                            key: _qrKey,
                            child: SizedBox.expand(
                              child: CustomPaint(
                                painter: _QrPainter(_qrImage!),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildSection(
                  label: 'Options',
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _selectedSize,
                      isExpanded: true,
                      decoration: fieldDecoration('Size'),
                      dropdownColor: kSurfaceColor,
                      style: TextStyle(color: kTextPrimary, fontSize: 13),
                      items: List.generate(10, (i) => i + 1).map((v) {
                        final locked = _minVersion != null && v < _minVersion!;
                        return DropdownMenuItem<int>(
                          value: v,
                          enabled: !locked,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Version $v',
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (locked) ...[
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.lock,
                                  size: 12,
                                  color: kTextSecondary.withAlpha(150),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedSize = v);
                        _generator();
                      },
                    ),
                    if (_minVersion != null &&
                        _selectedSize < _minVersion!) ...[
                      const SizedBox(height: 6),
                      Text(
                        _minVersion! > 10
                            ? 'Text too long for 1–10 → automatically switched to version $_effectiveSize.'
                            : 'Automatically increased to version $_effectiveSize.',
                        style: TextStyle(color: kAccentLight, fontSize: 10.5),
                      ),
                    ],
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: _selectedQuality,
                      isExpanded: true,
                      decoration: fieldDecoration('Quality'),
                      dropdownColor: kSurfaceColor,
                      style: TextStyle(color: kTextPrimary, fontSize: 13),
                      items: _qualityLabels.entries.map((e) {
                        final locked =
                            _text.isNotEmpty &&
                            !_fits(_effectiveSize, e.key, _text);
                        return DropdownMenuItem<int>(
                          value: e.key,
                          enabled: !locked,
                          child: Text(e.value, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _selectedQuality = v);
                        _generator();
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _qrImage == null ? null : _copyImage,
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
                            onPressed: _qrImage == null ? null : _downloadQr,
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
                  ],
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

class _QrPainter extends CustomPainter {
  final QrImage qrImage;
  _QrPainter(this.qrImage);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final moduleCount = qrImage.moduleCount;
    final cell = size.width / moduleCount;

    final path = Path();
    for (int x = 0; x < moduleCount; x++) {
      for (int y = 0; y < moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          path.addRect(Rect.fromLTWH(x * cell, y * cell, cell, cell));
        }
      }
    }

    final fg = Paint()
      ..color = Colors.black
      ..isAntiAlias = false
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fg);
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.qrImage != qrImage;
}
