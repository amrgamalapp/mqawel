import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // تفعيل وضع الاختبار لحماية الحساب أثناء فترة الـ Closed Testing
  static const bool isTestMode = true;

  // معرّفات وحدات الإعلانات الخاصة بحسابك في AdMob
  static const String _realBannerId = 'ca-app-pub-3310851277570813/3590154936';
  static const String _realInterstitialId = 'ca-app-pub-3310851277570813/4483650389';

  // معرّفات الاختبار الرسمية من Google AdMob
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  static String get bannerAdUnitId {
    if (isTestMode || kDebugMode) return _testBannerId;
    return Platform.isAndroid ? _realBannerId : '';
  }

  static String get interstitialAdUnitId {
    if (isTestMode || kDebugMode) return _testInterstitialId;
    return Platform.isAndroid ? _realInterstitialId : '';
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;
  DateTime? _lastInterstitialShownTime;
  int _actionCounter = 0;

  Future<void> init() async {
    await MobileAds.instance.initialize();
    loadInterstitialAd();
  }

  void loadInterstitialAd() {
    if (_isInterstitialAdLoading || _interstitialAd != null) return;
    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialAdLoading = false;
        },
      ),
    );
  }

  // إظهار الإعلان البيني بهدوء (يظهر بعد 4 نقرات وبفاصل 4 دقائق كحد أدنى)
  void showSmartInterstitial({int requiredActions = 4, int minIntervalMinutes = 4}) {
    _actionCounter++;

    if (_actionCounter < requiredActions) return;

    if (_lastInterstitialShownTime != null) {
      final difference = DateTime.now().difference(_lastInterstitialShownTime!);
      if (difference.inMinutes < minIntervalMinutes) return;
    }

    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _lastInterstitialShownTime = DateTime.now();
          _actionCounter = 0;
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          loadInterstitialAd();
        },
      );

      _interstitialAd!.show();
    } else {
      loadInterstitialAd();
    }
  }
}

/// Test/production banner widget.
/// When [AdService.isTestMode] is true, this uses Google's official
/// AdMob test banner unit ID. The real AdMob unit ID remains untouched
/// and will be used automatically when test mode is disabled.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    final ad = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd = ad;
    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: Center(
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

