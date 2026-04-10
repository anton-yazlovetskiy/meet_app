import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/index.dart';
import '../../../../domain/repositories/index.dart';
import '../../../../domain/usecases/index.dart';
import '../../../../l10n/app_localizations.dart';
import 'models/event_create_city_options.dart';
import 'widgets/event_create_form_widget.dart';

/// Экран создания события внутри EventList.
///
/// Открывается модально и не участвует в корневой маршрутизации приложения.
class EventCreateScreen extends StatefulWidget {
  const EventCreateScreen({super.key});

  @override
  State<EventCreateScreen> createState() => _EventCreateScreenState();
}

class _EventCreateScreenState extends State<EventCreateScreen> {
  final _createEventUseCase = GetIt.instance<CreateEventUseCase>();
  final _authRepository = GetIt.instance<AuthRepository>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  late TextEditingController _maxParticipantsController;
  late TextEditingController _priceController;

  DateTime? _selectedStartDate;
  DateTime? _selectedVotingStart;
  DateTime? _selectedVotingEnd;
  bool _isPublic = true;
  EventType _eventType = EventType.voting;
  bool _isLoading = false;
  String? _selectedCity;
  String _currentUserId = 'user_1';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _priceController = TextEditingController(text: '0');
    _selectedStartDate = DateTime.now().add(const Duration(days: 7));
    _selectedCity = EventCreateCityOptions.values.first;
    _initCurrentUser();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _maxParticipantsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _initCurrentUser() async {
    final user = await _authRepository.getCurrentUser();
    if (!mounted || user == null) {
      return;
    }
    setState(() {
      _currentUserId = user.id;
      if (user.city != null && user.city!.trim().isNotEmpty) {
        _selectedCity = user.city!.trim();
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) {
      return;
    }

    setState(() {
      _selectedStartDate = picked;
    });
  }

  Future<void> _selectVotingDates() async {
    final pickedStart = await showDatePicker(
      context: context,
      initialDate: _selectedVotingStart ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedStart == null || !mounted) {
      return;
    }

    final pickedEnd = await showDatePicker(
      context: context,
      initialDate:
          _selectedVotingEnd ?? pickedStart.add(const Duration(days: 7)),
      firstDate: pickedStart,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedEnd == null || !mounted) {
      return;
    }

    setState(() {
      _selectedVotingStart = pickedStart;
      _selectedVotingEnd = pickedEnd;
    });
  }

  Future<void> _showCityPicker() async {
    final l10n = AppLocalizations.of(context)!;
    // Берем общий справочник и аккуратно добавляем текущий город пользователя,
    // если он отсутствует в базовом списке.
    final cities = <String>{...EventCreateCityOptions.values};
    if (_selectedCity != null && _selectedCity!.trim().isNotEmpty) {
      cities.add(_selectedCity!.trim());
    }
    final cityItems = cities.toList()..sort();
    final searchController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        var filtered = [...cityItems];
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: l10n.eventCreateCitySearchHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      final query = value.trim().toLowerCase();
                      setModalState(() {
                        filtered = cityItems
                            .where((city) => city.toLowerCase().contains(query))
                            .toList(growable: false);
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final city = filtered[index];
                        return ListTile(
                          selected: _selectedCity == city,
                          title: Text(city),
                          onTap: () {
                            setState(() => _selectedCity = city);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    searchController.dispose();
  }

  Future<void> _createEvent() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStartDate == null) {
      _showFloatingMessage(l10n.eventCreateDateRequiredError);
      return;
    }

    if (_eventType == EventType.voting &&
        (_selectedVotingStart == null || _selectedVotingEnd == null)) {
      _showFloatingMessage(l10n.eventCreateVotingPeriodRequiredError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Нормализуем форму перед передачей в domain-слой.
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
      final maxParticipants = _maxParticipantsController.text.isEmpty
          ? null
          : int.parse(_maxParticipantsController.text);
      final price = double.parse(_priceController.text);

      final city = _selectedCity ?? l10n.eventCreateDefaultCity;
      final event = await _createEventUseCase(
        CreateEventParams(
          title: _titleController.text,
          description: _descriptionController.text,
          tags: tags,
          location: Location(
            lat: 55.7558,
            lng: 37.6173,
            mapLink: 'https://maps.google.com/?q=55.7558,37.6173',
            address: '$city, ${l10n.eventCreateDefaultAddressSuffix}',
          ),
          isPublic: _isPublic,
          eventType: _eventType,
          maxParticipants: maxParticipants,
          price: price,
          startLimit: _selectedStartDate!,
          votingPeriod: _eventType == EventType.voting
              ? DateRange(
                  start: _selectedVotingStart!,
                  end: _selectedVotingEnd!,
                )
              : null,
          unAvailableSlots: const <String>[],
          userId: _currentUserId,
        ),
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(event);
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showFloatingMessage(l10n.eventCreateErrorMessage(e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFloatingMessage(String text) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(text),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    final l10n = AppLocalizations.of(context)!;
    if (date == null) {
      return l10n.eventCreateDateNotSelected;
    }
    return DateFormat('dd.MM.yyyy').format(date);
  }

  String _formatVotingPeriod() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedVotingStart == null || _selectedVotingEnd == null) {
      return l10n.eventCreateNotSelected;
    }

    return [
      _formatDate(_selectedVotingStart),
      _formatDate(_selectedVotingEnd),
    ].join(l10n.eventCreateDateRangeSeparator);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createEventPageTitle)),
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            EventCreateFormWidget(
              formKey: _formKey,
              isLoading: _isLoading,
              eventType: _eventType,
              isPublic: _isPublic,
              titleController: _titleController,
              descriptionController: _descriptionController,
              tagsController: _tagsController,
              maxParticipantsController: _maxParticipantsController,
              priceController: _priceController,
              selectedStartDate: _formatDate(_selectedStartDate),
              selectedVotingPeriod: _formatVotingPeriod(),
              selectedCity: _selectedCity ?? l10n.eventCreateNotSelected,
              onSelectStartDate: _selectDate,
              onSelectVotingPeriod: _selectVotingDates,
              onSelectCity: _showCityPicker,
              onPublicChanged: (value) => setState(() => _isPublic = value),
              onEventTypeChanged: (value) => setState(() => _eventType = value),
              onCreate: _createEvent,
            ),
          ],
        ),
      ),
    );
  }
}
