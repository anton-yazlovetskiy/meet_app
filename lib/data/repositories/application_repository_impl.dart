import '../../domain/repositories/application_repository.dart';
import '../../domain/entities/index.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../datasources/index.dart';
import '../models/index.dart';

/// Реализация ApplicationRepository
class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;

  ApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Application> createApplication({required String eventId, required String userId, required List<String> selectedSlotIds}) async {
    try {
      final application = ApplicationModel(
        id: 'app_${DateTime.now().millisecondsSinceEpoch}',
        eventId: eventId,
        userId: userId,
        selectedSlotIds: selectedSlotIds,
        status: ApplicationStatus.pending,
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      return await remoteDataSource.createApplication(application);
    } catch (e) {
      throw BusinessLogicException('Ошибка при подаче заявки: $e');
    }
  }

  @override
  Future<Application> getApplicationById(String applicationId) async {
    try {
      return await remoteDataSource.getApplicationById(applicationId);
    } catch (e) {
      throw NotFoundException('Заявка не найдена');
    }
  }

  @override
  Future<List<Application>> getUserApplications(String userId) async {
    try {
      return await remoteDataSource.getUserApplications(userId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при загрузке заявок пользователя');
    }
  }

  @override
  Future<List<Application>> getEventApplications(String eventId) async {
    try {
      return await remoteDataSource.getEventApplications(eventId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при загрузке заявок на мероприятие');
    }
  }

  @override
  Future<void> updateApplicationSlots({required String applicationId, required List<String> selectedSlotIds}) async {
    try {
      await remoteDataSource.updateApplicationSlots(applicationId, selectedSlotIds);
    } catch (e) {
      throw BusinessLogicException('Ошибка при обновлении заявки: $e');
    }
  }

  @override
  Future<void> approveApplication(String applicationId) async {
    try {
      final app = await getApplicationById(applicationId);
      await remoteDataSource.updateApplicationSlots(applicationId, app.selectedSlotIds);
    } catch (e) {
      throw BusinessLogicException('Ошибка при одобрении заявки');
    }
  }

  @override
  Future<void> rejectApplication(String applicationId) async {
    try {
      await getApplicationById(applicationId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при отклонении заявки');
    }
  }

  @override
  Future<void> cancelApplication(String applicationId) async {
    try {
      await getApplicationById(applicationId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при отмене заявки');
    }
  }

  @override
  Future<Application?> getUserApplicationForEvent({required String userId, required String eventId}) async {
    try {
      return await remoteDataSource.getUserApplicationForEvent(userId: userId, eventId: eventId);
    } catch (e) {
      return null;
    }
  }
}
