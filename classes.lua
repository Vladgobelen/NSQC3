-- Локальные переменные для оптимизации
local pairs = pairs
local table_insert = table.insert
local setmetatable = setmetatable
local utf8len = utf8myLen
local CreateFrame = CreateFrame
local tonumber = tonumber
local utf8sub = utf8mySub
local ipairs = ipairs
local gmatch = string.gmatch
local en85 = en85
local en10 = en10
local string_utf8sub = utf8mySub
local string_utf8len = utf8myLen
local str_rep = string.rep
local str_sub = string.sub

-- Определяем класс NsDb
NsDb = {}
NsDb.__index = NsDb

-- Конструктор для создания нового объекта NsDb
function NsDb:new(input_table, input_table_p, key, str_len)
    local new_object = setmetatable({}, self)
    new_object:init(input_table, input_table_p, key, str_len)
    return new_object
end

-- Инициализация объекта
function NsDb:init(input_table, input_table_p, key, str_len)
    self.input_table = self:initializeTable(input_table, key)
    if input_table_p then
        self.input_table_p = self:initializeTable(input_table_p, key)
    end
    if str_len then
        self.str_len = str_len
    end
    self.isPointer = input_table_p and true or false

    -- Инициализация переменных состояния
    if self.isPointer then
        if #self.input_table_p == 0 then
            self.last_str_addr = 0
            self.str_count = 0
        else
            -- Считаем количество строк и размер последней строки
            self.str_count = 0
            self.last_str_addr = en10(self.input_table_p[#self.input_table_p]:sub(-2):gsub("^%s", ""))
            for i = 1, #self.input_table_p do
                self.str_count = self.str_count + 1
            end
        end
    end
end

-- Вспомогательная функция для инициализации таблиц
function NsDb:initializeTable(input_table, key)
    if key then
        input_table[key] = input_table[key] or {}
        return input_table[key]
    else
        return input_table or {}
    end
end

-- Добавление или обновление строки
function NsDb:addStaticStr(nik, nStr, nArg, message)
    self.input_table[nik] = self.input_table[nik] or {}

    if not nArg then
        self.input_table[nik][nStr] = message
        return
    end

    -- Обновляем строку
    local currentStr = self.input_table[nik][nStr]
    self.input_table[nik][nStr] = currentStr:sub(1, (nArg - 1) * 3)
                                .. ("   " .. message):sub(-3)
                                .. currentStr:sub(nArg * 3 + 1)
end

function NsDb:getStaticStr(nik, nStr, nArg)
    local str = self.input_table 
              and self.input_table[nik] 
              and self.input_table[nik][nStr]
    
    return str and (nArg and str_sub(str, (nArg-1)*3 + 1, nArg*3) or str)
end

function NsDb:addStr(message)
    local msg_len = utf8len(message) -- Длина входящего сообщения
    -- Если адрес последней строки превысил лимит или это первая строка
    if self.last_str_addr >= self.str_len or self.str_count == 0 then
        -- Добавляем новую строку в основной массив
        self.input_table[#self.input_table + 1] = message
        
        -- Кодируем длину и форматируем до 3 символов
        local encoded_len = ("   "..en85(msg_len)):sub(-3)
        -- Добавляем в таблицу указателей
        self.input_table_p[#self.input_table_p + 1] = encoded_len
    else
        -- Дописываем к последней существующей строке
        self.input_table[#self.input_table] = self.input_table[#self.input_table] .. message
        
        -- Кодируем новую конечную позицию
        print('333',self.last_str_addr, msg_len)
        local encoded_len = ("   "..en85(self.last_str_addr + msg_len)):sub(-3)
        
        -- Обновляем последний указатель
        self.input_table_p[#self.input_table_p] = self.input_table_p[#self.input_table_p] .. encoded_len
    end
    
    -- Обновляем состояние
    self.last_str_addr = utf8len(self.input_table[#self.input_table])
    self.str_count = #self.input_table_p
end

function NsDb:getStr(n)
    if not self.isPointer or n < 1 then return nil end
    
    local buff = 0 -- Накопитель смещения между блоками
    
    -- Ищем нужный блок указателей
    for i = 1, #self.input_table_p do
        local block_size = #self.input_table_p[i] / 3  -- Количество указателей в блоке
        
        -- Проверяем попадание в текущий блок
        if n > block_size + buff then
            buff = buff + block_size
        else
            -- Вычисляем позиции в строке указателей
            local start_pos = (n - 1 - buff - 1) * 3 + 1
            local end_pos = (n - buff - 1) * 3 + 1 + 2
            
            -- Извлекаем и декодируем адреса
            local start_str = self.input_table_p[i]:sub(start_pos, start_pos + 2):match("%S+.*")
            local end_str = self.input_table_p[i]:sub(end_pos - 2, end_pos):match("%S+.*")
            -- Возвращаем подстроку из основного хранилища
            return utf8sub(
                self.input_table[i], 
                en10(start_str) + 1,  -- +1 из-за индексации с 1
                en10(end_str)
            )
        end
    end
end

-- function NsDb:getStr(n)
--     if not self.isPointer or n < 1 then return nil end

--     -- 1. Поиск нужной строки с адресами
--     local totalAddr, addressStr, strIndex, relIndex = 0, nil, 0, 0
--     for i, str in ipairs(self.input_table_p) do
--         local count = math.floor(utf8len(str) / 2) -- кол-во адресов в строке (замена // на math.floor)
--         if totalAddr + count >= n then
--             relIndex = n - totalAddr    -- относительный индекс в строке
--             addressStr, strIndex = str, i
--             break
--         end
--         totalAddr = totalAddr + count
--     end
--     if not addressStr then return nil end

--     -- 2. Извлечение конкретного адреса
--     local addrPos = (relIndex - 1) * 2 + 1
--     local addr = utf8sub(addressStr, addrPos, addrPos + 1)

--     -- 3. Обработка адреса (удаление пробела)
--     if utf8sub(addr, 1, 1) == ' ' then
--         addr = utf8sub(addr, 2, 2)
--     end
--     local length = en10(addr) -- получаем длину данных

--     -- 4. Извлечение данных из соответствующей строки
--     local dataChunk = self.input_table[strIndex]
--     if not dataChunk then return nil end

--     -- 5. Вычисляем стартовую позицию только в текущем чанке
--     local start = 0
--     for i = 1, relIndex - 1 do
--         local pos = (i - 1) * 2 + 1
--         local a = utf8sub(addressStr, pos, pos + 1)
--         if utf8sub(a, 1, 1) == ' ' then a = utf8sub(a, 2, 2) end
--         start = start + en10(a)
--     end

--     -- 6. Возвращаем данные из текущего чанка
--     return utf8sub(dataChunk, start + 1, start + length)
-- end

-- Метод для создания бинарного представления сообщения
function NsDb:create_bin(message, str)
    local pointer = en85(utf8len(message))
    pointer = (string.len(pointer) < 2) and " " .. pointer or pointer
    if str == 0 then
        table_insert(self.input_table, message)
        table_insert(self.input_table_p, pointer)
    else
        self.input_table[#self.input_table] = self.input_table[#self.input_table] .. message
        self.input_table_p[#self.input_table_p] = self.input_table_p[#self.input_table_p] .. pointer
    end
end

-- Метод для добавления сообщения в таблицу
function NsDb:add_str(message)
    local num = #self.input_table
    if num < 1 or utf8len(self.input_table[num]) >= self.str_len then
        self:create_bin(message, 0)
    else
        self:create_bin(message, 1)
    end
end

function NsDb:add_line(message)
    local num = #self.input_table
    if num < 1 then
        self.input_table[num + 1] = {}
        self.input_table[num + 1][#self.input_table[num + 1] + 1] = message
    else
        self.input_table[num][#self.input_table[num] + 1] = message
    end
end

-- Метод для добавления словаря
function NsDb:add_dict(message, kod)
    local num = #self.input_table
    if num < 1 or tablelength(self.input_table[num]) >= self.str_len then
        self.input_table[num + 1] = {}
        self.input_table[num + 1][message] = kod
    else
        self.input_table[num][message] = kod
    end
end

-- Метод для добавления сообщения в хэш-таблицу
function NsDb:add_fdict(msg)
    local num = #self.input_table
    local pointer = numCod(#msg)
    pointer = (string.len(pointer) < 2) and " " .. pointer or pointer

    if num < 1 or #self.input_table[num] >= self.str_len then
        self.input_table[num + 1] = {}
        num = num + 1
    end

    for _, v in ipairs(msg) do
        self.input_table[num][#self.input_table[num] + 1] = v
    end

    if self.input_table_p then
        self.input_table_p[num] = self.input_table_p[num] or {}
        self.input_table_p[num][1] = self.input_table_p[num][1] or ""
        self.input_table_p[num][1] = self.input_table_p[num][1] .. pointer
    end
end

function NsDb:get_fdict(index)
    -- Проверяем, что таблица с адресами существует
    if not self.input_table_p or not self.input_table_p[1] then
        return nil, "Таблица с адресами не найдена."
    end

    -- Инициализируем переменные
    local currentAddressLine = 1
    local currentAddressString = self.input_table_p[currentAddressLine][1]
    local addresses = {}

    -- Разбиваем строку с адресами на пары символов
    for address in string.gmatch(currentAddressString, "..") do
        table.insert(addresses, address)
    end

    -- Поиск нужного индекса
    while index > #addresses do
        -- Переходим к следующей строке с адресами
        currentAddressLine = currentAddressLine + 1
        if not self.input_table_p[currentAddressLine] then
            return nil, "Индекс вне диапазона."
        end

        currentAddressString = self.input_table_p[currentAddressLine][1]
        addresses = {}

        -- Разбиваем новую строку с адресами на пары символов
        for address in string.gmatch(currentAddressString, "..") do
            table.insert(addresses, address)
        end
    end

    -- Получаем адрес по индексу
    local address = addresses[index]

    -- Декодируем адрес с помощью функции 
    local wordCount = en10(address)
    if not wordCount then
        return nil, "Некорректный адрес: " .. address
    end

    -- Определяем, в какой таблице данных находятся слова
    local dataTableIndex = math.ceil(index / 1000)
    if not self.input_table[dataTableIndex] then
        return nil, "Таблица с данными не найдена."
    end

    -- Получаем данные из соответствующей таблицы
    local messageParts = self.input_table[dataTableIndex]

    -- Вычисляем начальный индекс для текущего адреса
    local startIndex = 1
    for i = 1, index - 1 do
        local prevAddress = addresses[i]
        local prevWordCount = numeCod(prevAddress)
        if not prevWordCount then
            return nil, "Некорректный адрес: " .. prevAddress
        end
        startIndex = startIndex + prevWordCount
    end

    -- Проверяем, что индексы находятся в пределах таблицы
    if startIndex < 1 or (startIndex + wordCount - 1) > #messageParts then
        return nil, "Адрес вне диапазона данных."
    end

    -- Собираем слова в сообщение
    local message = {}
    for i = startIndex, startIndex + wordCount - 1 do
        table.insert(message, messageParts[i])
    end

    -- Объединяем слова в строку
    local result = table.concat(message, " ")

    -- Логируем номер адреса, сам адрес и полученные данные
    print(string.format("Адрес %d: %s (декодировано: %d) -> Данные: %s", index, address, wordCount, result))

    return result
end

-- Метод для проверки уникальности сообщения
function NsDb:is_unique(message)
    for i = 1, #self.input_table do
        if self.input_table[i][message] then
            return false
        end
    end
    return true
end

function NsDb:pLen()
    local pLen = 0
    if self.input_table_p then
        for i = 1, #self.input_table_p do
            pLen = pLen + (tonumber(utf8len(self.input_table_p[i]))/3)
        end
        return pLen
    else
        return nil
    end
end

-- Метод для получения общей длины
function NsDb:Len()
    local Len = 0
    for i = 1, #self.input_table do
        if type(self.input_table[i]) == "table" then
            for _ in pairs(self.input_table[i]) do
                Len = Len + 1
            end
        else
            Len = Len + #self.input_table[i]
        end
    end
    return Len
end

function NsDb:modKey(...)
    local n = select('#', ...)
    if n < 2 then return end
 
    local value = select(n, ...)
    local row_key = select(n-1, ...)
    if not row_key or value == nil then return end
 
    local target = self.input_table
 
    for i = 1, n-2 do
        local key = select(i, ...)
        if not key then return end
        
        local next_table = target[key]
        if not next_table then
            next_table = {}
            target[key] = next_table
        end
        target = next_table
    end
 
    target[row_key] = value
end

function NsDb:getKey(...)
    local n = select('#', ...)
    if n == 0 then return nil end
    
    local target = self.input_table
    
    for i = 1, n-1 do
        local key = select(i, ...)
        if type(target) ~= "table" then return nil end
        target = target[key]
        if target == nil then return nil end
    end
    
    return type(target) == "table" and target[select(n, ...)] or nil
end

-- Определяем класс create_table
create_table = {}
create_table.__index = create_table

-- Конструктор для создания нового объекта create_table
function create_table:new(input_table, is_pointer)
    local new_object = setmetatable({}, self)
    if is_pointer then
        _G[input_table.."_p"] = _G[input_table.."_p"] or {}
        new_object.input_table_p = _G[input_table.."_p"]
    end
    _G[input_table] = _G[input_table] or {}
    new_object.input_table = _G[input_table]
    return new_object
end

-- Метод для получения таблицы
function create_table:get_table()
    return self.input_table
end

-- Метод для получения таблицы-указателя
function create_table:get_table_p()
    return self.input_table_p
end

-- Определяем класс ButtonManager
ButtonManager = {}
ButtonManager.__index = ButtonManager

-- Конструктор для создания новой кнопки
function ButtonManager:new(name, parent, width, height, text, texture, mv)
    local button = setmetatable({}, ButtonManager)
    if texture then
        button.frame = CreateFrame("Button", name, parent)
        button.frame:SetNormalTexture(texture)
        button.frame:SetHighlightTexture(texture) -- Устанавливаем текстуру подсветки
    else
        button.frame = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    end
    if not button.frame then
        print("Ошибка: не удалось создать фрейм кнопки!")
        return
    end
    button.frame:SetSize(width, height)
    button:SetText(text)
    if mv then
        button:SetMovable(mv)
    end
    return button
end

-- Метод для установки текстуры на кнопке
function ButtonManager:SetTexture(texture, highlightTexture)
    if texture then
        self.frame:SetNormalTexture('Interface\\AddOns\\NSQC3\\libs\\' .. texture .. '.tga')
    end
    if highlightTexture then
        self.frame:SetHighlightTexture('Interface\\AddOns\\NSQC3\\libs\\' .. highlightTexture .. '.tga')
    end
end

-- Метод для установки текста на кнопке
function ButtonManager:SetText(text)
    local fontString = self.frame:GetFontString() or self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fontString:SetText(text)
    local buttonWidth, buttonHeight = self.frame:GetSize()
    local fontSize = math.floor(buttonHeight * 0.6)
    fontString:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE", "MONOCHROME")
    while fontString:GetStringWidth() > buttonWidth and fontSize > 6 do
        fontSize = fontSize - 1
        fontString:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE", "MONOCHROME")
    end
    fontString:SetPoint("CENTER", self.frame, "CENTER", 0, 0)
    fontString:SetJustifyH("CENTER")
    fontString:SetJustifyV("MIDDLE")
    fontString:SetWordWrap(false)
    fontString:SetNonSpaceWrap(false)
end

-- Метод для установки текста на кнопке через FontString с возможностью задания цвета в формате HEX
function ButtonManager:SetTextT(text, color)
    local fontString = self.frame:GetFontString()
    if not fontString then
        fontString = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.frame:SetFontString(fontString)
    end

    -- Установка шрифта и размера
    fontString:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE", "MONOCHROME")

    -- Установка текста
    fontString:SetText(text)

    -- Функция для преобразования HEX-цвета в RGB
    local function HexToRGB(hexColor)
        -- Убираем символ "#" если он есть
        hexColor = hexColor:gsub("#", "")
        
        -- Преобразуем шестнадцатеричную строку в числа RGB
        local r = tonumber("0x" .. hexColor:sub(1, 2)) / 255
        local g = tonumber("0x" .. hexColor:sub(3, 4)) / 255
        local b = tonumber("0x" .. hexColor:sub(5, 6)) / 255
        
        return r, g, b
    end

    -- Установка цвета текста
    if color == nil then
        -- Если цвет не указан, используем цвет по умолчанию #FF8C00
        local r, g, b = HexToRGB("FF8C00")
        fontString:SetTextColor(r, g, b)
    elseif type(color) == "string" and color:match("^%x%x%x%x%x%x$") then
        -- Если передан HEX-цвет, преобразуем его в RGB
        local r, g, b = HexToRGB(color)
        fontString:SetTextColor(r, g, b)
    elseif type(color) == "table" then
        -- Если передан массив RGB
        local r, g, b = unpack(color)
        fontString:SetTextColor(r, g, b)
    else
        -- Используем белый цвет по умолчанию, если формат некорректен
        fontString:SetTextColor(1.0, 1.0, 1.0)
    end
end

-- Метод для установки позиции кнопки
function ButtonManager:SetPosition(point, relativeTo, relativePoint, xOffset, yOffset)
    self.frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
end

-- Метод для скрытия кнопки
function ButtonManager:Hide()
    self.frame:Hide()
end

-- Метод для отображения кнопки
function ButtonManager:Show()
    self.frame:Show()
end

-- Метод для установки обработчика нажатия на кнопку
function ButtonManager:SetOnClick(onClickFunction)
    self.frame:SetScript("OnClick", onClickFunction)
end

-- Метод для установки обработчика наведения мыши на кнопку
function ButtonManager:SetOnEnter(onEnterFunction)
    local oldOnEnter = self.frame:GetScript("OnEnter")
    self.frame:SetScript("OnEnter", function(selfFrame, ...)
        if oldOnEnter then oldOnEnter(selfFrame, ...) end
        onEnterFunction(selfFrame, ...)
    end)
end

function ButtonManager:SetOnLeave(onLeaveFunction)
    local oldOnLeave = self.frame:GetScript("OnLeave")
    self.frame:SetScript("OnLeave", function(...)
        if oldOnLeave then oldOnLeave(...) end
        onLeaveFunction(...)
    end)
end

-- Метод для добавления всплывающей подсказки
function ButtonManager:SetTooltip(text)
    self.frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text)
        GameTooltip:Show()
    end)
    self.frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function ButtonManager:SetMultiLineTooltip(tooltipsTable)
    if type(tooltipsTable) ~= "table" then return end
    local oldOnEnter = self.frame:GetScript("OnEnter")
    local oldOnLeave = self.frame:GetScript("OnLeave")
    self.frame:SetScript("OnEnter", function(selfFrame, ...)
        if oldOnEnter then oldOnEnter(selfFrame, ...) end
        GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT")
        for _, line in ipairs(tooltipsTable) do
            GameTooltip:AddLine(line, 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    self.frame:SetScript("OnLeave", function(...)
        if oldOnLeave then oldOnLeave(...) end
        GameTooltip:Hide()
    end)
end

function ButtonManager:SetSize(width, height)
    if self.frame then
        self.frame:SetWidth(width)
        self.frame:SetHeight(height)
    else
        print("Ошибка: фрейм кнопки не существует!")
    end
end

function ButtonManager:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    if self.frame then
        self.frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    else
        print("Ошибка: фрейм кнопки не существует!")
    end
end

function ButtonManager:Hide()
    if self.frame then
        self.frame:Hide()
    else
        print("Ошибка: фрейм кнопки не существует!")
    end
end

function ButtonManager:Show()
    if self.frame then
        self.frame:Show()
    else
        print("Ошибка: фрейм кнопки не существует!")
    end
end

-- Метод для получения последних трех символов пути текстуры (с выбором типа текстуры)
function ButtonManager:GetTxt(textureType)
    local texture
    if textureType == "N" then
        texture = self.frame:GetNormalTexture()
    elseif textureType == "P" then
        texture = self.frame:GetPushedTexture()
    elseif textureType == "H" then
        texture = self.frame:GetHighlightTexture()
    else
        return "Неверный тип текстуры."
    end
    if texture then
        local texturePath = texture:GetTexture()
        if texturePath then
            return texturePath:sub(-3)
        else
            return "Текстура не установлена."
        end
    else
        return "Текстура не установлена."
    end
end

-- Метод для перемещения кнопки
function ButtonManager:SetMovable(isMovable)
    if isMovable then
        self.frame:SetMovable(true)
        self.frame:RegisterForDrag("LeftButton")
        self.frame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        self.frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)
    else
        self.frame:SetMovable(false)
        self.frame:RegisterForDrag(nil)
        self.frame:SetScript("OnDragStart", nil)
        self.frame:SetScript("OnDragStop", nil)
    end
end

-- Константы
local CLOSE_BUTTON_SIZE = 32
local PADDING = 15
local SCREEN_PADDING = -40  -- Отступ от краев экрана
local MIN_WIDTH = 200
local MIN_HEIGHT = 200
local BUTTON_PADDING = 0
local F_PAD = 40
local MOVE_ALPHA = 0
-- Добавляем константы прозрачности
local FRAME_ALPHA = 0
local BUTTON_ALPHA = 1
-- Определяем класс AdaptiveFrame
AdaptiveFrame = {}
AdaptiveFrame.__index = AdaptiveFrame

-- Конструктор для создания нового объекта AdaptiveFrame
function AdaptiveFrame:new(parent)
    local self = setmetatable({}, AdaptiveFrame)
    self.parent = parent or UIParent
    self.width = 600
    self.height = 600
    self.initialAspectRatio = self.width / self.height  -- Сохраняем начальное соотношение сторон
    self.buttonsPerRow = 5  -- Количество кнопок в ряду (по умолчанию)
    self.skipSizeCheck = true -- Новый флаг
    -- Создаем фрейм
    self.frame = CreateFrame("Frame", "fdsfasdf", self.parent)
    self.frame:SetSize(self.width, self.height)
    self.skipSizeCheck = false -- Разрешаем проверки после инициализации
    self.frame:SetPoint("CENTER", self.parent, "CENTER", 150, 100)
    self.frame:SetFrameStrata("HIGH")
    self.frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    FRAME_ALPHA = ns_dbc:getKey("настройки", "FRAME_ALPHA") or FRAME_ALPHA
    BUTTON_ALPHA = ns_dbc:getKey("настройки", "BUTTON_ALPHA") or BUTTON_ALPHA
    self.frame:SetBackdropColor(0.1, 0.1, 0.1, FRAME_ALPHA)  -- Устанавливаем прозрачность фрейма
    self.frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 0)

     -- Создаем текстовое поле
    self.textField = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.textField:SetPoint("TOP", self.frame, "TOP", 0, -5)  -- Позиционируем текстовое поле в верхней части фрейма, отступ 5 пикселей от верха
    self.textField:SetText("")  -- Устанавливаем начальный текст
    self.textField:SetTextColor(1, 1, 1, 1)  -- Устанавливаем цвет текста (белый)

    -- Включаем возможность перемещения и изменения размера фрейма
    self.frame:SetMovable(true)
    self.frame:SetResizable(true)  -- Включаем возможность изменения размера
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton", "RightButton")  -- Регистрируем обработку левой и правой кнопок мыши
    -- Обработчик клика правой кнопкой мыши
    self.frame:SetScript("OnMouseDown", function(_, button)
        if button == "RightButton" then
            self:ToggleFrameAlpha()
        elseif button == "LeftButton" then
            self:StartMoving()
        end
    end)
    -- Обработчик перетаскивания правой кнопкой мыши
    local startX = 0
    local isDragging = false
    self.frame:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            isDragging = false
            self.frame:SetScript("OnUpdate", nil) -- Удаляем OnUpdate, когда перетаскивание завершено
        else
            self:StopMovingOrSizing()
        end
    end)
    self.frame:SetScript("OnDragStart", function(_, button)
        if button == "RightButton" then
            startX = GetCursorPosition()
            isDragging = true
            -- Устанавливаем OnUpdate только при начале перетаскивания
            self.frame:SetScript("OnUpdate", function()
                if isDragging then
                    local currentX = GetCursorPosition()
                    local deltaX = currentX - startX
                    startX = currentX
                    -- Изменяем прозрачность дочерних кнопок
                    for _, child in ipairs(self.children) do
                        local currentAlpha = child.frame:GetAlpha() -- Исправлено: child.frame -> child
                        if deltaX > 0 then
                            -- Увеличиваем прозрачность при движении вправо
                            local newAlpha = math.min(currentAlpha + math.abs(deltaX) / 1000, 1)
                            child.frame:SetAlpha(newAlpha) -- Исправлено: child.frame -> child
                            ns_dbc:modKey("настройки", "BUTTON_ALPHA", newAlpha)
                            BUTTON_ALPHA = newAlpha
                        elseif deltaX < 0 then
                            -- Уменьшаем прозрачность при движении влево
                            local newAlpha = math.max(currentAlpha - math.abs(deltaX) / 1000, 0)
                            child.frame:SetAlpha(newAlpha) -- Исправлено: child.frame -> child
                            ns_dbc:modKey("настройки", "BUTTON_ALPHA", newAlpha)
                            BUTTON_ALPHA = newAlpha
                        end
                    end
                end
            end)
        else
            self:StartMoving()
        end
    end)
    self.frame:SetScript("OnDragStop", function(_, button)
        if button == "RightButton" then
            isDragging = false
            self.frame:SetScript("OnUpdate", nil) -- Удаляем OnUpdate при остановке перетаскивания
        else
            self:StopMovingOrSizing()
        end
    end)
    -- Создаем кнопку закрытия
    self.closeButton = CreateFrame("Button", nil, self.frame, "UIPanelCloseButton")
    self.closeButton:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    self.closeButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -PADDING, -PADDING)
    self.closeButton:SetScript("OnClick", function()
        self:Hide()
        for i = 1, 100 do
            adaptiveFrame.children[i]:SetTextT("")
        end
    end)
    -- Создаем ручку для изменения размера фрейма
    self.resizeHandle = CreateFrame("Button", nil, self.frame)
    self.resizeHandle:SetSize(16, 16)
    self.resizeHandle:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -40, 40)
    self.resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    self.resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    self.resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    self.resizeHandle:SetScript("OnMouseDown", function()
        self.frame:StartSizing("BOTTOMRIGHT")
    end)
    self.resizeHandle:SetScript("OnMouseUp", function()
        self.frame:StopMovingOrSizing()
        local x, y = self:GetSize()
        ns_dbc:modKey("настройки", "mfldRX", x)
        self:AdjustSizeAndPosition()
    end)
    -- Обработчик изменения размера фрейма
    self.frame:SetScript("OnSizeChanged", function(_, width, height)
        if self.skipSizeCheck then
            self.skipSizeCheck = false
            return
        end
        width, height = self:CheckFrameSize(width, height)
        self.frame:SetSize(width, height)
        self:AdjustSizeAndPosition()
    end)
    -- Инициализируем список дочерних элементов
    self.children = {}
    return self
end

function AdaptiveFrame:SetText(text)
    if self.textField then
        self.textField:SetText(text)
    else
        print("Ошибка: Текстовое поле не инициализировано.")
    end
end

-- Метод для переключения прозрачности основного фрейма
function AdaptiveFrame:ToggleFrameAlpha()
    local currentAlpha = select(4, self.frame:GetBackdropColor())
    FRAME_ALPHA = ns_dbc:getKey("настройки", "FRAME_ALPHA") or FRAME_ALPHA
    if not ns_dbc:getKey("настройки", "fullAlphaFrame") then
        if FRAME_ALPHA ~= 0 then
            if currentAlpha > FRAME_ALPHA - 0.05 then
                self.frame:SetBackdropColor(0.1, 0.1, 0.1, 0)  -- Сбрасываем прозрачность до нуля
            elseif currentAlpha == 0 then
                self.frame:SetBackdropColor(0.1, 0.1, 0.1, FRAME_ALPHA)  -- Возвращаем исходную прозрачность
            end
        else
            if currentAlpha > 0.1 then
                self.frame:SetBackdropColor(0.1, 0.1, 0.1, 0)  -- Сбрасываем прозрачность до нуля
            elseif currentAlpha == 0 then
                self.frame:SetBackdropColor(0.1, 0.1, 0.1, 1)  -- Возвращаем исходную прозрачность
            end
        end
    end
end

-- Метод для начала перемещения фрейма
function AdaptiveFrame:StartMoving()
    self.frame:StartMoving()
end

-- Метод для остановки перемещения или изменения размера фрейма
function AdaptiveFrame:StopMovingOrSizing()
    self.frame:StopMovingOrSizing()
    local x, y = self:GetPosition()
    ns_dbc:modKey("настройки", "mfldX", x)
    ns_dbc:modKey("настройки", "mfldY", y)
    self:AdjustSizeAndPosition()
end

-- Метод для скрытия фрейма
function AdaptiveFrame:Hide()
    self.frame:Hide()
end

-- Метод для отображения фрейма
function AdaptiveFrame:Show()
    self.frame:Show()
    self:AdjustSizeAndPosition()
end

-- Метод для получения размеров фрейма
function AdaptiveFrame:GetSize()
    local width, height = self.frame:GetSize()
    return width, height
end

function AdaptiveFrame:CheckFrameSize(width, height)
    local screenWidth, screenHeight = WorldFrame:GetWidth(), WorldFrame:GetHeight()
    local maxFrameHeight = screenHeight + 200 -- Максимальная высота фрейма
    local minFrameHeight = MIN_HEIGHT
    -- Ограничиваем высоту фрейма максимальной доступной высотой
    if height > maxFrameHeight then
        height = maxFrameHeight
    end
    -- Проверяем минимальную высоту
    if height < minFrameHeight then
        height = minFrameHeight
    end
    -- Возвращаем высоту как ширину и высоту для сохранения пропорций
    return height, height
end

-- Метод для позиционирования и размеров кнопок
function AdaptiveFrame:AdjustSizeAndPosition()
    local buttonsPerRow = 10  -- Фиксируем 10 столбцов
    local numChildren = #self.children
    local rows = math.ceil(numChildren / buttonsPerRow)
    local frameWidth, frameHeight = self.frame:GetSize()
    local buttonWidth = (frameWidth - 2 * F_PAD - (buttonsPerRow - 1) * BUTTON_PADDING) / buttonsPerRow
    local buttonHeight = buttonWidth
    local requiredWidth = 2 * F_PAD + buttonsPerRow * buttonWidth + (buttonsPerRow - 1) * BUTTON_PADDING
    local requiredHeight = 2 * F_PAD + rows * buttonHeight + (rows - 1) * BUTTON_PADDING
    if frameWidth < requiredWidth or frameHeight < requiredHeight then
        self.frame:SetSize(requiredWidth, requiredHeight)
        frameWidth, frameHeight = requiredWidth, requiredHeight
        buttonWidth = (frameWidth - 2 * F_PAD - (buttonsPerRow - 1) * BUTTON_PADDING) / buttonsPerRow
        buttonHeight = buttonWidth
    end
    for i, child in ipairs(self.children) do
        local row = math.floor((i - 1) / buttonsPerRow)
        local col = (i - 1) % buttonsPerRow
        local x = F_PAD + col * (buttonWidth + BUTTON_PADDING)
        local y = F_PAD + row * (buttonHeight + BUTTON_PADDING)
        if ButtonManager.SetSize and ButtonManager.SetPoint then
            ButtonManager.SetSize(child, buttonWidth, buttonHeight)
            ButtonManager.SetPoint(child, "BOTTOMLEFT", self.frame, "BOTTOMLEFT", x, y)
        else
            print("Error: Child does not support required methods")
        end
    end
    local screenWidth, screenHeight = UIParent:GetSize()
    local x, y = self.frame:GetLeft(), self.frame:GetBottom()
    SCREEN_PADDING = ns_dbc:getKey("настройки", "SCREEN_PADDING") or SCREEN_PADDING
    x = math.max(SCREEN_PADDING, math.min(x, screenWidth - frameWidth - SCREEN_PADDING))
    y = math.max(SCREEN_PADDING, math.min(y, screenHeight - frameHeight - SCREEN_PADDING))
    self.frame:ClearAllPoints()
    self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
end

-- Метод для добавления массива кнопок на фрейм
function AdaptiveFrame:AddButtons(numButtons, buttonsPerRow, size, texture, highlightTexture)
    self.buttonsPerRow = buttonsPerRow or self.buttonsPerRow
    local buttonWidth = size
    local buttonHeight = size
    local buttonTexture = texture
    local buttonHighlightTexture = highlightTexture
    local buttonText = ""
    for i = 1, numButtons do
        local buttonName = "button"..i
        local button = ButtonManager:new(buttonName, self.frame, buttonWidth, buttonHeight, buttonText, '', nil)
        button.frame:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonUp", "RightButtonDown", "MiddleButtonDown", "Button4Up", "Button5Up", "Button5Down")
        button.frame:EnableMouseWheel(true)
        button.frame:SetAlpha(BUTTON_ALPHA)  -- Устанавливаем прозрачность кнопки
        table.insert(self.children, button)
    end
    self:AdjustSizeAndPosition()
end

-- Метод для управления прозрачностью дочерних кнопок при движении персонажа
function AdaptiveFrame:StartMovementAlphaTracking()
    if self.movementFrame then return end -- Уже отслеживается
    local movementFrame = CreateFrame("Frame")
    self.movementFrame = movementFrame
    movementFrame.parent = self
    MOVE_ALPHA = ns_dbc:getKey("настройки", "MOVE_ALPHA") or MOVE_ALPHA
    movementFrame.targetAlpha = MOVE_ALPHA
    movementFrame.currentAlpha = BUTTON_ALPHA
    movementFrame.alphaSpeed = 2
    movementFrame.BUTTON_ALPHA = BUTTON_ALPHA  -- Сохраняем исходное значение
    movementFrame:SetScript("OnUpdate", function(self, elapsed)
        local isMoving = GetUnitSpeed("player") > 0
        local shouldUpdate = false
        -- Определение целевой прозрачности
        if isMoving then
            self.targetAlpha = MOVE_ALPHA
            if ns_dbc:getKey("настройки", "disableFld") then
                self.parent.frame:EnableMouse(self.targetAlpha > MOVE_ALPHA + 0.1)
            end
            shouldUpdate = true
        else
            self.targetAlpha = self.BUTTON_ALPHA  -- Возвращаемся к BUTTON_ALPHA при остановке
            shouldUpdate = true
        end
        -- Плавное изменение прозрачности
        if shouldUpdate and math.abs(self.currentAlpha - self.targetAlpha) > 0.01 then
            self.currentAlpha = self.currentAlpha + (self.targetAlpha - self.currentAlpha) * self.alphaSpeed * elapsed
            self.currentAlpha = math.min(math.max(self.currentAlpha, 0), 1)
            -- Обновление кнопок2
            for _, child in ipairs(self.parent.children) do
                if child.frame and child.frame.SetAlpha then
                    child.frame:SetAlpha(self.currentAlpha)
                    if ns_dbc:getKey("настройки", "disableFld") then
                        child.frame:EnableMouse(self.currentAlpha > MOVE_ALPHA + 0.1)
                    end
                    if self.currentAlpha < MOVE_ALPHA + 0.1 then
                        if ns_dbc:getKey("настройки", "closeFld") then
                            self.parent:Hide()
                        end
                    end
                end
            end
        end
        -- Автоматическая остановка при достижении цели
        if not isMoving and math.abs(self.currentAlpha - self.targetAlpha) < 0.01 then
            self.currentAlpha = BUTTON_ALPHA  -- Точно устанавливаем конечное значение
            self.parent.frame:EnableMouse(true)
            self.parent.frame:StopMovingOrSizing()
            self.parent:StopMovementAlphaTracking()
        end
    end)
end

function AdaptiveFrame:getTexture(id)
    return self.children[id].frame:GetNormalTexture():GetTexture():sub(-3)
end

-- Метод для остановки отслеживания движения и очистки скрипта
function AdaptiveFrame:StopMovementAlphaTracking()
    if self.movementFrame then
        self.movementFrame:SetScript("OnUpdate", nil)  -- Удаляем обработчик OnUpdate
        self.movementFrame = nil  -- Очищаем ссылку на movementFrame
    end
end

-- Метод для получения текущих координат фрейма относительно родителя
function AdaptiveFrame:GetPosition()
    return self.frame:GetCenter()
end

-- Метод для установки координат фрейма
function AdaptiveFrame:SetPoint(x, y)
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end

function AdaptiveFrame:isVisible()
    -- Проверяем, существует ли фрейм
    if not self.frame then
        return false
    end

    -- Проверяем, видим ли фрейм
    return self.frame:IsVisible()
end

PopupPanel = {}
PopupPanel.__index = PopupPanel

function PopupPanel:Create(buttonWidth, buttonHeight, buttonsPerRow, spacing)
    local self = setmetatable({}, PopupPanel)
    self.buttonWidth = buttonWidth
    self.buttonHeight = buttonHeight
    self.buttonsPerRow = buttonsPerRow
    self.spacing = spacing or 0
    self.buttons = {}
    return self
end

function PopupPanel:CreateButtons(buttonDataList)
    if not self.panel then 
        error("Сначала вызовите Show() для создания панели.")
    end

    -- Уничтожаем старые кнопки (для Wrath 3.3.5)
    for _, btn in ipairs(self.buttons) do 
        btn:SetParent(nil)  -- Отсоединяем от родителя
        btn:Hide()          -- Скрываем
        btn:SetScript("OnClick", nil)  -- Удаляем обработчики
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
    end
    self.buttons = {} -- Очищаем таблицу

    -- Создаем новые кнопки
    local totalButtons = #buttonDataList
    if totalButtons == 0 then return end

    -- Рассчитываем ширину панели
    local buttonsPerRow = math.min(totalButtons, self.buttonsPerRow)
    local panelWidth = buttonsPerRow * self.buttonWidth + (buttonsPerRow - 1) * self.spacing
    local panelHeight = math.ceil(totalButtons / self.buttonsPerRow) * (self.buttonHeight + self.spacing)

    self.panel:SetSize(panelWidth, panelHeight)

    -- Центрируем кнопки
    for i, data in ipairs(buttonDataList) do
        local button = CreateFrame("Button", nil, self.panel)
        button:SetSize(self.buttonWidth, self.buttonHeight)
        button:SetFrameStrata("DIALOG")

        -- Расчет позиции
        local row = math.floor((i - 1) / self.buttonsPerRow)
        local col = (i - 1) % self.buttonsPerRow
        local xOffset = col * (self.buttonWidth + self.spacing) - (panelWidth / 2) + (self.buttonWidth / 2)
        local yOffset = -row * (self.buttonHeight + self.spacing)

        button:SetPoint("CENTER", self.panel, "CENTER", xOffset, yOffset)
        
        -- Настройка текстуры
        button:SetNormalTexture(data.texture)
        button:SetHighlightTexture(data.texture)

        -- Обработчик клика
        button:SetScript("OnClick", data.func)

        -- Взаимодействие с панелью
        button:SetScript("OnEnter", function() 
            self.panel:Show()

            -- Показываем тултип, если он задан
            if data.tooltip then
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:SetText(data.tooltip)
                GameTooltip:SetWidth(500) -- Устанавливаем ширину тултипа вручную
                GameTooltip:Show()
            end
        end)

        button:SetScript("OnLeave", function() 
            GameTooltip:Hide() -- Скрываем тултип
            if not self.panel:IsMouseOver() then
                self.panel:Hide()
            end
        end)

        table.insert(self.buttons, button)
    end
end

-- Показ панели
function PopupPanel:Show(parentButton, secondaryTriggers)
    if not self.panel then
        self.panel = CreateFrame("Frame", nil, UIParent)
        self.panel:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
        self.panel:SetBackdropColor(0, 0, 0, 0.8)
        self.panel:Hide()
    end

    self.parentButton = parentButton

    -- Позиционирование панели
    local function UpdatePosition()
        self.panel:ClearAllPoints()
        self.panel:SetPoint("BOTTOM", parentButton, "TOP", 0, 0)
    end

    -- Триггеры
    parentButton:SetScript("OnEnter", function()
        local buttonDataList = {}

        -- Проверяем все триггеры
        for _, triggerFunc in ipairs(secondaryTriggers) do
            local success, data = triggerFunc(parentButton)
            if success then
                for _, btnData in ipairs(data) do
                    table.insert(buttonDataList, btnData)
                end
            end
        end

        if #buttonDataList > 0 then
            self:CreateButtons(buttonDataList)
            UpdatePosition()
            self.panel:Show()
        end
    end)

    parentButton:SetScript("OnLeave", function()
        --if not self.panel:IsMouseOver() then
            self.panel:Hide()
        --end
    end)

    self.panel:SetScript("OnLeave", function()
        --if not parentButton:IsMouseOver() then
            self.panel:Hide()
        --end
    end)
end

mDB = {}
mDB.__index = mDB

function mDB:new()
    local private = setmetatable({}, { __mode = "k" }) -- слабые ключи для сборки мусора
    local obj = setmetatable({
        getArg = function(self, index)
            return private[index]
        end,
        setArg = function(self, index, value)
            if value == nil then
                private[index] = nil -- явное удаление, если значение nil
            else
                private[index] = value
            end
        end
    }, self)
    obj.private = private -- хранить ссылку на private в объекте для предотвращения утечек памяти
    return obj
end

-- Класс UniversalInfoFrame
UniversalInfoFrame = {}
UniversalInfoFrame.__index = UniversalInfoFrame

function UniversalInfoFrame:new(updateInterval, saveTable)
    -- Разбиваем строку на части
    local tableName, key = saveTable:match("^([%w_]+)%['?\"?([^'\"]+)['\"]?%]$")
    if not tableName or not key then
        error("Неверный формат пути к таблице: " .. tostring(saveTablePath))
    end

    -- Получаем таблицу из _G
    local tableRef = _G[tableName]
    if type(tableRef) ~= "table" then
        error("Таблица " .. tableName .. " не существует")
    end

    -- Проверяем, существует ли ключ
    if type(tableRef[key]) ~= "table" then
        tableRef[key] = {}  -- Создаем новую таблицу, если её нет
    end

    -- Инициализация нового объекта
    local new_object = setmetatable({}, self)
    self.__index = self

    -- Сохраняем таблицу в объекте
    new_object.saveTable = tableRef[key]
    new_object.textsTop = {}
    new_object.textsBottom = {}
    new_object.updateInterval = updateInterval or 1
    new_object.timeElapsed = 0
    new_object.isCollapsed = false
    new_object.collapsedText = nil

    -- Создание фрейма
    new_object.frame = CreateFrame("Frame", nil, UIParent)
    new_object.frame:SetSize(200, 50)

    -- Загрузка координат из saveTable, если они есть
    if new_object.saveTable.x and new_object.saveTable.y then
        new_object.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", new_object.saveTable.x, new_object.saveTable.y)
    else
        -- Устанавливаем фрейм в центр, если координаты не заданы
        new_object.frame:SetPoint("CENTER")
        -- Сохраняем начальные координаты
        local x = new_object.frame:GetLeft()
        local y = new_object.frame:GetBottom() + new_object.frame:GetHeight()
        new_object.saveTable.x = x
        new_object.saveTable.y = y
    end

    -- Конфигурация фрейма (без изменений)
    new_object.frame:SetMovable(true)
    new_object.frame:EnableMouse(true)
    new_object.frame:RegisterForDrag("LeftButton")
    new_object.frame:SetScript("OnDragStart", new_object.frame.StartMoving)
    new_object.frame:SetScript("OnDragStop", function()
        new_object.frame:StopMovingOrSizing()
        -- Обновляем координаты после перемещения
        local x = new_object.frame:GetLeft()
        local y = new_object.frame:GetBottom() + new_object.frame:GetHeight()
        new_object.saveTable.x = x
        new_object.saveTable.y = y
    end)

    new_object.frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    new_object.frame:SetBackdropColor(0, 0, 0, 0.8)

    -- Настройка скриптов
    new_object.frame:SetScript("OnUpdate", function(_, elapsed)
        new_object:OnUpdate(elapsed)
    end)

    new_object.frame:SetScript("OnReceiveDrag", function()
        new_object:OnReceiveDrag()
    end)

    -- Восстановление сохраненных данных
    for _, data in ipairs(new_object.saveTable) do
        if data.description then
            data.valueFunc = data.valueFunc or function() return "N/A" end
            data.addToTop = data.addToTop == nil and true or data.addToTop
            new_object:AddText(data.description, data.valueFunc, data.addToTop, true)
        end
    end

    return new_object
end

function UniversalInfoFrame:UpdateSettings(newInterval, newSaveTable)
    self.updateInterval = newInterval or self.updateInterval
    if newSaveTable then
        -- допишу
    end
end

-- Метод для обработки перетаскивания предмета на фрейм
function UniversalInfoFrame:OnReceiveDrag()
    local type, id, info = GetCursorInfo()
    if type == "item" then
        local name, _, quality = GetItemInfo(id)
        if name then
            self:AddText(name, 'GetItemCount('..id..')', true, false, id)
        end
        ClearCursor()
    end
end

-- Метод для добавления текстового поля
function UniversalInfoFrame:AddText(description, valueFunc, addToTop, isRestore, itemID)
    -- Если valueFunc — это строка, преобразуем её в функцию
    local valueString
    if type(valueFunc) == "string" then
        valueString = valueFunc
        local func, err = loadstring("return function() return " .. valueFunc .. " end")
        if not func then
            -- Если произошла ошибка, выводим её и используем функцию по умолчанию
            print("Ошибка загрузки функции:", err)
            valueFunc = function() return "N/A" end
        else
            -- Выполняем загруженный код и сохраняем функцию
            valueFunc = func()
        end
    end

    -- Если valueFunc — это число, создаём функцию, которая возвращает это число
    if type(valueFunc) == "number" then
        local num = valueFunc
        valueFunc = function() return num end
    end

    -- Устанавливаем значение по умолчанию, если valueFunc не задана
    valueFunc = valueFunc or function() return "N/A" end

    -- Добавляем двоеточие после названия строки
    local headerTextStr = description .. ":"

    -- Получаем цвет качества, если передан itemID
    local r, g, b = 1, 1, 1  -- Белый цвет по умолчанию
    if itemID then
        local _, _, quality = GetItemInfo(itemID)
        if quality then
            r, g, b = GetItemQualityColor(quality)
        end
    end

    -- Создаем текстовое поле для заголовка
    local headerText = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    headerText:SetJustifyH("LEFT")
    headerText:SetText(headerTextStr)
    headerText:SetTextColor(r, g, b)

    -- Создаем текстовое поле для данных
    local valueText = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valueText:SetJustifyH("LEFT")
    valueText:SetText(tostring(valueFunc()))
    valueText:SetTextColor(0.59, 0.98, 0.59)  -- Светло-зелёный цвет для данных

    -- Создаем фрейм для кликабельной области
    local clickFrame = CreateFrame("Frame", nil, self.frame)
    clickFrame:SetAllPoints(headerText)
    clickFrame:EnableMouse(true)
    clickFrame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            self:ToggleCollapse(headerText, valueText)
        elseif button == "RightButton" and not self.isCollapsed then
            self:RemoveText(headerText, valueText)
        end
    end)

    -- Добавляем текстовые поля в верхнюю или нижнюю часть фрейма
    local targetTable = addToTop and self.textsTop or self.textsBottom
    table.insert(targetTable, { description = description, valueFunc = valueFunc, headerText = headerText, valueText = valueText, clickFrame = clickFrame })

    -- Сохраняем строку в таблицу сохранения, если это не восстановление
    if not isRestore then
        if valueString then
            table.insert(self.saveTable, { description = description, valueFunc = valueString, addToTop = addToTop })
        else
            table.insert(self.saveTable, { description = description, valueFunc = valueFunc, addToTop = addToTop })
        end
    end

    -- Обновляем позиции всех текстовых полей и размер фрейма
    self:UpdateTextPositions()
    self:UpdateFrameSize()
end

-- Метод для удаления текстового поля
function UniversalInfoFrame:RemoveText(headerText, valueText)
    if not headerText or not valueText then return end

    local headerTextStr = headerText:GetText()
    if not headerTextStr then return end

    -- Локальная функция для удаления из указанной таблицы
    local function removeFromTable(tbl)
        for i = #tbl, 1, -1 do -- Итерируем с конца для безопасного удаления
            local data = tbl[i]
            if data.headerText and data.headerText:GetText() == headerTextStr then
                -- Удаляем кликабельную область
                if data.clickFrame then
                    data.clickFrame:Hide()
                    data.clickFrame:SetScript("OnMouseDown", nil)
                end

                -- Удаляем текстовые поля
                if data.headerText then
                    data.headerText:Hide()
                    data.headerText:SetText("")
                end

                if data.valueText then
                    data.valueText:Hide()
                    data.valueText:SetText("")
                end

                -- Удаляем из saveTable
                for j = #self.saveTable, 1, -1 do
                    if self.saveTable[j].description == data.description then
                        table.remove(self.saveTable, j)
                        break
                    end
                end

                -- Удаляем запись из основной таблицы
                table.remove(tbl, i)
                break
            end
        end
    end

    -- Удаляем из обеих таблиц
    removeFromTable(self.textsTop)
    removeFromTable(self.textsBottom)

    -- Если фрейм был свёрнут, разворачиваем
    if self.isCollapsed then
        self.isCollapsed = false
        self.collapsedText = nil
        -- Показываем все текстовые поля
        self:UpdateTextVisibility(true)
    end

    -- Обновляем интерфейс
    self:UpdateTextPositions()
    self:UpdateFrameSize()
end

-- Метод для обновления позиций текстовых полей
function UniversalInfoFrame:UpdateTextPositions()
    -- Очищаем все точки привязки
    for _, data in ipairs(self.textsTop) do
        data.headerText:ClearAllPoints()
        data.valueText:ClearAllPoints()
    end
    for _, data in ipairs(self.textsBottom) do
        data.headerText:ClearAllPoints()
        data.valueText:ClearAllPoints()
    end

    -- Находим максимальную ширину заголовка
    local maxHeaderWidth = 0
    for _, data in ipairs(self.textsTop) do
        local width = data.headerText:GetStringWidth()
        if width > maxHeaderWidth then
            maxHeaderWidth = width
        end
    end
    for _, data in ipairs(self.textsBottom) do
        local width = data.headerText:GetStringWidth()
        if width > maxHeaderWidth then
            maxHeaderWidth = width
        end
    end

    -- Позиционируем текстовые поля в верхней части
    for i, data in ipairs(self.textsTop) do
        if i == 1 then
            data.headerText:SetPoint("TOPLEFT", 10, -10)  -- Первое поле в верхней части
        else
            data.headerText:SetPoint("TOPLEFT", self.textsTop[i - 1].headerText, "BOTTOMLEFT", 0, -5)  -- Остальные поля
        end
        -- Позиционируем значение на той же строке, что и заголовок
        data.valueText:SetPoint("LEFT", data.headerText, "RIGHT", 5, 0)
    end

    -- Позиционируем текстовые поля в нижней части
    for i, data in ipairs(self.textsBottom) do
        if i == 1 then
            data.headerText:SetPoint("BOTTOMLEFT", 10, 10)  -- Первое поле в нижней части
        else
            data.headerText:SetPoint("BOTTOMLEFT", self.textsBottom[i - 1].headerText, "TOPLEFT", 0, 5)  -- Остальные поля
        end
        -- Позиционируем значение на той же строке, что и заголовок
        data.valueText:SetPoint("LEFT", data.headerText, "RIGHT", 5, 0)
    end
end

local function formatNumber(value)
    -- Форматируем число с двумя знаками после запятой
    local formatted = string.format("%.2f", value)
    
    -- Проверяем, есть ли после точки только нули
    if formatted:match("%.00$") then
        -- Если после точки только нули, удаляем точку и нули
        formatted = formatted:gsub("%.00$", "")
    end

    return formatted
end

function UniversalInfoFrame:UpdateTexts()
    for _, data in ipairs(self.textsTop) do
        local value = data.valueFunc()
        -- Форматируем число, если это число
        if type(value) == "number" then
            value = formatNumber(value)
        end
        data.valueText:SetText(tostring(value))
    end

    for _, data in ipairs(self.textsBottom) do
        local value = data.valueFunc()
        -- Форматируем число, если это число
        if type(value) == "number" then
            value = formatNumber(value)
        end
        data.valueText:SetText(tostring(value))
    end

    -- Обновляем размер фрейма после изменения текста
    self:UpdateFrameSize()
end

-- Метод для обновления размера фрейма
function UniversalInfoFrame:UpdateFrameSize()
    if self.isCollapsed and self.collapsedText then
        -- В свёрнутом состоянии фрейм имеет фиксированную высоту
        local headerText = self.collapsedText.headerText
        local valueText = self.collapsedText.valueText

        if headerText and valueText then
            local headerWidth = headerText:GetStringWidth()
            local valueWidth = valueText:GetStringWidth()
            local totalWidth = headerWidth + valueWidth + 15  -- Учитываем отступ между заголовком и значением

            -- Устанавливаем размер фрейма
            self.frame:SetHeight(30)  -- Высота одной строки
            self.frame:SetWidth(totalWidth + 20)  -- Ширина текста с отступами

            -- Позиционируем заголовок и значение в центре фрейма
            headerText:ClearAllPoints()
            headerText:SetPoint("LEFT", self.frame, "LEFT", 10, 0)
            valueText:ClearAllPoints()
            valueText:SetPoint("LEFT", headerText, "RIGHT", 5, 0)
        end
    else
        -- В развёрнутом состоянии фрейм подстраивается под содержимое
        local totalHeight = 0
        local maxTotalWidth = 0

        -- Вычисляем общую высоту и максимальную ширину текстовых полей
        for _, data in ipairs(self.textsTop) do
            local headerText = data.headerText
            local valueText = data.valueText
            totalHeight = totalHeight + 20  -- Высота одного текстового поля

            local headerWidth = headerText:GetStringWidth()
            local valueWidth = valueText:GetStringWidth()
            local totalWidth = headerWidth + valueWidth + 15  -- Учитываем отступ между заголовком и данными
            if totalWidth > maxTotalWidth then
                maxTotalWidth = totalWidth
            end
        end

        for _, data in ipairs(self.textsBottom) do
            local headerText = data.headerText
            local valueText = data.valueText
            totalHeight = totalHeight + 20  -- Высота одного текстового поля

            local headerWidth = headerText:GetStringWidth()
            local valueWidth = valueText:GetStringWidth()
            local totalWidth = headerWidth + valueWidth + 15  -- Учитываем отступ между заголовком и данными
            if totalWidth > maxTotalWidth then
                maxTotalWidth = totalWidth
            end
        end

        -- Устанавливаем новый размер фрейма
        self.frame:SetHeight(totalHeight + 20)  -- Добавляем отступы
        self.frame:SetWidth(maxTotalWidth + 20)  -- Ширина самой длинной строки + отступы
    end
end

-- Метод для сворачивания/разворачивания фрейма
function UniversalInfoFrame:ToggleCollapse(headerText, valueText)
    if self.isCollapsed then
        -- Разворачиваем фрейм
        self.isCollapsed = false
        self.collapsedText = nil

        -- Показываем все текстовые поля
        for _, data in ipairs(self.textsTop) do
            data.headerText:Show()
            data.valueText:Show()
        end
        for _, data in ipairs(self.textsBottom) do
            data.headerText:Show()
            data.valueText:Show()
        end
    else
        -- Сворачиваем фрейм
        self.isCollapsed = true

        -- Находим данные для свёрнутого текста
        for _, data in ipairs(self.textsTop) do
            if data.headerText == headerText then
                self.collapsedText = data
                break
            end
        end
        for _, data in ipairs(self.textsBottom) do
            if data.headerText == headerText then
                self.collapsedText = data
                break
            end
        end

        -- Скрываем все текстовые поля, кроме выбранного
        for _, data in ipairs(self.textsTop) do
            if data.headerText ~= headerText then
                data.headerText:Hide()
                data.valueText:Hide()
            end
        end
        for _, data in ipairs(self.textsBottom) do
            if data.headerText ~= headerText then
                data.headerText:Hide()
                data.valueText:Hide()
            end
        end
    end

    -- Обновляем позиции всех текстовых полей и размер фрейма
    self:UpdateTextPositions()
    self:UpdateFrameSize()
end

-- Метод для обработки обновления фрейма
function UniversalInfoFrame:OnUpdate(elapsed)
    self.timeElapsed = self.timeElapsed + elapsed
    if self.timeElapsed > self.updateInterval then
        self.timeElapsed = 0
        self:UpdateTexts()  -- Обновляем текстовые поля
    end
end

-- Метод для отображения фрейма
function UniversalInfoFrame:Show()
    self.frame:Show()
end

-- Метод для скрытия фрейма
function UniversalInfoFrame:Hide()
    self.frame:Hide()
end

ChatHandler = {}
ChatHandler.__index = ChatHandler

-- Локальная таблица для хранения переменных вместо глобальных
local variables = {}

-- Предопределенные шаблоны для поиска по позициям слов
WORD_POSITION_PATTERNS = {}
for i = 1, 10 do -- Поддерживаем до 10 позиций
    WORD_POSITION_PATTERNS[i] = "^"..string.rep("%S*%s+", i-1).."(%S+)"
end

-- Функции для работы с локальными переменными
local function SetVariable(name, value)
    variables[name] = value
end

local function GetVariable(name)
    return variables[name]
end

function ChatHandler:new(triggersByAddress, chatTypes)
    local new_object = setmetatable({}, self)
    new_object.triggersByAddress = triggersByAddress or {}
    new_object.frame = CreateFrame("Frame")

    local events = chatTypes and {} or {
        "CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER",
        "CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_RAID", "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_BATTLEGROUND", "CHAT_MSG_SYSTEM", "CHAT_MSG_ADDON"
    }

    if chatTypes then
        for _, chatType in ipairs(chatTypes) do
            new_object.frame:RegisterEvent(chatType == "ADDON" and "CHAT_MSG_ADDON" or "CHAT_MSG_"..chatType)
        end
    else
        for _, event in ipairs(events) do
            new_object.frame:RegisterEvent(event)
        end
    end

    new_object.frame:SetScript("OnEvent", function(_, event, ...)
        new_object:OnChatMessage(event, ...)
    end)

    return new_object
end

function ChatHandler:OnChatMessage(event, ...)
    local text, sender, prefix, channel
    if event == "CHAT_MSG_ADDON" then
        prefix, text, _, sender = ...
    else
        text, sender = ...
    end

    -- Обработка общего триггера
    if self.triggersByAddress["*"] then
        for _, trigger in ipairs(self.triggersByAddress["*"]) do
            if self:CheckTrigger(trigger, text, sender, channel, prefix, event) and trigger.stopOnMatch then
                return
            end
        end
    end

    -- Формирование адресов для поиска
    local addressPrefix = event == "CHAT_MSG_ADDON" and "prefix:"..(prefix:match("^(%S+)") or "")
    local addressMessage = "message:"..(text:match("^(%S+)") or "")

    -- Проверка триггеров по адресам
    for _, address in ipairs({addressPrefix, addressMessage}) do
        if address and self.triggersByAddress[address] then
            for _, trigger in ipairs(self.triggersByAddress[address]) do
                if self:CheckTrigger(trigger, text, sender, channel, prefix, event) then
                    return
                end
            end
        end
    end
end

function ChatHandler:CheckTrigger(trigger, text, sender, channel, prefix, event)
    -- Проверка типа чата
    if trigger.chatType then
        local currentChatType = event:match("CHAT_MSG_(.+)$")
        local found = false
        for _, t in ipairs(trigger.chatType) do
            if t == currentChatType then
                found = true
                break
            end
        end
        if not found then return false end
    end

    -- Проверка запрещенных слов
    local lowerText = text:lower()
    for _, wordOrVar in ipairs(trigger.forbiddenWords or {}) do
        local word = type(wordOrVar) == "string" and wordOrVar:sub(1,1) == "$" 
            and GetVariable(wordOrVar:sub(2)) or wordOrVar
        
        if type(word) == "table" then
            for _, w in ipairs(word) do
                if lowerText:find(w:lower(), 1, true) then return false end
            end
        elseif word and lowerText:find(word:lower(), 1, true) then
            return false
        end
    end

    -- Проверка ключевых слов
    for _, keywordData in ipairs(trigger.keyword) do
        local target = keywordData.source == "prefix" and prefix or text
        if not target then return false end
        
        local pattern = WORD_POSITION_PATTERNS[keywordData.position]
        local match = target:match(pattern)
        if not match or match ~= keywordData.word then
            return false
        end
    end

    -- Проверка дополнительных условий
    for _, condition in ipairs(trigger.conditions or {}) do
        local func = type(condition) == "string" and _G[condition] or condition
        if not func or not func(text, sender, channel, prefix) then
            return false
        end
    end

    -- Вызов целевой функции
    local func = _G[trigger.func]
    if func then
        func(event, text, sender, prefix, channel)
        return trigger.stopOnMatch
    else
        print("Ошибка: функция '"..trigger.func.."' не найдена")
    end
    return false
end

-- Класс для работы с кастомными достижениями
CustomAchievements = {}
CustomAchievements.__index = CustomAchievements

-- Константы
local DEFAULT_ICON_SIZE = 40
local REWARD_ICON_SIZE = 48
local COLLAPSED_HEIGHT = 50
local EXPANDED_BASE_HEIGHT = 100
local SCROLL_BAR_WIDTH = 16
local TOOLTIP_ANCHOR = "ANCHOR_RIGHT"
local MAX_ICONS_PER_ROW = 10

-- Константы для позиций элементов
CustomAchievements.COLLAPSED_POSITIONS = {
    icon = {x = 5, y = 0},
    name = {x = 50, y = -5},
    date = {x = 300, y = -5},
    rewardPoints = {x = 440, y = -5}
}
CustomAchievements.EXPANDED_POSITIONS = {
    icon = {x = 5, y = 0},
    name = {x = 50, y = -5},
    description = {x = 50, y = -25},
    date = {x = 300, y = -5},
    rewardPoints = {x = 440, y = -5},
    requiredAchievements = {x = 50, y = -50}
}

-- Текстуры
local TEXTURE_BACKGROUND = "Interface\\FrameGeneral\\UI-Background-Rock"
local TEXTURE_HIGHLIGHT = "Interface\\Buttons\\UI-Listbox-Highlight"
local TEXTURE_INCOMPLETE = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated"
local TEXTURE_COMPLETE = "Interface\\AchievementFrame\\UI-Achievement-AchievementBackground"
local TEXTURE_SHIELD = "Interface\\AchievementFrame\\UI-Achievement-Shields"

-- Вспомогательные функции
local function CreateFontString(parent, template, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY", template)
    fs:SetJustifyH(justify or "LEFT")
    return fs
end

local function CreateTexture(parent, layer, texture)
    local tex = parent:CreateTexture(nil, layer)
    tex:SetTexture(texture)
    return tex
end

-- Конструктор класса
function CustomAchievements:new(staticDataTable, dynamicDataTable)
    local obj = setmetatable({}, self)
    obj.staticData = _G[staticDataTable]
    obj.dynamicData = _G[dynamicDataTable] or {}
    obj.frame = nil
    obj.buttons = {}
    obj.tabCreated = false
    obj.nightWatchTab = nil
    obj.selectedButton = nil
    obj.customAlertFrame = nil

    if not obj.staticData or type(obj.staticData) ~= "table" then
        error("Ошибка: статическая таблица данных не найдена или некорректна.")
    end
    if not obj.dynamicData or type(obj.dynamicData) ~= "table" then
        error("Ошибка: динамическая таблица данных не найдена или некорректна.")
    end
    return obj
end

-- Метод для получения данных ачивки по её имени
function CustomAchievements:GetAchievementData(name)
    for _, achievements in pairs(self.staticData) do
        local static = achievements[name]
        if static then
            local dynamic = self.dynamicData[name]
            return {
                name = static.name,
                description = static.description,
                texture = static.texture,
                rewardPoints = static.rewardPoints,
                requiredAchievements = static.requiredAchievements,
                subAchievements = static.subAchievements or {},
                dateEarned = dynamic and dynamic.dateEarned or "Не получена",
                dateCompleted = dynamic and dynamic.dateCompleted or "Не выполнена",
                progress = dynamic and dynamic.progress or 0,
                isExpanded = dynamic and dynamic.isExpanded or false,
                scrollPosition = dynamic and dynamic.scrollPosition or 0,
                category = _
            }
        end
    end
    return nil
end

-- Метод для создания вкладки "Ночная стража"
function CustomAchievements:CreateNightWatchTab()
    if not AchievementFrameTab1 then
        return
    end

    -- Найдем последнюю вкладку
    local lastTab = AchievementFrameTab1
    local tabIndex = 1
    while _G["AchievementFrameTab" .. (tabIndex + 1)] do
        lastTab = _G["AchievementFrameTab" .. (tabIndex + 1)]
        tabIndex = tabIndex + 1
    end

    self.nightWatchTab = CreateFrame("Button", "AchievementFrameTab" .. (tabIndex + 1), AchievementFrame, "AchievementFrameTabButtonTemplate")
    self.nightWatchTab:SetText("Ночная стража")
    self.nightWatchTab:SetPoint("LEFT", lastTab, "RIGHT", -6, 0)

    local fontString = self.nightWatchTab:GetFontString()
    if fontString then
        fontString:SetText("Ночная стража")
    else
        return
    end

    PanelTemplates_TabResize(self.nightWatchTab, 0)

    self.nightWatchTab:SetScript("OnClick", function()
        AchievementFrameSummary:Hide()
        AchievementFrameAchievements:Hide()
        AchievementFrameStats:Hide()
        for i = 1, 20 do
            local button = _G['AchievementFrameCategoriesContainerButton' .. i]
            if button then
                button:Hide()
            end
        end
        self:Show()
        self:UpdateUI(self.selectedCategory)
        PanelTemplates_SetTab(AchievementFrame, tabIndex + 1)
    end)
end

-- Метод для создания текстового элемента
local function CreateTextElement(parent, template, justify, point, relativeTo, relativePoint, x, y)
    local text = parent:CreateFontString(nil, "OVERLAY", template)
    text:SetJustifyH(justify)
    text:SetPoint(point, relativeTo, relativePoint, x, y)
    return text
end

-- Метод для создания текстуры
local function CreateTextureElement(parent, layer, texture, width, height, point, relativeTo, relativePoint, x, y)
    local tex = parent:CreateTexture(nil, layer)
    tex:SetTexture(texture)
    tex:SetSize(width, height)
    tex:SetPoint(point, relativeTo, relativePoint, x, y)
    return tex
end

-- Синхронизация динамических данных с новой структурой
function CustomAchievements:SyncDynamicData()
    if not self:IsStructureChanged() then
        return
    end

    local oldDataMap = {}
    for _, category in pairs(self.staticData) do
        for name, staticData in pairs(category) do
            local uniqueIndex = staticData.uniqueIndex
            if uniqueIndex and self.dynamicData[name] then
                oldDataMap[uniqueIndex] = self.dynamicData[name]
            end
        end
    end

    for categoryName, achievements in pairs(self.staticData) do
        for name, staticData in pairs(achievements) do
            local uniqueIndex = staticData.uniqueIndex
            if uniqueIndex then
                if oldDataMap[uniqueIndex] then
                    self.dynamicData[name] = oldDataMap[uniqueIndex]
                else
                    self.dynamicData[name] = {
                        uniqueIndex = uniqueIndex,
                        dateEarned = "Не получена",
                        dateCompleted = "Не выполнена",
                        progress = 0,
                        isExpanded = false,
                        scrollPosition = 0
                    }
                end
            end
        end
    end

    local idsToRemove = {}
    for name, data in pairs(self.dynamicData) do
        local found = false
        for _, category in pairs(self.staticData) do
            if category[name] then
                found = true
                break
            end
        end
        if not found then
            table.insert(idsToRemove, name)
        end
    end
    for _, id in ipairs(idsToRemove) do
        self.dynamicData[id] = nil
    end
end

-- Проверка изменения структуры данных
function CustomAchievements:IsStructureChanged()
    local staticIndexByUnique = {}
    local dynamicIndexByUnique = {}

    for _, category in pairs(self.staticData) do
        for name, staticData in pairs(category) do
            if staticData.uniqueIndex then
                staticIndexByUnique[staticData.uniqueIndex] = name
            end
        end
    end

    for name, dynamicData in pairs(self.dynamicData) do
        if dynamicData.uniqueIndex then
            dynamicIndexByUnique[dynamicData.uniqueIndex] = name
        end
    end

    for uniqueIndex, staticName in pairs(staticIndexByUnique) do
        local dynamicName = dynamicIndexByUnique[uniqueIndex]
        if dynamicName ~= staticName then
            return true
        end
    end

    for uniqueIndex in pairs(dynamicIndexByUnique) do
        if not staticIndexByUnique[uniqueIndex] then
            return true
        end
    end
    return false
end

-- Метод для поиска ID ачивки по уникальному индексу
function CustomAchievements:FindAchievementIdByUniqueIndex(uniqueIndex)
    for _, achievements in pairs(self.staticData) do
        for name, data in pairs(achievements) do
            if data.uniqueIndex == uniqueIndex then
                return name
            end
        end
    end
    return nil
end

-- Метод для поиска ID ачивки по имени
function CustomAchievements:FindAchievementIdByName(name)
    for _, achievements in pairs(self.staticData) do
        if achievements[name] then
            return name
        end
    end
    return nil
end

-- Создание основного фрейма
function CustomAchievements:CreateFrame(parent)
    self.frame = CreateFrame("Frame", nil, parent)
    self.frame:SetSize(850, 500)
    self.frame:SetPoint("CENTER")
    self.frame:Hide()

    local title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 130, -10)

    self:CreateCategoryButtons(self.frame)

    self.achievementList = CreateFrame("ScrollFrame", "achievementScrollFrame", self.frame, "UIPanelScrollFrameTemplate")
    self.achievementList:SetSize(690, 450)
    self.achievementList:SetPoint("TOPLEFT", self.categoryContainer, "TOPRIGHT", -100, 0)

    self.achievementContainer = CreateFrame("Frame", nil, self.achievementList)
    self.achievementContainer:SetSize(720, 450)
    self.achievementList:SetScrollChild(self.achievementContainer)

    local background = CreateTexture(self.achievementContainer, "BACKGROUND", TEXTURE_BACKGROUND)
    background:SetAllPoints()
    background:SetVertexColor(1, 1, 1, 1)

    local scrollBar = CreateFrame("Slider", nil, self.achievementList, "UIPanelScrollBarTemplate")
    scrollBar:Hide()
    scrollBar:SetPoint("TOPLEFT", self.achievementList, "TOPRIGHT", -20, -16)
    scrollBar:SetPoint("BOTTOMLEFT", self.achievementList, "BOTTOMRIGHT", -20, 16)
    scrollBar:SetWidth(SCROLL_BAR_WIDTH)
    scrollBar:SetValueStep(1)
    scrollBar:SetFrameStrata("DIALOG")
    scrollBar:SetScript("OnValueChanged", function(s, value) s:GetParent():SetVerticalScroll(value) end)
    self.achievementList.scrollBar = scrollBar
    self.achievementList:SetScript("OnMouseWheel", function(_, delta)
        scrollBar:SetValue(scrollBar:GetValue() - delta * 20)
    end)
end

-- Создание кнопок категорий
function CustomAchievements:CreateCategoryButtons(parent)
    if not parent then
        error("Parent frame is required for creating category buttons.")
    end

    local categories = {}
    for categoryName, _ in pairs(self.staticData) do
        categories[#categories + 1] = categoryName
    end

    local buttonWidth = 100
    local buttonHeight = 20
    local yOffset = 0
    self.categoryButtons = {}

    self.categoryContainer = CreateFrame("Frame", nil, parent)
    self.categoryContainer:SetSize(buttonWidth, #categories * buttonHeight + 10)
    self.categoryContainer:SetPoint("TOPLEFT", parent, "TOPLEFT", 70, -30)

    for _, category in ipairs(categories) do
        local button = CreateFrame("Button", nil, self.categoryContainer)
        button:SetSize(buttonWidth + 80, buttonHeight)
        button:SetPoint("TOPLEFT", self.categoryContainer, "TOPLEFT", 0, -yOffset)

        local normalTexture = button:CreateTexture(nil, "BACKGROUND")
        normalTexture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Category-Background")
        normalTexture:SetPoint("CENTER", button, "CENTER")
        normalTexture:SetSize(200, 35)
        normalTexture:SetTexCoord(0, 0.6640625, 0, 1)

        local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        buttonText:SetPoint("CENTER", button, "CENTER", 0, 3)
        buttonText:SetText(category)

        local highlightTexture = button:CreateTexture(nil, "HIGHLIGHT")
        highlightTexture:SetAllPoints()
        highlightTexture:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
        highlightTexture:SetBlendMode("ADD")
        highlightTexture:SetTexCoord(0, 1, 0, 0.5)

        button:SetScript("OnClick", function()
            self:FilterAchievementsByCategory(category)
        end)

        self.categoryButtons[category] = button
        yOffset = yOffset + buttonHeight + 5
    end
end

-- Метод для фильтрации ачивок по категории
function CustomAchievements:FilterAchievementsByCategory(category)
    if not self.achievementContainer then return end
    self.selectedCategory = category
    self:UpdateUI(category)
end

-- Метод для добавления ачивки
function CustomAchievements:AddAchievement(name)
    if not self.staticData[name] then
        print("Ошибка: ачивка с ID " .. name .. " не найдена в статичных данных")
        return
    end
    if self.dynamicData[name] then return end

    local currentDate = date("%d/%m/%Y %H:%M")
    self.dynamicData[name] = {
        uniqueIndex = self.staticData[name].uniqueIndex,
        dateEarned = currentDate,
        dateCompleted = "Не выполнена",
        progress = 0,
        isExpanded = false,
        scrollPosition = 0
    }

    self:UpdateUI(self.selectedCategory)
    self:ShowAchievementAlert(name)
end

-- Метод для обновления интерфейса с учетом выбранной категории
function CustomAchievements:UpdateUI(selectedCategory)
    self:SyncDynamicData()
    if not self.achievementContainer then return end

    for _, child in ipairs({self.achievementContainer:GetChildren()}) do
        child:Hide()
        child:ClearAllPoints()
        child:SetParent(nil)
    end
    self.buttons = {}

    local yOffset = 0
    local sortedAchievements = {}

    for category, achievements in pairs(self.staticData) do
        if not selectedCategory or category == selectedCategory then
            for name, staticData in pairs(achievements) do
                table.insert(sortedAchievements, {name = name, index = staticData.index or 0})
            end
        end
    end

    table.sort(sortedAchievements, function(a, b)
        return a.index < b.index
    end)

    for _, achievement in ipairs(sortedAchievements) do
        local name = achievement.name
        local dynamicData = self.dynamicData[name] or {}
        local button = self.buttons[name] or self:CreateAchievementButton(name, yOffset)
        if button then
            self.buttons[name] = button
            yOffset = yOffset + button:GetHeight()
        end
    end

    self:UpdateScrollArea(yOffset)
end

-- Метод для обновления скроллируемой области
function CustomAchievements:UpdateScrollArea(totalHeight)
    local scrollBar = self.achievementList.scrollBar
    local containerHeight = totalHeight + 60

    self.achievementContainer:SetHeight(containerHeight)

    if scrollBar then
        local scrollHeight = containerHeight - self.achievementList:GetHeight()
        scrollBar:SetMinMaxValues(0, math.max(0, scrollHeight))
        scrollBar:SetValue(0)
    end
end

-- Метод для отправки сообщения о выполнении ачивки в чат
function CustomAchievements:SendAchievementCompletionMessage(name)
    local achievementData = self:GetAchievementFullData(name)
    if achievementData then
        SendChatMessage("Достижение " .. achievementData.name .. ": " .. achievementData.dateCompleted, "OFFICER", nil, 1)
    end
end

-- Метод для создания кнопки ачивки
function CustomAchievements:CreateAchievementButton(name, yOffset)
    local achievement = self:GetAchievementFullData(name)
    if not achievement then return nil end

    local button = CreateFrame("Button", nil, self.achievementContainer)
    button:SetSize(510, COLLAPSED_HEIGHT)
    button:SetPoint("TOPLEFT", self.achievementContainer, "TOPLEFT", 195, -yOffset)
    button.id = name

    button.icon = CreateTextureElement(button, "ARTWORK", achievement.texture, DEFAULT_ICON_SIZE, DEFAULT_ICON_SIZE, "TOPLEFT", button, "TOPLEFT", self.COLLAPSED_POSITIONS.icon.x, self.COLLAPSED_POSITIONS.icon.y)
    button.nameText = CreateTextElement(button, "GameFontHighlight", "LEFT", "TOPLEFT", button.icon, "TOPRIGHT", 5, 0)
    button.nameText:SetText(achievement.name)
    button.dateText = CreateTextElement(button, "GameFontNormal", "LEFT", "TOPLEFT", button, "TOPLEFT", self.COLLAPSED_POSITIONS.date.x, self.COLLAPSED_POSITIONS.date.y)
    button.dateText:SetText(achievement.dateEarned)
    button.rewardPointsIcon = CreateTextureElement(button, "ARTWORK", TEXTURE_SHIELD, REWARD_ICON_SIZE, REWARD_ICON_SIZE, "TOPLEFT", button, "TOPLEFT", self.COLLAPSED_POSITIONS.rewardPoints.x, self.COLLAPSED_POSITIONS.rewardPoints.y)

    if achievement.dateCompleted ~= "Не выполнена" then
        button.rewardPointsIcon:SetTexCoord(0, 0.5, 0, 1)
    else
        button.rewardPointsIcon:SetTexCoord(0.5, 1, 0, 1)
    end

    button.rewardPointsText = CreateTextElement(button, "GameFontNormal", "CENTER", "CENTER", button.rewardPointsIcon, "CENTER", 0, 0)
    button.rewardPointsText:SetText(achievement.rewardPoints)

    button.highlight = CreateTextureElement(button, "BACKGROUND", TEXTURE_HIGHLIGHT, 510, COLLAPSED_HEIGHT, "TOPLEFT", button, "TOPLEFT", 0, 0)
    button.highlight:SetAlpha(0)

    button.normal = CreateTextureElement(button, "BACKGROUND", achievement.dateCompleted ~= "Не выполнена" and TEXTURE_COMPLETE or TEXTURE_INCOMPLETE, 510, COLLAPSED_HEIGHT, "TOPLEFT", button, "TOPLEFT", 0, 0)
    button.normal:SetAlpha(1)

    button:RegisterForClicks("RightButtonDown", "LeftButtonDown")
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            self.dynamicData[name].isExpanded = not self.dynamicData[name].isExpanded
            local scrollBarValue = self.achievementList.scrollBar:GetValue()
            self:UpdateUI(self.selectedCategory)
            self.achievementList.scrollBar:SetValue(scrollBarValue)
        elseif mouseButton == "RightButton" then
            self:SendAchievementCompletionMessage(name)
        end
    end)

    button:SetScript("OnEnter", function()
        button.highlight:SetAlpha(1)
        self:ShowAchievementTooltip(button, name)
    end)

    button:SetScript("OnLeave", function()
        button.highlight:SetAlpha(0)
        GameTooltip:Hide()
    end)

    if achievement.isExpanded then
        self:ExpandAchievement(button, name)
    end
    return button
end

-- Метод для показа тултипа
function CustomAchievements:ShowAchievementTooltip(button, name)
    local data = self:GetAchievementFullData(name)
    if not data then return end

    GameTooltip:SetOwner(button, TOOLTIP_ANCHOR)
    GameTooltip:SetText(data.name)
    GameTooltip:AddLine(data.description, 1, 1, 1, true)
    GameTooltip:AddLine("Дата получения: " .. data.dateEarned)
    if data.dateCompleted ~= "Не выполнена" then
        GameTooltip:AddLine("Выполнено: " .. data.dateCompleted)
    end
    GameTooltip:Show()
end

-- Метод для раскрытия ачивки
function CustomAchievements:ExpandAchievement(button, name)
    local achievement = self:GetAchievementFullData(name)
    if not achievement then return end

    if not button.descriptionText then
        button.descriptionText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        button.descriptionText:SetWidth(400)
        button.descriptionText:SetWordWrap(true)
        button.descriptionText:SetText(achievement.description)
        button.descriptionText:SetJustifyH("LEFT")
        button.descriptionText:Hide()
    end

    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.icon.x, self.EXPANDED_POSITIONS.icon.y)
    button.nameText:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.name.x, self.EXPANDED_POSITIONS.name.y)
    button.dateText:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.date.x, self.EXPANDED_POSITIONS.date.y)
    button.rewardPointsIcon:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.rewardPoints.x, self.EXPANDED_POSITIONS.rewardPoints.y)

    button.descriptionText:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.description.x, self.EXPANDED_POSITIONS.description.y)
    button.descriptionText:Show()

    local descriptionHeight = button.descriptionText:GetHeight()
    local requiredYOffset = -80
    local iconSize = 30
    local iconSpacing = 5

    for i, reqId in ipairs(achievement.subAchievements) do
        local reqAchievement = self:GetAchievementFullData(reqId)
        if reqAchievement then
            self:CreateNestedAchievementIcon(button, reqAchievement, i, self.EXPANDED_POSITIONS.requiredAchievements.x, requiredYOffset, iconSize, iconSpacing)
        end
    end

    local numRows = math.ceil(#achievement.subAchievements / MAX_ICONS_PER_ROW)
    local totalHeight = EXPANDED_BASE_HEIGHT + descriptionHeight + numRows * (iconSize + iconSpacing)
    button:SetHeight(totalHeight - 30)

    button.normal:SetAllPoints()
    button.highlight:SetAllPoints()
end

-- Метод для создания иконки под-ачивки
function CustomAchievements:CreateNestedAchievementIcon(parent, achievement, index, x, y, size, spacing)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(size, size)
    local col = (index - 1) % MAX_ICONS_PER_ROW
    local row = math.floor((index - 1) / MAX_ICONS_PER_ROW)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x + col * (size + spacing), y - row * (size + spacing))

    local icon = CreateTexture(button, "ARTWORK", achievement.texture)
    icon:SetAllPoints()

    if achievement.dateCompleted ~= "Не выполнена" then
        icon:SetDesaturated(false)
    else
        icon:SetDesaturated(true)
    end

    button:SetScript("OnMouseDown", function()
        self:NavigateToAchievement(achievement.id)
    end)

    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetText(achievement.name)
        GameTooltip:AddLine(achievement.description, 1, 1, 1, true)
        GameTooltip:AddLine("Дата получения: " .. achievement.dateEarned)
        if achievement.dateCompleted ~= "Не выполнена" then
            GameTooltip:AddLine("Выполнено: " .. achievement.dateCompleted)
        end
        GameTooltip:Show()
    end)

    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

-- Навигация к достижению
function CustomAchievements:NavigateToAchievement(id)
    for _, dynamic in pairs(self.dynamicData) do
        dynamic.isExpanded = false
    end

    local dynamic = self.dynamicData[id]
    if dynamic then
        dynamic.isExpanded = true
    end

    self:UpdateUI()
    local scrollBar = self.achievementList.scrollBar
    local scrollPosition = dynamic and dynamic.scrollPosition or 0
    scrollBar:SetValue(scrollPosition)
end

-- Метод для скрытия ачивок
function CustomAchievements:HideAchievements()
    if self.frame then
        self.frame:Hide()
    end
    for _, button in pairs(self.buttons) do
        button:Hide()
    end
end

-- Метод для отображения ачивок
function CustomAchievements:ShowAchievements()
    for _, button in pairs(self.buttons) do
        button:Show()
    end
end

-- Метод для отображения фрейма
function CustomAchievements:Show()
    if self.frame then
        self.frame:Show()
        self:UpdateUI(self.selectedCategory)
        self:ShowAchievements()
    end
end

-- Метод для скрытия фрейма
function CustomAchievements:Hide()
    if self.frame then
        self.frame:Hide()
        self.selectedCategory = nil
        self:UpdateUI()
    end
end

-- Метод для создания кастомного фрейма уведомлений
function CustomAchievements:CreateCustomAlertFrame()
    local alertFrame = CreateFrame("Frame", "CustomAchievementAlertFrame", UIParent)
    alertFrame:SetFrameStrata("DIALOG")
    alertFrame:SetFrameLevel(100)
    alertFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    alertFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    alertFrame:SetBackdropColor(0, 0, 0, 0.8)
    alertFrame:SetAlpha(1)

    alertFrame.Icon = alertFrame:CreateTexture(nil, "ARTWORK")
    alertFrame.Icon:SetSize(40, 40)
    alertFrame.Icon:SetPoint("TOPLEFT", alertFrame, "TOPLEFT", 10, -10)
    alertFrame.Icon:SetTexture("Interface\\Icons\\Ability_Rogue_ShadowStrikes")

    alertFrame.Name = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    alertFrame.Name:SetPoint("TOPLEFT", alertFrame.Icon, "TOPRIGHT", 10, 0)
    alertFrame.Name:SetJustifyH("LEFT")
    alertFrame.Name:SetText("Название ачивки")

    alertFrame.Description = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    alertFrame.Description:SetPoint("TOPLEFT", alertFrame.Name, "BOTTOMLEFT", 0, -5)
    alertFrame.Description:SetJustifyH("LEFT")
    alertFrame.Description:SetText("Описание ачивки")

    alertFrame.UpdateSize = function(self)
        local nameWidth = self.Name:GetStringWidth()
        local descriptionWidth = self.Description:GetStringWidth()
        local maxTextWidth = math.max(nameWidth, descriptionWidth)
        local minWidth = 300
        local frameWidth = math.max(minWidth, maxTextWidth + 75)
        local frameHeight = self.Name:GetHeight() + self.Description:GetHeight() + 35
        self:SetSize(frameWidth, frameHeight)
        self.Name:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 10, 0)
        self.Description:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -5)
    end
    return alertFrame
end

-- Метод для получения динамической таблицы ачивки по её имени
function CustomAchievements:GetAchievementData(name)
    for _, category in pairs(self.staticData) do
        if category[name] then
            return self.dynamicData[name]
        end
    end
    return nil
end

-- Метод для получения данных ачивки по её имени (объединяет статические и динамические данные)
function CustomAchievements:GetAchievementFullData(name)
    -- Проверяем наличие ачивки в статической таблице
    for _, category in pairs(self.staticData) do
        if category[name] then
            local staticData = category[name]
            local dynamicData = self.dynamicData[name] or {}  -- Если динамических данных нет, используем пустую таблицу
            -- Возвращаем объединенные данные
            return {
                name = staticData.name,
                description = staticData.description,
                texture = staticData.texture,
                rewardPoints = staticData.rewardPoints,
                requiredAchievements = staticData.requiredAchievements,
                subAchievements = staticData.subAchievements or {},
                dateEarned = dynamicData.dateEarned or "Не получена",
                dateCompleted = dynamicData.dateCompleted or "Не выполнена",
                progress = dynamicData.progress or 0,
                isExpanded = dynamicData.isExpanded or false,
                scrollPosition = dynamicData.scrollPosition or 0,
                category = category,  -- Возвращаем категорию, в которой находится ачивка
                send_txt = staticData.send_txt,
                subAchievements_args = staticData.subAchievements_args,
                achievement_args = staticData.achievement_args,
                achFunc = staticData.achFunc  -- Восстанавливаем поле achFunc
            }
        end
    end
    return nil  -- Если ачивка не найдена
end

-- Метод для отображения уведомления о новой ачивке
function CustomAchievements:ShowAchievementAlert(achievementName)
    local achievement = self:GetAchievementFullData(achievementName)
    if not achievement then
        print("Ачивка с именем " .. achievementName .. " не найдена.")
        return
    end

    if not self.customAlertFrame then
        self.customAlertFrame = self:CreateCustomAlertFrame()
    end

    self.customAlertFrame.Name:SetText(achievement.name)
    self.customAlertFrame.Description:SetText(achievement.description)
    self.customAlertFrame.Icon:SetTexture(achievement.texture)
    self.customAlertFrame:UpdateSize()
    self.customAlertFrame:SetAlpha(1)
    self.customAlertFrame:Show()

    self.customAlertFrame.timer = 5
    self.customAlertFrame.elapsed = 0
    self.customAlertFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= self.timer then
            local alpha = self:GetAlpha()
            alpha = alpha - elapsed * 0.5
            if alpha <= 0 then
                alpha = 0
                self:Hide()
                self:SetScript("OnUpdate", nil)
            end
            self:SetAlpha(alpha)
        end
    end)
end

-- Метод для проверки существования ачивки по имени
function CustomAchievements:IsAchievement(name)
    for _, category in pairs(self.staticData) do
        if category[name] then
            local uniqueIndex = category[name].uniqueIndex
            return self.dynamicData[name] ~= nil and self.dynamicData[name].uniqueIndex == uniqueIndex
        end
    end
    return false
end

-- Метод для проверки количества добавленных ачивок
function CustomAchievements:GetAchievementCount()
    local count = 0
    for _, _ in pairs(self.dynamicData) do
        count = count + 1
    end
    return count
end

-- Метод для изменения данных динамической таблицы
function CustomAchievements:setData(name, key, value)
    if not self.dynamicData[name] then
        print("Ошибка: ачивка с именем " .. name .. " не найдена в динамической таблице.")
        return
    end

    local allowedKeys = {
        dateEarned = true,
        dateCompleted = true,
        progress = true,
        isExpanded = true,
        scrollPosition = true
    }

    if not allowedKeys[key] then
        print("Ошибка: ключ " .. key .. " недопустим для изменения.")
        return
    end

    self.dynamicData[name][key] = value
    self:UpdateUI(self.selectedCategory)
end

NSQCMenu = {}
NSQCMenu.__index = NSQCMenu

-- Конструктор класса
function NSQCMenu:new(addonName, options)
    local instance = setmetatable({}, self)
    instance.addonName = addonName
    instance.subMenus = {}
    instance.elements = {}
    -- Создаем основной фрейм
    instance.mainFrame = CreateFrame("Frame", addonName.."MainFrame", InterfaceOptionsFramePanelContainer)
    instance.mainFrame.name = addonName
    instance.mainFrame:Hide()
    -- Инициализация позиции элементов
    instance.currentY = -50 -- Начальная позиция Y после заголовка
    -- Заголовок аддона
    local title = instance.mainFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(addonName)
    InterfaceOptions_AddCategory(instance.mainFrame)
    return instance
end

-- Метод для добавления информационной секции
function NSQCMenu:addInfoSection(titleText, contentText)
    local parentFrame = self.mainFrame
    local sectionY = self.currentY
    -- Добавляем подзаголовок
    local subtitle = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", 20, sectionY - 10)
    subtitle:SetText(titleText)
    subtitle:SetTextColor(1, 0.82, 0) -- Золотой цвет
    -- Добавляем текст
    local content = parentFrame:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    content:SetPoint("TOPLEFT", 30, sectionY - 30)
    content:SetWidth(550) -- Фиксированная ширина
    content:SetJustifyH("LEFT")
    content:SetJustifyV("TOP")
    content:SetText(self:wrapText(contentText, 540, "GameFontWhite")) -- Перенос текста
    -- Обновляем позицию для следующих элементов
    local textHeight = content:GetStringHeight()
    self.currentY = sectionY - 40 - textHeight
    table.insert(self.elements, {subtitle, content})
end

-- Метод для переноса текста
function NSQCMenu:wrapText(text, maxWidth, font)
    local wrappedText = ""
    local line = ""
    for word in text:gmatch("%S+") do
        local temp = line .. " " .. word
        local tempWidth = self:getStringWidth(self.mainFrame, temp, font)
        if tempWidth > maxWidth then
            wrappedText = wrappedText .. line .. "\n"
            line = word
        else
            line = temp
        end
    end
    return wrappedText .. line
end

-- Вспомогательный метод для получения ширины текста
function NSQCMenu:getStringWidth(frame, text, font)
    if not frame then
        print("Error: Frame is nil in getStringWidth")
        return 0
    end
    local temp = frame:CreateFontString(nil, "ARTWORK", font)
    temp:SetText(text)
    local width = temp:GetStringWidth()
    temp:Hide()
    return width
end

-- Метод для создания подменю
function NSQCMenu:addSubMenu(menuName)
    local subFrame = CreateFrame("Frame", self.addonName..menuName.."SubFrame", InterfaceOptionsFramePanelContainer)
    subFrame.name = menuName
    subFrame.parent = self.addonName
    subFrame:Hide()
    -- Создаем ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", menuName.."ScrollFrame", subFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -10, 10)
    -- Создаем контент для скролла
    local scrollContent = CreateFrame("Frame", menuName.."ScrollContent", scrollFrame)
    scrollContent:SetWidth(scrollFrame:GetWidth() - 20)
    scrollContent:SetHeight(1)
    scrollFrame:SetScrollChild(scrollContent)
    -- Настраиваем скроллбар
    local scrollBar = _G[menuName.."ScrollFrameScrollBar"]
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", -20, -16)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", -20, 16)
    -- Заголовок подменю
    local title = subFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(menuName)
    InterfaceOptions_AddCategory(subFrame)
    local subMenu = {
        frame = subFrame,
        scrollFrame = scrollFrame,
        scrollContent = scrollContent,
        elements = {},
        lastY = 0, -- Теперь отсчет от верхнего края scrollContent
        totalHeight = 0,
        maxHeight = scrollFrame:GetHeight()
    }
    table.insert(self.subMenus, subMenu)
    return subMenu
