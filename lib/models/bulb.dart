class Bulb {
  String id;
  String name;
  bool isOn;
  double brightness;
  double dailyUsage; // estimated daily in kWh
  double instantUsage; // in Watts
  double ratedWattage; // e.g. 60.0
  double totalConsumed; // Lifetime in kWh
  int lastUpdate; // Timestamp in ms

  Bulb({
    required this.id,
    required this.name,
    this.isOn = false,
    this.brightness = 0.5,
    this.dailyUsage = 0.0,
    this.instantUsage = 0.0,
    this.ratedWattage = 60.0,
    this.totalConsumed = 0.0,
    this.lastUpdate = 0,
  });

  factory Bulb.fromMap(String id, Map<dynamic, dynamic> map) {
    return Bulb(
      id: id,
      name: map['name'] ?? '',
      isOn: map['isOn'] ?? false,
      brightness: (map['brightness'] ?? 0.5).toDouble(),
      dailyUsage: (map['dailyUsage'] ?? 0.0).toDouble(),
      instantUsage: (map['instantUsage'] ?? 0.0).toDouble(),
      ratedWattage: (map['ratedWattage'] ?? 60.0).toDouble(),
      totalConsumed: (map['totalConsumed'] ?? 0.0).toDouble(),
      lastUpdate: map['lastUpdate'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isOn': isOn,
      'brightness': brightness,
      'dailyUsage': dailyUsage,
      'instantUsage': instantUsage,
      'ratedWattage': ratedWattage,
      'totalConsumed': totalConsumed,
      'lastUpdate': lastUpdate,
    };
  }

  double calculateCurrentWattage({bool? isOn}) {
    final active = isOn ?? this.isOn;
    if (!active) return 0.0;
    return ratedWattage * brightness;
  }

  double estimateDailyUsage() {
    return (calculateCurrentWattage() * 8) / 1000;
  }

  String get formattedDailyUsage => '${dailyUsage.toStringAsFixed(2)} kWh';
  String get formattedInstantUsage => '${instantUsage.toStringAsFixed(1)} W';
  String get formattedTotalConsumed => '${totalConsumed.toStringAsFixed(3)} kWh';
}
