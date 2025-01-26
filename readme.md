# Документация по классам

## Класс `NsDb`

### Описание:
Класс `NsDb` предназначен для работы с таблицами данных, которые хранят строки и их индексы. Он позволяет добавлять строки, получать строки по индексу, а также проверять уникальность сообщений.

### Основные методы:

#### `NsDb:new(input_table, input_table_p, key, str_len, tbl_size)`
- **Описание**: Конструктор для создания нового объекта `NsDb`.
- **Параметры**:
  - `input_table`: Основная таблица для хранения данных.
  - `input_table_p`: Таблица-указатель для хранения дополнительных данных (опционально).
  - `key`: Ключ для доступа к данным в таблице.
  - `str_len`: Максимальная длина строки.
  - `tbl_size`: Размер таблицы.
- **Возвращает**: Новый объект `NsDb`.

#### `NsDb:getLine(line)`
- **Описание**: Получает строку по индексу.
- **Параметры**:
  - `line`: Индекс строки.
- **Возвращает**: Строку или `nil`, если строка не найдена.

#### `NsDb:create_bin(message, str)`
- **Описание**: Создает бинарное представление сообщения и добавляет его в таблицу.
- **Параметры**:
  - `message`: Сообщение для добавления.
  - `str`: Флаг, указывающий, нужно ли добавлять сообщение в существующую строку (0 — новая строка, 1 — добавление к существующей).

#### `NsDb:add_str(message)`
- **Описание**: Добавляет сообщение в таблицу.
- **Параметры**:
  - `message`: Сообщение для добавления.

#### `NsDb:add_line(message)`
- **Описание**: Добавляет строку в таблицу.
- **Параметры**:
  - `message`: Сообщение для добавления.

#### `NsDb:add_dict(message, kod)`
- **Описание**: Добавляет словарь в таблицу.
- **Параметры**:
  - `message`: Ключ словаря.
  - `kod`: Значение словаря.

#### `NsDb:add_fdict(msg)`
- **Описание**: Добавляет сообщение в хэш-таблицу.
- **Параметры**:
  - `msg`: Сообщение для добавления.

#### `NsDb:get_fdict(index)`
- **Описание**: Получает сообщение из хэш-таблицы по индексу.
- **Параметры**:
  - `index`: Индекс сообщения.
- **Возвращает**: Сообщение или `nil`, если индекс вне диапазона.

#### `NsDb:is_unique(message)`
- **Описание**: Проверяет уникальность сообщения в таблице.
- **Параметры**:
  - `message`: Сообщение для проверки.
- **Возвращает**: `true`, если сообщение уникально, иначе `false`.

#### `NsDb:pLen()`
- **Описание**: Возвращает длину таблицы-указателя.
- **Возвращает**: Длину таблицы или `nil`, если таблица-указатель отсутствует.

#### `NsDb:Len()`
- **Описание**: Возвращает длину основной таблицы.
- **Возвращает**: Длину таблицы.

#### `NsDb:mod_key(change_key, num, message)`
- **Описание**: Изменяет ключ в таблице.
- **Параметры**:
  - `change_key`: Новый ключ.
  - `num`: Номер строки.
  - `message`: Сообщение для добавления.

---

## Класс `create_table`

### Описание:
Класс `create_table` предназначен для создания и управления таблицами.

### Основные методы:

#### `create_table:new(input_table, is_pointer)`
- **Описание**: Конструктор для создания нового объекта `create_table`.
- **Параметры**:
  - `input_table`: Имя таблицы.
  - `is_pointer`: Флаг, указывающий, нужно ли создавать таблицу-указатель.
- **Возвращает**: Новый объект `create_table`.

#### `create_table:get_table()`
- **Описание**: Возвращает основную таблицу.
- **Возвращает**: Таблицу.

#### `create_table:get_table_p()`
- **Описание**: Возвращает таблицу-указатель.
- **Возвращает**: Таблицу-указатель.

---

## Класс `ButtonManager`

### Описание:
Класс `ButtonManager` предназначен для создания и управления кнопками в интерфейсе.

