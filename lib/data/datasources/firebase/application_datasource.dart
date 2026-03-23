import '../../domain/index.dart';
import '../../data/models/index.dart';

/// Интерфейс для Application (заявки) datasource
abstract class ApplicationRemoteDataSource {
  /// Создать заявку
  Future<ApplicationModel> createApplication(ApplicationModel application);

  /// Получить заявку по ID
  Future<ApplicationModel> getApplicationById(String applicationId);

  /// Получить заявки пользователя
  Future<List<ApplicationModel>> getUserApplications(String userId);

  /// Получить заявки на мероприятие
  Future<List<ApplicationModel>> getEventApplications(String eventId);

  /// Обновить слоты заявки
  Future<void> updateApplicationSlots(String applicationId, List<String> slotIds);

  /// Отменить заявку
  Future<void> cancelApplication(String applicationId);

  /// Получить заявку пользователя для мероприятия
  Future<ApplicationModel?> getUserApplicationForEvent({
    required String userId,
    required String eventId,
  });
}
