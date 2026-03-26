import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../core/di/service_locator.dart';
import '../../core/router/app_router.dart';
import '../../domain/usecases/auth/sign_in_usecases.dart';
import '../../domain/repositories/auth_repository.dart';

class LicensePage extends StatefulWidget {
  const LicensePage({super.key});

  @override
  State<LicensePage> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  final _authRepository = GetIt.instance<AuthRepository>();
  final _acceptLicenseUseCase = GetIt.instance<AcceptLicenseUseCase>();
  final _router = getIt<AppRouter>();

  bool _isLoading = false;
  String? _error;

  Future<void> _accept() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('Пользователь не найден');
      await _acceptLicenseUseCase(AcceptLicenseParams(userId: user.id));
      _router.replace(EventListRoute());
    } catch (e) {
      setState(() => _error = 'Ошибка сохранения соглашения: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logOut() async {
    await _authRepository.signOut();
    _router.replace(LoginRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лицензионное соглашение')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Условия использования',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '1. Это приложение предназначено для планирования и голосования за мероприятия.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. Пользователь подтверждает, что ознакомлен и согласен с правилами.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '3. Запрещено публиковать противозаконный контент и нарушать права других пользователей.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '4. Разработчик не несет ответственности за личные встречи, безопасность и финансы.',
                      ),
                      SizedBox(height: 8),
                      Text(
                        '5. Пользователь вправе отозвать своё согласие удалив аккаунт.',
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: _isLoading ? null : _accept,
                child: const Text('Принять и продолжить'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _isLoading ? null : _logOut,
                child: const Text('Выйти'),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
