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
    if dop_key then
        if self.input_table[dop_key] then
            if id then
                return self.input_table[dop_key][change_key][id]
            else
                return self.input_table[dop_key][change_key]
            end
        end
    else
        if self.input_table[change_key] then
            if id then
                return self.input_table[change_key][id]
            else
                return self.input_table[change_key]
            end
        end
    end
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
function ButtonManager:new(name, parent, width, height, text, texture, parentFrame)
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
    if parentFrame then
        button:SetMovable(parentFrame)
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

-- Метод для изменения размера кнопки
function ButtonManager:SetSize(width, height)
    if self.frame then
        self.frame:SetSize(width, height)
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

-- Определяем класс AdaptiveFrame
AdaptiveFrame = {}
AdaptiveFrame.__index = AdaptiveFrame

-- Функция для проверки размеров кнопок и корректировки размеров фрейма
local function CheckButtonSizes(frame)
    local frameWidth, frameHeight = frame:GetSize()
    local numColumns = 10
    local numRows = math.ceil(#frame.children / numColumns)
    local buttonWidth = frameWidth / numColumns
    local buttonHeight = frameHeight / numRows

    -- Проверяем размер текста на каждой кнопке
    for _, buttonData in ipairs(frame.children) do
        if buttonData and buttonData.child then
            local fontString = buttonData.child:GetFontString()
            if fontString then
                local textWidth = fontString:GetStringWidth()
                local textHeight = fontString:GetStringHeight()

                -- Если текст не влезает, увеличиваем размер кнопки
                if textWidth > buttonWidth or textHeight > buttonHeight then
                    buttonWidth = math.max(buttonWidth, textWidth + 10)  -- Добавляем отступ
                    buttonHeight = math.max(buttonHeight, textHeight + 10)
                end
            end
        end
    end

    -- Возвращаем новые размеры фрейма на основе размеров кнопок
    return buttonWidth * numColumns, buttonHeight * numRows
end

-- Функция для проверки и корректировки размеров фрейма
local function CheckFrameSize(frame, newWidth, newHeight)
    -- Проверяем минимальный размер фрейма на основе размеров кнопок
    local minWidth, minHeight = CheckButtonSizes(frame)
    local widthWithMin = math.max(newWidth, minWidth)  -- Ограничиваем снизу
    local heightWithMin = math.max(newHeight, minHeight)

    -- Проверяем максимальный размер фрейма, чтобы он не выходил за пределы экрана
    local worldWidth = WorldFrame:GetWidth()
    local worldHeight = WorldFrame:GetHeight()
    local maxWidth = worldWidth - 200
    local maxHeight = worldHeight - 200
    local finalWidth = math.min(widthWithMin, maxWidth)  -- Ограничиваем сверху
    local finalHeight = math.min(heightWithMin, maxHeight)

    return finalWidth, finalHeight
end

-- Конструктор для создания нового объекта AdaptiveFrame
function AdaptiveFrame:Create(parent, initialWidth, initialHeight)
    initialWidth = initialWidth or 512
    initialHeight = initialHeight or 512

    -- Создаем фрейм
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(initialWidth, initialHeight)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.0)
    frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 0)
    -- Сохраняем начальное соотношение сторон
    frame.initialAspectRatio = initialWidth / initialHeight
    frame:SetResizable(true)
    frame.children = {}

    -- Добавляем методы к фрейму
    frame.AddChild = AdaptiveFrame.AddChild
    frame.UpdateSize = AdaptiveFrame.UpdateSize
    frame.AddGrid = AdaptiveFrame.AddGrid
    frame.ResizeButtons = AdaptiveFrame.ResizeButtons

    -- Включаем возможность перемещения фрейма
    frame:SetMovable(true)
    

    -- Создаем ручку для изменения размера фрейма
    local resizeHandle = CreateFrame("Button", nil, frame)
    resizeHandle:SetSize(16, 16)
    resizeHandle:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeHandle:SetScript("OnMouseDown", function(self)
        frame:StartSizing("BOTTOMRIGHT")
    end)
    resizeHandle:SetScript("OnMouseUp", function(self)
        frame:StopMovingOrSizing()
        frame:ResizeButtons()
    end)

    -- Обработчик изменения размера фрейма
    frame:SetScript("OnSizeChanged", function(self, width, height)
        -- Проверяем размеры фрейма
        width, height = CheckFrameSize(self, width, height)

        -- Сохраняем пропорции сторон
        local newAspectRatio = width / height
        if newAspectRatio ~= self.initialAspectRatio then
            if newAspectRatio > self.initialAspectRatio then
                height = width / self.initialAspectRatio
            else
                width = height * self.initialAspectRatio
            end
            self:SetSize(width, height)
        end

        -- Обновляем размеры и позиции кнопок
        self:ResizeButtons()
    end)

    -- Создаем кнопку закрытия фрейма
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetSize(32, 32)
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 25, 25)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    return frame
end

