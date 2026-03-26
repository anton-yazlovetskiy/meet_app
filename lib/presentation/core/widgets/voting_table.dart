import 'package:flutter/material.dart';
import 'package:meet_app/domain/entities/index.dart';

class VotingTable extends StatelessWidget {
  final List<SlotStats> slots;
  final List<Application> applicants;
  final Function(String slotId) onSlotSelected;
  final String? selectedSlotId;
  final String? finalSlotId;

  const VotingTable({super.key, required this.slots, required this.applicants, required this.onSlotSelected, this.selectedSlotId, this.finalSlotId});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Таблица голосования', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (slots.isEmpty)
              const Center(child: Text('Слоты не созданы'))
            else
              Table(
                border: TableBorder.all(color: Theme.of(context).dividerColor),
                columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1), 2: FlexColumnWidth(2), 3: FlexColumnWidth(1)},
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Слот', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Голоса', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Участники', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Выбор', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  ...slots.map((slot) {
                    final isSelected = selectedSlotId == slot.slotId;
                    final isWinning = finalSlotId == slot.slotId;

                    return TableRow(
                      decoration: BoxDecoration(
                        color: isWinning
                            ? Colors.green.shade50
                            : isSelected
                            ? Colors.blue.shade50
                            : null,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('Слот ${slots.indexOf(slot) + 1}', style: TextStyle(fontWeight: isWinning ? FontWeight.bold : FontWeight.normal)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text('${slot.votes} (${slot.voters.length} чел.)', style: const TextStyle(fontSize: 12)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: slot.voters.length,
                              itemBuilder: (context, index) {
                                final voterId = slot.voters[index];
                                final voter = applicants.firstWhere(
                                  (app) => app.userId == voterId,
                                  orElse: () => Application(
                                    id: voterId,
                                    eventId: '',
                                    userId: voterId,
                                    selectedSlotIds: [],
                                    status: ApplicationStatus.pending,
                                    updatedAt: DateTime.now(),
                                    createdAt: DateTime.now(),
                                  ),
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Chip(label: Text(voter.userId), backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Checkbox(value: isSelected, onChanged: (value) => onSlotSelected(slot.slotId)),
                              if (isWinning)
                                const Chip(
                                  label: Text('Выбран'),
                                  backgroundColor: Colors.green,
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
