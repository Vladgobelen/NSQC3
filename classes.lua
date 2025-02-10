-- Локальные переменные для оптимизации
local pairs = pairs
local table_insert = table.insert
local setmetatable = setmetatable
local utf8len = string.utf8len
local CreateFrame = CreateFrame
local tonumber = tonumber
local utf8sub = string.utf8sub
local ipairs = ipairs
local gmatch = string.gmatch
local numeCod = numeCod
local string_utf8sub = string.utf8sub
local string_utf8len = string.utf8len
-- Определяем класс NsDb
NsDb = {}
NsDb.__index = NsDb

-- Конструктор для создания нового объекта NsDb
function NsDb:new(input_table, input_table_p, key, str_len, tbl_size)
    local new_object = setmetatable({}, self)
    if input_table_p then
        input_table_p[key] = input_table_p[key] or {}
        new_object.input_table_p = input_table_p[key]
    end
    if key then
        input_table[key] = input_table[key] or {}
        new_object.input_table = input_table[key]
    else
        input_table = input_table or {}
        new_object.input_table = input_table
    end
    new_object.str_len = str_len
    new_object.tbl_size = tbl_size
    if input_table_p then
        new_object.isPointer = 1
    end
    return new_object
end

-- Метод для получения строки по индексу
function NsDb:getLine(line)
    local function getSum(line)
        local targetLength = line
        local totalLengths = 0
        local targetLineIndex
        local targetLine

        local decodedLengthsCache = {}

        -- Проходим по всем строкам в input_table_p
        for i, lengthsLine in ipairs(self.input_table_p) do
            if not decodedLengthsCache[i] then
                local lengths = {}
                -- Разбиваем строку на пары символов
                for length in gmatch(lengthsLine, "..") do
                    table_insert(lengths, length)
                end
                decodedLengthsCache[i] = lengths
            end

            local lengths = decodedLengthsCache[i]
            totalLengths = totalLengths + #lengths

            -- Если суммарная длина превышает целевой индекс, сохраняем строку
            if totalLengths >= targetLength then
                targetLineIndex = i
                targetLine = lengthsLine
                break
            end
        end

        if not targetLine then
            return nil, "Длина не найдена."
        end

        local lengths = decodedLengthsCache[targetLineIndex]
        local positionInLine = targetLength - (totalLengths - #lengths)

        if positionInLine < 1 or positionInLine > #lengths then
            return nil, "Длина не найдена в целевой строке."
        end

        local decodedLengths = {}
        for i = 1, #lengths do
            decodedLengths[i] = numeCod(lengths[i])
        end

        local sum = 0
        for i = 1, positionInLine do
            sum = sum + (decodedLengths[i] or 0)
        end

        return decodedLengths[positionInLine], sum, targetLineIndex, positionInLine, lengths[positionInLine], decodedLengths[positionInLine]
    end

    local num, sum, my_line, positionInLine, encryptedLength, decryptedLength = getSum(line)

    if num then
        local startIndex = sum - num + 1
        local endIndex = sum
        local inputLine = self.input_table[my_line]
        local inputLineLength = utf8len(inputLine)  -- Используем кэшированную функцию

        if startIndex < 1 or endIndex > inputLineLength then
            return nil, "Некорректные индексы для подстроки."
        end

        return utf8sub(inputLine, startIndex, endIndex)  -- Используем кэшированную функцию
    else
        return nil, "Длина не найдена."
    end
end

-- Метод для создания бинарного представления сообщения
function NsDb:create_bin(message, str)
    local pointer = numCod(utf8len(message))
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
    if num < 1 or #self.input_table[num] >= self.tbl_size then
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

    -- Декодируем адрес с помощью функции numeCod
    local wordCount = numeCod(address)
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
            pLen = pLen + (tonumber(utf8len(self.input_table_p[i]))/2)
        end
        return pLen
    else
        return nil
    end
end
function NsDb:Len()
    local Len = 0
    for i = 1, #self.input_table do
        Len = Len + #self.input_table[i]
    end
    return Len
end

-- Метод для изменения ключа
function NsDb:mod_key(change_key, message, dop_key, id)
    if dop_key then
        self.input_table[dop_key] = self.input_table[dop_key] or {}
        if id then
            self.input_table[dop_key][change_key] = self.input_table[dop_key][change_key] or {}
            self.input_table[dop_key][change_key][id] = message
        else
            self.input_table[dop_key][change_key] = message
        end
    else
        if id then
            self.input_table[change_key] = self.input_table[change_key] or {}
            self.input_table[change_key][id] = message
        else
            self.input_table[change_key] = message
        end
    end
end
function NsDb:get_key(change_key, dop_key, id)
    -- Проверяем существование основных таблиц и ключей на каждом уровне
    if dop_key then
        local dop_table = self.input_table[dop_key]
        if dop_table and dop_table[change_key] then
            if id and dop_table[change_key][id] ~= nil then
                return dop_table[change_key][id]
            elseif not id then
                return dop_table[change_key]
            end
        end
    else
        local change_table = self.input_table[change_key]
        if change_table then
            if id and change_table[id] ~= nil then
                return change_table[id]
            elseif not id then
                return change_table
            end
        end
    end

    -- Если что-то пошло не так, возвращаем nil
    return nil
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
    -- Создаем фрейм кнопки
    if texture then
        button.frame = CreateFrame("Button", name, parent)
        button.frame:SetNormalTexture(texture)
        button.frame:SetHighlightTexture(texture) -- Устанавливаем текстуру подсветки
    else
        button.frame = CreateFrame("Button", name, parent, "UIPanelButtonTemplate")
    end
    
    -- Проверяем, удалось ли создать фрейм
    if not button.frame then
        print("Ошибка: не удалось создать фрейм кнопки!")
        return
    end
    
    -- Устанавливаем размер и текст кнопки
    button.frame:SetSize(width, height)
    button:SetText(text)
    
    -- Делаем кнопку перемещаемой
    if mv then
        button:SetMovable(mv)
    end
    
    return button
end

function ButtonManager:SetTexture(texture, highlightTexture)
    if texture then
        self.frame:SetNormalTexture('Interface\\AddOns\\NSQC3\\libs\\' .. texture .. '.tga')
    end
    if highlightTexture then
        self.frame:SetHighlightTexture('Interface\\AddOns\\NSQC3\\libs\\' .. highlightTexture .. '.tga') -- Устанавливаем текстуру подсветки
    end
end

-- Метод для установки текста на кнопке
function ButtonManager:SetText(text)
    if texture then
        self.frame:SetText(text)
    else
        local fontString = self.frame:GetFontString()
        if not fontString then
            fontString = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            self.frame:SetFontString(fontString)
        end

        -- Устанавливаем текст
        fontString:SetText(text)

        -- Получаем размеры кнопки
        local buttonWidth, buttonHeight = self.frame:GetSize()

        -- Начальный размер шрифта (60% от высоты кнопки)
        local fontSize = math.floor(buttonHeight * 0.6)

        -- Устанавливаем шрифт
        fontString:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE", "MONOCHROME")

        -- Проверяем, помещается ли текст в кнопку
        while fontString:GetStringWidth() > buttonWidth and fontSize > 6 do
            fontSize = fontSize - 1 -- Уменьшаем размер шрифта
            fontString:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE", "MONOCHROME")
        end

        -- Выравниваем текст по центру кнопки
        fontString:SetPoint("CENTER", self.frame, "CENTER", 0, 0) -- Центрируем текст
        fontString:SetJustifyH("CENTER") -- Горизонтальное выравнивание по центру
        fontString:SetJustifyV("MIDDLE") -- Вертикальное выравнивание по центру

        -- Убедимся, что текст не выходит за границы кнопки
        fontString:SetWordWrap(false) -- Отключаем перенос слов
        fontString:SetNonSpaceWrap(false) -- Отключаем перенос по пробелам
    end
end

-- Метод для установки текста на кнопке через FontString
function ButtonManager:SetTextT(text)
    local fontString = self.frame:GetFontString()
    if not fontString then
        fontString = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        self.frame:SetFontString(fontString)
    end
    fontString:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE", "MONOCHROME")
    fontString:SetText(text)
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
        -- Вызываем предыдущий обработчик (например, для тултипа)
        if oldOnEnter then oldOnEnter(selfFrame, ...) end
        
        -- Вызываем новый обработчик
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
    
    -- Сохраняем предыдущие обработчики
    local oldOnEnter = self.frame:GetScript("OnEnter")
    local oldOnLeave = self.frame:GetScript("OnLeave")
    
    self.frame:SetScript("OnEnter", function(selfFrame, ...)
        -- Вызываем предыдущий обработчик, если он был
        if oldOnEnter then oldOnEnter(selfFrame, ...) end
        
        GameTooltip:SetOwner(selfFrame, "ANCHOR_RIGHT")
        for _, line in ipairs(tooltipsTable) do
            GameTooltip:AddLine(line, 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    
    self.frame:SetScript("OnLeave", function(...)
        -- Вызываем предыдущий обработчик, если он был
        if oldOnLeave then oldOnLeave(...) end
        GameTooltip:Hide()
    end)
end

function ButtonManager:SetSize(width, height)
    if self.frame then
        self.frame:SetWidth(width)  -- Используем SetWidth и SetHeight вместо SetSize
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
        -- Разрешаем перемещение кнопки
        self.frame:SetMovable(true)
        self.frame:RegisterForDrag("LeftButton") -- Разрешаем перетаскивание левой кнопкой мыши
        self.frame:SetScript("OnDragStart", function(self)
            self:StartMoving() -- Начинаем перемещение
        end)
        self.frame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing() -- Завершаем перемещение
        end)
    else
        -- Запрещаем перемещение кнопки
        self.frame:SetMovable(false)
        self.frame:RegisterForDrag(nil) -- Отключаем перетаскивание
        self.frame:SetScript("OnDragStart", nil) -- Убираем обработчики
        self.frame:SetScript("OnDragStop", nil)
    end
end

-- Константы
local CLOSE_BUTTON_SIZE = 32
local PADDING = 15
local SCREEN_PADDING = -40  -- Отступ от краев экрана
local MIN_WIDTH = 200       -- Минимальная ширина фрейма
local MIN_HEIGHT = 200      -- Минимальная высота фрейма
local BUTTON_PADDING = 0    -- Расстояние между кнопками
local F_PAD = 40
local MOVE_ALPHA = .0

-- Добавляем константы прозрачности
local FRAME_ALPHA = 0     -- Прозрачность основного фрейма
local BUTTON_ALPHA = 1    -- Прозрачность дочерних кнопок

-- Определяем класс AdaptiveFrame
AdaptiveFrame = {}
AdaptiveFrame.__index = AdaptiveFrame

-- Конструктор для создания нового объекта AdaptiveFrame
function AdaptiveFrame:new(parent)
    local self = setmetatable({}, AdaptiveFrame)
    self.parent = parent or UIParent
    self.width = 600        -- По умолчанию ширина
    self.height = 600       -- По умолчанию высота
    self.initialAspectRatio = self.width / self.height  -- Сохраняем начальное соотношение сторон
    self.buttonsPerRow = 5  -- Количество кнопок в ряду (по умолчанию)

    -- Создаем фрейм
    self.frame = CreateFrame("Frame", nil, self.parent)
    self.frame:SetSize(self.width, self.height)
    self.frame:SetPoint("CENTER", self.parent, "CENTER", 150, 100)
    self.frame:SetFrameStrata("HIGH")
    self.frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    FRAME_ALPHA = ns_dbc:get_key("FRAME_ALPHA", "настройки") or FRAME_ALPHA
    BUTTON_ALPHA = ns_dbc:get_key("BUTTON_ALPHA", "настройки") or BUTTON_ALPHA
    self.frame:SetBackdropColor(0.1, 0.1, 0.1, FRAME_ALPHA)  -- Устанавливаем прозрачность фрейма
    self.frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 0)

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
                            child.frame:SetAlpha(math.min(currentAlpha + math.abs(deltaX) / 1000, 1)) -- Исправлено: child.frame -> child
                            ns_dbc:mod_key("BUTTON_ALPHA", math.min(currentAlpha + math.abs(deltaX) / 1000, 1), "настройки")
                            BUTTON_ALPHA = ns_dbc:get_key("BUTTON_ALPHA", "настройки") or BUTTON_ALPHA
                        elseif deltaX < 0 then
                            -- Уменьшаем прозрачность при движении влево
                            child.frame:SetAlpha(math.max(currentAlpha - math.abs(deltaX) / 1000, 0)) -- Исправлено: child.frame -> child
                            ns_dbc:mod_key("BUTTON_ALPHA", math.max(currentAlpha - math.abs(deltaX) / 1000, 0), "настройки")
                            BUTTON_ALPHA = ns_dbc:get_key("BUTTON_ALPHA", "настройки") or BUTTON_ALPHA
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
        --self:AdjustSizeAndPosition()
    end)

    -- Обработчик изменения размера фрейма
    self.frame:SetScript("OnSizeChanged", function(_, width, height)
        width, height = self:CheckFrameSize(width, height)
        self.frame:SetSize(width, height)
        self:AdjustSizeAndPosition()
    end)

    -- Инициализируем список дочерних элементов
    self.children = {}

    return self
