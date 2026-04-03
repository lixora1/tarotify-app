import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DiamondBadge extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const DiamondBadge({super.key, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.diamond.withOpacity(0.1),
          border: Border.all(color: AppTheme.diamond.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💎', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text('$count', style: const TextStyle(color: AppTheme.diamond, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
