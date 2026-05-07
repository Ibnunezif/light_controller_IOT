import 'package:flutter/material.dart';
import '../models/language.dart';
import '../services/localization_service.dart';

class StatusRow extends StatelessWidget {
  final bool isOn;
  final String dailyUsage;
  final AppLanguage lang;

  const StatusRow({
    super.key,
    required this.isOn,
    required this.dailyUsage,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isOn ? Icons.bolt : Icons.power_settings_new,
          size: 16,
          color: isOn ? Colors.greenAccent : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          isOn 
            ? '${LocalizationService.get('energy_usage', lang)} $dailyUsage' 
            : LocalizationService.get('bulb_off', lang),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            color: isOn ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
