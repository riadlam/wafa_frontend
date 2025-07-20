import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectorSheet extends StatefulWidget {
  const LanguageSelectorSheet({super.key});

  @override
  State<LanguageSelectorSheet> createState() => _LanguageSelectorSheetState();
}

class _LanguageSelectorSheetState extends State<LanguageSelectorSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'select_language'.tr(),
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildLanguageOption(context, 'English', 'en'),
          _buildLanguageOption(context, 'Français', 'fr'),
          _buildLanguageOption(context, 'العربية', 'ar'),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, String language, String languageCode) {
    final currentLocale = context.locale.languageCode;
    final isSelected = currentLocale == languageCode;

    return ListTile(
      leading: Text(
        _getLanguageFlag(languageCode),
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(language),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () async {
        if (!isSelected) {
          await context.setLocale(Locale(languageCode));
          // Save the selected language preference
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('language_code', languageCode);
          
          // Force a rebuild with the new locale
          if (mounted) {
            context.setLocale(Locale(languageCode));
          }
        }
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'fr':
        return '🇫🇷';
      case 'ar':
        return '🇸🇦';
      default:
        return '🌐';
    }
  }
}
