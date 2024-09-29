
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageModel {
  final String languageName;
  final String languageCode;
  final String languageEmoji;
  final RxBool isSelected;

  LanguageModel({
    required this.languageName,
    required this.languageCode,
    required this.languageEmoji,
    bool isSelected = false,
  }) : isSelected = isSelected.obs;
}

class LocaleController extends GetxController {
  var locale = Locale('en').obs;

  final List<LanguageModel> languages = [
    LanguageModel(languageName: 'English', languageCode: 'en', languageEmoji: '🇺🇸'),
    LanguageModel(languageName: 'Tiếng Việt', languageCode: 'vi', languageEmoji: '🇻🇳'),
  ];

  @override
  void onInit() {
    super.onInit();
    loadSavedLocale();
  }

  Future<void> loadSavedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString('locale');
    if (savedLocale != null) {
      var selectedLanguage = languages.firstWhere((lang) => lang.languageCode == savedLocale, orElse: () => languages[0]);
      selectedLanguage.isSelected.value = true;
      locale.value = Locale(savedLocale);
      Get.updateLocale(Locale(savedLocale));
    } else {
      languages[0].isSelected.value = true; 
    }
  }

  Future<void> changeLocale(String langCode) async {
    var newLocale = Locale(langCode);
    locale.value = newLocale;
    Get.updateLocale(newLocale);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', langCode);
  }

  void saveSelectedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var selectedLanguage = languages.firstWhere((lang) => lang.isSelected.value);
    await prefs.setString('locale', selectedLanguage.languageCode);
  }
}
