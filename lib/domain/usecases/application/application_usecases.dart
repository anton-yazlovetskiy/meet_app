import '../../entities/index.dart';
import '../../repositories/index.dart';
import '../../exceptions/domain_exceptions.dart';
import '../usecase.dart';

/// Params для CreateApplicationUseCase
class CreateApplicationParams {
  final String eventId;
  final String userId;
  final List<String> selectedSlotIds;

  CreateApplicationParams({
    required this.eventId,
    required this.userId,
    required this.selectedSlotIds,
  });
}

/// Usecase для подачи заявки на мероприятие
class CreateApplicationUseCase extends UseCase<Application, CreateApplicationParams> {
  final ApplicationRepository applicationRepository;
  final EventRepository eventRepository;

  CreateApplicationUseCase({
    required this.applicationRepository,
    required this.eventRepository,
  });

  @override
  Future<Application> call(CreateApplicationParams params) async {
    /// Получить мероприятие
    final event = await eventRepository.getEventById(params.eventId);

    /// Проверить что мероприятие не архивное
    if (event.isArchived || event.status == EventStatus.archived) {
      throw BusinessLogicException('Не можно подать заявку на архивное мероприятие');
    }

    /// Проверить что пользователь еще не подал заявку
    final existingApp = await applicationRepository.getUserApplicationForEvent(
      userId: params.userId,
      eventId: params.eventId,
    );
    if (existingApp != null) {
      throw ConflictException('Вы уже подали заявку на это мероприятие');
    }

    /// Проверить доступность слотов
    final slots = await eventRepository.getEventSlots(params.eventId);
    for (final slotId in params.selectedSlotIds) {
      final slot = slots.firstWhere(
        (s) => s.id == slotId,
        orElse: () => throw NotFoundException('Слот $slotId не найден'),
      );
      if (!slot.isAvailable) {
        throw BusinessLogicException('Слот $slotId недоступен для выбора');
      }
    }

    return await applicationRepository.createApplication(
      eventId: params.eventId,
      userId: params.userId,
      selectedSlotIds: params.selectedSlotIds,
    );
  }
}

/// Params для UpdateApplicationUseCase
class UpdateApplicationParams {
  final String applicationId;
  final List<String> selectedSlotIds;
  final String userId;
  final String eventId;

  UpdateApplicationParams({
    required this.applicationId,
    required this.selectedSlotIds,
    required this.userId,
    required this.eventId,
  });
}

/// Usecase для обновления заявки (изменение выбранных слотов)
class UpdateApplicationUseCase extends UseCase<void, UpdateApplicationParams> {
  final ApplicationRepository applicationRepository;
  final EventRepository eventRepository;

  UpdateApplicationUseCase({
    required this.applicationRepository,
    required this.eventRepository,
  });

  @override
  Future<void> call(UpdateApplicationParams params) async {
    /// Проверить что мероприятие еще в режиме голосования
    final event = await eventRepository.getEventById(params.eventId);
    if (event.eventType != EventType.voting) {
      throw BusinessLogicException(
        'Нельзя изменить заявку, мероприятие уже перешло в финальный режим',
      );
    }

    /// Проверить доступность слотов
    final slots = await eventRepository.getEventSlots(params.eventId);
    for (final slotId in params.selectedSlotIds) {
      final slot = slots.firstWhere(
        (s) => s.id == slotId,
        orElse: () => throw NotFoundException('Слот $slotId не найден'),
      );
      if (!slot.isAvailable) {
        throw BusinessLogicException('Слот $slotId недоступен для выбора');
      }
    }

    await applicationRepository.updateApplicationSlots(
      applicationId: params.applicationId,
      selectedSlotIds: params.selectedSlotIds,
    );
  }
}

/// Params для CancelApplicationUseCase
class CancelApplicationParams {
  final String applicationId;

  CancelApplicationParams({required this.applicationId});
}

/// Usecase для отмены заявки
class CancelApplicationUseCase extends UseCase<void, CancelApplicationParams> {
  final ApplicationRepository applicationRepository;

  CancelApplicationUseCase(this.applicationRepository);

  @override
  Future<void> call(CancelApplicationParams params) async {
    await applicationRepository.cancelApplication(params.applicationId);
  }
}
