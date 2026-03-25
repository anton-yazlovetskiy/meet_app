import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';
import '../../domain/usecases/application/application_usecases.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/LayoutBuilder.dart';
import 'event_create_page.dart';

class EventListPage extends StatefulWidget {
  final VoidCallback onOpenSettings;
  final Locale currentLocale;
  final void Function(Locale locale) onLocaleChanged;
  final VoidCallback onToggleTheme;

  const EventListPage({super.key, required this.onOpenSettings, required this.currentLocale, required this.onLocaleChanged, required this.onToggleTheme});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final _eventRepository = GetIt.instance<EventRepository>();
  final _authRepository = GetIt.instance<AuthRepository>();
  final _applicationRepository = GetIt.instance<ApplicationRepository>();
  final Logger _logger = GetIt.instance<Logger>();

  User? _currentUser;
  List<Event> _events = [];
  Set<String> _userAppliedEventIds = {};
  bool _isLoading = false;
  String? _error;
  String _cityFilter = '';
  String _searchQuery = '';
  bool _sortDateDesc = true; // true = desc (свежие сначала)
  int _priceSortState = 0; // 0: no sorting, 1: cheap first (asc), 2: expensive first (desc)
  final Set<String> _tagFilters = {};
  String _myFilter = 'all'; // all, created, participating, applied, archived

