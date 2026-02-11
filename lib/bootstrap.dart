import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nameswipe/services/cache/cache_service.dart';
import 'package:nameswipe/services/cache/database_service.dart';
import 'package:nameswipe/utils/logger/app_logger.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';

abstract final class Bootstrap {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

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
    AppLogger.info('Bootstrapping NameSwipe', tag: 'Bootstrap');

    await Future.wait([
      CacheService.init(),
      DatabaseService.init(),
    ]);

    // TODO: Uncomment when ready to enable ads
    // await MobileAds.instance.initialize();

    AppLogger.info('Bootstrap complete', tag: 'Bootstrap');
  }
}
