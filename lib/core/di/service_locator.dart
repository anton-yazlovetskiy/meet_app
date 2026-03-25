import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/index.dart';
import '../../data/index.dart';

final getIt = GetIt.instance;

/// Инициализация Dependency Injection
Future<void> setupDependencyInjection() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Logger
  getIt.registerSingleton<Logger>(Logger(printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8, lineLength: 120, colors: true, printEmojis: true, printTime: true)));

  /// Datasources - Mock implementations for development
  getIt.registerSingleton<LocalMockDataSource>(LocalMockDataSource());

  /// Auth Datasources
  getIt.registerSingleton<FirebaseAuthDataSource>(MockFirebaseAuthDataSourceImpl());
  getIt.registerSingleton<LocalAuthDataSource>(MockLocalAuthDataSourceImpl());

  /// Event Datasources
  getIt.registerSingleton<EventRemoteDataSource>(MockEventRemoteDataSourceImpl());
  getIt.registerSingleton<EventLocalDataSource>(MockEventLocalDataSourceImpl());

  /// Application Datasources
  getIt.registerSingleton<ApplicationRemoteDataSource>(MockApplicationRemoteDataSourceImpl());

  /// Chat Datasources
  getIt.registerSingleton<ChatRemoteDataSource>(MockChatRemoteDataSourceImpl());
  getIt.registerSingleton<ChatLocalDataSource>(MockChatLocalDataSourceImpl());

  /// Expense Datasources
  getIt.registerSingleton<ExpenseRemoteDataSource>(MockExpenseRemoteDataSourceImpl());

  /// Notification Datasources
  getIt.registerSingleton<NotificationRemoteDataSource>(MockNotificationRemoteDataSourceImpl());
  getIt.registerSingleton<NotificationLocalDataSource>(MockNotificationLocalDataSourceImpl());

  /// User Datasources
  getIt.registerSingleton<UserRemoteDataSource>(MockUserRemoteDataSourceImpl());

  /// Repositories
  getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl(firebaseAuthDataSource: getIt<FirebaseAuthDataSource>(), localAuthDataSource: getIt<LocalAuthDataSource>()));

  getIt.registerSingleton<EventRepository>(EventRepositoryImpl(remoteDataSource: getIt<EventRemoteDataSource>(), localDataSource: getIt<EventLocalDataSource>()));

  getIt.registerSingleton<ApplicationRepository>(ApplicationRepositoryImpl(remoteDataSource: getIt<ApplicationRemoteDataSource>()));

  getIt.registerSingleton<ChatRepository>(ChatRepositoryImpl(remoteDataSource: getIt<ChatRemoteDataSource>(), localDataSource: getIt<ChatLocalDataSource>()));

  getIt.registerSingleton<ExpenseRepository>(ExpenseRepositoryImpl(remoteDataSource: getIt<ExpenseRemoteDataSource>()));

  getIt.registerSingleton<NotificationRepository>(NotificationRepositoryImpl(remoteDataSource: getIt<NotificationRemoteDataSource>(), localDataSource: getIt<NotificationLocalDataSource>()));

  getIt.registerSingleton<UserRepository>(UserRepositoryImpl(remoteDataSource: getIt<UserRemoteDataSource>()));

  /// Usecases - Auth
  getIt.registerSingleton<SignInWithGoogleUseCase>(SignInWithGoogleUseCase(getIt<AuthRepository>()));

  getIt.registerSingleton<SignInWithAppleUseCase>(SignInWithAppleUseCase(getIt<AuthRepository>()));

  getIt.registerSingleton<SignInWithTwitterUseCase>(SignInWithTwitterUseCase(getIt<AuthRepository>()));

  getIt.registerSingleton<SignOutUseCase>(SignOutUseCase(getIt<AuthRepository>()));

  getIt.registerSingleton<AcceptLicenseUseCase>(AcceptLicenseUseCase(getIt<AuthRepository>()));

  /// Usecases - Event
  getIt.registerSingleton<CreateEventUseCase>(CreateEventUseCase(eventRepository: getIt<EventRepository>(), userRepository: getIt<UserRepository>()));

  getIt.registerSingleton<SelectFinalSlotUseCase>(SelectFinalSlotUseCase(getIt<EventRepository>()));

  /// Usecases - Application
  getIt.registerSingleton<CreateApplicationUseCase>(CreateApplicationUseCase(applicationRepository: getIt<ApplicationRepository>(), eventRepository: getIt<EventRepository>()));

  getIt.registerSingleton<UpdateApplicationUseCase>(UpdateApplicationUseCase(applicationRepository: getIt<ApplicationRepository>(), eventRepository: getIt<EventRepository>()));

  getIt.registerSingleton<CancelApplicationUseCase>(CancelApplicationUseCase(getIt<ApplicationRepository>()));

  /// Usecases - Notification
  getIt.registerSingleton<CreateNotificationUseCase>(CreateNotificationUseCase(getIt<NotificationRepository>()));

  getIt.registerSingleton<MarkNotificationAsReadUseCase>(MarkNotificationAsReadUseCase(getIt<NotificationRepository>()));

  getIt.registerSingleton<GetUserNotificationsUseCase>(GetUserNotificationsUseCase(getIt<NotificationRepository>()));

  await _seedMockData();
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
  final applicationsMap = applications.fold<Map<String, dynamic>>({}, (map, application) {
    map[application.id] = application.toJson();
    return map;
  });
  prefs.setString('mock_applications', jsonEncode(applicationsMap));

  final chatMessages = await localMockDataSource.loadChatMessages();
  final chatMessagesByChat = <String, List<Map<String, dynamic>>>{};
  for (final message in chatMessages) {
    chatMessagesByChat.putIfAbsent(message.chatId, () => []).add(message.toJson());
  }
  prefs.setString('mock_chat_messages', jsonEncode(chatMessagesByChat));

  prefs.setBool('mock_data_seeded', true);
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
