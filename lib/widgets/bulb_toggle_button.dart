import 'package:flutter/material.dart';

class BulbToggleButton extends StatelessWidget {
  final bool isOn;
  final double brightness;
  final VoidCallback onTap;

  const BulbToggleButton({
    super.key,
    required this.isOn,
    required this.brightness,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF252932),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.3 * brightness),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                  BoxShadow(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.1 * brightness),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            isOn ? Icons.lightbulb : Icons.lightbulb_outline,
            size: 80,
            color: isOn
                ? Colors.white.withValues(alpha: 0.5 + (brightness * 0.5))
                : Colors.white24,
          ),
        ),
      ),
    );
  }
}
