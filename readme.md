# Документация по классам и методам

## Класс `NsDb`

### Описание
Класс `NsDb` предназначен для работы с таблицами данных, включая их инициализацию, добавление и извлечение строк, а также управление указателями на строки.

### Методы

#### `NsDb:new(input_table, input_table_p, key, str_len)`
- **Описание**: Конструктор для создания нового объекта `NsDb`.
- **Параметры**:
  - `input_table`: Основная таблица данных.
  - `input_table_p`: Таблица указателей (опционально).
  - `key`: Ключ для инициализации таблицы (опционально).
  - `str_len`: Длина строки (опционально).
- **Возвращает**: Новый объект `NsDb`.

#### `NsDb:init(input_table, input_table_p, key, str_len)`
- **Описание**: Инициализация объекта.
- **Параметры**:
  - `input_table`: Основная таблица данных.
  - `input_table_p`: Таблица указателей (опционально).
  - `key`: Ключ для инициализации таблицы (опционально).
  - `str_len`: Длина строки (опционально).

#### `NsDb:initializeTable(input_table, key)`
- **Описание**: Вспомогательная функция для инициализации таблиц.
- **Параметры**:
  - `input_table`: Таблица данных.
  - `key`: Ключ для инициализации таблицы (опционально).
- **Возвращает**: Инициализированная таблица.

#### `NsDb:addStaticStr(nik, nStr, nArg, message)`
- **Описание**: Добавление или обновление строки.
- **Параметры**:
  - `nik`: Идентификатор строки.
  - `nStr`: Название строки.
  - `nArg`: Аргумент (опционально).
  - `message`: Сообщение для добавления.

#### `NsDb:getStaticStr(nik, nStr, nArg)`
- **Описание**: Получение статической строки.
- **Параметры**:
  - `nik`: Идентификатор строки.
  - `nStr`: Название строки.
  - `nArg`: Аргумент (опционально).
- **Возвращает**: Запрошенная строка.

#### `NsDb:addStr(message)`
- **Описание**: Добавление строки.
- **Параметры**:
  - `message`: Сообщение для добавления.

#### `NsDb:getStr(n)`
- **Описание**: Получение строки по индексу.
- **Параметры**:
  - `n`: Индекс строки.
- **Возвращает**: Запрошенная строка.

#### `NsDb:create_bin(message, str)`
- **Описание**: Создание бинарного представления сообщения.
- **Параметры**:
  - `message`: Сообщение.
  - `str`: Флаг строки.

#### `NsDb:add_str(message)`
- **Описание**: Добавление сообщения в таблицу.
- **Параметры**:
  - `message`: Сообщение для добавления.

#### `NsDb:add_line(message)`
- **Описание**: Добавление строки в таблицу.
- **Параметры**:
  - `message`: Сообщение для добавления.

#### `NsDb:add_dict(message, kod)`
- **Описание**: Добавление словаря.
- **Параметры**:
  - `message`: Сообщение.
  - `kod`: Код.

#### `NsDb:add_fdict(msg)`
- **Описание**: Добавление сообщения в хэш-таблицу.
- **Параметры**:
  - `msg`: Сообщение.

#### `NsDb:get_fdict(index)`
- **Описание**: Получение сообщения из хэш-таблицы.
- **Параметры**:
  - `index`: Индекс.
- **Возвращает**: Запрошенное сообщение.

#### `NsDb:is_unique(message)`
- **Описание**: Проверка уникальности сообщения.
- **Параметры**:
  - `message`: Сообщение.
- **Возвращает**: `true`, если сообщение уникально, иначе `false`.

#### `NsDb:pLen()`
- **Описание**: Получение длины таблицы указателей.
- **Возвращает**: Длина таблицы указателей.

#### `NsDb:Len()`
- **Описание**: Получение общей длины таблицы.
- **Возвращает**: Общая длина таблицы.

#### `NsDb:modKey(...)`
- **Описание**: Изменение значения по ключу.
- **Параметры**:
  - `...`: Ключи и значение.

#### `NsDb:getKey(...)`
- **Описание**: Получение значения по ключу.
- **Параметры**:
  - `...`: Ключи.
- **Возвращает**: Запрошенное значение.

## Класс `create_table`

### Описание
Класс `create_table` предназначен для создания и управления таблицами.

