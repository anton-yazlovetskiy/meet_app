import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final void Function(Locale locale) onLocaleChanged;
  final void Function(ThemeMode themeMode) onThemeModeChanged;

  const SettingsPage({
    super.key,
    required this.currentLocale,
    required this.currentThemeMode,
    required this.onLocaleChanged,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPageTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.interfaceLanguage),
            subtitle: Text(
              currentLocale.languageCode == 'ru' ? l10n.russian : l10n.english,
            ),
            trailing: DropdownButton<Locale>(
              value: currentLocale,
              onChanged: (Locale? value) {
                if (value != null) onLocaleChanged(value);
              },
              items: [
                DropdownMenuItem(
                  value: const Locale('ru'),
                  child: Text(l10n.russian),
                ),
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(l10n.english),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.theme),
            subtitle: Text(
              currentThemeMode == ThemeMode.dark
                  ? l10n.darkTheme
                  : currentThemeMode == ThemeMode.light
                  ? l10n.lightTheme
                  : l10n.systemTheme,
            ),
            trailing: DropdownButton<ThemeMode>(
              value: currentThemeMode,
              onChanged: (ThemeMode? value) {
                if (value != null) onThemeModeChanged(value);
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.systemTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.lightTheme),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.darkTheme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
