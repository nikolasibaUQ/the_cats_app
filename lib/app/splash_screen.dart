import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import '../shared/responsive.dart';
import 'app_routes.dart';

/// Brief entry screen that hands over to the breed list.
///
/// The splash belongs to the app shell: it uses no breed state and replaces
/// itself with `/breeds` so normal navigation does not leave an extra
/// browser-history stop behind.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(const Duration(milliseconds: 1800), _openBreeds);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  Future<void> _openBreeds() async {
    if (!mounted || _navigated) return;
    _navigated = true;
    _navigationTimer?.cancel();
    if (context.mounted) {
      context.pushReplacement(AppRoutes.breeds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(responsive.pagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pets_rounded,
                  semanticLabel: strings.openingApp,
                  size: responsive.icon(72),
                  color: colors.primary,
                ),
                SizedBox(height: responsive.spacing(24)),
                Text(
                  strings.appTitle,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
            ),
          ),
        ),
      ),
    );
  }
}
