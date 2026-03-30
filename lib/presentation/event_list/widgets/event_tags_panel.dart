import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class EventTagsPanel extends StatelessWidget {
  final List<String> tags;
  final Set<String> selectedTags;
  final ValueChanged<String> onTagToggle;
  final VoidCallback onReset;

  const EventTagsPanel({
    super.key,
    required this.tags,
    required this.selectedTags,
    required this.onTagToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          ListTile(
            title: Text(
              l10n.tagsLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.resetAll),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                final selected = selectedTags.contains(tag);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => onTagToggle(tag),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
