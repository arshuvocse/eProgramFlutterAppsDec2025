import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Collects basic device/app info to send with login requests.
class DeviceInfoService {
  DeviceInfoService._internal();
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;

  bool _loaded = false;

  String? _imei;
  String? _deviceToken;
  String? _device;
  String? _appVersion;
  String? _os;
  String? _osVersion;

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        final candidateIds = <String?>[
          info.id, // Build.ID (public)
          info.fingerprint, // device fingerprint
          info.device, // device codename
        ];
        final deviceId = candidateIds.firstWhere(
          (e) => e != null && e.trim().isNotEmpty,
          orElse: () => null,
        );

        _imei = deviceId; // cannot read IMEI; use device identifier surrogate
        _deviceToken = deviceId;
        final brand = info.manufacturer.trim();
        final model = info.model.trim();
        _device = [brand, model].where((e) => e.isNotEmpty).join(' ').trim();
        _os = 'Android';
        _osVersion = info.version.release?.trim();
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        _imei = info.identifierForVendor?.trim();
        _deviceToken = info.identifierForVendor?.trim();
        _device = info.utsname.machine?.trim() ?? info.model?.trim();
        _os = 'iOS';
        _osVersion = info.systemVersion?.trim();
      } else {
        _os = Platform.operatingSystem;
        _osVersion = Platform.operatingSystemVersion;
      }

      final package = await PackageInfo.fromPlatform();
      _appVersion = package.version;
    } catch (_) {
      // Leave nulls; fallbacks will apply
    } finally {
      _loaded = true;
    }
  }

  Future<Map<String, String>> getLoginParams() async {
    await _load();
    return {
      'Imei': _imei ?? '001',
      'DeviceToken': _deviceToken ?? '001',
      'Device': _device?.isNotEmpty == true ? _device! : 'Unknown Device',
      'AppVersion': _appVersion ?? '01',
      'OS': _os ?? Platform.operatingSystem,
      'OS_Version': _osVersion ?? Platform.operatingSystemVersion,
    };
  }
}
