// import 'dart:math';
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:logger/logger.dart';
// import '../../domain/entities/index.dart';
// import '../../domain/repositories/index.dart';
// import '../../l10n/app_localizations.dart';
// import 'event_create_page.dart';

// @RoutePage()
// class EventListPage extends StatelessWidget {
//   const EventListPage({super.key, required this.onOpenSettings, required this.currentLocale, required this.onLocaleChanged, required this.onToggleTheme});

//   final VoidCallback onOpenSettings;
//   final Locale currentLocale;
//   final void Function(Locale locale) onLocaleChanged;
//   final VoidCallback onToggleTheme;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Event List (Заглушка)')),
//       body: ListView.builder(
//         itemCount: 1000,
//         itemBuilder: (context, index) {
//           return Card(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: ListTile(
//               leading: CircleAvatar(child: Text('${index + 1}')),
//               title: Text('Событие #${index + 1}'),
//               subtitle: Text('Описание события #${index + 1}'),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

//   final ScrollController _eventsScrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _cityFilter = _defaultCity();
//     _loadEvents();
//   }

//   String _defaultCity() {
//     return widget.currentLocale.languageCode == 'ru' ? 'Москва' : 'Moscow';
//   }

//   Future<void> _loadUserAppliedEventIds(String userId) async {
//     try {
//       final apps = await _applicationRepository.getUserApplications(userId);
//       setState(() {
//         _userAppliedEventIds = apps.map((a) => a.eventId).toSet();
//       });
//     } catch (_) {
//       setState(() {
//         _userAppliedEventIds = {};
//       });
//     }
//   }

//   String _eventCity(Event event) {
//     final mapLink = event.location.mapLink.toLowerCase();
//     if (mapLink.contains('55.754') || mapLink.contains('55.755') || mapLink.contains('55.761')) {
//       return 'Москва';
//     }
//     if (mapLink.contains('59.93')) {
//       return 'Санкт-Петербург';
//     }
//     return 'Другой';
//   }

//   List<String> _availableCities() {
//     final cities = {'all', ..._events.map(_eventCity)};
//     return cities.toList();
//   }

//   Future<void> _loadEvents() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final user = await _authRepository.getCurrentUser();
//       _currentUser = user;
//       _logger.d('Loaded current user: ${user?.id}');

//       final events = await _eventRepository.listEvents();
//       events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       setState(() => _events = events);
//       _logger.i('Loaded ${events.length} events');