### Основные методы:

#### `ButtonManager:new(name, parent, width, height, text, texture, parentFrame)`
- **Описание**: Конструктор для создания новой кнопки.
- **Параметры**:
  - `name`: Имя кнопки.
  - `parent`: Родительский фрейм.
  - `width`: Ширина кнопки.
  - `height`: Высота кнопки.
  - `text`: Текст кнопки.
  - `texture`: Текстура кнопки (опционально).
  - `parentFrame`: Родительский фрейм для перемещения (опционально).
- **Возвращает**: Новый объект `ButtonManager`.

#### `ButtonManager:SetText(text)`
- **Описание**: Устанавливает текст на кнопке.
- **Параметры**:
  - `text`: Текст для отображения.

#### `ButtonManager:SetTextT(text)`
- **Описание**: Устанавливает текст на кнопке через `FontString`.
- **Параметры**:
  - `text`: Текст для отображения.

#### `ButtonManager:SetPosition(point, relativeTo, relativePoint, xOffset, yOffset)`
- **Описание**: Устанавливает позицию кнопки.
- **Параметры**:
  - `point`: Точка привязки.
  - `relativeTo`: Относительный фрейм.
  - `relativePoint`: Относительная точка.
  - `xOffset`: Смещение по X.
  - `yOffset`: Смещение по Y.

#### `ButtonManager:Hide()`
- **Описание**: Скрывает кнопку.

#### `ButtonManager:Show()`
- **Описание**: Отображает кнопку.

#### `ButtonManager:SetOnClick(onClickFunction)`
- **Описание**: Устанавливает обработчик нажатия на кнопку.
- **Параметры**:
  - `onClickFunction`: Функция, которая будет вызвана при нажатии.

#### `ButtonManager:SetTooltip(text)`
- **Описание**: Добавляет всплывающую подсказку к кнопке.
- **Параметры**:
  - `text`: Текст подсказки.

#### `ButtonManager:SetSize(width, height)`
- **Описание**: Изменяет размер кнопки.
- **Параметры**:
  - `width`: Новая ширина.
  - `height`: Новая высота.

#### `ButtonManager:SetMovable(parentFrame)`
- **Описание**: Делает кнопку перемещаемой.
- **Параметры**:
  - `parentFrame`: Родительский фрейм для перемещения.

---

## Класс `AdaptiveFrame`

### Описание:
Класс `AdaptiveFrame` предназначен для создания адаптивного фрейма, который автоматически изменяет свои размеры в зависимости от содержимого.

### Основные методы:

#### `AdaptiveFrame:Create(parent, initialWidth, initialHeight)`
- **Описание**: Создает новый адаптивный фрейм.
- **Параметры**:
  - `parent`: Родительский фрейм.
  - `initialWidth`: Начальная ширина фрейма (опционально).
  - `initialHeight`: Начальная высота фрейма (опционально).
- **Возвращает**: Новый объект `AdaptiveFrame`.

#### `AdaptiveFrame:AddChild(child)`
- **Описание**: Добавляет дочерний элемент в фрейм.
- **Параметры**:
  - `child`: Дочерний элемент.

#### `AdaptiveFrame:UpdateSize()`
- **Описание**: Обновляет размер фрейма в зависимости от содержимого.

#### `AdaptiveFrame:AddGrid(buttons, num, columns, spacing)`
- **Описание**: Добавляет кнопки в сетку.
- **Параметры**:
  - `buttons`: Таблица кнопок.
  - `num`: Количество кнопок.
  - `columns`: Количество столбцов.
  - `spacing`: Расстояние между кнопками (опционально).

#### `AdaptiveFrame:ResizeButtons()`
- **Описание**: Изменяет размер кнопок в зависимости от размера фрейма.

---

## Класс `UniversalInfoFrame`

### Описание:
Класс `UniversalInfoFrame` предназначен для создания фрейма, который отображает информацию и может сворачиваться/разворачиваться.

### Основные методы:

