import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

Future<String> deviceData() async {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      return jsonEncode(_getAndroidData(await _deviceInfoPlugin.androidInfo));
    }
    if (Platform.isIOS) {
      return jsonEncode(_getIosData(await _deviceInfoPlugin.iosInfo));
    }
    return '';
  } on PlatformException {
    return jsonEncode({
      'Error': 'Failed to get device data',
    });
  }
}

Map<String, dynamic> _getAndroidData(AndroidDeviceInfo build) {
  return {
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'hardware': build.hardware,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    'isPhysicalDevice': build.isPhysicalDevice,
    //'systemFeatures': build.systemFeatures,
  };
}

Map<String, dynamic> _getIosData(IosDeviceInfo data) {
  return {
    'name': data.name,
    'systemName': data.systemName,
    'systemVersion': data.systemVersion,
    'model': data.model,
    'localizedModel': data.localizedModel,
    'isPhysicalDevice': data.isPhysicalDevice,
    'utsname.sysname:': data.utsname.sysname,
    'utsname.nodename:': data.utsname.nodename,
    'utsname.release:': data.utsname.release,
    'utsname.version:': data.utsname.version,
    'utsname.machine:': data.utsname.machine,
  };
}