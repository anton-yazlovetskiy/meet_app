import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/presentation/core/widgets/voting_table.dart';
import 'package:meet_app/presentation/core/widgets/voting_carousel.dart';
import 'package:meet_app/domain/entities/index.dart';
import 'package:meet_app/domain/repositories/index.dart';
import 'package:meet_app/domain/usecases/index.dart';
import 'package:get_it/get_it.dart';

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onOpenChat;
  final VoidCallback? onOpenExpenses;
  final VoidCallback? onOpenVoting;
  final bool isManager;
  final bool isVotingEnabled;

  const EventCard({super.key, required this.event, this.onEdit, this.onDelete, this.onOpenChat, this.onOpenExpenses, this.onOpenVoting, this.isManager = false, this.isVotingEnabled = true});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final _eventRepository = GetIt.instance<EventRepository>();
  final _createApplicationUseCase = GetIt.instance<CreateApplicationUseCase>();
  final _cancelApplicationUseCase = GetIt.instance<CancelApplicationUseCase>();
  final _selectFinalSlotUseCase = GetIt.instance<SelectFinalSlotUseCase>();

  late Event _event;
  bool _isLoading = false;
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
  }

  Future<void> _applyForEvent() async {
    setState(() => _isLoading = true);

    try {
      await _createApplicationUseCase(CreateApplicationParams(eventId: _event.id, userId: 'user_1', selectedSlotIds: []));

      final updated = await _eventRepository.getEventById(_event.id);
      setState(() => _event = updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Вы подали заявку на мероприятие')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _cancelApplication() async {
    setState(() => _isLoading = true);

    try {
      await _cancelApplicationUseCase(CancelApplicationParams(applicationId: 'app_1'));

      final updated = await _eventRepository.getEventById(_event.id);
      setState(() => _event = updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Вы отменили заявку на мероприятие')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectFinalSlot() async {
    if (_selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите слот')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _selectFinalSlotUseCase(SelectFinalSlotParams(eventId: _event.id, slotId: _selectedSlotId!, managerId: 'user_1'));

      final updated = await _eventRepository.getEventById(_event.id);
      setState(() => _event = updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Слот выбран успешно!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool get _isApplied => _event.applicants.any((app) => app == 'user_1');
  bool get _isManager => _event.managers.contains('user_1');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок и действия
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_event.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_event.description, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                if (widget.isManager)
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit), tooltip: l10n.edit, onPressed: widget.onEdit),
                      IconButton(icon: const Icon(Icons.delete), tooltip: l10n.delete, onPressed: widget.onDelete),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Информация о мероприятии
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l10n.eventStatus}: ${_event.status.name}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      Text('${l10n.eventType}: ${_event.eventType.name}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      Text('${l10n.participants}: ${_event.applicants.length}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${l10n.startDate}: ${_event.startLimit.toIso8601String()}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                    Text('${l10n.endDate}: ${_event.startLimit.toIso8601String()}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Теги
            if (_event.tags.isNotEmpty) Wrap(spacing: 8, runSpacing: 4, children: _event.tags.map((tag) => Chip(label: Text(tag))).toList()),

            const SizedBox(height: 16),

            // Кнопки действий
            Row(
              children: [
                if (_event.status == EventStatus.planned)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : (_isApplied ? _cancelApplication : _applyForEvent),
                      child: Text(_isApplied ? l10n.applicationCancelled : l10n.applicationSubmitted),
                    ),
                  ),
                const SizedBox(width: 8),
                if (widget.onOpenChat != null) IconButton(icon: const Icon(Icons.chat), tooltip: 'Чат', onPressed: widget.onOpenChat),
                if (widget.onOpenExpenses != null) IconButton(icon: const Icon(Icons.attach_money), tooltip: 'Расходы', onPressed: widget.onOpenExpenses),
                if (widget.onOpenVoting != null && _event.status == EventStatus.active) IconButton(icon: const Icon(Icons.poll), tooltip: l10n.votingPageTitle, onPressed: widget.onOpenVoting),
              ],
            ),

            // Голосование за слоты
            if (_event.status == EventStatus.active && widget.isVotingEnabled)
              Column(
                children: [
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(l10n.votingPageTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Таблица голосования
                  VotingTable(
                    slots: _event.slotStats,
                    applicants: [],
                    onSlotSelected: (slotId) {
                      setState(() => _selectedSlotId = slotId);
                    },
                    selectedSlotId: _selectedSlotId,
                    finalSlotId: _event.finalSlotId,
                  ),

                  const SizedBox(height: 16),

                  // Карусель голосования
                  VotingCarousel(
                    slots: _event.slotStats,
                    applicants: [],
                    onSlotSelected: (slotId) {
                      setState(() => _selectedSlotId = slotId);
                    },
                    selectedSlotId: _selectedSlotId,
                    finalSlotId: _event.finalSlotId,
                  ),

                  const SizedBox(height: 16),

                  // Кнопка выбора слота
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(onPressed: _isLoading ? null : _selectFinalSlot, icon: const Icon(Icons.check_circle), label: Text(l10n.votingPageTitle)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