function AdaptiveFrame:new()
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


-- Метод для изменения размера кнопок в зависимости от размера фрейма
function AdaptiveFrame:ResizeButtons()
    local frameWidth, frameHeight = self:GetSize()
    local numColumns = 10
    local numRows = math.ceil(#self.children / numColumns)
    local buttonWidth = frameWidth / numColumns
    local buttonHeight = frameHeight / numRows

    -- Обновляем размеры и позиции всех кнопок
    for i, buttonData in ipairs(self.children) do
        if buttonData and buttonData.child then
            buttonData.child:SetSize(buttonWidth, buttonHeight)
            local column = (i - 1) % numColumns
            local row = math.floor((i - 1) / numColumns)
            local xOffset = column * buttonWidth
            local yOffset = row * buttonHeight
            buttonData.child:ClearAllPoints()
            buttonData.child:SetPoint("TOPLEFT", self, "TOPLEFT", xOffset, -yOffset)
        end
    end
end

-- Метод для добавления элементов в сетку (grid)
function AdaptiveFrame:AddGrid(buttons, num, columns, spacing)
    spacing = spacing or 10
    local xOffset = 10
    local yOffset = 10
    local currentColumn = 1

    -- Добавляем кнопки в сетку
    for i = 1, num do
        local button = buttons[i]
        if button and button.frame then
            -- Добавляем кнопку в список дочерних элементов
            table.insert(self.children, {child = button.frame, xOffset = xOffset, yOffset = yOffset})

            -- Устанавливаем родителя для кнопки
            button.frame:SetParent(self)
            button.frame:ClearAllPoints()
            button.frame:SetPoint("TOPLEFT", self, "TOPLEFT", xOffset, -yOffset)

            -- Добавляем обработчики событий для перемещения фрейма
            button.frame:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" then
                    self:GetParent():StartMoving()
                else
                    -- Изменение прозрачности правой кнопкой мыши
                    local frame = self:GetParent()
                    local startX = GetCursorPosition()
                    local startAlpha = frame:GetAlpha()

                    -- Обработчик перемещения мыши для изменения прозрачности
                    frame:SetScript("OnUpdate", function(self)
                        local currentX = GetCursorPosition()
                        local deltaX = currentX - startX
                        local newAlpha = startAlpha + (deltaX / 500)  -- Меняем прозрачность на основе смещения мыши

                        -- Ограничиваем прозрачность в пределах от 0.1 до 1.0
                        newAlpha = math.max(0.1, math.min(1.0, newAlpha))

                        -- Устанавливаем новую прозрачность для всех дочерних элементов
                        self:SetAlpha(newAlpha)
                        for _, childData in ipairs(self.children) do
                            if childData and childData.child then
                                childData.child:SetAlpha(newAlpha)
                            end
                        end
                    end)
                end
            end)

            button.frame:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" then
                    local parentFrame = self:GetParent()
                    parentFrame:StopMovingOrSizing()

                    -- Ограничиваем позицию фрейма в пределах экрана
                    local screenWidth = UIParent:GetWidth()
                    local screenHeight = UIParent:GetHeight()
                    local frameWidth = parentFrame:GetWidth()
                    local frameHeight = parentFrame:GetHeight()
                    local x, y = parentFrame:GetCenter()

                    if x < frameWidth / 2 then
                        x = frameWidth / 2
                    elseif x > screenWidth - frameWidth / 2 then
                        x = screenWidth - frameWidth / 2
                    end

                    if y < frameHeight / 2 then
                        y = frameHeight / 2
                    elseif y > screenHeight - frameHeight / 2 then
                        y = screenHeight - frameHeight / 2
                    end

                    parentFrame:ClearAllPoints()
                    parentFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
                else
                    -- Отмена изменения прозрачности при отпускании правой кнопки мыши
                    local parentFrame = self:GetParent()
                    parentFrame:SetScript("OnUpdate", nil)  -- Убираем обработчик изменения прозрачности
                end
            end)

            -- Обновляем смещение для следующей кнопки
            if currentColumn < columns then
                xOffset = xOffset + button.frame:GetWidth() + spacing
                currentColumn = currentColumn + 1
            else
                xOffset = 10
                yOffset = yOffset + button.frame:GetHeight() + spacing
                currentColumn = 1
            end
        else
            print("Ошибка: кнопка или её frame не существует для индекса " .. i)
        end
    end
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
-- @param event: Тип события (например, "CHAT_MSG_SAY")
-- @param ...: Параметры события (текст, отправитель и т.д.)
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

    -- Разбиваем сообщение на слова
    local msg = {}
    local kodmsg = {}

    if event == "CHAT_MSG_ADDON" then
        -- Для событий ADDON разбиваем prefix и message
        if prefix then
            kodmsg = mysplit(prefix)
        else
            kodmsg = {}  -- Если prefix равен nil, используем пустую таблицу
        end
        msg = mysplit(text)
    else
        -- Для обычных сообщений чата разбиваем только text
        msg = mysplit(text)
    end

    -- Проверяем триггеры для ключа "*" (любое сообщение)
    if self.triggersByAddress["*"] then
        for _, trigger in ipairs(self.triggersByAddress["*"]) do
            if self:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event) then
                if trigger.stopOnMatch then
                    return  -- Прерываем дальнейшую обработку, если stopOnMatch = true
                end
            end
        end
    end
    -- Проверяем триггеры для ключа "*" (любое сообщение)
    if self.triggersByAddress["&"] then
        for _, trigger in ipairs(self.triggersByAddress["&"]) do
            if self:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event) then
                if trigger.stopOnMatch then
                    return  -- Прерываем дальнейшую обработку, если stopOnMatch = true
                end
            end
        end
    end
    -- Проверяем триггеры для ключа "*" (любое сообщение)
    if self.triggersByAddress["^"] then
        for _, trigger in ipairs(self.triggersByAddress["^"]) do
            if self:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event) then
                if trigger.stopOnMatch then
                    return  -- Прерываем дальнейшую обработку, если stopOnMatch = true
                end
            end
        end
    end

    -- Определяем адрес (первое слово сообщения или префикса)
    local addressPrefix = (event == "CHAT_MSG_ADDON" and "prefix:" .. (kodmsg[1] or "")) or nil
    local addressMessage = "message:" .. (msg[1] or "")

    -- Проверяем триггеры для префикса (если это ADDON-сообщение)
    if addressPrefix and self.triggersByAddress[addressPrefix] then
        for _, trigger in ipairs(self.triggersByAddress[addressPrefix]) do
            if self:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event) then
                return  -- Прерываем дальнейшую обработку, если триггер выполнен
            end
        end
    end

    -- Проверяем триггеры для сообщения
    if self.triggersByAddress[addressMessage] then
        for _, trigger in ipairs(self.triggersByAddress[addressMessage]) do
            if self:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event) then
                return  -- Прерываем дальнейшую обработку, если триггер выполнен
            end
        end
    end
