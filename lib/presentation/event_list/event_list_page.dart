import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';
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

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'all'; // all, planned, active, fixed

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final events = await _eventRepository.listEvents();
      events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() => _events = events);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Event> _getFilteredEvents() {
    if (_filterStatus == 'all') return _events;
    return _events.where((e) => e.status.name == _filterStatus).toList();
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
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final event = filtered[index];
                      return _EventListTile(
                        event: event,
                        statusColor: _getStatusColor(event.status),
                        formatDate: _formatDate,
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventDetailsPage(event: event)));
                          _loadEvents();
                        },
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

class _EventListTile extends StatelessWidget {
  final Event event;
  final Color statusColor;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  const _EventListTile({required this.event, required this.statusColor, required this.formatDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(width: 4, color: statusColor),
      title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.description, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Chip(label: Text(event.status.name), visualDensity: VisualDensity.compact),
              const SizedBox(width: 8),
              Chip(label: Text(event.eventType.name), visualDensity: VisualDensity.compact),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${event.participants.length} участников', style: const TextStyle(fontSize: 12)),
          Text(formatDate(event.startLimit), style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
      onTap: onTap,
    );
  }
}
