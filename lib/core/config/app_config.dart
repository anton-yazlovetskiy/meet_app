enum AppEnvironment { mock, firebase }

class AppConfig {
  final AppEnvironment environment;

  const AppConfig({required this.environment});

  bool get useMocks => environment == AppEnvironment.mock;

  factory AppConfig.fromEnvironment() {
    const rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'mock');
    return AppConfig(
      environment: rawEnv.toLowerCase() == 'firebase'
          ? AppEnvironment.firebase
          : AppEnvironment.mock,
    );
  }
}