end

-- Метод для проверки триггера
-- @param trigger: Триггер, который нужно проверить
-- @param msg: Таблица слов из сообщения
-- @param kodmsg: Таблица слов из префикса (для ADDON-сообщений)
-- @param text: Полный текст сообщения
-- @param sender: Имя отправителя
-- @param channel: Канал сообщения
-- @param prefix: Префикс сообщения (для ADDON-сообщений)
-- @return: true, если дальнейшая обработка должна быть прервана, иначе false
function ChatHandler:CheckTrigger(trigger, msg, kodmsg, text, sender, channel, prefix, event)
    local keywords = trigger.keyword or {}  -- Если keyword отсутствует, используем пустую таблицу
    local funcName = trigger.func
    local conditions = trigger.conditions or {}
    local stopOnMatch = trigger.stopOnMatch or false
    local forbiddenWords = trigger.forbiddenWords or {}
    local chatType = trigger.chatType  -- Тип чата, указанный в триггере

    -- Проверяем, соответствует ли тип чата
    if chatType then
        -- Преобразуем событие в тип чата (например, "CHAT_MSG_SAY" -> "SAY")
        local currentChatType = string.match(event, "CHAT_MSG_(.+)")
        if currentChatType ~= chatType then
            return false  -- Тип чата не совпадает, триггер не срабатывает
        end
    end

    -- Собираем все запрещенные слова, включая те, что указаны в переменных
    local allForbiddenWords = {}
    for _, wordOrVar in ipairs(forbiddenWords) do
        if type(wordOrVar) == "string" and wordOrVar:sub(1, 1) == "$" then
            -- Это переменная, извлекаем её значение
            local varName = wordOrVar:sub(2)  -- Убираем "$"
            local varValue = _G[varName]  -- Получаем значение переменной из глобальной таблицы
            if type(varValue) == "table" then
                -- Если переменная содержит таблицу, добавляем все её элементы
                for _, forbiddenWord in ipairs(varValue) do
                    table.insert(allForbiddenWords, forbiddenWord)
                end
            elseif type(varValue) == "string" then
                -- Если переменная содержит строку, добавляем её как одно слово
                table.insert(allForbiddenWords, varValue)
            end
        else
            -- Это обычное слово, добавляем его
            table.insert(allForbiddenWords, wordOrVar)
        end
    end

    -- Проверяем, есть ли в сообщении запрещенные слова
    for _, forbiddenWord in ipairs(allForbiddenWords) do
        if string.find(text:lower(), forbiddenWord:lower()) then
            return false  -- Если найдено запрещенное слово, триггер не срабатывает
        end
    end

    -- Проверяем ключевые слова (если они есть)
    local keywordsMatch = true
    if #keywords > 0 then  -- Проверяем, только если keywords не пуст
        for _, keywordData in ipairs(keywords) do
            local word = keywordData.word
            local position = keywordData.position
            local source = keywordData.source
            local words = (source == "prefix") and kodmsg or msg

            if not (words[position] and words[position] == word) then
                keywordsMatch = false
                break
            end
        end
    end

    -- Если ключевые слова совпали (или их нет), проверяем условия
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

        -- Если все условия выполнены, вызываем функцию
        if allConditionsMet then
            local func = _G[funcName]
            if func then
                func(text, sender, channel, prefix)
                if stopOnMatch then
                    return true  -- Прерываем дальнейшую обработку
                end
            else
                print("Ошибка: функция '" .. funcName .. "' не найдена.")
            end
        end
    end

    return false  -- Продолжаем обработку
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

