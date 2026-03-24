import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/di/service_locator.dart';
import 'presentation/auth/auth_gate.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/auth/license_page.dart' as auth_license;
import 'presentation/event_list/event_list_page.dart';
import 'presentation/event_list/event_create_page.dart';
import 'presentation/settings/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const MeetApp());
}

class MeetApp extends StatefulWidget {
  const MeetApp({super.key});

  @override
  State<MeetApp> createState() => _MeetAppState();
}

class _MeetAppState extends State<MeetApp> {
  final ValueNotifier<Locale> _localeNotifier = ValueNotifier(const Locale('ru'));
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light);
    final darkScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark);

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: _localeNotifier,
          builder: (context, locale, child) {
            return MaterialApp(
              title: 'MeetApp',
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
              theme: ThemeData.from(colorScheme: lightScheme, useMaterial3: true),
              darkTheme: ThemeData.from(colorScheme: darkScheme, useMaterial3: true),
              themeMode: themeMode,
              initialRoute: '/',
              routes: {
                '/': (context) => const AuthGate(),
                '/login': (context) => LoginPage(
                  currentLocale: locale,
                  onLocaleChanged: (value) => _localeNotifier.value = value,
                ),
                '/license': (context) => const auth_license.LicensePage(),
                '/feed': (context) => EventListPage(onOpenSettings: () => Navigator.of(context).pushNamed('/settings')),
                '/create': (context) => const EventCreatePage(),
                '/settings': (context) => SettingsPage(
                  currentLocale: locale,
                  currentThemeMode: themeMode,
                  onLocaleChanged: (value) => _localeNotifier.value = value,
                  onThemeModeChanged: (value) => _themeModeNotifier.value = value,
                ),
              },
            );
          },
        );
      },
    );
  }
}
