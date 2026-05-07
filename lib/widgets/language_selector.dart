import 'package:flutter/material.dart';
import '../models/language.dart';

class LanguageSelector extends StatelessWidget {
  final Function(AppLanguage) onLanguageChanged;

  const LanguageSelector({super.key, required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLanguage>(
      icon: const Icon(Icons.language),
      onSelected: onLanguageChanged,
      itemBuilder: (context) => [
        const PopupMenuItem(value: AppLanguage.english, child: Text('English')),
        const PopupMenuItem(value: AppLanguage.amharic, child: Text('አማርኛ (Amharic)')),
        const PopupMenuItem(value: AppLanguage.oromo, child: Text('Oromiffa')),
      ],
    );
  }
}
