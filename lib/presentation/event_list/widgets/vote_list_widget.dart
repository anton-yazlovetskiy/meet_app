import 'package:flutter/material.dart';

class VoteListWidget extends StatefulWidget {
  final String dayLabel;

  const VoteListWidget({super.key, required this.dayLabel});

  @override
  State<VoteListWidget> createState() => _VoteListWidgetState();
}

class _VoteListWidgetState extends State<VoteListWidget> {
  int _selectedDay = 0;
  final Set<int> _selectedSlots = {};

  @override
  Widget build(BuildContext context) {
    final days = List.generate(14, (i) => '${widget.dayLabel} ${i + 1}');
    return SizedBox(
      height: 240,
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: ListView.separated(
              itemCount: days.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final active = index == _selectedDay;
                return InkWell(
                  onTap: () => setState(() => _selectedDay = index),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: active
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    ),
                    child: Text(days[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ListView.separated(
              itemCount: 12,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final key = _selectedDay * 100 + index;
                final selected = _selectedSlots.contains(key);
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  tileColor: selected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  title: Text('${8 + index}:00'),
                  trailing: Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                  ),
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedSlots.remove(key);
                      } else {
                        _selectedSlots.add(key);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
