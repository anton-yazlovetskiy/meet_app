import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/index.dart';
import '../../domain/repositories/index.dart';
import '../../domain/usecases/index.dart';

class VotingPage extends StatefulWidget {
  final Event event;

  const VotingPage({super.key, required this.event});

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final _eventRepository = GetIt.instance<EventRepository>();
  final _selectFinalSlotUseCase = GetIt.instance<SelectFinalSlotUseCase>();

  late Event _event;
  bool _isLoading = false;
  String? _selectedSlotId;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Голосование за слоты')),
      body: Column(
        children: [
          Expanded(
            child: _event.slotStats.isEmpty
                ? const Center(child: Text('Слоты не созданы'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _event.slotStats.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, slotIndex) {
                      final slot = _event.slotStats[slotIndex];
                      final isSelected = _selectedSlotId == slot.slotId;
                      final isWinning = _event.finalSlotId == slot.slotId;

                      return Card(
                        color: isWinning
                            ? Colors.green.shade50
                            : isSelected
                            ? Colors.blue.shade50
                            : null,
                        child: ListTile(
                          leading: Icon(
                            _event.finalSlotId != null
                                ? Icons.check_circle
                                : isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isWinning
                                ? Colors.green
                                : isSelected
                                ? Colors.blue
                                : null,
                          ),
                          onTap: _event.finalSlotId == null
                              ? () {
                                  setState(() => _selectedSlotId = slot.slotId);
                                }
                              : null,
                          title: Text('Слот ${slotIndex + 1}', style: TextStyle(fontWeight: isWinning ? FontWeight.bold : FontWeight.normal)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${slot.votes} голос(ов) (${slot.voters.length} человек)', style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(value: _event.applicants.isEmpty ? 0 : slot.votes / _event.applicants.length, minHeight: 6),
                              ),
                            ],
                          ),
                          trailing: isWinning
                              ? const Chip(
                                  label: Text('Выбран'),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white),
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      );
                    },
                  ),
          ),
          if (_event.finalSlotId == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(onPressed: _isLoading ? null : _selectFinalSlot, icon: const Icon(Icons.check_circle), label: const Text('Зафиксировать слот')),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Слот выбран!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text('Голосование завершено. Событие переведено в статус "fixed".'),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Закрыть')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