### Методы

#### `create_table:new(input_table, is_pointer)`
- **Описание**: Конструктор для создания нового объекта `create_table`.
- **Параметры**:
  - `input_table`: Имя таблицы.
  - `is_pointer`: Флаг указателя (опционально).
- **Возвращает**: Новый объект `create_table`.

#### `create_table:get_table()`
- **Описание**: Получение таблицы.
- **Возвращает**: Таблица.

#### `create_table:get_table_p()`
- **Описание**: Получение таблицы-указателя.
- **Возвращает**: Таблица-указатель.

## Класс `ButtonManager`

### Описание
Класс `ButtonManager` предназначен для создания и управления кнопками.

### Методы

#### `ButtonManager:new(name, parent, width, height, text, texture, mv)`
- **Описание**: Конструктор для создания новой кнопки.
- **Параметры**:
  - `name`: Имя кнопки.
  - `parent`: Родительский фрейм.
  - `width`: Ширина кнопки.
  - `height`: Высота кнопки.
  - `text`: Текст кнопки.
  - `texture`: Текстура кнопки (опционально).
  - `mv`: Флаг перемещения (опционально).
- **Возвращает**: Новый объект `ButtonManager`.

#### `ButtonManager:SetTexture(texture, highlightTexture)`
- **Описание**: Установка текстуры на кнопке.
- **Параметры**:
  - `texture`: Текстура.
  - `highlightTexture`: Текстура подсветки (опционально).

#### `ButtonManager:SetText(text)`
- **Описание**: Установка текста на кнопке.
- **Параметры**:
  - `text`: Текст.

#### `ButtonManager:SetTextT(text, color)`
- **Описание**: Установка текста на кнопке через `FontString` с возможностью задания цвета в формате HEX.
- **Параметры**:
  - `text`: Текст.
  - `color`: Цвет (опционально).

#### `ButtonManager:SetPosition(point, relativeTo, relativePoint, xOffset, yOffset)`
- **Описание**: Установка позиции кнопки.
- **Параметры**:
  - `point`: Точка привязки.
  - `relativeTo`: Относительно какого элемента.
  - `relativePoint`: Точка привязки относительно элемента.
  - `xOffset`: Смещение по X.
  - `yOffset`: Смещение по Y.

#### `ButtonManager:Hide()`
- **Описание**: Скрытие кнопки.

#### `ButtonManager:Show()`
- **Описание**: Отображение кнопки.

#### `ButtonManager:SetOnClick(onClickFunction)`
- **Описание**: Установка обработчика нажатия на кнопку.
- **Параметры**:
  - `onClickFunction`: Функция обработки нажатия.

#### `ButtonManager:SetOnEnter(onEnterFunction)`
- **Описание**: Установка обработчика наведения мыши на кнопку.
- **Параметры**:
  - `onEnterFunction`: Функция обработки наведения.

#### `ButtonManager:SetOnLeave(onLeaveFunction)`
- **Описание**: Установка обработчика ухода мыши с кнопки.
- **Параметры**:
  - `onLeaveFunction`: Функция обработки ухода.

#### `ButtonManager:SetTooltip(text)`
- **Описание**: Добавление всплывающей подсказки.
- **Параметры**:
  - `text`: Текст подсказки.

#### `ButtonManager:SetMultiLineTooltip(tooltipsTable)`
- **Описание**: Добавление многострочной всплывающей подсказки.
- **Параметры**:
  - `tooltipsTable`: Таблица с текстами подсказок.

#### `ButtonManager:SetSize(width, height)`
- **Описание**: Установка размера кнопки.
- **Параметры**:
  - `width`: Ширина.
  - `height`: Высота.

#### `ButtonManager:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)`
- **Описание**: Установка позиции кнопки.
- **Параметры**:
  - `point`: Точка привязки.
  - `relativeTo`: Относительно какого элемента.
  - `relativePoint`: Точка привязки относительно элемента.
  - `xOffset`: Смещение по X.
  - `yOffset`: Смещение по Y.

#### `ButtonManager:GetTxt(textureType)`
- **Описание**: Получение последних трех символов пути текстуры.
- **Параметры**:
  - `textureType`: Тип текстуры.
- **Возвращает**: Путь текстуры.

