import 'package:flutter/material.dart';

class VoteTableWidget extends StatefulWidget {
  final List<String> weekdays;

  const VoteTableWidget({super.key, required this.weekdays});

  @override
  State<VoteTableWidget> createState() => _VoteTableWidgetState();
}

class _VoteTableWidgetState extends State<VoteTableWidget> {
  final Set<int> _selectedCells = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            7,
            (index) => Expanded(
              child: Center(
                child: Text(
                  widget.weekdays[index],
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 84,
            itemBuilder: (context, index) {
              final selected = _selectedCells.contains(index);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _selectedCells.remove(index);
                    } else {
                      _selectedCells.add(index);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
