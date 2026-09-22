import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import 'app_locale.dart';

class LanguageMenu extends ConsumerWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final selected = ref.watch(appLocaleProvider)?.languageCode ?? 'system';
    return PopupMenuButton<String>(
      tooltip: strings.language,
      icon: const Icon(Icons.language_rounded),
      initialValue: selected,
      onSelected: (value) => ref
          .read(appLocaleProvider.notifier)
          .select(value == 'system' ? null : Locale(value)),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'system', child: Text(strings.systemLanguage)),
        PopupMenuItem(value: 'es', child: Text(strings.spanish)),
        PopupMenuItem(value: 'en', child: Text(strings.english)),
      ],
    );
  }
}