#### `ButtonManager:SetMovable(isMovable)`
- **Описание**: Установка возможности перемещения кнопки.
- **Параметры**:
  - `isMovable`: Флаг перемещения.

## Класс `AdaptiveFrame`

### Описание
Класс `AdaptiveFrame` предназначен для создания адаптивного фрейма с кнопками.

### Методы

#### `AdaptiveFrame:new(parent)`
- **Описание**: Конструктор для создания нового объекта `AdaptiveFrame`.
- **Параметры**:
  - `parent`: Родительский фрейм.
- **Возвращает**: Новый объект `AdaptiveFrame`.

#### `AdaptiveFrame:SetText(text)`
- **Описание**: Установка текста на фрейме.
- **Параметры**:
  - `text`: Текст.

#### `AdaptiveFrame:ToggleFrameAlpha()`
- **Описание**: Переключение прозрачности основного фрейма.

#### `AdaptiveFrame:StartMoving()`
- **Описание**: Начало перемещения фрейма.

#### `AdaptiveFrame:StopMovingOrSizing()`
- **Описание**: Остановка перемещения или изменения размера фрейма.

#### `AdaptiveFrame:Hide()`
- **Описание**: Скрытие фрейма.

#### `AdaptiveFrame:Show()`
- **Описание**: Отображение фрейма.

#### `AdaptiveFrame:GetSize()`
- **Описание**: Получение размеров фрейма.
- **Возвращает**: Ширина и высота фрейма.

#### `AdaptiveFrame:CheckFrameSize(width, height)`
- **Описание**: Проверка размера фрейма.
- **Параметры**:
  - `width`: Ширина.
  - `height`: Высота.
- **Возвращает**: Ширина и высота фрейма.

#### `AdaptiveFrame:AdjustSizeAndPosition()`
- **Описание**: Позиционирование и размеры кнопок.

#### `AdaptiveFrame:AddButtons(numButtons, buttonsPerRow, size, texture, highlightTexture)`
- **Описание**: Добавление массива кнопок на фрейм.
- **Параметры**:
  - `numButtons`: Количество кнопок.
  - `buttonsPerRow`: Количество кнопок в ряду.
  - `size`: Размер кнопок.
  - `texture`: Текстура кнопок.
  - `highlightTexture`: Текстура подсветки кнопок.

#### `AdaptiveFrame:StartMovementAlphaTracking()`
- **Описание**: Управление прозрачностью дочерних кнопок при движении персонажа.

#### `AdaptiveFrame:getTexture(id)`
- **Описание**: Получение текстуры кнопки.
- **Параметры**:
  - `id`: Идентификатор кнопки.
- **Возвращает**: Текстура кнопки.

#### `AdaptiveFrame:StopMovementAlphaTracking()`
- **Описание**: Остановка отслеживания движения и очистка скрипта.

#### `AdaptiveFrame:GetPosition()`
- **Описание**: Получение текущих координат фрейма относительно родителя.
- **Возвращает**: Координаты X и Y.

#### `AdaptiveFrame:SetPoint(x, y)`
- **Описание**: Установка координат фрейма.
- **Параметры**:
  - `x`: Координата X.
  - `y`: Координата Y.

#### `AdaptiveFrame:isVisible()`
- **Описание**: Проверка видимости фрейма.
- **Возвращает**: `true`, если фрейм видим, иначе `false`.

## Класс `PopupPanel`

### Описание
Класс `PopupPanel` предназначен для создания всплывающих панелей с кнопками.

### Методы

#### `PopupPanel:Create(buttonWidth, buttonHeight, buttonsPerRow, spacing)`
- **Описание**: Конструктор для создания новой панели.
- **Параметры**:
  - `buttonWidth`: Ширина кнопок.
  - `buttonHeight`: Высота кнопок.
  - `buttonsPerRow`: Количество кнопок в ряду.
  - `spacing`: Расстояние между кнопками (опционально).
- **Возвращает**: Новый объект `PopupPanel`.

#### `PopupPanel:CreateButtons(buttonDataList)`
- **Описание**: Создание кнопок на панели.
- **Параметры**:
  - `buttonDataList`: Список данных для кнопок.

#### `PopupPanel:Show(parentButton, secondaryTriggers)`
- **Описание**: Показ панели.
- **Параметры**:
  - `parentButton`: Родительская кнопка.
  - `secondaryTriggers`: Дополнительные триггеры (опционально).

