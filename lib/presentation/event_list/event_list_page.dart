import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';
import '../../domain/usecases/application/application_usecases.dart';
import '../../l10n/app_localizations.dart';
import '../event_details/event_details_page.dart';
import 'event_create_page.dart';

class EventListPage extends StatefulWidget {
  final VoidCallback onOpenSettings;

  const EventListPage({super.key, required this.onOpenSettings});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final _eventRepository = GetIt.instance<EventRepository>();
  final _authRepository = GetIt.instance<AuthRepository>();
  final _applicationRepository = GetIt.instance<ApplicationRepository>();

  User? _currentUser;
  List<Event> _events = [];
  Set<String> _userAppliedEventIds = {};
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'all'; // all, planned, active, fixed
  String _cityFilter = 'all';
  String _searchQuery = '';
  String _sortBy = 'date_desc';
  final Set<String> _tagFilters = {};
  String _myFilter = 'all'; // all, created, participating, applied, archived

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadUserAppliedEventIds(String userId) async {
    try {
      final apps = await _applicationRepository.getUserApplications(userId);
      setState(() {
        _userAppliedEventIds = apps.map((a) => a.eventId).toSet();
      });
    } catch (_) {
      setState(() {
        _userAppliedEventIds = {};
      });
    }
  }

  String _eventCity(Event event) {
    final mapLink = event.location.mapLink.toLowerCase();
    if (mapLink.contains('55.754') || mapLink.contains('55.755') || mapLink.contains('55.761')) {
      return 'Москва';
    }
    if (mapLink.contains('59.93')) {
      return 'Санкт-Петербург';
    }
    return 'Другой';
  }

  List<String> _availableCities() {
    final cities = {'all', ..._events.map(_eventCity)};
    return cities.toList();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await _authRepository.getCurrentUser();
      _currentUser = user;

      final events = await _eventRepository.listEvents();
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() => _events = events);

      if (user != null) {
        await _loadUserAppliedEventIds(user.id);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Event> _getFilteredEvents() {
    var filtered = _events;

    if (_filterStatus != 'all') {
      filtered = filtered.where((e) => e.status.name == _filterStatus).toList();
    }

    if (_cityFilter != 'all') {
      filtered = filtered.where((e) => _eventCity(e) == _cityFilter).toList();
    }

    if (_tagFilters.isNotEmpty) {
      filtered = filtered.where((e) => e.tags.any((tag) => _tagFilters.contains(tag))).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        return e.title.toLowerCase().contains(query) || e.description.toLowerCase().contains(query) || e.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }

    switch (_myFilter) {
      case 'created':
        filtered = filtered.where((e) => _currentUser != null && e.creatorId == _currentUser!.id).toList();
        break;
      case 'participating':
        filtered = filtered.where((e) => _currentUser != null && e.participants.contains(_currentUser!.id)).toList();
        break;
      case 'applied':
        filtered = filtered.where((e) => _userAppliedEventIds.contains(e.id)).toList();
        break;
      case 'archived':
        filtered = filtered.where((e) => e.status == EventStatus.archived || e.isArchived).toList();
        break;
      case 'all':
      default:
        break;
    }

    if (_sortBy == 'date_asc') {
      filtered.sort((a, b) => a.startLimit.compareTo(b.startLimit));
    } else if (_sortBy == 'date_desc') {
      filtered.sort((a, b) => b.startLimit.compareTo(a.startLimit));
    } else if (_sortBy == 'price_asc') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date.toLocal());
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.planned:
        return Colors.blue;
      case EventStatus.active:
        return Colors.green;
      case EventStatus.fixed:
        return Colors.purple;
      case EventStatus.archived:
        return Colors.grey;
      case EventStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _getFilteredEvents();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventsPageTitle),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: widget.onOpenSettings),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _isLoading ? null : _loadEvents),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: 'Поиск по событиям', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _cityFilter,
                        decoration: const InputDecoration(labelText: 'Город'),
                        items: _availableCities().map((city) {
                          return DropdownMenuItem(value: city, child: Text(city == 'all' ? l10n.allEventsFilter : city));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _cityFilter = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _sortBy,
                        decoration: const InputDecoration(labelText: 'Сортировка'),
                        items: const [
                          DropdownMenuItem(value: 'date_desc', child: Text('Дата ↓')),
                          DropdownMenuItem(value: 'date_asc', child: Text('Дата ↑')),
                          DropdownMenuItem(value: 'price_asc', child: Text('Цена ↑')),
                          DropdownMenuItem(value: 'price_desc', child: Text('Цена ↓')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _sortBy = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _FilterChip(label: l10n.allEventsFilter, isSelected: _myFilter == 'all', onSelected: () => setState(() => _myFilter = 'all')),
                    _FilterChip(label: 'Созданные мной', isSelected: _myFilter == 'created', onSelected: () => setState(() => _myFilter = 'created')),
                    _FilterChip(label: 'Участвую', isSelected: _myFilter == 'participating', onSelected: () => setState(() => _myFilter = 'participating')),
                    _FilterChip(label: 'Подал заявку', isSelected: _myFilter == 'applied', onSelected: () => setState(() => _myFilter = 'applied')),
                    _FilterChip(label: 'Архив', isSelected: _myFilter == 'archived', onSelected: () => setState(() => _myFilter = 'archived')),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _events
                      .expand((e) => e.tags)
                      .toSet()
                      .map(
                        (tag) => FilterChip(
                          label: Text(tag),
                          selected: _tagFilters.contains(tag),
                          onSelected: (selected) => setState(() {
                            if (selected) {
                              _tagFilters.add(tag);
                            } else {
                              _tagFilters.remove(tag);
                            }
                          }),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  _FilterChip(label: l10n.allEventsFilter, isSelected: _filterStatus == 'all', onSelected: () => setState(() => _filterStatus = 'all')),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.plannedEventsFilter, isSelected: _filterStatus == 'planned', onSelected: () => setState(() => _filterStatus = 'planned')),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.activeEventsFilter, isSelected: _filterStatus == 'active', onSelected: () => setState(() => _filterStatus = 'active')),
                  const SizedBox(width: 8),
                  _FilterChip(label: l10n.fixedEventsFilter, isSelected: _filterStatus == 'fixed', onSelected: () => setState(() => _filterStatus = 'fixed')),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('${l10n.error}: $_error'))
                : filtered.isEmpty
                ? Center(child: Text(l10n.noEventsFound))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final event = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventCard(event: event, currentUser: _currentUser, onChanged: _loadEvents),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventCreatePage()));
                _loadEvents();
              },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(label: Text(label), selected: isSelected, onSelected: (_) => onSelected());
  }
}

