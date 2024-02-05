import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/logger/logger.dart';

class Observers extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    logger.i("Provider updated: ${provider.name}\n"
        "Previous value: $previousValue\n"
        "New value: $newValue");
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) {
    logger.i("Provider disposed: ${provider.name}");
    super.didDisposeProvider(provider, container);
  }
}
