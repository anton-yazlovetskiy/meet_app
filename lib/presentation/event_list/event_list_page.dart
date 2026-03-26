import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

enum _SidePanelType { chat, participants }

enum _EventCardType { fixed, voting }

class _EventListItem {
  final String id;
  final String title;
  final String city;
  final String description;
  final _EventCardType type;
  final double price;
  final List<String> tags;
  final List<String> topSlots;
  bool isParticipant;

  _EventListItem({
    required this.id,
    required this.title,
    required this.city,
    required this.description,
    required this.type,
    required this.price,
    required this.tags,
    required this.topSlots,
    this.isParticipant = false,
  });
}

class _EventListPageState extends State<EventListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _selectedCity = 'Все города';
  String _selectedLanguage = 'RU';
  bool _darkTheme = false;
  final Set<String> _selectedTags = {};
  _SidePanelType? _sidePanelType;
  String? _selectedEventId;

  final List<String> _cities = const [
    'Все города',
    'Москва',
    'Санкт-Петербург',
    'Казань',
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
  ];

  final List<_EventListItem> _events = [
    _EventListItem(
      id: 'e1',
      title: 'Поход в музей',
      city: 'Москва',
      description: 'Фиксированное мероприятие с ценой билета.',
      type: _EventCardType.fixed,
      price: 1200,
      tags: ['Культура', 'Еда'],
      topSlots: const [],
    ),
    _EventListItem(
      id: 'e2',
      title: 'Вечер настолок',
      city: 'Санкт-Петербург',
      description: 'Голосование по времени, до 12 участников.',
      type: _EventCardType.voting,
      price: 0,
      tags: ['Настолки', 'Нетворкинг'],
      topSlots: const ['Вт 19:00', 'Ср 20:00', 'Пт 19:00'],
      isParticipant: true,
    ),
    _EventListItem(
      id: 'e3',
      title: 'Утренняя пробежка',
      city: 'Москва',
      description: 'Регулярное событие по выходным.',
      type: _EventCardType.voting,
      price: 0,
      tags: ['Спорт', 'Прогулки'],
      topSlots: const ['Сб 09:00', 'Вс 10:00'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 1000;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isMobile ? Drawer(child: _buildTagsPanel(context)) : null,
      endDrawer: isMobile && _sidePanelType != null
          ? Drawer(
              child: _buildSidePanel(
                context,
                compact: true,
              ),
            )
          : null,
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            const Icon(Icons.pets_outlined),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Поиск мероприятий',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 10),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCity,
                items: _cities
                    .map(
                      (city) =>
                          DropdownMenuItem(value: city, child: Text(city)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedCity = value);
                },
              ),
            ),
          ],
        ),
        actions: [
          if (isMobile)
            IconButton(
              tooltip: 'Теги',
              icon: const Icon(Icons.label_outline),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          PopupMenuButton<String>(
            tooltip: 'Язык',
            initialValue: _selectedLanguage,
            onSelected: (value) => setState(() => _selectedLanguage = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'RU', child: Text('Русский')),
              PopupMenuItem(value: 'EN', child: Text('English')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Center(child: Text(_selectedLanguage)),
            ),
          ),
          IconButton(
            tooltip: 'Тема',
            icon: Icon(_darkTheme ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => setState(() => _darkTheme = !_darkTheme),
          ),
          IconButton(
            tooltip: 'Уведомления',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            tooltip: 'Личный кабинет',
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (isMobile) {
            return _buildMobileLayout(context);
          }

          final cardsWidth = (constraints.maxWidth * 0.33).clamp(500.0, 740.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: constraints.maxWidth * 0.25,
                child: _buildTagsPanel(context),
              ),
              const VerticalDivider(width: 1),
              SizedBox(
                width: cardsWidth,
                child: _buildEventsColumn(context),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: _buildSidePanel(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildFilterSortRow(context, isMobile: true),
        Expanded(child: _buildEventCardsList(context, isMobile: true)),
      ],
    );
  }

  Widget _buildTagsPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Теги', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _allTags.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tag = _allTags[index];
                final selected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
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

  Widget _buildEventsColumn(BuildContext context) {
    return Column(
      children: [
        _buildFilterSortRow(context),
        Expanded(child: _buildEventCardsList(context)),
      ],
    );
  }

  Widget _buildFilterSortRow(BuildContext context, {bool isMobile = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildOutlinedPill('Все мероприятия', selected: true),
            const SizedBox(width: 8),
            _buildOutlinedPill('Мои'),
            const SizedBox(width: 8),
            _buildOutlinedPill('Участвую'),
            const SizedBox(width: 8),
            _buildOutlinedPill('Подал заявку'),
            const SizedBox(width: 8),
            _buildOutlinedPill('Архив'),
            const SizedBox(width: 16),
            _buildOutlinedPill('Дата создания'),
            const SizedBox(width: 8),
            _buildOutlinedPill('Цена: бесплатно → платно'),
            const SizedBox(width: 8),
            _buildOutlinedPill('Цена: платно → бесплатно'),
            const SizedBox(width: 8),
            _buildOutlinedPill('Цена: без сортировки', selected: true),
            if (isMobile) ...[
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.label_outline),
                label: const Text('Теги'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEventCardsList(BuildContext context, {bool isMobile = false}) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: _events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildEventCard(context, event, isMobile: isMobile);
      },
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    _EventListItem event, {
    bool isMobile = false,
  }) {
    final isVoting = event.type == _EventCardType.voting;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(isVoting ? 'Голосование' : 'Фиксированное'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(event.description),
            const SizedBox(height: 10),
            Text('Город: ${event.city}'),
            Text(
              event.price > 0
                  ? 'Стоимость: ${event.price.toStringAsFixed(0)} ₽'
                  : 'Стоимость: бесплатно',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: event.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
            if (isVoting && event.topSlots.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Топ-слоты', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: event.topSlots
                    .map(
                      (slot) => ActionChip(
                        label: Text(slot),
                        onPressed: () {},
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: () {
                    setState(() {
                      event.isParticipant = !event.isParticipant;
                      if (!event.isParticipant &&
                          _selectedEventId == event.id) {
                        _selectedEventId = null;
                        _sidePanelType = null;
                      }
                    });
                  },
                  child: Text(
                    event.isParticipant ? 'Отказаться' : 'Участвовать',
                  ),
                ),
                const SizedBox(width: 8),
                if (event.isParticipant)
                  IconButton(
                    tooltip: 'Чат',
                    icon: const Icon(Icons.chat_bubble_outline),
                    onPressed: () {
                      setState(() {
                        _selectedEventId = event.id;
                        _sidePanelType = _SidePanelType.chat;
                      });
                      if (isMobile) {
                        _scaffoldKey.currentState?.openEndDrawer();
                      }
                    },
                  ),
                if (event.isParticipant)
                  IconButton(
                    tooltip: 'Участники',
                    icon: const Icon(Icons.group_outlined),
                    onPressed: () {
                      setState(() {
                        _selectedEventId = event.id;
                        _sidePanelType = _SidePanelType.participants;
                      });
                      if (isMobile) {
                        _scaffoldKey.currentState?.openEndDrawer();
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, {bool compact = false}) {
    if (_sidePanelType == null || _selectedEventId == null) {
      return Center(
        child: Text(
          'Панель чата и участников',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    final selectedEvent = _events.firstWhere(
      (event) => event.id == _selectedEventId,
    );
    final title = _sidePanelType == _SidePanelType.chat
        ? 'Чат мероприятия'
        : 'Участники';

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$title: ${selectedEvent.title}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (compact)
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _sidePanelType == _SidePanelType.chat
                ? ListView(
                    children: const [
                      ListTile(
                        title: Text('Иван'),
                        subtitle: Text('Подходит вторник 19:00'),
                      ),
                      ListTile(
                        title: Text('Мария'),
                        subtitle: Text('Я за пятницу 20:00'),
                      ),
                      ListTile(
                        title: Text('Система'),
                        subtitle: Text('Финальный слот ещё не выбран'),
                      ),
                    ],
                  )
                : ListView(
                    children: const [
                      ListTile(
                        leading: CircleAvatar(child: Text('И')),
                        title: Text('Иван Петров'),
                      ),
                      ListTile(
                        leading: CircleAvatar(child: Text('М')),
                        title: Text('Мария Сидорова'),
                      ),
                      ListTile(
                        leading: CircleAvatar(child: Text('А')),
                        title: Text('Алексей Иванов'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedPill(String text, {bool selected = false}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? Theme.of(context).colorScheme.secondaryContainer
            : null,
      ),
      onPressed: () {},
      child: Text(text),
    );
  }
}
