// splash_screen.dart
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (b) => AppGradients.goldGradient.createShader(b),
              child: const Text('✦', style: TextStyle(fontSize: 64, color: Colors.white)),
            ),
            const SizedBox(height: 16),
            const Text('Tarotify', style: TextStyle(fontFamily: 'Cinzel', fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.gold)),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppTheme.gold, strokeWidth: 2),
          ],
        ),
      ),
    );
  }
}