end

-- Метод для переключения прозрачности основного фрейма
function AdaptiveFrame:ToggleFrameAlpha()
    local currentAlpha = select(4, self.frame:GetBackdropColor())
    FRAME_ALPHA = ns_dbc:get_key("FRAME_ALPHA", "настройки") or FRAME_ALPHA
    if currentAlpha > FRAME_ALPHA-0.05 then
        self.frame:SetBackdropColor(0.1, 0.1, 0.1, 0)  -- Сбрасываем прозрачность до нуля
    elseif currentAlpha == 0 then
        self.frame:SetBackdropColor(0.1, 0.1, 0.1, FRAME_ALPHA)  -- Возвращаем исходную прозрачность
    end
end

-- Метод для начала перемещения фрейма
function AdaptiveFrame:StartMoving()
    self.frame:StartMoving()
end

-- Метод для остановки перемещения или изменения размера фрейма
function AdaptiveFrame:StopMovingOrSizing()
    local x, y = self:GetPosition()
    ns_dbc:mod_key("mfldX", x, "настройки")
    ns_dbc:mod_key("mfldY", y, "настройки")
    self.frame:StopMovingOrSizing()
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
    local minFrameHeight = MIN_HEIGHT         -- Минимальная высота фрейма

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
    SCREEN_PADDING = ns_dbc:get_key("SCREEN_PADDING", "настройки") or SCREEN_PADDING
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
        local button = ButtonManager:new(buttonName, self.frame, buttonWidth, buttonHeight, buttonText, 'Interface\\AddOns\\NSQC3\\libs\\00t.tga', nil)
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

    MOVE_ALPHA = ns_dbc:get_key("MOVE_ALPHA", "настройки") or MOVE_ALPHA
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
            self.parent.frame:EnableMouse(self.targetAlpha > 0.1)
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
                    child.frame:EnableMouse(self.currentAlpha > 0.1)
                    if self.currentAlpha < .1 then
                        self.parent:Hide()
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

