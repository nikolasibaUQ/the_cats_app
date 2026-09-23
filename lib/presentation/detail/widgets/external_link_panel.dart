import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';

/// Panel that opens an article about the breed outside the application.
///
/// The URL is validated in the data layer, so this widget only reports the
/// outcome: a link the platform refuses leaves the screen unchanged and tells
/// the user instead of failing silently.
class ExternalLinkPanel extends StatelessWidget {
  const ExternalLinkPanel({super.key, required this.title, required this.url});

  final String title;
  final String url;

  Future<void> _open(BuildContext context) async {
    final strings = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(strings.linkOpenError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(responsive.radius(16));
    return Material(
      color: colors.surfaceContainer,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => _open(context),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(14),
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.open_in_new_rounded,
                size: responsive.icon(18),
                color: colors.primary,
              ),
              SizedBox(width: responsive.spacing(12)),
              Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
              SizedBox(width: responsive.spacing(8)),
              Text(
                strings.openLink,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                Icons.north_east_rounded,
                size: responsive.icon(16),
                color: colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
