import 'package:flutter/material.dart';

class SliderSection extends StatelessWidget {
  final String title;
  final double value;
  final double maxVal;
  final int divisions;
  final Function(double) onChanged;
  final IconData icon;
  final Color color;

  const SliderSection({
    super.key,
    required this.title,
    required this.value,
    required this.maxVal,
    required this.divisions,
    required this.onChanged,
    required this.icon,
    required this.color,
  });

  void _showNumericInputDialog(BuildContext context, String title, double currentValue, Function(double) onChanged) {
    final ctrl = TextEditingController(text: currentValue.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('Set $title'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Value',
            labelStyle: TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.black26,
          ),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text) ?? currentValue;
              onChanged(val);
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = maxVal / divisions;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            InkWell(
              onTap: () => _showNumericInputDialog(context, title, value, onChanged),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.white54),
              onPressed: () {
                final newVal = (value - step).clamp(0.0, maxVal);
                onChanged(newVal);
              },
            ),
            Expanded(
              child: Slider(
                value: value.clamp(0.0, maxVal),
                max: maxVal,
                divisions: divisions,
                activeColor: color,
                onChanged: onChanged,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white54),
              onPressed: () {
                final newVal = (value + step).clamp(0.0, maxVal);
                onChanged(newVal);
              },
            ),
          ],
        ),
      ],
    );
  }
}