mDB = {}
mDB.__index = mDB
function mDB:new()
    local private = {}

    local obj = {
        getArg = function(self, index)
            return private[index]
        end,
        setArg = function(self, index, value)
            private[index] = value
        end
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end

-- Класс UniversalInfoFrame
UniversalInfoFrame = {}
UniversalInfoFrame.__index = UniversalInfoFrame

function UniversalInfoFrame:new(updateInterval, saveTable)
    -- Инициализация нового объекта
    local new_object = setmetatable({}, self)
    self.__index = self

    -- Инициализация параметров
    new_object.saveTable = saveTable or {}
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

-- Класс ChatHandler для обработки сообщений чата
ChatHandler = {}
ChatHandler.__index = ChatHandler

function ChatHandler:new(triggersByAddress, chatTypes)
    local new_object = setmetatable({}, self)
    self.__index = self

    -- Инициализация таблицы триггеров
    new_object.triggersByAddress = triggersByAddress or {}

    -- Создаем фрейм для обработки событий
    new_object.frame = CreateFrame("Frame")

    -- Регистрируем события чата в зависимости от переданных chatTypes
    if chatTypes then
        for _, chatType in ipairs(chatTypes) do
            if chatType == "ADDON" then
                new_object.frame:RegisterEvent("CHAT_MSG_ADDON")
            else
                new_object.frame:RegisterEvent("CHAT_MSG_" .. chatType)
            end
        end
    else
        -- Если chatTypes не указан, регистрируем все события по умолчанию
        new_object.frame:RegisterEvent("CHAT_MSG_CHANNEL")
        new_object.frame:RegisterEvent("CHAT_MSG_SAY")
        new_object.frame:RegisterEvent("CHAT_MSG_YELL")
        new_object.frame:RegisterEvent("CHAT_MSG_WHISPER")
        new_object.frame:RegisterEvent("CHAT_MSG_GUILD")
        new_object.frame:RegisterEvent("CHAT_MSG_PARTY")
        new_object.frame:RegisterEvent("CHAT_MSG_RAID")
        new_object.frame:RegisterEvent("CHAT_MSG_RAID_WARNING")
        new_object.frame:RegisterEvent("CHAT_MSG_BATTLEGROUND")
        new_object.frame:RegisterEvent("CHAT_MSG_SYSTEM")
        new_object.frame:RegisterEvent("CHAT_MSG_ADDON")
    end

    -- Устанавливаем обработчик событий
    new_object.frame:SetScript("OnEvent", function(_, event, ...)
        new_object:OnChatMessage(event, ...)
    end)

    return new_object
end

-- Метод для обработки сообщений чата
function ChatHandler:OnChatMessage(event, ...)
    local text, sender, _, _, _, _, _, _, channel, channelName, _, prefix

    -- Обработка событий ADDON (параметры идут в другом порядке)
    if event == "CHAT_MSG_ADDON" then
        prefix, text, channel, sender = ...
    else
        -- Обработка обычных сообщений чата
        text, sender = ...
    end
    -- Проверяем триггер для специального ключа "*"
    if self.triggersByAddress["*"] then
        for _, trigger in ipairs(self.triggersByAddress["*"]) do
            if self:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event) then
                if trigger.stopOnMatch then
                    return -- Прекращаем обработку, если указан stopOnMatch
                end
            end
        end
    end

    -- Определяем адрес (первое слово сообщения или префикса)
    local addressPrefix = (event == "CHAT_MSG_ADDON" and "prefix:" .. (string.match(prefix, "^(%S+)") or "")) or nil
    local addressMessage = "message:" .. (string.match(text, "^(%S+)") or "")

    -- Проверяем триггеры для префикса (если это ADDON-сообщение)
    if addressPrefix and self.triggersByAddress[addressPrefix] then
        for _, trigger in ipairs(self.triggersByAddress[addressPrefix]) do
            if self:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event) then
                return
            end
        end
    end

    -- Проверяем триггеры для сообщения
    if self.triggersByAddress[addressMessage] then
        for _, trigger in ipairs(self.triggersByAddress[addressMessage]) do
            if self:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event) then
                return
            end
        end
    end
