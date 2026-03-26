import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'dart:ui';
import '../../../core/di/service_locator.dart';
import '../../../core/router/app_router.dart';
import '../../domain/usecases/auth/sign_in_usecases.dart';
import '../core/widgets/app_header.dart';
import '../core/widgets/auth_button_group.dart';
import '../core/widgets/tariff_card.dart';
import 'package:meet_app/l10n/app_localizations.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  final Locale? currentLocale;
  final void Function(Locale locale)? onLocaleChanged;

  const LoginPage({super.key, this.currentLocale, this.onLocaleChanged});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _signInWithGoogle = GetIt.instance<SignInWithGoogleUseCase>();
  final _signInWithApple = GetIt.instance<SignInWithAppleUseCase>();
  final _signInWithTwitter = GetIt.instance<SignInWithTwitterUseCase>();

  bool _isLoading = false;
  String? _error;
  final router = getIt<AppRouter>();

  Future<void> _onLogin(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
      if (!mounted) return;
      router.replace(const EventListRoute());
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Не удалось войти: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolvedLocale =
        widget.currentLocale ??
        Locale(PlatformDispatcher.instance.locale.languageCode);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.black, Colors.indigo, Colors.black],
            stops: [0.1, 0.9, 1.0],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.lightBlueAccent,
              Colors.lightBlue,
              Colors.lightBlueAccent,
            ],
            stops: [0.0, 0.5, 1.0],
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppHeader(
                  currentLocale: resolvedLocale,
                  onLocaleChanged: widget.onLocaleChanged ?? (_) {},
                ),
                const SizedBox(height: 20),
                AuthButtonGroup(
                  isLoading: _isLoading,
                  onGoogle: () =>
                      _onLogin(() => _signInWithGoogle(resolvedLocale)),
                  onApple: () =>
                      _onLogin(() => _signInWithApple(resolvedLocale)),
                  onTwitter: () =>
                      _onLogin(() => _signInWithTwitter(resolvedLocale)),
                  label: l10n.loginWith,
                ),
                const SizedBox(height: 20),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.rulesTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.rules1, style: const TextStyle(fontSize: 12)),
                      Text(l10n.rules2, style: const TextStyle(fontSize: 12)),
                      Text(l10n.rules3, style: const TextStyle(fontSize: 12)),
                      Text(l10n.rules4, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: (MediaQuery.of(context).size.width / 3).clamp(
                        150.0,
                        double.infinity,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _showLicenseDialog(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(l10n.licenseButton),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.licenseText,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.tariffsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 120,
                          child: TariffCard(
                            title: 'Физ. лица',
                            description: 'Базовый доступ',
                            price: '0 ₽',
                            features: [
                              'Просмотр мероприятий',
                              'Участие в голосованиях',
                            ],
                            isPhysical: true,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 120,
                          child: TariffCard(
                            title: 'Юр.Лица L1',
                            description: 'Расширенные инструменты',
                            price: '1490 ₽',
                            features: [
                              'Создание мероприятий',
                              'Управление участн.',
                              'Статистика',
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 120,
                          child: TariffCard(
                            title: 'Юр.Лица L2',
                            description: 'Приоритетная поддержка',
                            price: '2990 ₽',
                            features: [
                              'Всё из L1',
                              'Приоритетн. поддержка',
                              'API доступ',
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 120,
                          child: TariffCard(
                            title: 'Юр.Лица L3',
                            description: 'Максимальные возможности',
                            price: '4990 ₽',
                            features: [
                              'Всё из L2',
                              'Автомодерация',
                              'Кастомизация',
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLicenseDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Лицензионное соглашение'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('1. Приложение для планирования и голосования.'),
              SizedBox(height: 8),
              Text('2. Запрещены противоправные материалы.'),
              SizedBox(height: 8),
              Text('3. Сервис не несет ответственности за встречи.'),
              SizedBox(height: 8),
              Text('4. Вы подтверждаете свое согласие с этими правилами.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
