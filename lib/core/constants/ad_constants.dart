abstract final class AdConstants {
  // Test Ad Unit IDs (replace with real IDs before publishing)
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // Frequency caps
  static const int interstitialSwipeInterval = 15;
  static const int interstitialDetailInterval = 3;

  // Cooldowns (prevent ad fatigue)
  static const Duration interstitialCooldown = Duration(minutes: 2);
}