end

function ChatHandler:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event)
    local keywords = trigger.keyword or {}
    local funcName = trigger.func
    local conditions = trigger.conditions or {}
    local stopOnMatch = trigger.stopOnMatch or false
    local chatTypes = trigger.chatType
    -- Проверяем тип чата
    if chatTypes then
        local currentChatType = string.match(event, "CHAT_MSG_(.+)")
        local chatTypeMatch = false
        for _, allowedChatType in ipairs(chatTypes) do
            if currentChatType == allowedChatType then
                chatTypeMatch = true
                break
            end
        end
        if not chatTypeMatch then
            return false
        end
    else
        print("No specific chat types defined for this trigger.")
    end

    -- Проверяем запрещенные слова
    local allForbiddenWords = {}
    for _, wordOrVar in ipairs(trigger.forbiddenWords or {}) do
        if type(wordOrVar) == "string" and wordOrVar:sub(1, 1) == "$" then
            local varName = wordOrVar:sub(2)
            local varValue = _G[varName]
            if type(varValue) == "table" then
                for _, forbiddenWord in ipairs(varValue) do
                    table.insert(allForbiddenWords, forbiddenWord)
                end
            elseif type(varValue) == "string" then
                table.insert(allForbiddenWords, varValue)
            end
        else
            table.insert(allForbiddenWords, wordOrVar)
        end
    end

    for _, forbiddenWord in ipairs(allForbiddenWords) do
        if string.find(text:lower(), forbiddenWord:lower()) then
            print("Found forbidden word:", forbiddenWord)
            return false
        end
    end

    -- Проверяем ключевые слова
    local keywordsMatch = true
    if #keywords > 0 then
        for _, keywordData in ipairs(keywords) do
            local word = keywordData.word
            local position = keywordData.position
            local source = keywordData.source
            local targetText = (source == "prefix") and prefix or text
            local currentIndex = 0
            for match in targetText:gmatch("%S+") do
                currentIndex = currentIndex + 1
                if currentIndex == position then
                    if match ~= word then
                        keywordsMatch = false
                        break
                    end
                    break
                end
            end
            if not keywordsMatch then
                break
            end
        end
    end

    -- Проверяем условия
    if keywordsMatch then
        local allConditionsMet = true
        for _, condition in ipairs(conditions) do
            if type(condition) == "string" then
                condition = _G[condition]
            end
            if type(condition) == "function" then
                if not condition(text, sender, channel, prefix) then
                    allConditionsMet = false
                    break
                end
            else
                print("Ошибка: условие не является функцией или именем функции.")
                allConditionsMet = false
                break
            end
        end

        -- Вызываем функцию, если все условия выполнены
        if allConditionsMet then
            local func = _G[funcName]
            if func then
                func(event, text, sender, prefix, channel, channelName)
                if stopOnMatch then
                    return true
                end
            else
                print("Ошибка: функция '" .. funcName .. "' не найдена.")
            end
        end
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
    obj.staticData = _G[staticDataTable]  -- Статичные данные
    obj.dynamicData = _G[dynamicDataTable] or {}  -- Динамические данные (если не существуют, создаем пустую таблицу)
    obj.frame = nil
    obj.buttons = {}
    obj.tabCreated = false
    obj.nightWatchTab = nil
    obj.selectedButton = nil
    obj.customAlertFrame = nil

    -- Проверка корректности загрузки данных
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
    for category, achievements in pairs(self.staticData) do
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
                category = category  -- Добавляем категорию
            }
        end
    end
    return nil
end

