import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/ads_controller.dart';
import '../services/premium_service.dart';

class AdBannerWidget extends StatelessWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final adsController = Get.find<AdsController>();
    final premiumService = Get.find<PremiumService>();
    
    return Obx(() {
      // Don't show ads if user has premium or removed ads
      if (!premiumService.shouldShowAds()) {
        return const SizedBox.shrink();
      }
      
      if (!adsController.isBannerAdLoaded || adsController.bannerAd == null) {
        return const SizedBox.shrink();
      }
      
      return Container(
        alignment: Alignment.center,
        width: adsController.bannerAd!.size.width.toDouble(),
        height: adsController.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: adsController.bannerAd!),
      );
    });
  }
}