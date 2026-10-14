import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ads are Android-only for now — there's no iOS AdMob app yet, and
/// calling MobileAds.instance.initialize() on iOS/web without a real App
/// ID configured natively (Info.plist / not supported at all on web)
/// would fail there. Flip this on once an iOS AdMob app exists and its
/// App ID is added to ios/Runner/Info.plist.
bool get adsSupported => !kIsWeb && Platform.isAndroid;

// Google's public sample unit IDs in debug builds — never serve real ads
// to a developer's own device, that risks the AdMob account being flagged
// for invalid traffic.
String get bannerAdUnitId => kDebugMode
    ? 'ca-app-pub-3940256099942544/6300978111'
    : 'ca-app-pub-7616228384454849/2651027681';

String get interstitialAdUnitId => kDebugMode
    ? 'ca-app-pub-3940256099942544/1033173712'
    : 'ca-app-pub-7616228384454849/7523934624';

/// Owns the interstitial ad shown after a match ends. Keeps one preloaded
/// at all times so [showAfterGame] can display instantly instead of
/// blocking the Game Over screen on a network load.
class AdService {
  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  Future<void> init() async {
    if (!adsSupported) return;
    try {
      await MobileAds.instance.initialize();
      // This app's realistic player base spans children through adults —
      // there's no birthdate/account system to tell them apart per user,
      // so every request is treated as child-directed: non-personalized,
      // general-audience (G-rated) ads for everyone. Simpler and safer
      // than building age verification for a casual puzzle game.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          maxAdContentRating: MaxAdContentRating.g,
          ageRestrictedTreatment: AgeRestrictedTreatment.child,
        ),
      );
      _loadInterstitial();
    } catch (e) {
      debugPrint('AdService: initialize failed: $e');
    }
  }

  void _loadInterstitial() {
    if (!adsSupported || _loadingInterstitial || _interstitial != null) {
      return;
    }
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitial = ad;
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          debugPrint('AdService: interstitial failed to load: $error');
        },
      ),
    );
  }

  /// Shows the preloaded interstitial if one is ready, then starts loading
  /// the next one. A no-op (never blocks the caller) if none is ready yet
  /// — the Game Over screen should never wait on an ad network call.
  void showAfterGame() {
    final ad = _interstitial;
    if (!adsSupported || ad == null) return;
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: interstitial failed to show: $error');
        ad.dispose();
        _loadInterstitial();
      },
    );
    ad.show();
  }

  void dispose() {
    _interstitial?.dispose();
  }
}
