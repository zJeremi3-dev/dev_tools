import '../colors.dart';
import '../widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnixTimestampDialog extends StatefulWidget {
  const UnixTimestampDialog({super.key});

  @override
  State<UnixTimestampDialog> createState() => _UnixTimestampDialogState();
}

class _UnixTimestampDialogState extends State<UnixTimestampDialog> {
  final _timestampController = TextEditingController();
  int _mode = 0; // 0 = Timestamp -> Date, 1 = Date -> Timestamp
  bool _isMillis = false;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  String? _dateOutput;
  String? _utcOutput;
  int? _timestampOutput;
  String? _error;

  String _pad(int n) => n.toString().padLeft(2, '0');
  String _formatDate(DateTime dt) =>
      '${_pad(dt.day)}.${_pad(dt.month)}.${dt.year} ${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';

  void _convertFromTimestamp() {
    final raw = _timestampController.text.trim();
    if (raw.isEmpty) {
      setState(() {
        _dateOutput = null;
        _utcOutput = null;
        _error = null;
      });
      return;
    }
    final value = int.tryParse(raw);
    if (value == null) {
      setState(() {
        _dateOutput = null;
        _utcOutput = null;
        _error = 'Invalid timestamp';
      });
      return;
    }
    try {
      final millis = _isMillis ? value : value * 1000;
      final local = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: false);
      final utc = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
      setState(() {
        _dateOutput = _formatDate(local);
        _utcOutput = _formatDate(utc);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _dateOutput = null;
        _utcOutput = null;
        _error = 'Invalid timestamp';
      });
    }
  }

  void _convertFromDate() {
    final dt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    setState(() {
      _timestampOutput = _isMillis
          ? dt.millisecondsSinceEpoch
          : (dt.millisecondsSinceEpoch / 1000).round();
      _error = null;
    });
  }

  void _setNow() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = now;
      _selectedTime = TimeOfDay.fromDateTime(now);
      _timestampController.text = _isMillis
          ? now.millisecondsSinceEpoch.toString()
          : (now.millisecondsSinceEpoch ~/ 1000).toString();
    });
    _mode == 0 ? _convertFromTimestamp() : _convertFromDate();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _convertFromDate();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
      _convertFromDate();
    }
  }

  @override
  void initState() {
    super.initState();
    _convertFromDate();
  }

  @override
  void dispose() {
    _timestampController.dispose();
    super.dispose();
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
                'Unix-Timestamp',
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

          // Mode
          buildSegmentedToggle(
            groupValue: _mode,
            labels: const ["Timestamp → Date", "Date → Timestamp"],
            onChanged: (value) {
              setState(() => _mode = value);
              _mode == 0 ? _convertFromTimestamp() : _convertFromDate();
            },
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              buildCheckboxOption('Milliseconds', _isMillis, () {
                setState(() => _isMillis = !_isMillis);
                _mode == 0 ? _convertFromTimestamp() : _convertFromDate();
              }),
              const Spacer(),
              TextButton.icon(
                onPressed: _setNow,
                icon: Icon(Icons.access_time, size: 16, color: kAccentLight),
                label: Text(
                  'Now',
                  style: TextStyle(color: kAccentLight, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (_mode == 0) ...[
            buildSection(
              label: 'Timestamp',
              children: [
                TextField(
                  controller: _timestampController,
                  autofocus: true,
                  decoration: fieldDecoration(
                    _isMillis
                        ? 'Milliseconds since 1970'
                        : 'Seconds since 1970',
                  ),
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                  ],
                  onChanged: (_) => _convertFromTimestamp(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kAccent.withAlpha(40)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: _error != null
                  ? Text(
                      _error!,
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Local: ${_dateOutput ?? '—'}',
                                style: TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            buildCopyButton(
                              context: context,
                              copyText: _dateOutput ?? "",
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'UTC: ${_utcOutput ?? '—'}',
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
            ),
          ] else ...[
            buildSection(
              label: 'Date & Time',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: Icon(
                          Icons.calendar_today,
                          size: 15,
                          color: kAccentLight,
                        ),
                        label: Text(
                          '${_pad(_selectedDate.day)}.${_pad(_selectedDate.month)}.${_selectedDate.year}',
                          style: TextStyle(color: kTextPrimary, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTime,
                        icon: Icon(
                          Icons.access_time,
                          size: 15,
                          color: kAccentLight,
                        ),
                        label: Text(
                          '${_pad(_selectedTime.hour)}:${_pad(_selectedTime.minute)}',
                          style: TextStyle(color: kTextPrimary, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kBgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kAccent.withAlpha(40)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Timestamp: ${_timestampOutput ?? '—'}',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 15,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  buildCopyButton(
                    context: context,
                    copyText: _timestampOutput.toString(),
                  ),
                ],
              ),
            ),
          ],
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
