import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namora/services/ads/ad_service.dart';
import 'package:namora/services/cache/cache_service.dart';
import 'package:namora/utils/logger/app_logger.dart';

abstract final class Bootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );
    }

    AppLogger.setMinLevel(LogLevel.debug);
    AppLogger.info('Bootstrapping Namora', tag: 'Bootstrap');

    await Future.wait([
      CacheService.init(),
      Hive.initFlutter(),
    ]);

    // Open favorites box
    await Hive.openBox<String>('favorites');

    // Initialize ads (non-blocking — runs in background)
    AdService.instance.init();

    AppLogger.info('Bootstrap complete', tag: 'Bootstrap');
  }
}
