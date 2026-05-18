import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bulb.dart';

class AppFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppFirebaseService();

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  DatabaseReference get _userBulbsRef => 
      FirebaseDatabase.instance.ref('users/$_uid/bulbs');

  Stream<bool> get connectionStream {
    return FirebaseDatabase.instance.ref('.info/connected').onValue.map((event) {
      return event.snapshot.value as bool? ?? false;
    });
  }

  Stream<List<Bulb>> getBulbsStream() {
    try {
      return _userBulbsRef.onValue.map((event) {
        final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) return [];

        return data.entries.map((entry) {
          return Bulb.fromMap(entry.key.toString(), entry.value as Map<dynamic, dynamic>);
        }).toList();
      });
    } catch (e) {
      return Stream.error(e);
    }
  }

  Future<void> addBulb(String name, double ratedWattage) async {
    final newBulbRef = _userBulbsRef.push();
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
      final double hours = (now - bulb.lastUpdate) / (1000 * 60 * 60);
      final double consumed = (bulb.instantUsage * hours) / 1000;
      totalConsumed += consumed;
    }

    final double instantUsage = bulb.calculateCurrentWattage(isOn: isOn);
    // Note: You might want to update dailyUsage estimation logic too

    await _userBulbsRef.child(bulb.id).update({
      'isOn': isOn,
      'instantUsage': instantUsage,
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

    await _userBulbsRef.child(bulb.id).update({
      'brightness': brightness,
      'instantUsage': instantUsage,
      'totalConsumed': totalConsumed,
      'lastUpdate': now,
    });
  }

  Future<void> deleteBulb(String id) async {
    await _userBulbsRef.child(id).remove();
  }

  Future<void> seedDatabase() async {
    // Only seed if user is logged in
    User? user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _userBulbsRef.get();
    if (!snapshot.exists || snapshot.value == null) {
      final initialBulbs = {
        'bulb_1': {
          'name': 'Main Living Room',
          'isOn': true,
          'brightness': 0.8,
          'dailyUsage': 1.25,
          'instantUsage': 12.5,
          'ratedWattage': 15.0,
          'totalConsumed': 0.0,
          'lastUpdate': DateTime.now().millisecondsSinceEpoch,
        },
        'bulb_2': {
          'name': 'Kitchen Counter',
          'isOn': false,
          'brightness': 0.5,
          'dailyUsage': 0.85,
          'instantUsage': 0.0,
          'ratedWattage': 10.0,
          'totalConsumed': 0.0,
          'lastUpdate': DateTime.now().millisecondsSinceEpoch,
        },
      };
      await _userBulbsRef.set(initialBulbs);
    }
  }
}