## Класс `mDB`

### Описание
Класс `mDB` предназначен для работы с базой данных.

### Методы

#### `mDB:new()`
- **Описание**: Конструктор для создания нового объекта `mDB`.
- **Возвращает**: Новый объект `mDB`.

#### `mDB:getArg(index)`
- **Описание**: Получение значения по индексу.
- **Параметры**:
  - `index`: Индекс.
- **Возвращает**: Запрошенное значение.

#### `mDB:setArg(index, value)`
- **Описание**: Установка значения по индексу.
- **Параметры**:
  - `index`: Индекс.
  - `value`: Значение.

## Класс `UniversalInfoFrame`

### Описание
Класс `UniversalInfoFrame` предназначен для создания универсального информационного фрейма.

### Методы

#### `UniversalInfoFrame:new(updateInterval, saveTable)`
- **Описание**: Конструктор для создания нового объекта `UniversalInfoFrame`.
- **Параметры**:
  - `updateInterval`: Интервал обновления.
  - `saveTable`: Таблица для сохранения данных.
- **Возвращает**: Новый объект `UniversalInfoFrame`.

#### `UniversalInfoFrame:UpdateSettings(newInterval, newSaveTable)`
- **Описание**: Обновление настроек.
- **Параметры**:
  - `newInterval`: Новый интервал обновления.
  - `newSaveTable`: Новая таблица для сохранения данных.

#### `UniversalInfoFrame:OnReceiveDrag()`
- **Описание**: Обработка перетаскивания предмета на фрейм.

#### `UniversalInfoFrame:AddText(description, valueFunc, addToTop, isRestore, itemID)`
- **Описание**: Добавление текстового поля.
- **Параметры**:
  - `description`: Описание.
  - `valueFunc`: Функция для получения значения.
  - `addToTop`: Флаг добавления в верхнюю часть (опционально).
  - `isRestore`: Флаг восстановления (опционально).
  - `itemID`: Идентификатор предмета (опционально).

#### `UniversalInfoFrame:RemoveText(headerText, valueText)`
- **Описание**: Удаление текстового поля.
- **Параметры**:
  - `headerText`: Заголовок.
  - `valueText`: Значение.

#### `UniversalInfoFrame:UpdateTextPositions()`
- **Описание**: Обновление позиций текстовых полей.

#### `UniversalInfoFrame:UpdateTexts()`
- **Описание**: Обновление текстов.

#### `UniversalInfoFrame:UpdateFrameSize()`
- **Описание**: Обновление размера фрейма.

#### `UniversalInfoFrame:ToggleCollapse(headerText, valueText)`
- **Описание**: Сворачивание/разворачивание фрейма.
- **Параметры**:
  - `headerText`: Заголовок.
  - `valueText`: Значение.

#### `UniversalInfoFrame:OnUpdate(elapsed)`
- **Описание**: Обработка обновления фрейма.
- **Параметры**:
  - `elapsed`: Время, прошедшее с последнего обновления.

#### `UniversalInfoFrame:Show()`
- **Описание**: Отображение фрейма.

#### `UniversalInfoFrame:Hide()`
- **Описание**: Скрытие фрейма.

## Класс `ChatHandler`

### Описание
Класс `ChatHandler` предназначен для обработки сообщений в чате.

### Методы

#### `ChatHandler:new(triggersByAddress, chatTypes)`
- **Описание**: Конструктор для создания нового объекта `ChatHandler`.
- **Параметры**:
  - `triggersByAddress`: Триггеры по адресам.
  - `chatTypes`: Типы чатов (опционально).
- **Возвращает**: Новый объект `ChatHandler`.

#### `ChatHandler:OnChatMessage(event, ...)`
- **Описание**: Обработка сообщения в чате.
- **Параметры**:
  - `event`: Событие.
  - `...`: Дополнительные параметры.

#### `ChatHandler:CheckTrigger(trigger, text, sender, channel, prefix, event)`
- **Описание**: Проверка триггера.
- **Параметры**:
  - `trigger`: Триггер.
  - `text`: Текст сообщения.
  - `sender`: Отправитель.
  - `channel`: Канал.
  - `prefix`: Префикс.
  - `event`: Событие.
- **Возвращает**: `true`, если триггер сработал, иначе `false`.

