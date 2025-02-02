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
    input_table[key] = input_table[key] or {}
    new_object.input_table = input_table[key]
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
function NsDb:mod_key(change_key, num, message)
    if self.str_len > 1 and self.unique and not self.input_table[change_key] then
        self.input_table[change_key] = message
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
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)

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

-- Класс CustomAchievements
CustomAchievements = {}
CustomAchievements.__index = CustomAchievements

-- Конструктор
function CustomAchievements:new(achievementsTable)
    -- Проверяем, является ли achievementsTable таблицей
    print(_G[achievementsTable], '123')
    _G[achievementsTable] = _G[achievementsTable] or {}
    local obj = {
        achievements = _G[achievementsTable],  -- Таблица с ачивками
        frame = nil,  -- Фрейм для отображения ачивок
        buttons = {},  -- Таблица для хранения кнопок ачивок
        tabCreated = false,  -- Флаг для отслеживания создания вкладки
        nightWatchTab = nil,  -- Ссылка на вкладку "Ночная стража"
        selectedButton = nil  -- Текущая выбранная ачивка
    }
    setmetatable(obj, self)
    return obj
end

-- Метод для создания фрейма
function CustomAchievements:CreateFrame(parent)
    -- Создаем фрейм для отображения ачивок
    self.frame = CreateFrame("Frame", nil, parent)
    self.frame:SetSize(400, 500)
    self.frame:SetPoint("CENTER")
    self.frame:Hide()  -- Скрываем фрейм по умолчанию

    -- Заголовок раздела
    local title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", self.frame, "TOP", 0, -10)

    -- Создаем скроллфрейм вручную
    self.achievementList = CreateFrame("ScrollFrame", nil, self.frame)
    self.achievementList:SetSize(720, 450)  -- Ширина скроллфрейма
    self.achievementList:SetPoint("TOP", title, "BOTTOM", 0, -10)

    -- Контейнер для ачивок
    self.achievementContainer = CreateFrame("Frame", nil, self.achievementList)
    self.achievementContainer:SetSize(720, 450)  -- Ширина контейнера равна ширине скроллфрейма
    self.achievementList:SetScrollChild(self.achievementContainer)

    -- Устанавливаем слой для контейнера
    self.achievementContainer:SetFrameStrata("MEDIUM")  -- Убедимся, что контейнер находится на верхнем слое

    -- Добавляем текстуру для фона контейнера
    local background = self.achievementContainer:CreateTexture(nil, "BACKGROUND")
    background:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock")  -- Стандартная текстура
    background:SetAllPoints(self.achievementContainer)  -- Растягиваем текстуру на весь контейнер
    background:SetVertexColor(1, 1, 1, 1)  -- Устанавливаем цвет и прозрачность

    -- Создаем скроллбар вручную
    local scrollBar = CreateFrame("Slider", nil, self.achievementList, "UIPanelScrollBarTemplate")
    scrollBar:SetPoint("TOPLEFT", self.achievementList, "TOPRIGHT", -20, -16)
    scrollBar:SetPoint("BOTTOMLEFT", self.achievementList, "BOTTOMRIGHT", -20, 16)
    scrollBar:SetWidth(16)
    scrollBar:SetMinMaxValues(0, 100)
    scrollBar:SetValueStep(1)
    scrollBar:SetValue(0)
    scrollBar:SetFrameStrata("DIALOG")  -- Высокий слой (над большинством элементов)

    -- Настраиваем обработчик изменения значения скроллбара
    scrollBar:SetScript("OnValueChanged", function(self, value)
        self:GetParent():SetVerticalScroll(value)
    end)

    -- Настраиваем прокрутку колесом мыши
    self.achievementList:SetScript("OnMouseWheel", function(self, delta)
        local currentValue = scrollBar:GetValue()
        scrollBar:SetValue(currentValue - delta * 20)
    end)

    -- Привязываем скроллбар к скроллфрейму
    self.achievementList.scrollBar = scrollBar
end

