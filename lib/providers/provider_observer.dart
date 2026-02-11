import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nameswipe/utils/logger/app_logger.dart';

class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    AppLogger.debug(
      'Provider added: ${provider.name ?? provider.runtimeType}',
      tag: 'Riverpod',
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    AppLogger.debug(
      'Provider updated: ${provider.name ?? provider.runtimeType}',
      tag: 'Riverpod',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    AppLogger.debug(
      'Provider disposed: ${provider.name ?? provider.runtimeType}',
      tag: 'Riverpod',
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      'Provider failed: ${provider.name ?? provider.runtimeType}',
      tag: 'Riverpod',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
