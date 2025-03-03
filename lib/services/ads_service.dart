import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdsService {
  static String get bannerAdUnitId {
    // Use test ad unit IDs in development
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Ad loaded successfully');
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  static Widget buildBannerAdWidget(BannerAd? bannerAd, bool isReady) {
    if (!isReady || bannerAd == null) return const SizedBox.shrink();
    
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: SizedBox(
          width: bannerAd.size.width.toDouble(),
          height: bannerAd.size.height.toDouble(),
          child: AdWidget(ad: bannerAd),
        ),
      ),
    );
  }
} 