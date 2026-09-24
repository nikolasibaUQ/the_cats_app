import 'package:flutter/material.dart';
import '../../app/app_locale_controller.dart';
import '../../l10n/generated/app_localizations.dart';

/// Language selector shared by catalog and detail navigation controls.
///
/// The caller supplies the active [selected] language and receives a selection
/// through [onSelected], leaving state ownership outside the widget.
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({
    super.key,
    required this.selected,
    required this.onSelected,
    this.showLabel = false,
  });

  final AppLanguage selected;
  final ValueChanged<AppLanguage> onSelected;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return PopupMenuButton<AppLanguage>(
      tooltip: strings.language,
      icon: showLabel ? null : const Icon(Icons.language_rounded),
      initialValue: selected,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final language in AppLanguage.values)
          PopupMenuItem(
            value: language,
            child: Text(_label(strings, language)),
          ),
      ],
      child: showLabel ? _LanguageMenuTrigger(label: strings.language) : null,
    );
  }
}

class _LanguageMenuTrigger extends StatelessWidget {
  const _LanguageMenuTrigger({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainer,
      shape: StadiumBorder(side: BorderSide(color: colors.outlineVariant)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language_rounded, color: colors.primary),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

String _label(AppLocalizations strings, AppLanguage language) =>
    switch (language) {
      AppLanguage.system => strings.systemLanguage,
      AppLanguage.spanish => strings.spanish,
      AppLanguage.english => strings.english,
    };
