import 'package:flutter/material.dart';
import '../../app/app_locale_controller.dart';
import '../../l10n/generated/app_localizations.dart';

/// Language selector shared by the catalog bar and the detail photo controls.
///
/// The caller supplies the active [selected] language and receives a selection
/// through [onSelected], leaving state ownership outside the widget.
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return PopupMenuButton<AppLanguage>(
      tooltip: strings.language,
      icon: const Icon(Icons.language_rounded),
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final language in AppLanguage.values)
          PopupMenuItem(
            value: language,
            child: Text(_label(strings, language)),
          ),
      ],
    );
  }
}

String _label(AppLocalizations strings, AppLanguage language) =>
    switch (language) {
      AppLanguage.system => strings.systemLanguage,
      AppLanguage.spanish => strings.spanish,
      AppLanguage.english => strings.english,
    };
