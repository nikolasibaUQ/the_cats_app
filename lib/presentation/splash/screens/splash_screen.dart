import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../controllers/splash_controller.dart';

/// Brief entry screen that hands over to the breed list.
///
/// The splash belongs to the app shell: it uses no breed state and replaces
/// itself with `/breeds` so normal navigation does not leave an extra
/// browser-history stop behind. [SplashController] owns the timing; this
/// screen only renders and reacts when the controller says it is time to go.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(splashControllerProvider, (_, ready) {
      if (ready) context.pushReplacement(AppRoutes.breeds);
    });
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(responsive.pagePadding),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // The artwork keeps its square shape and grows with the
                // viewport, capped so it never dominates a wide screen. The
                // Flexible wrapper lets it give up room before the texts do
                // on short viewports or with a large text scale.
                final artworkSize = math.min(
                  constraints.maxWidth * 0.55,
                  math.min(constraints.maxHeight * 0.42, 280.0),
                );
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: artworkSize,
                        height: artworkSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // A soft glow in the brand accents gives the entry
                            // screen presence without adding motion or noise.
                            DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    colors.tertiary.withValues(alpha: 0.35),
                                    colors.primary.withValues(alpha: 0.20),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.55, 1.0],
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/splash_image.png',
                              width: artworkSize,
                              height: artworkSize,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              semanticLabel: strings.openingApp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(24)),
                    Text(
                      strings.appTitle,
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: responsive.spacing(8)),
                    Text(
                      strings.intro,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: responsive.spacing(24)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