function CustomAchievements:SyncDynamicData()
    if not self:IsStructureChanged() then
        return
    end
    local oldDataMap = {} -- [uniqueIndex] = data
    -- Собираем старые данные по уникальным индексам
    for oldId, data in pairs(self.dynamicData) do
        if data.uniqueIndex then
            oldDataMap[data.uniqueIndex] = data
        end
    end
    -- Строим новую структуру на основе статической
    for newId, staticData in pairs(self.staticData) do
        local uniqueIndex = staticData.uniqueIndex
        if oldDataMap[uniqueIndex] then
            -- Переносим существующие данные в новый индекс
            self.dynamicData[newId] = oldDataMap[uniqueIndex]
        else
            -- Создаем новую запись с дефолтными значениями
            self.dynamicData[newId] = {
                uniqueIndex = uniqueIndex,
                dateEarned = "Не получена",
                dateCompleted = "Не выполнена",
                progress = 0,
                isExpanded = false,
                scrollPosition = 0
            }
        end
    end
    -- Удаляем устаревшие записи из dynamicData
    local idsToRemove = {}
    for id, data in pairs(self.dynamicData) do
        if not self.staticData[id] then
            table.insert(idsToRemove, id)
        end
    end
    for _, id in ipairs(idsToRemove) do
        self.dynamicData[id] = nil
    end
end

-- Конструктор
function CustomAchievements:new(staticDataTable, dynamicDataTable)
    local obj = setmetatable({}, self)
    print(_G[dynamicDataTable], '999')
    obj.staticData = _G[staticDataTable]  -- Статичные данные
    obj.dynamicData = _G[dynamicDataTable]  -- Динамические данные
    obj.frame = nil
    obj.buttons = {}
    obj.tabCreated = falsed
    obj.nightWatchTab = nil
    obj.selectedButton = nil
    obj.customAlertFrame = nil
    print(obj.dynamicData, '111111111111111111111111')
    return obj
end

