import 'dart:convert';
import 'dart:io';

import '../colors.dart';
import '../widgets/widgets.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/widgets.dart' as pw;

const _imageIn = {
  'png',
  'jpg',
  'jpeg',
  'gif',
  'bmp',
  'tif',
  'tiff',
  'tga',
  'webp',
  'ico',
};
const _imageOut = ['png', 'jpg', 'gif', 'bmp', 'tiff', 'tga', 'ico'];
const _textIn = {'txt', 'md', 'csv', 'log', 'html', 'htm', 'xml', 'json'};
const _textOut = ['pdf', 'html', 'txt'];

List<String> targetsFor(String ext) {
  ext = ext.toLowerCase();
  final out = <String>[];
  if (_imageIn.contains(ext)) {
    out.addAll(_imageOut);
  } else if (_textIn.contains(ext)) {
    out.addAll(_textOut);
    if (ext == 'json') out.add('json (formatted)');
  }
  out.add('base64');
  out.remove(ext == 'jpeg' ? 'jpg' : ext);
  return out;
}

Future<Uint8List> _convertBytes(Map<String, dynamic> args) async {
  final Uint8List bytes = args['bytes'];
  final String from = (args['from'] as String).toLowerCase();
  final String to = args['to'];

  if (to == 'base64') {
    return Uint8List.fromList(utf8.encode(base64Encode(bytes)));
  }

  // Images
  if (_imageIn.contains(from)) {
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Image could not be read.');
    switch (to) {
      case 'png':
        return Uint8List.fromList(img.encodePng(image));
      case 'jpg':
        return Uint8List.fromList(img.encodeJpg(image, quality: 92));
      case 'gif':
        return Uint8List.fromList(img.encodeGif(image));
      case 'bmp':
        return Uint8List.fromList(img.encodeBmp(image));
      case 'tiff':
        return Uint8List.fromList(img.encodeTiff(image));
      case 'tga':
        return Uint8List.fromList(img.encodeTga(image));
      case 'ico':
        var icon = image;
        if (image.width > 256 || image.height > 256) {
          icon = img.copyResize(
            image,
            width: image.width >= image.height ? 256 : null,
            height: image.height > image.width ? 256 : null,
          );
        }
        return Uint8List.fromList(img.encodeIco(icon));
    }
  }
  // Text
  if (_textIn.contains(from)) {
    final text = utf8.decode(bytes, allowMalformed: true);
    switch (to) {
      case 'txt':
        return Uint8List.fromList(utf8.encode(text));
      case 'html':
        final escaped = const HtmlEscape().convert(text);
        return Uint8List.fromList(
          utf8.encode(
            '<!DOCTYPE html>\n<html><head><meta charset="utf-8"></head>'
            '<body><pre style="font-family:monospace;white-space:pre-wrap">'
            '$escaped</pre></body></html>',
          ),
        );
      case 'pdf':
        final doc = pw.Document();
        final lines = text.replaceAll('\r\n', '\n').split('\n');
        doc.addPage(
          pw.MultiPage(
            build: (_) =>
                lines.map((l) => pw.Text(l.isEmpty ? ' ' : l)).toList(),
          ),
        );
        return await doc.save();
      case 'json (formatted)':
        final pretty = const JsonEncoder.withIndent(
          '  ',
        ).convert(jsonDecode(text));
        return Uint8List.fromList(utf8.encode(pretty));
    }
  }

  throw Exception('This Conversion is not supported.');
}

class FileConverterDialog extends StatefulWidget {
  const FileConverterDialog({super.key});

  @override
  State<FileConverterDialog> createState() => _FileConverterDialogState();
}

class _FileConverterDialogState extends State<FileConverterDialog> {
  PlatformFile? file;
  List<String> targets = [];
  String? target;

  bool busy = false;
  Uint8List? resultBytes;
  String? resultName;
  String? error;

  String get uploadText => file?.name ?? "Select File..";
  String get downloadText {
    if (busy) return "Converting..";
    if (error != null) return error!;
    if (resultBytes != null) {
      return "$resultName (${_fmtSize(resultBytes!.length)})";
    }
    return "Start Convert..";
  }

