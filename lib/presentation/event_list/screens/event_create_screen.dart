import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/index.dart';
import '../../../domain/repositories/index.dart';
import '../../../domain/usecases/index.dart';

@RoutePage()
class EventCreatePage extends StatefulWidget {
  const EventCreatePage({super.key});

  @override
  State<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends State<EventCreatePage> {
  final _createEventUseCase = GetIt.instance<CreateEventUseCase>();
  final _authRepository = GetIt.instance<AuthRepository>();
  final _formKey = GlobalKey<FormState>();

  // Form fields
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

  static const List<String> _cityPool = [
    'Москва',
    'Санкт-Петербург',
    'Казань',
    'Екатеринбург',
    'Новосибирск',
    'Нижний Новгород',
    'Краснодар',
    'Самара',
    'Ростов-на-Дону',
    'Уфа',
    'Пермь',
    'Сочи',
    'Калининград',
    'Воронеж',
    'Волгоград',
    'Тюмень',
    'Омск',
    'Челябинск',
    'Красноярск',
    'Владивосток',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
    _maxParticipantsController = TextEditingController();
    _priceController = TextEditingController(text: '0');
    _selectedStartDate = DateTime.now().add(const Duration(days: 7));
    _selectedCity = _cityPool.first;
    _initCurrentUser();
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _maxParticipantsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_selectedStartDate ?? DateTime.now())
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        }
      });
    }
  }

  Future<void> _selectVotingDates(BuildContext context) async {
    final pickedStart = await showDatePicker(
      context: context,
      initialDate: _selectedVotingStart ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedStart == null) return;
    if (!context.mounted) return;

    final pickedEnd = await showDatePicker(
      context: context,
      initialDate:
          _selectedVotingEnd ?? pickedStart.add(const Duration(days: 7)),
      firstDate: pickedStart,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedEnd == null) return;
    if (!context.mounted) return;

    setState(() {
      _selectedVotingStart = pickedStart;
      _selectedVotingEnd = pickedEnd;
    });
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дату начала')));
      return;
    }

    if (_eventType == EventType.voting &&
        (_selectedVotingStart == null || _selectedVotingEnd == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите период голосования')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final maxParticipants = _maxParticipantsController.text.isEmpty
          ? null
          : int.parse(_maxParticipantsController.text);
      final price = double.parse(_priceController.text);

      final event = await _createEventUseCase(
        CreateEventParams(
          title: _titleController.text,
          description: _descriptionController.text,
          tags: tags,
          location: Location(
            lat: 55.7558,
            lng: 37.6173,
            mapLink: 'https://maps.google.com/?q=55.7558,37.6173',
            address: '${_selectedCity ?? 'Москва'}, Центр города',
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
          unAvailableSlots: [],
          userId: _currentUserId,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(event);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Не выбрана';
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Future<void> _showCityPicker() async {
    final cities = <String>{..._cityPool};
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
                    decoration: const InputDecoration(
                      hintText: 'Поиск города',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      final query = value.trim().toLowerCase();
                      setModalState(() {
                        filtered = cityItems
                            .where(
                              (city) => city.toLowerCase().contains(query),
                            )
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать событие')),
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Название события',
                      hintText: 'Введите название',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Требуется название';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      hintText: 'Введите описание события',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Требуется описание';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Теги (через запятую)',
                      hintText: 'спорт, развлечения',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Открытое событие'),
                    value: _isPublic,
                    onChanged: (value) => setState(() => _isPublic = value),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<EventType>(
                    segments: const [
                      ButtonSegment(
                        label: Text('Голосование'),
                        value: EventType.voting,
                      ),
                      ButtonSegment(
                        label: Text('С фиксированной датой'),
                        value: EventType.fixed,
                      ),
                    ],
                    selected: {_eventType},
                    onSelectionChanged: (Set<EventType> newSelection) {
                      setState(() => _eventType = newSelection.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Дата начала'),
                    subtitle: Text(_formatDate(_selectedStartDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context, true),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  if (_eventType == EventType.voting)
                    ListTile(
                      title: const Text('Период голосования'),
                      subtitle: Text(
                        _selectedVotingStart != null &&
                                _selectedVotingEnd != null
                            ? '${_formatDate(_selectedVotingStart)} - ${_formatDate(_selectedVotingEnd)}'
                            : 'Не выбран',
                      ),
                      trailing: const Icon(Icons.how_to_vote),
                      onTap: () => _selectVotingDates(context),
                      contentPadding: EdgeInsets.zero,
                    ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Город'),
                    subtitle: Text(_selectedCity ?? 'Не выбран'),
                    trailing: const Icon(Icons.location_city),
                    onTap: _showCityPicker,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _maxParticipantsController,
                    decoration: const InputDecoration(
                      labelText: 'Максимум участников (опционально)',
                      hintText: 'Оставьте пусто, если неограничено',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Цена (₽)',
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Требуется цена';
                      try {
                        double.parse(value!);
                        return null;
                      } catch (e) {
                        return 'Некорректная цена';
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _createEvent,
                      child: const Text('Создать событие'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
