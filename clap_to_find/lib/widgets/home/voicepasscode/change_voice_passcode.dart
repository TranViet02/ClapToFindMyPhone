import 'package:clap_to_find/utils/style_configs.dart';
import 'package:clap_to_find/widgets/home/setting/setting_screen.dart';
import 'package:clap_to_find/widgets/home/voicepasscode/speech_to_text_screen.dart';
import 'package:clap_to_find/widgets/home/voicepasscode/text_to_speech_screen.dart';
import 'package:flutter/material.dart';

class ChangeVoicePasscodeScreen extends StatefulWidget {
  const ChangeVoicePasscodeScreen({super.key});

  @override
  State<ChangeVoicePasscodeScreen> createState() =>
      _ChangeVoicePasscodeScreenState();
}

class _ChangeVoicePasscodeScreenState extends State<ChangeVoicePasscodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice passcode"),
        actions: [
          IconButton(
            icon: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: Colors.black,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingScreen(),
                ),
              );
            },
          ),
        ],
        backgroundColor: mainColor,
      ),
      backgroundColor: Color.fromARGB(255, 248, 247, 247),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SpeechToTextScreen(),
                      ),
                    );
                  },
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Icon(
                      Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                  label: const Text(
                    'Voice',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    side: BorderSide(color: mainColor, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TextToSpeechScreen(),
                      ),
                    );
                  },
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Icon(Icons.chat),
                  ),
                  label: const Text(
                    'Text to voice',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 245, 243, 243),
                    side: BorderSide(color: mainColor, width: 1),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
