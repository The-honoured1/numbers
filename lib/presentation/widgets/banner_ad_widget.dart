import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:numbers/services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // Delay the heavyweight native ad initialization by 1 second.
    // This allows the initial screen entrance animations to finish rendering first,
    // completely eliminating the harsh "initial freeze" when navigating to pages.
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _loadAd();
      }
    });
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Standard banner ad size is 320x50. Locking this dimension strictly
    // prevents heavy layout shifting and frame drops when the ad finally loads.
    return RepaintBoundary(
      child: Container(
        alignment: Alignment.center,
        width: 320,
        height: 50,
        child: (_isLoaded && _bannerAd != null) 
            ? AdWidget(ad: _bannerAd!)
            : const SizedBox(width: 320, height: 50),
      ),
    );
  }
}
