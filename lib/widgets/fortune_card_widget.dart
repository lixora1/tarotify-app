// fortune_card_widget.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class FortuneCardWidget extends StatelessWidget {
  final String emoji;
  final String name;
  final Color accentColor;
  final bool isAI;
  final VoidCallback onTap;

  const FortuneCardWidget({
    super.key,
    required this.emoji,
    required this.name,
    required this.accentColor,
    required this.isAI,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.cardBg, accentColor.withOpacity(0.08)],
          ),
          border: Border.all(color: AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 10),
                  Text(name, style: const TextStyle(fontFamily: 'Cinzel', fontSize: 13, color: AppTheme.gold, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('💎 ', style: TextStyle(fontSize: 11)),
                    Text('50', style: TextStyle(color: AppTheme.diamond, fontSize: 12)),
                  ]),
                ],
              ),
            ),
            if (isAI)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.purple, AppTheme.purple2]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('YZ', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
