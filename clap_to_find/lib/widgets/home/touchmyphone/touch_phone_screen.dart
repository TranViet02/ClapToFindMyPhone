import 'package:clap_to_find/widgets/home/navigatobottom/CustomBottomNavigationBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clap_to_find/widgets/home/appbar/appbar_clap_widgets.dart';
import 'package:clap_to_find/widgets/home/navigatobottom/flashlight_screen.dart';
import 'package:clap_to_find/widgets/sound/sound_effects_widget.dart';
import 'package:clap_to_find/widgets/home/navigatobottom/vibration_screen.dart';
import 'package:clap_to_find/widgets/home/button/shakes_button.dart';
import 'package:clap_to_find/service/vibration_service.dart';
import 'package:clap_to_find/widgets/home/setting/setting_screen.dart';
import 'package:clap_to_find/widgets/sound/sound_selection_screen.dart';
import 'package:clap_to_find/widgets/home/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TouchPhoneScreen extends StatefulWidget {
  @override
  _TouchPhoneScreen createState() => _TouchPhoneScreen();
}

class _TouchPhoneScreen extends State<TouchPhoneScreen> {
  bool isServiceRunning = false;
  bool hasVibrationPermission = false;
  int _selectedIndex = 0;
  PageController _pageController = PageController();
  String selectedSound = 'assets/cat.png';

  @override
  void initState() {
    super.initState();
    _initializeStates();
    _loadSoundChoice();
  }

  void _initializeStates() async {
    await VibrationService.initializeStates(
        (serviceRunning, permissionGranted) {
      setState(() {
        isServiceRunning = serviceRunning;
        hasVibrationPermission = permissionGranted;
      });
      if (permissionGranted && serviceRunning) {
        setState(() {
          isServiceRunning = true;
        });
      }
    });
  }

  Future<void> _loadSoundChoice() async {
    final prefs = await SharedPreferences.getInstance();
    final soundChoice = prefs.getString('selectedSound');
    if (soundChoice != null) {
      setState(() {
        selectedSound = soundChoice;
      });
    }
  }

  void _startOrStopService() async {
    await VibrationService.toggleService(
        isServiceRunning, hasVibrationPermission, (newState) {
      setState(() {
        isServiceRunning = newState;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(
        context,
        _getAppBarTitle(_selectedIndex),
        () => _navigateToSettingScreen(context),
        _navigateToHomeScreen,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SoundEffectsWidget(_navigateToSoundSelectionScreen),
              ButtonImage(
                isServiceRunning: isServiceRunning,
                onTap: _startOrStopService,
                selectedSound: selectedSound,
              ),
            ],
          ),
          VibrationScreen(),
          FlashlightScreen(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.jumpToPage(index);
        },
        firstButtonTitle: 'Do not touch my phone'.tr,
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Do not touch my phone'.tr;
      case 1:
        return 'Vibration'.tr;
      case 2:
        return 'Flashlight'.tr;
      default:
        return 'Clap to find phone'.tr;
    }
  }

  void _navigateToSettingScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingScreen()),
    );
  }

  void _navigateToSoundSelectionScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SoundSelectionScreen()),
    );

    if (result != null) {
      setState(() {
        selectedSound = result;
      });
      _saveSoundChoice(result);
    }
  }

  void _navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _saveSoundChoice(String soundChoice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSound', soundChoice);
  }
}
