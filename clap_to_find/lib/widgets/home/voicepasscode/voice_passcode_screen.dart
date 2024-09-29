import 'package:avatar_glow/avatar_glow.dart';
import 'package:clap_to_find/utils/style_configs.dart';
import 'package:clap_to_find/widgets/home/appbar/appbar_clap_widgets.dart';
import 'package:clap_to_find/widgets/home/homeScreen.dart';
import 'package:clap_to_find/widgets/home/navigatobottom/CustomBottomNavigationBar.dart';
import 'package:clap_to_find/widgets/home/navigatobottom/flashlight_screen.dart';
import 'package:clap_to_find/widgets/home/navigatobottom/vibration_screen.dart';
import 'package:clap_to_find/widgets/home/setting/setting_screen.dart';
import 'package:clap_to_find/widgets/home/voicepasscode/change_voice_passcode.dart';
import 'package:clap_to_find/widgets/sound/sound_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoicePasscodeScreen extends StatefulWidget {
  final String passcodeText;

  const VoicePasscodeScreen({required this.passcodeText});

  @override
  State<VoicePasscodeScreen> createState() => _VoicePasscodeScreenState();
}

class _VoicePasscodeScreenState extends State<VoicePasscodeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  String recognizedText = "";
  bool _isListening = false;
  bool _speechInitialized = false;
  bool _isGlowing = false;

  @override
  void initState() {
    super.initState();
    _initSpeechState();
  }

  void _initSpeechState() async {
    bool available = await _speech.initialize();
    if (!mounted) return;
    setState(() {
      _speechInitialized = available;
    });
  }

  void _startListening() {
    if (_speechInitialized) {
      if (!_isListening) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              recognizedText = result.recognizedWords;
            });
            if (recognizedText.toLowerCase() ==
                widget.passcodeText.toLowerCase()) {
              Fluttertoast.showToast(
                msg: "Passcode matched!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          },
        );
        setState(() {
          _isListening = true;
          _isGlowing = true;
        });
        _showSnackBar("Listening started");
      } else {
        _speech.stop();
        setState(() {
          _isListening = false;
          _isGlowing = false;
        });
        _showSnackBar("Listening stopped");
      }
    } else {
      _showSnackBar("Speech recognition not initialized");
    }
  }

  void _cleanText() {
    setState(() {
      recognizedText = "";
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SoundSelectionScreen(),
                            ),
                          );
                        },
                        icon: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.volume_up),
                        ),
                        label: Text(
                          'Sound effects'.tr,
                          style: const TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: mainColor, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ChangeVoicePasscodeScreen(),
                            ),
                          );
                        },
                        icon: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.mic),
                        ),
                        label: const Text(
                          'Change voice passcode',
                          style: TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: mainColor, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 160),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _startListening,
                        child: AvatarGlow(
                          startDelay: const Duration(milliseconds: 1000),
                          glowColor: mainColor,
                          glowShape: BoxShape.circle,
                          curve: Curves.fastOutSlowIn,
                          animate: _isGlowing,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(255, 248, 246, 246)
                                          .withOpacity(0.4),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage('assets/cat.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isListening
                            ? 'Tap to stop listening...'
                            : 'Tap to start listening',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isListening ? mainColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        firstButtonTitle: 'Voice passcode'.tr,
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Voice passcode'.tr;
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
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }
}
