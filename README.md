# Calendar App

Flutter-приложение-календарь с четырьмя режимами отображения, цветными событиями, локальными уведомлениями и поддержкой тёмной темы.

---

## Возможности

- 4 режима отображения — Год, Месяц, Неделя, День
- Цветные события — 4 цвета приоритета: синий, красный, оранжевый, зелёный
- Локальные уведомления — напоминания за 5 мин, 15 мин, 1 час, 1 день или своё значение
- Тёмная и светлая тема с сохранением выбора
- Все данные хранятся локально в SQLite
- Навигация с 1950 по 2950 год
- Ленивый скролл через `PageView.builder`

---

## Архитектура

Проект построен по принципам **Clean Architecture** со строгим разделением слоёв:

```
lib/
├── core/
│   ├── constants/        # Цвета, стили текста, константы приложения
│   ├── theme/            # ThemeData + ThemeCubit
│   ├── error/            # Классы Failure и Exception
│   ├── usecases/         # Базовая абстракция UseCase
│   ├── utils/            # Утилиты для дат, NotificationService
│   └── di/               # Dependency injection (get_it)
│
└── features/
    ├── calendar/
    │   ├── domain/       # Сущность CalendarDate, контракт репозитория
    │   ├── data/         # Реализация репозитория, datasource
    │   └── presentation/ # CalendarBloc, виджеты 4 видов, CalendarPage
    │
    └── event/
        ├── domain/       # Сущность Event, enum EventColor, use cases
        ├── data/         # EventModel, SQLite datasource, реализация репозитория
        └── presentation/ # EventBloc, виджеты формы, страницы Create/Edit/Detail
```

Правило зависимостей: Domain не зависит ни от чего внешнего. Data зависит от Domain. Presentation зависит от Domain через BLoC.

---

## Технологии

| Слой | Технология |
|------|-----------|
| Фреймворк | Flutter 3.24+ / Dart 3.5+ |
| Управление состоянием | `flutter_bloc` / `bloc` |
| Навигация | `go_router` |
| Локальное хранилище | `sqflite` |
| Уведомления | `flutter_local_notifications` |
| Внедрение зависимостей | `get_it` + `injectable` |
| Функциональное программирование | `fpdart` (Either, Option) |
| Равенство объектов | `equatable` |
| Форматирование дат | `intl` |
| Часовые пояса | `timezone` |
| Настройки | `shared_preferences` |

---

## Запуск проекта

### Требования

- Flutter SDK `^3.10.4`
- Dart SDK `^3.5.0`
- Android SDK или Xcode (для iOS)

### Установка

```bash
# Клонировать репозиторий
git clone https://github.com/your-username/calendar.git
cd calendar

# Установить зависимости
flutter pub get

# Генерация кода (injectable)
dart run build_runner build --delete-conflicting-outputs

# Запустить приложение
flutter run
```

### Сборка

```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release
```

---

## Дизайн-система

### Цветовая палитра

| Роль | Светлая тема | Тёмная тема |
|------|-------------|------------|
| Фон | `#FFFFFF` | `#121212` |
| Поверхность | `#F5F5F5` | `#1E1E1E` |
| Основной цвет | `#42A5F5` | `#42A5F5` |
| Основной текст | `#212121` | `#FFFFFF` |
| Вторичный текст | `#757575` | `#BDBDBD` |

### Цвета приоритетов событий

| Цвет | HEX |
|------|-----|
| Синий | `#42A5F5` |
| Красный | `#EF5350` |
| Оранжевый | `#FFA726` |
| Зелёный | `#66BB6A` |

Фон карточки события — цвет акцента с прозрачностью 15%.

---

## Режимы отображения

**Месяц** — основной вид. Сетка 7 столбцов с цветными точками-индикаторами под каждым числом. Нажатие на дату показывает список событий ниже.

**Год** — сетка 4×3 из мини-месяцев. Нажатие на мини-месяц переходит в вид «Месяц».

**Неделя** — горизонтальная полоска из 7 дней. Свайп влево/вправо переключает неделю.

**День** — вертикальный таймлайн 00:00–23:59 с блоками событий по длительности. Красная линия обозначает текущее время.

---

## Уведомления

Напоминания планируются через `flutter_local_notifications` с поддержкой часовых поясов. Доступные варианты: без напоминания, за 5/15/30 минут, за 1 час, за 1 день, или своё значение в минутах.

При удалении события уведомление отменяется автоматически, при изменении — перепланируется.

---

## Схема базы данных

```sql
CREATE TABLE events (
  id               INTEGER PRIMARY KEY AUTOINCREMENT,
  name             TEXT    NOT NULL,
  description      TEXT    NOT NULL DEFAULT '',
  location         TEXT    NOT NULL DEFAULT '',
  date             TEXT    NOT NULL,  -- 'YYYY-MM-DD'
  start_time       TEXT    NOT NULL,  -- 'HH:mm'
  end_time         TEXT    NOT NULL,  -- 'HH:mm'
  color            TEXT    NOT NULL DEFAULT 'blue',
  reminder_minutes INTEGER,           -- NULL = без напоминания
  created_at       TEXT    NOT NULL,
  updated_at       TEXT    NOT NULL
);

CREATE INDEX idx_events_date ON events(date);
```

---

## Маршруты навигации

| Путь | Страница |
|------|---------|
| `/` | CalendarPage |
| `/event/create` | EventCreatePage |
| `/event/:id` | EventDetailPage |
| `/event/:id/edit` | EventEditPage |

---

## Ключевые ограничения

- Без библиотек для календаря — вся логика на стандартном `DateTime`
- Только BLoC — без Riverpod, GetX и Provider
- Clean Architecture — Domain-слой без внешних зависимостей
- Ленивый рендеринг — `PageView.builder` для всех видов
- Только SQLite — без удалённого API; `SharedPreferences` только для настроек темы

---

## Лицензия

MIT License. Подробнее в файле [LICENSE](LICENSE).
