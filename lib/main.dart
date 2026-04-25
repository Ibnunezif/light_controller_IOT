import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Light Controller IoT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const LightControllerPage(),
    );
  }
}

class LightControllerPage extends StatefulWidget {
  const LightControllerPage({super.key});

  @override
  State<LightControllerPage> createState() => _LightControllerPageState();
}

class _LightControllerPageState extends State<LightControllerPage> {
  bool _isLightOn = false;
  double _brightness = 0.5;

  void _toggleLight() {
    setState(() {
      _isLightOn = !_isLightOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Light Controller'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
              size: 100,
              color: _isLightOn ? Colors.yellow.withOpacity(_brightness) : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _isLightOn ? 'Light is ON' : 'Light is OFF',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            Switch(
              value: _isLightOn,
              onChanged: (value) => _toggleLight(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Slider(
                value: _brightness,
                onChanged: _isLightOn
                    ? (value) {
                        setState(() {
                          _brightness = value;
                        });
                      }
                    : null,
                label: 'Brightness',
              ),
            ),
            Text('Brightness: ${(_brightness * 100).round()}%'),
          ],
        ),
      ),
    );
  }
}
