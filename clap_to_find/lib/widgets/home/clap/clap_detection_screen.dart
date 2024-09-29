import 'package:clap_to_find/Widgets/home/appbar/appbar_clap_widgets.dart';
import 'package:clap_to_find/Widgets/home/navigatobottom/flashlight_screen.dart';
import 'package:clap_to_find/Widgets/sound/sound_selection_screen.dart';
import 'package:clap_to_find/Widgets/home/navigatobottom/vibration_screen.dart';
import 'package:clap_to_find/widgets/home/button/clap_button.dart';
import 'package:clap_to_find/widgets/home/homeScreen.dart';
import 'package:clap_to_find/widgets/home/navigatobottom/CustomBottomNavigationBar.dart';
import 'package:clap_to_find/widgets/sound/sound_effects_widget.dart';
import 'package:flutter/material.dart';
import 'package:clap_to_find/Widgets/home/setting/setting_Screen.dart';
import 'package:clap_to_find/service/clap_derection_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClapDetectionScreen extends StatefulWidget {
  @override
  _ClapDetectionScreenState createState() => _ClapDetectionScreenState();
}

class _ClapDetectionScreenState extends State<ClapDetectionScreen> {
  late Future<void> _initializationFuture;
  late ClapDetectionService _service;
  bool isServiceRunning = false;
  String selectedSound = 'assets/cat.png';
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initialize();
  }

  Future<void> _initialize() async {
    _loadSoundChoice();
    _service = ClapDetectionService(
      onStatusChange: (newStatus) {
        if (mounted) setState(() {});
      },
      onServiceStateChange: (isRunning) {
        if (mounted)
          setState(() {
            isServiceRunning = isRunning;
          });
      },
      selectedSound: selectedSound,
    );
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

  void _navigateToSoundSelectionScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SoundSelectionScreen()),
    );

    if (result != null) {
      setState(() {
        selectedSound = result;
      });
      await _saveSoundChoice(result);
    }
  }

  Future<void> _saveSoundChoice(String soundChoice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSound', soundChoice);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return WillPopScope(
            onWillPop: () async {
              _navigateToHomeScreen();
              return false;
            },
            child: Scaffold(
              appBar: buildCustomAppBar(
                context,
                _getAppBarTitle(_selectedIndex),
                () => _navigateToSettingScreen(context),
                _navigateToHomeScreen,
              ),
              body: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if (mounted)
                    setState(() {
                      _selectedIndex = index;
                    });
                },
                children: [
                  _buildMainScreen(),
                  VibrationScreen(),
                  FlashlightScreen(),
                ],
              ),
              bottomNavigationBar: CustomBottomNavigationBar(
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  if (mounted)
                    setState(() {
                      _selectedIndex = index;
                    });
                  _pageController.jumpToPage(index);
                },
                firstButtonTitle: 'Clap to find phone'.tr,
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildMainScreen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SoundEffectsWidget(_navigateToSoundSelectionScreen),
        ClapButton(isServiceRunning, _service, selectedSound),
      ],
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Clap to find phone'.tr;
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

  void _navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (route) => false,
    );
  }
}