## Класс `CustomAchievements`

### Описание
Класс `CustomAchievements` предназначен для работы с кастомными достижениями.

### Методы

#### `CustomAchievements:new(staticDataTable, dynamicDataTable)`
- **Описание**: Конструктор для создания нового объекта `CustomAchievements`.
- **Параметры**:
  - `staticDataTable`: Таблица статических данных.
  - `dynamicDataTable`: Таблица динамических данных.
- **Возвращает**: Новый объект `CustomAchievements`.

#### `CustomAchievements:GetAchievementData(name)`
- **Описание**: Получение данных ачивки по её имени.
- **Параметры**:
  - `name`: Имя ачивки.
- **Возвращает**: Данные ачивки.

#### `CustomAchievements:CreateNightWatchTab()`
- **Описание**: Создание вкладки "Ночная стража".

#### `CustomAchievements:CreateTextElement(parent, template, justify, point, relativeTo, relativePoint, x, y)`
- **Описание**: Создание текстового элемента.
- **Параметры**:
  - `parent`: Родительский фрейм.
  - `template`: Шаблон.
  - `justify`: Выравнивание.
  - `point`: Точка привязки.
  - `relativeTo`: Относительно какого элемента.
  - `relativePoint`: Точка привязки относительно элемента.
  - `x`: Смещение по X.
  - `y`: Смещение по Y.
- **Возвращает**: Текстовый элемент.

#### `CustomAchievements:CreateTextureElement(parent, layer, texture, width, height, point, relativeTo, relativePoint, x, y)`
- **Описание**: Создание текстуры.
- **Параметры**:
  - `parent`: Родительский фрейм.
  - `layer`: Слой.
  - `texture`: Текстура.
  - `width`: Ширина.
  - `height`: Высота.
  - `point`: Точка привязки.
  - `relativeTo`: Относительно какого элемента.
  - `relativePoint`: Точка привязки относительно элемента.
  - `x`: Смещение по X.
  - `y`: Смещение по Y.
- **Возвращает**: Текстура.

#### `CustomAchievements:SyncDynamicData()`
- **Описание**: Синхронизация динамических данных с новой структурой.

#### `CustomAchievements:IsStructureChanged()`
- **Описание**: Проверка изменения структуры данных.
- **Возвращает**: `true`, если структура изменилась, иначе `false`.

#### `CustomAchievements:CreateFrame(parent)`
- **Описание**: Создание основного фрейма.
- **Параметры**:
  - `parent`: Родительский фрейм.

#### `CustomAchievements:CreateCategoryButtons(parent)`
- **Описание**: Создание кнопок категорий.
- **Параметры**:
  - `parent`: Родительский фрейм.

#### `CustomAchievements:FilterAchievementsByCategory(category)`
- **Описание**: Фильтрация ачивок по категории.
- **Параметры**:
  - `category`: Категория.

#### `CustomAchievements:AddAchievement(name)`
- **Описание**: Добавление ачивки.
- **Параметры**:
  - `name`: Имя ачивки.

#### `CustomAchievements:UpdateUI(selectedCategory)`
- **Описание**: Обновление интерфейса с учетом выбранной категории.
- **Параметры**:
  - `selectedCategory`: Выбранная категория.

#### `CustomAchievements:UpdateScrollArea(totalHeight)`
- **Описание**: Обновление скроллируемой области.
- **Параметры**:
  - `totalHeight`: Общая высота.

#### `CustomAchievements:SendAchievementCompletionMessage(name)`
- **Описание**: Отправка сообщения о выполнении ачивки в чат.
- **Параметры**:
  - `name`: Имя ачивки.

#### `CustomAchievements:CreateAchievementButton(name, yOffset)`
- **Описание**: Создание кнопки ачивки.
- **Параметры**:
  - `name`: Имя ачивки.
  - `yOffset`: Смещение по Y.
- **Возвращает**: Кнопка ачивки.

#### `CustomAchievements:ShowAchievementTooltip(button, name)`
- **Описание**: Показ тултипа.
- **Параметры**:
  - `button`: Кнопка.
  - `name`: Имя ачивки.

#### `CustomAchievements:ExpandAchievement(button, name)`
- **Описание**: Раскрытие ачивки.
- **Параметры**:
  - `button`: Кнопка.
  - `name`: Имя ачивки.