-- Проверка изменения структуры данных
function CustomAchievements:IsStructureChanged()
    -- Создаем таблицы для отслеживания соответствия индексов по уникальному индексу
    local staticIndexByUnique = {}
    local dynamicIndexByUnique = {}
    -- Собираем соответствие индексов из статической таблицы
    for id, staticData in pairs(self.staticData) do
        if staticData.uniqueIndex then
            staticIndexByUnique[staticData.uniqueIndex] = id
        end
    end
    -- Собираем соответствие индексов из динамической таблицы
    for id, dynamicData in pairs(self.dynamicData) do
        if dynamicData.uniqueIndex then
            dynamicIndexByUnique[dynamicData.uniqueIndex] = id
        end
    end
    -- Сравниваем соответствие индексов между статической и динамической таблицами
    for uniqueIndex, staticId in pairs(staticIndexByUnique) do
        local dynamicId = dynamicIndexByUnique[uniqueIndex]
        if dynamicId ~= staticId then
            -- Если индексы не совпадают, значит структура изменена
            return true
        end
    end
    -- Проверяем наличие уникальных индексов в динамической таблице, которых нет в статической
    for uniqueIndex in pairs(dynamicIndexByUnique) do
        if not staticIndexByUnique[uniqueIndex] then
            return true
        end
    end
    -- Если все проверки пройдены, структура не изменилась
    return false
end

-- Метод для поиска ID ачивки по уникальному индексу
function CustomAchievements:FindAchievementIdByUniqueIndex(uniqueIndex)
    for id, data in pairs(self.dynamicData) do
        if data.uniqueIndex == uniqueIndex then
            return id
        end
    end
    return nil
end

-- Метод для поиска ID ачивки по имени
function CustomAchievements:FindAchievementIdByName(name)
    for id, data in pairs(self.staticData) do
        if data.name == name then
            return id
        end
    end
    return nil
end

-- Создание основного фрейма
function CustomAchievements:CreateFrame(parent)
    self.frame = CreateFrame("Frame", nil, parent)
    self.frame:SetSize(400, 500)
    self.frame:SetPoint("CENTER")
    self.frame:Hide()
    -- Заголовок
    local title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 0, -10)
    -- Скроллируемая область
    self.achievementList = CreateFrame("ScrollFrame", nil, self.frame)
    self.achievementList:SetSize(720, 450)
    self.achievementList:SetPoint("TOP", title, "BOTTOM", 0, -10)
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

-- Метод для добавления ачивки
function CustomAchievements:AddAchievement(id)
    -- Проверяем существование статичных данных
    if not self.staticData[id] then
        print("Ошибка: ачивка с ID " .. id .. " не найдена в статичных данных")
        return
    end
    -- Если уже есть динамические данные - выходим
    if self.dynamicData[id] then return end
    -- Получаем текущую дату и время
    local currentDate = date("%d/%m/%Y %H:%M")  -- Используем функцию date из библиотеки date
    -- Создаем запись в динамических данных
    print(self.dynamicData, '111')
    self.dynamicData[id] = {
        uniqueIndex = self.staticData[id].uniqueIndex,  -- Сохраняем уникальный индекс из статической таблицы
        dateEarned = currentDate,  -- Устанавливаем текущую дату
        dateCompleted = "Не выполнена",
        progress = 0,
        isExpanded = false,
        scrollPosition = 0
    }
    print(self.dynamicData, '222')
    self:UpdateUI()
    self:ShowAchievementAlert(id)
end

-- Метод для обновления интерфейса
function CustomAchievements:UpdateUI()
    self:SyncDynamicData()  -- Синхронизируем динамические данные перед обновлением интерфейса
    if not self.achievementContainer then return end
    -- Очистка предыдущих элементов
    for _, child in ipairs({self.achievementContainer:GetChildren()}) do
        child:Hide()
        child:ClearAllPoints()
        child:SetParent(nil)
    end
    self.buttons = {}
    local yOffset = 0
    -- Используем dynamicData вместо achievements
    for id, dynamicData in pairs(self.dynamicData) do
        local staticData = self.staticData[id]
        if staticData then
            local button = self:CreateAchievementButton(id, yOffset)
            self.buttons[id] = button
            yOffset = yOffset + button:GetHeight()
        end
    end
    -- Обновляем скроллируемую область
    self:UpdateScrollArea(yOffset)
end

