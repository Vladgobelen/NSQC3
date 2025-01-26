-- Локальные функции и переменные для оптимизации
local pairs = pairs
local table_insert = table.insert
local string_gmatch = string.gmatch
local string_lower = string.lower
local utf8sub = string.utf8sub
local math_abs = math.abs
local math_floor = math.floor
local utf8len = string.utf8len

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

-- Таблица для конвертации чисел в символы
local _convertTable = {
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

-- Обратная таблица для быстрого поиска
local _reverseConvertTable = {}
for k, v in pairs(_convertTable) do
    _reverseConvertTable[v] = k
end

-- Функция для преобразования десятичного числа в строку в 90-ричной системе
local function Convert(dec, base)
    local result = ""
    repeat
        local remainder = dec % base
        result = _convertTable[remainder] .. result
        dec = math_floor(dec / base)
    until dec == 0
    return result
end

-- Функция для кодирования числа в строку
function numCod(dec)
    dec = math_abs(dec)
    return Convert(dec, 85)
end

-- Функция для декодирования строки в число
function numeCod(encoded)
    local number = 0
    for i = 1, #encoded do
        local char = encoded:sub(i, i)
        local value = _reverseConvertTable[char] or 0
        number = number * 85 + value
    end
    return number
end

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

function deCryptStr(tbl)
    local result = ""
    for i = 1, #tbl do
        local element = tbl[i]
        -- Заменяем 𐑏 на пробел
        if element == "𐑏" then
            result = result .. " "
        else
            for j = 1, #deCode do
                if deCode[j][element] then
                    result = result .. deCode[j][element]
                    break
                end
            end
        end
    end
    return result
end

-- Функция для шифрования строки
function cryptStr(msg)
    local result = {}
    for i = 1, #msg do
        local word = string_lower(msg[i])  -- Приводим слово к нижнему регистру
        if word == "𐑏" then
            word = " "
        end
        local encryptedWord
        for j = 1, #NSQS_dict["словарь"] do
            encryptedWord = NSQS_dict["словарь"][j][word]
            if encryptedWord then
                break  -- Прерываем поиск, если слово найдено
            end
        end
        result[#result + 1] = encryptedWord
    end
    return table.concat(result, "")  -- Возвращаем строку с кодами, разделенными пробелами
end

function NSQCMenu()
    local optionsFrame = CreateFrame("Frame", "NSQSMenu", InterfaceOptionsFramePanelContainer)
    optionsFrame.name = "NSQC"  -- Имя для меню
    optionsFrame:Hide()

    local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Настройки NSQC")

    -- Опция для изменения размера окна
    local sizeSlider = CreateFrame("Slider", "HelloWorldSizeSlider", optionsFrame, "OptionsSliderTemplate")
    sizeSlider:SetPoint("TOPLEFT", 16, -50)
    sizeSlider:SetMinMaxValues(100, 500)  -- Минимум и максимум
    sizeSlider:SetValue(200)  -- Значение по умолчанию
    sizeSlider:SetValueStep(10)  -- Шаг
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        frame:SetSize(value, 100)  -- Изменяем размер окна
        print("Размер окна изменен на: " .. value)
    end)

    local sizeLabel = sizeSlider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sizeLabel:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -5)
    sizeLabel:SetText("Размер окна")

    -- Опция для фиксации позиции окна
    local lockCheckbox = CreateFrame("CheckButton", "HelloWorldLockCheckbox", optionsFrame, "ChatConfigCheckButtonTemplate")
    lockCheckbox:SetPoint("TOPLEFT", 16, -100)
    lockCheckbox:SetChecked(false)

    -- Убедимся, что текст для чекбокса установлен
    local lockCheckboxText = lockCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lockCheckboxText:SetPoint("LEFT", lockCheckbox, "RIGHT", 5, 0)
    lockCheckboxText:SetText("Фиксировать позицию окна")

    lockCheckbox:SetScript("OnClick", function(self)
        frame:SetMovable(not self:GetChecked())
        print(self:GetChecked() and "Позиция окна зафиксирована." or "Позиция окна разблокирована.")
    end)

    InterfaceOptions_AddCategory(optionsFrame)
end

function set_miniButton()
    -- Создаем фрейм для иконки
    local miniMapButton = CreateFrame("Button", nil, Minimap)
    miniMapButton:SetSize(32, 32)  -- Размер иконки
    miniMapButton:SetFrameLevel(8)  -- Уровень фрейма
    miniMapButton:SetMovable(true)  -- Разрешаем перемещение

    -- Устанавливаем текстуры для иконки
    miniMapButton:SetNormalTexture("Interface\\AddOns\\NSQC\\emblem.tga")
    miniMapButton:SetPushedTexture("Interface\\AddOns\\NSQC\\emblem.tga")
    miniMapButton:SetHighlightTexture("Interface\\AddOns\\NSQC\\emblem.tga")

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
        -- Сохраняем позицию
        NSQC_SavedData = NSQC_SavedData or {}
        NSQC_SavedData.angle = position.angle
        NSQC_SavedData.radius = position.radius
    end)

    -- Восстановление позиции иконки после перезагрузки
    local function SetInitialPosition()
        miniMapButton:ClearAllPoints()
        miniMapButton:SetPoint(
            "CENTER",
            Minimap,
            "CENTER",
            position.radius * math.cos(position.angle),
            position.radius * math.sin(position.angle)
        )
    end

    SetInitialPosition()  -- Устанавливаем начальную позицию
end
















