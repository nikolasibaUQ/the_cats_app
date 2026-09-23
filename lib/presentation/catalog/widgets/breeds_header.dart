import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';

class BreedsHeader extends StatelessWidget {
  const BreedsHeader({
    super.key,
    required this.onQueryChanged,
    required this.showMinimumHint,
  });

  final ValueChanged<String> onQueryChanged;
  final bool showMinimumHint;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.meetBreeds,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: responsive.spacing(8)),
        Text(
          strings.intro,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
        ),
        SizedBox(height: responsive.spacing(24)),
        TextField(
          decoration: InputDecoration(
            hintText: strings.searchHint,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
          onChanged: onQueryChanged,
        ),
        if (showMinimumHint) ...[
          SizedBox(height: responsive.spacing(8)),
          Text(
            strings.searchMinimum,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
