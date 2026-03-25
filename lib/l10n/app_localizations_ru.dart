// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'MeetApp';

  @override
  String get eventListTitle => 'Список мероприятий';

  @override
  String get eventsPageTitle => 'Мероприятия';

  @override
  String get settingsPageTitle => 'Настройки';

  @override
  String get createEventButton => 'Создать';

  @override
  String get createEventPageTitle => 'Создать мероприятие';

  @override
  String get eventDetailsPageTitle => 'Детали мероприятия';

  @override
  String get votingPageTitle => 'Голосование';

  @override
  String get refreshButton => 'Обновить';

  @override
  String get noEventsFound => 'Мероприятий не найдено';

  @override
  String get loading => 'Загрузка...';

  @override
  String get error => 'Ошибка';

  @override
  String get allEventsFilter => 'Все';

  @override
  String get plannedEventsFilter => 'В планах';

  @override
  String get activeEventsFilter => 'Активные';

  @override
  String get fixedEventsFilter => 'Зафиксированные';

  @override
  String get interfaceLanguage => 'Язык интерфейса';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'English';

  @override
  String get theme => 'Тема';

  @override
  String get systemTheme => 'Системная';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Темная';

  @override
  String get participants => 'Участников';

  @override
  String get eventStatus => 'Статус';

  @override
  String get eventType => 'Тип';

  @override
  String get startDate => 'Дата начала';

  @override
  String get endDate => 'Дата окончания';

  @override
  String get description => 'Описание';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get loginWith => 'Войти через';

  @override
  String get rulesTitle => 'Правила сервиса';

  @override
  String get rules1 => '• Запрет спама и мошенничества';

  @override
  String get rules2 => '• Запрет оскорблений и дискриминации';

  @override
  String get rules3 => '• Запрет противоправных действий';

  @override
  String get rules4 => '• Отказ от ответственности за действия пользователей';

  @override
  String get licenseButton => 'Лицензионное соглашение';

  @override
  String get licenseText =>
      'Регистрируясь, вы подтверждаете, что ознакомились и согласны со всеми пунктами лицензионного соглашения.';

  @override
  String get tariffsTitle => 'Тарифы';

  @override
  String get tariffPhysicalTitle => 'Физ. лица';

  @override
  String get tariffPhysicalDesc => 'Базовый доступ';

  @override
  String get tariffPhysicalPrice => '0 ₽';

  @override
  String get tariffPhysicalFeature1 => 'Просмотр мероприятий';

  @override
  String get tariffPhysicalFeature2 => 'Участие в голосованиях';

  @override
  String get searchEventsInYourCity => 'Поиск по событиям вашего города';

  @override
  String get tagsLabel => 'Теги';

  @override
  String get myEventsFilter => 'Созданные мной';

  @override
  String get participatingFilter => 'Участвую';

  @override
  String get appliedFilter => 'Подал заявку';

  @override
  String get archivedFilter => 'Архив';

  @override
  String get applicationCancelled => 'Вы отменили заявку на';

  @override
  String get applicationSubmitted => 'Вы подали заявку на';

  @override
  String get errorMessage => 'Ошибка';

  @override
  String get invalidMapUrl => 'Неверный URL карты';

  @override
  String get failedOpenMap => 'Не удалось открыть карту';

  @override
  String get tariffBusiness1Title => 'Юр.Лица L1';

  @override
  String get tariffBusiness1Desc => 'Расширенные инструменты';

  @override
  String get tariffBusiness1Price => '1490 ₽';

  @override
  String get tariffBusiness1Feature1 => 'Создание мероприятий';

  @override
  String get tariffBusiness1Feature2 => 'Управление участн.';

  @override
  String get tariffBusiness1Feature3 => 'Статистика';

  @override
  String get tariffBusiness2Title => 'Юр.Лица L2';

  @override
  String get tariffBusiness2Desc => 'Приоритетная поддержка';

  @override
  String get tariffBusiness2Price => '2990 ₽';

  @override
  String get tariffBusiness2Feature1 => 'Всё из L1';

  @override
  String get tariffBusiness2Feature2 => 'Приоритетн. поддержка';

  @override
  String get tariffBusiness2Feature3 => 'API доступ';

  @override
  String get tariffBusiness3Title => 'Юр.Лица L3';

  @override
  String get tariffBusiness3Desc => 'Максимальные возможности';

  @override
  String get tariffBusiness3Price => '4990 ₽';

  @override
  String get tariffBusiness3Feature1 => 'Всё из L2';

  @override
  String get tariffBusiness3Feature2 => 'Автомодерация';

  @override
  String get tariffBusiness3Feature3 => 'Кастомизация';

  @override
  String get locationParsingError_invalidUrl =>
      'Указанная ссылка не является действительным URL-адресом.';

  @override
  String get locationParsingError_unsupportedMapProvider =>
      'Поддерживаются только ссылки на Google Карты и Яндекс Карты.';

  @override
  String get locationParsingError_parsingFailed =>
      'Не удалось извлечь координаты из ссылки. Проверьте ссылку или введите адрес вручную.';

  @override
  String get locationParsingError_networkError =>
      'Ошибка сети. Не удалось обработать короткую ссылку. Проверьте ваше интернет-соединение.';
}