//       if (user != null) {
//         await _loadUserAppliedEventIds(user.id);
//       }
//     } catch (e, stack) {
//       _logger.e('Error loading events: $e', error: e, stackTrace: stack);
//       setState(() => _error = e.toString());
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   List<Event> _getFilteredEvents() {
//     var filtered = _events;

//     if (_cityFilter != 'all') {
//       filtered = filtered.where((e) => _eventCity(e) == _cityFilter).toList();
//     }

//     if (_tagFilters.isNotEmpty) {
//       filtered = filtered.where((e) => e.tags.any((tag) => _tagFilters.contains(tag))).toList();
//     }

//     if (_searchQuery.isNotEmpty) {
//       final query = _searchQuery.toLowerCase();
//       filtered = filtered.where((e) {
//         return e.title.toLowerCase().contains(query) || e.description.toLowerCase().contains(query) || e.tags.any((tag) => tag.toLowerCase().contains(query));
//       }).toList();
//     }

//     switch (_myFilter) {
//       case 'created':
//         filtered = filtered.where((e) => _currentUser != null && e.creatorId == _currentUser!.id).toList();
//         break;
//       case 'participating':
//         filtered = filtered.where((e) => _currentUser != null && e.participants.contains(_currentUser!.id)).toList();
//         break;
//       case 'applied':
//         filtered = filtered.where((e) => _userAppliedEventIds.contains(e.id)).toList();
//         break;
//       case 'archived':
//         filtered = filtered.where((e) => e.status == EventStatus.archived || e.isArchived).toList();
//         break;
//       case 'all':
//       default:
//         break;
//     }

//     if (_sortDateDesc) {
//       filtered.sort((a, b) => b.startLimit.compareTo(a.startLimit));
//     } else {
//       filtered.sort((a, b) => a.startLimit.compareTo(b.startLimit));
//     }

//     // Then sort by price if needed
//     if (_priceSortState > 0) {
//       filtered.sort((a, b) {
//         int dateComp = _sortDateDesc ? b.startLimit.compareTo(a.startLimit) : a.startLimit.compareTo(b.startLimit);
//         if (dateComp != 0) return dateComp;
//         // 1: cheap first (asc), 2: expensive first (desc)
//         return _priceSortState == 1 ? a.price.compareTo(b.price) : b.price.compareTo(a.price);
//       });
//     }

//     return filtered;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final l10n = AppLocalizations.of(context)!;
//     final filtered = _getFilteredEvents();
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final gradient = isDark
//         ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.black, Colors.indigo, Colors.black], stops: [0.1, 0.9, 1.0])
//         : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Colors.white, Colors.white], stops: [0.0, 0.5, 1.0]);

//     return Scaffold(
//       appBar: AppBar(
//         leading: const Icon(Icons.pets), // cat icon
//         title: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: l10n.searchEventsInYourCity,
//                   prefixIcon: const Icon(Icons.search),
//                   border: InputBorder.none, // borderless
//                 ),
//                 onChanged: (value) => setState(() => _searchQuery = value),
//               ),
//             ),
//             const SizedBox(width: 8),
//             DropdownButton<String>(
//               value: _cityFilter,
//               items: _availableCities().map((city) {
//                 return DropdownMenuItem(value: city, child: Text(city == 'all' ? l10n.allEventsFilter : city));
//               }).toList(),
//               onChanged: (value) {
//                 if (value != null) setState(() => _cityFilter = value);
//               },
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode), onPressed: widget.onToggleTheme),
//           PopupMenuButton<String>(
//             child: Text(widget.currentLocale.languageCode.toUpperCase()),
//             onSelected: (value) {
//               widget.onLocaleChanged(Locale(value));
//             },
//             itemBuilder: (context) => [const PopupMenuItem(value: 'ru', child: Text('Русский')), const PopupMenuItem(value: 'en', child: Text('English'))],
//           ),
//           IconButton(icon: const Icon(Icons.notifications), onPressed: () {}), // placeholder
//           IconButton(icon: const Icon(Icons.person), onPressed: widget.onOpenSettings), // profile
//         ],
//       ),
//       drawer: Drawer(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: Text(l10n.tagsLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             Expanded(
//               child: ListView(
//                 children: _events
//                     .expand((e) => e.tags)
//                     .toSet()
//                     .map(
//                       (tag) => Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         child: FilterChip(
//                           label: Text(tag),
//                           selected: _tagFilters.contains(tag),
//                           onSelected: (selected) => setState(() {
//                             if (selected == true) {
//                               _tagFilters.add(tag);
//                               _logger.d('Added tag filter: $tag');
//                             } else {
//                               _tagFilters.remove(tag);
//                               _logger.d('Removed tag filter: $tag');
//                             }
//                           }),
//                           shape: const StadiumBorder(),
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Container(decoration: BoxDecoration(gradient: gradient)),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _isLoading
//             ? null
//             : () {
//                 Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventCreatePage())).then((_) => _loadEvents());
//               },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildMobileBody(AppLocalizations l10n, List<Event> filtered) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 // Date sorting
//                 IconButton(
//                   icon: Icon(Icons.calendar_today, color: _sortDateDesc ? Colors.blue : Colors.grey),
//                   tooltip: _sortDateDesc ? 'Sort by date: Newest first' : 'Sort by date: Oldest first',
//                   onPressed: () => setState(() => _sortDateDesc = !_sortDateDesc),
//                 ),
//                 Icon(_sortDateDesc ? Icons.arrow_downward : Icons.arrow_upward, size: 16),
//                 const SizedBox(width: 16),
//                 // Price sorting
//                 IconButton(
//                   icon: Icon(Icons.attach_money, color: _priceSortState > 0 ? Colors.green : Colors.grey),
//                   tooltip: _priceSortState == 0
//                       ? 'Sort by price: Off'
//                       : _priceSortState == 1
//                       ? 'Sort by price: Cheap first'
//                       : 'Sort by price: Expensive first',
//                   onPressed: () => setState(() {
//                     _priceSortState = (_priceSortState + 1) % 3;
//                     _logger.d('Price sort state: $_priceSortState');
//                   }),
//                 ),
//                 if (_priceSortState > 0) Icon(_priceSortState == 1 ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
//                 const SizedBox(width: 24),
//                 // Vertical divider
//                 const SizedBox(width: 1, height: 20, child: VerticalDivider()),
//                 const SizedBox(width: 16),
//                 // // Filter chips
//                 // _FilterChip(label: l10n.allEventsFilter, isSelected: _myFilter == 'all', onSelected: () => setState(() => _myFilter = 'all')),
//                 // const SizedBox(width: 8),
//                 // _FilterChip(label: l10n.myEventsFilter, isSelected: _myFilter == 'created', onSelected: () => setState(() => _myFilter = 'created')),
//                 // const SizedBox(width: 8),
//                 // _FilterChip(label: l10n.participatingFilter, isSelected: _myFilter == 'participating', onSelected: () => setState(() => _myFilter = 'participating')),
//                 // const SizedBox(width: 8),
//                 // _FilterChip(label: l10n.appliedFilter, isSelected: _myFilter == 'applied', onSelected: () => setState(() => _myFilter = 'applied')),
//                 // const SizedBox(width: 8),
//                 // _FilterChip(label: l10n.archivedFilter, isSelected: _myFilter == 'archived', onSelected: () => setState(() => _myFilter = 'archived')),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           child: Center(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(maxWidth: max(600, MediaQuery.of(context).size.width / 3)),
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _error != null
//                   ? Center(child: Text('${l10n.error}: $_error'))
//                   : filtered.isEmpty
//                   ? Center(child: Text(l10n.noEventsFound))
//                   : ListView.builder(
//                       controller: _eventsScrollController,
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                       itemCount: filtered.length,
//                       itemBuilder: (context, index) {
//                         final event = filtered[index];
//                         return Padding(padding: const EdgeInsets.only(bottom: 12));
//                       },
//                     ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDesktopBody(AppLocalizations l10n, List<Event> filtered) {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 // Date sorting
//                 IconButton(
//                   icon: Icon(Icons.calendar_today, color: _sortDateDesc ? Colors.blue : Colors.grey),
//                   tooltip: _sortDateDesc ? 'Sort by date: Newest first' : 'Sort by date: Oldest first',
//                   onPressed: () => setState(() => _sortDateDesc = !_sortDateDesc),
//                 ),
//                 Icon(_sortDateDesc ? Icons.arrow_downward : Icons.arrow_upward, size: 16),
//                 const SizedBox(width: 16),
//                 // Price sorting
//                 IconButton(
//                   icon: Icon(Icons.attach_money, color: _priceSortState > 0 ? Colors.green : Colors.grey),
//                   tooltip: _priceSortState == 0
//                       ? 'Sort by price: Off'
//                       : _priceSortState == 1
//                       ? 'Sort by price: Cheap first'
//                       : 'Sort by price: Expensive first',
//                   onPressed: () => setState(() {
//                     _priceSortState = (_priceSortState + 1) % 3;
//                     _logger.d('Price sort state: $_priceSortState');
//                   }),
//                 ),
//                 if (_priceSortState > 0) Icon(_priceSortState == 1 ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
//                 const SizedBox(width: 24),
//                 // Vertical divider
//                 const SizedBox(width: 1, height: 20, child: VerticalDivider()),
//                 const SizedBox(width: 16),
//                 // // Filter chips
//                 // _FilterChip(label: l10n.allEventsFilter, isSelected: _myFilter == 'all', onSelected: () => setState(() => _myFilter = 'all')),
//                 // const SizedBox(width: 8),
//                 // _FilterChip(label: l10n.myEventsFilter, isSelected: _myFilter == 'created', onSelected: () => setState(() => _myFilter = 'created')),
//                 // const SizedBox(width: 8),
//                 // _FilterChip(label: l10n.participatingFilter, isSelected: _myFilter == 'participating', onSelected: () => setState(() => _myFilter = 'participating')),
//                 // const SizedBox(width: 8),
// // ...existing code...
