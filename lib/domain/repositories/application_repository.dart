import '../entities/index.dart';

/// Интерфейс репозитория заявок на участие
abstract class ApplicationRepository {
  /// Подать заявку на участие
  Future<Application> createApplication({
    required String eventId,
    required String userId,
    required List<String> selectedSlotIds,
  });

  /// Получить заявку по ID
  Future<Application> getApplicationById(String applicationId);

  /// Получить заявки пользователя
  Future<List<Application>> getUserApplications(String userId);

  /// Получить заявки на мероприятие
  Future<List<Application>> getEventApplications(String eventId);

  /// Обновить выбранные слоты заявки
  Future<void> updateApplicationSlots({
    required String applicationId,
    required List<String> selectedSlotIds,
  });

  /// Одобрить заявку (автоматически при выборе слота)
  Future<void> approveApplication(String applicationId);

  /// Отклонить заявку
  Future<void> rejectApplication(String applicationId);

  /// Отменить заявку пользователем
  Future<void> cancelApplication(String applicationId);

  /// Получить заявку пользователя для мероприятия
  Future<Application?> getUserApplicationForEvent({
    required String userId,
    required String eventId,
  });
}
