import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../presentation/auth/auth_gate_page.dart';
import '../../presentation/auth/login_page.dart';
import '../../presentation/event_list/event_list_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AuthGateRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: EventListRoute.page),
  ];
}

// Страницы должны быть аннотированы @RoutePage() в соответствующих файлах.
