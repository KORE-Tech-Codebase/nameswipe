import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:namora/core/constants/ad_constants.dart';
import 'package:namora/utils/logger/app_logger.dart';

/// Centralized ad manager — handles preloading, caching, frequency caps,
/// and proper disposal of all ad types.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  static const String _tag = 'AdService';

  bool _isInitialized = false;

  // Interstitial
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;
  int _swipeCount = 0;
  int _detailViewCount = 0;
  DateTime? _lastInterstitialShown;

  // Rewarded
  RewardedAd? _rewardedAd;
  bool _isLoadingRewarded = false;

  // ─── Init ────────────────────────────────────────────────────

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      AppLogger.info('MobileAds initialized', tag: _tag);
      _preloadInterstitial();
      _preloadRewarded();
    } catch (e) {
      AppLogger.error('Failed to init MobileAds: $e', tag: _tag);
    }
  }

  // ─── Banner ──────────────────────────────────────────────────

  /// Creates a banner ad. Caller is responsible for disposing it.
  BannerAd createBannerAd({
    required void Function(Ad) onLoaded,
    void Function(Ad, LoadAdError)? onFailed,
  }) {
    return BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: (ad, error) {
          AppLogger.warning('Banner failed: $error', tag: _tag);
          ad.dispose();
          onFailed?.call(ad, error);
        },
      ),
    );
  }

  // ─── Interstitial ────────────────────────────────────────────

  void _preloadInterstitial() {
    if (_interstitialAd != null || _isLoadingInterstitial) return;
    _isLoadingInterstitial = true;

    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
          AppLogger.debug('Interstitial preloaded', tag: _tag);
        },
        onAdFailedToLoad: (error) {
          _isLoadingInterstitial = false;
          AppLogger.warning('Interstitial load failed: $error', tag: _tag);
        },
      ),
    );
  }

  /// Call after each swipe. Shows interstitial every N swipes.
  void recordSwipe() {
    _swipeCount++;
    if (_swipeCount >= AdConstants.interstitialSwipeInterval) {
      _swipeCount = 0;
      _tryShowInterstitial();
    }
  }

  /// Call when opening a name detail page. Shows every N views.
  void recordDetailView() {
    _detailViewCount++;
    if (_detailViewCount >= AdConstants.interstitialDetailInterval) {
      _detailViewCount = 0;
      _tryShowInterstitial();
    }
  }

  void _tryShowInterstitial() {
    if (_lastInterstitialShown != null) {
      final elapsed = DateTime.now().difference(_lastInterstitialShown!);
      if (elapsed < AdConstants.interstitialCooldown) {
        AppLogger.debug('Interstitial on cooldown', tag: _tag);
        return;
      }
    }

    final ad = _interstitialAd;
    if (ad == null) {
      _preloadInterstitial();
      return;
    }

    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.warning('Interstitial show failed: $error', tag: _tag);
        ad.dispose();
        _preloadInterstitial();
      },
    );

    _lastInterstitialShown = DateTime.now();
    ad.show();
  }

  // ─── Rewarded ────────────────────────────────────────────────

  void _preloadRewarded() {
    if (_rewardedAd != null || _isLoadingRewarded) return;
    _isLoadingRewarded = true;

    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
          AppLogger.debug('Rewarded ad preloaded', tag: _tag);
        },
        onAdFailedToLoad: (error) {
          _isLoadingRewarded = false;
          AppLogger.warning('Rewarded load failed: $error', tag: _tag);
        },
      ),
    );
  }

  bool get isRewardedAdReady => _rewardedAd != null;

  /// Shows rewarded ad. Returns true if reward was earned, false otherwise.
  /// If no ad is ready, returns true immediately (don't block the user).
  Future<bool> showRewardedAd() async {
    final ad = _rewardedAd;
    if (ad == null) {
      _preloadRewarded();
      return true; // Don't block — let user proceed
    }

    _rewardedAd = null;
    bool rewarded = false;
    final completer = Completer<bool>();

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadRewarded();
        if (!completer.isCompleted) completer.complete(rewarded);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.warning('Rewarded show failed: $error', tag: _tag);
        ad.dispose();
        _preloadRewarded();
        if (!completer.isCompleted) completer.complete(true);
      },
    );

    ad.show(onUserEarnedReward: (ad, reward) {
      rewarded = true;
    });

    return completer.future;
  }

  // ─── Cleanup ─────────────────────────────────────────────────

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
