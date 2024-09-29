// ignore_for_file: depend_on_referenced_packages
import 'package:clap_to_find/utils/style_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_switch/flutter_switch.dart';

class FlashlightScreen extends StatefulWidget {
  @override
  _FlashlightScreenState createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  final MethodChannel _channel = const MethodChannel('clap_to_find');
  String _currentFlashMode = 'default';
  bool isButtonPressed = false;
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadFlashMode();
    _loadSwitchState();
  }

  Future<void> _loadFlashMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentFlashMode = prefs.getString('flashMode') ?? 'defaultFlash';
      if (_currentFlashMode == 'defaultFlash') {
        selectedIndex = 0;
      } else if (_currentFlashMode == 'discomode') {
        selectedIndex = 1;
      } else if (_currentFlashMode == 'sosmode') {
        selectedIndex = 2;
      }
    });
  }

  Future<void> _loadSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isButtonPressed = prefs.getBool('switchState') ?? false;
    });
  }

  void _updateFlashMode(String mode, int index) {
    setState(() {
      _currentFlashMode = mode;
      selectedIndex = index;
    });
  }

  void _saveFlashMode(String mode) async {
    try {
      await _channel.invokeMethod('updateFlashMode', {'flashMode': mode});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('flashMode', mode);
    } on PlatformException catch (e) {
      print('Failed to update flash mode: ${e.message}');
    }
    Fluttertoast.showToast(
        msg: "Update flash mode successfully!".tr,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.lightBlue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _updateSwitchState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('switchState', value);
    setState(() {
      isButtonPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 235, 234, 234),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: mainColor,
                            width: 4,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "SELECT MODE".tr,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Customize the flash".tr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FlutterSwitch(
                      activeColor: mainColor,
                      inactiveColor: Colors.grey,
                      value: isButtonPressed,
                      onToggle: (val) {
                        _updateSwitchState(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: isButtonPressed
                          ? () => _updateFlashMode('defaultFlash', 0)
                          : null,
                      style: ButtonStyle(
                        side: MaterialStateProperty.resolveWith(
                          (states) => BorderSide(
                            color: selectedIndex == 0 && isButtonPressed
                                ? mainColor
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all(
                            const Size(double.infinity, 44)),
                      ),
                      child: Text(
                        'Default'.tr,
                        style: TextStyle(
                          color: selectedIndex == 0 && isButtonPressed
                              ? mainColor
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 4),
                    child: ElevatedButton(
                      onPressed: isButtonPressed
                          ? () => _updateFlashMode('discomode', 1)
                          : null,
                      style: ButtonStyle(
                        side: MaterialStateProperty.resolveWith(
                          (states) => BorderSide(
                            color: selectedIndex == 1 && isButtonPressed
                                ? mainColor
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        fixedSize: MaterialStateProperty.all(
                            const Size(double.infinity, 44)),
                      ),
                      child: Text(
                        'Disco mode'.tr,
                        style: TextStyle(
                          color: selectedIndex == 1 && isButtonPressed
                              ? mainColor
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 12),
                    child: ElevatedButton(
                      onPressed: isButtonPressed
                          ? () => _saveFlashMode(_currentFlashMode)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        backgroundColor: mainColor,
                        disabledForegroundColor: isButtonPressed
                            ? null
                            : Colors.grey.withOpacity(0.4),
                        disabledBackgroundColor: isButtonPressed
                            ? null
                            : Colors.grey.withOpacity(0.12),
                        elevation: isButtonPressed ? null : 0,
                      ),
                      child: Text(
                        'Apply Now'.tr,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