#### `UniversalInfoFrame:new(updateInterval, saveTable)`
- **Описание**: Конструктор для создания нового объекта `UniversalInfoFrame`.
- **Параметры**:
  - `updateInterval`: Интервал обновления информации (опционально).
  - `saveTable`: Таблица для сохранения данных (опционально).
- **Возвращает**: Новый объект `UniversalInfoFrame`.

#### `UniversalInfoFrame:UpdateSettings(newInterval, newSaveTable)`
- **Описание**: Обновляет настройки фрейма.
- **Параметры**:
  - `newInterval`: Новый интервал обновления.
  - `newSaveTable`: Новая таблица для сохранения данных.

#### `UniversalInfoFrame:OnReceiveDrag()`
- **Описание**: Обрабатывает перетаскивание предмета на фрейм.

#### `UniversalInfoFrame:AddText(description, valueFunc, addToTop, isRestore, itemID)`
- **Описание**: Добавляет текстовое поле в фрейм.
- **Параметры**:
  - `description`: Описание текста.
  - `valueFunc`: Функция для получения значения.
  - `addToTop`: Флаг, указывающий, нужно ли добавлять текст в верхнюю часть фрейма.
  - `isRestore`: Флаг, указывающий, что это восстановление данных (опционально).
  - `itemID`: ID предмета (опционально).

#### `UniversalInfoFrame:RemoveText(headerText, valueText)`
- **Описание**: Удаляет текстовое поле из фрейма.
- **Параметры**:
  - `headerText`: Заголовок текста.
  - `valueText`: Значение текста.

#### `UniversalInfoFrame:UpdateTextPositions()`
- **Описание**: Обновляет позиции текстовых полей.

#### `UniversalInfoFrame:UpdateTexts()`
- **Описание**: Обновляет текстовые поля.

#### `UniversalInfoFrame:UpdateFrameSize()`
- **Описание**: Обновляет размер фрейма.

#### `UniversalInfoFrame:ToggleCollapse(headerText, valueText)`
- **Описание**: Сворачивает/разворачивает фрейм.
- **Параметры**:
  - `headerText`: Заголовок текста.
  - `valueText`: Значение текста.

#### `UniversalInfoFrame:OnUpdate(elapsed)`
- **Описание**: Обрабатывает обновление фрейма.
- **Параметры**:
  - `elapsed`: Время, прошедшее с последнего обновления.

#### `UniversalInfoFrame:Show()`
- **Описание**: Отображает фрейм.

#### `UniversalInfoFrame:Hide()`
- **Описание**: Скрывает фрейм.

---

## Класс `ChatHandler`

### Описание:
Класс `ChatHandler` предназначен для обработки сообщений чата и выполнения триггеров на основе ключевых слов.

### Основные методы:

#### `ChatHandler:new(triggersByAddress, chatTypes)`
- **Описание**: Конструктор для создания нового объекта `ChatHandler`.
- **Параметры**:
  - `triggersByAddress`: Ассоциативная таблица триггеров, сгруппированных по адресу.
  - `chatTypes`: Типы чатов, которые нужно отслеживать (опционально).
- **Возвращает**: Новый объект `ChatHandler`.

#### `ChatHandler:OnChatMessage(event, ...)`
- **Описание**: Обрабатывает сообщения чата.
- **Параметры**:
  - `event`: Тип события (например, `"CHAT_MSG_SAY"`).
  - `...`: Параметры события (текст, отправитель и т.д.).

#### `ChatHandler:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix)`
- **Описание**: Проверяет триггер на соответствие сообщению.
- **Параметры**:
  - `trigger`: Триггер для проверки.
  - `msg`: Таблица слов из сообщения.
  - `kodmsg`: Таблица слов из префикса (для ADDON-сообщений).
  - `text`: Полный текст сообщения.
  - `sender`: Имя отправителя.
  - `channel`: Канал сообщения.
  - `prefix`: Префикс сообщения (для ADDON-сообщений).
- **Возвращает**: `true`, если дальнейшая обработка должна быть прервана, иначе `false`.

---

Это полная документация по всем классам, представленным в вашем файле `classes.lua`. Вы можете использовать её для дальнейшей работы и разработки.