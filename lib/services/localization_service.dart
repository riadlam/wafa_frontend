import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LocalizationService {
  static final Map<String, Locale> _supportedLocales = {
    'en': const Locale('en'),
    'fr': const Locale('fr'),
    'ar': const Locale('ar'),
  };

  static List<Locale> get supportedLocales => _supportedLocales.values.toList();

  static Future<void> setLanguage(BuildContext context, String languageCode) async {
    if (!_supportedLocales.containsKey(languageCode)) return;
    
    await context.setLocale(_supportedLocales[languageCode]!);
  }

  static String getCurrentLanguage(BuildContext context) {
    return context.locale.languageCode;
  }

  static bool isRTL(BuildContext context) {
    return context.locale.languageCode == 'ar';
  }

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'language.english'.tr();
      case 'fr':
        return 'language.french'.tr();
      case 'ar':
        return 'language.arabic'.tr();
      default:
        return 'language.english'.tr();
    }
  }
}
