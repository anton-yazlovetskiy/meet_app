import 'package:logger/logger.dart';

import '../../entities/index.dart';
import '../../exceptions/domain_exceptions.dart';
import '../../repositories/index.dart';
import '../usecase.dart';

/// Params для CreateEventUseCase
class CreateEventParams {
  final String title;
  final String description;
  final List<String> tags;
  final Location location;
  final bool isPublic;
  final EventType eventType;
  final int? maxParticipants;
  final double price;
  final DateTime startLimit;
  final DateRange? votingPeriod;
  final List<String> unAvailableSlots;
  final String userId;

  CreateEventParams({
    required this.title,
    required this.description,
    required this.tags,
    required this.location,
    required this.isPublic,
    required this.eventType,
    this.maxParticipants,
    required this.price,
    required this.startLimit,
    this.votingPeriod,
    required this.unAvailableSlots,
    required this.userId,
  });
}

/// Usecase для создания мероприятия
class CreateEventUseCase extends UseCase<Event, CreateEventParams> {
  final EventRepository eventRepository;
  final UserRepository userRepository;
  final Logger logger;

  CreateEventUseCase({
    required this.eventRepository,
    required this.userRepository,
    required this.logger,
  });

  @override
  Future<Event> call(CreateEventParams params) async {
    logger.i(
      'Попытка создания мероприятия пользователем ${params.userId} с названием "${params.title}"',
    );
    try {
      /// Проверить теги (не больше 3)
      if (params.tags.length > 3) {
        throw ValidationException('Максимум 3 тега на мероприятие');
      }

      /// Проверить дату создания (не больше 1 месяца вперед для free, 2-3 мес для premium)
      final user = await userRepository.getUserById(params.userId);
      final maxDaysAllowed = user.premiumStatus == PremiumStatus.free ? 30 : 90;
      final now = DateTime.now();
      if (params.startLimit.isAfter(now.add(Duration(days: maxDaysAllowed)))) {
        throw PremiumLimitExceededException(
          'Дата создания превышает лимит вашей подписки ($maxDaysAllowed дней)',
          'event_creation_date_limit',
        );
      }

      /// Проверить лимит мероприятий в месяц для free аккаунтов
      if (user.premiumStatus == PremiumStatus.free) {
        final userEvents = await eventRepository.getUserCreatedEvents(
          params.userId,
        );
        final monthAgo = now.subtract(const Duration(days: 30));
        final recentEvents = userEvents
            .where((e) => e.createdAt.isAfter(monthAgo))
            .toList();
        if (recentEvents.length >= 2) {
          throw PremiumLimitExceededException(
            'Вы создали максимум мероприятий (2) в этом месяце',
            'max_events_per_month',
          );
        }
      }

      final newEvent = await eventRepository.createEvent(
        title: params.title,
        description: params.description,
        tags: params.tags,
        location: params.location,
        isPublic: params.isPublic,
        eventType: params.eventType,
        maxParticipants: params.maxParticipants,
        price: params.price,
        startLimit: params.startLimit,
        votingPeriod: params.votingPeriod,
        unAvailableSlots: params.unAvailableSlots,
      );
      logger.i(
        'Мероприятие "${newEvent.title}" (ID: ${newEvent.id}) успешно создано',
      );
      return newEvent;
    } catch (e, s) {
      logger.e('Ошибка при создании мероприятия', error: e, stackTrace: s);
      rethrow;
    }
  }
}

/// Params для SelectFinalSlotUseCase
class SelectFinalSlotParams {
  final String eventId;
  final String slotId;
  final String managerId;

  SelectFinalSlotParams({
    required this.eventId,
    required this.slotId,
    required this.managerId,
  });
}

/// Usecase для выбора финального слота
class SelectFinalSlotUseCase extends UseCase<void, SelectFinalSlotParams> {
  final EventRepository eventRepository;
  final Logger logger;

  SelectFinalSlotUseCase({required this.eventRepository, required this.logger});

  @override
  Future<void> call(SelectFinalSlotParams params) async {
    logger.i(
      'Попытка выбора финального слота ${params.slotId} для мероприятия ${params.eventId} менеджером ${params.managerId}',
    );
    try {
      /// Получить мероприятие
      final event = await eventRepository.getEventById(params.eventId);

      /// Проверить что менеджер имеет право
      if (!event.managers.contains(params.managerId) &&
          event.creatorId != params.managerId) {
        throw AuthorizationException('Только менеджер может выбирать слоты');
      }

      /// Проверить что мероприятие типа voting
      if (event.eventType != EventType.voting) {
        throw BusinessLogicException(
          'Финальный слот можно выбрать только для мероприятий с голосованием',
        );
      }

      /// Проверить что выбор слота находится в допустимых рамках
      if (event.votingPeriod != null) {
        final lastSelectionDate = event.votingPeriod!.start.subtract(
          const Duration(days: 1),
        );
        final now = DateTime.now();
        if (now.isAfter(lastSelectionDate)) {
          throw BusinessLogicException(
            'Срок выбора слота истек',
            code: 'slot_selection_deadline_passed',
          );
        }
      }

      await eventRepository.selectFinalSlot(
        eventId: params.eventId,
        slotId: params.slotId,
      );
      logger.i(
        'Слот ${params.slotId} успешно выбран для мероприятия ${params.eventId}',
      );
    } catch (e, s) {
      logger.e('Ошибка при выборе финального слота', error: e, stackTrace: s);
      rethrow;
    }
  }
}

/// Params для GetEventByIdUseCase
class GetEventByIdParams {
  final String eventId;

  GetEventByIdParams(this.eventId);
}

/// Usecase для получения мероприятия по ID
class GetEventByIdUseCase extends UseCase<Event, GetEventByIdParams> {
  final EventRepository eventRepository;
  final Logger logger;

  GetEventByIdUseCase({required this.eventRepository, required this.logger});

  @override
  Future<Event> call(GetEventByIdParams params) async {
    logger.i('Запрос мероприятия по ID: ${params.eventId}');
    try {
      final event = await eventRepository.getEventById(params.eventId);
      logger.i('Мероприятие ${params.eventId} успешно получено');
      return event;
    } on NotFoundException {
      logger.w('Мероприятие с ID ${params.eventId} не найдено');
      rethrow;
    } catch (e, s) {
      logger.e(
        'Не удалось получить мероприятие ${params.eventId}',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}

/// Params для ListEventsUseCase
class ListEventsParams {
  final String? userId;
  final List<String>? tags;
  final bool? isPublic;
  final EventStatus? status;
  final String? searchQuery;
  final int limit;
  final int offset;

  ListEventsParams({
    this.userId,
    this.tags,
    this.isPublic,
    this.status,
    this.searchQuery,
    this.limit = 20,
    this.offset = 0,
  });
}

/// Usecase для получения списка мероприятий
class ListEventsUseCase extends UseCase<List<Event>, ListEventsParams> {
  final EventRepository eventRepository;
  final Logger logger;

  ListEventsUseCase({required this.eventRepository, required this.logger});

  @override
  Future<List<Event>> call(ListEventsParams params) async {
    logger.i('Запрос списка мероприятий с параметрами: ${params.toString()}');
    try {
      final events = await eventRepository.listEvents(
        userId: params.userId,
        tags: params.tags,
        isPublic: params.isPublic,
        status: params.status,
        searchQuery: params.searchQuery,
        limit: params.limit,
        offset: params.offset,
      );
      logger.i('Получено ${events.length} мероприятий');
      return events;
    } catch (e, s) {
      logger.e(
        'Ошибка при получении списка мероприятий',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }
}
