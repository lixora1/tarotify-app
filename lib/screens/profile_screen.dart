import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/diamond_service.dart';
import '../widgets/shop_bottom_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _diamonds = 0;

  @override
  void initState() {
    super.initState();
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.purpleGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold, width: 2),
                ),
                child: const Center(child: Text('🔮', style: TextStyle(fontSize: 36))),
              ),
              const SizedBox(height: 12),
              const Text('Mistik Kullanıcı', style: TextStyle(fontFamily: 'Cinzel', fontSize: 18, color: AppTheme.gold)),
              const SizedBox(height: 4),
              const Text('Tarotify\'a Hoş Geldin ✦', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 24),

              // Stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _statBox('💎', '$_diamonds', 'Elmas'),
                    const SizedBox(width: 12),
                    _statBox('🔮', '0', 'Fal'),
                    const SizedBox(width: 12),
                    _statBox('🌟', '8', 'Tür'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: () => ShopBottomSheet.show(context),
                  child: const Text('💎 Elmas Satın Al'),
                ),
              ),

              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GEÇMIŞ FAL', style: TextStyle(fontFamily: 'Cinzel', fontSize: 12, color: AppTheme.gold, letterSpacing: 0.5)),
                    const SizedBox(height: 16),
                    const Center(
                      child: Column(children: [
                        Text('🌙', style: TextStyle(fontSize: 40)),
                        SizedBox(height: 8),
                        Text('Henüz fal baktırmadınız', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String emoji, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppTheme.cardBg, border: Border.all(color: AppTheme.cardBorder), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontFamily: 'Cinzel', fontSize: 18, color: AppTheme.gold, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