end

-- Методы для добавления элементов в подменю
function NSQCMenu:addSlider(parentMenu, options)
    local slider = CreateFrame("Slider", parentMenu.frame:GetName()..options.name, parentMenu.scrollContent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 16, -parentMenu.lastY)
    slider:SetWidth(590)
    slider:SetHeight(20)
    slider:SetMinMaxValues(options.min, options.max)
    slider:SetValueStep(options.step or 1)
    slider:SetValue(options.default)
    -- Добавляем текст тултипа
    slider.tooltipText = options.tooltip
    -- Текст слайдера
    _G[slider:GetName().."Text"]:SetText(options.label)
    _G[slider:GetName().."Low"]:SetText(options.min)
    _G[slider:GetName().."High"]:SetText(options.max)
    -- Обработчики тултипа
    slider:SetScript("OnEnter", function(self)
        if self.tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
            GameTooltip:AddLine("Текущее значение: |cffffffff"..self:GetValue().."|r", 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    slider:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    slider:SetScript("OnValueChanged", function(self, value)
        if options.onChange then options.onChange(value) end
        -- Обновляем тултип если открыт
        if GameTooltip:IsOwned(self) then
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
            GameTooltip:AddLine("Текущее значение: |cffffffff"..value.."|r", 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    -- Обновляем высоту контента
    parentMenu.lastY = parentMenu.lastY + 40
    parentMenu.totalHeight = parentMenu.totalHeight + 40
    parentMenu.scrollContent:SetHeight(parentMenu.totalHeight)
    table.insert(parentMenu.elements, slider)
    self:updateScrollRange(parentMenu)
    return slider
end

function NSQCMenu:addCheckbox(parentMenu, options)
    local checkbox = CreateFrame("CheckButton", parentMenu.frame:GetName()..options.name, parentMenu.scrollContent, "ChatConfigCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 16, -parentMenu.lastY)
    checkbox:SetChecked(options.default or false)
    -- Добавляем текст тултипа
    checkbox.tooltipText = options.tooltip
    -- Текст чекбокса
    local label = parentMenu.scrollContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    label:SetText(options.label)
    -- Обработчики тултипа
    checkbox:SetScript("OnEnter", function(self)
        if self.tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
            local state = self:GetChecked() and "|cff00ff00Включено|r" or "|cffff0000Выключено|r"
            GameTooltip:AddLine("Текущее значение: "..state, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    checkbox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    checkbox:SetScript("OnClick", function(self)
        if options.onClick then options.onClick(self:GetChecked()) end
        -- Обновляем тултип если открыт
        if GameTooltip:IsOwned(self) then
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
            local state = self:GetChecked() and "|cff00ff00Включено|r" or "|cffff0000Выключено|r"
            GameTooltip:AddLine("Текущее значение: "..state, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    -- Обновляем высоту контента
    parentMenu.lastY = parentMenu.lastY + 30
    parentMenu.totalHeight = parentMenu.totalHeight + 30
    parentMenu.scrollContent:SetHeight(parentMenu.totalHeight)
    table.insert(parentMenu.elements, checkbox)
    self:updateScrollRange(parentMenu)
    return checkbox
end

function NSQCMenu:updateScrollRange(parentMenu)
    local scrollFrame = parentMenu.scrollFrame
    local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]
    if not scrollBar then
        error("Scrollbar not found for scrollFrame: " .. scrollFrame:GetName())
    end
    local maxRange = parentMenu.totalHeight - parentMenu.maxHeight
    if maxRange < 0 then maxRange = 0 end
    scrollBar:SetMinMaxValues(0, maxRange)
    scrollBar:SetValue(0)
    scrollFrame:UpdateScrollChildRect()
end

QuestUI = {}
QuestUI.__index = QuestUI

function QuestUI:Create(parent)
    local self = setmetatable({}, QuestUI)
    
    -- Основное окно
    self.mainFrame = CreateFrame("Frame", nil, parent or UIParent)
    self.mainFrame:SetSize(400, 500)
    self.mainFrame:SetPoint("CENTER")
    self.mainFrame:SetMovable(true)
    self.mainFrame:EnableMouse(true)
    self.mainFrame:RegisterForDrag("LeftButton")
    self.mainFrame:SetScript("OnDragStart", self.mainFrame.StartMoving)
    self.mainFrame:SetScript("OnDragStop", self.mainFrame.StopMovingOrSizing)
    self.mainFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    self.mainFrame:SetFrameStrata("FULLSCREEN")
    self.mainFrame:SetAlpha(1.0)
    self.mainFrame:SetBackdropColor(0, 0, 0, 1)
    
    -- Заголовок основного окна
    local mainTitleBg = CreateFrame("Frame", nil, self.mainFrame)
    mainTitleBg:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 0, 0)
    mainTitleBg:SetPoint("TOPRIGHT", self.mainFrame, "TOPRIGHT", 0, 0)
    mainTitleBg:SetHeight(35) -- Увеличиваем высоту заголовка до 35 пикселей
    mainTitleBg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Header",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    mainTitleBg:SetBackdropColor(0, 0, 0, 1)
    
    local mainTitle = mainTitleBg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mainTitle:SetPoint("CENTER", mainTitleBg, "CENTER", 0, 0)
    mainTitle:SetText("Квест")
    
    -- Кнопка закрытия
    self.closeButton = CreateFrame("Button", nil, self.mainFrame, "UIPanelCloseButton")
    self.closeButton:SetPoint("TOPRIGHT", -3, 0)
    self.closeButton:SetScript("OnClick", function() self:Hide() end)
    
    -- Окна (левое, правое и действия)
    self.leftItemsFrame = self:_CreateSideFrame("LEFT", "TOP", 300, 300, "Локации")
    self.rightItemsFrame = self:_CreateSideFrame("RIGHT", "TOP", 300, 300, "Предметы")
    self.actionsFrame = self:_CreateSideFrame("RIGHT", "BOTTOM", 300, 200, "Действия")
    
    -- Настройка текста квеста
    self:_SetupQuestText()
    
    return self
end

function QuestUI:_CreateSideFrame(side, anchorPoint, width, height, titleText)
    local frame = CreateFrame("Frame", nil, self.mainFrame)
    frame:SetSize(width, height)
    
    -- Позиционирование
    if side == "LEFT" then
        frame:SetPoint("RIGHT", self.mainFrame, "LEFT", -10, 0)
    else
        frame:SetPoint("LEFT", self.mainFrame, "RIGHT", 10, 0)
    end
    frame:SetPoint(anchorPoint, self.mainFrame, anchorPoint, 0, 0)
    
    -- Стиль окна
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 1)
    
    -- Заголовок окна
    local titleBg = CreateFrame("Frame", nil, frame)
    titleBg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    titleBg:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    titleBg:SetHeight(35) -- Увеличиваем высоту заголовка до 35 пикселей
    titleBg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Header",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    titleBg:SetBackdropColor(0, 0, 0, 1)
    
    local title = titleBg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("CENTER", titleBg, "CENTER", 0, 0)
    title:SetText(titleText) -- Используем переданный текст заголовка
    
    -- Scroll Frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame)
    scrollFrame:SetPoint("TOPLEFT", 8, -43) -- Смещаем вниз, чтобы не перекрывать увеличенный заголовок
    scrollFrame:SetPoint("BOTTOMRIGHT", -8, 8)
    
    -- Scroll Bar
    local scrollBar = CreateFrame("Slider", nil, scrollFrame, "UIPanelScrollBarTemplate")
    scrollBar:SetPoint("TOPRIGHT", 8, -16)
    scrollBar:SetPoint("BOTTOMRIGHT", 8, 16)
    scrollBar:SetWidth(16)
    scrollBar:SetScript("OnValueChanged", function(_, value)
        scrollFrame:SetVerticalScroll(value)
    end)
    
    -- Контент
    local content = CreateFrame("Frame")
    content:SetSize(width - 16, 1)
    scrollFrame:SetScrollChild(content)
    
    return {
        frame = frame,
        scrollFrame = scrollFrame,
        scrollBar = scrollBar,
        content = content,
        items = {},
        title = title
    }
end

function QuestUI:_SetupQuestText()
    self.questScroll = CreateFrame("ScrollFrame", nil, self.mainFrame)
    self.questScroll:SetPoint("TOPLEFT", 15, -15)
    self.questScroll:SetSize(370, 475)
    
    self.mainScrollBar = CreateFrame("Slider", nil, self.questScroll, "UIPanelScrollBarTemplate")
    self.mainScrollBar:SetPoint("TOPRIGHT", 0, -30)
    self.mainScrollBar:SetPoint("BOTTOMRIGHT", -8, 16)
    self.mainScrollBar:SetWidth(16)
    self.mainScrollBar:SetScript("OnValueChanged", function(_, value)
        self.questScroll:SetVerticalScroll(value)
    end)
    
    self.questContent = CreateFrame("Frame")
    self.questContent:SetSize(340, 1)
    self.questScroll:SetScrollChild(self.questContent)
    
    self.questText = self.questContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.questText:SetPoint("TOPLEFT", 10, -25)
    self.questText:SetJustifyH("LEFT")
    self.questText:SetWordWrap(true)
    self.questText:SetWidth(325)
end

function QuestUI:SetQuestText(text)
    self.questText:SetText(text)
    local textHeight = self.questText:GetStringHeight()
    self.questContent:SetHeight(math.max(textHeight + 20, 475))
    self:_UpdateScroll({
        scrollFrame = self.questScroll,
        scrollBar = self.mainScrollBar,
        content = self.questContent
    })
end

function QuestUI:AddItem(name, onClick)
    self:_AddListElement(self.rightItemsFrame, name, onClick)
end

function QuestUI:AddLocationItem(name, onClick)
    self:_AddListElement(self.leftItemsFrame, name, onClick)
end

function QuestUI:AddAction(name, onClick)
    self:_AddListElement(self.actionsFrame, name, onClick)
end

function QuestUI:_AddListElement(targetFrame, text, onClick)
    local button = CreateFrame("Button", nil, targetFrame.content)
    button:SetHeight(20)
    
    button.textField = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.textField:SetText(text)
    button.textField:SetPoint("LEFT")
    
    local textWidth = button.textField:GetStringWidth()
    button:SetWidth(textWidth)
    
    local yOffset = -(#targetFrame.items * 20)
    button:SetPoint("TOPLEFT", 10, yOffset)
    
    button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    button:GetHighlightTexture():SetAlpha(0.6)
    button:SetScript("OnClick", onClick)
    
    table.insert(targetFrame.items, button)
    targetFrame.content:SetHeight(#targetFrame.items * 20)
    self:_UpdateFrameWidth(targetFrame)
    self:_UpdateScroll(targetFrame)
end

function QuestUI:_UpdateFrameWidth(targetFrame)
    local maxWidth = 0
    for _, button in ipairs(targetFrame.items) do
        local textWidth = button.textField:GetStringWidth()
        if textWidth > maxWidth then maxWidth = textWidth end
    end
    local newWidth = maxWidth + 20
    targetFrame.frame:SetWidth(newWidth + 16)
    targetFrame.content:SetWidth(newWidth)
end

function QuestUI:_UpdateScroll(targetFrame)
    local contentHeight = targetFrame.content:GetHeight()
    local frameHeight = targetFrame.scrollFrame:GetHeight()
    local maxScroll = math.max(0, contentHeight - frameHeight)
    targetFrame.scrollBar:SetMinMaxValues(0, maxScroll)
    targetFrame.scrollBar:SetValue(0)
    if maxScroll > 0 then
        targetFrame.scrollBar:Show()
    else
        targetFrame.scrollBar:Hide()
    end
end

function QuestUI:ClearItems()
    self:_ClearFrame(self.rightItemsFrame)
end

function QuestUI:ClearLocationItems()
    self:_ClearFrame(self.leftItemsFrame)
end

function QuestUI:ClearActions()
    self:_ClearFrame(self.actionsFrame)
end

function QuestUI:_ClearFrame(targetFrame)
    for _, button in ipairs(targetFrame.items) do
        button:Hide()
        button:SetParent(nil)
    end
    targetFrame.items = {}
    targetFrame.content:SetHeight(0)
    targetFrame.frame:SetWidth(230)
    targetFrame.content:SetWidth(230 - 16)
    self:_UpdateScroll(targetFrame)
end

function QuestUI:Show()
    self.mainFrame:Show()
    self.leftItemsFrame.frame:Show()
    self.rightItemsFrame.frame:Show()
    self.actionsFrame.frame:Show()
end

function QuestUI:Hide()
    self.mainFrame:Hide()
    self.leftItemsFrame.frame:Hide()
    self.rightItemsFrame.frame:Hide()
    self.actionsFrame.frame:Hide()
end

-- Пример использования
questUI = QuestUI:Create(UIParent)
questUI:SetQuestText("Новый текст квеста с интерактивными элементами")
questUI:AddItem("Меч героя", function() print("Меч выбран!") end)
questUI:AddLocationItem("Сундук", function() print("Сундук открыт!") end)
questUI:AddAction("Атаковать", function() print("Атака!") end)
questUI:Show()








