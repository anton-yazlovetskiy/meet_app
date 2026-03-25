import json
import random
from datetime import datetime, timedelta

# Список тегов
tags_list = [
    "спорт", "зима", "культура", "экскурсия", "развлечения", "общение", "еда", "путешествия",
    "музыка", "танцы", "искусство", "театр", "кино", "литература", "наука", "технологии",
    "здоровье", "фитнес", "йога", "медитация", "природа", "животные", "волонтерство", "образование"
]

# Типы событий
event_types = ["voting", "fixed"]
statuses = ["planned", "active", "fixed", "archived"]

# Города
cities = [
    {"name": "Москва", "lat": 55.7558, "lng": 37.6173},
    {"name": "Санкт-Петербург", "lat": 59.9343, "lng": 30.3351},
    {"name": "Екатеринбург", "lat": 56.8389, "lng": 60.6057},
    {"name": "Новосибирск", "lat": 55.0084, "lng": 82.9357},
    {"name": "Казань", "lat": 55.7961, "lng": 49.1064}
]

# Генерация событий
events = []
for i in range(1, 201):  # 200 событий
    event_id = f"event_{i}"
    title = f"Событие {i}"
    description = f"Описание события {i}. Это интересное мероприятие."
    tags = random.sample(tags_list, random.randint(1, 3))
    city = random.choice(cities)
    location = {
        "lat": city["lat"] + random.uniform(-0.01, 0.01),
        "lng": city["lng"] + random.uniform(-0.01, 0.01),
        "mapLink": f"https://maps.google.com/?q={city['lat']},{city['lng']}"
    }
    is_public = random.choice([True, False])
    event_type = random.choice(event_types)
    creator_id = f"user_{random.randint(1, 10)}"
    managers = [creator_id]
    max_participants = random.choice([None, random.randint(5, 50)])
    price = random.choice([0, random.randint(100, 2000)])
    created_at = (datetime.now() - timedelta(days=random.randint(0, 30))).isoformat() + "Z"
    start_limit = (datetime.now() + timedelta(days=random.randint(1, 60))).isoformat() + "Z"
    status = random.choice(statuses)
    voting_period = None if event_type == "fixed" else {
        "start": (datetime.now() + timedelta(days=random.randint(1, 10))).isoformat() + "Z",
        "end": (datetime.now() + timedelta(days=random.randint(15, 30))).isoformat() + "Z"
    }
    final_slot_id = f"slot_{i}" if event_type == "fixed" else None
    participants = [f"user_{random.randint(1, 10)}" for _ in range(random.randint(0, 5))]
    applicants = [f"user_{random.randint(1, 10)}" for _ in range(random.randint(0, 3))]
    slot_stats = [{
        "slotId": f"slot_{i}_{j}",
        "votes": random.randint(0, 10),
        "voters": [f"user_{random.randint(1, 10)}" for _ in range(random.randint(0, 5))]
    } for j in range(random.randint(1, 5))]
    chat_id = f"chat_{i}"
    expense_summary = {
        "totalAmount": random.randint(0, 5000),
        "receiptCount": random.randint(0, 10)
    }
    is_archived = random.choice([True, False])

    event = {
        "id": event_id,
        "title": title,
        "description": description,
        "tags": tags,
        "location": location,
        "isPublic": is_public,
        "eventType": event_type,
        "creatorId": creator_id,
        "managers": managers,
        "maxParticipants": max_participants,
        "price": price,
        "createdAt": created_at,
        "startLimit": start_limit,
        "status": status,
        "votingPeriod": voting_period,
        "finalSlotId": final_slot_id,
        "participants": participants,
        "applicants": applicants,
        "slotStats": slot_stats,
        "chatId": chat_id,
        "expenseSummary": expense_summary,
        "isArchived": is_archived
    }
    events.append(event)

# Запись в файл
with open('assets/mock_data/events.json', 'w', encoding='utf-8') as f:
    json.dump(events, f, ensure_ascii=False, indent=2)

print(f"Generated {len(events)} events")