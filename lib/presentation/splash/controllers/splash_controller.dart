import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_controller.g.dart';

/// Times the splash hand-over to the breed list.
///
/// The splash screen only renders; this controller owns when the app moves on,
/// so the timing is testable and the widget stays presentation-only. The state
/// flips to `true` once the splash has been visible long enough.
@riverpod
class SplashController extends _$SplashController {
  /// How long the splash stays visible before handing over to the catalog.
  static const Duration displayDuration = Duration(milliseconds: 2200);

  Timer? _timer;

  @override
  bool build() {
    _timer = Timer(displayDuration, () => state = true);
    ref.onDispose(() => _timer?.cancel());
    return false;
  }
}
