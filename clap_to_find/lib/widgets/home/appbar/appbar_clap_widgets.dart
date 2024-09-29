import 'package:clap_to_find/utils/style_configs.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget buildCustomAppBar(BuildContext context, String title,
    Function() navigateToSettingScreen, Function() navigateBack) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(26),
      ),
      child: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: navigateBack,
        ),
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
            onPressed: navigateToSettingScreen,
          ),
        ],
        backgroundColor: mainColor,
      ),
    ),
  );
}
