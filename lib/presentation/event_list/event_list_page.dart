import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/widgets/language_switcher.dart';
import 'models/event_feed_item.dart';
import 'widgets/event_feed_card.dart';

@RoutePage()
class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

enum _SidePanelType { chat, participants }

enum _FeedFilter { all, mine, participating, applied, archived }

enum _DateOrder { newestFirst, oldestFirst }

class _ChatMessage {
  final String userName;
  final String text;
  final double rating;
  final bool isMine;

  const _ChatMessage({
    required this.userName,
    required this.text,
    required this.rating,
    required this.isMine,
  });
}

class _EventListPageState extends State<EventListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _chatInputController = TextEditingController();
  final ScrollController _feedScrollController = ScrollController();
  final List<_ChatMessage> _chatMessages = [
    const _ChatMessage(
      userName: 'Иван',
      text: 'Предлагаю слот во вторник 19:00',
      rating: 4.4,
      isMine: true,
    ),
    const _ChatMessage(
      userName: 'Мария',
      text: 'Мне удобнее в пятницу после 20:00',
      rating: 4.9,
      isMine: false,
    ),
  ];

  late final List<EventFeedItem> _events;
  int _visibleCount = 40;
  String _feedCacheKey = '';
  List<EventFeedItem> _cachedFeed = const [];

  Locale _currentLocale = const Locale('ru');
  bool _darkTheme = false;
  String _selectedCity = 'Город не выбран';
  final Set<String> _selectedTags = {};
  _FeedFilter _selectedFilter = _FeedFilter.all;
  _DateOrder _dateOrder = _DateOrder.newestFirst;
  SortArrowState _priceSort = SortArrowState.none;

  _SidePanelType? _sidePanelType;
  EventFeedItem? _activeEvent;
  bool _panelHeaderCollapsed = false;

  static const double _tagsPanelWidth = 190;

  final List<String> _cities = const [
    'Город не выбран',
    'Москва',
    'Санкт-Петербург',
    'Казань',
    'Екатеринбург',
    'Новосибирск',
  ];

  final List<String> _allTags = const [
    'Спорт',
    'Еда',
    'Путешествия',
    'Кино',
    'Настолки',
    'Концерты',
    'Прогулки',
    'Нетворкинг',
    'Технологии',
    'Образование',
    'Йога',
    'Бег',
    'Велосипед',
    'Плавание',
    'Музеи',
    'Театр',
    'Стартапы',
    'Коворкинг',
    'Языки',
    'Пикник',
    'Горы',
    'Туризм',
    'Искусство',
    'Кулинария',
    'Кофе',
    'Книги',
    'Гейминг',
    'Фотопрогулки',
    'Маркет',
    'Танцы',
  ];

  @override
  void initState() {
    super.initState();
    _events = _buildMockEvents();
  }

  Future<void> _toggleThemeAsync() async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    setState(() => _darkTheme = !_darkTheme);
  }

  Future<void> _setLocaleAsync(Locale value) async {
    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;
    setState(() => _currentLocale = value);
  }

  void _resetVisibleCount() {
    _visibleCount = 40;
  }

  void _tryLoadMore(double pixels, double maxPixels, int totalCount) {
    if (_visibleCount >= totalCount) return;
    if (maxPixels - pixels < 600) {
      setState(() {
        _visibleCount += 30;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chatInputController.dispose();
    _feedScrollController.dispose();
    super.dispose();
  }

  void _handleWheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (!_feedScrollController.hasClients) return;
    final target = (_feedScrollController.offset + event.scrollDelta.dy).clamp(
      _feedScrollController.position.minScrollExtent,
      _feedScrollController.position.maxScrollExtent,
    );
    _feedScrollController.jumpTo(target);
  }

  void _closePanel({bool compact = false}) {
    setState(() {
      _activeEvent = null;
      _sidePanelType = null;
      _panelHeaderCollapsed = false;
    });
    if (compact) {
      Navigator.of(context).maybePop();
    }
  }

  void _sendChatMessage() {
    final text = _chatInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _chatMessages.add(
        _ChatMessage(
          userName: 'Вы',
          text: text,
          rating: 4.7,
          isMine: true,
        ),
      );
      _chatInputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1100;

    return Localizations.override(
      context: context,
      locale: _currentLocale,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final theme = _darkTheme ? _buildDarkTheme() : _buildLightTheme();

          return Theme(
            data: theme,
            child: Scaffold(
              key: _scaffoldKey,
              backgroundColor: theme.colorScheme.surface,
              drawer: isMobile
                  ? Drawer(child: _buildTagsPanel(context, l10n))
                  : null,
              endDrawer: isMobile && _sidePanelType != null
                  ? Drawer(child: _buildSidePanel(context, l10n, compact: true))
                  : null,
              appBar: _buildAppBar(context, l10n, isMobile),
              body: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _darkTheme
                        ? const [
                            Color(0xFF0E152A),
                            Color(0xFF141F3D),
                            Color(0xFF101935),
                          ]
                        : const [
                            Color(0xFFF9FBFE),
                            Color(0xFFF5F8FC),
                            Color(0xFFF8FAFD),
                          ],
                  ),
                ),
                child: isMobile
                    ? _buildMobileLayout(context, l10n)
                    : _buildDesktopLayout(context, l10n),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
    bool isMobile,
  ) {
    return AppBar(
      elevation: 1,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      backgroundColor: _darkTheme
          ? const Color(0xFF18233C)
          : Theme.of(context).colorScheme.surface,
      titleSpacing: 12,
      title: Row(
        children: [
          const Icon(Icons.pets_rounded),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(_resetVisibleCount),
              decoration: InputDecoration(
                hintText: l10n.eventSearchHint,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildCityDropdown(context, l10n),
        ],
      ),
      actions: [
        if (isMobile)
          IconButton(
            tooltip: l10n.tagsTooltip,
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.label_outline),
          ),
        LanguageSwitcher(
          value: _currentLocale,
          onChanged: _setLocaleAsync,
        ),
        IconButton(
          tooltip: l10n.themeLabel,
          onPressed: _toggleThemeAsync,
          icon: Icon(_darkTheme ? Icons.dark_mode : Icons.light_mode),
        ),
        IconButton(
          tooltip: l10n.notificationsLabel,
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
        ),
        IconButton(
          tooltip: l10n.profileLabel,
          onPressed: () {},
          icon: const Icon(Icons.person_outline),
        ),
      ],
    );
  }

  Widget _buildCityDropdown(BuildContext context, AppLocalizations l10n) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _darkTheme
            ? const Color(0xFF202B45)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCity,
            items: _cities
                .map(
                  (city) => DropdownMenuItem(
                    value: city,
                    child: Text(
                      city == 'Город не выбран' ? l10n.cityPlaceholder : city,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _selectedCity = value;
                _sidePanelType = null;
                _activeEvent = null;
                _resetVisibleCount();
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AppLocalizations l10n) {
    final hasPanel = _activeEvent != null && _sidePanelType != null;

    return Row(
      children: [
        SizedBox(width: _tagsPanelWidth, child: _buildTagsPanel(context, l10n)),
        Expanded(
          child: Listener(
            onPointerSignal: _handleWheel,
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final total = constraints.maxWidth;
                  final gap = hasPanel ? 14.0 : 0.0;
                  final panelWidth = hasPanel ? (total - gap) / 2 : 0.0;
                  final middleWidth = hasPanel ? (total - gap) / 2 : total;
                  final middleMaxWhenNoPanel = total * 0.44;

                  return Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutCubic,
                        width: middleWidth,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: hasPanel
                                ? middleWidth
                                : middleMaxWhenNoPanel,
                            child: _buildMiddleColumn(context, l10n),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutCubic,
                        width: gap,
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutCubic,
                        width: panelWidth,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 120),
                          opacity: hasPanel ? 1 : 0,
                          child: IgnorePointer(
                            ignoring: !hasPanel,
                            child: _buildSidePanel(context, l10n),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _buildFilterSortRow(context, l10n, isMobile: true),
        const Divider(height: 1),
        Expanded(child: _buildFeedList(context, l10n, isMobile: true)),
      ],
    );
  }

  Widget _buildMiddleColumn(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _buildFilterSortRow(context, l10n),
        const Divider(height: 1),
        Expanded(child: _buildFeedList(context, l10n)),
      ],
    );
  }

  Widget _buildTagsPanel(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: _darkTheme
            ? const Color(0xFF1A2540).withValues(alpha: 0.92)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.82),
      ),
      child: Column(
        children: [
          Center(
            child: TextButton(
              onPressed: () => setState(_selectedTags.clear),
              child: Text(l10n.resetAll),
            ),
          ),
          const SizedBox(height: 6),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allTags
                    .map(
                      (tag) => FilterChip(
                        label: Text(tag),
                        selected: _selectedTags.contains(tag),
                        shape: const StadiumBorder(),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                            _resetVisibleCount();
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortRow(
    BuildContext context,
    AppLocalizations l10n, {
    bool isMobile = false,
  }) {
    final filterConfig = [
      (_FeedFilter.all, l10n.filterAllSimple, Colors.grey),
      (_FeedFilter.mine, l10n.filterMine, const Color(0xFFD95A66)),
      (
        _FeedFilter.participating,
        l10n.filterParticipating,
        const Color(0xFF42A86A),
      ),
      (_FeedFilter.applied, l10n.filterAppliedSimple, const Color(0xFF4E88E7)),
      (_FeedFilter.archived, l10n.filterArchive, const Color(0xFF7E8698)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _SortIconButton(
              icon: Icons.calendar_month_outlined,
              state: _dateOrder == _DateOrder.newestFirst
                  ? SortArrowState.down
                  : SortArrowState.up,
              tooltip: l10n.sortDate,
              onTap: () {
                setState(() {
                  _dateOrder = _dateOrder == _DateOrder.newestFirst
                      ? _DateOrder.oldestFirst
                      : _DateOrder.newestFirst;
                });
              },
            ),
            _SortIconButton(
              icon: Icons.currency_ruble,
              state: _priceSort,
              tooltip: l10n.sortPrice,
              onTap: () =>
                  setState(() => _priceSort = _nextPriceSort(_priceSort)),
            ),
            ...filterConfig.map((item) {
              final selected = _selectedFilter == item.$1;
              return ChoiceChip(
                label: Text(item.$2),
                selected: selected,
                shape: const StadiumBorder(),
                side: BorderSide(
                  color: item.$3.withValues(alpha: 0.9),
                  width: 1.1,
                ),
                selectedColor: item.$3.withValues(alpha: 0.22),
                onSelected: (_) => setState(() {
                  _selectedFilter = item.$1;
                  _resetVisibleCount();
                }),
              );
            }),
            if (isMobile)
              IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.label_outline),
                tooltip: l10n.tagsTooltip,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedList(
    BuildContext context,
    AppLocalizations l10n, {
    bool isMobile = false,
  }) {
    final feed = _filteredEvents();

    if (_selectedCity == 'Город не выбран') {
      return _buildEmptyState(context, l10n.cityNotSelected);
    }

    if (feed.isEmpty) {
      return _buildEmptyState(context, l10n.noEventsFound);
    }

    final labels = EventFeedCardLabels(
      join: l10n.joinEvent,
      leave: l10n.leaveEvent,
      noPhoto: l10n.noPhotoLabel,
      table: l10n.tableLabel,
      list: l10n.listLabel,
      topSlots: l10n.topSlotsLabel,
      address: l10n.addressLabel,
      dayLabel: l10n.dayLabel,
      weekdays: _currentLocale.languageCode == 'ru'
          ? const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
          : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      tagMismatch: l10n.tagMismatchLabel,
    );

    final visibleCount = feed.length < _visibleCount
        ? feed.length
        : _visibleCount;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          _tryLoadMore(
            notification.metrics.pixels,
            notification.metrics.maxScrollExtent,
            feed.length,
          );
        }
        return false;
      },
      child: ListView.builder(
        controller: _feedScrollController,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
        cacheExtent: 1600,
        itemCount: visibleCount + (visibleCount < feed.length ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= visibleCount) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final item = feed[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Spacer(),
                Expanded(
                  flex: isMobile ? 100 : 70,
                  child: RepaintBoundary(
                    child: EventFeedCard(
                      item: item,
                      labels: labels,
                      accentColor: _relationColor(item.relation),
                      onParticipationChanged: (_) {
                        if (!item.isParticipant &&
                            _activeEvent?.id == item.id) {
                          setState(() {
                            _activeEvent = null;
                            _sidePanelType = null;
                          });
                        } else {
                          setState(() {});
                        }
                      },
                      onOpenChat: () {
                        setState(() {
                          _activeEvent = item;
                          _sidePanelType = _SidePanelType.chat;
                        });
                        if (isMobile) {
                          _scaffoldKey.currentState?.openEndDrawer();
                        }
                      },
                      onOpenParticipants: () {
                        setState(() {
                          _activeEvent = item;
                          _sidePanelType = _SidePanelType.participants;
                        });
                        if (isMobile) {
                          _scaffoldKey.currentState?.openEndDrawer();
                        }
                      },
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidePanel(
    BuildContext context,
    AppLocalizations l10n, {
    bool compact = false,
  }) {
    if (_activeEvent == null || _sidePanelType == null) {
      return const SizedBox.shrink();
    }

    final event = _activeEvent!;

    return Container(
      decoration: BoxDecoration(
        color: _darkTheme
            ? const Color(0xFF1B2742).withValues(alpha: 0.9)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          if (_panelHeaderCollapsed)
                            Text(
                              '${l10n.priceLabel}: ${event.ticketPrice?.toStringAsFixed(0) ?? 0} ₽ · ${event.address}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: _panelHeaderCollapsed
                          ? l10n.expandLabel
                          : l10n.collapseLabel,
                      onPressed: () => setState(
                        () => _panelHeaderCollapsed = !_panelHeaderCollapsed,
                      ),
                      icon: Icon(
                        _panelHeaderCollapsed
                            ? Icons.expand_more
                            : Icons.expand_less,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _closePanel(compact: compact),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                if (!_panelHeaderCollapsed) ...[
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text('${l10n.addressLabel}: ${event.address}'),
                  if (event.isVoting)
                    Text(
                      '${l10n.top3SlotsLabel}: ${event.topSlots.map((e) => '${e.votes} • ${e.label}').join(' | ')}',
                    )
                  else
                    Text(l10n.fixedSlotLabel),
                  Text(
                    event.ticketPrice == null
                        ? l10n.priceFreeLabel
                        : '${l10n.priceLabel}: ${event.ticketPrice!.toStringAsFixed(0)} ₽',
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _sidePanelType == _SidePanelType.chat
                ? _buildChatBody(l10n)
                : _buildParticipantsList(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody(AppLocalizations l10n) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final message = _chatMessages[index];
              final align = message.isMine
                  ? Alignment.centerLeft
                  : Alignment.centerRight;
              final bubbleColor = message.isMine
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest;

              return Align(
                alignment: align,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  child: Text(message.userName.substring(0, 1)),
                                ),
                                Positioned(
                                  right: -5,
                                  bottom: -4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '★ ${message.rating.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                message.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              iconSize: 18,
                              onPressed: () {},
                              icon: const Icon(Icons.reply_outlined),
                              tooltip: l10n.replyLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(message.text),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatInputController,
                  onSubmitted: (_) => _sendChatMessage(),
                  decoration: InputDecoration(
                    hintText: l10n.chatInputHint,
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _sendChatMessage,
                child: Text(l10n.sendLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsList(AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          tileColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
          leading: CircleAvatar(child: Text('U${index + 1}')),
          title: Text('${l10n.memberLabel} ${index + 1}'),
          subtitle: Text(
            '${l10n.ratingLabel}: ${(3.5 + (index % 15) / 10).toStringAsFixed(1)}',
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String title) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }

  List<EventFeedItem> _filteredEvents() {
    final currentKey = [
      _selectedCity,
      _searchController.text.trim().toLowerCase(),
      _selectedTags.toList()..sort(),
      _selectedFilter.name,
      _dateOrder.name,
      _priceSort.name,
    ].join('|');

    if (currentKey == _feedCacheKey) {
      return _cachedFeed;
    }

    if (_selectedCity == 'Город не выбран') {
      _feedCacheKey = currentKey;
      _cachedFeed = const [];
      return _cachedFeed;
    }

    var list = _events.where((event) => event.city == _selectedCity).toList();

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (event) =>
                event.title.toLowerCase().contains(query) ||
                event.description.toLowerCase().contains(query) ||
                event.tags.any((tag) => tag.toLowerCase().contains(query)),
          )
          .toList();
    }

    if (_selectedTags.isNotEmpty) {
      list = list
          .where(
            (event) => event.tags.any((tag) => _selectedTags.contains(tag)),
          )
          .toList();
    }

    list = list.where((event) {
      switch (_selectedFilter) {
        case _FeedFilter.all:
          return true;
        case _FeedFilter.mine:
          return event.relation == EventRelationKind.mine;
        case _FeedFilter.participating:
          return event.relation == EventRelationKind.participating;
        case _FeedFilter.applied:
          return event.relation == EventRelationKind.applied;
        case _FeedFilter.archived:
          return int.tryParse(event.id.replaceAll('e', ''))?.isEven ?? false;
      }
    }).toList();

    list.sort((a, b) {
      final aId = int.tryParse(a.id.replaceAll('e', '')) ?? 0;
      final bId = int.tryParse(b.id.replaceAll('e', '')) ?? 0;
      return _dateOrder == _DateOrder.newestFirst
          ? bId.compareTo(aId)
          : aId.compareTo(bId);
    });

    if (_priceSort != SortArrowState.none) {
      list.sort((a, b) {
        final ap = a.ticketPrice ?? 0;
        final bp = b.ticketPrice ?? 0;
        return _priceSort == SortArrowState.up
            ? ap.compareTo(bp)
            : bp.compareTo(ap);
      });
    }

    _feedCacheKey = currentKey;
    _cachedFeed = list;
    return _cachedFeed;
  }

  SortArrowState _nextPriceSort(SortArrowState value) {
    switch (value) {
      case SortArrowState.none:
        return SortArrowState.up;
      case SortArrowState.up:
        return SortArrowState.down;
      case SortArrowState.down:
        return SortArrowState.none;
    }
  }

  ThemeData _buildLightTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF3D63DD),
      onPrimary: Colors.white,
      secondary: Color(0xFF5A82E6),
      onSecondary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Color(0xFFF9FBFE),
      onSurface: Color(0xFF1F2937),
      surfaceContainerHighest: Color(0xFFEEF3FA),
      onSurfaceVariant: Color(0xFF5B6474),
      outline: Color(0xFFD2D9E4),
      outlineVariant: Color(0xFFE2E7F0),
      inverseSurface: Color(0xFF1F2937),
      onInverseSurface: Colors.white,
      tertiary: Color(0xFF6F5EEA),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE8E5FF),
      onTertiaryContainer: Color(0xFF2C245E),
      secondaryContainer: Color(0xFFE6EEFF),
      onSecondaryContainer: Color(0xFF1B2E61),
      primaryContainer: Color(0xFFDFE8FF),
      onPrimaryContainer: Color(0xFF1A2E5F),
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surfaceContainerHigh: Color(0xFFF2F6FC),
      surfaceTint: Color(0xFF3D63DD),
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceBright: Color(0xFFFFFFFF),
      surfaceDim: Color(0xFFF1F4FA),
      surfaceContainerLowest: Color(0xFFFFFFFF),
      surfaceContainerLow: Color(0xFFF8FAFD),
      surfaceContainer: Color(0xFFF5F8FC),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C77FF),
          brightness: Brightness.dark,
        ).copyWith(
          surfaceContainerHighest: const Color(0xFF24324E),
          surfaceContainerHigh: const Color(0xFF22314A),
          surfaceContainer: const Color(0xFF1C2942),
          surface: const Color(0xFF111A2E),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
    );
  }

  Color _relationColor(EventRelationKind relation) {
    switch (relation) {
      case EventRelationKind.mine:
        return const Color(0xFFD95A66);
      case EventRelationKind.participating:
        return const Color(0xFF42A86A);
      case EventRelationKind.applied:
        return const Color(0xFF4E88E7);
      case EventRelationKind.none:
        return const Color(0xFF8A95A8);
    }
  }

  List<EventFeedItem> _buildMockEvents() {
    final random = Random(42);
    final list = <EventFeedItem>[];

    const titles = [
      'Поход в музей',
      'Вечер настолок',
      'Пробежка на набережной',
      'Кофе и нетворкинг',
      'Киновечер',
      'Мини-поход',
      'Лекция по стартапам',
      'Йога в парке',
    ];

    final cityValues = _cities
        .where((city) => city != 'Город не выбран')
        .toList();

    for (var index = 1; index <= 240; index++) {
      final city = cityValues[index % cityValues.length];
      final isVoting = index % 3 != 0;
      final relation = switch (index % 5) {
        0 => EventRelationKind.mine,
        1 => EventRelationKind.participating,
        2 => EventRelationKind.applied,
        _ => EventRelationKind.none,
      };

      final itemTags = <String>{};
      final count = 1 + random.nextInt(3);
      while (itemTags.length < count) {
        itemTags.add(_allTags[random.nextInt(_allTags.length)]);
      }

      final topSlots = <SlotPreview>[];
      if (isVoting) {
        for (var i = 0; i < 3; i++) {
          topSlots.add(
            SlotPreview(
              votes: 4 + random.nextInt(12),
              label:
                  '${['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'][random.nextInt(7)]} ${10 + random.nextInt(11)}:00',
            ),
          );
        }
      }

      list.add(
        EventFeedItem(
          id: 'e$index',
          title: '${titles[index % titles.length]} #$index',
          description:
              'Совместная встреча с гибкой организацией времени и участников.',
          city: city,
          address: 'ул. Примерная, ${10 + index}',
          mapUrl: 'https://maps.google.com/?q=55.75,37.61',
          imageUrl: index % 4 == 0
              ? null
              : 'https://picsum.photos/seed/meet$index/520/360',
          isVoting: isVoting,
          ticketPrice: index % 4 == 0 ? null : 300 + (index % 9) * 150,
          tags: itemTags.toList(),
          topSlots: topSlots,
          relation: relation,
          authorRating: 3.8 + (index % 13) * 0.1,
          isParticipant: relation == EventRelationKind.participating,
          likes: 20 + random.nextInt(120),
          dislikes: random.nextInt(18),
        ),
      );
    }

    return list;
  }
}

class _SortIconButton extends StatelessWidget {
  final IconData icon;
  final SortArrowState state;
  final String tooltip;
  final VoidCallback onTap;

  const _SortIconButton({
    required this.icon,
    required this.state,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData? arrow;
    switch (state) {
      case SortArrowState.none:
        arrow = null;
      case SortArrowState.up:
        arrow = Icons.arrow_upward;
      case SortArrowState.down:
        arrow = Icons.arrow_downward;
    }

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              if (arrow != null) ...[
                const SizedBox(width: 4),
                Icon(arrow, size: 14),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
