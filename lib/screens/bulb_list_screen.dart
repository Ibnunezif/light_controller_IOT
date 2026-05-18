import 'package:flutter/material.dart';
import '../models/bulb.dart';
import '../models/language.dart';
import '../services/localization_service.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../widgets/bulb_card.dart';
import '../widgets/language_selector.dart';
import 'bulb_control_screen.dart';

class BulbListScreen extends StatefulWidget {
  final AppLanguage currentLang;
  final Function(AppLanguage) onLanguageChanged;

  const BulbListScreen({
    super.key,
    required this.currentLang,
    required this.onLanguageChanged,
  });

  @override
  State<BulbListScreen> createState() => _BulbListScreenState();
}

class _BulbListScreenState extends State<BulbListScreen> {
  final AppFirebaseService _firebaseService = AppFirebaseService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationService.get('title', widget.currentLang),
            style: const TextStyle(fontWeight: FontWeight.w300)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          LanguageSelector(onLanguageChanged: widget.onLanguageChanged),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authService.signOut(),
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBulbDialog(context),
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Bulb>>(
        stream: _firebaseService.getBulbsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          final bulbs = snapshot.data ?? [];

          if (bulbs.isEmpty) {
            return Center(
              child: Text(
                'No bulbs found.\nTap the + button to add one.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            );
          }

          final double totalInstantUsage = bulbs.fold(0, (sum, bulb) => sum + bulb.instantUsage);
          final double totalDailyUsage = bulbs.fold(0, (sum, bulb) => sum + bulb.dailyUsage);
          final double totalLifetimeUsage = bulbs.fold(0, (sum, bulb) => sum + bulb.totalConsumed);

          return Column(
            children: [
              _buildUsageSummary(totalInstantUsage, totalDailyUsage, totalLifetimeUsage),
              _buildConnectivityIndicator(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: bulbs.length,
                  itemBuilder: (context, index) {
                    final bulb = bulbs[index];
                    return Dismissible(
                      key: Key(bulb.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        _firebaseService.deleteBulb(bulb.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${bulb.name} deleted')),
                        );
                      },
                      child: BulbCard(
                        bulb: bulb,
                        lang: widget.currentLang,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BulbControlScreen(
                                bulb: bulb,
                                lang: widget.currentLang,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUsageSummary(double instant, double daily, double total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurpleAccent.withValues(alpha: 0.8), Colors.deepPurple.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('Instant', '${instant.toStringAsFixed(1)} W', Icons.bolt),
              _summaryItem('Daily Est.', '${daily.toStringAsFixed(2)} kWh', Icons.today),
            ],
          ),
          const Divider(color: Colors.white24, height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.history, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text('Total Consumed: ', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('${total.toStringAsFixed(3)} kWh', 
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConnectivityIndicator() {
    return StreamBuilder<bool>(
      stream: _firebaseService.connectionStream,
      builder: (context, snapshot) {
        final bool isConnected = snapshot.data ?? true;
        if (isConnected) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: Colors.orangeAccent.withValues(alpha: 0.2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 14, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text(
                'Offline Mode - Changes will sync when reconnected',
                style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showAddBulbDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController wattageController = TextEditingController(text: '60');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252932),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Smart Bulb'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Bulb Name',
                hintText: 'e.g. Living Room',
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: wattageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Rated Wattage (W)',
                hintText: 'e.g. 60',
                suffixText: 'Watts',
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.deepPurpleAccent)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final String name = nameController.text.trim();
              final double? wattage = double.tryParse(wattageController.text);
              
              if (name.isNotEmpty && wattage != null) {
                _firebaseService.addBulb(name, wattage);
                Navigator.pop(context);
              }
            },
            child: const Text('Add Bulb', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
