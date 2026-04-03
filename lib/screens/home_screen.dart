import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/diamond_service.dart';
import '../widgets/fortune_card_widget.dart';
import '../widgets/diamond_badge.dart';
import '../widgets/shop_bottom_sheet.dart';
import 'fortune_detail_screen.dart';
import 'profile_screen.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  int _diamonds = 0;

  final List<Map<String, dynamic>> _fortunes = [
    {'type': FortuneType.coffee,  'emoji': '☕', 'name': 'Kahve Falı',   'color': const Color(0xFF6B3E26), 'ai': true},
    {'type': FortuneType.tarot,   'emoji': '🃏', 'name': 'Tarot',        'color': AppTheme.purple,         'ai': false},
    {'type': FortuneType.hand,    'emoji': '🖐', 'name': 'El Falı',      'color': const Color(0xFF2D5A8E), 'ai': true},
    {'type': FortuneType.face,    'emoji': '🪞', 'name': 'Yüz Falı',     'color': const Color(0xFF4A2D6E), 'ai': true},
    {'type': FortuneType.dream,   'emoji': '🌙', 'name': 'Rüya Yorumu',  'color': const Color(0xFF1A3A5C), 'ai': false},
    {'type': FortuneType.water,   'emoji': '💧', 'name': 'Su Falı',      'color': const Color(0xFF0D3A5C), 'ai': false},
    {'type': FortuneType.star,    'emoji': '⭐', 'name': 'Yıldızname',   'color': const Color(0xFF2A1A5C), 'ai': false},
    {'type': FortuneType.iskambil,'emoji': '♠️', 'name': 'İskambil',     'color': const Color(0xFF1C3A1C), 'ai': false},
    {'type': FortuneType.love,    'emoji': '💕', 'name': 'Aşk Falı',     'color': const Color(0xFF5C1A3A), 'ai': false},
    {'type': FortuneType.color,   'emoji': '🎨', 'name': 'Renk Falı',    'color': const Color(0xFF3A1A5C), 'ai': false},
    {'type': FortuneType.chinese, 'emoji': '🐉', 'name': 'Çin Falı',     'color': const Color(0xFF5C1A1A), 'ai': false},
  ];

  @override
  void initState() {
    super.initState();
    DiamondService.instance.load();
    DiamondService.instance.addListener(_onDiamondsChanged);
    _diamonds = DiamondService.instance.diamonds;
  }

  @override
  void dispose() {
    DiamondService.instance.removeListener(_onDiamondsChanged);
    super.dispose();
  }

  void _onDiamondsChanged(int val) => setState(() => _diamonds = val);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBg,
      body: _currentTab == 0 ? _buildHome() : const ProfileScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(child: _buildHero()),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => FortuneCardWidget(
                emoji: _fortunes[i]['emoji'],
                name: _fortunes[i]['name'],
                accentColor: _fortunes[i]['color'],
                isAI: _fortunes[i]['ai'],
                onTap: () => _openFortune(_fortunes[i]['type']),
              ),
              childCount: _fortunes.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.deepBg.withOpacity(0.95),
      title: const Text('✦ Tarotify', style: TextStyle(fontFamily: 'Cinzel', color: AppTheme.gold, fontSize: 20, fontWeight: FontWeight.bold)),
      centerTitle: false,
      actions: [
        DiamondBadge(
          count: _diamonds,
          onTap: () => ShopBottomSheet.show(context),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        children: [
          const Text('✦ ✧ ✦', style: TextStyle(color: AppTheme.gold, fontSize: 20, letterSpacing: 8)),
          const SizedBox(height: 12),
          ShaderMask(
            shaderCallback: (bounds) => AppGradients.goldGradient.createShader(bounds),
            child: const Text(
              'Kaderine Bak,\nGeleceğini Keşfet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cinzel',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Yapay zeka destekli mistik fal deneyimi',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.deepBg.withOpacity(0.97),
        border: const Border(top: BorderSide(color: AppTheme.cardBorder, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, '🏠', 'Ana Sayfa'),
              _navItem(1, '👤', 'Profil'),
              GestureDetector(
                onTap: () => ShopBottomSheet.show(context),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('💎', style: TextStyle(fontSize: 22)),
                    SizedBox(height: 4),
                    Text('Elmas Al', style: TextStyle(fontSize: 10, color: AppTheme.diamond)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, String emoji, String label) {
    final active = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? AppTheme.gold : AppTheme.textSecondary,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _openFortune(FortuneType type) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => FortuneDetailScreen(type: type),
    ));
  }
}
