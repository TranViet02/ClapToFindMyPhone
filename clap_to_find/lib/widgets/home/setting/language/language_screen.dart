import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clap_to_find/widgets/home/setting/language/locale_controller.dart';
import 'package:clap_to_find/utils/style_configs.dart';

class LanguageScreen extends StatelessWidget {
  final LocaleController localeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 237, 237),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 240, 237, 237),
        title: Text('Language'.tr),
      ),
      body: ListView.builder(
        itemCount: localeController.languages.length,
        itemBuilder: (context, index) {
          return buildLanguageCheckbox(localeController.languages[index]);
        },
      ),
    );
  }

  Widget buildLanguageCheckbox(LanguageModel language) {
    return Obx(() {
      bool isSelected = language.isSelected.value;

      return GestureDetector(
        onTap: () {
          if (!isSelected) {
            localeController.languages.forEach((lang) {
              lang.isSelected.value = false;
            });
            language.isSelected.value = true;
            localeController.changeLocale(language.languageCode);
            localeController.saveSelectedLocale();
            Get.back(result: true);
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? mainColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text(
              language.languageName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            secondary: Text(
              language.languageEmoji,
              style: TextStyle(fontSize: 32),
            ),
            value: isSelected,
            onChanged: (bool? checked) {
              if (checked != null && checked) {
                localeController.languages.forEach((lang) {
                  lang.isSelected.value = false;
                });
                language.isSelected.value = true;
                localeController.changeLocale(language.languageCode);
                localeController.saveSelectedLocale();
                Get.back(result: true);
              }
            },
          ),
        ),
      );
    });
  }
}