-- Обновление скроллинга
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
function CustomAchievements:SendAchievementCompletionMessage(id)
    local achievementData = self:GetAchievementData(id)
    if achievementData then
        SendChatMessage("Достижение " .. achievementData.name .. ": " .. achievementData.dateCompleted, "OFFICER", nil, 1)
    end
end

-- Метод для создания кнопки ачивки
function CustomAchievements:CreateAchievementButton(id, yOffset)
    local achievementData = self:GetAchievementData(id)
    if not achievementData then return end
    -- Создаем кнопку
    local button = CreateFrame("Button", nil, self.achievementContainer)
    button:SetSize(510, COLLAPSED_HEIGHT)  -- Начальная высота
    button:SetPoint("TOP", self.achievementContainer, "TOP", 100, -yOffset)
    button.id = id  -- Сохраняем ID ачивки в кнопке
    -- Иконка ачивки
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(DEFAULT_ICON_SIZE, DEFAULT_ICON_SIZE)
    icon:SetPoint("TOPLEFT", self.COLLAPSED_POSITIONS.icon.x, self.COLLAPSED_POSITIONS.icon.y)
    icon:SetTexture(achievementData.texture)
    button.icon = icon
    -- Название ачивки
    button.nameText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    button.nameText:SetPoint("TOPLEFT", icon, "RIGHT", 10, 0)
    button.nameText:SetText(achievementData.name)
    button.nameText:SetJustifyH("LEFT")
    -- Дата получения
    button.dateText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.dateText:SetPoint("TOPLEFT", self.COLLAPSED_POSITIONS.date.x, self.COLLAPSED_POSITIONS.date.y)
    button.dateText:SetText(achievementData.dateEarned)
    button.dateText:SetJustifyH("LEFT")
    -- Иконка очков награды
    button.rewardPointsIcon = button:CreateTexture(nil, "ARTWORK")
    button.rewardPointsIcon:SetSize(REWARD_ICON_SIZE, REWARD_ICON_SIZE)
    button.rewardPointsIcon:SetPoint("TOPLEFT", self.COLLAPSED_POSITIONS.rewardPoints.x, self.COLLAPSED_POSITIONS.rewardPoints.y)
    button.rewardPointsIcon:SetTexture(TEXTURE_SHIELD)
    -- Состояние щита в зависимости от выполнения ачивки
    if achievementData.dateCompleted ~= "Не выполнена" then
        button.rewardPointsIcon:SetTexCoord(0, 0.5, 0, 1)  -- Зеленый щит
    else
        button.rewardPointsIcon:SetTexCoord(0.5, 1, 0, 1)  -- Серый щит
    end
    -- Текст очков награды
    button.rewardPointsText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.rewardPointsText:SetPoint("CENTER", button.rewardPointsIcon)
    button.rewardPointsText:SetText(achievementData.rewardPoints)
    -- Описание (скрыто в свернутом состоянии)
    button.descriptionText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    button.descriptionText:SetWidth(400)  -- Ограничиваем ширину текста
    button.descriptionText:SetWordWrap(true)  -- Включаем перенос строк
    button.descriptionText:SetText(achievementData.description)
    button.descriptionText:SetJustifyH("LEFT")
    button.descriptionText:Hide()
    -- Подсветка при наведении
    button.highlight = button:CreateTexture(nil, "BACKGROUND")
    button.highlight:SetAllPoints()
    button.highlight:SetTexture(TEXTURE_HIGHLIGHT)
    button.highlight:SetAlpha(0)
    -- Фон в зависимости от статуса
    button.normal = button:CreateTexture(nil, "BACKGROUND")
    button.normal:SetAllPoints()
    button.normal:SetTexture(achievementData.dateCompleted ~= "Не выполнена" and TEXTURE_COMPLETE or TEXTURE_INCOMPLETE)
    button.normal:SetAlpha(1)
    -- Обработчики событий
    button:SetScript("OnEnter", function()
        button.highlight:SetAlpha(1)
        button.normal:SetAlpha(0)
        self:ShowAchievementTooltip(button, id)
    end)
    button:SetScript("OnLeave", function()
        if button ~= self.selectedButton then
            button.highlight:SetAlpha(0)
            button.normal:SetAlpha(1)
        end
        GameTooltip:Hide()
    end)
    -- Левый клик - развернуть/свернуть ачивку
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            -- Обновляем состояние в динамических данных
            self.dynamicData[id].isExpanded = not self.dynamicData[id].isExpanded
            local scrollBarValue = self.achievementList.scrollBar:GetValue()
            self:UpdateUI()
            self.achievementList.scrollBar:SetValue(scrollBarValue)
        elseif mouseButton == "RightButton" then
            -- Правый клик - отправляем сообщение в чат
            self:SendAchievementCompletionMessage(id)
        end
    end)
    -- Обработка начального состояния (свернуто/развернуто)
    if achievementData.isExpanded then
        self:ExpandAchievement(button, id)
    end
    return button
