import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'diamond_service.dart';

/// AdMob — Banner + Rewarded Video reklam servisi
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  bool _isRewardedReady = false;

  // ⚠️ TEST ID'leri — canlıya geçmeden önce gerçek ID'lerle değiştirin!
  static String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6091501003143864/1740034251';
      // CANLI: return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    }
    return 'ca-app-pub-3940256099942544/1712485313'; // iOS TEST
  }

  static String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-6091501003143864/3294555431';
      // CANLI: return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    }
    return 'ca-app-pub-3940256099942544/2934735716'; // iOS TEST
  }

  void initialize() {
    _loadRewardedAd();
  }

  // Rewarded Video reklam yükle
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedReady = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _isRewardedReady = false;
              _loadRewardedAd(); // Sonraki için önceden yükle
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedReady = false;
          // 30 saniye sonra tekrar dene
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  /// Rewarded reklam göster. Kullanıcı izlerse true döner.
  Future<bool> showRewardedAd() async {
    if (!_isRewardedReady || _rewardedAd == null) {
      return false;
    }

    bool rewarded = false;
    _rewardedAd!.show(
      onUserEarnedReward: (_, reward) async {
        rewarded = true;
        await DiamondService.instance.earn(DiamondService.adReward);
      },
    );
    return rewarded;
  }

  bool get isRewardedReady => _isRewardedReady;

  // Banner reklam oluştur
  BannerAd createBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();
    return _bannerAd!;
  }

  void dispose() {
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
  }
}
