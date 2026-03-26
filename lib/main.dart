import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection(appConfig: AppConfig.fromEnvironment());
  runApp(const MeetApp());
}

class MeetApp extends StatefulWidget {
  const MeetApp({super.key});

  @override
  State<MeetApp> createState() => _MeetAppState();
}

class _MeetAppState extends State<MeetApp> {
  final ValueNotifier<Locale> _localeNotifier = ValueNotifier(
    Locale(PlatformDispatcher.instance.locale.countryCode.toString()),
  );
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    );

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, themeMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: _localeNotifier,
          builder: (context, locale, child) {
            final appRouter = getIt<AppRouter>();
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'King of Time',
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData.from(
                colorScheme: lightScheme,
                useMaterial3: true,
              ),
              darkTheme: ThemeData.from(
                colorScheme: darkScheme,
                useMaterial3: true,
              ),
              themeMode: themeMode,
              routerConfig: appRouter.config(),
            );
          },
        );
      },
    );
  }
}
