import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../models/event_feed_item.dart';
import '../models/event_list_filter.dart';

enum EventListStatus { initial, loading, success, failure }

class EventListState extends Equatable {
  final EventListStatus status;
  final List<EventFeedItem> sourceItems;
  final List<EventFeedItem> visibleItems;
  final Set<String> selectedTags;
  final String searchQuery;
  final String? selectedCity;
  final bool hasManualCitySelection;
  final EventListScopeFilter scopeFilter;
  final EventListDateSort dateSort;
  final EventListPriceSort priceSort;
  final List<String> availableTags;
  final List<String> availableCities;
  final String? currentUserId;
  final Locale locale;
  final bool isDarkTheme;
  final String? snackbarMessage;
  final int snackbarVersion;
  final String? errorMessage;

  const EventListState({
    required this.status,
    required this.sourceItems,
    required this.visibleItems,
    required this.selectedTags,
    required this.searchQuery,
    required this.selectedCity,
    required this.hasManualCitySelection,
    required this.scopeFilter,
    required this.dateSort,
    required this.priceSort,
    required this.availableTags,
    required this.availableCities,
    required this.currentUserId,
    required this.locale,
    required this.isDarkTheme,
    required this.snackbarMessage,
    required this.snackbarVersion,
    required this.errorMessage,
  });

  const EventListState.initial()
    : status = EventListStatus.initial,
      sourceItems = const [],
      visibleItems = const [],
      selectedTags = const <String>{},
      searchQuery = '',
      selectedCity = null,
      hasManualCitySelection = false,
      scopeFilter = EventListScopeFilter.all,
      dateSort = EventListDateSort.newestFirst,
      priceSort = EventListPriceSort.none,
      availableTags = const [],
      availableCities = const [],
      currentUserId = null,
      locale = const Locale('ru'),
      isDarkTheme = true,
      snackbarMessage = null,
      snackbarVersion = 0,
      errorMessage = null;

  EventListState copyWith({
    EventListStatus? status,
    List<EventFeedItem>? sourceItems,
    List<EventFeedItem>? visibleItems,
    Set<String>? selectedTags,
    String? searchQuery,
    Object? selectedCity = _unset,
    bool? hasManualCitySelection,
    EventListScopeFilter? scopeFilter,
    EventListDateSort? dateSort,
    EventListPriceSort? priceSort,
    List<String>? availableTags,
    List<String>? availableCities,
    Object? currentUserId = _unset,
    Locale? locale,
    bool? isDarkTheme,
    Object? snackbarMessage = _unset,
    int? snackbarVersion,
    Object? errorMessage = _unset,
  }) {
    return EventListState(
      status: status ?? this.status,
      sourceItems: sourceItems ?? this.sourceItems,
      visibleItems: visibleItems ?? this.visibleItems,
      selectedTags: selectedTags ?? this.selectedTags,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCity: selectedCity == _unset
          ? this.selectedCity
          : selectedCity as String?,
      hasManualCitySelection:
          hasManualCitySelection ?? this.hasManualCitySelection,
      scopeFilter: scopeFilter ?? this.scopeFilter,
      dateSort: dateSort ?? this.dateSort,
      priceSort: priceSort ?? this.priceSort,
      availableTags: availableTags ?? this.availableTags,
      availableCities: availableCities ?? this.availableCities,
      currentUserId: currentUserId == _unset
          ? this.currentUserId
          : currentUserId as String?,
      locale: locale ?? this.locale,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      snackbarMessage: snackbarMessage == _unset
          ? this.snackbarMessage
          : snackbarMessage as String?,
      snackbarVersion: snackbarVersion ?? this.snackbarVersion,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sourceItems,
    visibleItems,
    selectedTags,
    searchQuery,
    selectedCity,
    hasManualCitySelection,
    scopeFilter,
    dateSort,
    priceSort,
    availableTags,
    availableCities,
    currentUserId,
    locale,
    isDarkTheme,
    snackbarMessage,
    snackbarVersion,
    errorMessage,
  ];
}

const _unset = Object();
