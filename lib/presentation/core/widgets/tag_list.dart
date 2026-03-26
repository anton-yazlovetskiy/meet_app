import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';

class TagList extends StatefulWidget {
  final List<String> selectedTags;
  final List<String> allTags;
  final Function(List<String>) onTagsChanged;
  final bool isEditable;

  const TagList({super.key, required this.selectedTags, required this.allTags, required this.onTagsChanged, this.isEditable = true});

  @override
  State<TagList> createState() => _TagListState();
}

class _TagListState extends State<TagList> {
  late List<String> _selectedTags;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.selectedTags);
  }

  @override
  void didUpdateWidget(covariant TagList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTags != widget.selectedTags) {
      _selectedTags = List.from(widget.selectedTags);
    }
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      widget.onTagsChanged(_selectedTags);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isEditable) Text(l10n.tagsLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.allTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: widget.isEditable ? (bool selected) => _toggleTag(tag) : null,
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
