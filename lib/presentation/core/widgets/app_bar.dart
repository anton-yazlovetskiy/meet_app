import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSettings;
  final VoidCallback? onRefresh;
  final bool showSettings;
  final bool showRefresh;

  const CustomAppBar({super.key, required this.title, this.onSettings, this.onRefresh, this.showSettings = true, this.showRefresh = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      title: Text(title),
      actions: [
        if (showRefresh) IconButton(icon: const Icon(Icons.refresh), tooltip: l10n.refreshButton, onPressed: onRefresh),
        if (showSettings) IconButton(icon: const Icon(Icons.settings), tooltip: l10n.settingsPageTitle, onPressed: onSettings),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
