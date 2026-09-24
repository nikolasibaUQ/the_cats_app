import 'package:flutter/material.dart';

import '../../../app/app_locale_controller.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/language_menu.dart';

/// Contextual desktop controls shown above, rather than over, the breed photo.
class DetailNavigationBar extends StatelessWidget {
  const DetailNavigationBar({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    required this.onBack,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final responsive = Responsive.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        FilledButton.icon(
          key: const Key('detail-back'),
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(strings.backToBreeds),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.spacing(16),
              vertical: responsive.spacing(12),
            ),
          ),
        ),
        LanguageMenu(
          selected: selectedLanguage,
          onSelected: onLanguageSelected,
          showLabel: true,
        ),
      ],
    );
  }
}
