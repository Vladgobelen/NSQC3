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
    C_Timer(2, function()
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
    miniMapButton = CreateFrame("Button", nil, Minimap)
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
        GameTooltip:Show()
    end

    -- Добавляем обработчики для тултипа
    miniMapButton:SetScript("OnEnter", function(self)
        CreateTooltip(self)
    end)

    miniMapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    miniMapButton:SetScript("OnClick", function(self)
        if FriendsFrame:IsVisible() then
            FriendsFrameCloseButton:Click()
        end
        sendAch("Великий открыватор", -1)
        mFldName = GetUnitName("player")
        SendAddonMessage("getFld " .. mFldName, "", "guild")
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
-- C_Timer Emulation — FULLY BACKWARDS COMPATIBLE for WoW 3.3.5
-- Supports:
--   C_Timer.After(duration, callback)
--   C_Timer.NewTicker(duration, callback, iterations)
--   C_Timer(duration, callback, isLooping) → via __call
--   timer:Cancel() on all returned timer objects
-- Fixes:
--   "attempt to index global 'C_Timer' (a function value)"
--   "attempt to call global 'C_Timer' (a table value)"
-- Place this at the VERY TOP of your addon (main.lua)
-- ============================================================================

do
    local existing_C_Timer = _G.C_Timer

    -- Создаём базовую таблицу C_Timer
    local C_Timer = {
        _activeTimers = {}  -- для отладки (опционально)
    }

    -- Вспомогательная функция для безопасной отмены таймера
    local function cancelTimer(timerFrame)
        if not timerFrame or timerFrame.isCancelled then return end
        timerFrame.isCancelled = true
        timerFrame:SetScript("OnUpdate", nil)
        -- Удаляем из активных (если отслеживаем)
        for i, t in ipairs(C_Timer._activeTimers) do
            if t == timerFrame then
                table.remove(C_Timer._activeTimers, i)
                break
            end
        end
    end

    -- Реализация C_Timer.After — однократный вызов через duration
    function C_Timer.After(duration, callback)
        if type(callback) ~= "function" then return end
        if type(duration) ~= "number" or duration < 0 then duration = 0 end

        local timerFrame = CreateFrame("Frame")
        timerFrame.elapsed = 0
        timerFrame.isCancelled = false

        -- Метод отмены
        function timerFrame:Cancel()
            cancelTimer(self)
        end

        timerFrame:SetScript("OnUpdate", function(self, elapsed)
            if self.isCancelled then return end
            self.elapsed = self.elapsed + elapsed
            if self.elapsed >= duration then
                if not self.isCancelled and type(callback) == "function" then
                    callback()
                end
                cancelTimer(self)
            end
        end)

        table.insert(C_Timer._activeTimers, timerFrame)
        return timerFrame
    end

    -- Реализация C_Timer.NewTicker — повторяющийся таймер
    function C_Timer.NewTicker(duration, callback, iterations)
        if type(callback) ~= "function" then return end
        if type(duration) ~= "number" or duration < 0 then duration = 0 end

        local ticker = {
            _remaining = iterations or math.huge,
            Cancel = function(self)
                self._remaining = 0
            end
        }

        local function tick()
            if ticker._remaining <= 0 then return end
            if type(callback) == "function" then
                callback()
            end
            ticker._remaining = ticker._remaining - 1
            if ticker._remaining > 0 then
                C_Timer.After(duration, tick)
            end
        end

        C_Timer.After(duration, tick)
        return ticker
    end

    -- Совместимость: C_Timer.NewTimer (если используется)
    function C_Timer.NewTimer(duration, callback)
        return C_Timer.After(duration, callback)
    end

    -- Метаметод __call — чтобы можно было вызывать C_Timer как функцию
    setmetatable(C_Timer, {
        __call = function(_, duration, callback, isLooping)
            if isLooping then
                return C_Timer.NewTicker(duration, callback)
            else
                return C_Timer.After(duration, callback)
            end
        end
    })

    -- Восстанавливаем/устанавливаем глобальный C_Timer
    _G.C_Timer = C_Timer

    -- Эмуляция GetServerTime, если отсутствует (для полной совместимости)
    if not _G.GetServerTime then
        _G.GetServerTime = function()
            return time()
        end
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

    C_Timer(0.3, function()
        set = true
    end)
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
    -- Сборка строки в правильном порядке (обратном)
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

-- Определяет количество байт, занимаемых UTF-8 символом (без изменения логики)
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

-- Извлекает подстроку из UTF-8 строки с оптимизациями
function utf8mySub(s, i, j)
    if type(s) ~= "string" then
        error("bad argument #1 to 'utf8sub' (string expected)")
    end
    if type(i) ~= "number" or type(j) ~= "number" then
        error("bad arguments #2 and/or #3 to 'utf8sub' (numbers expected)")
    end

    local bytes = strlen(s)
    local startChar, endChar = i, j
    local charPositions -- Таблица для кэширования позиций символов при необходимости

    -- Обработка отрицательных индексов и вычисление длины
    if i < 0 or j < 0 then
        charPositions = {}
        local len = 0
        local pos = 1
        while pos <= bytes do
            local charBytes = utf8charbytes(s, pos)
            len = len + 1
            charPositions[len] = pos -- Сохраняем позицию символа
            pos = pos + charBytes
        end
        -- Корректируем индексы
        startChar = (i < 0) and (len + i + 1) or i
        endChar = (j < 0) and (len + j + 1) or j
        -- Ограничиваем endChar до максимума и корректируем startChar
        endChar = math.min(endChar, len)
        startChar = math.max(startChar, 1)
    end

    -- Проверка невалидных границ
    if startChar > endChar then
        return ""
    end

    -- Поиск байтовых позиций
    local startByte, endByte
    if charPositions then
        -- Используем кэшированные позиции
        startByte = charPositions[startChar]
        local endPos = charPositions[endChar]
        endByte = endPos + utf8charbytes(s, endPos) - 1
    else
        -- Стандартный поиск
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
    -- добавляем текущее время
    table.insert(messageBuffer[bufferKey], message)
    -- проверям текущий час
    if HOUR then
        local myUnixTime = table.concat(messageBuffer[bufferKey])
        messageBuffer[bufferKey] = nil
        -- получаем форматированное время (минуты, секунды)
        local minutes, seconds = loadstring(myUnixTime)
        if minutes then
            -- записываем сообщение в лог
            local success, result = pcall(minutes)
        end
    end
end

function move(saveTable)
    local frame = GetMouseFocus()
    if not frame or not frame.GetName then return end
    
    local frameName = frame:GetName()
    saveTable = saveTable or {}

    if not frame.moveToggle then
        -- Включение перемещения
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local point, _, relPoint, x, y = self:GetPoint()
            saveTable[frameName] = {point, relPoint, x, y}
            print(string.format("Позиция сохранена: %s (%.1f, %.1f)", frameName, x, y))
        end)
        
        frame.moveToggle = true
    else
        -- Выключение перемещения
        frame:SetMovable(false)
        frame:EnableMouse(false)
        frame:SetScript("OnDragStart", nil)
        frame:SetScript("OnDragStop", nil)
        frame.moveToggle = nil
    end
    
    return saveTable
end

function RestoreFramePositions(saveTable)
    if not saveTable then return end
    
    for frameName, posData in pairs(saveTable) do
        local frame = _G[frameName]
        if frame and frame.ClearAllPoints then
            frame:ClearAllPoints()
            frame:SetPoint(posData[1], UIParent, posData[2], posData[3], posData[4])
        end
    end
end

function remove()
    move(nsDbc['frames'])
end

function resetF()
    nsDbc['frames'] = nil
end

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
        C_Timer(1, function()
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
    if testQ["метка охотника"] then
        if classUnit == "HUNTER" then
            for slot = 1, 24, 1 do
                local debuffName = UnitDebuff("target", slot);
                if debuffName == "Метка охотника" then
                    for trackingIndex = 1, GetNumTrackingTypes(), 1 do
                        local name, texture, active, category = GetTrackingInfo(trackingIndex);
                        if UnitCreatureType("target") ~= nil then
                            if string.find(name, string.utf8sub(UnitCreatureType("target"), 2, 6)) then
                                if texture ~= GetTrackingTexture(trackingIndex) then
                                    SetTracking(trackingIndex);
                                end;
                            end;
                        end;
                    end;
                end;
            end;
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






local frame = CreateFrame("Frame", "RandomRouteTexture", WorldMapFrame)
frame:SetAllPoints(WorldMapFrame)

local texture = frame:CreateTexture(nil, "OVERLAY")
texture:SetTexture("Interface\\AddOns\\NSQC3\\libs\\121212.tga")
texture:SetWidth(32)
texture:SetHeight(32)
texture:SetBlendMode("ADD")

-- Функция для получения безопасных координат с учетом размера текстуры
local function GetSafeCoordinates(x, y)
    local mapWidth = WorldMapFrame:GetWidth()
    local mapHeight = WorldMapFrame:GetHeight()
    
    -- Рассчитываем минимальные и максимальные координаты с учетом размера текстуры
    local minX = texture:GetWidth() / 2 / mapWidth
    local maxX = 1 - minX
    local minY = texture:GetHeight() / 2 / mapHeight
    local maxY = 1 - minY
    
    -- Ограничиваем координаты безопасными значениями
    local safeX = math.max(minX, math.min(maxX, x))
    local safeY = math.max(minY, math.min(maxY, y))
    
    return safeX, safeY
end

-- Генерация случайных точек в безопасной зоне
local function GenerateRandomPath(segments)
    local points = {}
    for i = 1, segments do
        local x, y = GetSafeCoordinates(math.random(), math.random())
        points[i] = {
            x = x,
            y = y
        }
    end
    table.sort(points, function(a, b) 
        return (a.x + a.y) < (b.x + b.y)
    end)
    return points
end

-- Безопасные стартовая и конечная точки
local startX, startY = GetSafeCoordinates(0, 0)
local endX, endY = GetSafeCoordinates(1, 1)

-- Анимация движения
local function StartAnimation()
    local path = GenerateRandomPath(5)
    local duration = 20
    local startTime = GetTime()
    
    local function OnUpdate()
        local elapsed = GetTime() - startTime
        local progress = elapsed / duration
        
        if progress > 1 then
            -- Финальная позиция (безопасная)
            texture:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 
                endX * WorldMapFrame:GetWidth(), 
                -endY * WorldMapFrame:GetHeight())
            frame:SetScript("OnUpdate", nil)
            return
        end
        
        -- Интерполяция между точками пути
        local totalSegments = #path + 1
        local segmentProgress = progress * totalSegments
        local currentSegment = math.floor(segmentProgress)
        local segmentFraction = segmentProgress - currentSegment
        
        local x1, y1, x2, y2
        
        if currentSegment == 0 then
            x1, y1 = startX, startY
            x2, y2 = path[1].x, path[1].y
        elseif currentSegment >= #path then
            x1, y1 = path[#path].x, path[#path].y
            x2, y2 = endX, endY
        else
            x1, y1 = path[currentSegment].x, path[currentSegment].y
            x2, y2 = path[currentSegment + 1].x, path[currentSegment + 1].y
        end
        
        local currentX = x1 + (x2 - x1) * segmentFraction
        local currentY = y1 + (y2 - y1) * segmentFraction
        
        -- Обеспечиваем безопасные координаты на каждом кадре
        local safeX, safeY = GetSafeCoordinates(currentX, currentY)
        
        texture:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 
            safeX * WorldMapFrame:GetWidth(), 
            -safeY * WorldMapFrame:GetHeight())
    end
    
    -- Начальная позиция (безопасная)
    texture:SetPoint("CENTER", WorldMapFrame, "TOPLEFT", 
        startX * WorldMapFrame:GetWidth(), 
        -startY * WorldMapFrame:GetHeight())
    
    frame:SetScript("OnUpdate", OnUpdate)
end

-- Запуск анимации при открытии карты
WorldMapFrame:HookScript("OnShow", StartAnimation)

-- Остановка анимации при закрытии карты
WorldMapFrame:HookScript("OnHide", function()
    frame:SetScript("OnUpdate", nil)
end)



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

-- === NSQC3: DELETE VIA CREATE EVENT FRAME ONLY ===
if _G.NSQC3_CALENDAR_DEL_HOOKED then return end
_G.NSQC3_CALENDAR_DEL_HOOKED = true

local function TryHookContextMenu()
    if not _G.CalendarContextMenu then
        C_Timer.After(0.1, TryHookContextMenu)
        return
    end

    if _G.CalendarContextMenu.ns_hooked_del then return end

    local orig_OnShow = _G.CalendarContextMenu:GetScript("OnShow")
    _G.CalendarContextMenu:SetScript("OnShow", function(self)
        if orig_OnShow then orig_OnShow(self) end

        C_Timer.After(0.02, function()
            -- НЕ смотрим на eventButton! Просто показываем кнопку всегда в меню события
            local btn = _G["CalendarContextMenuButton7"]
            if not btn then return end

            btn:SetText("Удалить с сервера")
            btn:Show()

            if not btn.ns_hooked_del then
                btn:SetScript("OnClick", function()
                    -- === Берём ВСЁ только из CreateEventFrame ===
                    local createFrame = _G.CalendarCreateEventFrame
                    if not (createFrame and createFrame:IsVisible()) then
                        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[NSQC3] Окно редактирования не открыто.|r")
                        HideUIPanel(_G.CalendarContextMenu)
                        return
                    end

                    local titleEdit = _G.CalendarCreateEventTitleEdit
                    local title = titleEdit and titleEdit:GetText() or ""
                    if title == "" then
                        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[NSQC3] Название события пусто.|r")
                        HideUIPanel(_G.CalendarContextMenu)
                        return
                    end

                    -- Получаем дату из CalendarFrame (как в твоей функции создания)
                    local calFrame = _G.CalendarFrame
                    local year, month, day
                    if calFrame and calFrame.selectedYear then
                        year, month, day = calFrame.selectedYear, calFrame.selectedMonth, calFrame.selectedDay
                    else
                        local t = date("*t")
                        year, month, day = t.year, t.month, t.day
                    end
                    local dateStr = string.format("%04d-%02d-%02d", year, month, day)

                    -- Отправка
                    SendAddonMessage("ns_calendar_del", dateStr .. "|" .. title, "GUILD")
                    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[NSQC3] Удалено: " .. dateStr .. " | " .. title .. "|r")
                    HideUIPanel(_G.CalendarContextMenu)
                end)
                btn.ns_hooked_del = true
            end

            self:SetHeight(132)
        end)
    end)

    _G.CalendarContextMenu.ns_hooked_del = true
end

TryHookContextMenu()
-- === END ===