end

-- Модифицированный метод для показа тултипа
function CustomAchievements:ShowAchievementTooltip(button, id)
    local data = self:GetAchievementData(id)
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

-- Метод для раскрытия ачивки с под-ачивками
function CustomAchievements:ExpandAchievement(button, id)
    local achievement = self:GetAchievementData(id)
    if not achievement then return end
    -- Позиционирование элементов с явным указанием координат
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.icon.x, self.EXPANDED_POSITIONS.icon.y)
    button.nameText:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.name.x, self.EXPANDED_POSITIONS.name.y)
    button.dateText:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.date.x, self.EXPANDED_POSITIONS.date.y)
    button.rewardPointsIcon:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.rewardPoints.x, self.EXPANDED_POSITIONS.rewardPoints.y)
    -- Описание ачивки
    button.descriptionText:SetPoint("TOPLEFT", button, "TOPLEFT", self.EXPANDED_POSITIONS.description.x, self.EXPANDED_POSITIONS.description.y)
    button.descriptionText:Show()
    -- Рассчитываем высоту описания
    local descriptionHeight = button.descriptionText:GetHeight()
    -- Вложенные достижения
    local requiredYOffset = -80
    local iconSize = 30
    local iconSpacing = 5
    for i, reqId in ipairs(achievement.subAchievements) do
        local reqAchievement = self:GetAchievementData(reqId)
        if reqAchievement then
            self:CreateNestedAchievementIcon(button, reqAchievement, i, self.EXPANDED_POSITIONS.requiredAchievements.x, requiredYOffset, iconSize, iconSpacing)
        end
    end
    -- Высота кнопки
    local numRows = math.ceil(#achievement.subAchievements / MAX_ICONS_PER_ROW)
    local totalHeight = EXPANDED_BASE_HEIGHT + descriptionHeight + numRows * (iconSize + iconSpacing)
    button:SetHeight(totalHeight)
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
        self:ShowAchievements()  -- Показываем ачивки, если фрейм видим
    end
end

-- Метод для скрытия фрейма
function CustomAchievements:Hide()
    if self.frame then
        self.frame:Hide()
    end
end

-- Функция для создания третьей вкладки
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
        for i = 1, 20 do
            if _G['AchievementFrameCategoriesContainerButton'..i] then
                _G['AchievementFrameCategoriesContainerButton'..i]:Hide()
            end
        end
        -- Показываем наш кастомный фрейм
        self:Show()
        -- Показываем ачивки
        self:ShowAchievements()
        -- Обновляем состояние вкладок
        PanelTemplates_SetTab(AchievementFrame, 3)
    end)
end

-- Создание кастомного фрейма уведомлений
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
    alertFrame.Icon:SetPoint("TOPLEFT", alertFrame, "TOPLEFT", 10, -10)  -- Отступ от верхнего левого угла
    alertFrame.Icon:SetTexture("Interface\\Icons\\Ability_Rogue_ShadowStrikes")
    -- Текст названия ачивки
    alertFrame.Name = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    alertFrame.Name:SetPoint("TOPLEFT", alertFrame.Icon, "TOPRIGHT", 10, 0)  -- Отступ от иконки
    alertFrame.Name:SetJustifyH("LEFT")  -- Выравнивание по левому краю
    alertFrame.Name:SetText("Название ачивки")
    -- Текст описания ачивки (многострочный)
    alertFrame.Description = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    alertFrame.Description:SetPoint("TOPLEFT", alertFrame.Name, "BOTTOMLEFT", 0, -5)  -- Отступ от названия
    alertFrame.Description:SetJustifyH("LEFT")  -- Выравнивание по левому краю
    alertFrame.Description:SetText("Описание ачивки")
    -- Функция для обновления размера фрейма
    alertFrame.UpdateSize = function(self)
        -- Рассчитываем ширину текста
        local nameWidth = self.Name:GetStringWidth()
        local descriptionWidth = self.Description:GetStringWidth()
        local maxTextWidth = math.max(nameWidth, descriptionWidth)
        -- Минимальная ширина фрейма (чтобы он не был слишком узким)
        local minWidth = 300
        local frameWidth = math.max(minWidth, maxTextWidth + 75)  -- 75 = отступы (иконка + паддинги)
        -- Рассчитываем высоту фрейма
        local frameHeight = self.Name:GetHeight() + self.Description:GetHeight() + 35  -- Отступы
        -- Устанавливаем новый размер фрейма
        self:SetSize(frameWidth, frameHeight)
        -- Обновляем позицию текстовых элементов
        self.Name:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 10, 0)
        self.Description:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -5)
    end
    return alertFrame
