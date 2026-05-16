import 'package:firebase_database/firebase_database.dart';
import '../models/bulb.dart';

class FirebaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('bulbs');

  FirebaseService();

  Stream<bool> get connectionStream {
    return FirebaseDatabase.instance.ref('.info/connected').onValue.map((event) {
      return event.snapshot.value as bool? ?? false;
    });
  }

  Stream<List<Bulb>> getBulbsStream() {
    try {
      return _dbRef.onValue.map((event) {
        final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) return [];

        return data.entries.map((entry) {
          final bulb = Bulb.fromMap(entry.key.toString(), entry.value as Map<dynamic, dynamic>);
          // If bulb is ON, we might want to calculate current session consumption
          // but for simplicity we'll update it on state changes.
          return bulb;
        }).toList();
      });
    } catch (e) {
      return Stream.error(e);
    }
  }

  Future<void> addBulb(String name, double ratedWattage) async {
    final newBulbRef = _dbRef.push();
    final int now = DateTime.now().millisecondsSinceEpoch;
    final newBulb = Bulb(
      id: newBulbRef.key!,
      name: name,
      isOn: false,
      brightness: 0.5,
      dailyUsage: 0.0,
      instantUsage: 0.0,
      ratedWattage: ratedWattage,
      totalConsumed: 0.0,
      lastUpdate: now,
    );
    await newBulbRef.set(newBulb.toMap());
  }

  Future<void> toggleBulb(Bulb bulb, bool isOn) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    double totalConsumed = bulb.totalConsumed;

    if (bulb.isOn) {
      // It was ON, now turning OFF (or just updating). Calculate consumed since lastUpdate.
      final double hours = (now - bulb.lastUpdate) / (1000 * 60 * 60);
      final double consumed = (bulb.instantUsage * hours) / 1000;
      totalConsumed += consumed;
    }

    bulb.isOn = isOn;
    final double instantUsage = bulb.calculateCurrentWattage();
    final double dailyUsage = bulb.estimateDailyUsage();

    await _dbRef.child(bulb.id).update({
      'isOn': isOn,
      'instantUsage': instantUsage,
      'dailyUsage': dailyUsage,
      'totalConsumed': totalConsumed,
      'lastUpdate': now,
    });
  }

  Future<void> updateBrightness(Bulb bulb, double brightness) async {
    final int now = DateTime.now().millisecondsSinceEpoch;
    double totalConsumed = bulb.totalConsumed;

    if (bulb.isOn) {
      final double hours = (now - bulb.lastUpdate) / (1000 * 60 * 60);
      final double consumed = (bulb.instantUsage * hours) / 1000;
      totalConsumed += consumed;
    }

    bulb.brightness = brightness;
    final double instantUsage = bulb.calculateCurrentWattage();
    final double dailyUsage = bulb.estimateDailyUsage();

    await _dbRef.child(bulb.id).update({
      'brightness': brightness,
      'instantUsage': instantUsage,
      'dailyUsage': dailyUsage,
      'totalConsumed': totalConsumed,
      'lastUpdate': now,
    });
  }

  Future<void> deleteBulb(String id) async {
    await _dbRef.child(id).remove();
  }

  Future<void> seedDatabase() async {
    final snapshot = await _dbRef.get();
    if (!snapshot.exists || snapshot.value == null) {
      final initialBulbs = {
        'bulb_1': {
          'name': 'Main Living Room',
          'isOn': true,
          'brightness': 0.8,
          'dailyUsage': 1.25,
          'instantUsage': 12.5,
        },
        'bulb_2': {
          'name': 'Kitchen Counter',
          'isOn': false,
          'brightness': 0.5,
          'dailyUsage': 0.85,
          'instantUsage': 0.0,
        },
        'bulb_3': {
          'name': 'Master Bedroom',
          'isOn': true,
          'brightness': 0.3,
          'dailyUsage': 0.45,
          'instantUsage': 5.2,
        },
      };
      await _dbRef.set(initialBulbs);
    }
  }
}
