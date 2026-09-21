import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Downloads the given Windows installer and launches it silently, then
/// exits this app so the installer can safely overwrite it.
/// Windows-only; callers must check Platform.isWindows first.
Future<void> downloadAndInstall(String downloadUrl) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}\\DevTools-Setup.exe');

  final response = await http.get(Uri.parse(downloadUrl));
  await file.writeAsBytes(response.bodyBytes);

  await Process.start(file.path, [
    '/VERYSILENT',
    '/NORESTART',
    '/SUPPRESSMSGBOXES',
  ], mode: ProcessStartMode.detached);

  exit(0);
}
