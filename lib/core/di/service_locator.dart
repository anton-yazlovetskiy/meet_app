import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/index.dart';
import '../../data/index.dart';

final getIt = GetIt.instance;

/// Инициализация Dependency Injection
Future<void> setupDependencyInjection() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  /// Datasources - Mock implementations for development
  getIt.registerSingleton<LocalMockDataSource>(LocalMockDataSource());

  /// Auth Datasources
  getIt.registerSingleton<FirebaseAuthDataSource>(
    MockFirebaseAuthDataSourceImpl(),
  );
  getIt.registerSingleton<LocalAuthDataSource>(
    MockLocalAuthDataSourceImpl(),
  );

  /// Event Datasources
  getIt.registerSingleton<EventRemoteDataSource>(
    MockEventRemoteDataSourceImpl(),
  );
  getIt.registerSingleton<EventLocalDataSource>(
    MockEventLocalDataSourceImpl(),
  );

  /// Application Datasources
  getIt.registerSingleton<ApplicationRemoteDataSource>(
    MockApplicationRemoteDataSourceImpl(),
  );

  /// Chat Datasources
  getIt.registerSingleton<ChatRemoteDataSource>(
    MockChatRemoteDataSourceImpl(),
  );
  getIt.registerSingleton<ChatLocalDataSource>(
    MockChatLocalDataSourceImpl(),
  );

  /// Expense Datasources
  getIt.registerSingleton<ExpenseRemoteDataSource>(
    MockExpenseRemoteDataSourceImpl(),
  );

  /// Notification Datasources
  getIt.registerSingleton<NotificationRemoteDataSource>(
    MockNotificationRemoteDataSourceImpl(),
  );
  getIt.registerSingleton<NotificationLocalDataSource>(
    MockNotificationLocalDataSourceImpl(),
  );

  /// User Datasources
  getIt.registerSingleton<UserRemoteDataSource>(
    MockUserRemoteDataSourceImpl(),
  );

  /// Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      firebaseAuthDataSource: getIt<FirebaseAuthDataSource>(),
      localAuthDataSource: getIt<LocalAuthDataSource>(),
    ),
  );

  getIt.registerSingleton<EventRepository>(
    EventRepositoryImpl(
      remoteDataSource: getIt<EventRemoteDataSource>(),
      localDataSource: getIt<EventLocalDataSource>(),
    ),
  );

  getIt.registerSingleton<ApplicationRepository>(
    ApplicationRepositoryImpl(
      remoteDataSource: getIt<ApplicationRemoteDataSource>(),
    ),
  );

  getIt.registerSingleton<ChatRepository>(
    ChatRepositoryImpl(
      remoteDataSource: getIt<ChatRemoteDataSource>(),
      localDataSource: getIt<ChatLocalDataSource>(),
    ),
  );

  getIt.registerSingleton<ExpenseRepository>(
    ExpenseRepositoryImpl(
      remoteDataSource: getIt<ExpenseRemoteDataSource>(),
    ),
  );

  getIt.registerSingleton<NotificationRepository>(
    NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
      localDataSource: getIt<NotificationLocalDataSource>(),
    ),
  );

  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(
      remoteDataSource: getIt<UserRemoteDataSource>(),
    ),
  );

  /// Usecases - Auth
  getIt.registerSingleton<SignInWithGoogleUseCase>(
    SignInWithGoogleUseCase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<SignInWithAppleUseCase>(
    SignInWithAppleUseCase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<SignInWithTwitterUseCase>(
    SignInWithTwitterUseCase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<SignOutUseCase>(
    SignOutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerSingleton<AcceptLicenseUseCase>(
    AcceptLicenseUseCase(getIt<AuthRepository>()),
  );

  /// Usecases - Event
  getIt.registerSingleton<CreateEventUseCase>(
    CreateEventUseCase(
      eventRepository: getIt<EventRepository>(),
      userRepository: getIt<UserRepository>(),
    ),
  );

  getIt.registerSingleton<SelectFinalSlotUseCase>(
    SelectFinalSlotUseCase(getIt<EventRepository>()),
  );

  /// Usecases - Application
  getIt.registerSingleton<CreateApplicationUseCase>(
    CreateApplicationUseCase(
      applicationRepository: getIt<ApplicationRepository>(),
      eventRepository: getIt<EventRepository>(),
    ),
  );

  getIt.registerSingleton<UpdateApplicationUseCase>(
    UpdateApplicationUseCase(
      applicationRepository: getIt<ApplicationRepository>(),
      eventRepository: getIt<EventRepository>(),
    ),
  );

  getIt.registerSingleton<CancelApplicationUseCase>(
    CancelApplicationUseCase(getIt<ApplicationRepository>()),
  );

  /// Usecases - Notification
  getIt.registerSingleton<CreateNotificationUseCase>(
    CreateNotificationUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerSingleton<MarkNotificationAsReadUseCase>(
    MarkNotificationAsReadUseCase(getIt<NotificationRepository>()),
  );

  getIt.registerSingleton<GetUserNotificationsUseCase>(
    GetUserNotificationsUseCase(getIt<NotificationRepository>()),
  );
}

/// Mock Local Auth Datasource для разработки
class MockLocalAuthDataSourceImpl implements LocalAuthDataSource {
  UserModel? _currentUser;

  @override
  Future<UserModel?> getCurrentUser() async => _currentUser;

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    _currentUser = user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}
