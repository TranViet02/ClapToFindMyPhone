import 'package:flutter/services.dart';

class VibrationService {
  static const platform = MethodChannel('vibration_service');

  static Future<void> initializeStates(Function(bool, bool) setState) async {
    try {
      bool serviceRunning = await checkServiceState();
      bool permissionGranted = await checkVibrationPermission();
      setState(serviceRunning, permissionGranted);
    } on PlatformException catch (e) {
      print("Failed to initialize states: '${e.message}'.");
    }
  }

  static Future<bool> checkServiceState() async {
    try {
      final bool serviceRunning =
          await platform.invokeMethod('checkServiceState');
      return serviceRunning;
    } on PlatformException catch (e) {
      print("Failed to check service state: '${e.message}'.");
      return false;
    }
  }

  static Future<bool> checkVibrationPermission() async {
    try {
      final bool permissionGranted =
          await platform.invokeMethod('checkPermission');
      return permissionGranted;
    } on PlatformException catch (e) {
      print("Failed to check vibration permission: '${e.message}'.");
      return false;
    }
  }

  static Future<void> requestVibrationPermission() async {
    try {
      await platform.invokeMethod('requestPermission');
    } on PlatformException catch (e) {
      print("Failed to request vibration permission: '${e.message}'.");
    }
  }

  static Future<void> toggleService(bool isServiceRunning, bool hasPermission,
      Function(bool) setState) async {
    try {
      if (isServiceRunning) {
        await platform
            .invokeMethod('startServiceVibration', {"action": "stop"});
        setState(false);
      } else {
        if (hasPermission) {
          await platform
              .invokeMethod('startServiceVibration', {"action": "start"});
          setState(true);
        } else {
          requestVibrationPermission();
        }
      }
    } on PlatformException catch (e) {
      print("Failed to toggle service: '${e.message}'.");
    }
  }
}
