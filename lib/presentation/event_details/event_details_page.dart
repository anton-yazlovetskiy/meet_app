import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';
import '../voting/voting_page.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late Event _event;
  final _eventRepository = GetIt.instance<EventRepository>();

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _refreshEvent();
  }

  Future<void> _refreshEvent() async {
    try {
      final updated = await _eventRepository.getEventById(_event.id);
      setState(() => _event = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date.toLocal());
  }

  String _formatDateOnly(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_event.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshEvent,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEvent,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildDescriptionSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
            const SizedBox(height: 16),
            _buildDatesSection(),
            const SizedBox(height: 16),
            _buildParticipantsSection(),
            const SizedBox(height: 16),
            _buildSlotsSection(),
            const SizedBox(height: 16),
            _buildTagsSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(_event.status.name.toUpperCase()),
                  backgroundColor: _getStatusColor(_event.status),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                Chip(
                  label: Text(_event.eventType.name.toUpperCase()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Цена', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text('${_event.price} ₽', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Лимит участников', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(_event.maxParticipants?.toString() ?? 'Неограничено', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Описание', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(_event.description),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Локация', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Координаты: ${_event.location.lat.toStringAsFixed(4)}, ${_event.location.lng.toStringAsFixed(4)}'),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.map),
                  label: const Text('Открыть на карте'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Сроки', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Дата начала'),
          subtitle: Text(_formatDate(_event.startLimit)),
          contentPadding: EdgeInsets.zero,
        ),
        ListTile(
          leading: const Icon(Icons.today),
          title: const Text('Создано'),
          subtitle: Text(_formatDate(_event.createdAt)),
          contentPadding: EdgeInsets.zero,
        ),
        if (_event.votingPeriod != null)
          ListTile(
            leading: const Icon(Icons.how_to_vote),
            title: const Text('Период голосования'),
            subtitle: Text(
              '${_formatDateOnly(_event.votingPeriod!.start)} - ${_formatDateOnly(_event.votingPeriod!.end)}',
            ),
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }

  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Участники и заявки', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('${_event.participants.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('участников'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('${_event.applicants.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Text('заявок'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlotsSection() {
    if (_event.slotStats.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Слоты голосования', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...List.generate(
          _event.slotStats.length,
          (index) {
            final slot = _event.slotStats[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Слот ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('${slot.votes} голос(ов)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    LinearProgressIndicator(
                      value: _event.applicants.isEmpty ? 0 : slot.votes / _event.applicants.length,
                      minHeight: 8,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    if (_event.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Теги', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _event.tags.map((tag) => Chip(label: Text(tag))).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_event.eventType == EventType.voting && _event.votingPeriod != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VotingPage(event: _event),
                  ),
                );
              },
              icon: const Icon(Icons.how_to_vote),
              label: const Text('Голосовать'),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.how_to_vote),
              label: const Text('Голосовать'),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Функция подачи заявки в разработке')),
              );
            },
            icon: const Icon(Icons.app_registration),
            label: const Text('Подать заявку'),
          ),
        ),
      ],
    );
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
}
