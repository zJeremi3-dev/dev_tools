import '../colors.dart';
import '../widgets/widgets.dart';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class IpLeakDialog extends StatefulWidget {
  const IpLeakDialog({super.key});

  @override
  State<IpLeakDialog> createState() => _IpLeakDialogState();
}

class _IpLeakDialogState extends State<IpLeakDialog> {
  bool _isLoading = false;
  bool _hasInternet = false;
  Map<String, dynamic>? _info;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    bool connected = await hasInternetConnection();
    setState(() {
      _hasInternet = connected;
    });
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> check() async {
    setState(() {
      _isLoading = true;
    });
    var data = await IpLeakCheck.fetchIpInfo();
    setState(() {
      _info = data;
      _isLoading = false;
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
                'IP Leak Check',
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

          Row(
            children: [
              Icon(
                IconData(0xe6e7, fontFamily: 'MaterialIcons'),
                size: 15,
                color: kAccentLight,
              ),
              Expanded(
                child: Text(
                  ' Internet/WiFi connection required',
                  style: TextStyle(
                    color: kAccentLight,
                    fontSize: 12,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // IP-Display
          Container(
            decoration: BoxDecoration(
              color: kBgColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kAccent.withAlpha(40)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: _isLoading
                              ? "Load Data..."
                              : (_info == null
                                    ? "?"
                                    : "${_info!['ip']} [${_info!['version']}]"),
                          style: TextStyle(
                            color: _info == null && !_isLoading
                                ? kTextSecondary
                                : kTextPrimary,
                            fontSize: 15,
                            letterSpacing: 1,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Tooltip(
                  message: "Check",
                  decoration: BoxDecoration(
                    color: kSurfaceColor,
                    border: Border.all(width: 1, color: kAccent),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  textStyle: TextStyle(color: kTextPrimary),
                  child: IconButton(
                    onPressed: (!_hasInternet || _isLoading)
                        ? null
                        : () => check(),
                    icon: Icon(
                      _info == null ? Icons.play_arrow : Icons.refresh_rounded,
                    ),
                    color: kAccentLight,
                    iconSize: 22,
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Details
          buildSection(
            label: 'Details',
            children: [
              const SizedBox(height: 6),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("City: ", style: TextStyle(color: kTextSecondary)),
                      Text("Region: ", style: TextStyle(color: kTextSecondary)),
                      Text(
                        "Country: ",
                        style: TextStyle(color: kTextSecondary),
                      ),
                      Text(
                        "Postal Code: ",
                        style: TextStyle(color: kTextSecondary),
                      ),
                      Text(
                        "Latitude / Longitude: ",
                        style: TextStyle(color: kTextSecondary),
                      ),
                      Text(
                        "Time Zone: ",
                        style: TextStyle(color: kTextSecondary),
                      ),
                      Text(
                        "Currency: ",
                        style: TextStyle(color: kTextSecondary),
                      ),
                      Text(
                        "Calling Code: ",
                        style: TextStyle(color: kTextSecondary),
                      ),
                      Text(
                        "European Union: ",
                        style: TextStyle(color: kTextSecondary),
                      ),
                      Text("ASN: ", style: TextStyle(color: kTextSecondary)),
                      Text("Org: ", style: TextStyle(color: kTextSecondary)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _info == null ? "?" : _info!['city'],
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        _info == null ? "?" : _info!['region'],
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Row(
                        children: [
                          if (_info != null) ...[
                            Image.network(
                              'https://flagcdn.com/w40/${_info!['country_code'].toLowerCase()}.png',
                              width: 20,
                              height: 14,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            _info == null
                                ? "?"
                                : "${_info!['country_code']} | ${_info!['country_name']}",
                            style: TextStyle(color: kTextPrimary),
                          ),
                        ],
                      ),
                      Text(
                        _info == null ? "?" : _info!['postal'],
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        _info == null ? "?" : _info!['position'],
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        _info == null
                            ? "?"
                            : "${_info!['timezone']}(${_info!['utc']})",
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        _info == null ? "?" : _info!['currency'],
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        _info == null ? "?" : _info!['calling_code'],
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        _info == null ? "?" : _info!['in_eu'],
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        _info == null ? "?" : _info!['asn'],
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        _info == null ? "?" : _info!['isp'],
                        style: TextStyle(color: kTextPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ],
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

class IpLeakCheck {
  static Future<Map<String, dynamic>?> fetchIpInfo() async {
    final url = Uri.parse('https://ipapi.co/json/');
    final response = await http.get(
      url,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'ip': data['ip'],
        'version': data['version'],
        'city': data['city'],
        'region': data['region'],
        'country_name': data['country_name'],
        'country_code': data['country_code'],
        'postal': data['postal'],
        'position': "${data['latitude']}, ${data['longitude']}",
        'timezone': data['timezone'],
        'utc': data['utc_offset'],
        'currency': "${data['currency']} | ${data['currency_name']}",
        'calling_code': data['country_calling_code'],
        'in_eu': data['in_eu'].toString(),
        'asn': data['asn'],
        'isp': data['org'],
      };
    } else {
      return null;
    }
  }
}
