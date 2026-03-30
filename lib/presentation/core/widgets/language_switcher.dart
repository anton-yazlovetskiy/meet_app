import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  final Locale value;
  final ValueChanged<Locale> onChanged;

  const LanguageSwitcher({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<Locale>(
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem(value: const Locale('ru'), child: Text(l10n.russian)),
        PopupMenuItem(value: const Locale('en'), child: Text(l10n.english)),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            value.languageCode.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