class _EventCard extends StatefulWidget {
  final Event event;
  final User? currentUser;
  final Future<void> Function() onChanged;

  const _EventCard({required this.event, required this.currentUser, required this.onChanged});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<_EventCard> {
  final EventRepository _eventRepository = GetIt.instance<EventRepository>();
  final ApplicationRepository _applicationRepository = GetIt.instance<ApplicationRepository>();
  final CreateApplicationUseCase _createApplicationUseCase = GetIt.instance<CreateApplicationUseCase>();
  final CancelApplicationUseCase _cancelApplicationUseCase = GetIt.instance<CancelApplicationUseCase>();

  bool _expanded = false;
  bool _actionLoading = false;
  List<Slot> _slots = [];
  final Set<String> _selectedVoteSlots = {};

  bool get _isCreator => widget.currentUser?.id == widget.event.creatorId;
  bool get _isParticipant => widget.currentUser != null && widget.event.participants.contains(widget.currentUser!.id);
  bool get _hasApplication => widget.currentUser != null && widget.event.applicants.contains(widget.currentUser!.id);

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    if (widget.event.eventType != EventType.voting) return;
    try {
      final slots = await _eventRepository.getEventSlots(widget.event.id);
      setState(() => _slots = slots);
    } catch (_) {
      // consume
    }
  }

  String _eventCity(Event event) {
    final mapLink = event.location.mapLink.toLowerCase();
    if (mapLink.contains('55.754') || mapLink.contains('55.755') || mapLink.contains('55.761')) {
      return 'Москва';
    }
    if (mapLink.contains('59.93')) {
      return 'Санкт-Петербург';
    }
    return 'Другой';
  }

  Future<void> _toggleParticipation() async {
    if (widget.currentUser == null) return;
    setState(() => _actionLoading = true);

    try {
      if (_isParticipant || _hasApplication) {
        final app = await _applicationRepository.getUserApplicationForEvent(userId: widget.currentUser!.id, eventId: widget.event.id);
        if (app != null) {
          await _cancelApplicationUseCase.call(CancelApplicationParams(applicationId: app.id));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Вы отменили заявку на "${widget.event.title}"')));
        }
      } else {
        final slotIds = widget.event.eventType == EventType.voting ? (_selectedVoteSlots.isNotEmpty ? _selectedVoteSlots.toList() : _slots.take(1).map((s) => s.id).toList()) : <String>[];
        await _createApplicationUseCase.call(CreateApplicationParams(eventId: widget.event.id, userId: widget.currentUser!.id, selectedSlotIds: slotIds));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Вы подали заявку на "${widget.event.title}"')));
      }
      await widget.onChanged();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: ${e.toString()}')));
    } finally {
      setState(() => _actionLoading = false);
    }
  }

  Future<void> _openMap() async {
    final url = widget.event.location.mapLink;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверный URL карты')));
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Не удалось открыть карту')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final priceLabel = event.price > 0 ? '${event.price.toStringAsFixed(0)} ₽' : 'Бесплатно';
    final topSlots = _slots..sort((a, b) => b.votes.compareTo(a.votes));

    return Card(
      elevation: 2,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                height: 240,
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(label: Text(event.status.name)),
                        const SizedBox(width: 6),
                        Chip(label: Text(event.eventType.name)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text(_eventCity(event))),
                        IconButton(icon: const Icon(Icons.map), onPressed: _openMap),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 4),
                        Text('${event.participants.length}/${event.maxParticipants ?? 9999}'),
                        const SizedBox(width: 12),
                        const Icon(Icons.assignment, size: 16),
                        const SizedBox(width: 4),
                        Text('${event.applicants.length} заявок'),
                        const SizedBox(width: 12),
                        const Icon(Icons.price_check, size: 16),
                        const SizedBox(width: 4),
                        Text(priceLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.eventType == EventType.voting) ...[
                      const Text('Топ 3 слота', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...topSlots
                          .take(3)
                          .map(
                            (slot) => ListTile(
                              dense: true,
                              title: Text(DateFormat('dd.MM.yy HH:mm').format(slot.datetime.toLocal())),
                              subtitle: Text('${slot.votes} голосов'),
                              trailing: Checkbox(
                                value: _selectedVoteSlots.contains(slot.id),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedVoteSlots.add(slot.id);
                                    } else {
                                      _selectedVoteSlots.remove(slot.id);
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                    ],
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(onPressed: _actionLoading ? null : _toggleParticipation, child: Text(_isParticipant || _hasApplication ? 'Отказаться' : 'Участвовать')),
                    ),
                    if (widget.currentUser != null && _isCreator) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Вы менеджер события',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 6),
                      TextButton(onPressed: () {}, child: const Text('Выбрать итоговый слот')),
                      TextButton(onPressed: () {}, child: const Text('Блок/разблок участника')),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
