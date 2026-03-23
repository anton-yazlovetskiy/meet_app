import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/index.dart';
import '../../../data/models/index.dart';
import 'application_datasource.dart';

/// Mock реализация ApplicationRemoteDataSource
class MockApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  static const String _applicationsKey = 'mock_applications';

  Map<String, ApplicationModel> _loadApplications() {
    final json = _prefs.getString(_applicationsKey) ?? '{}';
    final Map<String, dynamic> data = jsonDecode(json);
    return data.map((k, v) => MapEntry(k, ApplicationModel.fromJson(v)));
  }

  void _saveApplications(Map<String, ApplicationModel> applications) {
    final json = jsonEncode(applications.map((k, v) => MapEntry(k, v.toJson())));
    _prefs.setString(_applicationsKey, json);
  }

  @override
  Future<ApplicationModel> createApplication(ApplicationModel application) async {
    final applications = _loadApplications();
    applications[application.id] = application;
    _saveApplications(applications);
    return application;
  }

  @override
  Future<ApplicationModel> getApplicationById(String applicationId) async {
    final applications = _loadApplications();
    final app = applications[applicationId];
    if (app == null) throw Exception('Application not found');
    return app;
  }

  @override
  Future<List<ApplicationModel>> getUserApplications(String userId) async {
    final applications = _loadApplications();
    return applications.values.where((a) => a.userId == userId).toList();
  }

  @override
  Future<List<ApplicationModel>> getEventApplications(String eventId) async {
    final applications = _loadApplications();
    return applications.values.where((a) => a.eventId == eventId).toList();
  }

  @override
  Future<void> updateApplicationSlots(
    String applicationId,
    List<String> slotIds,
  ) async {
    final applications = _loadApplications();
    final app = applications[applicationId];
    if (app != null) {
      applications[applicationId] = ApplicationModel(
        id: app.id,
        eventId: app.eventId,
        userId: app.userId,
        selectedSlotIds: slotIds,
        status: app.status,
        updatedAt: DateTime.now(),
        createdAt: app.createdAt,
      );
      _saveApplications(applications);
    }
  }

  @override
  Future<void> cancelApplication(String applicationId) async {
    final applications = _loadApplications();
    final app = applications[applicationId];
    if (app != null) {
      applications[applicationId] = ApplicationModel(
        id: app.id,
        eventId: app.eventId,
        userId: app.userId,
        selectedSlotIds: app.selectedSlotIds,
        status: ApplicationStatus.cancelled,
        updatedAt: DateTime.now(),
        createdAt: app.createdAt,
      );
      _saveApplications(applications);
    }
  }

  @override
  Future<ApplicationModel?> getUserApplicationForEvent({
    required String userId,
    required String eventId,
  }) async {
    final applications = _loadApplications();
    try {
      return applications.values.firstWhere(
        (a) => a.userId == userId && a.eventId == eventId,
      );
    } catch (e) {
      return null;
    }
  }
}
