import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class AppHeader extends StatefulWidget {
  final Locale currentLocale;
  final void Function(Locale locale) onLocaleChanged;

  const AppHeader({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          Tooltip(
            message: l10n.appTitle,
            showDuration: const Duration(seconds: 3),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Text(
                'К.О.Т.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              PopupMenuButton<String>(
                child: Text(
                  widget.currentLocale.languageCode.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onSelected: (value) {
                  widget.onLocaleChanged(Locale(value));
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'ru', child: Text(l10n.russian)),
                  PopupMenuItem(value: 'en', child: Text(l10n.english)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
