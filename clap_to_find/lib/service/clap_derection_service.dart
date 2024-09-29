import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ClapDetectionService {
  static const platform = MethodChannel('clap_to_find');
  bool isServiceRunning = false;
  // String status = "Waiting for clap...";

  void Function(String) onStatusChange;
  void Function(bool) onServiceStateChange;

  ClapDetectionService(
      {required this.onStatusChange,
      required this.onServiceStateChange,
      required String selectedSound}) {
    platform.setMethodCallHandler(_handleMethod);
    _checkServiceState();
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "clapDetected":
        onStatusChange("");
        break;
      case "permissionResult":
        bool isGranted = call.arguments;
        if (isGranted) {
          _startService();
        }
        break;
      default:
        break;
    }
  }

  Future<void> _checkServiceState() async {
    final bool result = await platform.invokeMethod('checkServiceState');
    isServiceRunning = result;
    onServiceStateChange(result);
    onStatusChange(isServiceRunning ? "Tap to deactivate".tr : "Tap to active".tr);
  }

  void toggleService() async {
    if (isServiceRunning) {
      await _stopService();
    } else {
      await _requestPermission();
    }
  }

  Future<void> _startService() async {
    await platform.invokeMethod('startService', {"action": "start"});
    isServiceRunning = true;
    onServiceStateChange(true);
    onStatusChange("Tap to deactivate".tr);
  }

  Future<void> _stopService() async {
    await platform.invokeMethod('startService', {"action": "stop"});
    isServiceRunning = false;
    onServiceStateChange(false);
    onStatusChange("Tap to active".tr);
  }

  Future<void> _requestPermission() async {
    await platform.invokeMethod('requestPermission');
  }
}
