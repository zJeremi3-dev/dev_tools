import 'package:dev_tools/settings/color_scheme_dialog.dart';
import 'dart:io';

import '../colors.dart';
import '../widgets/widgets.dart';
import '../models/tool_module.dart';
import 'hidden_modules.dart';
import 'module_layout.dart';

import 'package:flutter/material.dart';
import '../services/update_checker.dart';
import '../services/self_updater.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsDialog extends StatefulWidget {
  final List<ToolModule> tools;
  final List<double> hideOrder;
  final void Function(double id) onUnHide;
  final void Function(double id) onHide;
  final int moduleLayout;
  final void Function(int type)? onLayoutChange;
  final UpdateInfo? updateInfo;

  const SettingsDialog({
    super.key,
    required this.tools,
    required this.hideOrder,
    required this.onUnHide,
    required this.onHide,
    required this.moduleLayout,
    this.onLayoutChange,
    this.updateInfo,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  List<ToolModule> get _hiddenTools =>
      widget.tools.where((t) => widget.hideOrder.contains(t.id)).toList();
  List<ToolModule> get _visibleTools =>
      widget.tools.where((t) => !widget.hideOrder.contains(t.id)).toList();

  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
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
                'Settings',
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

          if (widget.updateInfo != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withAlpha(100)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.system_update_alt,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Update to v${widget.updateInfo!.latestVersion} available',
                      style: TextStyle(color: kTextPrimary, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final info = widget.updateInfo!;
                      if (Platform.isWindows &&
                          info.windowsDownloadUrl != null) {
                        await downloadAndInstall(info.windowsDownloadUrl!);
                      } else {
                        launchUrl(Uri.parse(info.releaseUrl));
                      }
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          buildSection(
            label: "",
            children: [
              SizedBox(width: 500),
              SizedBox(
                width: 300,
                height: 35,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      barrierColor: Colors.black.withAlpha(26),
                      builder: (context) => const ColorSchemeDialog(),
                      useRootNavigator: true,
                    );
                  },
                  icon: Icon(
                    Icons.color_lens_outlined,
                    color: kAccentLight,
                    size: 30,
                  ),
                  label: Text(
                    "Color Scheme",
                    style: TextStyle(color: kTextPrimary, fontSize: 20),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    side: BorderSide(color: kAccent.withAlpha(100), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              HiddenModulesSection(
                visibleTools: _visibleTools,
                hiddenTools: _hiddenTools,
                onHide: (id) {
                  widget.onHide(id);
                  setState(() {});
                },
                onUnHide: (id) {
                  widget.onUnHide(id);
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              ModuleLayoutSection(
                initialValue: widget.moduleLayout,
                onChanged: widget.onLayoutChange,
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 35,
                    child: OutlinedButton.icon(
                      onPressed: () => showLicensePage(
                        context: context,
                        applicationName: 'Dev-Tools',
                        applicationVersion: _appVersion,
                      ),
                      icon: Icon(
                        Icons.description_outlined,
                        color: kAccentLight,
                      ),
                      label: Text(
                        "Licenses",
                        style: TextStyle(color: kTextPrimary, fontSize: 20),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(
                          color: kAccent.withAlpha(100),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

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
