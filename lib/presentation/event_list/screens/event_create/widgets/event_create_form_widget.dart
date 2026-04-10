import 'package:flutter/material.dart';

import '../../../../../domain/entities/index.dart';
import '../../../../../l10n/app_localizations.dart';

class EventCreateFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isLoading;
  final EventType eventType;
  final bool isPublic;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController tagsController;
  final TextEditingController maxParticipantsController;
  final TextEditingController priceController;
  final String selectedStartDate;
  final String selectedVotingPeriod;
  final String selectedCity;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectVotingPeriod;
  final VoidCallback onSelectCity;
  final ValueChanged<bool> onPublicChanged;
  final ValueChanged<EventType> onEventTypeChanged;
  final VoidCallback onCreate;

  const EventCreateFormWidget({
    super.key,
    required this.formKey,
    required this.isLoading,
    required this.eventType,
    required this.isPublic,
    required this.titleController,
    required this.descriptionController,
    required this.tagsController,
    required this.maxParticipantsController,
    required this.priceController,
    required this.selectedStartDate,
    required this.selectedVotingPeriod,
    required this.selectedCity,
    required this.onSelectStartDate,
    required this.onSelectVotingPeriod,
    required this.onSelectCity,
    required this.onPublicChanged,
    required this.onEventTypeChanged,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: l10n.eventCreateTitleLabel,
              hintText: l10n.eventCreateTitleHint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return l10n.eventCreateTitleRequiredError;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: l10n.eventCreateDescriptionLabel,
              hintText: l10n.eventCreateDescriptionHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return l10n.eventCreateDescriptionRequiredError;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: tagsController,
            decoration: InputDecoration(
              labelText: l10n.eventCreateTagsLabel,
              hintText: l10n.eventCreateTagsHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.eventCreatePublicLabel),
            value: isPublic,
            onChanged: onPublicChanged,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          SegmentedButton<EventType>(
            segments: [
              ButtonSegment(
                label: Text(l10n.eventCreateTypeVoting),
                value: EventType.voting,
              ),
              ButtonSegment(
                label: Text(l10n.eventCreateTypeFixed),
                value: EventType.fixed,
              ),
            ],
            selected: {eventType},
            onSelectionChanged: (Set<EventType> newSelection) {
              onEventTypeChanged(newSelection.first);
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(l10n.startDate),
            subtitle: Text(selectedStartDate),
            trailing: const Icon(Icons.calendar_today),
            onTap: onSelectStartDate,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          if (eventType == EventType.voting)
            ListTile(
              title: Text(l10n.eventCreateVotingPeriodLabel),
              subtitle: Text(selectedVotingPeriod),
              trailing: const Icon(Icons.how_to_vote),
              onTap: onSelectVotingPeriod,
              contentPadding: EdgeInsets.zero,
            ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(l10n.eventCreateCityLabel),
            subtitle: Text(selectedCity),
            trailing: const Icon(Icons.location_city),
            onTap: onSelectCity,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: maxParticipantsController,
            decoration: InputDecoration(
              labelText: l10n.eventCreateMaxParticipantsLabel,
              hintText: l10n.eventCreateMaxParticipantsHint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: priceController,
            decoration: InputDecoration(
              labelText: l10n.eventCreatePriceLabel,
              hintText: '0',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return l10n.eventCreatePriceRequiredError;
              }
              try {
                double.parse(value!);
                return null;
              } catch (_) {
                return l10n.eventCreatePriceInvalidError;
              }
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onCreate,
              child: Text(l10n.createEventPageTitle),
            ),
          ),
        ],
      ),
    );
  }
}
