import 'package:flutter/material.dart';

import '../responsive.dart';

class AppStateMessage extends StatelessWidget {
  const AppStateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.detail,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: responsive.icon(48),
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: responsive.spacing(12)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (detail != null) ...[
              SizedBox(height: responsive.spacing(4)),
              Text(detail!, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              SizedBox(height: responsive.spacing(16)),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
