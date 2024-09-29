import 'package:clap_to_find/service/clap_derection_service.dart';
import 'package:clap_to_find/utils/style_configs.dart';
import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';

class ClapButton extends StatelessWidget {
  final bool isServiceRunning;
  final ClapDetectionService service;
  // final String status;
  final String selectedSound;

  ClapButton(this.isServiceRunning, this.service, this.selectedSound);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(status.tr),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                service.toggleService();
              },
              child: AvatarGlow(
                startDelay: const Duration(milliseconds: 1000),
                glowColor: mainColor,
                glowShape: BoxShape.circle,
                animate: isServiceRunning,
                curve: Curves.fastOutSlowIn,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            Color.fromARGB(255, 248, 246, 246).withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    image: DecorationImage(
                      image: AssetImage(selectedSound),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
