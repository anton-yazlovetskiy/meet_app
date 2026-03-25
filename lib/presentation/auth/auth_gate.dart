import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/index.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authRepository = GetIt.instance<AuthRepository>();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  Future<void> _checkAuthentication() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        Navigator.of(context).pushReplacementNamed('/login');
        return;
      }

      Navigator.of(context).pushReplacementNamed('/feed');
    } catch (e) {
      setState(() {
        _error = 'Ошибка аутентификации: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error ?? 'Неизвестная ошибка')));
    }

    return const SizedBox.shrink();
  }
}