-- Метод для добавления ачивки
function CustomAchievements:AddAchievement(id, name, description, texture, progress, dateEarned, dateCompleted, rewardPoints, requiredAchievements)
    -- Проверяем, существует ли ачивка с таким же ID
    if self.achievements[id] then
        return  -- Если ачивка уже существует, выходим
    end

    -- Добавляем ачивку в таблицу
    self.achievements[id] = {
        name = name,
        description = description,
        texture = texture,
        progress = progress or 0,
        dateEarned = dateEarned or "Не получена",  -- Дата получения
        dateCompleted = dateCompleted or "Не выполнена",  -- Дата выполнения на 100%
        rewardPoints = rewardPoints or 0,  -- Очки награды
        requiredAchievements = requiredAchievements or {},  -- Вложенные ачивки
        isExpanded = false,  -- По умолчанию кнопка свернута
        -- Координаты для свернутого состояния
        collapsedPositions = {
            icon = { x = 5, y = 0 },  -- Иконка
            name = { x = 50, y = -5 },  -- Заголовок
            date = { x = 300, y = -5 },  -- Дата (справа от заголовка)
            rewardPoints = { x = 440, y = -5 },  -- Иконка очков
        },
        -- Координаты для развернутого состояния
        expandedPositions = {
            icon = { x = 5, y = 0 },  -- Иконка
            name = { x = 50, y = -5 },  -- Заголовок
            description = { x = 50, y = -25 },  -- Описание
            date = { x = 300, y = -5 },  -- Дата (справа от заголовка)
            rewardPoints = { x = 440, y = -5 },  -- Иконка очков
            requiredAchievements = { x = 50, y = -50 },  -- Вложенные ачивки
        }
    }

    -- Обновляем интерфейс
    self:UpdateUI()
    self:ShowAchievementAlert(id)
end

