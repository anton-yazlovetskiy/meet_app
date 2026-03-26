/// Голосование
class Voting {
  /// Уникальный идентификатор
  final String id;

  /// ID мероприятия
  final String eventId;

  /// Заголовок
  final String title;

  /// Описание
  final String description;

  /// Тип голосования (single/multiple)
  final VotingType type;

  /// Варианты
  final List<VotingOption> options;

  /// Дата создания
  final DateTime createdAt;

  /// Дата окончания
  final DateTime expiresAt;

  const Voting({required this.id, required this.eventId, required this.title, required this.description, required this.type, required this.options, required this.createdAt, required this.expiresAt});
}

/// Вариант голосования
class VotingOption {
  /// Уникальный идентификатор
  final String id;

  /// Текст варианта
  final String text;

  /// Голоса (ID пользователя -> тип голоса)
  final Map<String, VoteType> votes;

  const VotingOption({required this.id, required this.text, required this.votes});
}

/// Тип голоса
enum VoteType {
  /// За
  voteFor,

  /// Против
  voteAgainst,

  /// Воздержался
  abstain,
}

/// Тип голосования
enum VotingType {
  /// Один вариант
  single,

  /// Несколько вариантов
  multiple,
}
