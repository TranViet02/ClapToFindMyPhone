import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:clap_to_find/widgets/home/voicepasscode/voice_passcode_screen.dart';
import 'package:clap_to_find/utils/style_configs.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController textController = TextEditingController();
  Map<String, String> languageMap = {'en': 'English', 'vi': 'Việt Nam'};

  List<String> languages = [];
  String? selectedLanguage;
  double pitch = 1.0;
  double volume = 0.8;
  double speechRate = 0.5;
  bool hasPlayed = false;

  @override
  void initState() {
    super.initState();
    initTts();
  }

  Future<void> initTts() async {
    List<dynamic> availableLanguages = await flutterTts.getLanguages;
    languages = availableLanguages
        .where((language) => languageMap.keys.contains(language))
        .map((language) => language as String)
        .toList();
    setState(() {});
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> speak(String text) async {
    await flutterTts.setLanguage(selectedLanguage ?? 'en-US');
    await flutterTts.setPitch(pitch);
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.speak(text);
    setState(() {
      hasPlayed = true;
    });
  }

  void _handleSave() {
    final text = textController.text.trim();
    if (text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Enter your voice passcode!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: mainColor,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VoicePasscodeScreen(passcodeText: text),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text to voice"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: "Enter your voice passcode!",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  Positioned(
                    bottom: 2,
                    left: 5,
                    child: IconButton(
                      onPressed: () async {
                        await speak(textController.text);
                      },
                      icon: Icon(
                        Icons.volume_up,
                        color: mainColor,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _handleSave,
                  child: Text("Save"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