-- Метод для обновления интерфейса
function CustomAchievements:UpdateUI()
    -- Проверяем, существует ли контейнер
    if not self.achievementContainer then
        return  -- Если контейнер не создан, выходим
    end

    -- Очищаем контейнер перед обновлением
    for _, child in ipairs({self.achievementContainer:GetChildren()}) do
        child:Hide()  -- Скрываем все дочерние элементы
        child:ClearAllPoints()  -- Очищаем привязки
        child:SetParent(nil)  -- Убираем родителя
    end

    self.buttons = {}  -- Очищаем таблицу кнопок

    -- Отображаем ачивки
    local yOffset = 0  -- Начальное смещение по вертикали
    for id, achievement in pairs(self.achievements) do
        local button = CreateFrame("Button", nil, self.achievementContainer)  -- Создаем кнопку для ачивки
        button:SetSize(510, 50)  -- Начальная высота кнопки
        button:SetPoint("TOP", self.achievementContainer, "TOP", 100, -yOffset)

        -- Устанавливаем слой для кнопки ачивки
        button:SetFrameStrata("HIGH")

        -- Иконка ачивки
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetSize(40, 40)
        icon:SetTexture(achievement.texture)

        -- Название ачивки
        local nameText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nameText:SetText(achievement.name)

        -- Дата (справа от заголовка)
        local dateText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        dateText:SetText(achievement.dateEarned)  -- По умолчанию показываем дату получения

        -- Иконка очков награды
        local rewardPointsIcon = button:CreateTexture(nil, "ARTWORK")
        rewardPointsIcon:SetSize(48, 48)
        rewardPointsIcon:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Shields")  -- Иконка очков

        -- Устанавливаем текстуру в зависимости от выполнения ачивки
        if achievement.progress == 100 then
            rewardPointsIcon:SetTexCoord(0, 0.5, 0, 1)  -- Ачивка выполнена
        else
            rewardPointsIcon:SetTexCoord(0.5, 1, 0, 1)  -- Ачивка не выполнена
        end

        -- Текст очков награды (в центре иконки)
        local rewardPointsText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rewardPointsText:SetText(achievement.rewardPoints)
        rewardPointsText:SetPoint("CENTER", rewardPointsIcon, "CENTER", 0, 0)  -- Центрируем текст на иконке

        -- Краткое описание ачивки (видно только в развернутом состоянии)
        local descriptionText = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        descriptionText:SetText(achievement.description)
        descriptionText:SetJustifyH("LEFT")
        descriptionText:Hide()  -- По умолчанию скрываем

        -- Подсветка при наведении
        local highlight = button:CreateTexture(nil, "BACKGROUND")
        highlight:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")  -- Текстура для подсветки
        highlight:SetAllPoints(button)
        highlight:SetAlpha(0)  -- Начально скрываем подсветку

        -- Текстура для фона кнопки (зависит от прогресса)
        local normal = button:CreateTexture(nil, "BACKGROUND")
        if achievement.progress < 100 then
            normal:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal-Desaturated")  -- Текстура для незавершенных ачивок
        else
            normal:SetTexture("Interface\\AchievementFrame\\UI-Achievement-AchievementBackground")  -- Текстура для завершенных ачивок
        end
        normal:SetAllPoints(button)
        normal:SetAlpha(1)  -- Показываем текстуру фона

        -- Обработчик наведения курсора на кнопку
        button:SetScript("OnEnter", function()
            highlight:SetAlpha(1)  -- Показываем подсветку
            normal:SetAlpha(0)  -- Скрываем текстуру фона

            -- Показываем тултип с датами
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText("Дата получения: " .. achievement.dateEarned)
            if achievement.dateCompleted ~= "Не выполнена" then
                GameTooltip:AddLine("Выполнено: " .. achievement.dateCompleted)
            end
            GameTooltip:Show()
        end)

        button:SetScript("OnLeave", function()
            if button ~= self.selectedButton then
                highlight:SetAlpha(0)  -- Скрываем подсветку, если ачивка не выбрана
                normal:SetAlpha(1)  -- Показываем текстуру фона
            end
            GameTooltip:Hide()
        end)

        -- Обработчик клика для сворачивания/разворачивания
        button:SetScript("OnClick", function()
            achievement.isExpanded = not achievement.isExpanded
            
            -- Сохраняем текущее значение скроллбара перед обновлением интерфейса
            local scrollBarValue = self.achievementList.scrollBar:GetValue()
            self:UpdateUI()  -- Обновляем интерфейс
            
            -- Восстанавливаем значение скроллбара после обновления интерфейса
            self.achievementList.scrollBar:SetValue(scrollBarValue)
        end)

        -- Сохраняем ссылки на элементы кнопки
        button.icon = icon
        button.nameText = nameText
        button.dateText = dateText
        button.rewardPointsIcon = rewardPointsIcon
        button.rewardPointsText = rewardPointsText
        button.descriptionText = descriptionText
        button.highlight = highlight
        button.normal = normal

        -- Сохраняем кнопку в таблице
        self.buttons[id] = button

        -- Обновляем позиции элементов в зависимости от состояния
        if achievement.isExpanded then
            -- Развернутое состояние
            icon:SetPoint("TOPLEFT", button, "TOPLEFT", achievement.expandedPositions.icon.x, achievement.expandedPositions.icon.y)
            nameText:SetPoint("TOPLEFT", button, "TOPLEFT", achievement.expandedPositions.name.x, achievement.expandedPositions.name.y)
            dateText:SetPoint("TOPLEFT", button, "TOPLEFT", achievement.expandedPositions.date.x, achievement.expandedPositions.date.y)
            rewardPointsIcon:SetPoint("TOPLEFT", button, "TOPLEFT", achievement.expandedPositions.rewardPoints.x, achievement.expandedPositions.rewardPoints.y)
            descriptionText:SetPoint("TOPLEFT", button, "TOPLEFT", achievement.expandedPositions.description.x, achievement.expandedPositions.description.y)
            descriptionText:Show()

            -- Отображаем вложенные ачивки
            local requiredYOffset = -80  -- Смещение для вложенных ачивок
            local requiredXOffset = 50   -- Смещение по горизонтали для вложенных ачивок
            local iconsPerRow = 10       -- Количество иконок в ряду
            local iconSize = 30          -- Размер иконки
            local iconSpacing = 5        -- Расстояние между иконками

            for i, reqId in ipairs(achievement.requiredAchievements) do
                local reqAchievement = self.achievements[reqId]
                if reqAchievement then
                    -- Создаем кнопку для вложенной иконки
                    local reqIconButton = CreateFrame("Button", nil, button)
                    reqIconButton:SetSize(iconSize, iconSize)
                    reqIconButton:SetPoint(
                        "TOPLEFT",
                        button,
                        "TOPLEFT",
                        achievement.expandedPositions.requiredAchievements.x + ((i - 1) % iconsPerRow) * (iconSize + iconSpacing),
                        requiredYOffset - math.floor((i - 1) / iconsPerRow) * (iconSize + iconSpacing)
                    )

                    -- Добавляем текстуру в кнопку
                    local reqIcon = reqIconButton:CreateTexture(nil, "ARTWORK")
                    reqIcon:SetAllPoints(reqIconButton)
                    reqIcon:SetTexture(reqAchievement.texture)

                    -- Затемняем иконку, если ачивка не выполнена
                    if reqAchievement.progress < 100 then
                        reqIcon:SetDesaturated(true)  -- Затемняем иконку
                    end

                    -- Обработчик клика на вложенную иконку
                    reqIconButton:SetScript("OnMouseDown", function()
                        self:ScrollToAchievement(reqId)  -- Переходим к ачивке
                        self.achievements[reqId].isExpanded = true  -- Разворачиваем ачивку
                        self:UpdateUI()  -- Обновляем интерфейс
                    end)

                    -- Обработчик наведения курсора на вложенную иконку
                    reqIconButton:SetScript("OnEnter", function()
                        GameTooltip:SetOwner(reqIconButton, "ANCHOR_RIGHT")
                        GameTooltip:SetText(reqAchievement.name)
                        GameTooltip:AddLine(reqAchievement.description, 1, 1, 1, true)
                        GameTooltip:AddLine("Дата получения: " .. reqAchievement.dateEarned, 1, 1, 1)
                        if reqAchievement.dateCompleted ~= "Не выполнена" then
                            GameTooltip:AddLine("Выполнено: " .. reqAchievement.dateCompleted, 1, 1, 1)
                        end
                        GameTooltip:Show()
                    end)

                    reqIconButton:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                end
            end

            -- Увеличиваем высоту кнопки в зависимости от количества рядов вложенных ачивок
            local numRows = math.ceil(#achievement.requiredAchievements / iconsPerRow)
            button:SetHeight(100 + numRows * (iconSize + iconSpacing))
        else
            -- Свернутое состояние
            icon:SetPoint("TOPLEFT", button, "TOPLEFT", achievement.collapsedPositions.icon.x, achievement.collapsedPositions.icon.y)
            nameText:SetPoint("TOPLEFT", button, "TOPLEFT", achievement.collapsedPositions.name.x, achievement.collapsedPositions.name.y)
            dateText:SetPoint("TOPLEFT", button, "TOPLEFT", achievement.collapsedPositions.date.x, achievement.collapsedPositions.date.y)
            rewardPointsIcon:SetPoint("TOPLEFT", button, "TOPLEFT", achievement.collapsedPositions.rewardPoints.x, achievement.collapsedPositions.rewardPoints.y)
            descriptionText:Hide()
            button:SetHeight(50)  -- Возвращаем стандартную высоту
        end

        yOffset = yOffset + button:GetHeight()  -- Увеличиваем смещение для следующей ачивки
    end

    -- Обновляем высоту контейнера в зависимости от количества ачивок
    local totalHeight = yOffset + 60
    self.achievementContainer:SetHeight(totalHeight)

    -- Обновляем диапазон скроллбара
    local scrollBar = self.achievementList.scrollBar
    if scrollBar then
        local scrollHeight = totalHeight - self.achievementList:GetHeight()
        if scrollHeight < 0 then
            scrollHeight = 0  -- Убедимся, что значение не отрицательное
        end
        scrollBar:SetMinMaxValues(0, scrollHeight)
        scrollBar:SetValue(0)
    end
end

-- Метод для перехода к ачивке
function CustomAchievements:ScrollToAchievement(id)
    local button = self.buttons[id]
    if button then
        -- Прокручиваем скроллфрейм к нужной ачивке
        local scrollBar = self.achievementList.scrollBar
        local scrollValue = button:GetTop() - self.achievementList:GetHeight()
        scrollBar:SetValue(scrollValue)
    end
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
        for i = 1, 10 do
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
    alertFrame.Icon:SetPoint("LEFT", alertFrame, "LEFT", 10, 0)
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
        local frameWidth = math.max(minWidth, maxTextWidth + 70)  -- 60 = отступы (иконка + паддинги)

        -- Рассчитываем высоту фрейма
        local frameHeight = self.Name:GetHeight() + self.Description:GetHeight() + 30  -- Отступы

        -- Устанавливаем новый размер фрейма
        self:SetSize(frameWidth, frameHeight)
    end
    return alertFrame
end

-- Метод для отображения уведомления о новой ачивке
function CustomAchievements:ShowAchievementAlert(achievementID)
    -- Проверяем, существует ли таблица achievements

    -- Получаем данные ачивки
    local achievement = self.achievements[achievementID]
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


