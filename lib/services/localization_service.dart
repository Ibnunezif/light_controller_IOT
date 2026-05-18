import '../models/language.dart';

class LocalizationService {
  static const Map<String, Map<AppLanguage, String>> _translations = {
    'title': {
      AppLanguage.english: 'Bulbs',
      AppLanguage.amharic: 'አምፖሎች',
      AppLanguage.oromo: 'Bulbulii',
    },
    'lighting': {
      AppLanguage.english: 'Lighting Control',
      AppLanguage.amharic: 'የመብራት ቁጥጥር',
      AppLanguage.oromo: "To'annoo Ibsaa",
    },
    'energy_usage': {
      AppLanguage.english: 'Usage:',
      AppLanguage.amharic: 'ፍጆታ:',
      AppLanguage.oromo: 'Fayyadama:',
    },
    'bulb_off': {
      AppLanguage.english: 'Bulb is OFF',
      AppLanguage.amharic: 'አምፖሉ ጠፍቷል',
      AppLanguage.oromo: 'Bulbuliin dhaameera',
    },
    'active': {
      AppLanguage.english: 'Active',
      AppLanguage.amharic: 'ንቁ',
      AppLanguage.oromo: 'Akkaataa',
    },
    'inactive': {
      AppLanguage.english: 'Inactive',
      AppLanguage.amharic: 'ተጠባባቂ',
      AppLanguage.oromo: 'Hojii keessatti miti',
    },
  };

  static String get(String key, AppLanguage lang) {
    return _translations[key]?[lang] ?? _translations[key]?[AppLanguage.english] ?? key;
  }
}
