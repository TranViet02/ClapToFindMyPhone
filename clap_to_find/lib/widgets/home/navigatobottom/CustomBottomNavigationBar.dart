import 'package:clap_to_find/utils/style_configs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;
  final String firstButtonTitle;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
    required this.firstButtonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          child: GNav(
            gap: 4,
            backgroundColor: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: mainColor,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
            tabs: [
              GButton(
                icon: Icons.class_sharp,
                text: firstButtonTitle.tr,
              ),
              GButton(
                icon: Icons.phone_android,
                text: 'Vibration'.tr,
              ),
              GButton(
                icon: Icons.flash_on,
                text: 'Flashlight'.tr,
              ),
            ],
          ),
        ),
        ZergAndroidPlugin.getSmallBannerView(
          alignment: Alignment.bottomCenter,
        ),
      ],
    );
  }
}
