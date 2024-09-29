import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_switcher/slide_switcher.dart';
import 'package:clap_to_find/widgets/home/appbar/appbar_clap_widgets.dart';
import 'package:clap_to_find/widgets/home/setting/setting_screen.dart';
import 'package:clap_to_find/utils/style_configs.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class SoundSelectionScreen extends StatefulWidget {
  @override
  _SoundSelectionScreenState createState() => _SoundSelectionScreenState();
}

class _SoundSelectionScreenState extends State<SoundSelectionScreen> {
  static const platform = MethodChannel('clap_to_find');
  int switcherIndex = 0;
  String? _fileName;

  Future<void> _saveSoundChoice(String soundChoice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSound', soundChoice);
    await platform
        .invokeMethod('saveSoundChoice', {'soundChoice': soundChoice});
  }

  void _navigateToSettingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingScreen()),
    );
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;
      setState(() {
        _fileName = file.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(
        context,
        "Sound library".tr,
        _navigateToSettingScreen,
        _navigateBack,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const SizedBox(height: 10),
            SlideSwitcher(
              onSelect: (index) => setState(() => switcherIndex = index),
              containerHeight: 40,
              containerWight: MediaQuery.of(context).size.width * 0.9,
              containerColor: Colors.white,
              slidersColors: [mainColor],
              children: [
                Text(
                  'Sound effects'.tr,
                  style: TextStyle(
                    color: switcherIndex == 0 ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  'Melody'.tr,
                  style: TextStyle(
                    color: switcherIndex == 1 ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: switcherIndex == 0
                        ? _buildSoundEffects()
                        : _buildMelody(),
                  ),
                  ZergAndroidPlugin.getNativeAdView(
                    isMediumSize: false,
                    adWidth: MediaQuery.of(context).size.width,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundEffects() {
    final soundChoices = [
      {'title': 'Cat'.tr, 'value': 'sound1', 'image': 'assets/cat.png'},
      {'title': 'Car'.tr, 'value': 'sound2', 'image': 'assets/car.png'},
      {'title': 'Cavalry'.tr, 'value': 'sound3', 'image': 'assets/cavalry.png'},
      {
        'title': 'Party horn'.tr,
        'value': 'sound4',
        'image': 'assets/partyhorn.png'
      },
      {
        'title': 'Police whistle'.tr,
        'value': 'sound5',
        'image': 'assets/police_whistle.png'
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 5,
      ),
      itemCount: soundChoices.length,
      itemBuilder: (context, index) {
        final sound = soundChoices[index];
        return GestureDetector(
          onTap: () {
            _saveSoundChoice(sound['value']!);
            Navigator.pop(context, sound['image']);
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => SoundDetailScreen(
            //       imagePath: sound['image']!,
            //     ),
            //   ),
            // );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 87,
                height: 87,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(sound['image']!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                sound['title']!,
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMelody() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset('assets/melody.png'),
                  const SizedBox(height: 10),
                  const Text(
                    'There are currently no playlists. Click the button below to add your playlists ',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: _pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                minimumSize: Size(450, 50),
              ),
              child: const Text(
                'Pick a File',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            if (_fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Text('Selected File: $_fileName'),
              ),
          ],
        ),
      ),
    );
  }
}
