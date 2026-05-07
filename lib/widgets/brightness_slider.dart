import 'package:flutter/material.dart';

class BrightnessSlider extends StatelessWidget {
  final double value;
  final bool enabled;
  final Function(double) onChanged;
  final Function(double)? onChangeEnd;

  const BrightnessSlider({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          const Icon(Icons.light_mode, size: 16, color: Colors.grey),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white12,
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: value,
                onChanged: enabled ? onChanged : null,
                onChangeEnd: enabled ? onChangeEnd : null,
              ),
            ),
          ),
          const Icon(Icons.light_mode, size: 24, color: Colors.white),
        ],
      ),
    );
  }
}