end

-- Метод для обновления данных ачивки
function CustomAchievements:UpdateAchievement(id, key, value)
    if not self.dynamicData[id] then
        print("Ачивка с ID " .. id .. " не получена игроком")
        return
    end
    local allowedKeys = {
        dateEarned = true,
        dateCompleted = true,
        progress = true,
        isExpanded = true,
        scrollPosition = true
    }
    if allowedKeys[key] then
        self.dynamicData[id][key] = value
        self:UpdateUI()  -- Перерисовываем интерфейс
    else
        print("Недопустимый ключ для динамических данных: " .. key)
    end
end

-- Метод для получения данных ачивки
function CustomAchievements:GetAchievementData(id)
    local static = self.staticData[id]
    local dynamic = self.dynamicData[id]
    if not static then return nil end
    return {
        -- Статичные данные
        name = static.name,
        description = static.description,
        texture = static.texture,
        rewardPoints = static.rewardPoints,
        requiredAchievements = static.requiredAchievements,
        subAchievements = static.subAchievements or {},  -- Под-ачивки
        collapsedPositions = static.collapsedPositions,
        expandedPositions = static.expandedPositions,
        -- Динамические данные
        dateEarned = dynamic and dynamic.dateEarned or "Не получена",  -- Используем значение по умолчанию, если динамические данные отсутствуют
        dateCompleted = dynamic and dynamic.dateCompleted or "Не выполнена",
        progress = dynamic and dynamic.progress or 0,
        isExpanded = dynamic and dynamic.isExpanded or false,
        scrollPosition = dynamic and dynamic.scrollPosition or 0
    }
end

-- Метод для отображения уведомления о новой ачивке
function CustomAchievements:ShowAchievementAlert(achievementID)
    -- Получаем данные ачивки через метод GetAchievementData
    local achievement = self:GetAchievementData(achievementID)
    if not achievement then
        print("Ачивка с ID " .. achievementID .. " не найдена.")
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
    -- Обновляем размер фрейма
    self.customAlertFrame:UpdateSize()
    -- Устанавливаем начальную прозрачность
    self.customAlertFrame:SetAlpha(1)
    -- Показываем фрейм
    self.customAlertFrame:Show()
    -- Сбрасываем таймер и состояние
    self.customAlertFrame.timer = 5  -- Время в секундах до скрытия
    self.customAlertFrame.elapsed = 0  -- Время, прошедшее с момента начала
    -- Удаляем предыдущий обработчик OnUpdate, если он есть
    self.customAlertFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= self.timer then
            -- Постепенно уменьшаем прозрачность
            local alpha = self:GetAlpha()
            alpha = alpha - elapsed * 0.5  -- Скорость уменьшения прозрачности
            if alpha <= 0 then
                alpha = 0
                self:Hide()
                self:SetScript("OnUpdate", nil)  -- Удаляем обработчик
            end
            self:SetAlpha(alpha)
        end
    end)
end

-- Метод для проверки существования ачивки по ID
function CustomAchievements:IsAchievement(id)
    -- Проверяем наличие статических данных
    local staticExists = self.staticData[id] ~= nil
    -- Проверяем наличие динамических данных
    local dynamicExists = self.dynamicData[id] ~= nil
    -- Возвращаем true, если хотя бы одни из данных существует
    return staticExists and dynamicExists
end

-- Метод для проверки количества добавленных ачивок
function CustomAchievements:GetAchievementCount()
    local count = 0
    for id, _ in pairs(self.dynamicData) do
        if self.staticData[id] then  -- Проверяем, что ачивка существует в статических данных
            count = count + 1
        end
    end
    return count
end