#### `CustomAchievements:CreateNestedAchievementIcon(parent, achievement, index, x, y, size, spacing)`
- **Описание**: Создание иконки под-ачивки.
- **Параметры**:
  - `parent`: Родительский фрейм.
  - `achievement`: Ачивка.
  - `index`: Индекс.
  - `x`: Координата X.
  - `y`: Координата Y.
  - `size`: Размер.
  - `spacing`: Расстояние.

#### `CustomAchievements:NavigateToAchievement(id)`
- **Описание**: Навигация к достижению.
- **Параметры**:
  - `id`: Идентификатор ачивки.

#### `CustomAchievements:HideAchievements()`
- **Описание**: Скрытие ачивок.

#### `CustomAchievements:ShowAchievements()`
- **Описание**: Отображение ачивок.

#### `CustomAchievements:Show()`
- **Описание**: Отображение фрейма.

#### `CustomAchievements:Hide()`
- **Описание**: Скрытие фрейма.

#### `CustomAchievements:CreateCustomAlertFrame()`
- **Описание**: Создание кастомного фрейма уведомлений.
- **Возвращает**: Фрейм уведомлений.

#### `CustomAchievements:GetAchievementFullData(name)`
- **Описание**: Получение данных ачивки по её имени (объединяет статические и динамические данные).
- **Параметры**:
  - `name`: Имя ачивки.
- **Возвращает**: Данные ачивки.

#### `CustomAchievements:ShowAchievementAlert(achievementName)`
- **Описание**: Отображение уведомления о новой ачивке.
- **Параметры**:
  - `achievementName`: Имя ачивки.

#### `CustomAchievements:IsAchievement(name)`
- **Описание**: Проверка существования ачивки по имени.
- **Параметры**:
  - `name`: Имя ачивки.
- **Возвращает**: `true`, если ачивка существует, иначе `false`.

#### `CustomAchievements:GetAchievementCount()`
- **Описание**: Получение количества добавленных ачивок.
- **Возвращает**: Количество ачивок.

#### `CustomAchievements:setData(name, key, value)`
- **Описание**: Изменение данных динамической таблицы.
- **Параметры**:
  - `name`: Имя ачивки.
  - `key`: Ключ.
  - `value`: Значение.

## Класс `NSQCMenu`

### Описание
Класс `NSQCMenu` предназначен для создания и управления меню.

### Методы

#### `NSQCMenu:new(addonName, options)`
- **Описание**: Конструктор для создания нового объекта `NSQCMenu`.
- **Параметры**:
  - `addonName`: Имя аддона.
  - `options`: Опции (опционально).
- **Возвращает**: Новый объект `NSQCMenu`.

#### `NSQCMenu:addInfoSection(titleText, contentText)`
- **Описание**: Добавление информационной секции.
- **Параметры**:
  - `titleText`: Заголовок.
  - `contentText`: Содержание.

#### `NSQCMenu:wrapText(text, maxWidth, font)`
- **Описание**: Перенос текста.
- **Параметры**:
  - `text`: Текст.
  - `maxWidth`: Максимальная ширина.
  - `font`: Шрифт.
- **Возвращает**: Текст с переносами.

#### `NSQCMenu:getStringWidth(frame, text, font)`
- **Описание**: Получение ширины текста.
- **Параметры**:
  - `frame`: Фрейм.
  - `text`: Текст.
  - `font`: Шрифт.
- **Возвращает**: Ширина текста.

#### `NSQCMenu:addSubMenu(menuName)`
- **Описание**: Создание подменю.
- **Параметры**:
  - `menuName`: Имя подменю.
- **Возвращает**: Подменю.

#### `NSQCMenu:addSlider(parentMenu, options)`
- **Описание**: Добавление слайдера.
- **Параметры**:
  - `parentMenu`: Родительское меню.
  - `options`: Опции.

#### `NSQCMenu:addCheckbox(parentMenu, options)`
- **Описание**: Добавление чекбокса.
- **Параметры**:
  - `parentMenu`: Родительское меню.
  - `options`: Опции.

#### `NSQCMenu:updateScrollRange(parentMenu)`
- **Описание**: Обновление диапазона скролла.
- **Параметры**:
  - `parentMenu`: Родительское меню.