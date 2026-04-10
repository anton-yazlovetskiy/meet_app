import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/widgets/language_switcher.dart';

class EventListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final bool isMobile;
  final bool isDarkTheme;
  final Locale locale;
  final List<String> cityItems;
  final String selectedCity;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCitySelected;
  final VoidCallback onToggleTheme;
  final ValueChanged<Locale> onLocaleChanged;
  final VoidCallback onOpenDrawer;

  const EventListAppBar({
    super.key,
    required this.searchController,
    required this.isMobile,
    required this.isDarkTheme,
    required this.locale,
    required this.cityItems,
    required this.selectedCity,
    required this.onSearchChanged,
    required this.onCitySelected,
    required this.onToggleTheme,
    required this.onLocaleChanged,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      titleSpacing: 8,
      leading: IconButton(
        onPressed: isMobile ? onOpenDrawer : null,
        icon: const Icon(Icons.pets),
        tooltip: isMobile ? l10n.tagsTooltip : l10n.appTitle,
      ),
      title: SizedBox(
        height: 44,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.eventSearchHint,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 180,
              child: DropdownMenu<String>(
                width: 180,
                expandedInsets: EdgeInsets.zero,
                initialSelection: selectedCity,
                enableFilter: true,
                requestFocusOnTap: true,
                menuHeight: 320,
                leadingIcon: const Icon(Icons.location_city, size: 16),
                textStyle: Theme.of(context).textTheme.labelMedium,
                hintText: l10n.cityPlaceholder,
                dropdownMenuEntries: [
                  DropdownMenuEntry<String>(
                    value: '',
                    label: l10n.cityPlaceholder,
                  ),
                  ...cityItems.map(
                    (city) => DropdownMenuEntry<String>(
                      value: city,
                      label: city,
                    ),
                  ),
                ],
                onSelected: onCitySelected,
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: onToggleTheme,
          icon: Icon(isDarkTheme ? Icons.light_mode : Icons.dark_mode),
          tooltip: l10n.themeLabel,
        ),
        LanguageSwitcher(
          value: locale,
          onChanged: onLocaleChanged,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
          tooltip: l10n.notificationsLabel,
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.account_circle_outlined),
          tooltip: l10n.profileLabel,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