  String _fmtSize(int b) {
    if (b < 1024) return "$b B";
    if (b < 1024 * 1024) return "${(b / 1024).toStringAsFixed(1)} KB";
    return "${(b / 1024 / 1024).toStringAsFixed(1)} MB";
  }

  void _snack(String msg) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _uploadFile() async {
    final res = await FilePicker.platform.pickFiles(withData: true);
    if (res == null || res.files.isEmpty) return;
    final f = res.files.first;
    final ext = f.extension ?? '';
    final t = targetsFor(ext);
    setState(() {
      file = f;
      targets = t;
      target = t.isNotEmpty ? t.first : null;
      resultBytes = null;
      resultName = null;
      error = null;
    });
  }

  Future<void> _convertFile() async {
    if (file == null || file!.bytes == null) {
      _snack("Please select a file first.");
      return;
    }
    if (target == null) return;

    setState(() {
      busy = true;
      error = null;
      resultBytes = null;
    });

    try {
      final bytes = await compute(_convertBytes, {
        'bytes': file!.bytes!,
        'from': file!.extension ?? '',
        'to': target!,
      });

      final base = file!.name.contains('.')
          ? file!.name.substring(0, file!.name.lastIndexOf('.'))
          : file!.name;
      final outExt = target!.startsWith('json')
          ? 'json'
          : (target == 'base64' ? 'txt' : target!);

      if (!mounted) return;
      setState(() {
        resultBytes = bytes;
        resultName = "$base.$outExt";
        busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        busy = false;
        error = "Error: ${e.toString().replaceFirst('Exception: ', '')}";
      });
    }
  }

  Future<void> _downloadFile() async {
    if (resultBytes == null || resultName == null) {
      _snack('First convert, then download.');
      return;
    }
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save file',
        fileName: resultName,
        bytes: resultBytes,
      );
      if (path != null &&
          !kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        await File(path).writeAsBytes(resultBytes!);
      }
      if (path != null || kIsWeb) _snack("Saved.");
    } catch (e) {
      _snack("Saving failed: $e");
    }
  }

  BoxDecoration get _boxDeco => BoxDecoration(
    color: kBgColor,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: kAccent.withAlpha(40)),
  );
  Widget _iconBtn(IconData icon, VoidCallback? onPressed) => IconButton(
    onPressed: onPressed,
    icon: Icon(icon),
    color: kAccentLight,
    iconSize: 22,
    style: ButtonStyle(
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    padding: EdgeInsets.zero,
  );
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
                'File Converter',
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

          // File-Picker
          Container(
            decoration: _boxDeco,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _iconBtn(Icons.upload, _uploadFile),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _uploadFile,
                    child: Text(
                      uploadText,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: file == null ? kTextSecondary : kTextPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Details
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  decoration: _boxDeco,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    file == null ? "Select File" : ".${file!.extension ?? '?'}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: file == null ? kTextSecondary : kTextPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text("=>", style: TextStyle(color: kTextSecondary)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 48,
                  decoration: _boxDeco,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: target,
                      hint: Text(
                        "Format",
                        style: TextStyle(color: kTextSecondary),
                      ),
                      dropdownColor: kBgColor,
                      iconEnabledColor: kAccentLight,
                      style: TextStyle(color: kTextPrimary),
                      items: targets
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.startsWith('json') ? t : '.$t'),
                            ),
                          )
                          .toList(),
                      onChanged: targets.isEmpty
                          ? null
                          : (v) => setState(() {
                              target = v;
                              resultBytes = null;
                              error = null;
                            }),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _iconBtn(Icons.transform, busy ? null : _convertFile),
            ],
          ),
          const SizedBox(height: 14),

          // Download
          Container(
            decoration: _boxDeco,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (busy)
                  const Padding(
                    padding: EdgeInsets.only(right: 10),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Expanded(
                  child: Text(
                    downloadText,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: error != null
                          ? Colors.redAccent
                          : (resultBytes == null
                                ? kTextSecondary
                                : kTextPrimary),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _iconBtn(
                  Icons.download,
                  resultBytes == null ? null : _downloadFile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

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
