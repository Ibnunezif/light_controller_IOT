import 'package:flutter/material.dart';
import '../models/bulb.dart';
import '../models/language.dart';
import '../services/localization_service.dart';

class BulbCard extends StatelessWidget {
  final Bulb bulb;
  final AppLanguage lang;
  final VoidCallback onTap;

  const BulbCard({
    super.key,
    required this.bulb,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF252932),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Icon(
          bulb.isOn ? Icons.lightbulb : Icons.lightbulb_outline,
          color: bulb.isOn ? Colors.deepPurpleAccent : Colors.grey,
          size: 30,
        ),
        title: Text(bulb.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        subtitle: Text(
          bulb.isOn 
            ? '${LocalizationService.get('active', lang)} • ${bulb.formattedDailyUsage}' 
            : LocalizationService.get('inactive', lang),
          style: TextStyle(color: bulb.isOn ? Colors.deepPurpleAccent : Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
