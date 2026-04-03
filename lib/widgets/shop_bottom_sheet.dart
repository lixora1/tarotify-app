import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/diamond_service.dart';
import '../services/ad_service.dart';
import '../services/purchase_service.dart';

class ShopBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ShopSheet(),
    );
  }
}

class _ShopSheet extends StatefulWidget {
  const _ShopSheet();
  @override
  State<_ShopSheet> createState() => _ShopSheetState();
}

class _ShopSheetState extends State<_ShopSheet> {
  bool _watchingAd = false;

  static const _packages = [
    {'id': 'tarotify_diamonds_100',  'name': 'Başlangıç',     'diamonds': 100,  'price': '₺29,99',  'icon': '💎', 'popular': false},
    {'id': 'tarotify_diamonds_300',  'name': 'Mistik Paket',  'diamonds': 300,  'price': '₺69,99',  'icon': '💎', 'popular': true},
    {'id': 'tarotify_diamonds_700',  'name': 'Büyük Paket',   'diamonds': 700,  'price': '₺139,99', 'icon': '💎', 'popular': false},
    {'id': 'tarotify_diamonds_2000', 'name': 'Premium Yıllık','diamonds': 2000, 'price': '₺299,99', 'icon': '💎', 'popular': false},
  ];

  Future<void> _watchAd() async {
    setState(() => _watchingAd = true);
    final success = await AdService.instance.showRewardedAd();
    setState(() => _watchingAd = false);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('💎 +25 elmas kazandınız!'), backgroundColor: AppTheme.deepBg3, behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reklam henüz hazır değil, lütfen tekrar deneyin.'), backgroundColor: AppTheme.deepBg3),
      );
    }
  }

  Future<void> _buyPackage(Map pkg) async {
    final products = PurchaseService.instance.products;
    final product = products.firstWhere(
      (p) => p.id == pkg['id'],
      orElse: () => throw Exception('Ürün bulunamadı'),
    );
    try {
      await PurchaseService.instance.buyProduct(product);
    } catch (e) {
      // Test modunda fake satın alım
      await DiamondService.instance.earn(pkg['diamonds'] as int);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('💎 ${pkg['diamonds']} elmas eklendi!'), backgroundColor: AppTheme.deepBg3, behavior: SnackBarBehavior.floating),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppTheme.deepBg2, AppTheme.deepBg]),
        border: Border(top: BorderSide(color: AppTheme.cardBorder, width: 0.5)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const Text('💎 Elmas Paketi Seç', style: TextStyle(fontFamily: 'Cinzel', fontSize: 18, color: AppTheme.gold)),
            const SizedBox(height: 4),
            const Text('Daha fazla fal için elmas satın al', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 20),
            ..._packages.map((pkg) => _buildPackageCard(pkg)).toList(),
            const SizedBox(height: 12),
            _buildWatchAdButton(),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map pkg) {
    final isPopular = pkg['popular'] as bool;
    return GestureDetector(
      onTap: () => _buyPackage(pkg),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPopular ? AppTheme.gold.withOpacity(0.08) : AppTheme.cardBg,
          border: Border.all(color: isPopular ? AppTheme.gold : AppTheme.cardBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Text('💎', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular)
                    const Text('⭐ EN POPÜLER', style: TextStyle(color: AppTheme.gold2, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  Text(pkg['name'] as String, style: const TextStyle(fontFamily: 'Cinzel', fontSize: 14, color: AppTheme.gold)),
                  Row(children: [
                    const Text('💎 ', style: TextStyle(fontSize: 11)),
                    Text('${pkg['diamonds']} elmas', style: const TextStyle(color: AppTheme.diamond, fontSize: 12)),
                  ]),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppGradients.goldGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(pkg['price'] as String, style: const TextStyle(color: Color(0xFF1A1000), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchAdButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _watchingAd ? null : _watchAd,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.diamond,
          side: const BorderSide(color: AppTheme.diamond, width: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _watchingAd
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.diamond, strokeWidth: 2))
          : const Text('📺 Reklam İzle → +25 💎 Kazan (Ücretsiz)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
