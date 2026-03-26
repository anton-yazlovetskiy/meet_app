import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/router/app_router.dart';
import '../../domain/repositories/auth_repository.dart';

@RoutePage()
class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  final _authRepository = getIt<AuthRepository>();
  final _router = getIt<AppRouter>();

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    final user = await _authRepository.getCurrentUser();
    if (!mounted) {
      return;
    }
    if (user == null) {
      _router.replace(LoginRoute());
      return;
    }
    _router.replace(EventListRoute());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
