# Mock-данные для MeetApp

Этот каталог содержит mock-данные для тестирования и разработки приложения MeetApp.

## Структура данных

### Пользователи (`users.json`)
- **id**: Уникальный идентификатор пользователя
- **name**: Имя пользователя
- **avatarUrl**: Ссылка на аватар
- **email**: Email пользователя
- **gender**: Пол (male/female/null для организаций)
- **birthDate**: Дата рождения
- **age**: Возраст
- **rating**: Рейтинг пользователя
- **status**: Статус (active/blocked)
- **blockedUntil**: Дата окончания блокировки
- **role**: Роль (user/admin)
- **premiumStatus**: Уровень премиум-статуса
- **acceptedLicense**: Принята ли лицензия
- **createdAt**: Дата регистрации
- **lastActiveAt**: Дата последней активности
- **notificationsEnabled**: Включены ли уведомления
- **language**: Язык интерфейса
- **timezone**: Часовой пояс

### События (`events.json`)
- **id**: Уникальный идентификатор события
- **title**: Название события
- **description**: Описание события
- **location**: Локация (название, адрес, координаты, тип)
- **category**: Категория (sports/relax/culture)
- **organizerId**: ID организатора
- **createdAt**: Дата создания
- **updatedAt**: Дата последнего обновления
- **status**: Статус (active/completed/cancelled)
- **maxParticipants**: Максимальное количество участников
- **currentParticipants**: Текущее количество участников
- **isPublic**: Публичное ли событие
- **isFree**: Бесплатное ли событие
- **price**: Стоимость участия
- **currency**: Валюта
- **tags**: Теги события
- **images**: Список URL изображений
- **requirements**: Требования к участникам
- **rules**: Правила события
- **votingId**: ID голосования
- **chatId**: ID чата
- **expenseId**: ID расходов

### Чаты (`chats.json`)
- **id**: Уникальный идентификатор чата
- **eventId**: ID события
- **name**: Название чата
- **description**: Описание чата
- **createdAt**: Дата создания
- **lastMessageAt**: Дата последнего сообщения
- **participants**: Список ID участников
- **messages**: Список ID сообщений

### Сообщения чата (`chat_messages.json`)
- **id**: Уникальный идентификатор сообщения
- **chatId**: ID чата
- **senderId**: ID отправителя
- **text**: Текст сообщения
- **timestamp**: Время отправки
- **status**: Статус (visible/deleted)
- **messageType**: Тип сообщения (text/image)

### Заявки на участие (`applications.json`)
- **id**: Уникальный идентификатор заявки
- **eventId**: ID события
- **userId**: ID пользователя
- **selectedSlotIds**: Выбранные слоты
- **status**: Статус (pending/approved/rejected)
- **updatedAt**: Дата последнего обновления
- **createdAt**: Дата создания

### Слоты голосования (`voting.json`)
- **id**: Уникальный идентификатор голосования
- **eventId**: ID события
- **title**: Название голосования
- **description**: Описание голосования
- **createdAt**: Дата создания
- **expiresAt**: Дата окончания
- **options**: Варианты голосования
  - **id**: ID варианта
  - **votingId**: ID голосования
  - **text**: Текст варианта
  - **votes**: Количество голосов
  - **voters**: Список ID проголосовавших
- **status**: Статус (active/completed)
- **winnerOptionId**: ID выигравшего варианта

### Расходы (`expenses.json`)
- **id**: Уникальный идентификатор расхода
- **eventId**: ID события
- **authorId**: ID автора расхода
- **description**: Описание расхода
- **amount**: Сумма расхода
- **createdAt**: Дата создания
- **contributors**: Участники и их взносы (ID пользователя -> сумма)
- **receipts**: Список чеков
  - **id**: ID чека
  - **expenseId**: ID расхода
  - **fileUrl**: Ссылка на файл чека
  - **uploadedBy**: ID загрузившего
  - **createdAt**: Дата загрузки

### Уведомления (`notifications.json`)
- **id**: Уникальный идентификатор уведомления
- **userId**: ID пользователя
- **type**: Тип уведомления
- **title**: Заголовок
- **message**: Текст сообщения
- **eventId**: ID события
- **applicationId**: ID заявки
- **payload**: Дополнительные данные
- **createdAt**: Дата создания
- **isRead**: Прочитано ли
- **actionLabel**: Текст действия
- **actionType**: Тип действия

## Примеры использования

### Создание нового пользователя
```json
{
  "id": "user_new",
  "name": "Новый Пользователь",
  "avatarUrl": "https://example.com/avatar_new.jpg",
  "email": "new@example.com",
  "gender": "male",
  "birthDate": "1990-01-01",
  "age": 33,
  "rating": 4.5,
  "status": "active",
  "blockedUntil": null,
  "role": "user",
  "premiumStatus": "free",
  "acceptedLicense": true,
  "createdAt": "2026-03-23T10:00:00Z",
  "lastActiveAt": "2026-03-23T10:00:00Z",
  "notificationsEnabled": true,
  "language": "ru",
  "timezone": "Europe/Moscow"
}
```

### Создание нового события
```json
{
  "id": "event_new",
  "title": "Новое событие",
  "description": "Описание нового события",
  "location": {
    "name": "Новое место",
    "address": "ул. Новая, 1",
    "latitude": 55.7558,
    "longitude": 37.6176,
    "type": "indoor"
  },
  "category": "sports",
  "organizerId": "user_1",
  "createdAt": "2026-03-23T10:00:00Z",
  "updatedAt": "2026-03-23T10:00:00Z",
  "status": "active",
  "maxParticipants": 10,
  "currentParticipants": 0,
  "isPublic": true,
  "isFree": true,
  "price": 0.0,
  "currency": "RUB",
  "tags": ["спорт", "активный отдых"],
  "images": [],
  "requirements": [],
  "rules": [],
  "votingId": null,
  "chatId": null,
  "expenseId": null
}
```

## Валидация данных

Все mock-данные соответствуют структуре моделей данных в приложении:
- Соответствие типам данных
- Наличие всех обязательных полей
- Корректные связи между сущностями
- Валидные форматы дат и временных меток

## Обновление данных

При внесении изменений в модели данных необходимо:
1. Обновить соответствующие mock-файлы
2. Проверить соответствие структуры
3. Убедиться в наличии всех обязательных полей
4. Проверить валидность связей между сущностями