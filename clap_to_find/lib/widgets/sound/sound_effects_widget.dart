import 'package:clap_to_find/utils/style_configs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class SoundEffectsWidget extends StatelessWidget {
  final Function(BuildContext) navigateToAllSoundScreen;

  SoundEffectsWidget(this.navigateToAllSoundScreen);

  final List<String> soundEffects = [
    'assets/note.png',
    'assets/cat.png',
    'assets/car.png',
    'assets/cavalry.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Sound effects'.tr,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => rewardedAd(context),
                    child: Row(
                      children: [
                        Text(
                          'View All'.tr,
                          style: TextStyle(
                            color: mainColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: mainColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 84,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(soundEffects.length, (index) {
              return GestureDetector(
                onTap: () {
                  rewardedAd(context);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 4 - 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: index == 0 ? mainColor : Colors.transparent,
                  ),
                  child: Center(
                    child: index == 0
                        ? const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 45,
                          )
                        : Image.asset(
                            soundEffects[index],
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void rewardedAd(BuildContext context) {
    ZergAndroidPlugin.showRewardedAd(
      onFinished: () {
        navigateToAllSoundScreen(context);
      },
      onUserEarned: () {},
    );
  }
}