-- Метод для создания вкладки "Ночная стража"
function CustomAchievements:CreateNightWatchTab()
    -- Проверяем, существуют ли вкладки
    if not AchievementFrameTab1 or not AchievementFrameTab2 then
        return  -- Если вкладки не существуют, выходим
    end

    -- Создаем третью вкладку с уникальным именем
    self.nightWatchTab = CreateFrame("Button", "AchievementFrameTab3", AchievementFrame, "AchievementFrameTabButtonTemplate")
    self.nightWatchTab:SetText("Ночная стража")

    -- Привязываем новую вкладку к вкладке "Статистика"
    self.nightWatchTab:SetPoint("LEFT", AchievementFrameTab2, "RIGHT", -6, 0)

    -- Убедимся, что текст вкладки инициализирован
    local fontString = self.nightWatchTab:GetFontString()
    if fontString then
        fontString:SetText("Ночная стража")
    else
        return  -- Если не удалось получить FontString, выходим
    end

    -- Автоматически подгоняем ширину вкладки под текст
    PanelTemplates_TabResize(self.nightWatchTab, 0)

    -- Обработчик клика для вкладки "Ночная стража"
    self.nightWatchTab:SetScript("OnClick", function()
        -- Скрываем стандартные разделы
        AchievementFrameSummary:Hide()
        AchievementFrameAchievements:Hide()
        AchievementFrameStats:Hide()

        -- Скрываем стандартные категории
        for i = 1, 20 do
            if _G['AchievementFrameCategoriesContainerButton' .. i] then
                _G['AchievementFrameCategoriesContainerButton' .. i]:Hide()
            end
        end

        -- Показываем наш кастомный фрейм
        self:Show()

        -- Обновляем интерфейс без категории (если не задана явно)
        self:UpdateUI(self.selectedCategory)

        -- Обновляем состояние вкладок
        PanelTemplates_SetTab(AchievementFrame, 3)
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
    if relativeTo then
        tex:SetPoint(point, relativeTo, relativePoint, x, y)
    else
        tex:SetPoint(point, x, y)
    end
    return tex
end

-- Синхронизация динамических данных с новой структурой
function CustomAchievements:SyncDynamicData()
    if not self:IsStructureChanged() then
        return
    end

    -- Создаем временную таблицу для старых данных по уникальному индексу
    local oldDataMap = {}

    -- Собираем старые данные по уникальному индексу
    for _, category in pairs(self.staticData) do
        for name, staticData in pairs(category) do
            local uniqueIndex = staticData.uniqueIndex
            if uniqueIndex and self.dynamicData[name] then
                oldDataMap[uniqueIndex] = self.dynamicData[name]
            end
        end
    end

    -- Создаем новую структуру на основе статической таблицы
    for categoryName, achievements in pairs(self.staticData) do
        for name, staticData in pairs(achievements) do
            local uniqueIndex = staticData.uniqueIndex
            if uniqueIndex then
                if oldDataMap[uniqueIndex] then
                    -- Переносим существующие данные в новый индекс
                    self.dynamicData[name] = oldDataMap[uniqueIndex]
                else
                    -- Создаем новую запись с дефолтными значениями
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

    -- Удаляем устаревшие записи из dynamicData
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

    -- Собираем соответствие индексов из статической таблицы
    for _, category in pairs(self.staticData) do
        for name, staticData in pairs(category) do
            if staticData.uniqueIndex then
                staticIndexByUnique[staticData.uniqueIndex] = name
            end
        end
    end

    -- Собираем соответствие индексов из динамической таблицы
    for name, dynamicData in pairs(self.dynamicData) do
        if dynamicData.uniqueIndex then
            dynamicIndexByUnique[dynamicData.uniqueIndex] = name
        end
    end

    -- Сравниваем соответствие индексов между статической и динамической таблицами
    for uniqueIndex, staticName in pairs(staticIndexByUnique) do
        local dynamicName = dynamicIndexByUnique[uniqueIndex]
        if dynamicName ~= staticName then
            return true
        end
    end

    -- Проверяем наличие уникальных индексов в динамической таблице, которых нет в статической
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

    -- Заголовок
    local title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 130, -10)

    -- Контейнер для кнопок категорий
    self:CreateCategoryButtons(self.frame)

    -- Скроллируемая область для ачивок
    self.achievementList = CreateFrame("ScrollFrame", "achievementScrollFrame", self.frame, "UIPanelScrollFrameTemplate")
    self.achievementList:SetSize(690, 450)
    self.achievementList:SetPoint("TOPLEFT", self.categoryContainer, "TOPRIGHT", -100, 0)

    -- Контейнер для элементов
    self.achievementContainer = CreateFrame("Frame", nil, self.achievementList)
    self.achievementContainer:SetSize(720, 450)
    self.achievementList:SetScrollChild(self.achievementContainer)

    -- Фон
    local background = CreateTexture(self.achievementContainer, "BACKGROUND", TEXTURE_BACKGROUND)
    background:SetAllPoints()
    background:SetVertexColor(1, 1, 1, 1)

    -- Скроллбар
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

    -- Создаем контейнер для кнопок категорий
    self.categoryContainer = CreateFrame("Frame", nil, parent)
    self.categoryContainer:SetSize(buttonWidth, #categories * buttonHeight + 10)
    self.categoryContainer:SetPoint("TOPLEFT", parent, "TOPLEFT", 70, -30)

    -- Создаем кнопки для каждой категории
    for _, category in ipairs(categories) do
        local button = CreateFrame("Button", nil, self.categoryContainer)
        button:SetSize(buttonWidth + 80, buttonHeight)
        button:SetPoint("TOPLEFT", self.categoryContainer, "TOPLEFT", 0, -yOffset)

        -- Текстура фона кнопки
        local normalTexture = button:CreateTexture(nil, "BACKGROUND")
        normalTexture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Category-Background")
        normalTexture:SetPoint("CENTER", button, "CENTER")
        normalTexture:SetSize(200, 35)

        -- Устанавливаем координаты текстуры (выбираем нужный участок)
        normalTexture:SetTexCoord(0, 0.6640625, 0, 1)  -- Пример: используем верхнюю половину текстуры

        -- Текст кнопки
        local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        buttonText:SetPoint("CENTER", button, "CENTER", 0, 3)
        buttonText:SetText(category)

        -- Подсветка при наведении
        local highlightTexture = button:CreateTexture(nil, "HIGHLIGHT")
        highlightTexture:SetAllPoints()
        highlightTexture:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
        highlightTexture:SetBlendMode("ADD")
        -- Устанавливаем координаты текстуры (выбираем нужный участок)
        highlightTexture:SetTexCoord(0, 1, 0, 0.5)  -- Пример: используем верхнюю половину текстуры

        -- Обработчик клика
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

    -- Устанавливаем выбранную категорию
    self.selectedCategory = category

    -- Обновляем интерфейс с выбранной категорией
    self:UpdateUI(category)
end

-- Метод для добавления ачивки
function CustomAchievements:AddAchievement(name)
    -- Проверяем существование статичных данных
    if not self.staticData[name] then
        print("Ошибка: ачивка с ID " .. name .. " не найдена в статичных данных")
        return
    end

    -- Если уже есть динамические данные - выходим
    if self.dynamicData[name] then return end

    -- Получаем текущую дату и время
    local currentDate = date("%d/%m/%Y %H:%M")

    -- Создаем запись в динамических данных
    self.dynamicData[name] = {
        uniqueIndex = self.staticData[name].uniqueIndex,
        dateEarned = currentDate,
        dateCompleted = "Не выполнена",
        progress = 0,
        isExpanded = false,
        scrollPosition = 0
    }

    -- Обновляем интерфейс с учетом выбранной категории
    self:UpdateUI(self.selectedCategory)
    self:ShowAchievementAlert(name)
end

-- Метод для обновления интерфейса с учетом выбранной категории
function CustomAchievements:UpdateUI(selectedCategory)
    self:SyncDynamicData()  -- Синхронизируем динамические данные перед обновлением интерфейса
    if not self.achievementContainer then return end

    -- Очищаем предыдущие элементы
    for _, child in ipairs({self.achievementContainer:GetChildren()}) do
        child:Hide()
        child:ClearAllPoints()
        child:SetParent(nil)
    end

    self.buttons = {}
    local yOffset = 0  -- Инициализируем yOffset

    -- Создаем временную таблицу для сортировки ачивок по индексу
    local sortedAchievements = {}

    -- Собираем ачивки в зависимости от выбранной категории
    for category, achievements in pairs(self.staticData) do
        if not selectedCategory or category == selectedCategory then
            for name, staticData in pairs(achievements) do
                table.insert(sortedAchievements, {name = name, index = staticData.index or 0})
            end
        end
    end

    -- Сортируем ачивки по индексу
    table.sort(sortedAchievements, function(a, b)
        return a.index < b.index
    end)

    -- Отображаем ачивки в отсортированном порядке
    for _, achievement in ipairs(sortedAchievements) do
        local name = achievement.name
        local dynamicData = self.dynamicData[name] or {}
        local button = self.buttons[name] or self:CreateAchievementButton(name, yOffset)
        if button then
            self.buttons[name] = button
            yOffset = yOffset + button:GetHeight()
        end
    end

    -- Обновляем скроллируемую область
    self:UpdateScrollArea(yOffset)
end

-- Метод для обновления скроллируемой области
function CustomAchievements:UpdateScrollArea(totalHeight)
    local scrollBar = self.achievementList.scrollBar
    local containerHeight = totalHeight + 60

    -- Обновляем высоту контейнера
    self.achievementContainer:SetHeight(containerHeight)

    -- Обновляем скроллбар
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
    local achievement = self:GetAchievementFullData(name)  -- Используем GetAchievementFullData
    if not achievement then return nil end

    -- Создаем кнопку
    local button = CreateFrame("Button", nil, self.achievementContainer)
    button:SetSize(510, COLLAPSED_HEIGHT)
    button:SetPoint("TOPLEFT", self.achievementContainer, "TOPLEFT", 195, -yOffset)
    button.id = name

    -- Иконка ачивки
    button.icon = CreateTextureElement(button, "ARTWORK", achievement.texture, DEFAULT_ICON_SIZE, DEFAULT_ICON_SIZE, "TOPLEFT", button, "TOPLEFT", self.COLLAPSED_POSITIONS.icon.x, self.COLLAPSED_POSITIONS.icon.y)

    -- Название ачивки
    button.nameText = CreateTextElement(button, "GameFontHighlight", "LEFT", "TOPLEFT", button.icon, "TOPRIGHT", 5, 0)
    button.nameText:SetText(achievement.name)

    -- Дата получения
    button.dateText = CreateTextElement(button, "GameFontNormal", "LEFT", "TOPLEFT", button, "TOPLEFT", self.COLLAPSED_POSITIONS.date.x, self.COLLAPSED_POSITIONS.date.y)
    button.dateText:SetText(achievement.dateEarned)

    -- Иконка очков награды
    button.rewardPointsIcon = CreateTextureElement(button, "ARTWORK", TEXTURE_SHIELD, REWARD_ICON_SIZE, REWARD_ICON_SIZE, "TOPLEFT", button, "TOPLEFT", self.COLLAPSED_POSITIONS.rewardPoints.x, self.COLLAPSED_POSITIONS.rewardPoints.y)

    -- Состояние щита в зависимости от выполнения ачивки
    if achievement.dateCompleted ~= "Не выполнена" then
        button.rewardPointsIcon:SetTexCoord(0, 0.5, 0, 1)  -- Зеленый щит
    else
        button.rewardPointsIcon:SetTexCoord(0.5, 1, 0, 1)  -- Серый щит
    end

    -- Текст очков награды
    button.rewardPointsText = CreateTextElement(button, "GameFontNormal", "CENTER", "CENTER", button.rewardPointsIcon, "CENTER", 0, 0)
    button.rewardPointsText:SetText(achievement.rewardPoints)

    -- Подсветка при наведении
    button.highlight = CreateTextureElement(button, "BACKGROUND", TEXTURE_HIGHLIGHT, 510, COLLAPSED_HEIGHT, "TOPLEFT", button, "TOPLEFT", 0, 0)
    button.highlight:SetAlpha(0)

    -- Фон в зависимости от статуса
    button.normal = CreateTextureElement(button, "BACKGROUND", achievement.dateCompleted ~= "Не выполнена" and TEXTURE_COMPLETE or TEXTURE_INCOMPLETE, 510, COLLAPSED_HEIGHT, "TOPLEFT", button, "TOPLEFT", 0, 0)
    button.normal:SetAlpha(1)

    -- Обработчики событий
    button:RegisterForClicks("RightButtonDown", "LeftButtonDown")
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            -- Переключаем состояние разворачивания/сворачивания
            self.dynamicData[name].isExpanded = not self.dynamicData[name].isExpanded
            local scrollBarValue = self.achievementList.scrollBar:GetValue()
            self:UpdateUI(self.selectedCategory)
            self.achievementList.scrollBar:SetValue(scrollBarValue)
        elseif mouseButton == "RightButton" then
            self:SendAchievementCompletionMessage(name)
        end
    end)

    -- Обработчик события OnEnter (при наведении мыши)
    button:SetScript("OnEnter", function()
        button.highlight:SetAlpha(1)  -- Показываем подсветку
        self:ShowAchievementTooltip(button, name)  -- Показываем тултип
    end)

    -- Обработчик события OnLeave (при убирании мыши)
    button:SetScript("OnLeave", function()
        button.highlight:SetAlpha(0)  -- Скрываем подсветку
        GameTooltip:Hide()  -- Скрываем тултип
    end)

    -- Если ачивка уже развернута, вызываем метод раскрытия
    if achievement.isExpanded then
        self:ExpandAchievement(button, name)
    end

    return button
