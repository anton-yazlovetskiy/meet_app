import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/usecases/auth/sign_in_usecases.dart';
import '../../domain/usecases/usecase.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginPage extends StatefulWidget {
  final Locale currentLocale;
  final void Function(Locale locale) onLocaleChanged;

  const LoginPage({super.key, required this.currentLocale, required this.onLocaleChanged});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _signInWithGoogle = GetIt.instance<SignInWithGoogleUseCase>();
  final _signInWithApple = GetIt.instance<SignInWithAppleUseCase>();
  final _signInWithTwitter = GetIt.instance<SignInWithTwitterUseCase>();
  final _authRepository = GetIt.instance<AuthRepository>();

  bool _isLoading = false;
  String? _error;

  Future<void> _onLogin(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('Ошибка загрузки пользователя');
      if (!user.acceptedLicense && !(await _authRepository.hasAcceptedLicense(user.id))) {
        Navigator.of(context).pushReplacementNamed('/license');
      } else {
        Navigator.of(context).pushReplacementNamed('/feed');
      }
    } catch (e) {
      setState(() => _error = 'Не удалось войти: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Войти в MeetApp')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text('Войти через', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AuthIconButton(icon: Icons.g_mobiledata, label: 'Google', onTap: _isLoading ? null : () => _onLogin(() => _signInWithGoogle(NoParams()))),
                    _AuthIconButton(icon: Icons.apple, label: 'Apple', onTap: _isLoading ? null : () => _onLogin(() => _signInWithApple(NoParams()))),
                    _AuthIconButton(icon: Icons.alternate_email, label: 'Twitter', onTap: _isLoading ? null : () => _onLogin(() => _signInWithTwitter(NoParams()))),
                  ],
                ),
                const SizedBox(height: 16),
                if (_error != null) ...[Text(_error!, style: const TextStyle(color: Colors.red)), const SizedBox(height: 12)],
                Card(
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Правила сервиса', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('• Запрет спама и мошенничества'),
                        Text('• Запрет оскорблений и дискриминации'),
                        Text('• Запрет противоправных действий'),
                        Text('• Отказ от ответственности за действия пользователей'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Язык: '),
                    TextButton(
                      onPressed: () => widget.onLocaleChanged(const Locale('ru')),
                      child: Text('Русский', style: TextStyle(color: widget.currentLocale.languageCode == 'ru' ? Colors.blue : null)),
                    ),
                    TextButton(
                      onPressed: () => widget.onLocaleChanged(const Locale('en')),
                      child: Text('English', style: TextStyle(color: widget.currentLocale.languageCode == 'en' ? Colors.blue : null)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                OutlinedButton(onPressed: () => _showLicenseDialog(context), child: const Text('Лицензионное соглашение')),
                const SizedBox(height: 4),
                const Text('Регистрируясь, вы подтверждаете, что ознакомились и согласны со всеми пунктами лицензионного соглашения.'),
                const SizedBox(height: 16),
                const Text('Тарифы', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _TariffCard(title: 'Физ. лица', description: 'Базовый доступ', price: '0 ₽'),
                    _TariffCard(title: 'Юр. лица L1', description: 'Расширенные инструменты', price: '1490 ₽'),
                    _TariffCard(title: 'Юр. лица L2', description: 'Приоритетная поддержка', price: '2990 ₽'),
                    _TariffCard(title: 'Юр. лица L3', description: 'Автоматическая модерация', price: '4990 ₽'),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
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
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Закрыть'))],
      ),
    );
  }
}

class _AuthIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _AuthIconButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon, size: 36)),
        Text(label),
      ],
    );
  }
}

class _TariffCard extends StatelessWidget {
  final String title;
  final String description;
  final String price;

  const _TariffCard({required this.title, required this.description, required this.price});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2 - 28,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
