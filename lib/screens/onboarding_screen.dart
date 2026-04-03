import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  final _pages = [
    {'emoji': '🔮', 'title': 'Mistik Fal Deneyimi', 'desc': 'Yapay zeka destekli 8 farklı fal türüyle geleceğini keşfet'},
    {'emoji': '☕', 'title': 'YZ Analizi', 'desc': 'Kahve ve el falında fotoğrafını yükle, YZ her detayı analiz etsin'},
    {'emoji': '💎', 'title': '200 Elmas Hediye!', 'desc': 'Uygulamaya hoş geldin! Sana 200 elmas hediye. Her fal 50 elmas.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_pages[i]['emoji']!, style: const TextStyle(fontSize: 80)),
                      const SizedBox(height: 32),
                      Text(_pages[i]['title']!, style: const TextStyle(fontFamily: 'Cinzel', fontSize: 24, color: AppTheme.gold, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(_pages[i]['desc']!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16, height: 1.6), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => Container(
                width: _page == i ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: _page == i ? AppTheme.gold : AppTheme.cardBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: () {
                  if (_page < _pages.length - 1) {
                    _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  } else {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                  }
                },
                child: Text(_page < _pages.length - 1 ? 'Devam Et' : '✦ Başla — 200 💎 Al'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