end

-- Метод для показа тултипа
function CustomAchievements:ShowAchievementTooltip(button, name)
    local data = self:GetAchievementFullData(name)  -- Используем GetAchievementFullData
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
    local achievement = self:GetAchievementFullData(name)  -- Используем GetAchievementFullData
    if not achievement then return end

    -- Создаем descriptionText, если он не существует
    if not button.descriptionText then
        button.descriptionText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        button.descriptionText:SetWidth(400)
        button.descriptionText:SetWordWrap(true)
        button.descriptionText:SetText(achievement.description)
        button.descriptionText:SetJustifyH("LEFT")
        button.descriptionText:Hide() -- Скрываем по умолчанию
    end

    -- Позиционирование элементов
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.icon.x, self.EXPANDED_POSITIONS.icon.y)
    button.nameText:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.name.x, self.EXPANDED_POSITIONS.name.y)
    button.dateText:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.date.x, self.EXPANDED_POSITIONS.date.y)
    button.rewardPointsIcon:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.rewardPoints.x, self.EXPANDED_POSITIONS.rewardPoints.y)

    -- Показываем описание
    button.descriptionText:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.description.x, self.EXPANDED_POSITIONS.description.y)
    button.descriptionText:Show()

    -- Рассчитываем высоту описания
    local descriptionHeight = button.descriptionText:GetHeight()

    -- Вложенные достижения
    local requiredYOffset = -80
    local iconSize = 30
    local iconSpacing = 5
    for i, reqId in ipairs(achievement.subAchievements) do
        local reqAchievement = self:GetAchievementFullData(reqId)  -- Используем GetAchievementFullData
        if reqAchievement then
            self:CreateNestedAchievementIcon(button, reqAchievement, i, self.EXPANDED_POSITIONS.requiredAchievements.x, requiredYOffset, iconSize, iconSpacing)
        end
    end

    -- Высота кнопки
    local numRows = math.ceil(#achievement.subAchievements / MAX_ICONS_PER_ROW)
    local totalHeight = EXPANDED_BASE_HEIGHT + descriptionHeight + numRows * (iconSize + iconSpacing)
    button:SetHeight(totalHeight - 30)  -- Корректируем высоту

    -- Обновляем размеры текстур
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
    -- Проверяем выполнение ачивки
    if achievement.dateCompleted ~= "Не выполнена" then
        icon:SetDesaturated(false)  -- Цветная иконка
    else
        icon:SetDesaturated(true)   -- Серая иконка
    end
    -- Обработчики событий
    button:SetScript("OnMouseDown", function()
        self:NavigateToAchievement(achievement.id)  -- Передаем ID ачивки
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
    -- Сбрасываем состояние всех ачивок
    for _, dynamic in pairs(self.dynamicData) do
        dynamic.isExpanded = false
    end
    -- Устанавливаем состояние текущей ачивки как развернутой
    local dynamic = self.dynamicData[id]
    if dynamic then
        dynamic.isExpanded = true
    end
    -- Обновляем интерфейс
    self:UpdateUI()
    -- Прокручиваем к нужной ачивке
    local scrollBar = self.achievementList.scrollBar
    local scrollPosition = dynamic and dynamic.scrollPosition or 0
    scrollBar:SetValue(scrollPosition)
end

-- Метод для скрытия ачивок
function CustomAchievements:HideAchievements()
    if self.frame then
        self.frame:Hide()  -- Скрываем фрейм
    end
    for _, button in pairs(self.buttons) do
        button:Hide()  -- Скрываем все кнопки ачивок
    end
end

-- Метод для отображения ачивок
function CustomAchievements:ShowAchievements()
    for _, button in pairs(self.buttons) do
        button:Show()  -- Показываем все кнопки ачивок
    end
end

-- Метод для отображения фрейма
function CustomAchievements:Show()
    if self.frame then
        self.frame:Show()
        self:UpdateUI(self.selectedCategory)  -- Обновляем UI с текущей категорией
        self:ShowAchievements()  -- Показываем ачивки, если фрейм видим
    end
end

-- Метод для скрытия фрейма
function CustomAchievements:Hide()
    if self.frame then
        self.frame:Hide()
        self.selectedCategory = nil -- Сбрасываем выбранную категорию при закрытии окна
        self:UpdateUI()  -- Обновляем UI без категории
    end
end

-- Метод для создания кастомного фрейма уведомлений
function CustomAchievements:CreateCustomAlertFrame()
    local alertFrame = CreateFrame("Frame", "CustomAchievementAlertFrame", UIParent)
    alertFrame:SetFrameStrata("DIALOG")  -- Высокий слой
    alertFrame:SetFrameLevel(100)  -- Высокий уровень
    alertFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    alertFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    alertFrame:SetBackdropColor(0, 0, 0, 0.8)
    alertFrame:SetAlpha(1)  -- Начальная прозрачность
    -- Иконка ачивки
    alertFrame.Icon = alertFrame:CreateTexture(nil, "ARTWORK")
    alertFrame.Icon:SetSize(40, 40)
    alertFrame.Icon:SetPoint("TOPLEFT", alertFrame, "TOPLEFT", 10, -10)
    alertFrame.Icon:SetTexture("Interface\\Icons\\Ability_Rogue_ShadowStrikes")
    -- Текст названия ачивки
    alertFrame.Name = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    alertFrame.Name:SetPoint("TOPLEFT", alertFrame.Icon, "TOPRIGHT", 10, 0)
    alertFrame.Name:SetJustifyH("LEFT")
    alertFrame.Name:SetText("Название ачивки")
    -- Текст описания ачивки
    alertFrame.Description = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    alertFrame.Description:SetPoint("TOPLEFT", alertFrame.Name, "BOTTOMLEFT", 0, -5)
    alertFrame.Description:SetJustifyH("LEFT")
    alertFrame.Description:SetText("Описание ачивки")
    -- Функция для обновления размера фрейма
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
    -- Проверяем наличие ачивки в статической таблице
    for _, category in pairs(self.staticData) do
        if category[name] then
            -- Возвращаем динамическую таблицу, если она существует
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
                category = staticData.category,  -- Возвращаем категорию, в которой находится ачивка
                send_txt = staticData.send_txt,
                subAchievements_args = staticData.subAchievements_args,
                achievement_args = staticData.achievement_args,
                achFunc = staticData.achFunc
            }
        end
    end
    return nil  -- Если ачивка не найдена
end

-- Метод для отображения уведомления о новой ачивке
function CustomAchievements:ShowAchievementAlert(achievementName)
    -- Получаем данные ачивки по её имени
    local achievement = self:GetAchievementFullData(achievementName)
    if not achievement then
        print("Ачивка с именем " .. achievementName .. " не найдена.")
        return
    end

    -- Создаем или используем кастомный фрейм
    if not self.customAlertFrame then
        self.customAlertFrame = self:CreateCustomAlertFrame()
    end

    -- Устанавливаем данные ачивки
    self.customAlertFrame.Name:SetText(achievement.name)
    self.customAlertFrame.Description:SetText(achievement.description)
    self.customAlertFrame.Icon:SetTexture(achievement.texture)
    self.customAlertFrame:UpdateSize()
    self.customAlertFrame:SetAlpha(1)
    self.customAlertFrame:Show()

    -- Устанавливаем таймер для скрытия фрейма
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
    -- Проверяем наличие ачивки в статической таблице
    for _, category in pairs(self.staticData) do
        if category[name] then
            -- Проверяем наличие ачивки в динамической таблице
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
    -- Проверяем, существует ли ачивка в динамической таблице
    if not self.dynamicData[name] then
        print("Ошибка: ачивка с именем " .. name .. " не найдена в динамической таблице.")
        return
    end

    -- Список допустимых ключей для изменения
    local allowedKeys = {
        dateEarned = true,
        dateCompleted = true,
        progress = true,
        isExpanded = true,
        scrollPosition = true
    }

    -- Проверяем, является ли ключ допустимым
    if not allowedKeys[key] then
        print("Ошибка: ключ " .. key .. " недопустим для изменения.")
        return
    end

    -- Изменяем значение параметра
    self.dynamicData[name][key] = value

    -- Обновляем интерфейс, если ачивка видима
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
        local tempWidth = self:getStringWidth(temp, font)
        
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
function NSQCMenu:getStringWidth(text, font)
    local temp = self.mainFrame:CreateFontString(nil, "ARTWORK", font)
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
    slider:SetWidth(200)
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
    local scrollBar

    -- Retrieve the scrollbar as a child of the scrollFrame
    for i = 1, scrollFrame:GetNumChildren() do
        local child = select(i, scrollFrame:GetChildren())
        if child and child:IsObjectType("Slider") then
            scrollBar = child
            break
        end
    end

    if not scrollBar then
        error("Scrollbar not found for scrollFrame: " .. parentMenu.scrollFrame:GetName())
    end

    local maxRange = parentMenu.totalHeight - parentMenu.maxHeight
    if maxRange < 0 then maxRange = 0 end

    scrollBar:SetMinMaxValues(0, maxRange)
    scrollBar:SetValue(0)
    scrollFrame:UpdateScrollChildRect()
end
