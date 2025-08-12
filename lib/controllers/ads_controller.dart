import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsController extends GetxController {
  static AdsController get instance => Get.find<AdsController>();
  
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  final RxBool _isBannerAdLoaded = false.obs;
  final RxBool _isInterstitialAdLoaded = false.obs;
  final RxBool _isRewardedAdLoaded = false.obs;
  
  bool get isBannerAdLoaded => _isBannerAdLoaded.value;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded.value;
  bool get isRewardedAdLoaded => _isRewardedAdLoaded.value;
  
  BannerAd? get bannerAd => _bannerAd;
  
  // Test Ad Unit IDs - Replace with real ones for production
  static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  @override
  void onInit() {
    super.onInit();
    _initializeAds();
  }
  
  Future<void> _initializeAds() async {
    await MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }
  
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => _isBannerAdLoaded.value = true,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerAdLoaded.value = false;
        },
      ),
    );
    _bannerAd?.load();
  }
  
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded.value = true;
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded.value = false;
        },
      ),
    );
  }
  
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded.value = true;
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded.value = false;
        },
      ),
    );
  }
  
  void showInterstitialAd({void Function()? onAdClosed}) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          onAdClosed?.call();
        },
      );
      _interstitialAd!.show();
      _isInterstitialAdLoaded.value = false;
    } else {
      onAdClosed?.call();
    }
  }
  
  void showRewardedAd({required Function(RewardItem) onUserEarnedReward}) {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadRewardedAd();
        },
      );
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) => onUserEarnedReward(reward));
      _isRewardedAdLoaded.value = false;
    }
  }
  
  @override
  void onClose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.onClose();
  }
}