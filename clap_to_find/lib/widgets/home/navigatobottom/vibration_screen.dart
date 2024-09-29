// ignore_for_file: depend_on_referenced_packages
import 'package:clap_to_find/utils/style_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VibrationScreen extends StatefulWidget {
  @override
  _VibrationScreenState createState() => _VibrationScreenState();
}

class _VibrationScreenState extends State<VibrationScreen> {
  static const platform = MethodChannel('clap_to_find');
  bool isButtonPressed = false;
  String vibrationMode = 'Default';
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadVibrationMode();
    _loadSwitchState();
  }

  Future<void> _loadVibrationMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      vibrationMode = prefs.getString('vibrationMode') ?? 'Default';
      if (vibrationMode == 'Default') {
        selectedIndex = 0;
      } else if (vibrationMode == 'Strong Vibration') {
        selectedIndex = 1;
      } else if (vibrationMode == 'Heartbeat') {
        selectedIndex = 2;
      }
    });
  }

  Future<void> _loadSwitchState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isButtonPressed = prefs.getBool('vibrationSwitchState') ?? false;
    });
  }

  void _updateVibrationMode(String mode, int index) {
    setState(() {
      vibrationMode = mode;
      selectedIndex = index;
    });
  }

  void _saveVibrationMode(String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await platform.invokeMethod('updateVibrationMode', {'mode': mode});
    await prefs.setString('vibrationMode', mode);
    setState(() {
      vibrationMode = mode;
    });
    Fluttertoast.showToast(
        msg: "Updated vibration mode successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.lightBlue,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _updateSwitchState(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationSwitchState', value);
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
          height: 350,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 235, 234, 234),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "SELECT MODE".tr,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Vibration level option".tr,
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
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: isButtonPressed
                          ? () => _updateVibrationMode('Default', 0)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 44),
                        side: BorderSide(
                          color: selectedIndex == 0 && isButtonPressed
                              ? mainColor
                              : Colors.transparent,
                          width: 1,
                        ),
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
                          ? () => _updateVibrationMode('Strong Vibration', 1)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 44),
                        side: BorderSide(
                          color: selectedIndex == 1 && isButtonPressed
                              ? mainColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Strong Vibration'.tr,
                        style: TextStyle(
                          color: selectedIndex == 1 && isButtonPressed
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
                          ? () => _updateVibrationMode('Heartbeat', 2)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 44),
                        side: BorderSide(
                          color: selectedIndex == 2 && isButtonPressed
                              ? mainColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Heartbeat'.tr,
                        style: TextStyle(
                          color: selectedIndex == 2 && isButtonPressed
                              ? mainColor
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: isButtonPressed
                          ? () => _saveVibrationMode(vibrationMode)
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(350, 55),
                        backgroundColor: isButtonPressed
                            ? mainColor
                            : Colors.grey.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Apply Now'.tr,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
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
