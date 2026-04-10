// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AuthGatePage]
class AuthGateRoute extends PageRouteInfo<void> {
  const AuthGateRoute({List<PageRouteInfo>? children})
    : super(AuthGateRoute.name, initialChildren: children);

  static const String name = 'AuthGateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AuthGatePage();
    },
  );
}

/// generated route for
/// [EventListPage]
class EventListRoute extends PageRouteInfo<void> {
  const EventListRoute({List<PageRouteInfo>? children})
    : super(EventListRoute.name, initialChildren: children);

  static const String name = 'EventListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const EventListPage();
    },
  );
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    Key? key,
    Locale? currentLocale,
    void Function(Locale)? onLocaleChanged,
    List<PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(
           key: key,
           currentLocale: currentLocale,
           onLocaleChanged: onLocaleChanged,
         ),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return LoginPage(
        key: args.key,
        currentLocale: args.currentLocale,
        onLocaleChanged: args.onLocaleChanged,
      );
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.currentLocale, this.onLocaleChanged});

  final Key? key;

  final Locale? currentLocale;

  final void Function(Locale)? onLocaleChanged;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, currentLocale: $currentLocale, onLocaleChanged: $onLocaleChanged}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key && currentLocale == other.currentLocale;
  }

  @override
  int get hashCode => key.hashCode ^ currentLocale.hashCode;
}
