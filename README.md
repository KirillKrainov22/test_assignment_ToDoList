# ToDoList

Приложение для ведения списка дел (тестовое задание, iOS / UIKit).

## Стек и архитектура

- **UIKit**, вёрстка кодом (без storyboard), тёмная тема из макета.
- **Архитектура VIPER**: каждый модуль разделён на `View`, `Interactor`, `Presenter`, `Entity`, `Router`.
- **CoreData** — персистентное хранилище задач.
- **GCD** — все операции с данными (загрузка, поиск, CRUD) выполняются в фоне; UI не блокируется.
- Минимальная версия iOS — 15.0.

## Функциональность

- Список задач на главном экране: название, описание, дата создания, статус.
- Добавление, редактирование, удаление задач.
- Поиск по задачам (`UISearchController`).
- Переключение статуса выполнения тапом по чекбоксу.
- Контекстное меню на ячейке: **Редактировать / Поделиться / Удалить**, а также свайп для удаления.
- «Поделиться» через `UIActivityViewController`.
- При первом запуске список загружается из `https://dummyjson.com/todos` и сохраняется в CoreData.
  Повторные запуски читают данные из локального хранилища.

## Маппинг данных API

В `dummyjson` у задачи есть только `id`, `todo`, `completed`, `userId`, поэтому:

| Поле API     | Локальная модель                                  |
|--------------|---------------------------------------------------|
| `todo`       | название (`title`)                                |
| `completed`  | статус (`isCompleted`)                            |
| `id`         | `remoteId` — защита от повторного импорта          |
| `userId`     | не используется                                    |
| —            | `details` пустое, `createdAt` = момент импорта     |

## Структура проекта

```
ToDoList/
├── App/            AppDelegate, SceneDelegate
├── Common/         Theme, Formatters
├── CoreData/       CoreDataStack, модель, маппинг
├── Models/         Todo (доменная сущность), TodoDTO
├── Services/       NetworkService, TodoRepository
└── Modules/
    ├── TaskList/   VIPER-модуль списка задач
    └── TaskDetail/ VIPER-модуль создания/редактирования
ToDoListTests/      Юнит-тесты
```

## Запуск

```bash
open ToDoList.xcodeproj
```

Выбрать схему `ToDoList` и симулятор, затем Run (`⌘R`).

## Тесты

```bash
xcodebuild -project ToDoList.xcodeproj -scheme ToDoList \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Покрыты: декодирование ответа API и маппинг, CRUD-операции репозитория
(на in-memory CoreData), логика презентера списка, форматирование даты и
плюрализация счётчика задач.
