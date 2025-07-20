import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loyaltyapp/services/localization_service.dart';

class LanguageSelector extends StatelessWidget {
  final Function? onLanguageChanged;

  const LanguageSelector({super.key, this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    final currentLanguage = LocalizationService.getCurrentLanguage(context);
    
    return DropdownButton<String>(
      value: currentLanguage,
      icon: const Icon(Icons.language),
      underline: const SizedBox(),
      onChanged: (String? newValue) async {
        if (newValue != null && newValue != currentLanguage) {
          await LocalizationService.setLanguage(context, newValue);
          if (onLanguageChanged != null) {
            onLanguageChanged!();
          }
        }
      },
      items: LocalizationService.supportedLocales
          .map<DropdownMenuItem<String>>((Locale locale) {
        return DropdownMenuItem<String>(
          value: locale.languageCode,
          child: Text(
            LocalizationService.getLanguageName(locale.languageCode),
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }
}