  final ScrollController _eventsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _cityFilter = _defaultCity();
    _loadEvents();
  }

  String _defaultCity() {
    return widget.currentLocale.languageCode == 'ru' ? 'Москва' : 'Moscow';
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
      _logger.d('Loaded current user: ${user?.id}');

      final events = await _eventRepository.listEvents();
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() => _events = events);
      _logger.i('Loaded ${events.length} events');

      if (user != null) {
        await _loadUserAppliedEventIds(user.id);
      }
    } catch (e, stack) {
      _logger.e('Error loading events: $e', error: e, stackTrace: stack);
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Event> _getFilteredEvents() {
    var filtered = _events;

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

    if (_sortDateDesc) {
      filtered.sort((a, b) => b.startLimit.compareTo(a.startLimit));
    } else {
      filtered.sort((a, b) => a.startLimit.compareTo(b.startLimit));
    }

    // Then sort by price if needed
    if (_priceSortState > 0) {
      filtered.sort((a, b) {
        int dateComp = _sortDateDesc ? b.startLimit.compareTo(a.startLimit) : a.startLimit.compareTo(b.startLimit);
        if (dateComp != 0) return dateComp;
        // 1: cheap first (asc), 2: expensive first (desc)
        return _priceSortState == 1 ? a.price.compareTo(b.price) : b.price.compareTo(a.price);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _getFilteredEvents();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black, Colors.indigo, Colors.black], stops: [0.1, 0.9, 1.0])
        : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.white, Colors.white], stops: [0.0, 0.5, 1.0]);

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.pets), // cat icon
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchEventsInYourCity,
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none, // borderless
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _cityFilter,
              items: _availableCities().map((city) {
                return DropdownMenuItem(value: city, child: Text(city == 'all' ? l10n.allEventsFilter : city));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _cityFilter = value);
              },
            ),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode), onPressed: widget.onToggleTheme),
          PopupMenuButton<String>(
            child: Text(widget.currentLocale.languageCode.toUpperCase()),
            onSelected: (value) {
              widget.onLocaleChanged(Locale(value));
            },
            itemBuilder: (context) => [const PopupMenuItem(value: 'ru', child: Text('Русский')), const PopupMenuItem(value: 'en', child: Text('English'))],
          ),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}), // placeholder
          IconButton(icon: const Icon(Icons.person), onPressed: widget.onOpenSettings), // profile
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(l10n.tagsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView(
                children: _events
                    .expand((e) => e.tags)
                    .toSet()
                    .map(
                      (tag) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: FilterChip(
                          label: Text(tag),
                          selected: _tagFilters.contains(tag),
                          onSelected: (selected) => setState(() {
                            if (selected == true) {
                              _tagFilters.add(tag);
                              _logger.d('Added tag filter: $tag');
                            } else {
                              _tagFilters.remove(tag);
                              _logger.d('Removed tag filter: $tag');
                            }
                          }),
                          shape: const StadiumBorder(),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: ResponsiveUI(
          mobile: _buildMobileBody(l10n, filtered),
          desktop: _buildDesktopBody(l10n, filtered),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading
            ? null
            : () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventCreatePage())).then((_) => _loadEvents());
              },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileBody(AppLocalizations l10n, List<Event> filtered) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Date sorting
                IconButton(
                  icon: Icon(Icons.calendar_today, color: _sortDateDesc ? Colors.blue : Colors.grey),
                  tooltip: _sortDateDesc ? 'Sort by date: Newest first' : 'Sort by date: Oldest first',
                  onPressed: () => setState(() => _sortDateDesc = !_sortDateDesc),
                ),
                Icon(_sortDateDesc ? Icons.arrow_downward : Icons.arrow_upward, size: 16),
                const SizedBox(width: 16),
                // Price sorting
                IconButton(
                  icon: Icon(Icons.attach_money, color: _priceSortState > 0 ? Colors.green : Colors.grey),
                  tooltip: _priceSortState == 0 ? 'Sort by price: Off' : _priceSortState == 1 ? 'Sort by price: Cheap first' : 'Sort by price: Expensive first',
                  onPressed: () => setState(() {
                    _priceSortState = (_priceSortState + 1) % 3;
                    _logger.d('Price sort state: $_priceSortState');
                  }),
                ),
                if (_priceSortState > 0)
                  Icon(_priceSortState == 1 ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                const SizedBox(width: 24),
                // Vertical divider
                const SizedBox(width: 1, height: 20, child: VerticalDivider()),
                const SizedBox(width: 16),
                // Filter chips
                _FilterChip(label: l10n.allEventsFilter, isSelected: _myFilter == 'all', onSelected: () => setState(() => _myFilter = 'all')),
                const SizedBox(width: 8),
                _FilterChip(label: l10n.myEventsFilter, isSelected: _myFilter == 'created', onSelected: () => setState(() => _myFilter = 'created')),
                const SizedBox(width: 8),
                _FilterChip(label: l10n.participatingFilter, isSelected: _myFilter == 'participating', onSelected: () => setState(() => _myFilter = 'participating')),
                const SizedBox(width: 8),
                _FilterChip(label: l10n.appliedFilter, isSelected: _myFilter == 'applied', onSelected: () => setState(() => _myFilter = 'applied')),
                const SizedBox(width: 8),
                _FilterChip(label: l10n.archivedFilter, isSelected: _myFilter == 'archived', onSelected: () => setState(() => _myFilter = 'archived')),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: max(600, MediaQuery.of(context).size.width / 3)),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(child: Text('${l10n.error}: $_error'))
                  : filtered.isEmpty
                  ? Center(child: Text(l10n.noEventsFound))
                  : ListView.builder(
                      controller: _eventsScrollController,
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
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBody(AppLocalizations l10n, List<Event> filtered) {
    return Row(
      children: [
        SizedBox(
          width: max(200, MediaQuery.of(context).size.width / 6),
          child: Column(
            children: [
              Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(l10n.tagsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView(
                      children: _events
                          .expand((e) => e.tags)
                          .toSet()
                          .map(
                            (tag) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: FilterChip(
                                label: Text(tag),
                                selected: _tagFilters.contains(tag),
                                onSelected: (selected) => setState(() {
                                  if (selected == true) {
                                    _tagFilters.add(tag);
                                    _logger.d('Added tag filter: $tag');
                                  } else {
                                    _tagFilters.remove(tag);
                                    _logger.d('Removed tag filter: $tag');
                                  }
                                }),
                                shape: const StadiumBorder(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Listener(
                onPointerSignal: (signal) {
                  if (signal is PointerScrollEvent) {
                    _eventsScrollController.jumpTo((_eventsScrollController.offset + signal.scrollDelta.dy).clamp(0.0, _eventsScrollController.position.maxScrollExtent));
                  }
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Date sorting
                            IconButton(
                              icon: Icon(Icons.calendar_today, color: _sortDateDesc ? Colors.blue : Colors.grey),
                              tooltip: _sortDateDesc ? 'Sort by date: Newest first' : 'Sort by date: Oldest first',
                              onPressed: () => setState(() => _sortDateDesc = !_sortDateDesc),
                            ),
                            Icon(_sortDateDesc ? Icons.arrow_downward : Icons.arrow_upward, size: 16),
                            const SizedBox(width: 16),
                            // Price sorting
                            IconButton(
                              icon: Icon(Icons.attach_money, color: _priceSortState > 0 ? Colors.green : Colors.grey),
                              tooltip: _priceSortState == 0 ? 'Sort by price: Off' : _priceSortState == 1 ? 'Sort by price: Cheap first' : 'Sort by price: Expensive first',
                              onPressed: () => setState(() {
                                _priceSortState = (_priceSortState + 1) % 3;
                                _logger.d('Price sort state: $_priceSortState');
                              }),
                            ),
                            if (_priceSortState > 0)
                              Icon(_priceSortState == 1 ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                            const SizedBox(width: 24),
                            // Vertical divider
                            const SizedBox(width: 1, height: 20, child: VerticalDivider()),
                            const SizedBox(width: 16),
                            // Filter chips
                            _FilterChip(label: l10n.allEventsFilter, isSelected: _myFilter == 'all', onSelected: () => setState(() => _myFilter = 'all')),
                            const SizedBox(width: 8),
                            _FilterChip(label: l10n.myEventsFilter, isSelected: _myFilter == 'created', onSelected: () => setState(() => _myFilter = 'created')),
                            const SizedBox(width: 8),
                            _FilterChip(label: l10n.participatingFilter, isSelected: _myFilter == 'participating', onSelected: () => setState(() => _myFilter = 'participating')),
                            const SizedBox(width: 8),
                            _FilterChip(label: l10n.appliedFilter, isSelected: _myFilter == 'applied', onSelected: () => setState(() => _myFilter = 'applied')),
                            const SizedBox(width: 8),
                            _FilterChip(label: l10n.archivedFilter, isSelected: _myFilter == 'archived', onSelected: () => setState(() => _myFilter = 'archived')),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: max(600, MediaQuery.of(context).size.width / 3)),
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _error != null
                              ? Center(child: Text('${l10n.error}: $_error'))
                              : filtered.isEmpty
                              ? Center(child: Text(l10n.noEventsFound))
                              : ListView.builder(
                                  controller: _eventsScrollController,
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    )
  }

class _FilterChip extends void StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return FilterChip(label: Text(label), selected: isSelected, onSelected: (_) => onSelected());
  }
}

class _EventCard extends void StatefulWidget {
  final Event event;
  final User? currentUser;
  final Future<void> Function() onChanged;

  const _EventCard({required this.event, required this.currentUser, required this.onChanged});

  @override
  State<_EventCard> createState() => _EventCardState();
}

class _EventCardState extends void State<_EventCard> {
  final EventRepository eventRepository = GetIt.instance<EventRepository>();
  final ApplicationRepository applicationRepository = GetIt.instance<ApplicationRepository>();
  final CreateApplicationUseCase createApplicationUseCase = GetIt.instance<CreateApplicationUseCase>();
  final CancelApplicationUseCase cancelApplicationUseCase = GetIt.instance<CancelApplicationUseCase>();

  bool expanded = false;
  bool actionLoading = false;
  List<Slot> slots0 = [];
  final Set<String> selectedVoteSlots = {};

  bool get isCreator => widget.currentUser?.id == widget.event.creatorId;
  bool get isParticipant => widget.currentUser != null && widget.event.participants.contains(widget.currentUser!.id);
  bool get hasApplication => widget.currentUser != null && widget.event.applicants.contains(widget.currentUser!.id);
  
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    loadSlots();
  }

  Future<void> loadSlots() async {
    if (widget.event.eventType != EventType.voting) return;
    try {
      final slots = await eventRepository.getEventSlots(widget.event.id);
      setState(() => slots0 = slots);
    } catch (_) {
      // consume
    }
  }

  String eventCity(Event event) {
    final mapLink = event.location.mapLink.toLowerCase();
    if (mapLink.contains('55.754') || mapLink.contains('55.755') || mapLink.contains('55.761')) {
      return 'Москва';
    }
    if (mapLink.contains('59.93')) {
      return 'Санкт-Петербург';
    }
    return 'Другой';
  }

  Future<void> toggleParticipation() async {
    if (widget.currentUser == null) return;
    setState(() => actionLoading = true);

    String? message;
    try {
      if (isParticipant || hasApplication) {
        final app = await applicationRepository.getUserApplicationForEvent(userId: widget.currentUser!.id, eventId: widget.event.id);
        if (app != null) {
          await cancelApplicationUseCase.call(CancelApplicationParams(applicationId: app.id));
          message = l10n.applicationCancelled;
        }
      } else {
        final slotIds = widget.event.eventType == EventType.voting ? (selectedVoteSlots.isNotEmpty ? selectedVoteSlots.toList() : slots0.take(1).map((s) => s.id).toList()) : <String>[];
        await createApplicationUseCase.call(CreateApplicationParams(eventId: widget.event.id, userId: widget.currentUser!.id, selectedSlotIds: slotIds));
        message = l10n.applicationSubmitted;
      }
      await widget.onChanged();
    } catch (e) {
      message = '${l10n.errorMessage}: ${e.toString()}';
    } finally {
      setState(() => actionLoading = false);
      if (mounted && message != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$message "${widget.event.title}"')));
      }
    }
  }

  Future<void> openMap() async {
    final url = widget.event.location.mapLink;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.invalidMapUrl)));
      }
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failedOpenMap)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final priceLabel = event.price > 0 ? '${event.price.toStringAsFixed(0)} ₽' : 'Бесплатно';
    final topSlots = slots0..sort((a, b) => b.votes.compareTo(a.votes));

    return Card(
      elevation: 2,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => expanded = !expanded),
              child: Container(
                height: 200,
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
                        Expanded(child: Text(eventCity(event))),
                        IconButton(icon: const Icon(Icons.map), onPressed: openMap),
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
            if (expanded) ...[
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
                                value: selectedVoteSlots.contains(slot.id),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedVoteSlots.add(slot.id);
                                    } else {
                                      selectedVoteSlots.remove(slot.id);
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
                      child: ElevatedButton(onPressed: actionLoading ? null : toggleParticipation, child: Text(isParticipant || hasApplication ? 'Отказаться' : 'Участвовать')),
                    ),
                    if (widget.currentUser != null && isCreator) ...[
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
