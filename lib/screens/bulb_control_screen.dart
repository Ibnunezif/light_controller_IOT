import 'package:flutter/material.dart';
import '../models/bulb.dart';
import '../models/language.dart';
import '../services/localization_service.dart';
import '../services/firebase_service.dart';
import '../widgets/bulb_toggle_button.dart';
import '../widgets/brightness_slider.dart';
import '../widgets/status_row.dart';

class BulbControlScreen extends StatefulWidget {
  final Bulb bulb;
  final AppLanguage lang;
  const BulbControlScreen({super.key, required this.bulb, required this.lang});

  @override
  State<BulbControlScreen> createState() => _BulbControlScreenState();
}

class _BulbControlScreenState extends State<BulbControlScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Bulb _currentBulb;

  @override
  void initState() {
    super.initState();
    _currentBulb = widget.bulb;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(_currentBulb.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
            Text(LocalizationService.get('lighting', widget.lang), 
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Bulb>>(
        stream: _firebaseService.getBulbsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Find the updated bulb in the list
            try {
              _currentBulb = snapshot.data!.firstWhere((b) => b.id == _currentBulb.id);
            } catch (e) {
              // Bulb might have been deleted
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                StatusRow(
                  isOn: _currentBulb.isOn,
                  dailyUsage: _currentBulb.formattedDailyUsage,
                  lang: widget.lang,
                ),
                const SizedBox(height: 60),
                BulbToggleButton(
                  isOn: _currentBulb.isOn,
                  brightness: _currentBulb.brightness,
                  onTap: () {
                    _firebaseService.toggleBulb(_currentBulb, !_currentBulb.isOn);
                  },
                ),
                const SizedBox(height: 80),
                BrightnessSlider(
                  value: _currentBulb.brightness,
                  enabled: _currentBulb.isOn,
                  onChanged: (value) {
                    setState(() {
                      _currentBulb.brightness = value;
                    });
                  },
                  onChangeEnd: (value) {
                    _firebaseService.updateBrightness(_currentBulb, value);
                  },
                ),
                const SizedBox(height: 40),
                _buildLifetimeUsage(),
              ],
            ),
          );
        }
      ),
    );
  }


  Widget _buildLifetimeUsage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lifetime Usage', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Accumulated energy', style: TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
          Text(_currentBulb.formattedTotalConsumed, 
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252932),
        title: const Text('Delete Bulb'),
        content: Text('Are you sure you want to remove "${_currentBulb.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _firebaseService.deleteBulb(_currentBulb.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to list
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
