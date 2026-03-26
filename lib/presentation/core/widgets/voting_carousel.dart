import 'package:flutter/material.dart';
import 'package:meet_app/domain/entities/index.dart';

class VotingCarousel extends StatelessWidget {
  final List<SlotStats> slots;
  final List<Application> applicants;
  final Function(String slotId) onSlotSelected;
  final String? selectedSlotId;
  final String? finalSlotId;

  const VotingCarousel({super.key, required this.slots, required this.applicants, required this.onSlotSelected, this.selectedSlotId, this.finalSlotId});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Карусель голосования', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (slots.isEmpty)
              const Center(child: Text('Слоты не созданы'))
            else
              SizedBox(
                height: 160,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    final slot = slots[index];
                    final isSelected = selectedSlotId == slot.slotId;
                    final isWinning = finalSlotId == slot.slotId;

                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isWinning
                            ? Colors.green.shade50
                            : isSelected
                            ? Colors.blue.shade50
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isWinning
                              ? Colors.green
                              : isSelected
                              ? Colors.blue
                              : Theme.of(context).dividerColor,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Слот ${index + 1}', style: TextStyle(fontWeight: isWinning ? FontWeight.bold : FontWeight.normal)),
                                const Spacer(),
                                Checkbox(value: isSelected, onChanged: (value) => onSlotSelected(slot.slotId)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${slot.votes} голосов', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(value: applicants.isEmpty ? 0 : slot.votes / applicants.length, minHeight: 6, backgroundColor: Theme.of(context).dividerColor),
                            ),
                            const SizedBox(height: 8),
                            Text('Участники:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: slot.voters.map((voterId) {
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
                                return Chip(label: Text(voter.userId), backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2), padding: EdgeInsets.zero);
                              }).toList(),
                            ),
                            if (isWinning) const Spacer(),
                            if (isWinning)
                              const Chip(
                                label: Text('Выбран'),
                                backgroundColor: Colors.green,
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
