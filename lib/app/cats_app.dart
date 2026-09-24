import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_locale_controller.dart';
import 'app_router.dart';
import 'app_theme.dart';

class CatsApp extends ConsumerWidget {
  const CatsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
      title: 'Cats App',
      locale: ref.watch(appLocaleControllerProvider).locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: AppTheme.light,
    );
  }
}
