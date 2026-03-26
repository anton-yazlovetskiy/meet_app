import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/app_config.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'l10n/app_localizations.dart';

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
  static const Locale _fallbackLocale = Locale('en');

  Locale _resolveInitialLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;
    final isSupported = AppLocalizations.supportedLocales.any(
      (locale) => locale.languageCode == systemLocale.languageCode,
    );
    if (isSupported) {
      return Locale(systemLocale.languageCode);
    }
    return _fallbackLocale;
  }

  final ValueNotifier<Locale> _localeNotifier = ValueNotifier(
    const Locale('en'),
  );
  final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier(
    ThemeMode.system,
  );

  @override
  void initState() {
    super.initState();
    _localeNotifier.value = _resolveInitialLocale();
  }

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
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                if (deviceLocale == null) {
                  return _fallbackLocale;
                }
                for (final supported in supportedLocales) {
                  if (supported.languageCode == deviceLocale.languageCode) {
                    return supported;
                  }
                }
                return _fallbackLocale;
              },
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
