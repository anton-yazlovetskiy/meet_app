import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/index.dart';
import '../../domain/index.dart';
import '../config/app_config.dart';
import '../router/app_router.dart';

final getIt = GetIt.instance;

/// Инициализация Dependency Injection
Future<void> setupDependencyInjection({AppConfig? appConfig}) async {
  final resolvedConfig = appConfig ?? AppConfig.fromEnvironment();
  getIt.registerSingleton<AppConfig>(resolvedConfig);

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // AppRouter
  getIt.registerSingleton<AppRouter>(AppRouter());

  // Logger
  getIt.registerSingleton<Logger>(
    Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    ),
  );

  /// Datasources - Mock implementations for development
  getIt.registerSingleton<LocalMockDataSource>(LocalMockDataSource());

  /// Auth Datasources
  getIt.registerSingleton<FirebaseAuthDataSource>(
    MockFirebaseAuthDataSourceImpl(),
  );
  getIt.registerSingleton<LocalAuthDataSource>(
    MockLocalAuthDataSourceImpl(prefs),
  );

  /// Event Datasources
  getIt.registerSingleton<EventRemoteDataSource>(
    MockEventRemoteDataSourceImpl(),
  );
  getIt.registerSingleton<EventLocalDataSource>(MockEventLocalDataSourceImpl());

  /// Application Datasources
  getIt.registerSingleton<ApplicationRemoteDataSource>(
    MockApplicationRemoteDataSourceImpl(),
  );

  /// Chat Datasources
  getIt.registerSingleton<ChatRemoteDataSource>(MockChatRemoteDataSourceImpl());
  getIt.registerSingleton<ChatLocalDataSource>(MockChatLocalDataSourceImpl());

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
  getIt.registerSingleton<UserRemoteDataSource>(MockUserRemoteDataSourceImpl());

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
    ExpenseRepositoryImpl(remoteDataSource: getIt<ExpenseRemoteDataSource>()),
  );

  getIt.registerSingleton<NotificationRepository>(
    NotificationRepositoryImpl(
      remoteDataSource: getIt<NotificationRemoteDataSource>(),
      localDataSource: getIt<NotificationLocalDataSource>(),
    ),
  );

  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(remoteDataSource: getIt<UserRemoteDataSource>()),
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
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerSingleton<SelectFinalSlotUseCase>(
    SelectFinalSlotUseCase(
      eventRepository: getIt<EventRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerSingleton<GetEventByIdUseCase>(
    GetEventByIdUseCase(
      eventRepository: getIt<EventRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerSingleton<ListEventsUseCase>(
    ListEventsUseCase(
      eventRepository: getIt<EventRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerSingleton<GetEventSlotsUseCase>(
    GetEventSlotsUseCase(eventRepository: getIt<EventRepository>()),
  );

  getIt.registerSingleton<FilterAndSortEventFeedUseCase>(
    FilterAndSortEventFeedUseCase(),
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

  if (resolvedConfig.useMocks) {
    try {
      await _seedMockData();
    } catch (e, stackTrace) {
      getIt<Logger>().e(
        'Mock data seed failed. App continues without seeded mocks.',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}

Future<void> _seedMockData() async {
  final prefs = getIt<SharedPreferences>();
  final isSeeded = prefs.getBool('mock_data_seeded') ?? false;
  if (isSeeded) return;

  final localMockDataSource = getIt<LocalMockDataSource>();

  final users = await localMockDataSource.loadUsers();
  final userMap = users.fold<Map<String, dynamic>>({}, (map, user) {
    map[user.id] = user.toJson();
    return map;
  });
  prefs.setString('mock_users', jsonEncode(userMap));

  final events = await localMockDataSource.loadEvents();
  final eventMap = events.fold<Map<String, dynamic>>({}, (map, event) {
    map[event.id] = event.toJson();
    return map;
  });
  prefs.setString('mock_events', jsonEncode(eventMap));

  final slots = await localMockDataSource.loadSlots();
  final slotsByEvent = <String, List<Map<String, dynamic>>>{};
  for (final slot in slots) {
    slotsByEvent.putIfAbsent(slot.eventId, () => []).add(slot.toJson());
  }
  prefs.setString('mock_slots', jsonEncode(slotsByEvent));

  final applications = await localMockDataSource.loadApplications();
  final applicationsMap = applications.fold<Map<String, dynamic>>({}, (
    map,
    application,
  ) {
    map[application.id] = application.toJson();
    return map;
  });
  prefs.setString('mock_applications', jsonEncode(applicationsMap));

  final chatMessages = await localMockDataSource.loadChatMessages();
  final chatMessagesByChat = <String, List<Map<String, dynamic>>>{};
  for (final message in chatMessages) {
    chatMessagesByChat
        .putIfAbsent(message.chatId, () => [])
        .add(message.toJson());
  }
  prefs.setString('mock_chat_messages', jsonEncode(chatMessagesByChat));

  prefs.setBool('mock_data_seeded', true);
}

/// Mock Local Auth Datasource для разработки
class MockLocalAuthDataSourceImpl implements LocalAuthDataSource {
  static const String _currentUserKey = 'auth_current_user';
  final SharedPreferences _prefs;

  MockLocalAuthDataSourceImpl(this._prefs);

  UserModel? _currentUser;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }
    final rawUser = _prefs.getString(_currentUserKey);
    if (rawUser == null) {
      return null;
    }
    try {
      final Map<String, dynamic> decoded = jsonDecode(rawUser);
      _currentUser = UserModel.fromJson(decoded);
      return _currentUser;
    } catch (_) {
      await _prefs.remove(_currentUserKey);
      _currentUser = null;
      return null;
    }
  }

  @override
  Future<void> saveCurrentUser(UserModel user) async {
    _currentUser = user;
    await _prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    await _prefs.remove(_currentUserKey);
  }
}
