import 'package:clap_to_find/utils/style_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({Key? key}) : super(key: key);

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  String recognizedText = "";
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initSpeechState();
  }

  void _initSpeechState() async {
    bool available = await _speech.initialize();
    if (!mounted) return;
    setState(() {
      _isListening = available;
    });
  }

  void _startListening() {
    if (!_isListening) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
        },
      );
      setState(() {
        _isListening = true;
      });
      _showSnackBar("Listening started");
    } else {
      _speech.stop();
      setState(() {
        _isListening = false;
      });
      _showSnackBar("Listening stopped");
    }
  }

  void _copyText() {
    Clipboard.setData(ClipboardData(text: recognizedText));
    _showSnackBar("Text copied");
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
      appBar: AppBar(
        title: Text('Voice'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black45,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                recognizedText.isNotEmpty
                    ? recognizedText
                    : "Say something to record your voice ...",
                style: TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              onPressed: _startListening,
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
              iconSize: 50,
              color: _isListening ? mainColor : Colors.grey,
            ),
            SizedBox(height: 10),
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: recognizedText.isNotEmpty ? _copyText : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Copy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: recognizedText.isNotEmpty ? _cleanText : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 233, 53, 40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Clear",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
