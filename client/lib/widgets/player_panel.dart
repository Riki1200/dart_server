import 'package:flutter/material.dart';

class PlayerPanel extends StatelessWidget {
  final bool iWasSelected;

  const PlayerPanel({super.key, required this.iWasSelected});

  @override
  Widget build(BuildContext context) {
    final color = iWasSelected ? Colors.green : Colors.grey.shade400;
    final icon = iWasSelected
        ? Icons.celebration_rounded
        : Icons.hourglass_empty_rounded;
    final title = iWasSelected ? '¡HAS SIDO ELEGIDO!' : 'Esperando...';
    final subtitle = iWasSelected
        ? 'Es tu momento de brillar ✨'
        : 'Mantente atento a la pantalla';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: iWasSelected ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: iWasSelected ? Colors.green.shade200 : Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: iWasSelected
                  ? Colors.green.shade800
                  : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: iWasSelected
                  ? Colors.green.shade700
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
