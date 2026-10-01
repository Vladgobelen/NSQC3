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

function NsDb:addDeepStaticStr(...)
    local args = {...}
    local n = #args

    if n < 2 then return end

    self.input_table = self.input_table or {}
    local current = self.input_table

    -- Проверяем, является ли предпоследний аргумент nil
    local hasNil = (args[n-1] == nil)

    -- Определяем ключ и значение для записи
    local key = args[n-2]
    local value = args[n]

    -- Построение пути до родительской таблицы
    for i = 1, n-3 do
        local part = args[i]
        current[part] = current[part] or {}
        current = current[part]
    end

    if hasNil then
        -- Если предпоследний аргумент nil, записываем значение напрямую
        current[key] = value
    else
        -- Иначе обновляем строку по указанному индексу
        local index = args[n-1]
        local currentStr = current[key] or ""
        local formattedValue = ("   " .. value):sub(-3) -- Форматируем до 3 символов
        local start = (index - 1) * 3 + 1 -- Начало замены
        local end_pos = index * 3

        -- Обновляем строку
        current[key] = currentStr:sub(1, start - 1) 
                        .. formattedValue 
                        .. currentStr:sub(end_pos + 1)
    end
end

function NsDb:getDeepStaticStr(...)
    local args = {...}
    local n = #args
    
    if n == 0 then return nil end
    
    local current = self.input_table
    if not current then return nil end
    
    -- Идем по всем аргументам
    for i = 1, n do
        if not current then return nil end
        
        local arg = args[i]
        local nextData = current[arg]
        
        -- Если это последний аргумент
        if i == n then
            if type(nextData) == "string" then
                -- Если следующий элемент - строка, возвращаем её
                return nextData
            else
                -- Иначе возвращаем сам элемент
                return nextData
            end
        else
            -- Если следующий элемент - строка, но есть ещё аргументы
            if type(nextData) == "string" then
                -- Возвращаем подстроку по следующему аргументу (индексу)
                local index = args[i+1]
                if type(index) == "number" then
                    return nextData:sub((index-1)*3 + 1, index*3)
                else
                    return nil
                end
            end
            current = nextData
        end
    end
    
    return current
end

function NsDb:addDeepStaticStr2(...)
    local args = {...}
    local n = #args

    if n < 2 then return end

    self.input_table = self.input_table or {}
    local current = self.input_table

    -- Check if the second last argument is nil
    local hasNil = (args[n-1] == nil)

    -- Determine key and value for writing
    local key = args[n-2]
    local value = args[n]

    -- Build path to parent table
    for i = 1, n-3 do
        local part = args[i]
        current[part] = current[part] or {}
        current = current[part]
    end

    if hasNil then
        -- If second last argument is nil, write value directly
        current[key] = value
    else
        -- Otherwise update string at specified index
        local index = args[n-1]
        local currentStr = current[key] or ""
        local formattedValue
        
        -- First object is always 1 character, others are 2
        if index == 1 then
            formattedValue = (" " .. value):sub(-1) -- Format to 1 character
        else
            formattedValue = ("  " .. value):sub(-2) -- Format to 2 characters
        end
        
        -- Calculate positions
        local start, end_pos
        if index == 1 then
            start = 1
            end_pos = 1
        else
            start = 2 + (index - 2) * 2
            end_pos = start + 1
        end

        -- Update the string
        current[key] = currentStr:sub(1, start - 1) 
                        .. formattedValue 
                        .. currentStr:sub(end_pos + 1)
    end
end

function NsDb:getDeepStaticStr2(...)
    local args = {...}
    local n = #args
    
    if n == 0 then return nil end
    
    local current = self.input_table
    if not current then return nil end
    
    -- Iterate through all arguments
    for i = 1, n do
        if not current then return nil end
        
        local arg = args[i]
        local nextData = current[arg]
        
        -- If this is the last argument
        if i == n then
            if type(nextData) == "string" then
                -- If next element is a string, return it
                return nextData
            else
                -- Otherwise return the element itself
                return nextData
            end
        else
            -- If next element is a string but there are more arguments
            if type(nextData) == "string" then
                -- Return substring based on next argument (index)
                local index = args[i+1]
                if type(index) == "number" then
                    if index == 1 then
                        return nextData:sub(1, 1)
                    else
                        local start = 2 + (index - 2) * 2
                        return nextData:sub(start, start + 1)
                    end
                else
                    return nil
                end
            end
            current = nextData
        end
    end
    print(current,1111)
    return current
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

function NsDb:add_log(message)
    self.input_table = self.input_table or {}
    table.insert(self.input_table, message)
    if #self.input_table > 10000 then
        table.remove(self.input_table, 1)
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

function NsDb:logLen()
    if not self.input_table then return 0 end
    return #self.input_table  -- Просто количество элементов в массиве
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

function NsDb:hasKey(key)
    return self.input_table and self.input_table[key] ~= nil
end

function NsDb:createTable(key)
    self.input_table = self.input_table or {}
    self.input_table[key] = {}
end

function NsDb:addToSubtable(subtable_name, value)
    -- Если подтаблицы нет — создаём её как массив
    if not self.input_table[subtable_name] then
        self.input_table[subtable_name] = {}
    end

    -- Проверяем, что подтаблица — массив (если нет — преобразуем)
    if not self:isArray(self.input_table[subtable_name]) then
        local old_value = self.input_table[subtable_name]
        self.input_table[subtable_name] = {old_value}  -- Делаем из старого значения массив
    end

    -- Добавляем новое значение
    table.insert(self.input_table[subtable_name], value)
end

-- Вспомогательная функция: проверяет, является ли таблица массивом (списком)
function NsDb:isArray(tbl)
    if type(tbl) ~= "table" then return false end
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count == #tbl  -- Если количество элементов == длине массива
end

-- Метод для получения размера подтаблицы (включая вложенные таблицы)
function NsDb:getSubtableSize(...)
    local n = select('#', ...)
    if n == 0 then return 0 end
    
    local target = self.input_table
    
    -- Ищем целевую подтаблицу по цепочке ключей
    for i = 1, n do
        local key = select(i, ...)
        if type(target) ~= "table" then return 0 end
        target = target[key]
        if target == nil then return 0 end
    end
    
    -- Если дошли сюда - нашли подтаблицу
    return self:calculateTableSize(target)
end

-- Вспомогательная рекурсивная функция для подсчета размера таблицы
function NsDb:calculateTableSize(tbl)
    if type(tbl) ~= "table" then return 0 end
    
    local size = 0
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            size = size + self:calculateTableSize(v)
        else
            size = size + 1
        end
    end
    
    return size
end

-- Считает количество подтаблиц в основной таблице (верхний уровень)
function NsDb:TotalSize()
    if not self.input_table or type(self.input_table) ~= "table" then
        return 0
    end
    
    local count = 0
    for _, v in pairs(self.input_table) do
        if type(v) == "table" then
            count = count + 1
        end
    end
    return count
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

-- Таблицы
local CRAFT_ENABLED_LOCATIONS = {
    ["хижина"] = true,
}
-- Константы
local CRAFT_BUTTON_SIZE = 32
local CRAFT_BUTTON_ACTIVE_ALPHA = 1.0
local CRAFT_BUTTON_INACTIVE_ALPHA = 0.4
local CRAFT_BUTTON_COLOR_ACTIVE = {0.1, 0.8, 0.1} -- Зеленый
local CRAFT_BUTTON_COLOR_INACTIVE = {0.5, 0.5, 0.5} -- Серый

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

function AdaptiveFrame:new(parent)
    local self = setmetatable({}, AdaptiveFrame)
    self.parent = parent or UIParent
    self.width = 600
    self.height = 600
    self.initialAspectRatio = self.width / self.height
    self.buttonsPerRow = 5
    self.skipSizeCheck = true
    
    -- Создаем основной фрейм
    self.frame = CreateFrame("Frame", "AdaptiveFrame_"..math.random(10000), self.parent)
    self.frame:SetSize(self.width, self.height)
    self.skipSizeCheck = false
    self.frame:SetPoint("CENTER", self.parent, "CENTER", 150, 100)
    self.frame:SetScript("OnShow", function()
        if not ns_game_table or not ns_game_table.board then return end
        for idxStr, data in pairs(ns_game_table.board) do
            local idx = tonumber(idxStr)
            if idx and self.children[idx] and self.children[idx].frame and data.mainTex then
                local texPath = "Interface\\AddOns\\NSQC3\\libs\\" .. data.mainTex .. ".tga"
                self.children[idx].frame:SetNormalTexture(texPath)
            end
        end
    end)
    self.frame:SetFrameStrata("HIGH")
    self.frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    FRAME_ALPHA = ns_dbc:getKey("настройки", "FRAME_ALPHA") or FRAME_ALPHA
    BUTTON_ALPHA = ns_dbc:getKey("настройки", "BUTTON_ALPHA") or BUTTON_ALPHA
    self.frame:SetBackdropColor(0.1, 0.1, 0.1, FRAME_ALPHA)
    self.frame:SetBackdropBorderColor(0.8, 0.8, 0.8, 0)
    
    -- Текстовое поле
    self.textField = self.frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.textField:SetPoint("TOP", self.frame, "TOP", 0, -5)
    self.textField:SetText("")
    self.textField:SetTextColor(1, 1, 1, 1)
    
    -- Настройки перемещения и изменения размера
    self.frame:SetMovable(true)
    self.frame:SetResizable(true)
    self.frame:EnableMouse(true)
    self.frame:RegisterForDrag("LeftButton", "RightButton")
    
    -- Обработчики событий мыши
    self.frame:SetScript("OnMouseDown", function(_, button)
        if button == "RightButton" then
            self:ToggleFrameAlpha()
        elseif button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    local startX = 0
    local isDragging = false
    
    self.frame:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            isDragging = false
            self.frame:SetScript("OnUpdate", nil)
        else
            self:StopMovingOrSizing()
        end
    end)
    
    self.frame:SetScript("OnDragStart", function(_, button)
        if button == "RightButton" then
            startX = GetCursorPosition()
            isDragging = true
            self.frame:SetScript("OnUpdate", function()
                if isDragging then
                    local currentX = GetCursorPosition()
                    local deltaX = currentX - startX
                    startX = currentX
                    for _, child in ipairs(self.children) do
                        local currentAlpha = child.frame:GetAlpha()
                        if deltaX > 0 then
                            local newAlpha = math.min(currentAlpha + math.abs(deltaX)/1000, 1)
                            child.frame:SetAlpha(newAlpha)
                            ns_dbc:modKey("настройки", "BUTTON_ALPHA", newAlpha)
                            BUTTON_ALPHA = newAlpha
                        elseif deltaX < 0 then
                            local newAlpha = math.max(currentAlpha - math.abs(deltaX)/1000, 0)
                            child.frame:SetAlpha(newAlpha)
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
            self.frame:SetScript("OnUpdate", nil)
        else
            self:StopMovingOrSizing()
        end
    end)
    
    -- Кнопка закрытия
    self.closeButton = CreateFrame("Button", nil, self.frame, "UIPanelCloseButton")
    self.closeButton:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    self.closeButton:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -PADDING+5, -PADDING)
    self.closeButton:SetScript("OnClick", function()
        if self.textField:GetText():match(WORD_POSITION_PATTERNS[3]) ~= "участок" then
            SendAddonMessage("getFld " .. mFldName, "", "guild")
        else
            self:Hide()
        end
        for i = 1, 100 do
            if self.children[i] then
                self.children[i]:SetTextT("")
            end
        end
    end)
    
    -- Кнопка управления боковой панелью
    self.toggleSideButton = CreateFrame("Button", nil, self.frame)
    self.toggleSideButton:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    self.toggleSideButton:SetPoint("TOPRIGHT", self.closeButton, "BOTTOMRIGHT", 5, -5)
    self.toggleSideButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    self.toggleSideButton:GetNormalTexture():SetDesaturated(true)
    self.toggleSideButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    self.toggleSideButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    self.toggleSideButton:SetScript("OnClick", function()
        if not self.sideFrame then
            self:CreateSideFrame()
            self:ShowSideFrame()
            self.toggleSideButton:GetNormalTexture():SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
            self.toggleSideButton:GetPushedTexture():SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
        elseif self.sideFrame:IsShown() then
            self:HideSideFrame()
            self.toggleSideButton:GetNormalTexture():SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
            self.toggleSideButton:GetPushedTexture():SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
        else
            self:ShowSideFrame()
            self.toggleSideButton:GetNormalTexture():SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
            self.toggleSideButton:GetPushedTexture():SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
        end
    end)
    self.toggleSideButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.toggleSideButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Показать/скрыть инвентарь")
        GameTooltip:Show()
    end)
    self.toggleSideButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    -- Кнопка открытия интерфейса нуклеотидов
    self.nucleotideButton = CreateFrame("Button", nil, self.frame)
    self.nucleotideButton:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    self.nucleotideButton:SetPoint("TOPRIGHT", self.toggleSideButton, "BOTTOMRIGHT", 0, -5)
    self.nucleotideButton:SetNormalTexture("Interface\\ICONS\\inv_misc_gem_diamond_02")
    self.nucleotideButton:SetPushedTexture("Interface\\ICONS\\inv_misc_gem_diamond_02")
    self.nucleotideButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    
    local function UpdateNucleotideButtonState()
        local btn = self.nucleotideButton
        local nucBtn = _G["NucleotideMainButton"]
        if nucBtn and nucBtn:IsShown() then
            btn:GetNormalTexture():SetDesaturated(true)
            btn:SetAlpha(0.5)
            btn.isNucActive = true
        else
            btn:GetNormalTexture():SetDesaturated(false)
            btn:SetAlpha(1)
            btn.isNucActive = false
        end
    end
    
    self.nucleotideButton:SetScript("OnClick", function()
        if not NucleotideMainButton then
            SendAddonMessage("ns_dna " .. GetUnitName("player"), "", "GUILD")
            UpdateNucleotideButtonState()
            return
        end
        if not IsAnyMainButtonVisible() then
            SendAddonMessage("ns_dna " .. GetUnitName("player"), "", "GUILD")
        else
            SendAddonMessage("ns_dna_x " .. GetUnitName("player"), "", "GUILD")
        end
        UpdateNucleotideButtonState()
    end)
    self.nucleotideButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.nucleotideButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Открыть/скрыть интерфейс нуклеотидов")
        GameTooltip:Show()
    end)
    self.nucleotideButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    local timerFrame = CreateFrame("Frame")
    timerFrame:Hide()
    local elapsed = 0
    local delay = 0.5

    timerFrame:SetScript("OnUpdate", function(frame, dt)
        elapsed = elapsed + dt
        if elapsed >= delay then
            frame:SetScript("OnUpdate", nil)
            frame:Hide()
            UpdateNucleotideButtonState()
        end
    end)
    self.UpdateNucleotideButtonState = UpdateNucleotideButtonState
    
    -- === КНОПКА: переключение видимости маркера игрока ===
    self.togglePlayerMarkerButton = CreateFrame("Button", nil, self.frame)
    self.togglePlayerMarkerButton:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    self.togglePlayerMarkerButton:SetPoint("TOPRIGHT", self.nucleotideButton, "BOTTOMRIGHT", 0, -5)
    self.togglePlayerMarkerButton:SetNormalTexture("Interface\\ICONS\\Ability_Mage_Invisibility")
    self.togglePlayerMarkerButton:SetPushedTexture("Interface\\ICONS\\Ability_Mage_Invisibility")
    self.togglePlayerMarkerButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    self.drawPlayerMarker = true

    local function UpdatePlayerMarkerButtonState()
        local btn = self.togglePlayerMarkerButton
        if self.drawPlayerMarker then
            btn:GetNormalTexture():SetDesaturated(false)
            btn:SetAlpha(1)
            GameTooltip:SetText("Скрыть маркер игрока")
        else
            btn:GetNormalTexture():SetDesaturated(true)
            btn:SetAlpha(0.5)
            GameTooltip:SetText("Показать маркер игрока")
        end
    end

    self.togglePlayerMarkerButton:SetScript("OnClick", function()
        OpenLuaCourse()
    end)

    self.togglePlayerMarkerButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.togglePlayerMarkerButton, "ANCHOR_RIGHT")
        UpdatePlayerMarkerButtonState()
        GameTooltip:Show()
    end)

    self.togglePlayerMarkerButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    UpdatePlayerMarkerButtonState()
    
    -- === КНОПКА: запуск мини-игры ===
    self.gameStartButton = CreateFrame("Button", nil, self.frame)
    self.gameStartButton:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    self.gameStartButton:SetPoint("TOPRIGHT", self.togglePlayerMarkerButton, "BOTTOMRIGHT", 0, -5)
    self.gameStartButton:SetNormalTexture("Interface\\AddOns\\NSQC3\\libs\\5.tga")
    self.gameStartButton:SetPushedTexture("Interface\\AddOns\\NSQC3\\libs\\5.tga")
    self.gameStartButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    
    self.gameStartButton:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            local ownerName = self.owner
            if not ownerName and self.textField then
                local headerText = self.textField:GetText() or ""
                local parts = mysplit(headerText)
                if parts and parts[1] then
                    ownerName = parts[1]
                end
            end
            if not ownerName or ownerName == "" then
                ownerName = UnitName("player")
            end
            
            if ownerName == UnitName("player") and self.gameClient and self.gameClient:IsActive() then
                print("|cFFFF0000[Игра]|r Вы уже в игре на своём поле")
                return
            end
            
            SendAddonMessage("nsShowMeGame", ownerName, "GUILD")
            print("|cFF00FF00[Игра]|r Запрошен просмотр игры на поле: " .. ownerName)
            return
        end
        
        if self.gameClient and self.gameClient:IsActive() then
            _G.ns_game_funcs = nil
            _G.ns_move_st = nil
            if _G.gameClient then
                _G.gameClient.active = false
                _G.gameClient = nil
            end
            
            local ownerName = self.gameClient.ownerName or UnitName("player")
            local playerName = UnitName("player")
            self.gameClient:EndGame(ownerName, playerName)
            self.gameClient = nil
            print("|cFFFF0000[Игра]|r Игра завершена")
        else
            local ownerName = self.owner
            if not ownerName and self.textField then
                local headerText = self.textField:GetText() or ""
                local parts = mysplit(headerText)
                if parts and parts[1] then
                    ownerName = parts[1]
                end
            end
            if not ownerName or ownerName == "" then
                ownerName = UnitName("player")
            end
            
            _G.ns_game_funcs = nil
            _G.ns_move_st = nil
            if _G.gameClient then _G.gameClient = nil end
            
            self.gameClient = GameClient:new()
            _G.gameClient = self.gameClient
            SendAddonMessage("ns_NewGame", ownerName, "GUILD")
            self.gameClient:StartGame(ownerName, UnitName("player"))
            print("|cFF00FF00[Игра]|r Игра запущена")
        end
    end)

    self.gameStartButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.gameStartButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Запустить игру", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Правила игры:", 1, 0.82, 0)
        GameTooltip:AddLine("• У каждого игрока по 10 кубиков (d6)", 1, 1, 1)
        GameTooltip:AddLine("• Игрок 1 стартует снизу (клетки 1-10)", 1, 1, 1)
        GameTooltip:AddLine("• Игрок 2/ИИ стартует сверху (клетки 91-100)", 1, 1, 1)
        GameTooltip:AddLine("• Цель: уничтожить все кубики противника", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Как ходить:", 1, 0.82, 0)
        GameTooltip:AddLine("• Кликните на свой кубик (подсветятся варианты)", 1, 1, 1)
        GameTooltip:AddLine("• Зелёные клетки — обычный ход", 0.2, 1, 0.2)
        GameTooltip:AddLine("• Красные клетки — захват кубика врага", 1, 0.2, 0.2)
        GameTooltip:AddLine("• Число на кубике = дальность хода", 1, 1, 1)
        GameTooltip:AddLine("• Ходить назад нельзя (только вперёд)", 1, 0.5, 0.5)
        GameTooltip:AddLine("• ПКМ по доске = отмена выбора", 1, 1, 1)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Особые механики:", 1, 0.82, 0)
        GameTooltip:AddLine("• Респаун: дойдя до края противника,", 0.5, 1, 0.5)
        GameTooltip:AddLine("  вы получаете новый кубик в своей зоне", 0.5, 1, 0.5)
        GameTooltip:AddLine("• Захват: ход на клетку с кубиком врага", 1, 0.5, 0)
        GameTooltip:AddLine("  уничтожает его и занимает клетку", 1, 0.5, 0)
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Режимы игры:", 1, 0.82, 0)
        GameTooltip:AddLine("• Одиночная игра: откройте свое поле", 1, 1, 1)
        GameTooltip:AddLine("• Игра вдвоём: откройте поле соперника", 1, 1, 1)
        GameTooltip:AddLine("• Просмотр игры: ПКМ по кнопке", 0.5, 0.8, 1)
        GameTooltip:AddLine("• Первый ход определяется случайно", 1, 1, 1)
        GameTooltip:Show()
    end)

    self.gameStartButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- === КНОПКА: Основы луа ===
    self.luaBasicsButton = CreateFrame("Button", nil, self.frame)
    self.luaBasicsButton:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    self.luaBasicsButton:SetPoint("TOPRIGHT", self.gameStartButton, "BOTTOMRIGHT", 0, -5)
    self.luaBasicsButton:SetNormalTexture("Interface\\ICONS\\INV_Misc_Book_09")
    self.luaBasicsButton:SetPushedTexture("Interface\\ICONS\\INV_Misc_Book_09")
    self.luaBasicsButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

    self.luaBasicsButton:SetScript("OnClick", function()
        logic:ManageCourse()
    end)

    self.luaBasicsButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.luaBasicsButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Основы Lua", 1, 1, 1)
        
        -- Проверяем статус окна и меняем подсказку
        if _G.activeLuaCourse and _G.activeLuaCourse.window and _G.activeLuaCourse.window:IsShown() then
            GameTooltip:AddLine("Закрыть курс обучения", 1, 0.5, 0.5)
        else
            GameTooltip:AddLine("Открыть курс обучения", 0.5, 1, 0.5)
        end
        
        GameTooltip:Show()
    end)

    self.luaBasicsButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Кнопка крафта
    self.craftButton = CreateFrame("Button", nil, self.frame)
    self.craftButton:SetSize(CRAFT_BUTTON_SIZE, CRAFT_BUTTON_SIZE)
    self.craftButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
    self.craftButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
    self.craftButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    self.craftButton.icon = self.craftButton:CreateTexture(nil, "OVERLAY")
    self.craftButton.icon:SetTexture("Interface\\ICONS\\Trade_BlackSmithing")
    self.craftButton.icon:SetAllPoints()
    self.craftSettings = {
        active = false,
        visibleCells = {},
        enabledLocations = CRAFT_ENABLED_LOCATIONS
    }
    self.craftButton:SetScript("OnClick", function()
        self.craftSettings.active = not self.craftSettings.active
        self:UpdateCraftButtonState()
        ns_dbc:modKey("настройки", "CRAFT_ACTIVE", self.craftSettings.active)
    end)
    self.craftButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.craftButton, "ANCHOR_RIGHT")
        GameTooltip:SetText("Режим крафта")
        GameTooltip:AddLine("ЛКМ - активация/деактивация", 1,1,1)
        GameTooltip:Show()
    end)
    self.craftButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
    self.craftSettings.active = ns_dbc:getKey("настройки", "CRAFT_ACTIVE") or false
    self:UpdateCraftButtonState()
    
    -- Ручка изменения размера
    self.resizeHandle = CreateFrame("Button", nil, self.frame)
    self.resizeHandle:SetSize(16, 16)
    self.resizeHandle:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -40, 40)
    self.resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    self.resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    self.resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    self.resizeHandle:SetScript("OnMouseDown", function() self.frame:StartSizing("BOTTOMRIGHT") end)
    self.resizeHandle:SetScript("OnMouseUp", function() 
        self.frame:StopMovingOrSizing()
        local x, y = self:GetSize()
        ns_dbc:modKey("настройки", "mfldRX", x)
        self:AdjustSizeAndPosition()
    end)
    
    -- Обработчик изменения размера
    self.frame:SetScript("OnSizeChanged", function(_, width, height)
        if self.skipSizeCheck then
            self.skipSizeCheck = false
            return
        end
        width, height = self:CheckFrameSize(width, height)
        self.frame:SetSize(width, height)
        self:AdjustSizeAndPosition()
    end)
    
    -- Инициализация списка дочерних элементов
    self.children = {}
    return self
end

function AdaptiveFrame:UpdateCraftButtonState()
    -- Проверяем необходимые объекты
    if not self.craftButton or not self.textField then 
        return 
    end

    -- Получаем текущую локацию
    local currentLocation = self:GetCurrentLocation():match(WORD_POSITION_PATTERNS[1])
    local isLocationAllowed = self.craftSettings.enabledLocations[currentLocation] or false
    -- Управление видимостью кнопки
    if isLocationAllowed then
        self.craftButton:Show()
    else
        self.craftButton:Hide()
        if self.craftSettings then
            self.craftSettings.active = false
        end
    end

    -- Устанавливаем цвет и прозрачность
    if self.craftSettings then
        local color = self.craftSettings.active and CRAFT_BUTTON_COLOR_ACTIVE or CRAFT_BUTTON_COLOR_INACTIVE
        local alpha = self.craftSettings.active and CRAFT_BUTTON_ACTIVE_ALPHA or CRAFT_BUTTON_INACTIVE_ALPHA
        
        if self.craftButton.icon then
            self.craftButton.icon:SetVertexColor(unpack(color))
        end
        self.craftButton:SetAlpha(alpha)
    end

    -- Обновляем иконки крафта
    self:UpdateCraftIconsVisibility()
    
    -- Обновляем триггеры панели
    self:SetupPopupTriggers()
end

function AdaptiveFrame:GetCurrentLocation()
    if not self.textField or not self.textField.GetText then return "" end
    local headerText = self.textField:GetText() or ""
    
    if WORD_POSITION_PATTERNS and WORD_POSITION_PATTERNS[3] then
        if headerText:match(WORD_POSITION_PATTERNS[5]) then
            return headerText:match(WORD_POSITION_PATTERNS[3]) .. " " .. headerText:match(WORD_POSITION_PATTERNS[5])
        else
            return headerText:match(WORD_POSITION_PATTERNS[3]) or ""
        end
    end
    return ""
end

function AdaptiveFrame:SetCraftVisibleCells(cellIndices)
    self.craftSettings.visibleCells = {}
    for _, index in ipairs(cellIndices) do
        self.craftSettings.visibleCells[index] = true
    end
    self:UpdateCraftIconsVisibility()
end

function AdaptiveFrame:UpdateCraftIconsVisibility()
    local currentLocation = self:GetCurrentLocation()
    local isLocationAllowed = self.craftSettings.enabledLocations[currentLocation] or false
    
    -- Обновляем иконки только если локация разрешена и кнопка активна
    if isLocationAllowed then
        for cellIndex in pairs(self.craftSettings.visibleCells or {}) do
            local shouldShow = self.craftSettings.active
            self:SetCellIcon(cellIndex, shouldShow and "craft_icon" or nil, 5, currentLocation, shouldShow)
        end
    else
        -- Скрываем все иконки крафта если локация не разрешена
        for cellIndex in pairs(self.craftSettings.visibleCells or {}) do
            self:SetCellIcon(cellIndex, nil, 5)
        end
    end
end

function AdaptiveFrame:SetCraftEnabledLocations(locationsTable)
    self.craftSettings.enabledLocations = {}
    for location, enabled in pairs(locationsTable or {}) do
        self.craftSettings.enabledLocations[location] = enabled
    end
    self:UpdateCraftButtonState()
end

function AdaptiveFrame:SetText(text)
    if self.textField then
        self.textField:SetText(text or "")
        
        -- При изменении текста проверяем нужно ли обновить кнопку крафта
        self:UpdateCraftButtonState()
        
        -- Обновляем видимость всех иконок
        for cellIndex, child in ipairs(self.children or {}) do
            if child.icons then
                for corner in pairs(child.icons) do
                    self:UpdateIconVisibility(cellIndex, corner)
                end
            end
        end
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

-- Универсальная функция ожидания метода
local function WaitForMethodAndCall(obj, methodName, callback)
    -- Если метод уже существует, вызываем callback сразу
    if obj and obj[methodName] and type(obj[methodName]) == "function" then
        callback()
        return
    end

    -- Создаём временный фрейм для эмуляции таймера
    local frame = CreateFrame("Frame")
    frame:Hide()
    local elapsed = 0
    local interval = 5

    frame:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        if elapsed >= interval then
            elapsed = 0
            
            -- Проверяем наличие метода
            if obj and obj[methodName] and type(obj[methodName]) == "function" then
                -- Очистка таймера
                self:SetScript("OnUpdate", nil)
                self:Hide()
                callback()
            elseif not obj then
                -- Если объект был удалён (например, при перезагрузке UI), останавливаем проверку
                self:SetScript("OnUpdate", nil)
                self:Hide()
            end
        end
    end)
end
-- Метод для скрытия фрейма
function AdaptiveFrame:Hide()
    self.frame:Hide()

    -- Ждём, пока появится StopPlayerPositionTracking, и вызываем его
    WaitForMethodAndCall(self, "StopPlayerPositionTracking", function()
        self:StopPlayerPositionTracking()
    end)
end

-- Метод для отображения фрейма
function AdaptiveFrame:Show()
    self.frame:Show()
    self:AdjustSizeAndPosition()
    -- Запускаем отслеживание позиции игрока при показе фрейма
    --self:StartPlayerPositionTracking()
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
    local buttonsPerRow = 10
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
        end
    end
    
    if self.craftButton then
        self.craftButton:ClearAllPoints()
        self.craftButton:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -F_PAD+34, F_PAD)
        self.craftButton:SetFrameLevel(self.frame:GetFrameLevel() + 50)
    end
    -- ============================================================
    
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

function AdaptiveFrame:CreateSideFrame()
    if self.sideFrame then return end
    
    -- Увеличиваем дополнительные отступы
    self.sideTextHeight = 15
    self.sideTextPadding = 5
    self.scrollBarWidth = 16
    self.framePadding = 10
    self.textExtraSpace = 500  -- Увеличено с 10 до 25 для гарантии
    
    -- Главный фрейм
    self.sideFrame = CreateFrame("Frame", "MyAddonSideFrame", self.frame)
    self.sideFrame:SetFrameStrata("HIGH")
    self.sideFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = self.framePadding, right = self.framePadding, 
                 top = self.framePadding, bottom = self.framePadding }
    })
    self.sideFrame:SetBackdropColor(0, 0, 0, 1)
    self.sideFrame:SetBackdropBorderColor(0.8, 0.8, 0.8, 0.6)

    -- Фрейм для скроллинга с именем
    self.sideScrollFrame = CreateFrame("ScrollFrame", "MyAddonScrollFrame", self.sideFrame, "UIPanelScrollFrameTemplate")
    self.sideScrollFrame:SetPoint("TOPLEFT", self.framePadding, -self.framePadding)
    self.sideScrollFrame:SetPoint("BOTTOMRIGHT", -self.scrollBarWidth-self.framePadding, self.framePadding)

    -- Контентная область с запасом по ширине
    self.sideContent = CreateFrame("Frame", nil, self.sideScrollFrame)
    self.sideContent:SetSize(100, 100)
    self.sideScrollFrame:SetScrollChild(self.sideContent)

    -- Скроллбар
    self.sideScrollBar = _G[self.sideScrollFrame:GetName().."ScrollBar"]
    self.sideScrollBar.scrollStep = self.sideTextHeight + self.sideTextPadding
    
    self.sideTextLines = {}
    self:HideSideFrame()
end

function AdaptiveFrame:UpdateSideFrame()
    if not self.sideFrame or not self.sideFrame:IsShown() then 
        return 
    end
    
    local mainWidth, mainHeight = self.frame:GetSize()
    local maxTextWidth = 0
    local extraPadding = 40
    
    -- Сначала обновляем все тексты и находим максимальную ширину
    for _, lineFrame in ipairs(self.sideTextLines) do
        lineFrame.text:SetWidth(0) -- Сбрасываем ширину для корректного расчета
        local textWidth = lineFrame.text:GetStringWidth()
        maxTextWidth = math.max(maxTextWidth, textWidth)
    end
    
    -- Увеличиваем максимальную ширину на 30 пикселей для учета возможных итераторов
    maxTextWidth = maxTextWidth + 30
    
    -- Рассчитываем итоговые ширины
    local contentWidth = maxTextWidth + extraPadding
    local frameWidth = math.max(100, contentWidth)
    
    -- Устанавливаем размеры sideFrame
    self.sideFrame:SetSize(frameWidth, mainHeight)
    self.sideFrame:SetPoint("LEFT", self.frame, "RIGHT", 5, 0)
    
    -- Обновляем размер контента
    local totalHeight = #self.sideTextLines * (self.sideTextHeight + self.sideTextPadding)
    local visibleHeight = self.sideScrollFrame:GetHeight()
    self.sideContent:SetSize(frameWidth, math.max(totalHeight, visibleHeight))
    
    -- Настраиваем скроллбар
    self.sideScrollBar:SetMinMaxValues(0, math.max(0, totalHeight - visibleHeight))
    
    -- Позиционируем строки с учетом новой ширины
    for i, lineFrame in ipairs(self.sideTextLines) do
        lineFrame:ClearAllPoints()
        lineFrame:SetWidth(frameWidth - 20) -- Оставляем отступ для скроллбара
        lineFrame:SetHeight(self.sideTextHeight)
        local yOffset = -(i-1)*(self.sideTextHeight + self.sideTextPadding)
        lineFrame:SetPoint("TOPLEFT", self.sideContent, "TOPLEFT", 10, yOffset)
        
        lineFrame.text:SetWidth(frameWidth - 30) -- Устанавливаем ширину текста с запасом
        lineFrame.text:SetPoint("LEFT", lineFrame, "LEFT", 5, 0)
    end
end

function AdaptiveFrame:RemoveSideText(baseText)
    if not self.sideFrame or not self.sideTextLines then return 0 end
    
    local removedCount = 0
    baseText = baseText:gsub("%(%d+%)$", ""):trim()
    
    for i = #self.sideTextLines, 1, -1 do
        local lineText = self.sideTextLines[i].text:GetText()
        local lineBase = lineText:gsub("%(%d+%)$", ""):trim()
        
        if lineBase == baseText then
            self.sideTextLines[i]:Hide()
            table.remove(self.sideTextLines, i)
            removedCount = removedCount + 1
        end
    end
    
    if removedCount > 0 then
        self:UpdateSideFrame()
    end
    return removedCount
end

-- Модифицированный метод AddSideText
function AdaptiveFrame:AddSideText(text)
    if not self.sideFrame then self:CreateSideFrame() end
    
    -- Парсим базовое имя и счетчик
    local baseText = text:gsub("%(%d+%)$", ""):trim()
    local maxCount = 0
    local existingIndex = -1
    
    -- Ищем существующие строки с таким же базовым именем
    for i, lineFrame in ipairs(self.sideTextLines) do
        local lineText = lineFrame.text:GetText()
        local lineBase = lineText:gsub("%(%d+%)$", ""):trim()
        
        if lineBase == baseText then
            -- Извлекаем текущий счетчик
            local currentCount = tonumber(lineText:match("%((%d+)%)$")) or 1
            if currentCount > maxCount then
                maxCount = currentCount
                existingIndex = i
            end
        end
    end
    
    -- Если нашли существующую строку - обновляем ее
    if existingIndex ~= -1 then
        local lineFrame = self.sideTextLines[existingIndex]
        local newCount = maxCount + 1
        local newText = baseText .. "(" .. newCount .. ")"
        
        lineFrame.text:SetText(newText)
        self:UpdateSideFrame() -- Принудительно обновляем фрейм после изменения
        return
    end
    
    -- Если строка не найдена - добавляем новую
    local lineFrame = CreateFrame("Frame", nil, self.sideContent)
    lineFrame:SetSize(100, self.sideTextHeight)
    
    local line = lineFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    line:SetPoint("LEFT", lineFrame, "LEFT", 0, 0)
    line:SetJustifyH("LEFT")
    line:SetText(text)
    line:SetTextColor(1, 1, 1, 1)
    line:SetHeight(self.sideTextHeight)
    
    lineFrame:EnableMouse(true)
    lineFrame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            self:MoveLineUp(lineFrame)
        elseif button == "RightButton" then
            self:ShowDeleteConfirmation(lineFrame)
        end
    end)
    
    lineFrame.text = line
    table.insert(self.sideTextLines, 1, lineFrame)
    self:UpdateSideFrame()
end

-- Вспомогательный метод для парсинга текста и номера
function AdaptiveFrame:ParseExistingText(text)
    if not text then return nil, nil end
    
    -- Проверяем формат "текст(число)"
    local base, count = text:match("^(.-)%((%d+)%)$")
    if base and count then
        return base:trim(), tonumber(count)
    end
    
    -- Если нет числа в скобках - возвращаем исходный текст
    return text:trim(), 1
end

function AdaptiveFrame:MoveLineUp(lineFrame)
    for i, frame in ipairs(self.sideTextLines) do
        if frame == lineFrame and i > 1 then
            -- Меняем местами с предыдущей строкой
            self.sideTextLines[i], self.sideTextLines[i-1] = self.sideTextLines[i-1], self.sideTextLines[i]
            
            -- Обновляем текст (чтобы сохранить порядок)
            local tempText = lineFrame.text:GetText()
            lineFrame.text:SetText(self.sideTextLines[i-1].text:GetText())
            self.sideTextLines[i-1].text:SetText(tempText)
            
            self:UpdateSideFrame()
            break
        end
    end
end

-- Новый метод для показа подтверждения удаления
function AdaptiveFrame:ShowDeleteConfirmation(lineFrame)
    local textToDelete = lineFrame.text:GetText()
    
    StaticPopupDialogs["CONFIRM_DELETE_LINE"] = {
        text = "Вы хотите удалить \""..textToDelete.."\"?",
        button1 = "Да",
        button2 = "Нет",
        OnAccept = function()
            self:DeleteLine(lineFrame)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    
    StaticPopup_Show("CONFIRM_DELETE_LINE")
end

-- Метод для удаления строки
function AdaptiveFrame:DeleteLine(lineFrame)
    for i, frame in ipairs(self.sideTextLines) do
        if frame == lineFrame then
            frame:Hide()
            frame:SetParent(nil)
            table.remove(self.sideTextLines, i)
            self:UpdateSideFrame()
            break
        end
    end
end

-- Метод для показа бокового фрейма
function AdaptiveFrame:ShowSideFrame()
    if not self.sideFrame then self:CreateSideFrame() end
    self.sideFrame:Show()
    self:UpdateSideFrame()
end

-- Метод для скрытия бокового фрейма
function AdaptiveFrame:HideSideFrame()
    if self.sideFrame then
        self.sideFrame:Hide()
    end
end

function AdaptiveFrame:SetCellIcon(cellIndex, texture, corner, room, visible)
    -- Проверка клетки
    if not self.children or not self.children[cellIndex] then return end
    local cell = self.children[cellIndex]
    
    -- Инициализация таблицы иконок, если ее нет
    if not cell.icons then
        cell.icons = {}
    end
    
    -- Если текстура не указана - удаляем все иконки в указанном углу
    if not texture then
        if cell.icons[corner] then
            cell.icons[corner].texture = nil
            cell.icons[corner]:Hide()
            cell.icons[corner] = nil
        end
        return
    end
    
    -- Угол должен быть от 1 до 8
    corner = math.min(math.max(corner or 1, 1), 8)
    
    -- Создаем новую иконку, если ее еще нет
    if not cell.icons[corner] then
        cell.icons[corner] = cell.frame:CreateTexture(nil, "OVERLAY")
        cell.icons[corner]:SetSize(16, 16)
        
        local positions = {
            [1] = {"TOPLEFT", 5, -5},    [2] = {"TOP", 0, -5},
            [3] = {"TOPRIGHT", -5, -5},  [4] = {"RIGHT", -5, 0},
            [5] = {"BOTTOMRIGHT", -5, 5},[6] = {"BOTTOM", 0, 5},
            [7] = {"BOTTOMLEFT", 5, 5},  [8] = {"LEFT", 5, 0}
        }
        
        local pos = positions[corner]
        cell.icons[corner]:SetPoint(pos[1], cell.frame, pos[1], pos[2], pos[3])
    end
    
    -- Сохраняем метаданные об иконке
    cell.icons[corner].texture = texture
    cell.icons[corner].room = room and room:trim() or nil
    cell.icons[corner].forcedVisible = visible
    
    -- Обновляем видимость иконки
    self:UpdateIconVisibility(cellIndex, corner)
end

function AdaptiveFrame:UpdateIconVisibility(cellIndex, corner)
    if not self.children or not self.children[cellIndex] then return end
    local cell = self.children[cellIndex]
    if not cell.icons or not cell.icons[corner] then return end
    
    local icon = cell.icons[corner]
    local headerText = self.textField:GetText() or ""
    local currentRoom = headerText:match(".-%-(.*)") and headerText:match(".-%-(.*)"):trim() or ""
    
    -- Определяем, должна ли иконка быть видимой
    local shouldShow = true
    
    -- Если явно указана видимость - используем ее
    if icon.forcedVisible ~= nil then
        shouldShow = icon.forcedVisible
    -- Иначе проверяем соответствие комнаты
    elseif icon.room and icon.room ~= currentRoom then
        shouldShow = false
    end
    
    -- Устанавливаем видимость
    if shouldShow then
        icon:SetTexture("Interface\\AddOns\\NSQC3\\libs\\"..icon.texture..".tga")
        icon:Show()
    else
        icon:Hide()
    end
end

-- Метод для получения количества объектов в инвентаре по базовому имени
function AdaptiveFrame:GetSideTextCount(baseText)
    if not self.sideFrame or not self.sideTextLines then return 0 end
    
    local totalCount = 0
    baseText = baseText:gsub("%(%d+%)$", ""):trim()
    
    for _, lineFrame in ipairs(self.sideTextLines) do
        local lineText = lineFrame.text:GetText()
        local lineBase = lineText:gsub("%(%d+%)$", ""):trim()
        
        if lineBase == baseText then
            -- Извлекаем число из скобок, если есть
            local count = tonumber(lineText:match("%((%d+)%)$")) or 1
            totalCount = totalCount + count
        end
    end
    
    return totalCount
end

function AdaptiveFrame:HideAllCellTexts()
    for cellIndex, child in ipairs(self.children or {}) do
        if child and child.SetTextT then
            child:SetTextT("")  -- Устанавливаем пустой текст
        end
    end
end

function AdaptiveFrame:SetupPopupTriggers()
    -- Проверяем наличие таблицы триггеров
    if not ns_triggers then return end
    
    -- Создаем панель только если она еще не существует
    if not self.popupPanel then
        self.popupPanel = PopupPanel:Create(50, 50, 6, 0)
        if not self.popupPanel then return end
    end

    -- Функция для создания триггера по текстуре
    local function createTextureTrigger(triggerKey)
        return function(parentButton)
            -- Получаем текущий скрипт OnEnter (если есть)
            local oldOnEnter = parentButton:GetScript("OnEnter")
            local oldOnLeave = parentButton:GetScript("OnLeave")
            
            local texture = parentButton:GetNormalTexture()
            if not texture then return false end
            
            local texturePath = texture:GetTexture()
            if not texturePath then return false end
            
            -- Получаем только имя файла текстуры (последнюю часть пути)
            local textureFile = texturePath:match("[^\\]+$") or ""
            -- Сравниваем только последние 3 символа
            local shortTexture = textureFile:sub(-3)
            
            if shortTexture == triggerKey and ns_triggers[triggerKey] then
                local cellIndex
                -- Находим индекс клетки по фрейму
                for i = 1, #(self.children or {}) do
                    if self.children[i] and self.children[i].frame == parentButton then
                        cellIndex = i
                        break
                    end
                end
                if not cellIndex then return false end
                
                local buttonDataList = {}
                local craftModeActive = self.craftSettings and self.craftSettings.active or false
                
                -- Формируем данные для кнопок
                for btnTexture, btnData in pairs(ns_triggers[triggerKey]) do
                    -- Проверяем флаг craft (если есть)
                    local isCraftAction = type(btnData) == "table" and btnData.craft or false
                    
                    -- Показываем кнопку если:
                    -- 1. Режим крафта ВКЛ и действие для крафта
                    -- 2. Режим крафта ВЫКЛ и действие НЕ для крафта
                    if (craftModeActive and isCraftAction) or (not craftModeActive and not isCraftAction) then
                        local func, tooltip
                        
                        -- Извлекаем ключ текстуры (последние 3 символа)
                        local btnTextureKey = btnTexture:match("[^\\]+$"):sub(-3)
                        
                        if type(btnData) == "function" then
                            -- Обертываем функцию для передачи cellIndex и textureKey
                            func = function() 
                                btnData(cellIndex, btnTextureKey) 
                            end
                            tooltip = "Действие"
                        elseif type(btnData) == "table" then
                            -- Обертываем функцию из таблицы с передачей флага craft
                            func = function() 
                                btnData.func(cellIndex, btnTextureKey, btnData.craft) 
                            end
                            tooltip = btnData.tooltip
                        end
                        
                        if func then
                            table.insert(buttonDataList, {
                                texture = btnTexture,
                                func = func,
                                tooltip = tooltip or "Действие: " .. btnTextureKey
                            })
                        end
                    end
                end
                
                if #buttonDataList > 0 then
                    -- Восстанавливаем старые обработчики тултипов
                    if oldOnEnter then
                        parentButton:SetScript("OnEnter", function(self)
                            oldOnEnter(self)
                        end)
                    end
                    
                    if oldOnLeave then
                        parentButton:SetScript("OnLeave", function(self)
                            oldOnLeave(self)
                        end)
                    end
                    
                    return true, buttonDataList
                end
            end
            
            return false
        end
    end
    
    -- Собираем все уникальные триггеры
    local allTriggers = {}
    for textureKey in pairs(ns_triggers) do
        table.insert(allTriggers, createTextureTrigger(textureKey))
    end
    
    -- Обновляем триггеры для всех клеток
    for i = 1, #(self.children or {}) do
        if self.children[i] and self.children[i].frame then
            local frame = self.children[i].frame
            local oldOnEnter = frame:GetScript("OnEnter")
            local oldOnLeave = frame:GetScript("OnLeave")
            
            -- Добавляем панель
            self.popupPanel:Show(frame, allTriggers)
            
            -- Восстанавливаем скрипты после добавления панели
            if oldOnEnter then
                frame:SetScript("OnEnter", function(self)
                    oldOnEnter(self)
                end)
            end
            
            if oldOnLeave then
                frame:SetScript("OnLeave", function(self)
                    oldOnLeave(self)
                end)
            end
        end
    end
end

function AdaptiveFrame:AnimateTextureAcrossCells(durationPerCell)
    durationPerCell = durationPerCell or 0.4

    if not self.children or #self.children < 2 then 
        print("|cFFFF0000[Анимация]|r Для анимации необходимо минимум 2 клетки.")
        return 
    end

    local totalCells = math.min(100, #self.children)

    -- Создаём текстуру
    local movingTex = UIParent:CreateTexture(nil, "OVERLAY")
    movingTex:SetSize(32, 32)
    movingTex:SetTexture("Interface\\AddOns\\NSQC3\\libs\\bbb.tga")
    movingTex:SetAlpha(1)
    movingTex:SetDrawLayer("OVERLAY")

    -- Вспомогательная функция получения центра клетки
    local function GetCellCenter(cellIndex)
        local cell = self.children[cellIndex]
        if not cell or not cell.frame then return 0, 0 end
        local cx, cy = cell.frame:GetCenter()
        if not cx then return 0, 0 end
        return cx, cy
    end

    -- Безопасная инициализация координат
    local startX, startY = GetCellCenter(1)
    local endX, endY = GetCellCenter(2)

    -- Если фрейм ещё не отрисован и координаты нулевые, прерываем выполнение
    if startX == 0 and startY == 0 then
        print("|cFFFF0000[Анимация]|r Не удалось получить координаты. Убедитесь, что фрейм виден на экране.")
        return
    end

    movingTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", startX, startY)

    -- Фрейм для анимации
    local animFrame = CreateFrame("Frame")
    animFrame:Hide()

    local currentIndex = 1
    local progress = 0

    animFrame:SetScript("OnUpdate", function(_, elapsed)
        progress = progress + (elapsed / durationPerCell)

        if progress >= 1 then
            progress = 1
            movingTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", endX, endY)

            currentIndex = currentIndex + 1
            if currentIndex >= totalCells then
                animFrame:SetScript("OnUpdate", nil)
                animFrame:Hide()
                print("|cFF00FF00[Анимация]|r Текстура остановлена на клетке " .. totalCells)
                return
            end

            startX, startY = endX, endY
            endX, endY = GetCellCenter(currentIndex + 1)
            progress = 0
        else
            -- Линейная интерполяция
            local x = startX + (endX - startX) * progress
            local y = startY + (endY - startY) * progress
            movingTex:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
        end
    end)

    animFrame:Show()
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
        button:SetScript("OnClick", function()
            -- Сначала вызываем оригинальную функцию
            if data.func then
                data.func()
            end
            
            -- Затем скрываем панель
            self.panel:Hide()
            
            -- Дополнительно скрываем тултип
            GameTooltip:Hide()
        end)

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
    local private = {
        storage = {},
    }
    
    local obj = setmetatable({
        getArg = function(self, index)
            return private.storage[index]
        end,
        
        setArg = function(self, index, value)
            private.storage[index] = value 
        end,
        
        ls = function(self, l_s)
            self:setArg("ls", l_s)
        end,
        
    }, self)
    
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

-- Шаблон для доступа к номеру элемента без пробелов
OBJECT_POSITION_PATTERNS = {}
for i = 1, 100 do  -- Важно: цикл до 100, а не 10!
    OBJECT_POSITION_PATTERNS[i] = "^" .. string.rep("...", i - 1) .. "(...)"
end
-- Предопределенные шаблоны для поиска по позициям слов
WORD_POSITION_PATTERNS = {}
for i = 1, 10 do -- Поддерживаем до 10 позиций
    WORD_POSITION_PATTERNS[i] = "^"..string.rep("%S*%s+", i-1).."(%S+)"
end
WORD_POSITION_LAST = "(%S+)$"
WORD_POSITION_NOLAST = "^%s*(.-)%f[%w]%w+%s*$"
WORD_POSITION_MIDDLE = "^%S+%s+(.+[^%s])%s+%S+$"

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
function NSQCMenu:addSubMenu(menuName, parentMenu)
    -- Определяем родительское меню (по умолчанию - self)
    parentMenu = parentMenu or self
    
    -- Создаем уникальное имя для фрейма
    local frameName = self.addonName..menuName.."SubFrame"
    
    -- Создаем основной фрейм подменю
    local subFrame = CreateFrame("Frame", frameName, InterfaceOptionsFramePanelContainer)
    subFrame.name = menuName
    subFrame.parent = parentMenu.addonName or parentMenu.name
    subFrame:Hide()
    
    -- Создаем ScrollFrame
    local scrollFrame = CreateFrame("ScrollFrame", frameName.."ScrollFrame", subFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)
    
    -- Создаем контент для скролла
    local scrollContent = CreateFrame("Frame", frameName.."ScrollContent", scrollFrame)
    scrollContent:SetWidth(scrollFrame:GetWidth() - 20)
    scrollContent:SetHeight(1) -- Начальная высота
    scrollFrame:SetScrollChild(scrollContent)
    
    -- Настраиваем скроллбар
    local scrollBar = _G[frameName.."ScrollFrameScrollBar"]
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 12, -16)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 12, 16)
    
    -- Заголовок подменю
    local title = subFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(menuName)
    
    -- Регистрируем подменю в интерфейсе WoW
    InterfaceOptions_AddCategory(subFrame)
    
    -- Создаем объект подменю
    local subMenu = {
        frame = subFrame,
        scrollFrame = scrollFrame,
        scrollContent = scrollContent,
        elements = {},
        lastY = 0,
        totalHeight = 0,
        maxHeight = scrollFrame:GetHeight(),
        parent = parentMenu,
        name = menuName
    }
    
    -- Добавляем подменю в список
    table.insert(self.subMenus, subMenu)
    
    return subMenu
end

function NSQCMenu:showSubMenu(subMenu)
    if subMenu.parent then
        subMenu.parent.frame:Hide()
    end
    subMenu.frame:Show()
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

-- Метод для добавления кнопки
function NSQCMenu:addButton(parentMenu, options)
    -- Создаем кнопку
    local button = CreateFrame("Button", parentMenu.frame:GetName()..options.name, parentMenu.scrollContent, "UIPanelButtonTemplate")
    button:SetPoint("TOPLEFT", 16, -parentMenu.lastY)
    button:SetSize(options.width or 120, options.height or 24) -- Размеры кнопки (по умолчанию 120x24)
    button:SetText(options.label or "Кнопка") -- Текст на кнопке

    -- Обработчик нажатия
    button:SetScript("OnClick", function(self)
        if options.onClick then
            options.onClick() -- Вызываем пользовательскую функцию
        end
    end)

    -- Добавляем тултип, если указан
    if options.tooltip then
        button.tooltipText = options.tooltip
        button:SetScript("OnEnter", function(self)
            if self.tooltipText then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self.tooltipText, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        button:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    -- Обновляем высоту контента
    parentMenu.lastY = parentMenu.lastY + (options.height or 24) + 10 -- Добавляем отступ
    parentMenu.totalHeight = parentMenu.totalHeight + (options.height or 24) + 10
    parentMenu.scrollContent:SetHeight(parentMenu.totalHeight)

    -- Добавляем кнопку в список элементов
    table.insert(parentMenu.elements, button)

    -- Обновляем диапазон прокрутки
    self:updateScrollRange(parentMenu)

    return button
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
-- questUI = QuestUI:Create(UIParent)
-- questUI:SetQuestText("Новый текст квеста с интерактивными элементами")
-- questUI:AddItem("Меч героя", function() print("Меч выбран!") end)
-- questUI:AddLocationItem("Сундук", function() print("Сундук открыт!") end)
-- questUI:AddAction("Атаковать", function() print("Атака!") end)
-- questUI:Show()


QuestManagerClient = {}
QuestManagerClient.__index = QuestManagerClient

function QuestManagerClient:new()
    local obj = setmetatable({}, self)
    obj.questData = {}
    return obj
end

function QuestManagerClient:CreateQuestWindow()
    -- Создаем основное окно
    self.questWindow = CreateFrame("Frame", "QuestTrackerWindow", UIParent)
    self.questWindow:SetFrameStrata("DIALOG")
    self.questWindow:SetSize(400, 500)
    self.questWindow:SetPoint("LEFT", 5, 100)
    self.questWindow:SetMovable(true)
    self.questWindow:EnableMouse(true)
    self.questWindow:RegisterForDrag("LeftButton")
    self.questWindow:SetScript("OnDragStart", self.questWindow.StartMoving)
    self.questWindow:SetScript("OnDragStop", function()
        self.questWindow:StopMovingOrSizing()
        -- добавить сохранение позиции
    end)
    self.questWindow:Hide()

    -- Черный непрозрачный фон
    self.questWindow.background = self.questWindow:CreateTexture(nil, "BACKGROUND")
    self.questWindow.background:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.questWindow.background:SetVertexColor(0, 0, 0, 1)
    self.questWindow.background:SetAllPoints(true)

    -- Граница окна
    self.questWindow.border = CreateFrame("Frame", nil, self.questWindow)
    self.questWindow.border:SetPoint("TOPLEFT", -3, 3)
    self.questWindow.border:SetPoint("BOTTOMRIGHT", 3, -3)
    self.questWindow.border:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })

    -- Заголовок окна
    self.questWindow.title = self.questWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.questWindow.title:SetPoint("TOP", 0, -15)
    self.questWindow.title:SetText("Трекер квестов")

    -- Кнопка закрытия
    self.questWindow.closeButton = CreateFrame("Button", nil, self.questWindow, "UIPanelCloseButton")
    self.questWindow.closeButton:SetPoint("TOPRIGHT", -5, -5)
    self.questWindow.closeButton:SetScript("OnClick", function()
        self.questWindow:Hide()
    end)

    -- Область с прокруткой
    self.questWindow.scrollFrame = CreateFrame("ScrollFrame", "QuestTrackerScrollFrame", self.questWindow, "UIPanelScrollFrameTemplate")
    self.questWindow.scrollFrame:SetPoint("TOPLEFT", 10, -40)
    self.questWindow.scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)
    
    -- Ползунок прокрутки
    self.questWindow.scrollBar = _G["QuestTrackerScrollFrameScrollBar"]
    self.questWindow.scrollBar:SetValue(0)

    -- Дочерний фрейм с поддержкой HTML
    self.questWindow.scrollChild = CreateFrame("SimpleHTML", "QuestTrackerHTML", self.questWindow.scrollFrame)
    self.questWindow.scrollChild:SetWidth(360)
    self.questWindow.scrollFrame:SetScrollChild(self.questWindow.scrollChild)

    -- Настройка HTML-текста
    self.questWindow.scrollChild:SetPoint("TOPLEFT", 5, -5)
    self.questWindow.scrollChild:SetWidth(350)
    self.questWindow.scrollChild:SetFontObject("GameFontNormal")
    self.questWindow.scrollChild:SetSpacing(3)
    self.questWindow.scrollChild:SetText("")

    -- Обработчики для интерактивных ссылок
    self.questWindow.scrollChild:SetScript("OnHyperlinkEnter", function(_, link, text)
        if link:find("^achievement:") then
            self.currentAchievementID = tonumber(link:match("achievement:(%d+)"))
            GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink("|H"..link.."|h["..text.."]|h")
            GameTooltip:Show()
        end
    end)

    self.questWindow.scrollChild:SetScript("OnHyperlinkLeave", function()
        GameTooltip:Hide()
    end)

    self.questWindow.scrollChild:SetScript("OnHyperlinkClick", function(_, link, text, button)
        if link:find("^achievement:") then
            self.currentAchievementID = tonumber(link:match("achievement:(%d+)"))
            
            if IsShiftKeyDown() then
                ChatEdit_InsertLink(text)
                return
            end

            local success, err = pcall(function()
                if not AchievementFrame then
                    LoadAddOn("Blizzard_AchievementUI")
                end
                
                if AchievementFrame then
                    AchievementFrame_Show()
                    AchievementFrame_SelectAchievement(self.currentAchievementID)
                else
                    OpenAchievementFrame(self.currentAchievementID)
                end
            end)
            
            if not success then
                GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
                GameTooltip:SetHyperlink("|H"..link.."|h["..text.."]|h")
                GameTooltip:Show()
            end
        end
    end)

    -- Кнопка принятия квеста
    self.questWindow.acceptButton = CreateFrame("Button", nil, self.questWindow, "UIPanelButtonTemplate")
    self.questWindow.acceptButton:SetSize(120, 25)
    self.questWindow.acceptButton:SetPoint("BOTTOMLEFT", 10, 10)
    self.questWindow.acceptButton:SetText("Принять")
    self.questWindow.acceptButton:SetScript("OnClick", function()
        if self.questWindow.title:GetText() == "Хижина" then
            if self.currentAchievementID then
                local link = GetAchievementLink(self.currentAchievementID)
                if link then
                    SendChatMessage("Принята ачивка: "..link, "OFFICER")
                else
                    print("Ошибка: не удалось получить ссылку на ачивку")
                end
            else
                print("Ошибка: ID ачивки не установлен")
            end
        end
        if self.questWindow.title:GetText() == "Бонус" then
            SendChatMessage("Мне нужно прислать шефу: " .. self.bonusQuestItemName .. " " .. self.bonusQuestItemCount .. " штук", "OFFICER")
        end
        self.questWindow:Hide()
    end)

    -- Кнопка отказа от квеста
    self.questWindow.declineButton = CreateFrame("Button", nil, self.questWindow, "UIPanelButtonTemplate")
    self.questWindow.declineButton:SetSize(120, 25)
    self.questWindow.declineButton:SetPoint("BOTTOMRIGHT", -10, 10)
    self.questWindow.declineButton:SetText("Отказаться")
    self.questWindow.declineButton:SetScript("OnClick", function()
        if self.questWindow.title:GetText() == "Хижина" then
            SendChatMessage("Я злонамеренно отказываюсь от выполнения ачивки: " .. GetAchievementLink(tonumber(self.currentAchievementID)), "OFFICER")
            SendAddonMessage("ns_achiv00h_decline ", "achievementID", "guild")
        end

        if self.questWindow.title:GetText() == "Бонус" then
            SendChatMessage("Я отказываюсь от квеста на добровольное отдание вот этого: " .. self.bonusQuestItemName .. " " .. self.bonusQuestItemCount .. " штук", "OFFICER")
            SendAddonMessage("ns_bonusQuestX ", "", "guild")
        end
        self.questWindow:Hide()
    end)

    -- Кнопка просмотра ачивки
    self.questWindow.viewAchievementBtn = CreateFrame("Button", nil, self.questWindow, "UIPanelButtonTemplate")
    self.questWindow.viewAchievementBtn:SetSize(150, 25)
    self.questWindow.viewAchievementBtn:SetPoint("BOTTOM", 0, 40)
    self.questWindow.viewAchievementBtn:SetText("Просмотр ачивки")
    self.questWindow.viewAchievementBtn:Hide()
    self.questWindow.viewAchievementBtn:SetScript("OnClick", function()
        if self.currentAchievementID then
            if not AchievementFrame then
                LoadAddOn("Blizzard_AchievementUI")
            end
            if AchievementFrame then
                AchievementFrame_Show()
                AchievementFrame_SelectAchievement(self.currentAchievementID)
            end
        end
    end)
end

function QuestManagerClient:ShowQuest(questTitle, questText)
    if not self.questWindow then
        self:CreateQuestWindow()
    end

    -- Устанавливаем текст
    self.questWindow.title:SetText(questTitle or "Новый квест")
    self.questWindow.scrollChild:SetText(questText or "Описание квеста...")

    -- Парсим ID ачивки из текста
    self.currentAchievementID = nil
    if questText then
        local achievementID = questText:match("achievement:(%d+)")
        if achievementID then
            self.currentAchievementID = tonumber(achievementID)
            self.questWindow.viewAchievementBtn:Hide() -- Показываем кнопку просмотра
        else
            self.questWindow.viewAchievementBtn:Hide() -- Скрываем кнопку просмотра
        end
    end

    -- Рассчитываем высоту
    local lineCount = select(2, string.gsub(questText or "", "\n", "")) + 1
    local approxHeight = lineCount * 15 + 20
    
    self.questWindow.scrollChild:SetHeight(approxHeight)
    self.questWindow.scrollFrame:UpdateScrollChildRect()
    self.questWindow.scrollFrame:SetVerticalScroll(0)

    self.questWindow:Show()
end

function QuestManagerClient:ShowBonusQuest(itemName, itemCount)
    if not self.questWindow then
        self:CreateQuestWindow()
    end

    -- Сохраняем данные в отдельные переменные класса
    self.bonusQuestItemName = itemName or ""
    self.bonusQuestItemCount = itemCount or ""
    self.currentQuestTitle = "Бонус"
    
    -- Форматируем текст с цветами и ссылками
    local mainText = "Мне нужно прислать Шефу:"
    local instructionText = "(Переместить на почту нужное количество. Появится новая большая кнопка. Нажать ее.)"
    local formattedText = mainText .. " \n\n"
    
    -- Добавляем ссылку на предмет (если есть название)
    if self.bonusQuestItemName and self.bonusQuestItemName ~= "" then
        local itemName = self.bonusQuestItemName:gsub("^%s*(.-)%s*$", "%1") -- Удаляем лишние пробелы
        local itemLink, itemID, itemRarity, itemColor
        
        -- Поиск предмета в сумках
        for bag = 0, NUM_BAG_SLOTS do
            for slot = 1, GetContainerNumSlots(bag) do
                local _, _, _, quality, _, _, link = GetContainerItemInfo(bag, slot)
                if link then
                    local name = GetItemInfo(link)
                    if name and name:find(itemName) then
                        itemLink = link
                        itemID = tonumber(link:match("item:(%d+)"))
                        itemRarity = quality
                        break
                    end
                end
            end
            if itemLink then break end
        end
        
        -- Если предмет не найден в сумках, ищем по имени
        if not itemLink then
            for id = 1, 50000 do -- Ограниченный диапазон
                local name, link, rarity = GetItemInfo(id)
                if name and name:find(itemName) then
                    itemLink = link
                    itemID = id
                    itemRarity = rarity
                    break
                end
            end
        end
        
        -- Получаем цвет по редкости предмета
        if itemRarity then
            itemColor = select(4, GetItemQualityColor(itemRarity))
        else
            itemColor = "|cFFFFFFFF" -- Белый, если качество неизвестно
        end
        
        if itemLink then
            formattedText = formattedText .. itemColor .. "|Hitem:"..itemID.."|h["..itemName.."]|h|r "
        else
            formattedText = formattedText .. itemName .. " "
        end
    end
    
    -- Добавляем количество с цветом
    if self.bonusQuestItemCount and self.bonusQuestItemCount ~= "" then
        formattedText = formattedText .. "|cff99ff99" .. self.bonusQuestItemCount .. "|r штук\n\n"
    else
        formattedText = formattedText .. "\n\n"
    end
    
    -- Добавляем инструкцию с цветом
    formattedText = formattedText .. "|cFF6495ED" .. instructionText .. "|r"
    
    -- Устанавливаем текст в окно
    self.questWindow.title:SetText(self.currentQuestTitle)
    self.questWindow.scrollChild:SetText(formattedText)
    
    -- Обработчики для всплывающих подсказок
    self.questWindow.scrollChild:SetScript("OnHyperlinkEnter", function(_, link, text)
        local type, id = link:match("^(.-):(%-?%d+)")
        if type == "item" then
            GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
            GameTooltip:SetHyperlink(link)
            GameTooltip:Show()
        end
    end)

    self.questWindow.scrollChild:SetScript("OnHyperlinkLeave", GameTooltip_Hide)
    self.questWindow.scrollChild:SetScript("OnHyperlinkClick", function(_, link, text, button)
        if IsShiftKeyDown() then
            ChatEdit_InsertLink(text)
        end
    end)
    
    -- Рассчитываем высоту
    local lineCount = select(2, string.gsub(formattedText or "", "\n", "")) + 1
    local approxHeight = lineCount * 15 + 20
    
    self.questWindow.scrollChild:SetHeight(approxHeight)
    self.questWindow.scrollFrame:UpdateScrollChildRect()
    self.questWindow.scrollFrame:SetVerticalScroll(0)
    
    -- Показываем кнопки
    self.questWindow.acceptButton:Show()
    self.questWindow.declineButton:Show()
    self.questWindow.viewAchievementBtn:Hide()
    
    self.questWindow:Show()
end

function QuestManagerClient:Hide()
    if self.questWindow then
        self.questWindow:Hide()
    end
end

function QuestManagerClient:GetRandomProfessionSkill()
    -- Table of professions we're interested in
    local targetProfessions = {
        "Наложение чар",
        "Горное дело",
        "Алхимия",
        "Травничество",
        "Снятие шкур"
    }
    
    local foundProfessions = {}
    
    -- Check all skill lines (assuming there are no more than 20 skill lines)
    for i = 1, 20 do
        local name, _, _, currentLevel = GetSkillLineInfo(i)
        if name and currentLevel then
            -- Check if this is one of our target professions
            for _, profName in ipairs(targetProfessions) do
                if name == profName then
                    table.insert(foundProfessions, {
                        name = name,
                        level = currentLevel
                    })
                    break
                end
            end
        end
    end
    
    -- If we found any matching professions
    if #foundProfessions > 0 then
        -- Select a random profession from those found
        local randomProf = foundProfessions[math.random(1, #foundProfessions)]
        SendAddonMessage("ns_myBonusQuest " .. randomProf.level, randomProf.name, "GUILD")
        return
    else
        SendAddonMessage("ns_myBonusQuest ", "отсутствует", "GUILD")
        return
    end
    
    -- Return nil if no matching professions were found
    return nil, 0
end

function AdaptiveFrame:InitSnakeGame()
    self.snakeGame = {
        active = false,
        headPos = nil,
        body = {},
        direction = nil,
        score = 0,
        timerFrame = nil,
        speed = 0.3,
        originalBindings = {},
        macroFrames = {}
    }
end

function AdaptiveFrame:StartSnakeGame()
    -- Отладочный вывод начала запуска
    
    -- Проверка активности игры
    if self.snakeGame and self.snakeGame.active then 
        return 
    end

    -- Инициализация при первом запуске
    if not self.snakeGame then 
        self:InitSnakeGame() 
    end

    -- 1. Сохраняем ВСЕ текущие привязки клавиш
    self.snakeGame.originalBindings = {}
    
    for i = 1, GetNumBindings() do
        local command, key1, key2 = GetBinding(i)
        if command and (key1 or key2) then
            self.snakeGame.originalBindings[command] = {key1, key2}
        end
    end

    -- 2. Создаем макросы управления
    self:CreateSnakeMacros()

    -- 3. Устанавливаем новые привязки для стрелок
    local keyBindings = {
        ["UP"]        = "SnakeMacroUp",
        ["DOWN"]      = "SnakeMacroDown",
        ["LEFT"]      = "SnakeMacroLeft",
        ["RIGHT"]     = "SnakeMacroRight",
        ["ARROWUP"]   = "SnakeMacroUp",
        ["ARROWDOWN"] = "SnakeMacroDown",
        ["ARROWLEFT"] = "SnakeMacroLeft",
        ["ARROWRIGHT"]= "SnakeMacroRight",
        ["NUMPAD8"]   = "SnakeMacroUp",
        ["NUMPAD2"]   = "SnakeMacroDown",
        ["NUMPAD4"]   = "SnakeMacroLeft",
        ["NUMPAD6"]   = "SnakeMacroRight",
        ["W"]         = "SnakeMacroUp",    -- WASD для удобства
        ["S"]         = "SnakeMacroDown",
        ["A"]         = "SnakeMacroLeft",
        ["D"]         = "SnakeMacroRight"
    }

    local bindSuccess = 0
    local bindTotal = 0
    
    for key, macro in pairs(keyBindings) do
        bindTotal = bindTotal + 1
        local success = SetBinding(key, "CLICK "..macro..":LeftButton")
        
        if success then
            bindSuccess = bindSuccess + 1
        end
    end

    -- 4. Сохраняем привязки и проверяем результат
    SaveBindings(GetCurrentBindingSet())

    -- 5. Проверка установленных привязок
    local checkKeys = {"UP", "DOWN", "LEFT", "RIGHT", "W", "S", "A", "D"}
    for _, key in ipairs(checkKeys) do
        local action = GetBindingAction(key)
    end

    -- 6. Запуск игрового процесса
    local startPos = math.random(1, 100)
    self.snakeGame.headPos = startPos
    self.snakeGame.body = {startPos}
    self.snakeGame.direction = nil
    self.snakeGame.score = 1
    self.snakeGame.active = true
    
    -- Устанавливаем текстуру головы змейки
    self.children[startPos].frame:SetNormalTexture("Interface\\AddOns\\NSQC3\\libs\\bbb.tga")
    
    -- 7. Финальные сообщения
    print("|cFF00FF00Бобер выходит на тропу войны!|r Используйте |cFFFFA500WASD|r или |cFFFFA500стрелки|r для управления")
end

function AdaptiveFrame:CreateSnakeMacros()
    self:DeleteSnakeMacros()

    local directions = {
        {name = "Up", func = "SnakeUp"},
        {name = "Down", func = "SnakeDown"},
        {name = "Left", func = "SnakeLeft"},
        {name = "Right", func = "SnakeRight"}
    }

    for _, dir in ipairs(directions) do
        local macroName = "SnakeMacro"..dir.name
        local macroFrame = CreateFrame("Button", macroName, UIParent, "SecureActionButtonTemplate")
        
        macroFrame:SetAttribute("type", "macro")
        macroFrame:SetAttribute("macrotext", "/run adaptiveFrame:"..dir.func.."()")
        macroFrame:RegisterForClicks("AnyUp")
        
        macroFrame:SetScript("PreClick", function() 
        end)
        
        self.snakeGame.macroFrames[dir.name] = macroFrame
    end
end

function AdaptiveFrame:DeleteSnakeMacros()
    if not self.snakeGame.macroFrames then return end
    
    for dir, frame in pairs(self.snakeGame.macroFrames) do
        if frame then
            frame:Hide()
            frame:SetParent(nil)
        end
    end
    self.snakeGame.macroFrames = {}
end

function AdaptiveFrame:RegisterSnakeKeyBindings()
    -- Регистрируем глобальные обработчики
    _G["ADAPTIVEFRAME_SNAKE_UP"] = function()
        if self.snakeGame and self.snakeGame.active then
            self:SnakeUp()
        end
    end
    
    _G["ADAPTIVEFRAME_SNAKE_DOWN"] = function()
        if self.snakeGame and self.snakeGame.active then
            self:SnakeDown()
        end
    end
    
    _G["ADAPTIVEFRAME_SNAKE_LEFT"] = function()
        if self.snakeGame and self.snakeGame.active then
            self:SnakeLeft()
        end
    end
    
    _G["ADAPTIVEFRAME_SNAKE_RIGHT"] = function()
        if self.snakeGame and self.snakeGame.active then
            self:SnakeRight()
        end
    end
    
    -- Регистрируем кнопки для клика
    for _, cmd in ipairs({"UP", "DOWN", "LEFT", "RIGHT"}) do
        local action = "ADAPTIVEFRAME_SNAKE_"..cmd
        SetBindingClick(action, action)
    end
end

function AdaptiveFrame:RestoreOriginalKeyBindings()
    if not self.snakeGame or not self.snakeGame.originalKeyBindings then return end

    -- Восстанавливаем оригинальные привязки
    for key, binding in pairs(self.snakeGame.originalKeyBindings) do
        if binding then
            SetBinding(binding, key)
        else
            -- Если привязки не было, очищаем
            local currentBinding = GetBindingKey(key)
            if currentBinding then
                SetBinding(currentBinding)
            end
        end
    end

    -- Очищаем наши обработчики
    _G["ADAPTIVEFRAME_SNAKE_UP"] = nil
    _G["ADAPTIVEFRAME_SNAKE_DOWN"] = nil
    _G["ADAPTIVEFRAME_SNAKE_LEFT"] = nil
    _G["ADAPTIVEFRAME_SNAKE_RIGHT"] = nil

    -- Сохраняем изменения
    SaveBindings(GetCurrentBindingSet())
end

function AdaptiveFrame:StopSnakeGame(success)
    if not self.snakeGame or not self.snakeGame.active then return end
    
    -- Восстанавливаем ВСЕ оригинальные привязки
    local restoreSuccess = 0
    local restoreTotal = 0
    
    for command, keys in pairs(self.snakeGame.originalBindings) do
        if command and keys then
            restoreTotal = restoreTotal + 1
            -- Удаляем текущие привязки для этой команды
            local current1, current2 = GetBindingKey(command)
            if current1 then SetBinding(current1) end
            if current2 then SetBinding(current2) end
            
            -- Восстанавливаем оригинальные
            if keys[1] and SetBinding(keys[1], command) then
                restoreSuccess = restoreSuccess + 1
            end
            if keys[2] and SetBinding(keys[2], command) then
                restoreSuccess = restoreSuccess + 1
            end
        end
    end
    
    SaveBindings(GetCurrentBindingSet())
    
    -- Удаляем макросы
    self:DeleteSnakeMacros()
    
    -- Останавливаем игру
    self.snakeGame.active = false
    
    -- Восстанавливаем текстуры
    for _, pos in ipairs(self.snakeGame.body) do
        self.children[pos].frame:SetNormalTexture("Interface\\AddOns\\NSQC3\\libs\\00t.tga")
    end
    
    print("Игра окончена. Счет:", self.snakeGame.score)
    
    -- Дополнительная проверка восстановленных привязок
    local checkCommands = {"MOVEFORWARD", "MOVEBACKWARD", "TURNLEFT", "TURNRIGHT"}
    for _, cmd in ipairs(checkCommands) do
        local key1, key2 = GetBindingKey(cmd)
    end
end

function AdaptiveFrame:MoveSnake()
    -- Защитные проверки
    if not self or not self.snakeGame or not self.snakeGame.active or not self.snakeGame.direction then 
        return 
    end
    
    -- Вычисляем новую позицию головы
    local newPos
    local row = math.floor((self.snakeGame.headPos - 1) / 10)  -- 0-9 (снизу вверх)
    local col = (self.snakeGame.headPos - 1) % 10              -- 0-9 (слева направо)
    
    -- Определяем новую позицию в зависимости от направления
    if self.snakeGame.direction == "UP" then
        newPos = self.snakeGame.headPos + 10
    elseif self.snakeGame.direction == "DOWN" then
        newPos = self.snakeGame.headPos - 10
    elseif self.snakeGame.direction == "LEFT" then
        newPos = self.snakeGame.headPos - 1
    elseif self.snakeGame.direction == "RIGHT" then
        newPos = self.snakeGame.headPos + 1
    end
    
    -- Проверяем выход за границы поля
    if newPos < 1 or newPos > 100 or 
       (self.snakeGame.direction == "LEFT" and col == 0) or 
       (self.snakeGame.direction == "RIGHT" and col == 9) then
        self:StopSnakeGame(false)
        return
    end
    
    -- Проверяем текстуру новой клетки
    local texture = self:getTexture(newPos)
    
    -- Обработка столкновений и специальных клеток
    if texture == "bbb" then
        -- Столкновение с собой
        self:StopSnakeGame(false)
        return
    elseif texture == "00t" then
        -- Специальная клетка - сброс части змейки
        if #self.snakeGame.body > 1 then
            local maxReset = math.min(#self.snakeGame.body - 1, 5) -- Не более 5 клеток
            local numToReset = math.random(1, maxReset)
            for i = 1, numToReset do
                if #self.snakeGame.body > 1 then
                    local pos = table.remove(self.snakeGame.body, 1)
                    self.children[pos].frame:SetNormalTexture("Interface\\AddOns\\NSQC3\\libs\\0ka.tga")
                end
            end
            self.snakeGame.score = #self.snakeGame.body
        end
    elseif texture == "0ob" then
        -- Специальная клетка - сброс всего тела
        if #self.snakeGame.body > 1 then
            for i = 1, #self.snakeGame.body - 1 do
                local pos = self.snakeGame.body[i]
                self.children[pos].frame:SetNormalTexture("Interface\\AddOns\\NSQC3\\libs\\00k.tga")
            end
            self.snakeGame.body = {self.snakeGame.headPos}
            self.snakeGame.score = 1
        end
    elseif texture == "00f" then
        -- Специальная клетка - удвоение очков
        for _, pos in ipairs(self.snakeGame.body) do
            self.children[pos].frame:SetNormalTexture("Interface\\AddOns\\NSQC3\\libs\\00t.tga")
        end
        self.snakeGame.score = self.snakeGame.score * 2
        self:StopSnakeGame(true)
        return
    end
    
    -- Проверяем столкновение с телом
    for _, pos in ipairs(self.snakeGame.body) do
        if pos == newPos then
            self:StopSnakeGame(false)
            return
        end
    end
    
    -- Обновляем позицию змейки
    table.insert(self.snakeGame.body, newPos)
    self.snakeGame.headPos = newPos
    self.children[newPos].frame:SetNormalTexture("Interface\\AddOns\\NSQC3\\libs\\bbb.tga")
    self.snakeGame.score = #self.snakeGame.body
    
    -- Удаляем старый таймер, если есть
    if self.snakeGame.timerFrame then
        self.snakeGame.timerFrame:SetScript("OnUpdate", nil)
        self.snakeGame.timerFrame = nil
    end
    
    -- Создаем новый таймер для следующего хода
    local timerFrame = CreateFrame("Frame")
    timerFrame.elapsed = 0
    timerFrame.speed = self.snakeGame.speed
    timerFrame.parent = self
    
    timerFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= self.speed then
            self.parent:MoveSnake()
            self:SetScript("OnUpdate", nil)
        end
    end)
    
    self.snakeGame.timerFrame = timerFrame
end

-- Методы управления змейкой
function AdaptiveFrame:SnakeUp()
    if not self.snakeGame.active then return end
    local row = math.floor((self.snakeGame.headPos - 1) / 10)
    if row < 9 then  -- Нельзя идти вверх, если уже на верхней строке
        if self.snakeGame.direction ~= "DOWN" then
            self.snakeGame.direction = "UP"
            if not self.snakeGame.timerFrame then
                self:MoveSnake()
            end
        end
    else
        self:StopSnakeGame(false)
    end
end

function AdaptiveFrame:SnakeDown()
    if not self.snakeGame.active then return end
    local row = math.floor((self.snakeGame.headPos - 1) / 10)
    if row > 0 then  -- Нельзя идти вниз, если уже на нижней строке
        if self.snakeGame.direction ~= "UP" then
            self.snakeGame.direction = "DOWN"
            if not self.snakeGame.timerFrame then
                self:MoveSnake()
            end
        end
    else
        self:StopSnakeGame(false)
    end
end

function AdaptiveFrame:SnakeLeft()
    if not self.snakeGame.active then return end
    local col = (self.snakeGame.headPos - 1) % 10
    if col > 0 then  -- Нельзя идти влево, если уже в левом столбце
        if self.snakeGame.direction ~= "RIGHT" then
            self.snakeGame.direction = "LEFT"
            if not self.snakeGame.timerFrame then
                self:MoveSnake()
            end
        end
    else
        self:StopSnakeGame(false)
    end
end

function AdaptiveFrame:SnakeRight()
    if not self.snakeGame.active then return end
    local col = (self.snakeGame.headPos - 1) % 10
    if col < 9 then  -- Нельзя идти вправо, если уже в правом столбце
        if self.snakeGame.direction ~= "LEFT" then
            self.snakeGame.direction = "RIGHT"
            if not self.snakeGame.timerFrame then
                self:MoveSnake()
            end
        end
    else
        self:StopSnakeGame(false)
    end
end

function AdaptiveFrame:RegisterSlashCommands()
    -- Создаем команды для управления змейкой
    _G["ADAPTIVEFRAME_SNAKE_UP"] = function()
        self:SnakeUp()
    end
    
    _G["ADAPTIVEFRAME_SNAKE_DOWN"] = function()
        self:SnakeDown()
    end
    
    _G["ADAPTIVEFRAME_SNAKE_LEFT"] = function()
        self:SnakeLeft()
    end
    
    _G["ADAPTIVEFRAME_SNAKE_RIGHT"] = function()
        self:SnakeRight()
    end
    
    -- Регистрируем команды в WoW
    for _, cmd in ipairs({"UP", "DOWN", "LEFT", "RIGHT"}) do
        local action = "ADAPTIVEFRAME_SNAKE_"..cmd
        SetBindingClick(action, action)
    end
    
    SaveBindings(GetCurrentBindingSet())
end




















































SpellQueue = {}
SpellQueue.__index = SpellQueue

local CLASS_PRESETS = {
    ["Рыцарь смерти"] = {
        ["Удар смерти"] = {
            combo = 0,
            priority = 3,
            icon = "Interface\\Icons\\Spell_DeathKnight_Butcher2",
            pos = 0,
        },
        ["Смерть и разложение"] = {
            combo = 0,
            priority = 5,
            icon = "Interface\\Icons\\Spell_Shadow_DeathAndDecay",
            pos = 0,
        },
        ["Ледяное прикосновение"] = {
            combo = 0,
            debuf = "Озноб",
            priority = 1,
            icon = "Interface\\Icons\\Spell_DeathKnight_IceTouch",
            pos = 0,
        },
        ["Удар чумы"] = {
            combo = 0,
            debuf = "Кровавая чума",
            priority = 2,
            icon = "Interface\\Icons\\Spell_DeathKnight_EmpowerRuneBlade",
            pos = 0,
        },
        ["Зимний горн"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\INV_Misc_Horn_02",
            pos = 0,
        },
        ["Лик смерти"] = {
            combo = 0,
            resource = {
                amount = 80,
                type = 6,
            },
            icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",
            pos = 5,
        },
        ["Кровавый удар"] = {
            combo = 0,
            priority = 4,
            icon = "Interface\\Icons\\Spell_Deathknight_DeathStrike",
            pos = 0,
        },
    },
    ["Жрец (дд)"] = {
        ["Молитва защиты от темной магии"] = {
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Holy_PrayerofShadowProtection",
            pos = 0,
        },
        ["Облик Тьмы"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Shadow_Shadowform",
            pos = 0,
        },
        ["Молитва стойкости"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfFortitude",
            pos = 0,
        },
        ["Всепожирающая чума"] = {
            combo = 0,
            debuf = 1,
            priority = 2,
            icon = "Interface\\Icons\\Spell_Shadow_DevouringPlague",
            pos = 0,
        },
        ["Слово Тьмы: Боль"] = {
            combo = 0,
            debuf = 1,
            priority = 4,
            icon = "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
            pos = 0,
        },
        ["Взрыв разума"] = {
            combo = 0,
            priority = 3,
            icon = "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
            pos = 0,
        },
        ["Прикосновение вампира"] = {
            combo = 0,
            debuf = 1,
            priority = 1,
            icon = "Interface\\Icons\\Spell_Holy_Stoicism",
            pos = 0,
        },
        ["Молитва духа"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Holy_PrayerofSpirit",
            pos = 0,
        },
        ["Внутренний огонь"] = {
            buf = 1,
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_InnerFire",
            pos = 0,
        },
        ["Объятия вампира"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding",
            pos = 0,
        },
    },
    ["Паладин (танк)"] = {
        ["Великое благословение неприкосновенности"] = {
            buf = 1,
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_GreaterBlessingofSanctuary",
            pos = 0,
        },
        ["Молот гнева"] = {
            texture = 1,
            combo = 0,
            prok = 20,
            priority = 0,
            icon = "Interface\\Icons\\Ability_ThunderClap",
            pos = 0,
        },
        ["Щит небес"] = {
            buf = 1,
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_BlessingOfProtection",
            pos = 0,
        },
        ["Праведное неистовство"] = {
            buf = 1,
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_SealOfFury",
            pos = 0,
        },
        ["Молот праведника"] = {
            combo = 0,
            icon = "Interface\\Icons\\Ability_Paladin_HammeroftheRighteous",
            pos = 0,
        },
        ["Священный щит"] = {
            buf = 1,
            combo = 0,
            icon = "Interface\\Icons\\Ability_Paladin_BlessedMending",
            pos = 0,
        },
        ["Правосудие света"] = {
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_RighteousFury",
            pos = 0,
        },
        ["Щит праведности"] = {
            combo = 0,
            icon = "Interface\\Icons\\Ability_Paladin_ShieldofVengeance",
            pos = 0,
        },
        ["Щит мстителя"] = {
            combo = 0,
            priority = -1,
            icon = "Interface\\Icons\\Spell_Holy_AvengersShield",
            pos = 0,
        },
        ["Печать повиновения"] = {
            buf = 1,
            combo = 0,
            icon = "Interface\\Icons\\Ability_Warrior_InnerRage",
            pos = 0,
        },
    },
    ["Друид (медведь)"] = {
        ["Устрашающий рев"] = {
            combo = 0,
            debuf = 1,
            icon = "Interface\\Icons\\Ability_Druid_DemoralizingRoar",
            pos = 3,
        },
        ["Волшебный огонь (зверь)"] = {
            combo = 0,
            debuf = 1,
            icon = "Interface\\Icons\\Spell_Nature_FaerieFire",
            pos = 3,
        },
        ["Увечье (медведь)"] = {
            combo = 0,
            icon = "Interface\\Icons\\Ability_Druid_Mangle2",
            pos = 0,
        },
        ["Свирепый укус"] = {
            combo = 5,
            icon = "Interface\\Icons\\Ability_Druid_FerociousBite",
            pos = 2,
        },
    },
    ["Паладин (дд)"] = {
        ["Длань возмездия"] = {
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_UnyieldingFaith",
            pos = 0,
        },
        ["Молот гнева"] = {
            prok = 20,
            texture = 1,
            combo = 0,
            icon = "Interface\\Icons\\Ability_ThunderClap",
            pos = 0,
        },
        ["Удар воина Света"] = {
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_CrusaderStrike",
            pos = 0,
        },
        ["Великое благословение могущества"] = {
            buf = 1,
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_GreaterBlessingofKings",
            pos = 0,
        },
        ["Печать праведности"] = {
            buf = 1,
            combo = 0,
            icon = "Interface\\Icons\\Ability_ThunderBolt",
            pos = 0,
        },
        ["Экзорцизм"] = {
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",
            pos = 0,
        },
        ["Правосудие света"] = {
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_RighteousFury",
            pos = 0,
        },
        ["Божественная буря"] = {
            combo = 0,
            icon = "Interface\\Icons\\Ability_Paladin_DivineStorm",
            pos = 0,
        },
        ["Покаяние"] = {
            combo = 0,
            icon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
            pos = 5,
        },
    },
    ["Маг (фаер)"] = {
        ["Невидимость"] = {
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Ability_Mage_Invisibility",
            pos = 4,
        },
        ["Чародейская гениальность"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Holy_ArcaneIntellect",
            pos = 0,
        },
        ["Ожог"] = {
            combo = 0,
            debuf = "Улучшенный ожог",
            priority = 0,
            icon = "Interface\\Icons\\Spell_Fire_SoulBurn",
            pos = 0,
        },
        ["Прилив сил"] = {
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Nature_Purge",
            pos = 4,
        },
        ["Раскаленный доспех"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Ability_Mage_MoltenArmor",
            pos = 0,
        },
        ["Кольцо льда"] = {
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Frost_FrostNova",
            pos = 3,
        },
        ["Огненный взрыв"] = {
            combo = 0,
            priority = 1,
            icon = "Interface\\Icons\\Spell_Fire_Fireball",
            pos = 0,
        },
        ["Живая бомба"] = {
            combo = 0,
            debuf = 1,
            priority = 2,
            icon = "Interface\\Icons\\Ability_Mage_LivingBomb",
            pos = 0,
        },
    },
    ["Шаман (элем)"] = {
        ["Щит молний"] = {
            buf = 1,
            combo = 0,
            icon = "Interface\\Icons\\Spell_Nature_LightningShield",
            pos = 0,
        },
        ["Огненный шок"] = {
            combo = 0,
            debuf = 1,
            icon = "Interface\\Icons\\Spell_Fire_FlameShock",
            pos = 0,
        },
        ["Земной шок"] = {
            combo = 0,
            icon = "Interface\\Icons\\Spell_Nature_EarthShock",
            pos = 0,
        },
    },
    ["Чернокнижник (афли)"] = {
        ["Проклятие агонии"] = {
            combo = 0,
            debuf = 1,
            priority = 5,
            icon = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",
            pos = 0,
        },
        ["Доспех Скверны"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Shadow_FelArmour",
            pos = 0,
        },
        ["Порча"] = {
            combo = 0,
            debuf = 1,
            priority = 4,
            icon = "Interface\\Icons\\Spell_Shadow_AbominationExplosion",
            pos = 0,
        },
        ["Блуждающий дух"] = {
            combo = 0,
            debuf = 1,
            priority = 2,
            icon = "Interface\\Icons\\Ability_Warlock_Haunt",
            pos = 0,
        },
        ["Нестабильное колдовство"] = {
            combo = 0,
            debuf = 1,
            priority = 3,
            icon = "Interface\\Icons\\Spell_Shadow_UnstableAffliction_3",
            pos = 0,
        },
        ["Проклятие стихий"] = {
            combo = 0,
            debuf = 1,
            priority = 1,
            icon = "Interface\\Icons\\Spell_Shadow_ChillTouch",
            pos = 0,
        },
    },
    ["Охотник (мм)"] = {
        ["Прицельный выстрел"] = {
            combo = 0,
            priority = 4,
            icon = "Interface\\Icons\\INV_Spear_07",
            pos = 0,
        },
        ["Дух дракондора"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Ability_Hunter_Pet_DragonHawk",
            pos = 0,
        },
        ["Укус змеи"] = {
            combo = 0,
            debuf = 1,
            priority = 2,
            icon = "Interface\\Icons\\Ability_Hunter_Quickshot",
            pos = 0,
        },
        ["Метка охотника"] = {
            combo = 0,
            debuf = 1,
            priority = 1,
            icon = "Interface\\Icons\\Ability_Hunter_SniperShot",
            pos = 0,
        },
        ["Глушащий выстрел"] = {
            combo = 0,
            priority = 7,
            icon = "Interface\\Icons\\Ability_TheBlackArrow",
            pos = 0,
        },
        ["Чародейский выстрел"] = {
            combo = 0,
            priority = 5,
            icon = "Interface\\Icons\\Ability_ImpalingBolt",
            pos = 0,
        },
        ["Выстрел химеры"] = {
            combo = 0,
            priority = 3,
            icon = "Interface\\Icons\\Ability_Hunter_ChimeraShot2",
            pos = 0,
        },
        ["Убийственный выстрел"] = {
            texture = 1,
            combo = 0,
            prok = 20,
            priority = 0,
            icon = "Interface\\Icons\\Ability_Hunter_Assassinate2",
            pos = 0,
        },
    },
    ["Разбойник (саб)"] = {
        ["Внезапный удар"] = {
            combo = 0,
            priority = 1,
            icon = "Interface\\Icons\\Ability_Rogue_Ambush",
            pos = 0,
        },
        ["Маленькие хитрости"] = {
            combo = 0,
            priority = 3,
            icon = "Interface\\Icons\\Ability_Rogue_TricksOftheTrade",
            pos = 0,
        },
        ["Мясорубка"] = {
            buf = 1,
            combo = 0,
            priority = 0,
            icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
            pos = 4,
        },
        ["Кровоизлияние"] = {
            combo = 0,
            debuf = 1,
            priority = 0,
            icon = "Interface\\Icons\\Spell_Shadow_LifeDrain",
            pos = 0,
        },
        ["Танец теней"] = {
            pos = 5,
            icon = "Interface\\Icons\\Ability_Rogue_ShadowDance",
            combo = 0,
        },
        ["Потрошение"] = {
            combo = 5,
            priority = 2,
            icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",
            pos = 0,
        },
    },
}

-- Константы
local COMBO_TEXTURE = "Interface\\AddOns\\NSQC3\\libs\\00t.tga"
local POISON_TEXTURE = "Interface\\AddOns\\NSQC3\\libs\\00t.tga"
local FEATURE_HP = 1
local FEATURE_RESOURCE = 2
local FEATURE_TARGET = 4
local FEATURE_COMBO = 8
local FEATURE_POISON = 16
local FEATURE_COLORS = {
    MANA = {0.0, 0.82, 1.0},
    RAGE = {1.0, 0.0, 0.0},
    ENERGY = {1.0, 1.0, 0.0},
    RUNIC_POWER = {0.0, 0.82, 1.0},
    HEALTH = {1.0, 0.0, 0.0},
    COMBO_ACTIVE = {1.0, 0.5, 0.0},
    POISON_ACTIVE = {0.0, 1.0, 0.0},
    COMBO_EMPTY = {0.1, 0.1, 0.1},
    COMBO_FILLED = {1.0, 0.5, 0.0},
    COMBO_FULL = {0.5, 0.0, 1.0},
    POISON_EMPTY = {0.1, 0.1, 0.1},
    POISON_FILLED = {0.0, 1.0, 0.0},
    POISON_FULL = {0.5, 0.0, 1.0}
}
local RESOURCE_TYPES = {
    MANA = 0,
    RAGE = 1,
    FOCUS = 2,
    ENERGY = 3,
    RUNIC_POWER = 6,
    COMBO_POINTS = 14
}
local RESOURCE_NAMES = {
    [0] = "Мана",
    [1] = "Ярость",
    [3] = "Энергия",
    [6] = "Сила рун",
    [14] = "Комбо-поинты"
}
local CLASS_RESOURCE_TYPES = {
    DRUID = 0,
    HUNTER = 2,
    MAGE = 0,
    PALADIN = 0,
    PRIEST = 0,
    ROGUE = 3,
    SHAMAN = 0,
    WARLOCK = 0,
    WARRIOR = 1
}

local SHIELD_CACHE = {
    maxAbsorb = 0,
    currentAbsorb = 0,
    isActive = false,
    history = {},
    historySize = 5
}
local SHIELD_BAR_MODE = 1  -- 1 = фиксированная ширина, 2 = пропорционально HP
local SHIELD_BAR_HEIGHT = 5  -- высота полоски щита по умолчанию

local PLAYER_KEY = UnitName("player")
local RETURN_DELAY = 0.00
local DEBUFF_UPDATE_DELAY = 0.00
local READY_ALPHA = 1.0
local COOLDOWN_ALPHA = 0.6
local DEBUFF_ALPHA = 0.5
local NO_RESOURCE_ALPHA = 0.25
local READY_GLOW_COLOR = {0, 1, 0, 0.3}
local COOLDOWN_GLOW_COLOR = {1, 0, 0, 0.2}
local INACTIVE_ALPHA = 0.2
local BUFF_PRIORITY_POSITION = -100
local MODE_COMBAT_ONLY = 1
local MODE_ALWAYS_VISIBLE = 2
local MODE_ALWAYS_HIDDEN = 3

function SpellQueue:FindIconBySpellQueueName(spellName)
    if not ProkIconManager or not ProkIconManager.icons then
        return nil
    end
    for _, iconData in pairs(ProkIconManager.icons) do
        if iconData.spellqueue_name == spellName and iconData.triggerType == "custom" then
            return iconData
        end
    end
    return nil
end

function SpellQueue:ShowProkTexture(spellName, iconData)
    if not self.prokTextures then
        self.prokTextures = {}
    end
    if not self.prokTextures[spellName] then
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetFrameStrata("HIGH")
        frame.texture = frame:CreateTexture(nil, "BACKGROUND")
        frame.texture:SetAllPoints()
        self.prokTextures[spellName] = frame
    end
    local frame = self.prokTextures[spellName]
    local profile = ProkIconManager.settings[iconData.profil or 1] or ProkIconManager.settings[1]
    local width = profile.Rx == 0 and GetScreenWidth() or profile.Rx
    local height = profile.Ry == 0 and GetScreenHeight() or profile.Ry
    local x, y = profile.x or 0, profile.y or 0
    frame:SetSize(width, height)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    local texturePath = iconData.icon
    if not strfind(texturePath:lower(), "^interface\\") then
        if not strfind(texturePath:lower(), "%.tga$") and not strfind(texturePath:lower(), "%.blp$") then
            texturePath = texturePath .. ".tga"
        end
        texturePath = "Interface\\AddOns\\NSQC\\libs\\" .. texturePath
    end
    local success = pcall(function()
        frame.texture:SetTexture(texturePath)
    end)
    if not success then
        frame.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    frame:Show()
end

function SpellQueue:HideProkTexture(spellName)
    if self.prokTextures and self.prokTextures[spellName] then
        self.prokTextures[spellName]:Hide()
    end
end

function SpellQueue:UpdateDebuffState(spellName)
    local spell = self.spells[spellName]
    if not spell or not spell.data.debuf then
        return
    end
    local debuffName = type(spell.data.debuf) == "string" and spell.data.debuf or spellName
    local hasDebuff, expirationTime = self:HasDebuff(debuffName)
    spell.hasDebuff = hasDebuff
    spell.debuffExpirationTime = expirationTime
end

function SpellQueue:ScheduleDebuffCheck(spellName)
    self:CreateTimer(DEBUFF_UPDATE_DELAY, function()
        local spell = self.spells[spellName]
        if not spell or not spell.data.debuf then
            return
        end
        self:UpdateDebuffState(spellName)
    end)
end

function SpellQueue:SetShieldBarHeight(height)
    height = tonumber(height)
    if not height or height < 1 then
        print("|cFFFF0000[ShieldBar]|r Использование: /sqshield <высота> (1-30)")
        print("|cFFFF0000[ShieldBar]|r Текущая высота: " .. SHIELD_BAR_HEIGHT)
        return
    end
    
    height = math.floor(height)
    if height < 1 then height = 1 end
    if height > 30 then height = 30 end
    
    SHIELD_BAR_HEIGHT = height
    self.shieldBar:SetHeight(SHIELD_BAR_HEIGHT)
    self:UpdateShieldBar()
    
    if height > 10 then
        print(string.format("|cFF00FF00[ShieldBar]|r Высота: %dpx (текст включен)", height))
    else
        print(string.format("|cFF00FF00[ShieldBar]|r Высота: %dpx", height))
    end
end

function SpellQueue:ToggleShieldBarMode()
    if SHIELD_BAR_MODE == 1 then
        SHIELD_BAR_MODE = 2
        print("|cFF00FF00[ShieldBar]|r Режим: пропорционально полоске HP")
    else
        SHIELD_BAR_MODE = 1
        print("|cFF00FF00[ShieldBar]|r Режим: фиксированная ширина")
    end
    self:UpdateShieldBar()
end

function SpellQueue:UpdateShieldBar()
    if not self.shieldBar then return end
    
    if SHIELD_CACHE.isActive and SHIELD_CACHE.maxAbsorb > 0 then
        local percent = SHIELD_CACHE.currentAbsorb / SHIELD_CACHE.maxAbsorb
        percent = math.max(0, math.min(1, percent))
        
        if SHIELD_BAR_MODE == 2 then
            local maxHP = UnitHealthMax("player")
            if maxHP > 0 then
                local hpPercent = SHIELD_CACHE.maxAbsorb / maxHP
                hpPercent = math.min(hpPercent, 1)
                self.shieldBar:SetWidth(self.width * hpPercent * percent)
            else
                self.shieldBar:SetWidth(self.width * percent)
            end
        else
            self.shieldBar:SetWidth(self.width * percent)
        end
        
        self.shieldBar:Show()
        
        if percent > 0.5 then
            self.shieldBar:SetVertexColor(1, 0.82, 0)
        elseif percent > 0.25 then
            self.shieldBar:SetVertexColor(1, 0.5, 0)
        else
            self.shieldBar:SetVertexColor(1, 0, 0)
        end
        
        if SHIELD_BAR_HEIGHT > 10 and self.shieldBarText then
            local text = string.format("%d/%d", SHIELD_CACHE.currentAbsorb, SHIELD_CACHE.maxAbsorb)
            self.shieldBarText:SetText(text)
            
            local fontSize = math.floor(SHIELD_BAR_HEIGHT * 0.7)
            if fontSize < 8 then fontSize = 8 end
            if fontSize > 16 then fontSize = 16 end
            self.shieldBarText:SetFont("Fonts\\FRIZQT__.TTF", fontSize, "OUTLINE")
            
            self.shieldBarText:Show()
        else
            if self.shieldBarText then
                self.shieldBarText:Hide()
            end
        end
        
    else
        self.shieldBar:Hide()
        if self.shieldBarText then
            self.shieldBarText:Hide()
        end
    end
end

function SpellQueue:HasDebuff(debuffName)
    if not UnitExists("target") or not UnitCanAttack("player", "target") then
        return false, 0
    end
    for i = 1, 40 do
        local name, _, _, _, _, _, expirationTime = UnitDebuff("target", i)
        if not name then
            break
        end
        if name == debuffName then
            if expirationTime and expirationTime > 0 then
                return true, expirationTime
            else
                return true, 0
            end
        end
    end
    return false, 0
end

function SpellQueue:UpdateBuffState(spellName, isActive)
    local spell = self.spells[spellName]
    if not spell or not spell.data.buf then
        return
    end
    local buffName = type(spell.data.buf) == "string" and spell.data.buf or spellName
    if isActive and type(spell.data.buf) == "string" and spellName ~= buffName then
        return
    end
    spell.hasBuff = isActive
    self:UpdateSpellPosition(spellName)
    self:UpdateSpellsPriority()
end

function SpellQueue:Create(name, width, height, anchorPoint, parentFrame)
    local frame = CreateFrame("Frame", name, parentFrame or UIParent)
    local self = setmetatable({}, SpellQueue)
    self.playerClass = select(2, UnitClass("player"))
    self.resourceTypeNames = {
        [0] = "MANA",
        [1] = "RAGE",
        [3] = "ENERGY",
        [6] = "RUNIC_POWER"
    }
    self.frame = frame
    self.width = width or 300
    self.height = height or 50
    self.anchorPoint = anchorPoint or "CENTER"
    self.spells = {}
    self.activeSpells = {}
    self.isAnchored = false
    self.alpha = 1.0
    self.scale = 1.0
    self.inCombat = false
    self.combatRegistered = false
    self.features = bit.bor(
        FEATURE_HP,
        FEATURE_RESOURCE,
        FEATURE_TARGET,
        FEATURE_COMBO,
        FEATURE_POISON
    )
    self.timers = {}
    self.groupEndPositions = {}
    self.groupReadyCount = {}
    self.priorityDirty = true
    self.lastReadyState = {}
    frame:SetClampedToScreen(true)
    frame:SetWidth(self.width)
    frame:SetHeight(self.height)
    if _G.nsDbc.SpellQueuePosition then
        local pos = _G.nsDbc.SpellQueuePosition
        frame:SetPoint(pos.point, UIParent, pos.relativePoint,
            ns_dbc:getKey("настройки", "Skill Queue position", "x"),
            ns_dbc:getKey("настройки", "Skill Queue position", "y"))
    else
        frame:SetPoint(self.anchorPoint)
    end
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetAlpha(INACTIVE_ALPHA)
    frame:SetScale(self.scale)
    frame:Hide()
    self.isClickThrough = false
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(0.1, 0.1, 0.1, 0.8)
    bg:SetVertexColor(0.1, 0.1, 0.1)
    bg:SetAlpha(0.8)
    self.background = bg
    local timeLine = frame:CreateTexture(nil, "OVERLAY")
    timeLine:SetHeight(2)
    timeLine:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, height / 2 - 10)
    timeLine:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, height / 2 - 10)
    timeLine:SetTexture(1, 1, 0.5)
    timeLine:SetVertexColor(1, 1, 0.5)
    timeLine:SetAlpha(0.3)
    self.timeLine = timeLine
    local zeroPoint = frame:CreateTexture(nil, "OVERLAY")
    zeroPoint:SetWidth(2)
    zeroPoint:SetHeight(1)
    zeroPoint:SetPoint("LEFT", frame, "LEFT", 0, 0)
    zeroPoint:SetTexture(1, 0.2, 0.2)
    zeroPoint:SetVertexColor(1, 0.2, 0.2)
    zeroPoint:SetAlpha(0.5)
    self.zeroPoint = zeroPoint
    self.comboPoints = nil
    self.poisonStacks = nil
    self:CreateComboPoisonElements()
    self:CreateResourceBars()
    local configButton = CreateFrame("Button", nil, frame)
    configButton:SetSize(20, 20)
    configButton:SetPoint("BOTTOMRIGHT", -2, 2)
    configButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    configButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    configButton:SetScript("OnClick", function()
        if not self.configFrame then
            self:CreateConfigWindow()
        end
        self.configFrame:Show()
    end)
    configButton:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            self.isAnchored = false
            self.isClickThrough = false
            self.frame:EnableMouse(true)
            self.frame:SetMovable(true)
            self.frame:RegisterForDrag("LeftButton")
            self.frame:SetAlpha(self.alpha)
        end
    end)
    local prokButton = CreateFrame("Button", nil, frame)
    prokButton:SetSize(20, 20)
    prokButton:SetPoint("BOTTOMRIGHT", -2, 25)
    prokButton:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
    prokButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    prokButton:SetScript("OnClick", function()
        if not ProkIconManager.configFrame then
            ProkIconManager:CreateConfigUI()
        end
        ProkIconManager.configFrame:Show()
    end)
    frame:SetScript("OnUpdate", function(_, elapsed)
        if self.frame:IsShown() then
            local stateChanged = false
            for spellName, spell in pairs(self.spells) do
                local oldReady = self.lastReadyState[spellName]
                if oldReady ~= spell.isReady then
                    stateChanged = true
                    self.lastReadyState[spellName] = spell.isReady
                end
            end
            if stateChanged or self.priorityDirty then
                self:UpdateSpellsPriority()
                self.priorityDirty = false
                for spellName, spell in pairs(self.spells) do
                    self:UpdateSpellPosition(spellName)
                end
            end
            for spellName, spell in pairs(self.spells) do
                self:UpdateSpellPosition(spellName)
            end
            self:UpdateCooldownLayers()
            self:UpdateResourceBars()
            self:UpdateComboPoints()
            self:UpdatePoisonStacks()
            if self.frame:GetAlpha() ~= self.alpha then
                self.frame:SetAlpha(self.alpha)
            end
        end
        local currentTime = GetTime()
        for i = #self.timers, 1, -1 do
            local timer = self.timers[i]
            if not timer.executed and (currentTime - timer.startTime) >= timer.delay then
                timer.callback()
                timer.executed = true
                table.remove(self.timers, i)
            end
        end
    end)
    self.displayMode = ns_dbc:getKey("настройки", "Skill Queue mode") or MODE_COMBAT_ONLY
    self:ApplyDisplayMode()
    self:SetupDrag()
    self:UpdateClickThrough()
    self:RegisterAllEvents()
    self:UpdateSkillTables()
    _G.SpellQueueInstance = self
    self:ForceUpdateAllSpells()
    self:UpdateComboPoints()
    self:UpdatePoisonStacks()
    return self
end

function SpellQueue:UpdateSpellCooldownOnly(spellName)
    local spell = self.spells[spellName]
    if not spell then
        return
    end
    local start, duration = GetSpellCooldown(spellName)
    if start and duration and start > 0 and duration > 0 and duration < 2.0 then
        if spell.cooldownFrame then
            spell.cooldownFrame:SetCooldown(start, duration)
            spell.cooldownFrame:Show()
        end
        spell.cooldownText:Hide()
    end
end

function SpellQueue:CreateTimer(delay, callback)
    table.insert(self.timers, {
        startTime = GetTime(),
        delay = delay,
        callback = callback,
        executed = false
    })
end

function SpellQueue:ClearTimers()
    self.timers = {}
end

function SpellQueue:ApplyDisplayMode()
    if self.displayMode == MODE_ALWAYS_VISIBLE then
        self.frame:SetAlpha(INACTIVE_ALPHA)
        self.frame:Show()
    elseif self.displayMode == MODE_ALWAYS_HIDDEN then
        self.frame:Hide()
    else
        if self.inCombat then
            self.frame:SetAlpha(self.alpha)
            self.frame:Show()
        else
            self.frame:Hide()
        end
    end
end

function SpellQueue:CreateResourceBars()
    self.healthBar = self.frame:CreateTexture(nil, "OVERLAY")
    self.healthBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.healthBar:SetHeight(5)
    self.healthBar:SetWidth(self.width)
    self.healthBar:SetPoint("TOP", self.frame, "TOP", 0, 10)
    self.healthBar:SetVertexColor(1, 0, 0)
    self.healthBar:Hide()
    
    self.shieldBar = self.frame:CreateTexture(nil, "OVERLAY")
    self.shieldBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.shieldBar:SetHeight(SHIELD_BAR_HEIGHT)
    self.shieldBar:SetWidth(0)
    self.shieldBar:SetPoint("BOTTOM", self.healthBar, "TOP", 0, 2)
    self.shieldBar:SetVertexColor(1, 0.82, 0)
    self.shieldBar:SetAlpha(0.8)
    self.shieldBar:Hide()
    
    self.shieldBarText = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.shieldBarText:SetPoint("CENTER", self.shieldBar, "CENTER", 0, 0)
    self.shieldBarText:SetTextColor(1, 1, 1, 1)
    self.shieldBarText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    self.shieldBarText:Hide()
    
    self.resourceBar = self.frame:CreateTexture(nil, "OVERLAY")
    self.resourceBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.resourceBar:SetHeight(5)
    self.resourceBar:SetWidth(self.width)
    self.resourceBar:SetPoint("TOP", self.healthBar, "BOTTOM", 0, -1)
    self.resourceBar:Hide()
    
    self.targetHealthBar = self.frame:CreateTexture(nil, "OVERLAY")
    self.targetHealthBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.targetHealthBar:SetHeight(5)
    self.targetHealthBar:SetWidth(self.width)
    self.targetHealthBar:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, -10)
    self.targetHealthBar:SetVertexColor(1, 0, 0)
    self.targetHealthBar:Hide()
    
    self.targetResourceBar = self.frame:CreateTexture(nil, "OVERLAY")
    self.targetResourceBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.targetResourceBar:SetHeight(5)
    self.targetResourceBar:SetWidth(self.width)
    self.targetResourceBar:SetPoint("BOTTOM", self.targetHealthBar, "TOP", 0, 1)
    self.targetResourceBar:Hide()
end

function SpellQueue:CreateComboPoints()
    self.comboPoints = {}
    local comboSize = 14
    local baseX = 20
    local yOffset = -10
    for i = 1, 5 do
        local point = self.frame:CreateTexture(nil, "BACKGROUND")
        point:SetTexture("Interface\\TargetingFrame\\UI-Combopoint")
        point:SetSize(comboSize, comboSize)
        point:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", baseX + (i - 1) * 25, yOffset)
        point:SetVertexColor(0.2, 0.2, 0.2)
        table.insert(self.comboPoints, point)
    end
end

function SpellQueue:CreatePoisonStacks()
    self.poisonStacks = {}
    local poisonSize = self.height * 0.8
    for i = 1, 5 do
        local stack = self.frame:CreateTexture(nil, "OVERLAY")
        stack:SetSize(poisonSize, poisonSize)
        stack:SetTexture("Interface\\TargetingFrame\\UI-Combopoint")
        stack:SetPoint("RIGHT", self.frame, "RIGHT", -poisonSize * (i - 3), 0)
        stack:SetVertexColor(0.1, 0.1, 0.1)
        stack:SetAlpha(1.0)
        table.insert(self.poisonStacks, stack)
    end
end

function SpellQueue:GetPlayerResourceType()
    local _, class = UnitClass("player")
    if class == "DRUID" then
        local form = GetShapeshiftForm()
        if form == 1 then
            return 1
        elseif form == 3 then
            return 3
        else
            return 0
        end
    end
    local classResourceMap = {
        ["DRUID"] = 0,
        ["HUNTER"] = 0,
        ["MAGE"] = 0,
        ["PALADIN"] = 0,
        ["PRIEST"] = 0,
        ["ROGUE"] = 3,
        ["SHAMAN"] = 0,
        ["WARLOCK"] = 0,
        ["WARRIOR"] = 1
    }
    return classResourceMap[class] or 0
end

function SpellQueue:GetTargetResourceType()
    if not UnitExists("target") then
        return 0
    end
    local powerType = UnitPowerType("target")
    return powerType
end

function SpellQueue:UpdateResourceBars()
    self:UpdateShieldBar()
    
    if bit.band(self.features, FEATURE_HP) ~= 0 then
        local maxHP = UnitHealthMax("player")
        local hp = maxHP > 0 and (UnitHealth("player") / maxHP) or 0
        self.healthBar:SetWidth(self.width * hp)
        self.healthBar:Show()
    else
        self.healthBar:Hide()
    end
    
    if bit.band(self.features, FEATURE_RESOURCE) ~= 0 then
        local resourceType = self:GetPlayerResourceType()
        local current = UnitPower("player", resourceType)
        local max = UnitPowerMax("player", resourceType)
        if max > 0 then
            local color = self:GetResourceColor(resourceType)
            self.resourceBar:SetWidth((current / max) * self.width)
            self.resourceBar:SetVertexColor(unpack(color))
            self.resourceBar:Show()
        else
            self.resourceBar:Hide()
        end
    else
        self.resourceBar:Hide()
    end
    
    if UnitExists("target") and bit.band(self.features, FEATURE_TARGET) ~= 0 then
        local maxHP = UnitHealthMax("target")
        local hp = maxHP > 0 and (UnitHealth("target") / maxHP) or 0
        self.targetHealthBar:SetWidth(self.width * hp)
        self.targetHealthBar:Show()
        
        local powerType = UnitPowerType("target")
        local current = UnitPower("target", powerType)
        local max = UnitPowerMax("target", powerType)
        if max > 0 then
            local color = self:GetResourceColor(powerType)
            self.targetResourceBar:SetWidth((current / max) * self.width)
            self.targetResourceBar:SetVertexColor(unpack(color))
            self.targetResourceBar:Show()
        else
            local foundResource = false
            for altType = 0, 12 do
                current = UnitPower("target", altType)
                max = UnitPowerMax("target", altType)
                if max > 0 and current > 0 then
                    color = self:GetResourceColor(altType)
                    self.targetResourceBar:SetWidth((current / max) * self.width)
                    self.targetResourceBar:SetVertexColor(unpack(color))
                    self.targetResourceBar:Show()
                    foundResource = true
                    break
                end
            end
            if not foundResource then
                self.targetResourceBar:Hide()
            end
        end
    else
        self.targetHealthBar:Hide()
        self.targetResourceBar:Hide()
    end
end

function SpellQueue:GetResourceColor(resourceType)
    local colors = {
        [0] = {0.0, 0.82, 1.0},
        [1] = {1.0, 0.0, 0.0},
        [2] = {1.0, 0.5, 0.0},
        [3] = {1.0, 1.0, 0.0},
        [5] = {0.4, 0.4, 1.0},
        [6] = {0.0, 0.82, 1.0},
        [7] = {0.5, 0.5, 0.5},
        [8] = {1.0, 0.5, 0.0},
        [9] = {0.8, 0.2, 0.8},
        [10] = {0.6, 0.4, 0.2},
        [11] = {0.2, 0.8, 0.2},
        [12] = {0.8, 0.8, 0.2}
    }
    return colors[resourceType] or {1, 1, 1}
end

function SpellQueue:UpdateComboPoints()
    if bit.band(self.features, FEATURE_COMBO) == 0 then
        self.comboFrame:Hide()
        return
    end
    self.comboFrame:Show()
    local cp = GetComboPoints("player", "target")
    local isFull = cp == 5
    for i = 1, 5 do
        local color
        if isFull then
            color = FEATURE_COLORS.COMBO_FULL
        else
            color = i <= cp and FEATURE_COLORS.COMBO_FILLED or FEATURE_COLORS.COMBO_EMPTY
        end
        self.comboSquares[i]:SetVertexColor(unpack(color))
    end
end

function SpellQueue:UpdateProkSpells()
    for spellName, spell in pairs(self.spells) do
        if spell.data.prok then
            self:UpdateSpellPosition(spellName)
        end
    end
end

function SpellQueue:UpdatePoisonStacks()
    if bit.band(self.features, FEATURE_POISON) == 0 then
        self.poisonFrame:Hide()
        return
    end
    self.poisonFrame:Show()
    local hasPoison = self:HasWeaponEnchant()
    local stacks = hasPoison and 5 or 0
    local isFull = stacks == 5
    for i = 1, 5 do
        local color
        if isFull then
            color = FEATURE_COLORS.POISON_FULL
        else
            color = i <= stacks and FEATURE_COLORS.POISON_FILLED or FEATURE_COLORS.POISON_EMPTY
        end
        self.poisonSquares[i]:SetVertexColor(unpack(color))
    end
end

function SpellQueue:HasWeaponEnchant()
    local hasMainHandEnchant, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
    return hasMainHandEnchant or hasOffHandEnchant
end

function SpellQueue:ToggleDisplayMode()
    if self.displayMode == MODE_COMBAT_ONLY then
        self.displayMode = MODE_ALWAYS_VISIBLE
    elseif self.displayMode == MODE_ALWAYS_VISIBLE then
        self.displayMode = MODE_ALWAYS_HIDDEN
    else
        self.displayMode = MODE_COMBAT_ONLY
    end
    ns_dbc:modKey("настройки", "Skill Queue mode", self.displayMode)
    self:ApplyDisplayMode()
    local modeText = {
        [MODE_COMBAT_ONLY] = "'Только в бою'",
        [MODE_ALWAYS_VISIBLE] = "'Всегда видимый'",
        [MODE_ALWAYS_HIDDEN] = "'Всегда скрыт'"
    }
    print("SpellQueue: Режим " .. (modeText[self.displayMode] or "'неизвестен'"))
end

function SpellQueue:RegisterAllEvents()
    if not self.combatRegistered then
        self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self.frame:RegisterEvent("UNIT_POWER")
        self.frame:RegisterEvent("UNIT_AURA")
        self.frame:SetScript("OnEvent", function(_, event, ...)
            if event == "PLAYER_REGEN_DISABLED" then
                self:EnterCombat()
            elseif event == "PLAYER_REGEN_ENABLED" then
                self:LeaveCombat()
            elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
                local timestamp, subEvent, hideCaster,
                    sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                    destGUID, destName, destFlags, destRaidFlags,
                    spellID, spellName, spellSchool = ...
                self:ProcessCombatLogEvent(timestamp, subEvent, hideCaster,
                    sourceGUID, sourceName, sourceFlags, sourceRaidFlags,
                    destGUID, destName, destFlags, destRaidFlags,
                    spellID, spellName, spellSchool)
            elseif event == "UNIT_POWER" then
                local unit, powerType = ...
                if unit == "player" then
                    self:ForceUpdateAllSpells()
                end
            elseif event == "UNIT_AURA" then
                local unit = ...
                if unit == "player" or unit == "target" then
                    self:ForceUpdateAllSpells()
                end
            end
        end)
        self.combatRegistered = true
    end
end

function SpellQueue:ProcessCombatLogEvent(...)
    local args = {...}
    local timestamp = args[1]
    local eventType = args[2]
    local sourceGUID = args[3]
    local sourceName = args[4]
    local sourceFlags = args[5]
    local destGUID = args[6]
    local destName = args[7]
    local destFlags = args[8]
    local spellID = args[9]
    local spellName = args[10]
    local spellSchool = args[11]
    local auraType = args[12]
    
    local playerGUID = UnitGUID("player")
    local playerName = UnitName("player")
    
    -- Отслеживание щита
    if spellName == "Слово силы: Щит" then
        
        if (eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH") 
            and destGUID == playerGUID then
            
            if SHIELD_CACHE.maxAbsorb == 0 then
                SHIELD_CACHE.maxAbsorb = 5000
            end
            
            SHIELD_CACHE.currentAbsorb = SHIELD_CACHE.maxAbsorb
            SHIELD_CACHE.isActive = true
            self.shieldStartTime = GetTime()
            self.shieldTotalAbsorbed = 0
            self:UpdateShieldBar()
            
        elseif eventType == "SPELL_AURA_REMOVED" 
            and destGUID == playerGUID then
            
            if self.shieldTotalAbsorbed and self.shieldTotalAbsorbed > 0 then
                table.insert(SHIELD_CACHE.history, self.shieldTotalAbsorbed)
                while #SHIELD_CACHE.history > SHIELD_CACHE.historySize do
                    table.remove(SHIELD_CACHE.history, 1)
                end
                local sum = 0
                for _, val in ipairs(SHIELD_CACHE.history) do
                    sum = sum + val
                end
                SHIELD_CACHE.maxAbsorb = math.floor(sum / #SHIELD_CACHE.history)
            end
            
            SHIELD_CACHE.isActive = false
            SHIELD_CACHE.currentAbsorb = 0
            self.shieldStartTime = nil
            self.shieldTotalAbsorbed = nil
            self:UpdateShieldBar()
        end
    end
    
    -- Отслеживание урона под щитом
    if destGUID == playerGUID and SHIELD_CACHE.isActive then
        
        if eventType == "SWING_MISSED" and args[9] == "ABSORB" then
            local absorbed = args[10] or 0
            SHIELD_CACHE.currentAbsorb = math.max(0, SHIELD_CACHE.currentAbsorb - absorbed)
            self.shieldTotalAbsorbed = (self.shieldTotalAbsorbed or 0) + absorbed
            self:UpdateShieldBar()
            
        elseif eventType == "SPELL_MISSED" and args[12] == "ABSORB" then
            local absorbed = args[13] or 0
            SHIELD_CACHE.currentAbsorb = math.max(0, SHIELD_CACHE.currentAbsorb - absorbed)
            self.shieldTotalAbsorbed = (self.shieldTotalAbsorbed or 0) + absorbed
            self:UpdateShieldBar()
            
        elseif eventType == "SWING_DAMAGE" then
            local absorbed = args[14] or 0
            if absorbed > 0 then
                SHIELD_CACHE.currentAbsorb = math.max(0, SHIELD_CACHE.currentAbsorb - absorbed)
                self.shieldTotalAbsorbed = (self.shieldTotalAbsorbed or 0) + absorbed
                self:UpdateShieldBar()
            end
            
        elseif eventType == "SPELL_DAMAGE" or eventType == "SPELL_PERIODIC_DAMAGE" then
            local absorbed = args[17] or args[18] or args[14] or 0
            if absorbed > 0 then
                SHIELD_CACHE.currentAbsorb = math.max(0, SHIELD_CACHE.currentAbsorb - absorbed)
                self.shieldTotalAbsorbed = (self.shieldTotalAbsorbed or 0) + absorbed
                self:UpdateShieldBar()
            end
        end
    end
    
    -- Оригинальная логика
    if args[3] ~= UnitGUID("player") then
        return
    end
    
    if eventType == "SPELL_MISSED" then
        spellName = args[10]
        self:SpellUsed(spellName)
    elseif eventType == "SWING_MISSED" then
        spellName = "Атака ближнего боя"
        self:SpellUsed(spellName)
    else
        spellName = eventType:find("SPELL") and args[10] or "Атака ближнего боя"
        if eventType == "SPELL_CAST_SUCCESS" then
            self:SpellUsed(spellName)
        elseif eventType == "SPELL_AURA_APPLIED" and args[12] == "BUFF" then
            self:UpdateBuffState(spellName, true)
        elseif eventType == "SPELL_AURA_REMOVED" and args[12] == "BUFF" then
            self:UpdateBuffState(spellName, false)
        elseif eventType == "SPELL_AURA_APPLIED" and args[12] == "DEBUFF" then
            self:CheckAllDebuffs()
        elseif eventType == "SPELL_AURA_REMOVED" and args[12] == "DEBUFF" then
            self:CheckAllDebuffs()
        elseif eventType == "SPELL_DAMAGE" then
            self:SpellUsed(spellName)
        end
    end
end

-- НОВЫЙ МЕТОД: Получение актуального значения щита из баффа
function SpellQueue:GetShieldAmountFromBuff()
    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, shieldAbsorb = UnitBuff("player", i)
        if not name then break end
        if name == "Слово силы: Щит" then
            if shieldAbsorb and shieldAbsorb > 0 then
                return shieldAbsorb
            end
        end
    end
    return nil
end

-- Исправленный метод GetTalentRank
function SpellQueue:GetTalentRank(talentName)
    -- GetTalentInfo(tabIndex, talentIndex) - tabIndex: 1,2,3 (ветка), talentIndex: 1-...
    -- Improved Power Word: Shield находится во 2-й ветке (Discipline), 2-й талант
    local talentPositions = {
        ["Improved Power Word: Shield"] = {tab = 2, index = 2}
    }
    
    if talentPositions[talentName] then
        local pos = talentPositions[talentName]
        -- Проверяем, изучен ли талант (у персонажа)
        local name, _, _, _, currentRank, _, _, _ = GetTalentInfo(pos.tab, pos.index)
        if name and name == talentName then
            return currentRank or 0
        end
    end
    return 0
end

function SpellQueue:_HasShield()
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        if not name then break end
        if name == "Слово силы: Щит" then
            return true
        end
    end
    return false
end

function SpellQueue:CheckAllDebuffs()
    for spellName, spell in pairs(self.spells) do
        if spell.data.debuf then
            self:UpdateDebuffState(spellName)
        end
    end
end

function SpellQueue:EnterCombat()
    self.inCombat = true
    self:ApplyDisplayMode()
    for spellName, _ in pairs(self.spells) do
        self:UpdateSpellPosition(spellName)
    end
    self:UpdateSpellsPriority()
end

function SpellQueue:LeaveCombat()
    self.inCombat = false
    self:ClearTimers()
    self:ApplyDisplayMode()
end

function SpellQueue:SetIconsTable(tblIcons)
    if type(tblIcons) ~= "table" then
        return
    end
    self.tblIcons = tblIcons or {}
    self.spells = self.spells or {}
    for spellName, spell in pairs(self.spells) do
        if spell.icon then
            spell.icon:Hide()
        end
        if spell.glow then
            spell.glow:Hide()
        end
        if spell.cooldownText then
            spell.cooldownText:Hide()
        end
        if spell.cooldownFrame then
            spell.cooldownFrame:Hide()
        end
    end
    wipe(self.spells)
    local createdCount = 0
    for spellName, spellData in pairs(self.tblIcons) do
        if type(spellName) == "string" and type(spellData) == "table" then
            local iconSize = self.iconSize or (self.height - 10)
            local glowSize = iconSize + (self.glowSizeOffset or 10)
            local highlightSize = iconSize + (self.highlightSizeOffset or 15)
            local spellInfoName, _, spellIcon = GetSpellInfo(spellName)
            local texturePath = spellData.icon or spellIcon or "Interface\\Icons\\INV_Misc_QuestionMark"
            local icon = self.frame:CreateTexture(nil, "OVERLAY")
            icon:SetTexture(texturePath)
            icon:SetSize(iconSize, iconSize)
            icon:Hide()
            local glow = self.frame:CreateTexture(nil, "ARTWORK")
            glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            glow:SetBlendMode("ADD")
            glow:SetAlpha(self.glowAlpha or 0.3)
            glow:SetSize(glowSize, glowSize)
            glow:SetPoint("CENTER", icon, "CENTER")
            glow:Hide()
            local cooldownText = self.frame:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
            cooldownText:SetPoint("CENTER", icon, "CENTER")
            cooldownText:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
            cooldownText:SetTextColor(1, 1, 0.5)
            cooldownText:Hide()
            local highlight = self.frame:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            highlight:SetBlendMode("ADD")
            highlight:SetAlpha(0)
            highlight:SetSize(highlightSize, highlightSize)
            highlight:SetPoint("CENTER", icon, "CENTER")
            highlight:Hide()
            local cooldownFrame = CreateFrame("Cooldown", nil, self.frame)
            cooldownFrame:SetAllPoints(icon)
            cooldownFrame:Hide()
            local newData = {
                pos = spellData.pos or 0,
                buf = spellData.buf or 0,
                debuf = spellData.debuf or nil,
                combo = spellData.combo or 0,
                icon = texturePath,
                name = spellName,
                resource = spellData.resource and {
                    type = spellData.resource.type,
                    amount = spellData.resource.amount
                } or nil,
                prok = spellData.prok,
                texture = spellData.texture,
                priority = spellData.priority or 0
            }
            local initPos = (spellData.pos or 0) * (iconSize + (self.iconSpacing or 5))
            self.spells[spellName] = {
                data = newData,
                icon = icon,
                glow = glow,
                cooldownText = cooldownText,
                highlight = highlight,
                cooldownFrame = cooldownFrame,
                active = false,
                remaining = 0,
                total = 0,
                position = initPos,
                isReady = false,
                hasBuff = false,
                hasDebuff = false,
                startTime = nil,
                endTime = nil,
                readyPosition = initPos,
                lastPosition = -9999,
                lastStart = 0,
                lastDuration = 0,
                visualIndex = 0,
                cooldownTargetPosition = initPos
            }
            createdCount = createdCount + 1
        end
    end
end

function SpellQueue:HasEnoughResource(spellName)
    local spell = self.spells[spellName]
    if not spell or not spell.data.resource then
        return true
    end
    local resourceType = spell.data.resource.type
    local requiredAmount = spell.data.resource.amount or 0
    local current = UnitPower("player", resourceType)
    return current >= requiredAmount
end

function SpellQueue:HasEnoughComboPoints(required)
    local cp = GetComboPoints("player", "target")
    return cp and cp >= required
end

function SpellQueue:SetAlpha(alpha)
    self.alpha = alpha
    if self.inCombat then
        self.frame:SetAlpha(alpha)
    end
end

function SpellQueue:SetAnchored(anchored)
    self.isAnchored = anchored
    self:UpdateClickThrough()
    if anchored then
        self.frame:StopMovingOrSizing()
    end
end

function SpellQueue:UpdateClickThrough()
    self.frame:EnableMouse(not self.isClickThrough)
    self.frame:SetMovable(not self.isClickThrough)
    if self.isClickThrough then
        self.frame:RegisterForDrag()
    else
        self.frame:RegisterForDrag("LeftButton")
    end
    if self.configButton then
        self.configButton:EnableMouse(not self.isClickThrough)
    end
end

function SpellQueue:SetupDrag()
    self.frame:SetScript("OnMouseDown", function(frame, button)
        if self.isClickThrough then
            return
        end
        if not self.isAnchored and button == "LeftButton" then
            frame:StartMoving()
        end
    end)
    self.frame:SetScript("OnMouseUp", function(frame, button)
        if self.isClickThrough then
            return
        end
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
            local point, _, relativePoint, x, y = frame:GetPoint(1)
            ns_dbc:modKey("настройки", "Skill Queue position", "x", x)
            ns_dbc:modKey("настройки", "Skill Queue position", "y", y)
            _G.nsDbc.SpellQueuePosition = {
                point = point,
                relativePoint = relativePoint,
                x = x,
                y = y
            }
        elseif button == "RightButton" then
            self.isAnchored = false
            self.isClickThrough = not self.isClickThrough
            self.frame:EnableMouse(not self.isClickThrough)
            self.frame:SetMovable(not self.isClickThrough)
            if self.isClickThrough then
                self.frame:RegisterForDrag()
                self.frame:SetAlpha(INACTIVE_ALPHA)
            else
                self.frame:RegisterForDrag("LeftButton")
                self.frame:SetAlpha(self.alpha)
            end
        end
    end)
end

function SpellQueue:SetClickThrough(enable)
    self.isClickThrough = enable == 1
    self:UpdateClickThrough()
    print(string.format("SpellQueue: ClickThrough %s", self.isClickThrough and "enabled" or "disabled"))
end

function SpellQueue:SpellUsed(spellName)
    local spell = self.spells[spellName]
    if not spell then
        return
    end
    self:ForceUpdateAllSpells()
end

function SpellQueue:UpdateSpellPosition(spellName)
    local spell = self.spells[spellName]
    if not spell then
        return
    end
    spell.cooldownText:Hide()
    -- Обработка текстур прока (ProkIconManager)
    if spell.data.texture then
        local wasVisible = spell.textureVisible or false
        spell.textureVisible = false
        local iconData = nil
        if ProkIconManager and ProkIconManager.icons and ProkIconManager.icons[spellName] then
            iconData = ProkIconManager.icons[spellName]
        elseif nsDbc and nsDbc.proks and nsDbc.proks[spellName] then
            iconData = nsDbc.proks[spellName]
        elseif nsDbc and nsDbc.proks then
            for name, data in pairs(nsDbc.proks) do
                if data.spellqueue_name == spellName then
                    iconData = data
                    break
                end
            end
        end
        local isUsable = IsUsableSpell(spellName)
        if iconData then
            if iconData.triggerType == "custom" and isUsable then
                if spell.data.prok then
                    if UnitExists("target") and UnitCanAttack("player", "target") then
                        local maxHP = UnitHealthMax("target")
                        if maxHP > 0 then
                            local hpPercent = (UnitHealth("target") / maxHP) * 100
                            if hpPercent <= spell.data.prok then
                                spell.textureVisible = true
                            end
                        end
                    end
                else
                    spell.textureVisible = true
                end
            elseif iconData.triggerType == "buff" then
                if self:HasBuff(iconData.name) then
                    spell.textureVisible = true
                end
            end
        end
        if spell.textureVisible ~= wasVisible then
            if spell.textureVisible then
                self:ShowProkTexture(spellName, iconData)
            else
                self:HideProkTexture(spellName)
            end
        end
        spell.icon:SetAlpha(INACTIVE_ALPHA)
        spell.icon:Show()
        spell.glow:Show()
        spell.glow:SetAlpha(0)
        return
    end
    -- Проверка условий активации (проки, комбо, ресурсы, баффы)
    local prokActive = true
    if spell.data.prok then
        if not UnitExists("target") or not UnitCanAttack("player", "target") then
            prokActive = false
        else
            local maxHP = UnitHealthMax("target")
            if maxHP <= 0 then
                prokActive = false
            else
                local hpPercent = (UnitHealth("target") / maxHP) * 100
                if hpPercent > spell.data.prok then
                    prokActive = false
                end
            end
        end
    end
    local comboOk = true
    if spell.data.combo and spell.data.combo > 0 then
        if not self:HasEnoughComboPoints(spell.data.combo) then
            comboOk = false
        end
    end
    local resourceOk = true
    if spell.data.resource then
        if not self:HasEnoughResource(spellName) then
            resourceOk = false
        end
    end
    local buffOk = true
    if spell.data.buf then
        local buffName = type(spell.data.buf) == "string" and spell.data.buf or spellName
        spell.hasBuff = self:HasBuff(buffName)
        if spell.hasBuff then
            buffOk = false
        end
    end
    -- Проверка дебаффа на цели
    local isDebuffActive = false
    local debuffRemaining = 0
    if spell.data.debuf then
        self:UpdateDebuffState(spellName)
        if spell.hasDebuff and spell.debuffExpirationTime and spell.debuffExpirationTime > 0 then
            local now = GetTime()
            if spell.debuffExpirationTime > now then
                isDebuffActive = true
                debuffRemaining = spell.debuffExpirationTime - now
            end
        end
    end
    -- Проверка кулдауна
    local start, duration, enabled = GetSpellCooldown(spellName)
    local remaining, fullDuration = 0, 0
    if start and duration and start ~= 0 and duration ~= 0 then
        local now = GetTime()
        remaining = (start + duration) - now
        remaining = remaining > 0 and remaining or 0
        fullDuration = duration
    end
    local isGCD = (fullDuration > 0 and fullDuration < 2.0)
    local oldIsReady = spell.isReady
    if isGCD then
        spell.active = false
        spell.isReady = true
        spell.remaining = 0
    else
        spell.active = remaining and remaining > 0
        spell.isReady = not spell.active
        spell.remaining = remaining
    end
    if oldIsReady ~= spell.isReady then
        self.priorityDirty = true
    end
    local gcdChanged = (spell.lastStart ~= start or spell.lastDuration ~= duration)
    spell.lastStart = start
    spell.lastDuration = duration
    if gcdChanged and isGCD then
        self.priorityDirty = true
    end
    local shouldHide = false
    if spell.data.buf and not buffOk then
        shouldHide = true
    end
    -- Логика прозрачности (Alpha)
    local alpha = READY_ALPHA
    if spell.active then
        alpha = COOLDOWN_ALPHA
    end
    -- Дебафф делает скилл полупрозрачным независимо от КД
    if isDebuffActive then
        alpha = DEBUFF_ALPHA
    end
    -- Проверка ресурсов не должна полностью скрывать дебафф
    if not resourceOk then
        if isDebuffActive then
            alpha = DEBUFF_ALPHA * NO_RESOURCE_ALPHA
        else
            alpha = INACTIVE_ALPHA
        end
    end
    if not comboOk then
        alpha = alpha * NO_RESOURCE_ALPHA
    end
    if not buffOk then
        alpha = INACTIVE_ALPHA
    end
    if not prokActive then
        alpha = INACTIVE_ALPHA
    end
    local isUsable = IsUsableSpell(spellName)
    -- isUsable проверка не переопределяет дебафф-альфу
    if not isUsable and not isDebuffActive then
        alpha = INACTIVE_ALPHA
    end
    -- Отображение текста кулдауна
    if isDebuffActive and not spell.active then
        if spell.cooldownFrame then
            spell.cooldownFrame:Hide()
        end
        if debuffRemaining > 3 then
            spell.cooldownText:SetText(math.floor(debuffRemaining))
        else
            spell.cooldownText:SetText(string.format("%.1f", debuffRemaining))
        end
        spell.cooldownText:Show()
    elseif isGCD then
        if spell.cooldownFrame then
            if gcdChanged then
                spell.cooldownFrame:SetCooldown(start, duration)
            end
            spell.cooldownFrame:Show()
        end
        spell.cooldownText:Hide()
    else
        if spell.cooldownFrame then
            spell.cooldownFrame:Hide()
        end
        if remaining and remaining > 0 then
            if remaining > 3 then
                spell.cooldownText:SetText(math.floor(remaining))
            else
                spell.cooldownText:SetText(string.format("%.1f", remaining))
            end
            spell.cooldownText:Show()
        end
    end
    if shouldHide then
        spell.icon:Hide()
        spell.glow:Hide()
        spell.cooldownText:Hide()
        return
    end
    -- Применение прозрачности
    spell.icon:SetAlpha(alpha)
    spell.glow:SetAlpha(alpha * (self.glowAlpha or 0.3))
    if spell.active then
        spell.glow:SetVertexColor(unpack(COOLDOWN_GLOW_COLOR))
    elseif isDebuffActive then
        spell.glow:SetVertexColor(unpack(COOLDOWN_GLOW_COLOR))
    else
        spell.glow:SetVertexColor(unpack(READY_GLOW_COLOR))
    end
    -- Расчет позиции
    local iconSize = self.iconSize or (self.height - 10)
    local spacing = self.iconSpacing or 5
    local step = iconSize + spacing
    local maxPosition = self.width - iconSize
    local groupPos = spell.data.pos or 0
    local baseX = groupPos * step
    local targetPos = baseX
    if spell.active and fullDuration > 0 then
        -- Используем уникальную целевую позицию для каждого скилла на КД, чтобы избежать наложения
        local target = spell.cooldownTargetPosition or spell.readyPosition
        local cooldownStartPos = maxPosition
        local progress = 1 - (remaining / fullDuration)
        targetPos = cooldownStartPos - (cooldownStartPos - target) * progress
        targetPos = math.max(targetPos, target)
    else
        targetPos = spell.readyPosition
        if targetPos == -10000 or targetPos == nil then
            targetPos = baseX
        end
    end
    spell.position = targetPos
    spell.icon:ClearAllPoints()
    spell.icon:SetPoint("LEFT", self.frame, "LEFT", spell.position, 0)
    spell.lastPosition = spell.position
    spell.icon:Show()
    spell.glow:Show()
end

function SpellQueue:UpdateCooldownLayers()
    local shownSpells = {}
    for spellName, spell in pairs(self.spells) do
        if spell.icon:IsShown() then
            table.insert(shownSpells, spell)
        end
    end
    table.sort(shownSpells, function(a, b)
        if a.active ~= b.active then
            return a.active
        end
        return (a.remaining or 999) < (b.remaining or 999)
    end)
    for i, spell in ipairs(shownSpells) do
        spell.icon:SetDrawLayer("OVERLAY", i)
        spell.glow:SetDrawLayer("ARTWORK", i)
        spell.cooldownText:SetDrawLayer("OVERLAY", i + 10)
    end
end

function SpellQueue:GetSpellCooldown(spellName)
    local start, duration, enabled = GetSpellCooldown(spellName)
    if not start or not duration or start == 0 or duration == 0 then
        return 0, 0
    end
    local now = GetTime()
    local remaining = (start + duration) - now
    return remaining > 0 and remaining or 0, duration
end

function SpellQueue:HasBuff(buffName)
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        if not name then
            break
        end
        if name == buffName then
            return true
        end
    end
    return false
end

function SpellQueue:UpdateSpellsPriority()
    local iconSize = self.iconSize or (self.height - 10)
    local spacing = self.iconSpacing or 5
    local step = iconSize + spacing
    local groups = {}
    for name, spell in pairs(self.spells) do
        local pos = spell.data.pos or 0
        if not groups[pos] then
            groups[pos] = {}
        end
        table.insert(groups[pos], spell)
    end
    for pos, spells in pairs(groups) do
        table.sort(spells, function(a, b)
            local hideA = false
            if a.data.texture then
                hideA = true
            end
            if not hideA and a.data.buf then
                local bName = type(a.data.buf) == "string" and a.data.buf or a.data.name
                if self:HasBuff(bName) then
                    hideA = true
                end
            end
            local hideB = false
            if b.data.texture then
                hideB = true
            end
            if not hideB and b.data.buf then
                local bName = type(b.data.buf) == "string" and b.data.buf or b.data.name
                if self:HasBuff(bName) then
                    hideB = true
                end
            end
            if hideA and hideB then
                return a.data.name < b.data.name
            end
            if hideA then
                return false
            end
            if hideB then
                return true
            end
            local pA = a.data.priority or 0
            local pB = b.data.priority or 0
            if pA ~= pB then
                return pA < pB
            end
            return a.data.name < b.data.name
        end)
        local baseX = pos * step
        local maxPosition = self.width - iconSize
        local readySpells = {}
        local activeSpells = {}
        for i, spell in ipairs(spells) do
            local hide = false
            if spell.data.texture then
                hide = true
            end
            if not hide and spell.data.buf then
                local bName = type(spell.data.buf) == "string" and spell.data.buf or spell.data.name
                if self:HasBuff(bName) then
                    hide = true
                end
            end
            if hide then
                spell.readyPosition = -10000
            elseif not spell.active then
                table.insert(readySpells, spell)
            else
                table.insert(activeSpells, spell)
            end
        end
        -- Сортировка готовых скиллов (по приоритету)
        table.sort(readySpells, function(a, b)
            local pA = a.data.priority or 0
            local pB = b.data.priority or 0
            if pA ~= pB then
                return pA < pB
            end
            return a.data.name < b.data.name
        end)
        -- Сортировка активных скиллов (по времени отката, затем по приоритету)
        -- Меньшее время = ближе к готовым. При одинаковом времени = меньший приоритет ближе.
        table.sort(activeSpells, function(a, b)
            if a.remaining ~= b.remaining then
                return a.remaining < b.remaining
            end
            local pA = a.data.priority or 0
            local pB = b.data.priority or 0
            if pA ~= pB then
                return pA < pB
            end
            return a.data.name < b.data.name
        end)
        local readyIndex = 0
        for i, spell in ipairs(readySpells) do
            spell.readyPosition = math.min(baseX + readyIndex * step, maxPosition)
            spell.visualIndex = readyIndex
            readyIndex = readyIndex + 1
        end
        -- Активные скиллы выстраиваются после готовых, каждый в свой слот
        local lastReadyPos = baseX + readyIndex * step
        lastReadyPos = math.min(lastReadyPos, maxPosition)
        for i, spell in ipairs(activeSpells) do
            -- Уникальная целевая позиция для каждого скилла на КД
            spell.cooldownTargetPosition = math.min(baseX + (readyIndex + i - 1) * step, maxPosition)
            spell.visualIndex = -1
        end
        self.groupEndPositions[pos] = baseX + (readyIndex + #activeSpells) * step
        self.groupReadyCount[pos] = readyIndex
    end
end

function SpellQueue:CacheReturnPosition(spell)
    local iconSize = self.iconSize or (self.height - 10)
    local spacing = self.iconSpacing or 5
    local groupPos = spell.data.pos or 0
    local baseX = groupPos * (iconSize + spacing)
    local maxPosition = self.width - iconSize
    local lastOccupiedPos = baseX
    local visualIndex = 0
    for name, s in pairs(self.spells) do
        if s.isReady and s.data.pos == groupPos and s ~= spell then
            local shouldHide = false
            if s.data.buf == 1 and s.hasBuff then
                shouldHide = true
            end
            local resourceOk = true
            if s.data.resource then
                if not self:HasEnoughResource(name) then
                    resourceOk = false
                end
            end
            local comboOk = true
            if s.data.combo and s.data.combo > 0 then
                if not self:HasEnoughComboPoints(s.data.combo) then
                    comboOk = false
                end
            end
            if not shouldHide and resourceOk and comboOk then
                local x = baseX + visualIndex * (iconSize + spacing)
                lastOccupiedPos = math.min(x, maxPosition)
                visualIndex = visualIndex + 1
            end
        end
    end
    spell.returnPosition = lastOccupiedPos
end

function SpellQueue:CreateConfigWindow()
    local configFrame = CreateFrame("Frame", "SpellQueueConfig", UIParent)
    configFrame.parent = self
    configFrame.spellQueue = self
    configFrame:SetSize(310, 450)
    configFrame:SetPoint("CENTER")
    configFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame:Hide()

    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Настройки SpellQueue")

    local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        configFrame:Hide()
    end)

    local nameLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", 15, -45)
    nameLabel:SetText("Название скилла:")

    local editBox = CreateFrame("EditBox", "SpellQueueEditBox", configFrame, "InputBoxTemplate")
    editBox:SetSize(180, 20)
    editBox:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -5)
    editBox:SetAutoFocus(false)

    local deleteButton, addButton, loadPresetButton, presetDropdown
    local posDropdown
    local buffCheckButton, buffNameEditBox
    local debuffCheckButton, debuffNameEditBox
    local comboCheckButton, comboDropdown
    local resourceCheckButton, resourceDropdown, resourceAmountEditBox
    local prokCheckButton, prokHPEditBox
    local textureCheckButton
    local priorityCheckButton, priorityEditBox

    deleteButton = CreateFrame("Button", "SpellQueueDeleteButton", configFrame, "UIPanelButtonTemplate")
    deleteButton:SetSize(25, 25)
    deleteButton:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
    deleteButton:SetText("-")
    deleteButton:SetScript("OnClick", function()
        local spellName = editBox:GetText()
        if not spellName or spellName == "" then
            return
        end
        local name = GetSpellInfo(spellName)
        if not name then
            message("Скилл не найден!")
            return
        end
        if _G.nsDbc.skills3[PLAYER_KEY] and _G.nsDbc.skills3[PLAYER_KEY][name] then
            _G.nsDbc.skills3[PLAYER_KEY][name] = nil
            self:UpdateSkillTables()
            message("Скилл " .. name .. " удален!")
            editBox:SetText("")
        else
            message("Скилл " .. name .. " не найден в списке!")
        end
    end)

    addButton = CreateFrame("Button", "SpellQueueAddButton", configFrame, "UIPanelButtonTemplate")
    addButton:SetSize(25, 25)
    addButton:SetPoint("LEFT", deleteButton, "RIGHT", 5, 0)
    addButton:SetText("+")
    addButton:SetScript("OnClick", function()
        local spellName = editBox:GetText()
        if not spellName or spellName == "" then
            return
        end
        local name, _, icon = GetSpellInfo(spellName)
        if not name then
            message("Скилл не найден!")
            return
        end
        local comboValue = 0
        if comboCheckButton:GetChecked() then
            comboValue = UIDropDownMenu_GetSelectedValue(comboDropdown)
        end
        local resourceValue = nil
        if resourceCheckButton:GetChecked() then
            local amount = tonumber(resourceAmountEditBox:GetText()) or 0
            resourceValue = {
                type = UIDropDownMenu_GetSelectedValue(resourceDropdown),
                amount = amount
            }
        end
        local buffParam = nil
        if buffCheckButton:GetChecked() then
            local buffName = buffNameEditBox:GetText()
            buffParam = buffName ~= "" and buffName or 1
        end
        local debuffParam = nil
        if debuffCheckButton:GetChecked() then
            local debuffName = debuffNameEditBox:GetText()
            debuffParam = debuffName ~= "" and debuffName or 1
        end
        local prokParam = nil
        if prokCheckButton:GetChecked() then
            local hpPercent = tonumber(prokHPEditBox:GetText()) or 50
            if hpPercent < 0 then
                hpPercent = 0
            end
            if hpPercent > 100 then
                hpPercent = 100
            end
            prokParam = hpPercent
        end
        local textureParam = textureCheckButton:GetChecked()
        local priorityValue = 0
        if priorityCheckButton:GetChecked() then
            priorityValue = tonumber(priorityEditBox:GetText()) or 0
        end
        if not _G.nsDbc.skills3[PLAYER_KEY] then
            _G.nsDbc.skills3[PLAYER_KEY] = {}
        end
        _G.nsDbc.skills3[PLAYER_KEY][name] = {
            pos = UIDropDownMenu_GetSelectedValue(posDropdown),
            buf = buffParam,
            debuf = debuffParam,
            combo = comboValue,
            resource = resourceValue,
            prok = prokParam,
            texture = textureParam,
            icon = icon,
            priority = priorityValue
        }
        _G.SpellQueueInstance:UpdateSkillTables()
        if _G.SpellQueueInstance.inCombat then
            _G.SpellQueueInstance:ForceUpdateAllSpells()
        end
        editBox:SetText("")
        buffCheckButton:SetChecked(false)
        buffNameEditBox:SetText("")
        buffNameEditBox:Hide()
        debuffCheckButton:SetChecked(false)
        debuffNameEditBox:SetText("")
        debuffNameEditBox:Hide()
        comboCheckButton:SetChecked(false)
        comboDropdown:SetAlpha(0)
        resourceCheckButton:SetChecked(false)
        resourceDropdown:SetAlpha(0)
        resourceAmountEditBox:SetText("0")
        resourceAmountEditBox:Hide()
        prokCheckButton:SetChecked(false)
        prokHPEditBox:SetText("50")
        prokHPEditBox:Hide()
        textureCheckButton:SetChecked(false)
        priorityCheckButton:SetChecked(false)
        priorityEditBox:SetText("0")
        priorityEditBox:Hide()
        message("Скилл " .. name .. " добавлен!")
    end)

    -- Кнопка загрузки пресета
    loadPresetButton = CreateFrame("Button", "SpellQueueLoadPresetButton", configFrame, "UIPanelButtonTemplate")
    loadPresetButton:SetSize(25, 25)
    loadPresetButton:SetPoint("LEFT", addButton, "RIGHT", 5, 0)
    loadPresetButton:SetText("P")
    loadPresetButton:SetScript("OnClick", function()
        if presetDropdown:IsShown() then
            presetDropdown:Hide()
        else
            presetDropdown:Show()
        end
    end)

    -- Выпадающий список пресетов
    presetDropdown = CreateFrame("Frame", "SpellQueuePresetDropdown", configFrame, "UIDropDownMenuTemplate")
    presetDropdown:SetPoint("TOPLEFT", loadPresetButton, "BOTTOMLEFT", 0, -2)
    presetDropdown:Hide()
    UIDropDownMenu_SetWidth(presetDropdown, 150)

    local function PresetDropDown_Initialize()
        local info = UIDropDownMenu_CreateInfo()
        
        -- Пункт "Очистить всё"
        info.text = "|cffff0000Очистить всё|r"
        info.value = "clear"
        info.func = function()
            _G.nsDbc.skills3[PLAYER_KEY] = {}
            _G.SpellQueueInstance:UpdateSkillTables()
            if _G.SpellQueueInstance.inCombat then
                _G.SpellQueueInstance:ForceUpdateAllSpells()
            end
            print("SpellQueue: Все скиллы удалены!")
            presetDropdown:Hide()
        end
        UIDropDownMenu_AddButton(info)
        
        -- Разделитель
        info.text = ""
        info.value = "separator"
        info.func = nil
        info.disabled = true
        UIDropDownMenu_AddButton(info)
        
        -- Пресеты классов
        for className, spells in pairs(CLASS_PRESETS) do
            info.text = className
            info.value = className
            info.func = function()
                if not _G.nsDbc.skills3[PLAYER_KEY] then
                    _G.nsDbc.skills3[PLAYER_KEY] = {}
                end
                
                for spellName, spellData in pairs(spells) do
                    _G.nsDbc.skills3[PLAYER_KEY][spellName] = spellData
                end
                
                _G.SpellQueueInstance:UpdateSkillTables()
                if _G.SpellQueueInstance.inCombat then
                    _G.SpellQueueInstance:ForceUpdateAllSpells()
                end
                
                print("SpellQueue: Загружен пресет для " .. className)
                presetDropdown:Hide()
            end
            info.disabled = nil
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(presetDropdown, PresetDropDown_Initialize)

    local posLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    posLabel:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", 0, -15)
    posLabel:SetText("Позиция:")

    posDropdown = CreateFrame("Frame", "SpellQueuePosDropdown", configFrame, "UIDropDownMenuTemplate")
    posDropdown:SetPoint("TOPLEFT", posLabel, "BOTTOMLEFT", -15, -5)
    UIDropDownMenu_SetWidth(posDropdown, 100)
    local function PosDropDown_Initialize()
        local info = UIDropDownMenu_CreateInfo()
        for i = 0, 10 do
            info.text = i
            info.value = i
            info.func = function()
                UIDropDownMenu_SetSelectedValue(posDropdown, i)
            end
            UIDropDownMenu_AddButton(info)
        end
    end
    UIDropDownMenu_Initialize(posDropdown, PosDropDown_Initialize)
    UIDropDownMenu_SetSelectedValue(posDropdown, 0)

    buffCheckButton = CreateFrame("CheckButton", "SpellQueueBuffCheckButton", configFrame, "UICheckButtonTemplate")
    buffCheckButton:SetSize(24, 24)
    buffCheckButton:SetPoint("TOPLEFT", posDropdown, "BOTTOMLEFT", 15, -10)
    buffCheckButton.text = buffCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buffCheckButton.text:SetText("Бафф")
    buffCheckButton.text:SetPoint("LEFT", buffCheckButton, "RIGHT", 5, 0)
    buffNameEditBox = CreateFrame("EditBox", "SpellQueueBuffNameEditBox", configFrame, "InputBoxTemplate")
    buffNameEditBox:SetSize(150, 20)
    buffNameEditBox:SetPoint("LEFT", buffCheckButton.text, "RIGHT", 10, 0)
    buffNameEditBox:SetAutoFocus(false)
    buffNameEditBox:Hide()
    buffCheckButton:SetScript("OnClick", function(self)
        if self:GetChecked() then
            buffNameEditBox:Show()
        else
            buffNameEditBox:Hide()
            buffNameEditBox:SetText("")
        end
    end)

    debuffCheckButton = CreateFrame("CheckButton", "SpellQueueDebuffCheckButton", configFrame, "UICheckButtonTemplate")
    debuffCheckButton:SetSize(24, 24)
    debuffCheckButton:SetPoint("TOPLEFT", buffCheckButton, "BOTTOMLEFT", 0, -10)
    debuffCheckButton.text = debuffCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debuffCheckButton.text:SetText("Дебафф")
    debuffCheckButton.text:SetPoint("LEFT", debuffCheckButton, "RIGHT", 5, 0)
    debuffNameEditBox = CreateFrame("EditBox", "SpellQueueDebuffNameEditBox", configFrame, "InputBoxTemplate")
    debuffNameEditBox:SetSize(150, 20)
    debuffNameEditBox:SetPoint("LEFT", debuffCheckButton.text, "RIGHT", 10, 0)
    debuffNameEditBox:SetAutoFocus(false)
    debuffNameEditBox:Hide()
    debuffCheckButton:SetScript("OnClick", function(self)
        if self:GetChecked() then
            debuffNameEditBox:Show()
        else
            debuffNameEditBox:Hide()
            debuffNameEditBox:SetText("")
        end
    end)

    comboCheckButton = CreateFrame("CheckButton", "SpellQueueComboCheckButton", configFrame, "UICheckButtonTemplate")
    comboCheckButton:SetSize(24, 24)
    comboCheckButton:SetPoint("TOPLEFT", debuffCheckButton, "BOTTOMLEFT", 0, -10)
    comboCheckButton.text = comboCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    comboCheckButton.text:SetText("Комбо-поинты:")
    comboCheckButton.text:SetPoint("LEFT", comboCheckButton, "RIGHT", 5, 0)
    comboDropdown = CreateFrame("Frame", "SpellQueueComboDropdown", configFrame, "UIDropDownMenuTemplate")
    comboDropdown:SetPoint("LEFT", comboCheckButton.text, "RIGHT", 10, 0)
    comboDropdown:SetAlpha(0)
    UIDropDownMenu_SetWidth(comboDropdown, 50)
    local function ComboDropDown_Initialize()
        local info = UIDropDownMenu_CreateInfo()
        for i = 1, 5 do
            info.text = i
            info.value = i
            info.func = function()
                UIDropDownMenu_SetSelectedValue(comboDropdown, i)
            end
            UIDropDownMenu_AddButton(info)
        end
    end
    UIDropDownMenu_Initialize(comboDropdown, ComboDropDown_Initialize)
    UIDropDownMenu_SetSelectedValue(comboDropdown, 1)
    comboCheckButton:SetScript("OnClick", function(self)
        if self:GetChecked() then
            comboDropdown:SetAlpha(1)
        else
            comboDropdown:SetAlpha(0)
        end
    end)

    resourceCheckButton = CreateFrame("CheckButton", "SpellQueueResourceCheckButton", configFrame, "UICheckButtonTemplate")
    resourceCheckButton:SetSize(24, 24)
    resourceCheckButton:SetPoint("TOPLEFT", comboCheckButton, "BOTTOMLEFT", 0, -10)
    resourceCheckButton.text = resourceCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resourceCheckButton.text:SetText("Ресурс:")
    resourceCheckButton.text:SetPoint("LEFT", resourceCheckButton, "RIGHT", 5, 0)
    resourceDropdown = CreateFrame("Frame", "SpellQueueResourceDropdown", configFrame, "UIDropDownMenuTemplate")
    resourceDropdown:SetPoint("LEFT", resourceCheckButton.text, "RIGHT", 10, 0)
    resourceDropdown:SetAlpha(0)
    UIDropDownMenu_SetWidth(resourceDropdown, 120)
    local function ResourceDropDown_Initialize()
        local info = UIDropDownMenu_CreateInfo()
        local resources = {
            {text = "Мана", value = 0},
            {text = "Ярость", value = 1},
            {text = "Энергия", value = 3},
            {text = "Сила рун", value = 6},
            {text = "Комбо-поинты", value = 14}
        }
        for _, res in ipairs(resources) do
            info.text = res.text
            info.value = res.value
            info.func = function()
                UIDropDownMenu_SetSelectedValue(resourceDropdown, res.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end
    UIDropDownMenu_Initialize(resourceDropdown, ResourceDropDown_Initialize)
    UIDropDownMenu_SetSelectedValue(resourceDropdown, 0)
    resourceAmountEditBox = CreateFrame("EditBox", "SpellQueueResourceAmountEditBox", configFrame, "InputBoxTemplate")
    resourceAmountEditBox:SetSize(50, 20)
    resourceAmountEditBox:SetPoint("LEFT", resourceDropdown, "RIGHT", 15, 0)
    resourceAmountEditBox:SetAutoFocus(false)
    resourceAmountEditBox:Hide()
    resourceAmountEditBox:SetText("0")
    resourceCheckButton:SetScript("OnClick", function(self)
        if self:GetChecked() then
            resourceDropdown:SetAlpha(1)
            resourceAmountEditBox:Show()
        else
            resourceDropdown:SetAlpha(0)
            resourceAmountEditBox:Hide()
            resourceAmountEditBox:SetText("0")
        end
    end)

    prokCheckButton = CreateFrame("CheckButton", "SpellQueueProkCheckButton", configFrame, "UICheckButtonTemplate")
    prokCheckButton:SetSize(24, 24)
    prokCheckButton:SetPoint("TOPLEFT", resourceCheckButton, "BOTTOMLEFT", 0, -10)
    prokCheckButton.text = prokCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    prokCheckButton.text:SetText("Прок")
    prokCheckButton.text:SetPoint("LEFT", prokCheckButton, "RIGHT", 5, 0)
    prokHPEditBox = CreateFrame("EditBox", "SpellQueueProkHPEditBox", configFrame, "InputBoxTemplate")
    prokHPEditBox:SetSize(50, 20)
    prokHPEditBox:SetPoint("LEFT", prokCheckButton.text, "RIGHT", 10, 0)
    prokHPEditBox:SetAutoFocus(false)
    prokHPEditBox:Hide()
    prokHPEditBox:SetText("50")
    prokCheckButton:SetScript("OnClick", function(self)
        if self:GetChecked() then
            prokHPEditBox:Show()
        else
            prokHPEditBox:Hide()
            prokHPEditBox:SetText("50")
        end
    end)

    textureCheckButton = CreateFrame("CheckButton", "SpellQueueTextureCheckButton", configFrame, "UICheckButtonTemplate")
    textureCheckButton:SetSize(24, 24)
    textureCheckButton:SetPoint("TOPLEFT", prokCheckButton, "BOTTOMLEFT", 0, -10)
    textureCheckButton.text = textureCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textureCheckButton.text:SetText("Текстура")
    textureCheckButton.text:SetPoint("LEFT", textureCheckButton, "RIGHT", 5, 0)

    priorityCheckButton = CreateFrame("CheckButton", "SpellQueuePriorityCheckButton", configFrame, "UICheckButtonTemplate")
    priorityCheckButton:SetSize(24, 24)
    priorityCheckButton:SetPoint("TOPLEFT", textureCheckButton, "BOTTOMLEFT", 0, -10)
    priorityCheckButton.text = priorityCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    priorityCheckButton.text:SetText("Приоритет:")
    priorityCheckButton.text:SetPoint("LEFT", priorityCheckButton, "RIGHT", 5, 0)
    priorityEditBox = CreateFrame("EditBox", "SpellQueuePriorityEditBox", configFrame, "InputBoxTemplate")
    priorityEditBox:SetSize(50, 20)
    priorityEditBox:SetPoint("LEFT", priorityCheckButton.text, "RIGHT", 10, 0)
    priorityEditBox:SetAutoFocus(false)
    priorityEditBox:Hide()
    priorityEditBox:SetText("0")
    priorityCheckButton:SetScript("OnClick", function(self)
        if self:GetChecked() then
            priorityEditBox:Show()
        else
            priorityEditBox:Hide()
            priorityEditBox:SetText("0")
        end
    end)

    self.configFrame = configFrame
end

function SpellQueue:UpdateSkillTables()
    _G.nsDbc = _G.nsDbc or {}
    _G.nsDbc.skills3 = _G.nsDbc.skills3 or {}
    _G.nsDbc.skills3[PLAYER_KEY] = _G.nsDbc.skills3[PLAYER_KEY] or {}
    local combined = {}
    if self.tblIcons then
        for k, v in pairs(self.tblIcons) do
            combined[k] = v
            if not combined[k].resource then
                combined[k].resource = nil
            end
        end
    end
    if _G.nsDbc.skills3[PLAYER_KEY] then
        for k, v in pairs(_G.nsDbc.skills3[PLAYER_KEY]) do
            if not combined[k] then
                combined[k] = v
                if not combined[k].resource then
                    combined[k].resource = nil
                end
            end
        end
    end
    self:SetIconsTable(combined)
end

function SpellQueue:ForceUpdateAllSpells()
    self.frame:SetWidth(self.width)
    self.frame:SetHeight(self.height)
    self:UpdateComboPoints()
    self:UpdatePoisonStacks()
    self:UpdateResourceBars()
    self:UpdateShieldBar()
    self.priorityDirty = true
    for spellName, spell in pairs(self.spells) do
        local remaining, fullDuration = self:GetSpellCooldown(spellName)
        spell.active = remaining and remaining > 0
        spell.isReady = not spell.active
        spell.remaining = remaining
        spell.lastStart = 0
        spell.lastDuration = 0
        self.lastReadyState[spellName] = spell.isReady
        if spell.data.buf and spell.data.buf ~= 0 then
            local buffName = type(spell.data.buf) == "string" and spell.data.buf or spellName
            spell.hasBuff = self:HasBuff(buffName)
        end
        if spell.data.debuf then
            self:UpdateDebuffState(spellName)
        end
        if spell.icon and not spell.icon:GetTexture() then
            local _, _, spellIcon = GetSpellInfo(spellName)
            if spellIcon then
                spell.icon:SetTexture(spellIcon)
            end
        end
    end
    self:UpdateSpellsPriority()
    for spellName, spell in pairs(self.spells) do
        self:UpdateSpellPosition(spellName)
    end
    self:UpdateCooldownLayers()
end

function SpellQueue:SetAppearanceSettings(options)
    self.glowSizeOffset = options.glowSizeOffset or 10
    self.glowAlpha = options.glowAlpha or 0.3
    self.highlightSizeOffset = options.highlightSizeOffset or 15
    self.iconSize = options.iconSize or (self.height - 10)
    self.iconSpacing = options.iconSpacing or 5
    if options.clickThrough ~= nil then
        if options.clickThrough == 1 then
            self.isAnchored = false
            self.isClickThrough = true
            self.frame:EnableMouse(false)
            self.frame:SetMovable(false)
            self.frame:RegisterForDrag()
            self.frame:SetAlpha(INACTIVE_ALPHA)
        else
            self.isAnchored = false
            self.isClickThrough = false
            self.frame:EnableMouse(true)
            self.frame:SetMovable(true)
            self.frame:RegisterForDrag("LeftButton")
            self.frame:SetAlpha(self.alpha)
        end
    end
    for _, spell in pairs(self.spells) do
        if spell.icon then
            spell.icon:SetSize(self.iconSize, self.iconSize)
        end
        if spell.glow then
            local glowSize = self.iconSize + self.glowSizeOffset
            spell.glow:SetSize(glowSize, glowSize)
            spell.glow:SetAlpha(self.glowAlpha)
            spell.glow:SetPoint("CENTER", spell.icon, "CENTER")
        end
        if spell.highlight then
            local highlightSize = self.iconSize + self.highlightSizeOffset
            spell.highlight:SetSize(highlightSize, highlightSize)
            spell.highlight:SetPoint("CENTER", spell.icon, "CENTER")
        end
    end
    if options.width then
        self.width = options.width
        self.frame:SetWidth(self.width)
    end
    if options.height then
        self.height = options.height
        self.frame:SetHeight(self.height)
    end
    if options.scale then
        self.scale = options.scale
        self.frame:SetScale(self.scale)
    end
    if options.alpha then
        self.alpha = options.alpha
        if self.inCombat then
            self.frame:SetAlpha(self.alpha)
        end
    end
    if options.inactiveAlpha then
        INACTIVE_ALPHA = options.inactiveAlpha
        if not self.inCombat then
            self.frame:SetAlpha(INACTIVE_ALPHA)
        end
    end
    if options.healthBarHeight then
        self.healthBar:SetHeight(options.healthBarHeight)
    end
    if options.healthBarOffset then
        self.healthBar:ClearAllPoints()
        self.healthBar:SetPoint("TOP", self.frame, "TOP", 0, options.healthBarOffset or 10)
    end
    if options.healthBarColor then
        self.healthBar:SetVertexColor(unpack(options.healthBarColor))
    end
    if options.shieldBarHeight then
        SHIELD_BAR_HEIGHT = options.shieldBarHeight
        self.shieldBar:SetHeight(options.shieldBarHeight)
    end
    if options.shieldBarOffset then
        self.shieldBar:ClearAllPoints()
        self.shieldBar:SetPoint("BOTTOM", self.healthBar, "TOP", 0, options.shieldBarOffset or 2)
    end
    if options.shieldBarColor then
        self.shieldBar:SetVertexColor(unpack(options.shieldBarColor))
    end
    if options.resourceBarHeight then
        self.resourceBar:SetHeight(options.resourceBarHeight)
    end
    if options.resourceBarOffset then
        self.resourceBar:ClearAllPoints()
        self.resourceBar:SetPoint("TOP", self.healthBar, "BOTTOM", 0, options.resourceBarOffset or -1)
    end
    if options.resourceBarColor then
        self.resourceBar:SetVertexColor(unpack(options.resourceBarColor))
    end
    if options.targetHealthBarHeight then
        self.targetHealthBar:SetHeight(options.targetHealthBarHeight)
    end
    if options.targetHealthBarOffset then
        self.targetHealthBar:ClearAllPoints()
        self.targetHealthBar:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, options.targetHealthBarOffset or -10)
    end
    if options.targetHealthBarColor then
        self.targetHealthBar:SetVertexColor(unpack(options.targetHealthBarColor))
    end
    if options.targetResourceBarHeight then
        self.targetResourceBar:SetHeight(options.targetResourceBarHeight)
    end
    if options.targetResourceBarOffset then
        self.targetResourceBar:ClearAllPoints()
        self.targetResourceBar:SetPoint("BOTTOM", self.targetHealthBar, "TOP", 0, options.targetResourceBarOffset or 1)
    end
    if options.targetResourceBarColor then
        self.targetResourceBar:SetVertexColor(unpack(options.targetResourceBarColor))
    end
    if options.comboSize or options.comboSpacing or options.comboOffset then
        local size = options.comboSize or 6
        local spacing = options.comboSpacing or 0
        local offsetX = options.comboOffset and options.comboOffset.x or 0
        local offsetY = options.comboOffset and options.comboOffset.y or 24
        for i, square in ipairs(self.comboSquares) do
            square:SetSize(size, size)
            square:ClearAllPoints()
            square:SetPoint("BOTTOM", self.comboFrame, "BOTTOM", 0, (i - 1) * (size + spacing))
        end
        self.comboFrame:SetPoint("RIGHT", self.frame, "LEFT", offsetX, offsetY)
    end
    if options.poisonSize or options.poisonSpacing or options.poisonOffset then
        local size = options.poisonSize or 6
        local spacing = options.poisonSpacing or 0
        local offsetX = options.poisonOffset and options.poisonOffset.x or 0
        local offsetY = options.poisonOffset and options.poisonOffset.y or 24
        for i, square in ipairs(self.poisonSquares) do
            square:SetSize(size, size)
            square:ClearAllPoints()
            square:SetPoint("BOTTOM", self.poisonFrame, "BOTTOM", 0, (i - 1) * (size + spacing))
        end
        self.poisonFrame:SetPoint("LEFT", self.frame, "RIGHT", offsetX, offsetY)
    end
    if options.timeLinePosition then
        self.timeLine:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, self.height / 2 - options.timeLinePosition)
    end
    self:ForceUpdateAllSpells()
end

function SpellQueue:CreateComboPoisonElements()
    local square_size = 12
    local spacing = 4
    local total_height = (square_size + spacing) * 5 - spacing
    self.comboFrame = CreateFrame("Frame", nil, self.frame)
    self.comboFrame:SetSize(square_size, total_height)
    self.comboFrame:SetPoint("RIGHT", self.frame, "LEFT", -10, 0)
    self.comboSquares = {}
    for i = 1, 5 do
        local square = self.comboFrame:CreateTexture(nil, "OVERLAY")
        square:SetSize(square_size, square_size)
        square:SetTexture("Interface\\Buttons\\WHITE8X8")
        square:SetPoint("BOTTOM", self.comboFrame, "BOTTOM", 0, (i - 1) * (square_size + spacing))
        square:SetVertexColor(unpack(FEATURE_COLORS.COMBO_EMPTY))
        table.insert(self.comboSquares, square)
    end
    self.poisonFrame = CreateFrame("Frame", nil, self.frame)
    self.poisonFrame:SetSize(square_size, total_height)
    self.poisonFrame:SetPoint("LEFT", self.frame, "RIGHT", 10, 0)
    self.poisonSquares = {}
    for i = 1, 5 do
        local square = self.poisonFrame:CreateTexture(nil, "OVERLAY")
        square:SetSize(square_size, square_size)
        square:SetTexture("Interface\\Buttons\\WHITE8X8")
        square:SetPoint("BOTTOM", self.poisonFrame, "BOTTOM", 0, (i - 1) * (square_size + spacing))
        square:SetVertexColor(unpack(FEATURE_COLORS.POISON_EMPTY))
        table.insert(self.poisonSquares, square)
    end
end

function SpellQueue:UpdateGlowSettings()
    if not self.iconSize then
        return
    end
    local glowOffset = self.glowSizeOffset or 10
    local glowAlpha = self.glowAlpha or 0.3
    local highlightOffset = self.highlightSizeOffset or 15
    for _, spell in pairs(self.spells) do
        if spell.glow then
            spell.glow:SetSize(self.iconSize + glowOffset, self.iconSize + glowOffset)
            spell.glow:SetAlpha(glowAlpha)
        end
        if spell.highlight then
            spell.highlight:SetSize(self.iconSize + highlightOffset, self.iconSize + highlightOffset)
        end
    end
end

SlashCmdList["SPELLQUEUE"] = function()
    if not _G.SpellQueueConfig then
        SpellQueue:CreateConfigWindow()
    end
    SpellQueue.configFrame:Show()
end
SLASH_SPELLQUEUE1 = "/sq"
SlashCmdList["SPELLQUEUEMODE"] = function()
    if _G.SpellQueueInstance then
        _G.SpellQueueInstance:ToggleDisplayMode()
    else
        print("SpellQueue не инициализирован")
    end
end
SLASH_SPELLQUEUEMODE1 = "/sqmode"
SlashCmdList["SPELLQUEUE_HP"] = function()
    SpellQueueInstance.features = bit.bxor(SpellQueueInstance.features, FEATURE_HP)
    if bit.band(SpellQueueInstance.features, FEATURE_HP) ~= 0 then
        SpellQueueInstance.healthBar:Show()
    else
        SpellQueueInstance.healthBar:Hide()
    end
end
SLASH_SPELLQUEUE_HP1 = "/sqhp"
SlashCmdList["SPELLQUEUE_RES"] = function()
    SpellQueueInstance.features = bit.bxor(SpellQueueInstance.features, FEATURE_RESOURCE)
    if bit.band(SpellQueueInstance.features, FEATURE_RESOURCE) ~= 0 then
        SpellQueueInstance.resourceBar:Show()
    else
        SpellQueueInstance.resourceBar:Hide()
    end
end
SLASH_SPELLQUEUE_RES1 = "/sqres"
SlashCmdList["SPELLQUEUE_COMBO"] = function()
    SpellQueueInstance.features = bit.bxor(SpellQueueInstance.features, FEATURE_COMBO)
    for _, point in ipairs(SpellQueueInstance.comboPoints) do
        if point then
            if bit.band(SpellQueueInstance.features, FEATURE_COMBO) ~= 0 then
                point:Show()
            else
                point:Hide()
            end
        end
    end
end
SLASH_SPELLQUEUE_COMBO1 = "/sqcp"
SlashCmdList["SPELLQUEUE_POISON"] = function()
    SpellQueueInstance.features = bit.bxor(SpellQueueInstance.features, FEATURE_POISON)
    for _, stack in ipairs(SpellQueueInstance.poisonStacks) do
        if stack then
            if bit.band(SpellQueueInstance.features, FEATURE_POISON) ~= 0 then
                stack:Show()
            else
                stack:Hide()
            end
        end
    end
end
SLASH_SPELLQUEUE_POISON1 = "/sqps"

-- Добавьте слаш-команду для теста
SLASH_SHIELDTEST1 = "/shieldtest"
SlashCmdList["SHIELDTEST"] = function()
    print("|cFF00FF00=== ТЕСТ ОТСЛЕЖИВАНИЯ ЩИТА ===|r")
    print("Player GUID:", UnitGUID("player"))
    print("Player Name:", UnitName("player"))
    
    -- Проверяем наличие щита
    local hasShield = false
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        if not name then break end
        print(string.format("Бафф %d: %s", i, name))
        if name == "Слово силы: Щит" then
            hasShield = true
            print("|cFF00FF00НАЙДЕН ЩИТ!|r")
        end
    end
    
    if not hasShield then
        print("|cFFFF0000Щит не найден|r")
    end
    
    -- Проверяем события
    print("Ожидание событий COMBAT_LOG_EVENT_UNFILTERED...")
end

-- Добавьте слэш-команду в конец файла, где другие команды:
SLASH_SHIELDBARMODE1 = "/sqshield"
SlashCmdList["SHIELDBARMODE"] = function()
    if _G.SpellQueueInstance then
        _G.SpellQueueInstance:ToggleShieldBarMode()
    else
        print("SpellQueue не инициализирован")
    end
end

SLASH_SHIELDBAR1 = "/sqshield"
SlashCmdList["SHIELDBAR"] = function(msg)
    if not _G.SpellQueueInstance then
        print("SpellQueue не инициализирован")
        return
    end
    
    if msg and msg ~= "" then
        local num = tonumber(msg)
        if num then
            _G.SpellQueueInstance:SetShieldBarHeight(num)
        else
            _G.SpellQueueInstance:ToggleShieldBarMode()
        end
    else
        _G.SpellQueueInstance:ToggleShieldBarMode()
    end
end









































local PROK_PRESETS = {
    ["Рыцарь смерти (танк)"] = {
        ["Незыблемость льда"] = {
            spellqueue_name = "",
            triggerType = "buff",
            icon = "Interface\\AddOns\\NSQC\\libs\\nl",
            profil = 4,
            stack = 0,
            skill = "",
            name = "Незыблемость льда",
        },
        ["Кровь вампира"] = {
            spellqueue_name = "",
            triggerType = "buff",
            icon = "Interface\\AddOns\\NSQC\\libs\\krov_vampira",
            profil = 4,
            stack = 0,
            skill = "",
            name = "Кровь вампира",
        },
        ["Кровавый доспех"] = {
            spellqueue_name = "",
            triggerType = "buff",
            icon = "Interface\\AddOns\\NSQC\\libs\\krovootvod",
            profil = 4,
            stack = 0,
            skill = "",
            name = "Кровавый доспех",
        },
        ["Костяной щит"] = {
            spellqueue_name = "",
            triggerType = "buff",
            icon = "Interface\\AddOns\\NSQC\\libs\\kostKluch",
            profil = 4,
            stack = 0,
            skill = "",
            name = "Костяной щит",
        },
        ["Антимагический панцирь"] = {
            spellqueue_name = "",
            triggerType = "buff",
            icon = "Interface\\AddOns\\NSQC\\libs\\zelenka",
            profil = 4,
            stack = 0,
            skill = "",
            name = "Антимагический панцирь",
        },
    },
    ["Паладин (танк)"] = {
        ["Щит небес"] = {
            name = "Щит небес",
            spellqueue_name = "",
            skill = "",
            profil = 2,
            stack = 0,
            icon = "SpellActivationOverlays\\genericarc_03",
            triggerType = "buff",
        },
        ["Молот гнева"] = {
            name = "Молот гнева",
            spellqueue_name = "Молот гнева",
            skill = "",
            profil = 3,
            stack = 0,
            icon = "SpellActivationOverlays\\backlash",
            triggerType = "custom",
        },
        ["Священный щит"] = {
            name = "Священный щит",
            spellqueue_name = "",
            skill = "",
            profil = 1,
            stack = 0,
            icon = "SpellActivationOverlays\\hot_streak",
            triggerType = "buff",
        },
    },
    ["Разбойник (саб)"] = {
        ["Танец теней"] = {
            triggerType = "buff",
            name = "Танец теней",
            icon = "SpellActivationOverlays\\sudden_doom",
            profil = 1,
            stack = 0,
            skill = "",
            spellqueue_name = "",
        },
    },
    ["Друид"] = {
        ["Ясность мысли"] = {
            name = "Ясность мысли",
            spellqueue_name = "",
            icon = "SpellActivationOverlays\\focus_fire",
            profil = 1,
            stack = 0,
            skill = "Ясность мысли",
            triggerType = "buff",
        },
        ["Жизнецвет"] = {
            name = "Жизнецвет",
            profil = 1,
            stack = 3,
            skill = "",
            icon = "SpellActivationOverlays\\sword_and_board",
        },
    },
    ["Охотник"] = {
        ["Убийственый выстрел"] = {
            triggerType = "custom",
            name = "Убийственый выстрел",
            skill = "",
            profil = 1,
            stack = 0,
            icon = "SpellActivationOverlays\\focus_fire",
            spellqueue_name = "Убийственый выстрел",
        },
    },
    ["Маг (аркан)"] = {
        ["Заградительные стрелы"] = {
            spellqueue_name = "",
            triggerType = "buff",
            skill = "",
            profil = 1,
            stack = 0,
            icon = "SpellActivationOverlays\\arcane_missiles",
            name = "Заградительные стрелы",
        },
        ["Чародейская вспышка"] = {
            spellqueue_name = "",
            triggerType = "buff",
            skill = "",
            profil = 2,
            stack = 0,
            icon = "SpellActivationOverlays\\sudden_death",
            name = "Чародейская вспышка",
        },
    },
}

ProkIconManager = {
    icons = {},
    settings = {
        { -- Профиль 1 (Слева)
            name = "Слева",
            ["Rx"] = 128,
            ["Ry"] = 256,
            ["x"] = -200,
            ["y"] = 0,
        },
        { -- Профиль 2 (Справа)
            name = "Справа",
            ["Rx"] = 128,
            ["Ry"] = 256,
            ["x"] = 200,
            ["y"] = 0,
        },
        { -- Профиль 3 (Сверху)
            name = "Сверху",
            ["Rx"] = 256,
            ["Ry"] = 128,
            ["x"] = 0,
            ["y"] = 200,
        },
        { -- Профиль 4 (Центр)
            name = "Центр",
            ["Rx"] = 0,  -- Полный экран
            ["Ry"] = 0,   -- Полный экран
            ["x"] = 0,
            ["y"] = 0,
        }
    },
    frames = {},
    activeIcons = {},
    previewFrame = nil,
    selectedIcon = nil,
    iconDropdownBtn = nil,
    iconPreview = nil,
    configFrame = nil,
    eventFrame = nil,
    profileDropdown = nil,
    externalIconsTable = nil,
    
    textureList = {
        LEFT = {
            {name = "arcane_missiles", path = "SpellActivationOverlays\\arcane_missiles"},
            {name = "art_of_war", path = "SpellActivationOverlays\\art_of_war"},
            {name = "blood_boil", path = "SpellActivationOverlays\\blood_boil"},
            {name = "blood_surge", path = "SpellActivationOverlays\\blood_surge"},
            {name = "brain_freeze", path = "SpellActivationOverlays\\brain_freeze"},
            {name = "daybreak", path = "SpellActivationOverlays\\daybreak"},
            {name = "eclipse_moon", path = "SpellActivationOverlays\\eclipse_moon"},
            {name = "feral_omenofclarity", path = "SpellActivationOverlays\\feral_omenofclarity"},
            {name = "focus_fire", path = "SpellActivationOverlays\\focus_fire"},
            {name = "genericarc_01", path = "SpellActivationOverlays\\genericarc_01"},
            {name = "genericarc_02", path = "SpellActivationOverlays\\genericarc_02"},
            {name = "genericarc_04", path = "SpellActivationOverlays\\genericarc_04"},
            {name = "genericarc_05", path = "SpellActivationOverlays\\genericarc_05"},
            {name = "genericarc_06", path = "SpellActivationOverlays\\genericarc_06"},
            {name = "grand_crusader", path = "SpellActivationOverlays\\grand_crusader"},
            {name = "hot_streak", path = "SpellActivationOverlays\\hot_streak"},
            {name = "imp_empowerment", path = "SpellActivationOverlays\\imp_empowerment"},
            {name = "killing_machine", path = "SpellActivationOverlays\\killing_machine"},
            {name = "molten_core", path = "SpellActivationOverlays\\molten_core"},
            {name = "natures_grace", path = "SpellActivationOverlays\\natures_grace"},
            {name = "nightfall", path = "SpellActivationOverlays\\nightfall"},
            {name = "sudden_doom", path = "SpellActivationOverlays\\sudden_doom"},
            {name = "surge_of_light", path = "SpellActivationOverlays\\surge_of_light"},
            {name = "sword_and_board", path = "SpellActivationOverlays\\sword_and_board"}
        },
        TOP = {
            {name = "backlash", path = "SpellActivationOverlays\\backlash"},
            {name = "berserk", path = "SpellActivationOverlays\\berserk"},
            {name = "dark_transformation", path = "SpellActivationOverlays\\dark_transformation"},
            {name = "denounce", path = "SpellActivationOverlays\\denounce"},
            {name = "eclipse_sun", path = "SpellActivationOverlays\\eclipse_sun"},
            {name = "frozen_fingers", path = "SpellActivationOverlays\\frozen_fingers"},
            {name = "fulmination", path = "SpellActivationOverlays\\fulmination"},
            {name = "fury_of_stormrage", path = "SpellActivationOverlays\\fury_of_stormrage"},
            {name = "generictop_01", path = "SpellActivationOverlays\\generictop_01"},
            {name = "generictop_02", path = "SpellActivationOverlays\\generictop_02"},
            {name = "hand_of_light", path = "SpellActivationOverlays\\hand_of_light"},
            {name = "impact", path = "SpellActivationOverlays\\impact"},
            {name = "lock_and_load", path = "SpellActivationOverlays\\lock_and_load"},
            {name = "maelstrom_weapon", path = "SpellActivationOverlays\\maelstrom_weapon"},
            {name = "master_marksman", path = "SpellActivationOverlays\\master_marksman"},
            {name = "necropolis", path = "SpellActivationOverlays\\necropolis"},
            {name = "rime", path = "SpellActivationOverlays\\rime"},
            {name = "serendipity", path = "SpellActivationOverlays\\serendipity"},
            {name = "shooting_stars", path = "SpellActivationOverlays\\shooting_stars"},
            {name = "slice_and_dice", path = "SpellActivationOverlays\\slice_and_dice"},
            {name = "spellactivationoverlay_0", path = "SpellActivationOverlays\\spellactivationoverlay_0"}
        },
        RIGHT = {
            {name = "genericarc_03", path = "SpellActivationOverlays\\genericarc_03"},
            {name = "sudden_death", path = "SpellActivationOverlays\\sudden_death"}
        },
        CENTER = {
            {name = "kostKluch", path = "Interface\\AddOns\\NSQC\\libs\\kostKluch"},
            {name = "zelenka", path = "Interface\\AddOns\\NSQC\\libs\\zelenka"},
            {name = "nl", path = "Interface\\AddOns\\NSQC\\libs\\nl"},
            {name = "krovootvod", path = "Interface\\AddOns\\NSQC\\libs\\krovootvod"},
            {name = "krov_vampira", path = "Interface\\AddOns\\NSQC\\libs\\krov_vampira"}
        }
    }
}

function ProkIconManager:CreatePresetDropdown()
    self.prokPresetDropdown = CreateFrame("Frame", "ProkPresetDropdown", self.configFrame, "UIDropDownMenuTemplate")
    self.prokPresetDropdown:SetPoint("TOPLEFT", self.configFrame, "TOPLEFT", 20, -320)
    self.prokPresetDropdown:Hide()
    UIDropDownMenu_SetWidth(self.prokPresetDropdown, 200)
    
    UIDropDownMenu_Initialize(self.prokPresetDropdown, function()
        local info = UIDropDownMenu_CreateInfo()
        
        -- Пункт "Очистить всё"
        info.text = "|cffff0000Очистить всё|r"
        info.value = "clear"
        info.func = function()
            _G.nsDbc.proks = {}
            self.icons = {}
            if self.externalIconsTable then
                for k in pairs(self.externalIconsTable) do
                    self.externalIconsTable[k] = nil
                end
            end
            self:ForceHideAllIcons()
            print("ProkIconManager: Все проки удалены!")
            self.prokPresetDropdown:Hide()
        end
        UIDropDownMenu_AddButton(info)
        
        -- Разделитель
        info.text = ""
        info.value = "separator"
        info.func = nil
        info.disabled = true
        UIDropDownMenu_AddButton(info)
        
        -- Пресеты
        for presetName, icons in pairs(PROK_PRESETS) do
            info.text = presetName
            info.value = presetName
            info.func = function()
                _G.nsDbc = _G.nsDbc or {}
                _G.nsDbc.proks = _G.nsDbc.proks or {}
                
                for name, iconData in pairs(icons) do
                    _G.nsDbc.proks[name] = iconData
                    self.icons[name] = iconData
                    if self.externalIconsTable then
                        self.externalIconsTable[name] = iconData
                    end
                end
                
                self:CheckInitialStates()
                print("ProkIconManager: Загружен пресет для " .. presetName)
                self.prokPresetDropdown:Hide()
            end
            info.disabled = nil
            UIDropDownMenu_AddButton(info)
        end
    end)
end

function ProkIconManager:Initialize(iconsTable)
    if not iconsTable then 
        return 
    end
    
    self.externalIconsTable = iconsTable
    
    -- Копируем проки из внешней таблицы во внутреннюю
    for name, iconData in pairs(iconsTable) do
        self.icons[name] = iconData
        
        -- Регистрация кастомных триггеров
        if iconData.triggerType == "custom" and iconData.spellqueue_name and _G.SpellQueueInstance then
            -- Инициализируем таблицу триггеров
            if not _G.SpellQueueInstance.customTriggers then
                _G.SpellQueueInstance.customTriggers = {}
            end
            
            if not _G.SpellQueueInstance.customTriggers[iconData.spellqueue_name] then
                _G.SpellQueueInstance.customTriggers[iconData.spellqueue_name] = {}
            end
            
            -- Регистрируем обработчики
            _G.SpellQueueInstance:RegisterTrigger(
                iconData.spellqueue_name,
                function(sName, sData)
                    self:HandleCustomTrigger(sName, sData, "onActivate", iconData)
                end,
                "onActivate"
            )
            
            _G.SpellQueueInstance:RegisterTrigger(
                iconData.spellqueue_name,
                function(sName, sData)
                    self:HandleCustomTrigger(sName, sData, "onDeactivate", iconData)
                end,
                "onDeactivate"
            )
        end
    end

    -- Восстанавливаем регистрацию событий для обычных баффов
    self.eventFrame = self.eventFrame or CreateFrame("Frame")
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.eventFrame:RegisterEvent("UNIT_AURA")
    
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            -- Правильное получение данных CLEU - аргументы передаются напрямую
            local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, 
                  destGUID, destName, destFlags, destRaidFlags, spellID, spellName = ...
            
            local isPlayer = (destGUID == UnitGUID("player"))
            if not isPlayer then 
                return 
            end
            
            if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_CAST_SUCCESS" or
               subEvent == "SPELL_AURA_REMOVED" or subEvent == "SPELL_AURA_REFRESH" then
                
                for name, icon in pairs(self.icons) do
                    -- Пропускаем кастомные триггеры
                    if icon.triggerType ~= "custom" then
                        -- Проверяем по обоим полям - name и skill
                        if spellName == icon.name or (icon.skill and icon.skill ~= "" and spellName == icon.skill) then
                            self:HandleSpellEvent(subEvent, icon, spellName)
                        end
                    end
                end
            end
        elseif event == "UNIT_AURA" and ... == "player" then
            for name, icon in pairs(self.icons) do
                -- Пропускаем кастомные триггеры
                if icon.triggerType ~= "custom" then
                    self:HandleSpellEvent("UNIT_AURA", icon)
                end
            end
        end
    end)

    -- Принудительно проверяем баффы после загрузки
    for name, icon in pairs(self.icons) do
        if icon.triggerType ~= "custom" then
            self:HandleSpellEvent("UNIT_AURA", icon)
        end
    end
end

function ProkIconManager:HandleSpellEvent(event, iconData, spellName)
    if not iconData then 
        return 
    end
    
    -- Пропускаем кастомные триггеры
    if iconData.triggerType == "custom" then 
        return 
    end

    if event == "SPELL_AURA_APPLIED" or event == "SPELL_CAST_SUCCESS" or
       event == "SPELL_AURA_REFRESH" or event == "UNIT_AURA" then
        
        -- Проверяем наличие баффа в реальном времени
        local shouldShow = false
        local buffToCheckName = iconData.skill and iconData.skill ~= "" and iconData.skill or iconData.name
        
        for i = 1, 40 do
            local name, _, _, count = UnitBuff("player", i)
            if name and (name == iconData.name or name == buffToCheckName) then
                if (iconData.stack or 0) <= (count or 1) then
                    shouldShow = true
                    break
                end
            end
        end
        
        if shouldShow then
            local profile = self.settings[iconData.profil or 1]
            local width = profile.Rx == 0 and GetScreenWidth() or profile.Rx
            local height = profile.Ry == 0 and GetScreenHeight() or profile.Ry
            
            -- Формируем полный путь к текстуре
            local texturePath = iconData.icon
            if not strfind(texturePath:lower(), "^interface\\") then
                texturePath = "Interface\\AddOns\\NSQC\\libs\\" .. texturePath:gsub("%.tga$", "") .. ".tga"
            end
            
            self:ShowIcon(iconData.name, width, height, profile.x, profile.y, texturePath)
        else
            self:HideIcon(iconData.name)
        end
    elseif event == "SPELL_AURA_REMOVED" then
        -- Мгновенно скрываем иконку при спадении баффа
        -- Проверяем по обоим возможным названиям
        if spellName == iconData.name or (iconData.skill and spellName == iconData.skill) then
            self:HideIcon(iconData.name)
        end
    end
end

function ProkIconManager:CheckInitialStates()
    -- Проверяем начальное состояние для всех иконок
    for name, iconData in pairs(self.icons) do
        -- Определяем тип триггера (по умолчанию "buff" если не указан)
        local triggerType = iconData.triggerType or "buff"
        if triggerType == "custom" and _G.SpellQueueInstance then
            -- Для кастомных триггеров проверяем через SpellQueue
            local spell = _G.SpellQueueInstance.spells[iconData.spellqueue_name]
            if spell then
                local isActive = _G.SpellQueueInstance:IsSpellActive(spell)
                if isActive then
                    self:HandleCustomTrigger(iconData.spellqueue_name, spell, "onActivate", iconData)
                else
                    self:HandleCustomTrigger(iconData.spellqueue_name, spell, "onDeactivate", iconData)
                end
            end
        else
            -- Для баффов проверяем текущее состояние
            local shouldShow = false
            -- Используем skill если он не пустой, иначе name
            local buffToCheck = (iconData.skill and iconData.skill ~= "") and iconData.skill or iconData.name
            for i = 1, 40 do
                local buffName, _, _, count = UnitBuff("player", i)
                if buffName and buffName == buffToCheck then
                    if (iconData.stack or 0) <= (count or 1) then
                        shouldShow = true
                        break
                    end
                end
            end
            if shouldShow then
                self:ShowIconNow(iconData)
            else
                self:HideIcon(iconData.name)
            end
        end
    end
end

function ProkIconManager:ShowIconNow(iconData)
    if not iconData or not iconData.name then return end
    
    local profile = self.settings[iconData.profil or 1]
    local width = profile.Rx == 0 and GetScreenWidth() or profile.Rx
    local height = profile.Ry == 0 and GetScreenHeight() or profile.Ry
    
    -- === ИСПРАВЛЕНО: Корректная обработка пути к текстуре без GetFileIDFromPath ===
    local texturePath = iconData.icon or ""
    if texturePath == "" then
        texturePath = "Interface\\Icons\\INV_Misc_QuestionMark"
    elseif not strfind(texturePath:lower(), "^interface\\") then
        texturePath = "Interface\\AddOns\\NSQC\\libs\\" .. texturePath:gsub("%.tga$", "") .. ".tga"
    end
    
    if not self.frames[iconData.name] then
        self.frames[iconData.name] = CreateFrame("Frame", nil, UIParent)
        self.frames[iconData.name].texture = self.frames[iconData.name]:CreateTexture(nil, "BACKGROUND")
        self.frames[iconData.name].texture:SetAllPoints()
        self.frames[iconData.name]:SetFrameStrata("HIGH")
    end
    
    -- Безопасная загрузка текстуры
    local textureLoaded = pcall(function()
        self.frames[iconData.name].texture:SetTexture(texturePath)
    end)
    
    if not textureLoaded then
        debug(string.format("Не удалось загрузить текстуру для %s: %s", iconData.name, texturePath))
        self.frames[iconData.name].texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    
    self.frames[iconData.name]:SetSize(width, height)
    self.frames[iconData.name]:ClearAllPoints()
    self.frames[iconData.name]:SetPoint("CENTER", UIParent, "CENTER", profile.x, profile.y)
    self.frames[iconData.name]:Show()
end

function ProkIconManager:HandleSpellEvent(event, iconData, spellName)
    if not iconData then return end
    
    -- Определяем тип триггера (по умолчанию "buff" если не указан)
    local triggerType = iconData.triggerType or "buff"
    if triggerType == "custom" then return end
    
    -- Определяем название баффа для проверки
    local buffToCheck = (iconData.skill and iconData.skill ~= "") and iconData.skill or iconData.name
    
    if event == "SPELL_AURA_APPLIED" or event == "SPELL_CAST_SUCCESS" or
       event == "SPELL_AURA_REFRESH" or event == "UNIT_AURA" then
        
        local shouldShow = false
        for i = 1, 40 do
            local name, _, _, count = UnitBuff("player", i)
            if name and name == buffToCheck then
                if (iconData.stack or 0) <= (count or 1) then
                    shouldShow = true
                    break
                end
            end
        end
        
        if shouldShow then
            local profile = self.settings[iconData.profil or 1]
            local width = profile.Rx == 0 and GetScreenWidth() or profile.Rx
            local height = profile.Ry == 0 and GetScreenHeight() or profile.Ry
            local texturePath = iconData.icon
            if not strfind(texturePath:lower(), "^interface\\") then
                texturePath = "Interface\\AddOns\\NSQC\\libs\\" .. texturePath:gsub("%.tga$", "") .. ".tga"
            end
            self:ShowIcon(iconData.name, width, height, profile.x, profile.y, texturePath)
        else
            self:HideIcon(iconData.name)
        end
    elseif event == "SPELL_AURA_REMOVED" and spellName == buffToCheck then
        self:HideIcon(iconData.name)
    end
end

function ProkIconManager:ShowIcon(spellNum, width, height, x, y, texturePath)
    if not self.frames[spellNum] then
        self.frames[spellNum] = CreateFrame("Frame", nil, UIParent)
        self.frames[spellNum].texture = self.frames[spellNum]:CreateTexture(nil, "BACKGROUND")
        self.frames[spellNum].texture:SetAllPoints()
        self.frames[spellNum]:SetFrameStrata("HIGH")
        
        -- Убираем таймер автоскрытия
        self.frames[spellNum]:SetScript("OnUpdate", nil)
    end
    
    local frame = self.frames[spellNum]
    frame:SetSize(width, height)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
    frame.texture:SetTexture(texturePath)
    frame:Show()
end

function ProkIconManager:HideIcon(spellNum)
    if self.frames[spellNum] then
        self.frames[spellNum]:Hide()
    end
end

function ProkIconManager:CreateConfigUI()
    self.configFrame = CreateFrame("Frame", "ProkIconConfig", UIParent)
    self.configFrame:SetSize(400, 320) -- Увеличена высота для новых элементов
    self.configFrame:SetPoint("CENTER")
    self.configFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    self.configFrame:SetMovable(true)
    self.configFrame:EnableMouse(true)
    self.configFrame:RegisterForDrag("LeftButton")
    self.configFrame:SetScript("OnDragStart", self.configFrame.StartMoving)
    self.configFrame:SetScript("OnDragStop", self.configFrame.StopMovingOrSizing)
    
    -- Кнопка закрытия
    local closeBtn = CreateFrame("Button", nil, self.configFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() self.configFrame:Hide() end)
    
    -- Заголовок
    local title = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", 0, -18)
    title:SetText("Управление проками")
    
    self:CreateConfigUIElements()
    self.configFrame:Hide()
end

function ProkIconManager:CreateConfigUIElements()
    local yPos = 50
    local fieldHeight = 30

    -- Поле названия с кнопкой удаления
    self:CreateInputField("Название", "name", yPos)
    local delBtn = CreateFrame("Button", nil, self.configFrame, "UIPanelButtonTemplate")
    delBtn:SetSize(24, 24)
    delBtn:SetPoint("LEFT", self.input_name, "RIGHT", 5, 0)
    delBtn:SetText("X")
    delBtn:SetScript("OnClick", function()
        local inputText = self.input_name:GetText()
        if inputText == "" then return end

        -- 1. Удаление из self.icons (локальная таблица)
        if self.icons[inputText] then
            self.icons[inputText] = nil
            if self.externalIconsTable then
                self.externalIconsTable[inputText] = nil
            end
            self:ResetForm()
            print("Иконка удалена:", inputText)
            return
        end

        -- 2. Удаление из nsDbc.proks по имени
        if _G.nsDbc and _G.nsDbc.proks and _G.nsDbc.proks[inputText] then
            _G.nsDbc.proks[inputText] = nil
            if self.icons then
                self.icons[inputText] = nil
            end
            if self.externalIconsTable then
                self.externalIconsTable[inputText] = nil
            end
            self:ResetForm()
            print("Иконка удалена из nsDbc.proks:", inputText)
            return
        end

        -- 3. Поиск по spellqueue_name в nsDbc.proks
        local foundKey = nil
        if _G.nsDbc and _G.nsDbc.proks then
            for key, iconData in pairs(_G.nsDbc.proks) do
                if iconData.spellqueue_name == inputText then
                    foundKey = key
                    break
                end
            end
        end

        if foundKey then
            _G.nsDbc.proks[foundKey] = nil
            if self.icons then
                self.icons[foundKey] = nil
            end
            if self.externalIconsTable then
                self.externalIconsTable[foundKey] = nil
            end
            self:ResetForm()
            print("Иконка удалена по spellqueue_name из nsDbc.proks:", inputText)
        else
            print("Иконка не найдена:", inputText)
        end
    end)

    -- Поле способности
    yPos = yPos + fieldHeight
    self:CreateInputField("Способность", "skill", yPos)

    -- Выбор профиля
    yPos = yPos + fieldHeight
    local profileLabel = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    profileLabel:SetPoint("TOPLEFT", 20, -yPos + 5)
    profileLabel:SetText("Профиль:")
    self.profileDropdown = CreateFrame("Frame", "ProkProfileDropdown", self.configFrame, "UIDropDownMenuTemplate")
    self.profileDropdown:SetPoint("TOPLEFT", 120, -yPos)
    UIDropDownMenu_SetWidth(self.profileDropdown, 180)
    UIDropDownMenu_Initialize(self.profileDropdown, function()
        for i, p in ipairs(self.settings) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = p.name ~= "" and p.name or "Профиль "..i
            info.value = i
            info.func = function()
                UIDropDownMenu_SetSelectedValue(self.profileDropdown, i)
                if self.selectedIcon then
                    self:ShowTexturePreview(self.selectedIcon)
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedValue(self.profileDropdown, 1)

    -- Выбор текстуры
    yPos = yPos + fieldHeight
    local texLabel = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    texLabel:SetPoint("TOPLEFT", 20, -yPos + 5)
    texLabel:SetText("Текстура:")
    self.texDropdown = CreateFrame("Frame", "ProkTexDropdown", self.configFrame, "UIDropDownMenuTemplate")
    self.texDropdown:SetPoint("TOPLEFT", 120, -yPos)
    UIDropDownMenu_SetWidth(self.texDropdown, 180)
    UIDropDownMenu_Initialize(self.texDropdown, function(_, level)
        if level == 1 then
            for category in pairs(self.textureList) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = category
                info.hasArrow = true
                info.menuList = category
                UIDropDownMenu_AddButton(info, level)
            end
        elseif level == 2 then
            local category = UIDROPDOWNMENU_MENU_VALUE
            for _, tex in ipairs(self.textureList[category]) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = tex.name
                info.func = function()
                    self.selectedIcon = tex.path
                    UIDropDownMenu_SetText(self.texDropdown, tex.name)
                    self:ShowTexturePreview(tex.path)
                    CloseDropDownMenus()
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end
    end)
    UIDropDownMenu_SetText(self.texDropdown, "Выбрать текстуру")

    -- Поле стаков
    yPos = yPos + fieldHeight
    self:CreateInputField("Стаки", "stack", yPos, true)
    self.input_stack:SetText("0")

    -- Новое поле: Название скилла из SpellQueue
    yPos = yPos + fieldHeight + 10
    self:CreateInputField("Скилл SpellQueue", "spellqueue_name", yPos)

    -- Чекбоксы типа триггера
    yPos = yPos + fieldHeight
    local triggerLabel = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    triggerLabel:SetPoint("TOPLEFT", 20, -yPos + 5)
    triggerLabel:SetText("Тип триггера:")

    -- Сохраняем чекбоксы как поля объекта для прямого доступа
    self.triggerTypeBuff = CreateFrame("CheckButton", "ProkTriggerBuff", self.configFrame, "UICheckButtonTemplate")
    self.triggerTypeBuff:SetSize(24, 24)
    self.triggerTypeBuff:SetPoint("TOPLEFT", 120, -yPos)
    self.triggerTypeBuff.text = self.triggerTypeBuff:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.triggerTypeBuff.text:SetText("Бафф")
    self.triggerTypeBuff.text:SetPoint("LEFT", self.triggerTypeBuff, "RIGHT", 5, 0)
    self.triggerTypeBuff:SetChecked(true)

    self.triggerTypeCustom = CreateFrame("CheckButton", "ProkTriggerCustom", self.configFrame, "UICheckButtonTemplate")
    self.triggerTypeCustom:SetSize(24, 24)
    self.triggerTypeCustom:SetPoint("LEFT", self.triggerTypeBuff.text, "RIGHT", 20, 0)
    self.triggerTypeCustom.text = self.triggerTypeCustom:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.triggerTypeCustom.text:SetText("Кастомный")
    self.triggerTypeCustom.text:SetPoint("LEFT", self.triggerTypeCustom, "RIGHT", 5, 0)

    -- Синхронизация чекбоксов через прямые ссылки на объект
    self.triggerTypeBuff:SetScript("OnClick", function()
        if self.triggerTypeBuff:GetChecked() then
            self.triggerTypeCustom:SetChecked(false)
        end
    end)
    self.triggerTypeCustom:SetScript("OnClick", function()
        if self.triggerTypeCustom:GetChecked() then
            self.triggerTypeBuff:SetChecked(false)
        end
    end)

    -- Кнопка добавления
    yPos = yPos + fieldHeight + 10
    local addBtn = CreateFrame("Button", nil, self.configFrame, "UIPanelButtonTemplate")
    addBtn:SetSize(120, 24)
    addBtn:SetPoint("TOP", 0, -yPos)
    addBtn:SetText("Добавить")
    addBtn:SetScript("OnClick", function()
        self:AddNewIcon()
        CloseDropDownMenus()
        self:ForceHideAllIcons()
    end)

    -- Кнопка загрузки пресета проков (квадратная, справа от "Добавить")
    local loadPresetBtn = CreateFrame("Button", nil, self.configFrame, "UIPanelButtonTemplate")
    loadPresetBtn:SetSize(24, 24)
    loadPresetBtn:SetPoint("LEFT", addBtn, "RIGHT", 5, 0)
    loadPresetBtn:SetText("P")
    loadPresetBtn:SetScript("OnClick", function()
        if self.prokPresetDropdown and self.prokPresetDropdown:IsShown() then
            self.prokPresetDropdown:Hide()
        else
            if not self.prokPresetDropdown then
                self:CreatePresetDropdown()
            end
            self.prokPresetDropdown:Show()
        end
    end)
    
    -- Тултип
    loadPresetBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(loadPresetBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText("Загрузить пресет")
        GameTooltip:Show()
    end)
    loadPresetBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function ProkIconManager:CreateInputField(label, fieldName, yOffset, isNumeric)
    local labelText = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", 20, -yOffset)
    labelText:SetText(label..":")

    local input = CreateFrame("EditBox", "fdfjkjk111111111", self.configFrame, "InputBoxTemplate")
    input:SetWidth(200)
    input:SetHeight(20)
    input:SetPoint("TOPLEFT", 150, -yOffset)
    input:SetAutoFocus(false)
    input:SetFontObject("GameFontNormal")
    
    if isNumeric then
        input:SetNumeric(true)
    end

    self["input_"..fieldName] = input
end

function ProkIconManager:CreateIconDropdown(yPos)
    local container = CreateFrame("Frame", nil, self.configFrame)
    container:SetWidth(250)
    container:SetHeight(40)
    container:SetPoint("TOPLEFT", 20, -yPos)
    
    -- Метка
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", 0, 0)
    label:SetText("Иконка:")
    label:SetJustifyH("LEFT")
    label:SetWidth(120)
    
    -- Кнопка выбора
    self.iconDropdownBtn = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
    self.iconDropdownBtn:SetWidth(120)
    self.iconDropdownBtn:SetHeight(20)
    self.iconDropdownBtn:SetPoint("LEFT", label, "RIGHT", 10, 0)
    self.iconDropdownBtn:SetText("Выбрать...")
    self.iconDropdownBtn:SetScript("OnClick", function()
        self:ShowIconSelectionMenu()
    end)
    
    -- Превью иконки
    self.iconPreview = container:CreateTexture(nil, "OVERLAY")
    self.iconPreview:SetWidth(20)
    self.iconPreview:SetHeight(20)
    self.iconPreview:SetPoint("LEFT", self.iconDropdownBtn, "RIGHT", 5, 0)
    self.iconPreview:Hide()
end

function ProkIconManager:ShowIconSelectionMenu()
    local menu = {
        {text = "Выбрать текстуру", isTitle = true, notCheckable = true},
        {text = "Слева", hasArrow = true, menuList = self:CreateTextureMenuList("Слева")},
        {text = "Сверху", hasArrow = true, menuList = self:CreateTextureMenuList("Сверху")},
        {text = "Справа", hasArrow = true, menuList = self:CreateTextureMenuList("Справа")},
        {text = "Центр", hasArrow = true, menuList = self:CreateTextureMenuList("Фулскрин")}
    }
    
    if not self.iconDropdownMenu then
        self.iconDropdownMenu = CreateFrame("Frame", "ProkIconDropdownMenu", UIParent, "UIDropDownMenuTemplate")
    end
    
    EasyMenu(menu, self.iconDropdownMenu, self.iconDropdownBtn, 0, 0, "MENU", 5)
end

function ProkIconManager:CreateTextureMenuList(position)
    local menuList = {}
    for _, texture in ipairs(self.textureList[position]) do
        table.insert(menuList, {
            text = texture.name,
            func = function()
                -- Закрыть ВСЕ уровни меню
                CloseDropDownMenus() 

                -- Обновить интерфейс
                self.selectedIcon = texture.path
                UIDropDownMenu_SetText(self.texDropdown, texture.name)
                self:ShowTexturePreview(texture.path)
            end,
            notCheckable = true
        })
    end
    return menuList
end

function ProkIconManager:ShowTexturePreview(texturePath)
    if not self.previewFrame then
        self.previewFrame = CreateFrame("Frame", nil, UIParent)
        self.previewFrame.texture = self.previewFrame:CreateTexture(nil, "BACKGROUND")
        self.previewFrame.texture:SetAllPoints()
    end

    local profileIndex = UIDropDownMenu_GetSelectedValue(self.profileDropdown)
    local profile = self.settings[profileIndex]
    
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local width = profile.Rx == 0 and screenWidth or profile.Rx
    local height = profile.Ry == 0 and screenHeight or profile.Ry
    
    self.previewFrame:SetWidth(width)
    self.previewFrame:SetHeight(height)
    self.previewFrame:ClearAllPoints()
    self.previewFrame:SetPoint("CENTER", UIParent, "CENTER", profile.x, profile.y)
    
    local fullTexturePath = texturePath
    if not string.find(texturePath, "Interface\\") then
        fullTexturePath = "Interface\\AddOns\\NSQC\\libs\\" .. texturePath .. ".tga"
    end
    
    self.previewFrame.texture:SetTexture(fullTexturePath)
    self.previewFrame:Show()
    
    self.previewFrame.startTime = GetTime()
    self.previewFrame:SetScript("OnUpdate", function(self, elapsed)
        if GetTime() - self.startTime >= 5 then
            self:Hide()
            self:SetScript("OnUpdate", nil)
        end
    end)
end

function ProkIconManager:AddNewIcon()
    local name = self.input_name:GetText()
    if not name or name == "" then
        print("Ошибка: не указано название")
        return
    end
    if not self.selectedIcon then
        print("Ошибка: не выбрана текстура")
        return
    end
    
    -- Определяем тип триггера
    local triggerType = "buff"
    if self.triggerTypeCustom and self.triggerTypeCustom:GetChecked() then
        triggerType = "custom"
    end
    
    local spellQueueName = self.input_spellqueue_name:GetText()
    if triggerType == "custom" and (not spellQueueName or spellQueueName == "") then
        print("Ошибка: для кастомного триггера необходимо указать название скилла из SpellQueue")
        return
    end
    
    local iconData = {
        name = name,
        skill = self.input_skill:GetText() or "",
        spellqueue_name = spellQueueName,
        icon = self.selectedIcon,
        stack = tonumber(self.input_stack:GetText()) or 0,
        profil = UIDropDownMenu_GetSelectedValue(self.profileDropdown) or 1,
        triggerType = triggerType
    }
    
    -- Инициализируем таблицы если их нет
    if not self.icons then
        self.icons = {}
    end
    
    if not self.externalIconsTable then
        self.externalIconsTable = {}
    end
    
    -- Добавляем в обе таблицы
    self.icons[name] = iconData
    self.externalIconsTable[name] = iconData
    
    -- Регистрация кастомных триггеров
    if triggerType == "custom" and _G.SpellQueueInstance then
        -- Создаем обработчик для активации
        local activateHandler = function(spellName, spellData)
            self:HandleCustomTrigger(spellName, spellData, "onActivate", iconData)
        end
        
        -- Создаем обработчик для деактивации
        local deactivateHandler = function(spellName, spellData)
            self:HandleCustomTrigger(spellName, spellData, "onDeactivate", iconData)
        end
        
        -- Инициализируем таблицу триггеров
        if not _G.SpellQueueInstance.customTriggers then
            _G.SpellQueueInstance.customTriggers = {}
        end
        
        if not _G.SpellQueueInstance.customTriggers[spellQueueName] then
            _G.SpellQueueInstance.customTriggers[spellQueueName] = {}
        end
        
        -- Сохраняем обработчики
        table.insert(_G.SpellQueueInstance.customTriggers[spellQueueName], {
            onActivate = activateHandler,
            onDeactivate = deactivateHandler,
            iconData = iconData
        })
    end
    
    -- Показываем иконку для превью
    local profile = self.settings[iconData.profil]
    local width = profile.Rx == 0 and GetScreenWidth() or profile.Rx
    local height = profile.Ry == 0 and GetScreenHeight() or profile.Ry
    local texturePath = iconData.icon
    if not strfind(texturePath:lower(), "^interface\\") then
        texturePath = "Interface\\AddOns\\NSQC\\libs\\" .. texturePath:gsub("%.tga$", "") .. ".tga"
    end
    self:ShowIcon(name, width, height, profile.x, profile.y, texturePath)
    
    self:ResetForm()
    if self.previewFrame then
        self.previewFrame:Hide()
    end
end

function ProkIconManager:HandleCustomTrigger(spellName, spellData, eventType, iconData)
    if not spellName or not iconData or not iconData.icon then
        return
    end
    if eventType == "onActivate" then
        local profile = self.settings[iconData.profil or 1] or self.settings[1]
        local width = profile.Rx == 0 and GetScreenWidth() or profile.Rx
        local height = profile.Ry == 0 and GetScreenHeight() or profile.Ry
        local x, y = profile.x or 0, profile.y or 0
        if not self.frames then
            self.frames = {}
        end
        if not self.frames[spellName] then
            self.frames[spellName] = CreateFrame("Frame", nil, UIParent)
            self.frames[spellName]:SetFrameStrata("HIGH")
            self.frames[spellName].texture = self.frames[spellName]:CreateTexture(nil, "BACKGROUND")
            self.frames[spellName].texture:SetAllPoints()
        end
        local frame = self.frames[spellName]
        frame:SetSize(width, height)
        frame:ClearAllPoints()
        frame:SetPoint("CENTER", UIParent, "CENTER", x, y)
        -- Обрабатываем путь к текстуре
        local texturePath = iconData.icon
        if not strfind(texturePath:lower(), "^interface\\") then
            -- Проверяем расширение
            if not strfind(texturePath:lower(), "%.tga$") and not strfind(texturePath:lower(), "%.blp$") then
                texturePath = texturePath .. ".tga"
            end
            texturePath = "Interface\\AddOns\\NSQC\\libs\\" .. texturePath
        end
        -- Безопасная загрузка текстуры
        local success = pcall(function()
            frame.texture:SetTexture(texturePath)
        end)
        if not success then
            frame.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            -- Попробуем альтернативный путь
            local altPath = "Interface\\AddOns\\NSQC\\textures\\" .. iconData.icon:gsub("%.tga$", "") .. ".tga"
            pcall(function()
                frame.texture:SetTexture(altPath)
            end)
        end
        frame:Show()
    elseif eventType == "onDeactivate" then
        if self.frames and self.frames[spellName] then
            self.frames[spellName]:Hide()
        end
    end
end

function ProkIconManager:ResetForm()
    self.input_name:SetText("")
    self.input_skill:SetText("")
    self.input_stack:SetText("")
    self.input_spellqueue_name:SetText("") -- Сброс нового поля
    self.selectedIcon = nil
    UIDropDownMenu_SetSelectedValue(self.profileDropdown, 1)
    -- Сброс чекбоксов через прямые ссылки
    if self.triggerTypeBuff then
        self.triggerTypeBuff:SetChecked(true)
    end
    if self.triggerTypeCustom then
        self.triggerTypeCustom:SetChecked(false)
    end
end

function ProkIconManager:ForceHideAllIcons()
    for spellNum, frame in pairs(self.frames) do
        if frame then
            frame:Hide()
        end
    end
    if self.previewFrame then
        self.previewFrame:Hide()
    end
end

SLASH_PROKICONHIDE1 = "/prokiconhide"
SlashCmdList["PROKICONHIDE"] = function()
    ProkIconManager:ForceHideAllIcons()
end

SLASH_PROKICON1 = "/prokicon"
SlashCmdList["PROKICON"] = function()
    if not ProkIconManager.configFrame then
        ProkIconManager:CreateConfigUI()
    end
    ProkIconManager.configFrame:Show()
end


AchievementHelper = {
    cachedAchievements = {},
    achievementCategories = {},
    maxOutputLines = 10,
    achievementHandlers = {
        [0] = "HandleCounterAchievement",
        [5] = "HandleType5Achievement",
        [10] = "HandleStandardAchievement",
        [15] = "HandleType15Achievement",
        [20] = "HandleType20Achievement",
        [25] = "HandleType25Achievement",
        [30] = "HandleType30Achievement",
        [50] = "HandleType50Achievement"
    }
}

function AchievementHelper:FormatMoney(copper)
    copper = copper or 0
    local gold = floor(copper / 10000)
    local silver = floor((copper % 10000) / 100)
    local copper = copper % 100
    
    local parts = {}
    if gold > 0 then table.insert(parts, gold.."g") end
    if silver > 0 then table.insert(parts, silver.."s") end
    if copper > 0 or (#parts == 0) then table.insert(parts, copper.."c") end
    
    return table.concat(parts, " ")
end

function AchievementHelper:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function AchievementHelper:SearchAchievements(searchText)
    if not searchText or string.trim(searchText) == "" then
        return nil, "Ошибка: Введите текст для поиска"
    end
    
    searchText = string.lower(string.trim(searchText))
    local foundAchievements = {}
    
    for id = 1, 10000 do
        local _, name, achievementType, _, _, _, _, description = GetAchievementInfo(id)
        
        if name and (string.find(string.lower(name), searchText) or 
                   (description and string.find(string.lower(description), searchText))) then
            table.insert(foundAchievements, {
                id = id,
                type = achievementType,
                name = name,
                description = description
            })
        end
    end
    
    if #foundAchievements == 0 then
        return nil, "Ачивки не найдены"
    end
    
    return foundAchievements
end

function AchievementHelper:SearchAndShowAchievements(searchText, channel)
    channel = channel or "OFFICER"
    local achievements, errorMsg = self:SearchAchievements(searchText)
    
    if errorMsg then
        self:SendMessage(errorMsg, channel)
        return
    end
        
    local maxToShow = math.min(#achievements, self.maxOutputLines)
    
    for i = 1, maxToShow do
        local achievement = achievements[i]
        self:DisplayAchievement(achievement.id, achievement.type, channel)
    end
end

function AchievementHelper:DisplayAchievement(achievementID, achievementType, channel)
    local handlerName = self.achievementHandlers[achievementType] or "HandleUnknownType"
    local handler = self[handlerName]
    
    if handler then
        handler(self, achievementID, channel)
    else
        self:SendMessage(string.format("Нет обработчика для ачивки ID %d типа %d", 
              achievementID, achievementType), channel)
    end
end

function AchievementHelper:HandleCounterAchievement(id, channel)
    local _, name, _, completed = GetAchievementInfo(id)
    local link = GetAchievementLink(id) or name
    local status = completed and "Выполнено" or "Не выполнено"
    
    -- Получаем статистику и преобразуем в число
    local statValue = tonumber(GetStatistic(id)) or 0
    
    -- Проверяем обычные критерии
    local numCriteria = GetAchievementNumCriteria(id)
    local progressParts = {}
    local hasDetailedProgress = false
    
    for i = 1, numCriteria do
        local criteriaString, _, _, quantity, reqQuantity, _, _, _, progressText = GetAchievementCriteriaInfo(id, i)
        
        if criteriaString then
            quantity = quantity or statValue  -- Используем статистику если нет quantity
            
            -- Для денежных достижений
            if string.find(criteriaString:lower(), "золот") or string.find(name:lower(), "золот") then
                table.insert(progressParts, self:FormatMoney(quantity))
                break
            
            -- Для критериев с текстовым прогрессом
            elseif progressText and progressText ~= "" and progressText ~= "--" then
                table.insert(progressParts, string.format("%d (%s)", quantity, progressText))
                hasDetailedProgress = true
            
            -- Для количественных критериев
            elseif reqQuantity and reqQuantity > 0 then
                table.insert(progressParts, string.format("%d/%d", quantity, reqQuantity))
            
            -- Для простых счетчиков
            elseif quantity > 0 then
                table.insert(progressParts, tostring(quantity))
            end
        end
    end
    
    -- Если не нашли критериев, но есть статистика
    if #progressParts == 0 and statValue > 0 then
        table.insert(progressParts, tostring(statValue))
    end
    
    -- Формируем итоговый прогресс
    if #progressParts > 0 then
        status = status.." ("..table.concat(progressParts, ", ")..")"
    end
    
    -- Отправляем сообщение
    self:SendMessage(string.format("%s [%d][0] - %s", link, id, status), channel)
end

function AchievementHelper:HandleStandardAchievement(id, channel)
    local _, name, _, completed, _, _, _, description = GetAchievementInfo(id)
    local link = GetAchievementLink(id) or name
    local status = completed and "Выполнено" or "Не выполнено"
    
    -- Проверяем критерии для типа 10
    local numCriteria = GetAchievementNumCriteria(id)
    local progressParts = {}
    
    for i = 1, numCriteria do
        local _, _, _, quantity, reqQuantity = GetAchievementCriteriaInfo(id, i)
        if quantity and reqQuantity and reqQuantity > 0 then
            table.insert(progressParts, string.format("%d/%d", quantity, reqQuantity))
        end
    end
    
    -- Добавляем прогресс если есть
    if #progressParts > 0 then
        status = status .. " ("..table.concat(progressParts, ", ")..")"
    end
    
    self:SendMessage(string.format("%s [%d][10] - %s", link, id, status), channel)
    
    -- Выводим награду если есть (10-й параметр GetAchievementInfo)
    local _, _, _, _, _, _, _, _, _, _, rewardText = GetAchievementInfo(id)
    if rewardText and rewardText ~= "" then
        self:SendMessage(string.format("%s", rewardText), channel)
    end
end

function AchievementHelper:HandleType5Achievement(id, channel)
    local _, name = GetAchievementInfo(id)
    local link = GetAchievementLink(id) or name
    self:SendMessage(string.format("%s [%d][%d] - обработчик не реализован", link, id, 5), channel)
end

function AchievementHelper:HandleType15Achievement(id, channel)
    local _, name = GetAchievementInfo(id)
    local link = GetAchievementLink(id) or name
    self:SendMessage(string.format("%s [%d][%d] - обработчик не реализован", link, id, 15), channel)
end

function AchievementHelper:HandleType20Achievement(id, channel)
    local _, name = GetAchievementInfo(id)
    local link = GetAchievementLink(id) or name
    self:SendMessage(string.format("%s [%d][%d] - обработчик не реализован", link, id, 20), channel)
end

function AchievementHelper:HandleType25Achievement(id, channel)
    local _, name = GetAchievementInfo(id)
    local link = GetAchievementLink(id) or name
    self:SendMessage(string.format("%s [%d][%d] - обработчик не реализован", link, id, 25), channel)
end

function AchievementHelper:HandleType30Achievement(id, channel)
    local _, name = GetAchievementInfo(id)
    local link = GetAchievementLink(id) or name
    self:SendMessage(string.format("%s [%d][%d] - обработчик не реализован", link, id, 30), channel)
end

function AchievementHelper:HandleType50Achievement(id, channel)
    local _, name = GetAchievementInfo(id)
    local link = GetAchievementLink(id) or name
    self:SendMessage(string.format("%s [%d][%d] - обработчик не реализован", link, id, 50), channel)
end

function AchievementHelper:HandleUnknownType(id, channel)
    local _, name = GetAchievementInfo(id)
    local link = GetAchievementLink(id) or name
    self:SendMessage(string.format("%s [%d][unknown] - неизвестный тип ачивки", link, id), channel)
end

function AchievementHelper:SendMessage(msg, channel)
    -- Экранируем только опасные символы |, но сохраняем гиперссылки
    local safeMsg = msg:gsub("|([^Hhcr])", "||%1")
    
    if channel and channel ~= "PRINT" then
        SendChatMessage(safeMsg, channel)
    else
        print(msg)
    end
end

function string.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

GuildRecruiter = {}
GuildRecruiter.__index = GuildRecruiter

if not nsDbc then nsDbc = {} end

local CLASSES = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "DRUID"
}
local RACES_ALLIANCE = {"Человек", "Дворф", "Ночной эльф", "Гном", "Дреней"}
local RACES_HORDE = {"Орк", "Нежить", "Таурен", "Тролль", "Эльф крови"}
local ALL_RACES = {}
for _, r in ipairs(RACES_ALLIANCE) do table.insert(ALL_RACES, r) end
for _, r in ipairs(RACES_HORDE) do table.insert(ALL_RACES, r) end

local function CreateLevelPicker(parent, current, callback)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(180, 300)
    frame:SetPoint("CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:Hide()

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame)
    scrollFrame:SetPoint("TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 10)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(160)
    content:SetHeight(80 * 22)

    scrollFrame:SetScrollChild(content)
    scrollFrame:UpdateScrollChildRect()

    local slider = CreateFrame("Slider", nil, frame)
    slider:SetOrientation("VERTICAL")
    slider:SetPoint("TOPRIGHT", -8, -10)
    slider:SetPoint("BOTTOMRIGHT", -8, 10)
    slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 }
    })

    local scrollRange = math.max(0, content:GetHeight() - scrollFrame:GetHeight())
    slider:SetMinMaxValues(0, scrollRange)
    slider:SetValue(0)
    slider:SetValueStep(10)

    frame.scrollFrame = scrollFrame
    frame.slider = slider

    slider:SetScript("OnValueChanged", function(self, value)
        local sf = self:GetParent().scrollFrame
        if sf then sf:SetVerticalScroll(value) end
    end)

    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        offset = math.max(0, math.min(offset, scrollRange))
        self:SetVerticalScroll(offset)
        local s = self:GetParent().slider
        if s then s:SetValue(offset) end
    end)

    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(self, delta)
        local sf = self.scrollFrame
        if not sf then return end
        local current = sf:GetVerticalScroll()
        local step = 20
        local newOffset = current - delta * step
        newOffset = math.max(0, math.min(newOffset, scrollRange))
        sf:SetVerticalScroll(newOffset)
        local s = self.slider
        if s then s:SetValue(newOffset) end
    end)

    for lvl = 1, 80 do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(140, 20)
        btn:SetPoint("TOP", 0, -5 - (lvl - 1) * 22)
        btn:SetText(lvl)
        btn:SetScript("OnClick", function()
            callback(lvl)
            frame:Hide()
        end)
    end

    return frame
end

function GuildRecruiter:ManualSave()
    nsDbc["набор в гильдию"] = {
        exceptions = self.exceptions,
        settings = {
            minLevel = self.settings.minLevel,
            maxLevel = self.settings.maxLevel,
            step = self.settings.step,
            autoAccept = self.settings.autoAccept,
            recursive = self.settings.recursive,
            factions = {
                Alliance = self.settings.factions.Alliance,
                Horde = self.settings.factions.Horde
            },
            classes = self.settings.classes,
            races = self.settings.races
        }
    }
    print("Настройки сохранены (С).")
end

function GuildRecruiter:ManualLoad()
    local saved = nsDbc["набор в гильдию"]
    if not saved or not saved.settings then
        print("Нет сохраненных настроек для загрузки.")
        return
    end

    if saved.settings.minLevel then self.settings.minLevel = saved.settings.minLevel end
    if saved.settings.maxLevel then self.settings.maxLevel = saved.settings.maxLevel end
    if saved.settings.step then self.settings.step = saved.settings.step end
    if type(saved.settings.autoAccept) == "boolean" then self.settings.autoAccept = saved.settings.autoAccept end
    if type(saved.settings.recursive) == "boolean" then self.settings.recursive = saved.settings.recursive end

    if saved.settings.factions then
        if saved.settings.factions.Alliance ~= nil then self.settings.factions.Alliance = saved.settings.factions.Alliance end
        if saved.settings.factions.Horde ~= nil then self.settings.factions.Horde = saved.settings.factions.Horde end
    end

    if saved.settings.classes then
        for cls, val in pairs(saved.settings.classes) do
            if self.settings.classes[cls] ~= nil then
                self.settings.classes[cls] = val
            end
        end
    end

    if saved.settings.races then
        for race, val in pairs(saved.settings.races) do
            if self.settings.races[race] ~= nil then
                self.settings.races[race] = val
            end
        end
    end

    if saved.exceptions then
        self.exceptions = saved.exceptions
    end

    if self.ui then
        if self.ui.minLevelBtn then self.ui.minLevelBtn:SetText(self.settings.minLevel) end
        if self.ui.maxLevelBtn then self.ui.maxLevelBtn:SetText(self.settings.maxLevel) end
        if self.ui.stepDD then UIDropDownMenu_SetText(self.ui.stepDD, "Шаг: " .. tostring(self.settings.step)) end
        
        if self.ui.autoCB then self.ui.autoCB:SetChecked(self.settings.autoAccept) end
        if self.ui.recursiveCB then self.ui.recursiveCB:SetChecked(self.settings.recursive) end

        if self.ui.factionChecks then
            self.ui.factionChecks.Alliance:SetChecked(self.settings.factions.Alliance)
            self.ui.factionChecks.Horde:SetChecked(self.settings.factions.Horde)
        end

        if self.ui.classChecks then
            for cls, cb in pairs(self.ui.classChecks) do
                if self.settings.classes[cls] ~= nil then
                    cb:SetChecked(self.settings.classes[cls])
                end
            end
        end

        if self.ui.raceChecks then
            for race, cb in pairs(self.ui.raceChecks) do
                if self.settings.races[race] ~= nil then
                    cb:SetChecked(self.settings.races[race])
                end
            end
        end
    end
    print("Настройки загружены (З).")
end

function GuildRecruiter.new()
    local self = setmetatable({}, GuildRecruiter)
    self.frame = CreateFrame("Frame", "GuildRecruiterFrame", UIParent)
    self.frame:SetSize(320, 520)
    self.frame:Hide()
    self.frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    self.frame:SetBackdropColor(0, 0, 0, 1)
    self.frame:SetFrameStrata("DIALOG")
    self.loadingText = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.loadingText:SetText("ЗАГРУЗКА...")
    self.loadingText:SetPoint("CENTER")
    if WhoFrame then
        self.frame:SetParent(WhoFrame)
        self.frame:SetPoint("TOPLEFT", WhoFrame, "TOPRIGHT", 10, 0)
    end
    
    local saved = nsDbc["набор в гильдию"] or {}
    self.exceptions = type(saved.exceptions) == "table" and saved.exceptions or {}
    
    local factions = saved.settings and saved.settings.factions or {}
    self.settings = {
        minLevel = type(saved.settings) == "table" and type(saved.settings.minLevel) == "number" and saved.settings.minLevel or 1,
        maxLevel = type(saved.settings) == "table" and type(saved.settings.maxLevel) == "number" and saved.settings.maxLevel or 80,
        step = type(saved.settings) == "table" and type(saved.settings.step) == "number" and saved.settings.step or 5,
        autoAccept = (saved.settings and saved.settings.autoAccept) == true,
        recursive = (saved.settings and saved.settings.recursive) == true,
        factions = {
            Alliance = (factions.Alliance == true),
            Horde = (factions.Horde == true)
        },
        classes = {},
        races = {}
    }
    for _, cls in ipairs(CLASSES) do
        self.settings.classes[cls] = (saved.settings and saved.settings.classes and saved.settings.classes[cls]) == true
    end
    for _, race in ipairs(ALL_RACES) do
        self.settings.races[race] = (saved.settings and saved.settings.races and saved.settings.races[race]) == true
    end
    self.isUIBuilt = false
    self.results = {}
    self.cooldown = false
    self.autoInviteLoop = false
    self.isSearching = false
    self.searchTimer = nil
    self.autoInviteTimer = nil
    self.cooldownTimer = nil
    self:SafeHookWhoFrame()
    return self
end

function GuildRecruiter:SafeHookWhoFrame()
    if not WhoFrame then
        local wait = CreateFrame("Frame")
        wait:SetScript("OnUpdate", function()
            if WhoFrame then
                wait:SetScript("OnUpdate", nil)
                self:DoHookWhoFrame()
                self.frame:SetParent(WhoFrame)
                self.frame:SetPoint("TOPLEFT", WhoFrame, "TOPRIGHT", 10, 0)
            end
        end)
        return
    end
    self:DoHookWhoFrame()
end

function GuildRecruiter:DoHookWhoFrame()
    local origShow = WhoFrame.Show
    WhoFrame.Show = function(...)
        GuildRecruiter.instance.frame:Show()
        if not GuildRecruiter.instance.isUIBuilt then
            GuildRecruiter.instance:BuildUI()
        end
        return origShow(...)
    end
    local origHide = WhoFrame.Hide
    WhoFrame.Hide = function(...)
        GuildRecruiter.instance.frame:Hide()
        return origHide(...)
    end
end

function GuildRecruiter:BuildUI()
    if self.isUIBuilt then return end
    self.isUIBuilt = true
    
    local now = time()
    for name, inviteTime in pairs(self.exceptions) do
        if type(inviteTime) == "number" and now - inviteTime > 7 * 24 * 60 * 60 then
            self.exceptions[name] = nil
        end
    end
    
    if self.loadingText then
        self.loadingText:Hide()
        self.loadingText = nil
    end
    
    local y = -45
    
    local saveBtn = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
    saveBtn:SetSize(32, 32)
    saveBtn:SetPoint("TOPLEFT", 5, -5)
    saveBtn:SetText("С")
    saveBtn:SetScript("OnClick", function() self:ManualSave() end)
    
    local loadBtn = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
    loadBtn:SetSize(32, 32)
    loadBtn:SetPoint("TOPLEFT", saveBtn, "BOTTOMLEFT", 37, 32)
    loadBtn:SetText("З")
    loadBtn:SetScript("OnClick", function() self:ManualLoad() end)
    
    local title = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetText("Набор в гильдию")
    title:SetPoint("TOP", 25, -10)
    
    local minLevelBtn = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
    minLevelBtn:SetSize(40, 20)
    minLevelBtn:SetPoint("TOPLEFT", 20, y)
    minLevelBtn:SetText(self.settings.minLevel)
    
    local maxLevelBtn = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
    maxLevelBtn:SetSize(40, 20)
    maxLevelBtn:SetPoint("LEFT", minLevelBtn, "RIGHT", 10, 0)
    maxLevelBtn:SetText(self.settings.maxLevel)
    
    local minPicker = CreateLevelPicker(self.frame, self.settings.minLevel, function(lvl)
        self.settings.minLevel = lvl
        minLevelBtn:SetText(lvl)
    end)
    
    local maxPicker = CreateLevelPicker(self.frame, self.settings.maxLevel, function(lvl)
        self.settings.maxLevel = lvl
        maxLevelBtn:SetText(lvl)
    end)
    
    minLevelBtn:SetScript("OnClick", function() minPicker:Show() end)
    maxLevelBtn:SetScript("OnClick", function() maxPicker:Show() end)
    
    local stepDD = CreateFrame("Frame", "GuildRecruiterStepDropdown", self.frame, "UIDropDownMenuTemplate")
    stepDD:SetPoint("TOPRIGHT", -20, y)
    UIDropDownMenu_SetWidth(stepDD, 80)
    UIDropDownMenu_Initialize(stepDD, function()
        local info = UIDropDownMenu_CreateInfo()
        for _, v in ipairs({1,2,5,10}) do
            info.text = "Шаг: " .. tostring(v)
            info.func = function()
                UIDropDownMenu_SetText(stepDD, "Шаг: " .. tostring(v))
                self.settings.step = v
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(stepDD, "Шаг: " .. tostring(self.settings.step))
    
    y = y - 35
    
    local factionChecks = {}
    for i, f in ipairs({"Alliance", "Horde"}) do
        local cb = CreateFrame("CheckButton", nil, self.frame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 20 + (i-1)*100, y)
        cb:SetChecked(self.settings.factions[f])
        cb:SetScript("OnClick", function()
            local isChecked = cb:GetChecked()
            self.settings.factions[f] = isChecked
            local raceList = (f == "Alliance") and RACES_ALLIANCE or RACES_HORDE
            for _, race in ipairs(raceList) do
                self.settings.races[race] = isChecked
                if self.ui and self.ui.raceChecks and self.ui.raceChecks[race] then
                    self.ui.raceChecks[race]:SetChecked(isChecked)
                end
            end
        end)
        local lbl = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetText(f)
        lbl:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        factionChecks[f] = cb
    end
    
    local allClassesCB = CreateFrame("CheckButton", nil, self.frame, "UICheckButtonTemplate")
    allClassesCB:SetPoint("TOPLEFT", 220, y)
    allClassesCB:SetScript("OnClick", function()
        local isChecked = allClassesCB:GetChecked()
        for _, cls in ipairs(CLASSES) do
            self.settings.classes[cls] = isChecked
            if self.ui and self.ui.classChecks and self.ui.classChecks[cls] then
                self.ui.classChecks[cls]:SetChecked(isChecked)
            end
        end
    end)
    local lblAll = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lblAll:SetText("Все классы")
    lblAll:SetPoint("LEFT", allClassesCB, "RIGHT", 5, 0)
    
    y = y - 30
    
    local classChecks = {}
    for i, cls in ipairs(CLASSES) do
        local col = (i-1) % 2
        local row = math.floor((i-1)/2)
        local x = 20 + col * 140
        local yy = y - row * 20
        local cb = CreateFrame("CheckButton", nil, self.frame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", x, yy)
        cb:SetChecked(self.settings.classes[cls])
        cb:SetScript("OnClick", function()
            local isChecked = cb:GetChecked()
            self.settings.classes[cls] = isChecked
        end)
        local lbl = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetText(cls)
        lbl:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        classChecks[cls] = cb
    end
    
    y = y - 110
    
    local raceChecks = {}
    for i, race in ipairs(ALL_RACES) do
        local col = (i-1) % 2
        local row = math.floor((i-1)/2)
        local x = 20 + col * 140
        local yy = y - row * 20
        local cb = CreateFrame("CheckButton", nil, self.frame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", x, yy)
        cb:SetChecked(self.settings.races[race])
        cb:SetScript("OnClick", function()
            local isChecked = cb:GetChecked()
            self.settings.races[race] = isChecked
        end)
        local lbl = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetText(race)
        lbl:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        raceChecks[race] = cb
    end
    
    y = y - 110
    
    local scrollFrame = CreateFrame("ScrollFrame", "GuildRecruiterScrollFrame", self.frame)
    scrollFrame:SetPoint("TOPLEFT", 15, y)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 60)
    local playerList = CreateFrame("Frame", nil, scrollFrame)
    playerList:SetWidth(scrollFrame:GetWidth() - 20)
    playerList:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    playerList:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, 0)
    scrollFrame:SetScrollChild(playerList)
    scrollFrame:UpdateScrollChildRect()
    
    local slider = CreateFrame("Slider", "GuildRecruiterScrollSlider", self.frame)
    slider:SetOrientation("VERTICAL")
    slider:SetPoint("TOPRIGHT", -8, y)
    slider:SetPoint("BOTTOMRIGHT", -8, 60)
    slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 3, right = 3, top = 6, bottom = 6 }
    })
    slider:SetMinMaxValues(0, 0)
    slider:SetValue(0)
    slider:SetValueStep(10)
    
    scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
        local maxRange = math.max(0, playerList:GetHeight() - scrollFrame:GetHeight())
        offset = math.max(0, math.min(offset, maxRange))
        self:SetVerticalScroll(offset)
        slider:SetMinMaxValues(0, maxRange)
        slider:SetValue(offset)
    end)
    
    slider:SetScript("OnValueChanged", function(self, value)
        scrollFrame:SetVerticalScroll(value)
    end)
    
    self.frame:EnableMouseWheel(true)
    self.frame:SetScript("OnMouseWheel", function(self, delta)
        local sf = GuildRecruiter.instance.ui.scroll
        if not sf then return end
        local current = sf:GetVerticalScroll()
        local maxRange = math.max(0, GuildRecruiter.instance.ui.playerList:GetHeight() - sf:GetHeight())
        local step = 20
        local newOffset = current - delta * step
        newOffset = math.max(0, math.min(newOffset, maxRange))
        sf:SetVerticalScroll(newOffset)
        GuildRecruiter.instance.ui.slider:SetValue(newOffset)
    end)
    
    local autoCB = CreateFrame("CheckButton", nil, self.frame, "UICheckButtonTemplate")
    autoCB:SetPoint("BOTTOMLEFT", 20, 30)
    autoCB:SetChecked(self.settings.autoAccept)
    autoCB:SetScript("OnClick", function()
        self.settings.autoAccept = autoCB:GetChecked()
        if self.settings.autoAccept and #self.results > 0 then
            self:StartAutoInvite()
        end
    end)
    autoCB:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Автоматически приглашать игроков из списка", 1, 1, 1)
        GameTooltip:Show()
    end)
    autoCB:SetScript("OnLeave", GameTooltip_Hide)

    local recursiveCB = CreateFrame("CheckButton", nil, self.frame, "UICheckButtonTemplate")
    recursiveCB:SetPoint("LEFT", autoCB, "RIGHT", 110, 0)
    recursiveCB:SetChecked(self.settings.recursive)
    recursiveCB:SetScript("OnClick", function()
        self.settings.recursive = recursiveCB:GetChecked()
    end)
    recursiveCB:SetScript("OnEnter", function()
        GameTooltip:SetOwner(recursiveCB, "ANCHOR_RIGHT")
        GameTooltip:SetText("Набирать рекурсивно", 1, 1, 1)
        GameTooltip:AddLine("При достижении максимального уровня поиск начнется заново с минимального.", 1, 0.8, 0, true)
        GameTooltip:Show()
    end)
    recursiveCB:SetScript("OnLeave", GameTooltip_Hide)
    
    local searchBtn = CreateFrame("Button", nil, self.frame, "UIPanelButtonTemplate")
    searchBtn:SetSize(80, 22)
    searchBtn:SetPoint("BOTTOMRIGHT", -20, 30)
    searchBtn:SetText("Найти")
    searchBtn:SetScript("OnClick", function()
        if self.isSearching then
            self:StopSearch()
            searchBtn:SetText("Найти")
        else
            self:StartSearch()
            searchBtn:SetText("Стоп")
        end
    end)
    
    self.ui = {
        minLevelBtn = minLevelBtn,
        maxLevelBtn = maxLevelBtn,
        minPicker = minPicker,
        maxPicker = maxPicker,
        stepDD = stepDD,
        playerList = playerList,
        scroll = scrollFrame,
        slider = slider,
        autoCB = autoCB,
        recursiveCB = recursiveCB,
        searchBtn = searchBtn,
        raceChecks = raceChecks,
        factionChecks = factionChecks,
        classChecks = classChecks
    }
end

function GuildRecruiter:LoadSettings()
    if not self.ui then return end
    self.ui.minLevelBtn:SetText(self.settings.minLevel)
    self.ui.maxLevelBtn:SetText(self.settings.maxLevel)
    UIDropDownMenu_SetText(self.ui.stepDD, "Шаг: " .. tostring(self.settings.step))
    self.ui.autoCB:SetChecked(self.settings.autoAccept)
    if self.ui.recursiveCB then
        self.ui.recursiveCB:SetChecked(self.settings.recursive)
    end

    if self.ui.factionChecks then
        self.ui.factionChecks.Alliance:SetChecked(self.settings.factions.Alliance)
        self.ui.factionChecks.Horde:SetChecked(self.settings.factions.Horde)
    end

    if self.ui.raceChecks then
        for race, cb in pairs(self.ui.raceChecks) do
            cb:SetChecked(self.settings.races[race] == true)
        end
    end
end

function GuildRecruiter:EnableEventMonitoring()
    self.frame:RegisterEvent("WHO_LIST_UPDATE")
    self.frame:RegisterEvent("GUILD_INVITE_REQUEST")
    self.frame:SetScript("OnEvent", function(_, event, ...)
        self:OnEvent(event, ...)
    end)
end

function GuildRecruiter:DisableEventMonitoring()
    self.frame:UnregisterEvent("WHO_LIST_UPDATE")
    self.frame:UnregisterEvent("GUILD_INVITE_REQUEST")
    self.frame:SetScript("OnEvent", nil)
end

function GuildRecruiter:StartSearch()
    self.isSearching = true
    self.currentLevel = self.settings.minLevel
    self.results = {}
    self.autoInviteLoop = false
    
    FriendsFrame:UnregisterEvent("WHO_LIST_UPDATE")
    SetWhoToUI(1)

    self:EnableEventMonitoring()
    self:SendNextWhoQuery()
end

function GuildRecruiter:StopSearch()
    self.isSearching = false
    self:DisableEventMonitoring()
    self.autoInviteLoop = false
    
    FriendsFrame:RegisterEvent("WHO_LIST_UPDATE")
    SetWhoToUI(1)

    if self.ui and self.ui.searchBtn then
        self.ui.searchBtn:SetText("Найти")
    end
    
    if self.searchTimer then
        self.searchTimer:SetScript("OnUpdate", nil)
        self.searchTimer:Hide()
        self.searchTimer = nil
    end
end

function GuildRecruiter:SendNextWhoQuery()
    if self.currentLevel > self.settings.maxLevel then
        if self.settings.recursive then
            self.currentLevel = self.settings.minLevel
        else
            self:StopSearch()
            if self.settings.autoAccept and #self.results > 0 then
                self:StartAutoInvite()
            end
            return
        end
    end
    
    local maxL = math.min(self.currentLevel + self.settings.step - 1, self.settings.maxLevel)
    local query = self.currentLevel .. "-" .. maxL
    
    SendWho(query)
    
    self.currentLevel = maxL + 1
    
    if not self.searchTimer then
        self.searchTimer = CreateFrame("Frame")
        self.searchTimer.guildRecruiter = self
        self.searchTimer:SetScript("OnUpdate", function(frame, deltaTime)
            frame.elapsed = (frame.elapsed or 0) + deltaTime
            if frame.elapsed >= 6 then
                local gr = frame.guildRecruiter
                if gr and gr.isSearching then
                    gr:SendNextWhoQuery()
                end
                frame.elapsed = 0
            end
        end)
    else
        self.searchTimer.elapsed = 0
    end
    self.searchTimer:Show()
end

function GuildRecruiter:ProcessWhoResults()
    local n = GetNumWhoResults()
    local now = time()
    for i = 1, n do
        local name, guildName, lvl, raceRU, classRU, _, classENG = GetWhoInfo(i)
        if not (guildName and guildName ~= "") then
            local inviteTime = self.exceptions[name]
            if not (type(inviteTime) == "number" and now - inviteTime <= 7 * 24 * 60 * 60) then
                if self:MatchesFilters(raceRU, classENG) then
                    -- Проверяем, нет ли уже такого игрока в results
                    local alreadyInResults = false
                    for _, r in ipairs(self.results) do
                        if r.name == name then
                            alreadyInResults = true
                            break
                        end
                    end
                    if not alreadyInResults then
                        table.insert(self.results, {name = name, level = lvl, race = raceRU, class = classENG})
                    end
                end
            end
        end
    end
    self:UpdatePlayerList()
    if self.settings.autoAccept and #self.results > 0 and not self.autoInviteLoop then
        self:StartAutoInvite()
    end
end

function GuildRecruiter:MatchesFilters(race, class)
    if not self.settings.classes[class] then return false end
    if not self.settings.races[race] then return false end

    if tContains(RACES_ALLIANCE, race) then
        return self.settings.factions.Alliance
    elseif tContains(RACES_HORDE, race) then
        return self.settings.factions.Horde
    else
        return false
    end
end

function GuildRecruiter:UpdatePlayerList()
    if not self.ui or not self.ui.playerList or not self.ui.scroll then return end
    local list = self.ui.playerList
    local scroll = self.ui.scroll

    for i = 1, 200 do
        local btn = _G["GuildRecruiterPlayerBtn" .. i]
        if btn then btn:Hide() end
    end

    for i, p in ipairs(self.results) do
        local btnName = "GuildRecruiterPlayerBtn" .. i
        local btn = _G[btnName]
        if not btn then
            btn = CreateFrame("Button", btnName, list, "UIPanelButtonTemplate")
            btn:SetSize(list:GetWidth() - 20, 20)
            btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            
            btn:SetScript("OnClick", function(self, button)
                if GuildRecruiter.instance.cooldown then return end
                
                if button == "LeftButton" then
                    GuildInvite(p.name)
                    GuildRecruiter.instance.exceptions[p.name] = time()
                    
                    if GuildRecruiter.instance.exceptions[p.name] then
                        print("|cFF00FF00[GUILD RECRUITER]|r (Клик) " .. p.name .. " добавлен в игнор.")
                    else
                        print("|cFFFF0000[GUILD RECRUITER]|r (Клик) ОШИБКА добавления " .. p.name)
                    end
                    
                    GuildRecruiter.instance:RemoveFromList(p.name)
                    GuildRecruiter.instance:SetCooldown()
                    
                elseif button == "RightButton" then
                    GuildRecruiter.instance.exceptions[p.name] = time()
                    print("|cFF00FF00[GUILD RECRUITER]|r (ПКМ) " .. p.name .. " добавлен в игнор без инвайта.")
                    GuildRecruiter.instance:RemoveFromList(p.name)
                end
            end)
        end
        
        btn:SetText(p.name)
        btn:Show()
        btn:SetPoint("TOP", list, "TOP", 0, -5 - (i - 1) * 25)
    end

    local contentHeight = math.max(1, #self.results) * 25 + 10
    list:SetHeight(contentHeight)

    scroll:SetScrollChild(list)
    scroll:UpdateScrollChildRect()

    local _, maxRange = scroll:GetVerticalScrollRange()
    if maxRange and maxRange > 0 then
        scroll:SetVerticalScroll(maxRange)
    end

    scroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local _, range = self:GetVerticalScrollRange()
        if not range then return end
        if delta > 0 then
            self:SetVerticalScroll(math.max(current - 20, 0))
        else
            self:SetVerticalScroll(math.min(current + 20, range))
        end
    end)
end

function GuildRecruiter:InviteAndExclude(name)
    if self.exceptions[name] then
        print("|cFFFF0000[GUILD RECRUITER]|r АВТО-ИНВАЙТ: " .. name .. " УЖЕ есть в списке исключений. Приглашение ОТМЕНЕНО.")
        return
    end

    GuildInvite(name)
    self.exceptions[name] = time()

    if self.exceptions[name] then
        print("|cFF00FF00[GUILD RECRUITER]|r АВТО-ИНВАЙТ: Игрок " .. name .. " приглашен. ДОБАВЛЕН в игнор-лист.")
    else
        print("|cFFFF0000[GUILD RECRUITER]|r ОШИБКА: Игрок " .. name .. " НЕ добавился в игнор-лист!")
    end

    self:RemoveFromList(name)
    self:SetCooldown()
end

function GuildRecruiter:ExcludeOnly(name)
    self.exceptions[name] = time()
    self:RemoveFromList(name)
end

function GuildRecruiter:SetCooldown()
    self.cooldown = true
    
    if not self.cooldownTimer then
        self.cooldownTimer = CreateFrame("Frame")
        self.cooldownTimer.elapsed = 0
        self.cooldownTimer.guildRecruiter = self
        self.cooldownTimer:SetScript("OnUpdate", function(self, deltaTime)
            self.elapsed = self.elapsed + deltaTime
            if self.elapsed >= 6 then
                if self.guildRecruiter then
                    self.guildRecruiter.cooldown = false
                end
                self.elapsed = 0
                self:SetScript("OnUpdate", nil)
                self:Hide()
                self.guildRecruiter.cooldownTimer = nil
            end
        end)
    else
        self.cooldownTimer.elapsed = 0
    end
    self.cooldownTimer:Show()
end

function GuildRecruiter:RemoveFromList(name)
    local i = 1
    while i <= #self.results do
        if self.results[i].name == name then
            table.remove(self.results, i)
        else
            i = i + 1
        end
    end
    self:UpdatePlayerList()
end

function GuildRecruiter:StartAutoInvite()
    if self.autoInviteLoop or #self.results == 0 then return end
    self.autoInviteLoop = true
    
    if self.autoInviteTimer then
        self.autoInviteTimer:SetScript("OnUpdate", nil)
        self.autoInviteTimer:Hide()
        self.autoInviteTimer = nil
    end
    
    self:ProcessAutoInvite()
end

function GuildRecruiter:ProcessAutoInvite()
    if not self.settings.autoAccept or #self.results == 0 then
        self.autoInviteLoop = false
        if self.autoInviteTimer then
            self.autoInviteTimer:SetScript("OnUpdate", nil)
            self.autoInviteTimer:Hide()
            self.autoInviteTimer = nil
        end
        return
    end

    local p = table.remove(self.results, 1)
    if p then
        self:InviteAndExclude(p.name)

        if not self.autoInviteTimer then
            self.autoInviteTimer = CreateFrame("Frame")
            self.autoInviteTimer.guildRecruiter = self
            self.autoInviteTimer:SetScript("OnUpdate", function(frame, deltaTime)
                frame.elapsed = (frame.elapsed or 0) + deltaTime
                if frame.elapsed >= 6 then
                    local gr = frame.guildRecruiter
                    if gr and gr.autoInviteLoop then
                        gr:ProcessAutoInvite()
                    end
                    frame.elapsed = 0
                end
            end)
        else
            self.autoInviteTimer.elapsed = 0
        end
        self.autoInviteTimer:Show()
    else
        self.autoInviteLoop = false
        if self.autoInviteTimer then
            self.autoInviteTimer:SetScript("OnUpdate", nil)
            self.autoInviteTimer:Hide()
            self.autoInviteTimer = nil
        end
    end
end

function GuildRecruiter:OnEvent(event, ...)
    if event == "WHO_LIST_UPDATE" and self.isSearching then
        self:ProcessWhoResults()
    elseif event == "GUILD_INVITE_REQUEST" then
        local name = ...
        self:RemoveFromList(name)
    end
end

function GuildRecruiter:SaveSettings()
    nsDbc["набор в гильдию"] = {
        exceptions = self.exceptions,
        settings = {
            minLevel = self.settings.minLevel,
            maxLevel = self.settings.maxLevel,
            step = self.settings.step,
            autoAccept = self.settings.autoAccept,
            recursive = self.settings.recursive,
            factions = {
                Alliance = self.settings.factions.Alliance,
                Horde = self.settings.factions.Horde
            },
            classes = self.settings.classes,
            races = self.settings.races
        }
    }
end









-- ============================================
-- ФОРУМ КЛИЕНТ - ВЕРСИЯ 6.7.1 DEBUG
-- Все данные только от сервера, без локального кэша тем
-- Фикс гонки пакетов, поддержка ссылок в шепоте, оптимизация
-- ДОБАВЛЕНА ОТЛАДКА ДЛЯ ПОИСКА ПРОБЛЕМЫ С ТЕМАМИ
-- ============================================
NSForumClient = NSForumClient or {}
NSForumFrameID = NSForumFrameID or 0

-- Константы для отладки
local DEBUG_MODE = false
local function DebugPrint(...)
    if DEBUG_MODE then
        print("|cff00ffff[FORUM DEBUG]|r", ...)
    end
end

NSForumClient.tempModerators = {}
local MAX_ADDON_MSG = 240
local CHUNK_DELAY = 0.3

local COLORS = {
    background = {0.12, 0.12, 0.12, 0.92},
    border = {0.3, 0.3, 0.3, 1},
    row_bg_even = {0.08, 0.08, 0.1, 0.9},
    row_bg_odd = {0.1, 0.1, 0.13, 0.9},
    row_text = {0.9, 0.9, 0.95, 1},
    row_highlight = {0.25, 0.25, 0.3, 0.9},
    post_text = {0.85, 0.85, 0.9, 1},
    header_bg = {0.2, 0.2, 0.2, 0.8},
    label_text = {0.9, 0.9, 0.9, 1},
    post_bg = {0.08, 0.08, 0.1, 0.9},
    author_color = {1, 0.84, 0, 1},
    meta_color = {0.5, 0.5, 0.5, 1},
    reply_bg = {0.15, 0.15, 0.15, 0.9},
    pinned_bg = {0.15, 0.12, 0.05, 0.95},
    pinned_icon = {1, 0.84, 0, 1},
}

local COLOR_TAGS = {
    ["к"] = "|cffff0000", ["з"] = "|cff00ff00", ["с"] = "|cff0000ff",
    ["б"] = "|cff00ffff", ["о"] = "|cffff8000", ["ж"] = "|cffffff00",
    ["ф"] = "|cffff00ff", ["бл"] = "|cffffffff", ["ч"] = "|cff000000",
    ["ср"] = "|cff808080", ["рз"] = "|cffff8080", ["л"] = "|cff80ff00",
}

local REACTIONS = {
    { icon = "Interface\\AddOns\\NSQC3\\libs\\emote_like", name = "Like", key = "like" },
    { icon = "Interface\\AddOns\\NSQC3\\libs\\emote_smile", name = "Love", key = "love" },
    { icon = "Interface\\AddOns\\NSQC3\\libs\\emote_fire", name = "Fire", key = "fire" },
    { icon = "Interface\\AddOns\\NSQC3\\libs\\emote_100", name = "Clap", key = "clap" },
    { icon = "Interface\\AddOns\\NSQC3\\libs\\emote_sad", name = "Sad", key = "sad" },
    { icon = "Interface\\AddOns\\NSQC3\\libs\\emote_think", name = "Wow", key = "wow" },
    { icon = "Interface\\AddOns\\NSQC3\\libs\\emote_dislike", name = "Dislike", key = "dislike" },
    { icon = "Interface\\AddOns\\NSQC3\\libs\\emote_facepalm", name = "Facepalm", key = "facepalm" },
    { icon = "Interface\\AddOns\\NSQC3\\libs\\emote_poop", name = "Poop", key = "poop" },
}

-- ============================================
-- ТАЙМЕРЫ
-- ============================================
NSForumClient.TimerID = 0

function NSForumClient.CreateTimer(delay, callback)
    if not callback then return nil end
    if delay <= 0 then callback(); return nil end
    NSForumClient.TimerID = NSForumClient.TimerID + 1
    local timer = CreateFrame("Frame")
    timer.elapsed = 0
    timer.callback = callback
    timer:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= delay then
            if self.callback then
                local cb = self.callback
                self.callback = nil
                self:SetScript("OnUpdate", nil)
                self:Hide()
                cb()
            end
        end
    end)
    return timer
end

-- ============================================
-- ДИАЛОГ ПОДТВЕРЖДЕНИЯ УДАЛЕНИЯ
-- ============================================
if not StaticPopupDialogs["NSFORUM_DELETE_THREAD"] then
    StaticPopupDialogs["NSFORUM_DELETE_THREAD"] = {
        text = "Вы действительно хотите удалить эту тему?\n|cffff0000Это действие нельзя отменить.|r",
        button1 = "Удалить",
        button2 = "Отмена",
        OnAccept = function(self, data)
            if data and data.threadId then
                SendAddonMessage("NSFORUM", "DELETE_THREAD:" .. data.threadId, "GUILD")
                NSForumClient.SetCurrentView("list")
                NSForumClient.SetSelectedThreadId(nil)
                NSForumClient.RequestThreads()
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

-- ============================================
-- СИСТЕМА АНИМАЦИЙ
-- ============================================
NSForumClient.AnimFrame = nil
NSForumClient.ActiveAnims = {}

local function EaseOutBack(t)
    if t >= 1.0 then return 1.0 end
    local c1 = 1.70158
    return 1 + (c1 + 1) * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2)
end

local function EaseInOutQuad(t)
    if t >= 1.0 then return 1.0 end
    if t <= 0.0 then return 0.0 end
    return t < 0.5 and 2 * t * t or -1 + (4 - 2 * t) * t
end

local function EaseOutQuad(t)
    if t >= 1.0 then return 1.0 end
    return 1 - (1 - t) * (1 - t)
end

function NSForumClient.InitAnimFrame()
    if NSForumClient.AnimFrame then return end
    NSForumClient.AnimFrame = CreateFrame("Frame")
    NSForumClient.AnimFrame:SetScript("OnUpdate", function(self, elapsed)
        local keys = {}
        for key in pairs(NSForumClient.ActiveAnims) do
            table.insert(keys, key)
        end
        for _, key in ipairs(keys) do
            local anim = NSForumClient.ActiveAnims[key]
            if anim and anim.active then
                anim.elapsed = anim.elapsed + elapsed
                local t = math.min(anim.elapsed / anim.duration, 1.0)
                if anim.easing then t = anim.easing(t) end
                if anim.callback then anim.callback(t) end
                if anim.elapsed >= anim.duration then
                    anim.active = false
                    NSForumClient.ActiveAnims[key] = nil
                    if anim.onComplete then anim.onComplete() end
                end
            end
        end
    end)
end

function NSForumClient.StopAnimation(key)
    if key and NSForumClient.ActiveAnims[key] then
        NSForumClient.ActiveAnims[key] = nil
    end
end

function NSForumClient.StopAllAnimations()
    for key in pairs(NSForumClient.ActiveAnims) do
        NSForumClient.ActiveAnims[key] = nil
    end
end

function NSForumClient.AddAnimation(key, duration, callback, easing, onComplete)
    NSForumClient.InitAnimFrame()
    if not callback then
        if onComplete then onComplete() end
        return
    end
    NSForumClient.StopAnimation(key)
    NSForumClient.ActiveAnims[key] = {
        duration = duration or 0.3, elapsed = 0,
        callback = callback, easing = easing,
        onComplete = onComplete, active = true
    }
end

function NSForumClient.AnimateWindowOpen(frame, onComplete)
    if not frame then
        if onComplete then onComplete() end
        return
    end
    frame:SetAlpha(0.3)
    frame:SetScale(0.85)
    frame:Show()
    frame:Raise()
    NSForumClient.AddAnimation("window_open", 0.35,
        function(progress)
            if frame and frame:IsShown() then
                frame:SetAlpha(0.3 + 0.7 * progress)
                frame:SetScale(0.85 + 0.15 * progress)
            end
        end, EaseOutBack,
        function()
            if frame then
                frame:SetAlpha(1.0)
                frame:SetScale(1.0)
                if onComplete then onComplete() end
            end
        end
    )
end

function NSForumClient.AnimateWindowClose(frame, onComplete)
    if not frame or not frame:IsShown() then
        if onComplete then onComplete() end
        return
    end
    NSForumClient.AddAnimation("window_close", 0.25,
        function(progress)
            if frame then
                frame:SetAlpha(1.0 - progress)
                frame:SetScale(1.0 - 0.15 * progress)
            end
        end, EaseInOutQuad,
        function()
            if onComplete then onComplete() end
        end
    )
end

function NSForumClient.AnimateRowAppearHorizontal(rowFrame, index, totalCount)
    if not rowFrame then return end
    local targetHeight = rowFrame.targetHeight or 70
    local key = (rowFrame:GetName() or "row") .. "_slide_" .. index
    local delay = math.min((index - 1) * 0.04, 0.4)
    local fromLeft = (index % 2 == 1)
    local point, relativeTo, relativePoint, xOfs, yOfs = rowFrame:GetPoint()
    local parentWidth = rowFrame:GetParent() and rowFrame:GetParent():GetWidth() or 600
    rowFrame:SetAlpha(0.2)
    rowFrame:SetHeight(1)
    local function animateFrame(progress)
        if rowFrame and rowFrame:IsShown() and rowFrame:GetParent() then
            local easedProgress = EaseOutQuad(progress)
            rowFrame:SetAlpha(0.2 + 0.8 * easedProgress)
            rowFrame:SetHeight(1 + (targetHeight - 1) * easedProgress)
            local offsetX = (1 - easedProgress) * parentWidth * 0.5
            if fromLeft then offsetX = -offsetX end
            rowFrame:ClearAllPoints()
            rowFrame:SetPoint(point, relativeTo, relativePoint, xOfs + offsetX, yOfs)
        end
    end
    local function onAnimComplete()
        if rowFrame and rowFrame:IsShown() then
            rowFrame:SetAlpha(1.0)
            rowFrame:SetHeight(targetHeight)
            rowFrame:ClearAllPoints()
            rowFrame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        end
    end
    if delay <= 0 then
        NSForumClient.AddAnimation(key, 0.4, animateFrame, nil, onAnimComplete)
    else
        local savedFrame = rowFrame
        NSForumClient.CreateTimer(delay, function()
            if not savedFrame or not savedFrame:IsShown() or not savedFrame:GetParent() then return end
            NSForumClient.AddAnimation(key, 0.4, animateFrame, nil, onAnimComplete)
        end)
    end
end

function NSForumClient.AnimateNewRowAppear(rowFrame, index)
    if not rowFrame then return end
    local key = (rowFrame:GetName() or "row") .. "_new_" .. index
    rowFrame:SetAlpha(0.3)
    rowFrame:SetScale(0.9)
    NSForumClient.AddAnimation(key, 0.3,
        function(progress)
            if rowFrame and rowFrame:IsShown() then
                rowFrame:SetAlpha(0.3 + 0.7 * progress)
                rowFrame:SetScale(0.9 + 0.1 * progress)
            end
        end, EaseOutBack,
        function()
            if rowFrame then
                rowFrame:SetAlpha(1.0)
                rowFrame:SetScale(1.0)
            end
        end
    )
end

function NSForumClient.AnimateNewPostAppear(postFrame, index)
    if not postFrame then return end
    local key = (postFrame:GetName() or "post") .. "_new_" .. index
    postFrame:SetAlpha(0.3)
    postFrame:SetScale(0.9)
    NSForumClient.AddAnimation(key, 0.3,
        function(progress)
            if postFrame and postFrame:IsShown() then
                postFrame:SetAlpha(0.3 + 0.7 * progress)
                postFrame:SetScale(0.9 + 0.1 * progress)
            end
        end, EaseOutBack,
        function()
            if postFrame then
                postFrame:SetAlpha(1.0)
                postFrame:SetScale(1.0)
            end
        end
    )
end

-- ============================================
-- СИСТЕМА ОТПРАВКИ ЧАНКОВ (С ОТЛАДКОЙ)
-- ============================================
NSForumClient.chunkSendQueue = {}
local chunkSendTimer = CreateFrame("Frame")
chunkSendTimer:Hide()
chunkSendTimer.timer = 0
chunkSendTimer:SetScript("OnUpdate", function(self, elapsed)
    self.timer = self.timer - elapsed
    if self.timer <= 0 then
        if #NSForumClient.chunkSendQueue > 0 then
            local msg = table.remove(NSForumClient.chunkSendQueue, 1)
            if IsInGuild() then 
                SendAddonMessage("NSFORUM", msg, "GUILD")
            end
            self.timer = CHUNK_DELAY
        else
            self:Hide()
            self.timer = 0
        end
    end
end)

function NSForumClient.SendChunkedMessage(prefix, data)
    if not IsInGuild() then return end
    local fullMsg = prefix .. data
    if #fullMsg <= MAX_ADDON_MSG then
        SendAddonMessage("NSFORUM", fullMsg, "GUILD")
        return
    end
    
    local availableSpace = MAX_ADDON_MSG - #prefix - 15
    local chunks = {}
    local pos = 1
    while pos <= #data do
        local chunk = data:sub(pos, pos + availableSpace - 1)
        table.insert(chunks, chunk)
        pos = pos + availableSpace
    end
    
    NSForumClient.chunkSendQueue = {}
    for i, chunk in ipairs(chunks) do
        local chunkMsg = i == 1 and (prefix .. "START:" .. #chunks .. "|" .. chunk)
            or (prefix .. "CHUNK:" .. i .. "|" .. chunk)
        table.insert(NSForumClient.chunkSendQueue, chunkMsg)
    end
    chunkSendTimer.timer = 0
    chunkSendTimer:Show()
end

-- ============================================
-- СБОРКА ЧАНКОВ (С ОТЛАДКОЙ)
-- ============================================
NSForumClient.recvChunkBuffer = {}

function NSForumClient.AssembleChunks(action, sender, chunkData, totalChunks, chunkNum)
    local bufferKey = action .. "_" .. sender

    if totalChunks then
        -- Новый набор чанков
        NSForumClient.recvChunkBuffer[bufferKey] = {
            total = totalChunks,
            chunks = {[1] = chunkData or ""},
            received = 1,
            action = action,
            sender = sender
        }
        return nil
    elseif chunkNum then
        local buffer = NSForumClient.recvChunkBuffer[bufferKey]
        if buffer then
            buffer.chunks[chunkNum] = chunkData or ""
            buffer.received = buffer.received + 1
            
            if buffer.received >= buffer.total then
                local fullData = ""
                for i = 1, buffer.total do
                    fullData = fullData .. (buffer.chunks[i] or "")
                end
                
                NSForumClient.recvChunkBuffer[bufferKey] = nil
                return fullData
            end
        else
            print("|cff00ffff[Forum Debug]|r ВНИМАНИЕ: Получен чанк, но буфер не найден для ключа:", bufferKey)
        end
        return nil
    end
    -- Одиночное сообщение (не чанк)
    print("|cff00ffff[Forum Debug]|r Одиночное сообщение, длина:", chunkData and #chunkData or 0)
    return chunkData
end

-- ============================================
-- БАЗОВЫЕ ФУНКЦИИ (ТОЛЬКО НАСТРОЙКИ, БЕЗ КЭША)
-- ============================================

function ProcessContentForDisplay(content)
    if not content then return "" end
    return content
end

function NSForumClient.EnsureDBSettings()
    if not nsDbc then nsDbc = {} end
    if not nsDbc["форум"] then nsDbc["форум"] = {} end
    if not nsDbc["форум"].windowPosition then nsDbc["форум"].windowPosition = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 } end
    if not nsDbc["форум"].view then nsDbc["форум"].view = "list" end
    if not nsDbc["форум"].selectedThreadId then nsDbc["форум"].selectedThreadId = nil end
    if not nsDbc["форум"].isOpen then nsDbc["форум"].isOpen = false end
end

function NSForumClient.IsWindowOpen()
    return NSForumClient.window and NSForumClient.window:IsShown()
end

function NSForumClient.GetCurrentView()
    NSForumClient.EnsureDBSettings()
    return nsDbc["форум"].view
end

function NSForumClient.SetCurrentView(view)
    NSForumClient.EnsureDBSettings()
    nsDbc["форум"].view = view
end

function NSForumClient.GetSelectedThreadId()
    NSForumClient.EnsureDBSettings()
    return nsDbc["форум"].selectedThreadId
end

function NSForumClient.SetSelectedThreadId(threadId)
    NSForumClient.EnsureDBSettings()
    nsDbc["форум"].selectedThreadId = threadId
end

function NSForumClient.SetLoadingThread(isLoading)
    NSForumClient.EnsureDBSettings()
    nsDbc["форум"].loadingThread = isLoading
end

function NSForumClient.IsLoadingThread()
    NSForumClient.EnsureDBSettings()
    return nsDbc["форум"].loadingThread
end

-- ============================================
-- ФУНКЦИИ ФОРМАТИРОВАНИЯ
-- ============================================

local function InsertColorTag(editBox, colorCode)
    if not editBox then return end
    local currentText = editBox:GetText() or ""
    local tag = "!ц" .. colorCode .. "Текст!цц"
    local prefixLen = #("!ц" .. colorCode)
    editBox:SetText(currentText .. tag)
    editBox:SetFocus()
    editBox:HighlightText(#currentText + prefixLen + 1, #currentText + prefixLen + 5)
end

local function InsertSizeTag(editBox, size)
    if not editBox then return end
    local currentText = editBox:GetText() or ""
    local tag = "!р" .. size .. "Текст!рр"
    local prefixLen = #("!р" .. size)
    editBox:SetText(currentText .. tag)
    editBox:SetFocus()
    editBox:HighlightText(#currentText + prefixLen + 1, #currentText + prefixLen + 5)
end

local function InsertSymbol(editBox, symbol)
    if not editBox then return end
    local currentText = editBox:GetText() or ""
    editBox:SetText(currentText .. symbol)
    editBox:SetFocus()
end

-- ============================================
-- 5. ПАНЕЛЬ ФОРМАТИРОВАНИЯ (БЕЗ КНОПКИ ССЫЛКИ)
-- ============================================
function NSForumClient.CreateFormattingBar(parent, targetEditBox)
    if not targetEditBox then return nil end
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetHeight(28)
    local bg = bar:CreateTexture(nil, "ARTWORK")
    bg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    bg:SetAllPoints(bar)
    bg:SetGradientAlpha("HORIZONTAL", 0.15, 0.15, 0.15, 0.5, 0.2, 0.2, 0.2, 0.5)
    local btnSize, btnSpacing, currentX = 22, 2, 5
    
    local function CreateButton(label, r, g, b, onClick, tooltipTitle)
        local btn = CreateFrame("Button", nil, bar)
        btn:SetSize(btnSize, btnSize)
        btn:SetPoint("LEFT", bar, "LEFT", currentX, 0)
        currentX = currentX + btnSize + btnSpacing
        btn:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 8, edgeSize = 8, insets = {left = 2, right = 2, top = 2, bottom = 2}})
        btn:SetBackdropColor(0, 0, 0, 0.9)
        btn:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
        local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btnText:SetPoint("CENTER")
        btnText:SetText(label)
        if r and g and b then btnText:SetTextColor(r, g, b, 1) else btnText:SetTextColor(1, 1, 1, 1) end
        btn:SetHighlightTexture("Interface\\Buttons\\White8x8")
        local hl = btn:GetHighlightTexture()
        if hl then hl:SetVertexColor(1, 0.9, 0.4, 0.3); hl:SetAllPoints(btn) end
        btn:SetScript("OnEnter", function(self) if tooltipTitle then GameTooltip:SetOwner(self, "ANCHOR_TOP"); GameTooltip:SetText(tooltipTitle, 1, 1, 1); GameTooltip:Show() end end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        btn:SetScript("OnClick", function() onClick(targetEditBox) end)
        return btn
    end
    
    local colorDefs = {
        { label = "К", r = 1, g = 0, b = 0, code = "к" }, { label = "З", r = 0, g = 1, b = 0, code = "з" },
        { label = "С", r = 0, g = 0, b = 1, code = "с" }, { label = "Б", r = 0, g = 1, b = 1, code = "б" },
        { label = "О", r = 1, g = 0.5, b = 0, code = "о" }, { label = "Ж", r = 1, g = 1, b = 0, code = "ж" },
        { label = "Ф", r = 1, g = 0, b = 1, code = "ф" }, { label = "Бл", r = 1, g = 1, b = 1, code = "бл" },
        { label = "Ч", r = 0, g = 0, b = 0, code = "ч" }, { label = "Ср", r = 0.5, g = 0.5, b = 0.5, code = "ср" },
        { label = "Рз", r = 1, g = 0.5, b = 0.5, code = "рз" }, { label = "Л", r = 0.5, g = 1, b = 0, code = "л" },
    }
    for _, cd in ipairs(colorDefs) do CreateButton(cd.label, cd.r, cd.g, cd.b, function(eb) InsertColorTag(eb, cd.code) end, "Цвет: " .. cd.label) end
    currentX = currentX + 8
    for _, size in ipairs({"10", "12", "14", "18", "22", "28"}) do CreateButton(size, nil, nil, nil, function(eb) InsertSizeTag(eb, size) end, "Размер: " .. size .. "px") end
    currentX = currentX + 8
    CreateButton("•", nil, nil, nil, function(eb) InsertSymbol(eb, "•") end, "Маркер списка")
    CreateButton("[ ]", 0.4, 0.8, 1, function(eb)
        if not eb then return end
        local currentText = eb:GetText() or ""
        local tag = "--[Текст для копирования--]"
        eb:SetText(currentText .. tag)
        eb:SetFocus()
        eb:HighlightText(#currentText + 4, #currentText + 24)
    end, "Блок для копирования")
    
    local linkHint = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    linkHint:SetPoint("LEFT", bar, "LEFT", currentX + 10, 0)
    linkHint:SetText("Shift+клик по предмету — вставит ссылку")
    linkHint:SetTextColor(0.6, 0.6, 0.6, 1)
    return bar
end

-- ============================================
-- УНИЧТОЖЕНИЕ ОКНА
-- ============================================

function NSForumClient.DestroyWindow()
    if not NSForumClient.window then return end
    NSForumClient.StopAllAnimations()
    NSForumClient.recvChunkBuffer = {}
    NSForumClient.SetLoadingThread(false)
    NSForumClient.SetSelectedThreadId(nil)
    NSForumClient.SetCurrentView("list")
    
    local function DestroyAllChildren(f)
        if not f then return end
        local children = {f:GetChildren()}
        for _, child in ipairs(children) do
            if child then
                local childName = child:GetName()
                DestroyAllChildren(child)
                if child.SetScrollChild then child:SetScrollChild(nil) end
                child:Hide()
                child:SetParent(nil)
                if childName then _G[childName] = nil end
            end
        end
    end
    DestroyAllChildren(NSForumClient.window)
    local windowName = NSForumClient.window:GetName()
    NSForumClient.window:Hide()
    NSForumClient.window:SetParent(nil)
    if windowName then _G[windowName] = nil end
    NSForumClient.window = nil
    NSForumClient.viewFrame = nil
    NSForumClient.reactionPanel = nil
    NSForumClient.EnsureDBSettings()
    nsDbc["форум"].isOpen = false
end

-- ============================================
-- СОЗДАНИЕ ОКНА
-- ============================================

function NSForumClient.CreateForumWindow()
    NSForumClient.EnsureDBSettings()
    local savedThreadId = NSForumClient.GetSelectedThreadId()
    local openSpecificTopic = (savedThreadId ~= nil)
    
    if not openSpecificTopic then
        NSForumClient.SetCurrentView("list")
    end
    
    if NSForumClient.window and NSForumClient.window:IsShown() then
        return
    end
    
    if NSForumClient.window then
        NSForumClient.DestroyWindow()
    end
    
    NSForumFrameID = NSForumFrameID + 1
    local fid = NSForumFrameID
    local frameName = "NSForumFrame_" .. fid
    local frame = CreateFrame("Frame", frameName, UIParent)
    frame:SetSize(650, 550)
    frame:SetFrameStrata("HIGH")
    frame:SetBackdrop({ 
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", 
        tile = true, tileSize = 16, edgeSize = 32, 
        insets = { left = 11, right = 12, top = 12, bottom = 11 } 
    })
    frame:SetBackdropColor(unpack(COLORS.background))
    frame:SetBackdropBorderColor(unpack(COLORS.border))
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local pt, _, rel, ox, oy = self:GetPoint()
        nsDbc["форум"].windowPosition = { point = pt, relativePoint = rel, x = ox, y = oy }
    end)
    
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetSize(frame:GetWidth() - 64, 24)
    titleBar:SetPoint("TOPLEFT", 32, -8)
    titleBar:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"})
    titleBar:SetBackdropColor(0.3, 0.3, 0.3, 0.5)
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("CENTER")
    titleText:SetText("Гильдейский форум")
    titleText:SetTextColor(1, 0.9, 0.4, 1)
    
    local p = nsDbc["форум"].windowPosition.point or "CENTER"
    local r = nsDbc["форум"].windowPosition.relativePoint or "CENTER"
    local x = nsDbc["форум"].windowPosition.x or 0
    local y = nsDbc["форум"].windowPosition.y or 0
    frame:SetPoint(p, UIParent, r, x, y)
    
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        NSForumClient.AnimateWindowClose(frame, function()
            NSForumClient.DestroyWindow()
        end)
    end)
    
    local createBtn = CreateFrame("Button", nil, frame)
    createBtn:SetSize(24, 24)
    createBtn:SetPoint("TOPLEFT", 5, -5)
    createBtn:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
    createBtn:SetScript("OnClick", function() 
        NSForumClient.SetSelectedThreadId(nil)
        NSForumClient.SetCurrentView("create")
        NSForumClient.RenderView() 
    end)
    createBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Создать тему", 1, 0.9, 0.4, 1)
        GameTooltip:Show()
    end)
    createBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    frame.createBtn = createBtn
    
    local editBtn = CreateFrame("Button", nil, frame)
    editBtn:SetSize(24, 24)
    editBtn:SetPoint("LEFT", createBtn, "RIGHT", 4, 0)
    editBtn:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-OfficerNote-Up")
    editBtn:SetScript("OnClick", function() 
        NSForumClient.SetCurrentView("edit_thread")
        NSForumClient.RenderView() 
    end)
    editBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Редактировать тему", 1, 0.9, 0.4, 1)
        GameTooltip:Show()
    end)
    editBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    editBtn:Hide()
    frame.editBtn = editBtn
    
    local deleteBtn = CreateFrame("Button", nil, frame)
    deleteBtn:SetSize(24, 24)
    deleteBtn:SetPoint("LEFT", editBtn, "RIGHT", 4, 0)
    deleteBtn:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
    deleteBtn:SetScript("OnClick", function()
        local tId = NSForumClient.GetSelectedThreadId()
        if tId then
            StaticPopup_Show("NSFORUM_DELETE_THREAD", nil, nil, { threadId = tId })
        end
    end)
    deleteBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Удалить тему", 1, 0.5, 0.5, 1)
        GameTooltip:Show()
    end)
    deleteBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    deleteBtn:Hide()
    frame.deleteBtn = deleteBtn
    
    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-OnlineDivider")
    divider:SetHeight(2)
    divider:SetPoint("TOPLEFT", 20, -35)
    divider:SetPoint("TOPRIGHT", -20, -35)
    
    local content = CreateFrame("Frame", "NSForumContent_" .. fid, frame)
    content:SetPoint("TOPLEFT", 18, -42)
    content:SetPoint("BOTTOMRIGHT", -18, 5)
    frame.content = content
    
    NSForumClient.window = frame
    NSForumClient.EnsureDBSettings()
    nsDbc["форум"].isOpen = true
    
    NSForumClient.AnimateWindowOpen(frame, function()
        if openSpecificTopic then
            NSForumClient.tempPosts = {}
            NSForumClient.tempReactions = {}
            NSForumClient.RequestThreads()
            NSForumClient.SetLoadingThread(true)
            NSForumClient.RequestThreadFull(savedThreadId)
        else
            NSForumClient.SetSelectedThreadId(nil)
            NSForumClient.tempPosts = {}
            NSForumClient.tempReactions = {}
            NSForumClient.RequestThreads()
        end
    end)
end

-- ============================================
-- ОТОБРАЖЕНИЕ (использует временные данные от сервера)
-- ============================================

NSForumClient.renderLocked = false
NSForumClient.pendingRender = false

NSForumClient.tempThreads = {}
NSForumClient.tempPosts = {}
NSForumClient.tempReactions = {}

function NSForumClient.ClearView()
    if not NSForumClient.window or not NSForumClient.window.content then return end
    if NSForumClient.viewFrame then
        local function DestroyAllChildren(f)
            if not f then return end
            local children = {f:GetChildren()}
            for _, child in ipairs(children) do
                if child then
                    local childName = child:GetName()
                    DestroyAllChildren(child)
                    if child.SetScrollChild then child:SetScrollChild(nil) end
                    child:Hide()
                    child:SetParent(nil)
                    if childName then _G[childName] = nil end
                end
            end
        end
        DestroyAllChildren(NSForumClient.viewFrame)
        NSForumClient.viewFrame:Hide()
        NSForumClient.viewFrame:SetParent(nil)
        NSForumClient.viewFrame = nil
    end
    if NSForumClient.reactionPanel then
        NSForumClient.reactionPanel:Hide()
        NSForumClient.reactionPanel:SetParent(nil)
        NSForumClient.reactionPanel = nil
    end
end

-- ============================================
-- 8. ОТОБРАЖЕНИЕ ТЕМЫ (ИСПРАВЛЕНО)
-- ============================================
function NSForumClient.DrawThreadView(parent)
    local tId = NSForumClient.GetSelectedThreadId()
    if not tId then NSForumClient.SetCurrentView("list"); NSForumClient.RenderView(); return end
    local thread = nil
    for _, t in ipairs(NSForumClient.tempThreads) do if t.id == tId then thread = t; break end end
    if not thread then NSForumClient.SetCurrentView("list"); NSForumClient.RenderView(); return end
    local threadPosts = {}
    for _, p in ipairs(NSForumClient.tempPosts) do if p.threadId == tId then table.insert(threadPosts, p) end end
    table.sort(threadPosts, function(a, b) return a.id < b.id end)
    local fid = NSForumFrameID
    local headerBg = parent:CreateTexture(nil, "ARTWORK")
    headerBg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    headerBg:SetHeight(40)
    headerBg:SetPoint("TOPLEFT", 2, -2)
    headerBg:SetPoint("TOPRIGHT", -2, -2)
    headerBg:SetGradientAlpha("HORIZONTAL", 0.2, 0.2, 0.2, 0.8, 0.3, 0.3, 0.3, 0.8)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLeftYellow")
    header:SetPoint("TOPLEFT", 10, -5)
    header:SetPoint("RIGHT", -40, 0)
    header:SetJustifyH("LEFT")
    header:SetText(ProcessContentForDisplay(thread.title))
    header:SetTextColor(unpack(COLORS.row_text))
    local meta = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    meta:SetPoint("BOTTOMLEFT", 10, 2)
    meta:SetText("|cff808080Автор:|r " .. thread.author .. "  |  |cff808080Дата:|r " .. thread.date)
    local backBtn = CreateFrame("Button", nil, parent)
    backBtn:SetSize(24, 24)
    backBtn:SetPoint("TOPRIGHT", -8, -8)
    backBtn:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    backBtn:SetScript("OnClick", function()
        NSForumClient.SetLoadingThread(false)
        NSForumClient.SetCurrentView("list")
        NSForumClient.SetSelectedThreadId(nil)
        NSForumClient.tempPosts = {}
        NSForumClient.tempReactions = {}
        NSForumClient.RequestThreads()
    end)
    local postCont = CreateFrame("ScrollFrame", "NSForumPostScroll_" .. fid, parent)
    postCont:SetPoint("TOPLEFT", 5, -50)
    postCont:SetPoint("BOTTOMRIGHT", -5, 55)
    postCont:EnableMouseWheel(true)
    local inner = CreateFrame("Frame", "NSForumPostInner_" .. fid, postCont)
    inner:SetSize(postCont:GetWidth() or 600, 100)
    postCont:SetScrollChild(inner)
    local sb = CreateFrame("Slider", "NSForumPostSlider_" .. fid, postCont)
    sb:SetOrientation("VERTICAL")
    sb:SetPoint("TOPRIGHT", postCont, "TOPRIGHT", -2, -2)
    sb:SetPoint("BOTTOMRIGHT", postCont, "BOTTOMRIGHT", -2, 2)
    sb:SetWidth(16)
    sb:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    sb:SetBackdrop({bgFile = "Interface\\Buttons\\UI-ScrollBar-Background"})
    sb:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    sb:SetValueStep(20)
    postCont.scrollbar = sb
    postCont:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local newVal = current - (delta * 20)
        if newVal < 0 then newVal = 0 end
        local maxScroll = select(2, self.scrollbar:GetMinMaxValues())
        if maxScroll and newVal > maxScroll then newVal = maxScroll end
        self:SetVerticalScroll(newVal); self.scrollbar:SetValue(newVal)
    end)
    sb:SetScript("OnValueChanged", function(self, val) postCont:SetVerticalScroll(val) end)
    local totalHeightAccumulator = 5
    if #threadPosts == 0 then
        local emptyText = inner:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("TOP", 0, -20)
        emptyText:SetText("Нет сообщений в теме")
        emptyText:SetTextColor(unpack(COLORS.row_text))
        emptyText:SetJustifyH("CENTER")
        totalHeightAccumulator = 100
    else
        for i, p in ipairs(threadPosts) do
            local rowY = -totalHeightAccumulator
            local postFrame = CreateFrame("Frame", "NSForumPost_" .. fid .. "_" .. p.id, inner)
            postFrame:SetWidth(inner:GetWidth() or 600)
            postFrame:SetPoint("TOPLEFT", inner, "TOPLEFT", 2, rowY)
            postFrame.postId = p.id
            local bg = postFrame:CreateTexture(nil, "BACKGROUND")
            bg:SetTexture("Interface\\Buttons\\White8x8")
            bg:SetVertexColor(unpack(COLORS.post_bg))
            bg:SetAllPoints(postFrame)
            local authorText = postFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            authorText:SetPoint("TOPLEFT", 10, -5)
            authorText:SetPoint("RIGHT", -10, 0)
            authorText:SetJustifyH("LEFT")
            local authorLabel = "|cffFFD700" .. p.author .. "|r"
            if i == 1 then authorLabel = authorLabel .. " |cff808080(автор)|r" end
            authorLabel = authorLabel .. "  |cff808080" .. (p.date or "") .. "|r"
            authorText:SetText(authorLabel)
            local div = postFrame:CreateTexture(nil, "ARTWORK")
            div:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
            div:SetHeight(1)
            div:SetPoint("TOPLEFT", 10, -23)
            div:SetPoint("TOPRIGHT", -10, 0)
            local contentText = postFrame:CreateFontString(nil, "OVERLAY")
            contentText:SetPoint("TOPLEFT", 15, -28)
            contentText:SetPoint("RIGHT", postFrame, "RIGHT", -15, 0)
            contentText:SetFont("Fonts\\FRIZQT__.TTF", 14)
            contentText:SetJustifyH("LEFT")
            local processedContent = p.content or ""
            
            -- Декодирование
            processedContent = string.gsub(processedContent, "&#124;", "|")
            processedContent = string.gsub(processedContent, "&#44;", ",")
            
            processedContent = string.gsub(processedContent, "!ц(%x%x%x%x%x%x%x%x)(.-)!цц", function(hex, text) return "|cff" .. hex .. text .. "|r" end)
            for tag, hex in pairs(COLOR_TAGS) do
                processedContent = string.gsub(processedContent, "!ц" .. tag .. "(.-)!цц", function(text) return hex .. text .. "|r" end)
            end
            processedContent = string.gsub(processedContent, "!р%d+", "")
            processedContent = string.gsub(processedContent, "!рр", "")
            processedContent = string.gsub(processedContent, "!цц", "")
            
            local blocks = NSForumClient.ParseContentBlocks(processedContent)
            local hasSpecialBlocks = false
            for _, block in ipairs(blocks) do if block.type == "copyable" or block.type == "link" then hasSpecialBlocks = true; break end end
            
            local contentHeight
            if hasSpecialBlocks then
                local currentY = -28
                contentText:Hide()
                for _, block in ipairs(blocks) do
                    if block.type == "text" and block.content ~= "" then
                        local textFrame = postFrame:CreateFontString(nil, "OVERLAY")
                        textFrame:SetPoint("TOPLEFT", 15, currentY)
                        textFrame:SetPoint("RIGHT", postFrame, "RIGHT", -15, 0)
                        textFrame:SetFont("Fonts\\FRIZQT__.TTF", 14)
                        textFrame:SetJustifyH("LEFT")
                        textFrame:SetText(block.content)
                        textFrame:SetTextColor(unpack(COLORS.row_text))
                        currentY = currentY - (textFrame:GetStringHeight() or 14) - 5
                    elseif block.type == "copyable" then
                        local copyBlock = NSForumClient.CreateCopyableBlock(postFrame, block.content, currentY)
                        currentY = currentY - (copyBlock:GetHeight() or 24) - 5
                    elseif block.type == "link" then
                        local linkBlock = NSForumClient.CreateLinkBlock(postFrame, block.linkPayload, block.linkText, currentY)
                        currentY = currentY - (linkBlock:GetHeight() or 24) - 5
                    end
                end
                contentHeight = math.abs(currentY) - 28
            else
                contentText:SetText(processedContent)
                contentText:SetTextColor(unpack(COLORS.row_text))
                contentHeight = contentText:GetStringHeight()
            end
            if not contentHeight or contentHeight < 14 then contentHeight = 14 end
            postFrame._contentHeight = contentHeight
            local reactionHeight = 0
            local reactions = NSForumClient.tempReactions
            if reactions and reactions[p.id] then
                for _, reaction in ipairs(REACTIONS) do if reactions[p.id][reaction.key] and #reactions[p.id][reaction.key] > 0 then reactionHeight = 24; break end end
            end
            local capturedPostId = p.id
            local reactionBtn = CreateFrame("Button", "NSForumReactionBtn_" .. fid .. "_" .. p.id, postFrame)
            reactionBtn:SetSize(24, 24)
            reactionBtn:SetPoint("BOTTOMRIGHT", -8, 4)
            reactionBtn:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
            reactionBtn:SetScript("OnClick", function(self, button) NSForumClient.ShowReactionPanel(capturedPostId, self) end)
            if reactionHeight > 0 then
                local reactionBar = CreateFrame("Frame", nil, postFrame)
                reactionBar.isReactionBar = true
                reactionBar:SetHeight(24)
                reactionBar:SetPoint("BOTTOMLEFT", postFrame, "BOTTOMLEFT", 10, 4)
                reactionBar:SetPoint("BOTTOMRIGHT", reactionBtn, "LEFT", -8, 0)
                local xOffset = 0
                for _, reaction in ipairs(REACTIONS) do
                    local count = reactions[p.id][reaction.key] and #reactions[p.id][reaction.key] or 0
                    if count > 0 then
                        local capturedReactionKey = reaction.key
                        local icon = CreateFrame("Button", nil, reactionBar)
                        icon:SetSize(20, 20)
                        icon:SetPoint("LEFT", reactionBar, "LEFT", xOffset, 0)
                        xOffset = xOffset + 24
                        local tex = icon:CreateTexture(nil, "OVERLAY")
                        tex:SetAllPoints()
                        tex:SetTexture(reaction.icon)
                        local countText = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                        countText:SetPoint("LEFT", icon, "RIGHT", 2, 0)
                        countText:SetText(tostring(count))
                        countText:SetTextColor(0.7, 0.7, 0.7, 1)
                        icon:SetScript("OnClick", function() NSForumClient.AddReaction(capturedPostId, capturedReactionKey) end)
                    end
                end
            end
            local frameHeight = contentHeight + 30 + reactionHeight
            postFrame._baseHeight = 30 + reactionHeight
            postFrame.targetHeight = frameHeight
            postFrame:SetHeight(frameHeight)
            postFrame:Show()
            totalHeightAccumulator = totalHeightAccumulator + frameHeight + 5
            NSForumClient.AnimateRowAppearHorizontal(postFrame, i, #threadPosts)
        end
    end
    totalHeightAccumulator = totalHeightAccumulator + 10
    inner:SetHeight(math.max(totalHeightAccumulator, postCont:GetHeight() or 100))
    local scrollRange = math.max(0, totalHeightAccumulator - (postCont:GetHeight() or 100))
    sb:SetMinMaxValues(0, scrollRange)
    sb:SetValue(0)
    postCont:SetVerticalScroll(0)
    local replyBox = CreateFrame("EditBox", "NSForumReplyBox_" .. fid .. "_" .. tId, parent)
    replyBox:SetPoint("BOTTOMLEFT", 10, 8)
    replyBox:SetPoint("BOTTOMRIGHT", -120, 8)
    replyBox:SetHeight(28)
    replyBox:SetAutoFocus(false)
    replyBox:SetMaxLetters(500)
    replyBox:SetFontObject("GameFontNormal")
    replyBox:SetTextInsets(8, 8, 4, 4)
    replyBox:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 8, edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 }})
    replyBox:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    replyBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.8)
    replyBox:SetTextColor(unpack(COLORS.row_text))
    replyBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local function SendReply()
        if not IsInGuild() then UIErrorsFrame:AddMessage("Необходимо состоять в гильдии", 1, 0, 0, 1, 5); return end
        local c = replyBox:GetText()
        if c and c ~= "" then
            local escapedContent = c:gsub("|", "&#124;"):gsub(",", "&#44;")
            SendAddonMessage("NSFORUM", "NEW_POST:" .. tId .. "|" .. escapedContent, "GUILD")
            replyBox:SetText(""); replyBox:ClearFocus()
        end
    end
    replyBox:SetScript("OnEnterPressed", function(self) SendReply() end)
    local replyBtn = CreateFrame("Button", "NSForumReplyBtn_" .. fid .. "_" .. tId, parent, "UIPanelButtonTemplate")
    replyBtn:SetSize(90, 24)
    replyBtn:SetPoint("LEFT", replyBox, "RIGHT", 5, 0)
    replyBtn:SetText("Ответить")
    replyBtn:SetScript("OnClick", function() SendReply() end)
end

function NSForumClient.RenderView()
    DebugPrint("RenderView called. renderLocked=", NSForumClient.renderLocked, "pendingRender=", NSForumClient.pendingRender)
    
    if NSForumClient.renderLocked then
        NSForumClient.pendingRender = true
        DebugPrint("Render locked, pending...")
        return
    end
    NSForumClient.renderLocked = true
    if not NSForumClient.window or not NSForumClient.window:IsShown() then
        NSForumClient.renderLocked = false
        DebugPrint("Window not shown, aborting render")
        return
    end
    local view = NSForumClient.GetCurrentView()
    DebugPrint("Current view:", view)
    
    if view == "thread" and NSForumClient.IsLoadingThread() then
        NSForumClient.renderLocked = false
        DebugPrint("Still loading thread, aborting render")
        return
    end
    
    NSForumClient.StopAllAnimations()
    NSForumClient.ClearView()
    local content = NSForumClient.window.content
    if not content then NSForumClient.renderLocked = false; return end
    NSForumClient.viewFrame = CreateFrame("Frame", "NSForumViewFrame_" .. NSForumFrameID, content)
    NSForumClient.viewFrame:SetAllPoints(content)
    NSForumClient.viewFrame:Show()
    local frame = NSForumClient.window
    
    if view == "thread" then
        local tId = NSForumClient.GetSelectedThreadId()
        local isCreator = false
        local isModerator = false
        local playerName = UnitName("player")
        
        if NSForumClient.tempModerators and NSForumClient.tempModerators[playerName] then
            isModerator = true
        end
        
        if tId then
            for _, t in ipairs(NSForumClient.tempThreads) do
                if t.id == tId and t.author == playerName then 
                    isCreator = true
                    break 
                end
            end
        end
        
        if frame.editBtn then 
            if isCreator or isModerator then frame.editBtn:Show() else frame.editBtn:Hide() end 
        end
        if frame.deleteBtn then 
            if isCreator or isModerator then frame.deleteBtn:Show() else frame.deleteBtn:Hide() end 
        end
    else
        if frame.editBtn then frame.editBtn:Hide() end
        if frame.deleteBtn then frame.deleteBtn:Hide() end
    end
    
    if view == "list" then 
        DebugPrint("Drawing list view with", #NSForumClient.tempThreads, "threads")
        -- Вывод всех тем для отладки
        if DEBUG_MODE then
            for i, t in ipairs(NSForumClient.tempThreads) do
                DebugPrint("  Thread", i, ":", "id=", t.id, "title=", t.title, "author=", t.author, "pinned=", tostring(t.pinned))
            end
        end
        NSForumClient.DrawListView(NSForumClient.viewFrame)
    elseif view == "create" then NSForumClient.DrawCreateView(NSForumClient.viewFrame)
    elseif view == "thread" then NSForumClient.DrawThreadView(NSForumClient.viewFrame)
    elseif view == "edit_thread" then NSForumClient.DrawEditThreadView(NSForumClient.viewFrame)
    else NSForumClient.SetCurrentView("list"); NSForumClient.renderLocked = false; NSForumClient.RenderView(); return end
    NSForumClient.renderLocked = false
    if NSForumClient.pendingRender then
        NSForumClient.pendingRender = false
        DebugPrint("Executing pending render")
        NSForumClient.RenderView()
    end
end

function NSForumClient.DrawListView(parent)
    local fid = NSForumFrameID
    local headerBg = parent:CreateTexture(nil, "ARTWORK")
    headerBg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    headerBg:SetHeight(28)
    headerBg:SetPoint("TOPLEFT", 2, -2)
    headerBg:SetPoint("TOPRIGHT", -2, -2)
    headerBg:SetGradientAlpha("HORIZONTAL", 0.2, 0.2, 0.2, 0.8, 0.3, 0.3, 0.3, 0.8)
    local headerText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLeftYellow")
    headerText:SetPoint("LEFT", headerBg, "LEFT", 10, 0)
    headerText:SetPoint("TOP", headerBg, "TOP", 0, -5)
    headerText:SetText("Темы обсуждений")
    headerText:SetTextColor(unpack(COLORS.row_text))
    local threadCount = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    threadCount:SetPoint("RIGHT", headerBg, "RIGHT", -10, 0)
    threadCount:SetText("Всего: " .. #NSForumClient.tempThreads)
    threadCount:SetTextColor(unpack(COLORS.row_text))
    local sf = CreateFrame("ScrollFrame", "NSForumListScroll_" .. fid, parent)
    sf:SetPoint("TOPLEFT", 5, -35)
    sf:SetPoint("BOTTOMRIGHT", -1, 5)
    sf:EnableMouseWheel(true)
    local scrollCont = CreateFrame("Frame", "NSForumListScrollCont_" .. fid, sf)
    scrollCont:SetSize(sf:GetWidth(), 10)
    sf:SetScrollChild(scrollCont)
    local sb = CreateFrame("Slider", "NSForumListSlider_" .. fid, sf)
    sb:SetOrientation("VERTICAL")
    sb:SetPoint("TOPRIGHT", sf, "TOPRIGHT", -2, -2)
    sb:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", -2, 2)
    sb:SetWidth(16)
    sb:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    sb:SetValueStep(20)
    sf.scrollbar = sb
    sf:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local newVal = current - (delta * 20)
        if newVal < 0 then newVal = 0 end
        local maxScroll = select(2, self.scrollbar:GetMinMaxValues())
        if maxScroll and newVal > maxScroll then newVal = maxScroll end
        self:SetVerticalScroll(newVal); self.scrollbar:SetValue(newVal)
    end)
    sb:SetScript("OnValueChanged", function(self, val) sf:SetVerticalScroll(val) end)
    local threads = NSForumClient.tempThreads
    local totalHeightAccumulator = 5
    if #threads == 0 then
        local emptyText = scrollCont:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("TOP", 0, -20)
        emptyText:SetText("Нет активных тем\n\nСоздайте новую тему")
        emptyText:SetJustifyH("CENTER")
        emptyText:SetTextColor(unpack(COLORS.row_text))
        totalHeightAccumulator = 120
    else
        local sortedThreads = {}
        for _, t in ipairs(threads) do table.insert(sortedThreads, t) end
        table.sort(sortedThreads, function(a, b)
            if (a.pinned and not b.pinned) then return true end
            if (not a.pinned and b.pinned) then return false end
            local dateA = a.lastPostDate or a.date or ""
            local dateB = b.lastPostDate or b.date or ""
            return dateA > dateB
        end)
        DebugPrint("Drawing", #sortedThreads, "sorted threads")
        for i, t in ipairs(sortedThreads) do
            local rowY = -totalHeightAccumulator
            local rowFrame = CreateFrame("Frame", "NSForumThreadRow_" .. fid .. "_" .. i, scrollCont)
            rowFrame:SetHeight(70)
            rowFrame.targetHeight = 70
            -- ВАЖНО: устанавливаем ширину строки равной ширине контейнера
            local containerWidth = scrollCont:GetWidth()
            if not containerWidth or containerWidth <= 0 then
                containerWidth = sf:GetWidth() - 20
                DebugPrint("WARNING: scrollCont width is 0, using sf width:", containerWidth)
            end
            rowFrame:SetWidth(containerWidth)
            rowFrame:SetPoint("TOPLEFT", scrollCont, "TOPLEFT", 2, rowY)
            rowFrame:SetPoint("TOPRIGHT", scrollCont, "TOPRIGHT", -2, rowY)
            
            local bg = rowFrame:CreateTexture(nil, "BACKGROUND")
            bg:SetTexture("Interface\\Buttons\\White8x8")
            local bgColor
            if t.pinned then bgColor = COLORS.pinned_bg else bgColor = (i % 2 == 0) and COLORS.row_bg_even or COLORS.row_bg_odd end
            bg:SetVertexColor(unpack(bgColor))
            bg:SetAllPoints(rowFrame)

            local threadId = t.id
            local threadTitle = t.title or "Без названия"

            local rowBtn = CreateFrame("Button", "NSForumRowBtn_" .. fid .. "_" .. i, rowFrame)
            rowBtn:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 45, 0)
            rowBtn:SetPoint("BOTTOMRIGHT", rowFrame, "BOTTOMRIGHT", 0, 0)
            rowBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            rowBtn:SetScript("OnClick", function(self, button)
                if button == "LeftButton" then
                    NSForumClient.SetSelectedThreadId(threadId)
                    NSForumClient.SetCurrentView("thread")
                    NSForumClient.SetLoadingThread(true)
                    NSForumClient.RequestThreadFull(threadId)
                else
                    if not NSForumClient.shareMenu then
                        local menu = CreateFrame("Frame", "NSForumShareMenu", UIParent, "UIDropDownMenuTemplate")
                        NSForumClient.shareMenu = menu
                    end
                    local menuFrame = NSForumClient.shareMenu
                    UIDropDownMenu_Initialize(menuFrame, function(self, level)
                        local info = UIDropDownMenu_CreateInfo()
                        info.text = "Отправить в чат"
                        info.func = function()
                            if IsInGuild() then
                                SendAddonMessage("NSFORUM", "ftCache:" .. threadId .. " " .. (t.title or "Без названия"), "GUILD")
                            end
                            local editBox = ChatEdit_ChooseBoxForSend()
                            if editBox then editBox:Insert("/forumtopic " .. threadId) end
                        end
                        UIDropDownMenu_AddButton(info)
                        
                        info = UIDropDownMenu_CreateInfo()
                        info.text = "Показать ID: " .. threadId
                        info.func = function()
                            print("|cffFFD700[Forum]|r ID темы: " .. threadId)
                            print("|cffFFD700[Forum]|r Команда: /forumtopic " .. threadId)
                        end
                        UIDropDownMenu_AddButton(info)
                    end)
                    ToggleDropDownMenu(1, nil, menuFrame, "cursor", 0, 0)
                end
            end)

            local pinBtn = CreateFrame("Button", "NSForumPinBtn_" .. fid .. "_" .. i, rowFrame)
            pinBtn:SetSize(28, 28)
            pinBtn:SetPoint("LEFT", rowFrame, "LEFT", 8, 0)
            local iconTex = pinBtn:CreateTexture(nil, "OVERLAY")
            iconTex:SetTexture("Interface\\GossipFrame\\BattlemasterGossipIcon")
            iconTex:SetAllPoints()
            iconTex:SetVertexColor(t.pinned and unpack(COLORS.pinned_icon) or {0.5, 0.5, 0.5, 1})

            pinBtn:SetScript("OnClick", function()
                SendAddonMessage("NSFORUM", (t.pinned and "UNPIN_THREAD:" or "PIN_THREAD:") .. threadId, "GUILD")
            end)
            pinBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(t.pinned and "Открепить тему" or "Закрепить тему", 1, 0.84, 0)
                GameTooltip:Show()
            end)
            pinBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            local titleText = rowBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            titleText:SetPoint("TOPLEFT", rowFrame, "TOPLEFT", 45, -8)
            titleText:SetPoint("RIGHT", rowFrame, "RIGHT", -15, 0)
            titleText:SetJustifyH("LEFT")
            titleText:SetText(ProcessContentForDisplay(threadTitle))
            titleText:SetTextColor(unpack(COLORS.row_text))
            
            local authorText = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            authorText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -2)
            authorText:SetText("Автор: " .. (t.author or "Неизвестный"))
            authorText:SetTextColor(unpack(COLORS.meta_color))
            
            local dateText = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            dateText:SetPoint("TOPLEFT", authorText, "BOTTOMLEFT", 0, -2)
            dateText:SetText("Последнее: " .. (t.lastPostDate or t.date or "Неизвестно"))
            dateText:SetTextColor(unpack(COLORS.meta_color))
            
            local repliesText = rowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            repliesText:SetPoint("RIGHT", rowFrame, "RIGHT", -35, 0)
            repliesText:SetPoint("TOP", rowFrame, "TOP", 0, -12)
            repliesText:SetText(math.max(0, (t.postCount or 0) - 1) .. " отв.")
            repliesText:SetTextColor(unpack(COLORS.meta_color))
            
            local arrow = rowFrame:CreateTexture(nil, "OVERLAY")
            arrow:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
            arrow:SetSize(16, 16)
            arrow:SetPoint("RIGHT", rowFrame, "RIGHT", -12, 0)
            
            rowFrame:Show()
            totalHeightAccumulator = totalHeightAccumulator + 70 + 5
            NSForumClient.AnimateRowAppearHorizontal(rowFrame, i, #sortedThreads)
        end
    end
    totalHeightAccumulator = totalHeightAccumulator + 10
    DebugPrint("Total scroll height:", totalHeightAccumulator)
    scrollCont:SetHeight(math.max(totalHeightAccumulator, sf:GetHeight() or 100))
    local scrollRange = math.max(0, totalHeightAccumulator - (sf:GetHeight() or 100))
    sb:SetMinMaxValues(0, scrollRange)
    sb:SetValue(0)
    sf:SetVerticalScroll(0)
end

-- ============================================
-- 6. СОЗДАНИЕ ТЕМЫ
-- ============================================
function NSForumClient.DrawCreateView(parent)
    local fid = NSForumFrameID
    local headerBg = parent:CreateTexture(nil, "ARTWORK")
    headerBg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    headerBg:SetHeight(28)
    headerBg:SetPoint("TOPLEFT", 2, -2)
    headerBg:SetPoint("TOPRIGHT", -2, -2)
    headerBg:SetGradientAlpha("HORIZONTAL", 0.2, 0.2, 0.2, 0.8, 0.3, 0.3, 0.3, 0.8)
    local headerText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLeftYellow")
    headerText:SetPoint("LEFT", headerBg, "LEFT", 10, 0)
    headerText:SetPoint("TOP", headerBg, "TOP", 0, -5)
    headerText:SetText("Создание новой темы")
    headerText:SetTextColor(unpack(COLORS.row_text))
    local titleLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -40)
    titleLabel:SetText("Название темы:")
    titleLabel:SetTextColor(unpack(COLORS.label_text))
    local titleBox = CreateFrame("EditBox", "NSForumCreateTitleBox_" .. fid, parent, "InputBoxTemplate")
    titleBox:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 0, -5)
    titleBox:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, -40)
    titleBox:SetHeight(28)
    titleBox:SetAutoFocus(false)
    titleBox:SetMaxLetters(100)
    titleBox:SetFontObject("GameFontNormal")
    titleBox:SetTextInsets(8, 8, 4, 4)
    titleBox:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"})
    titleBox:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    titleBox:SetTextColor(unpack(COLORS.row_text))
    titleBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local contentLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentLabel:SetPoint("TOPLEFT", titleBox, "BOTTOMLEFT", 0, -20)
    contentLabel:SetText("Содержание:")
    contentLabel:SetTextColor(unpack(COLORS.label_text))
    local contentScroll = CreateFrame("ScrollFrame", "NSForumCreateScroll_" .. fid, parent)
    local editBox = CreateFrame("EditBox", "NSForumCreateContentBox_" .. fid, contentScroll)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(0)
    editBox:SetFontObject("GameFontNormal")
    editBox:SetTextInsets(8, 8, 8, 8)
    editBox:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"})
    editBox:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    editBox:SetTextColor(unpack(COLORS.row_text))
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    contentScroll:SetScrollChild(editBox)
    
    NSForumClient.activeEditBox = editBox
    editBox:SetScript("OnEditFocusLost", function() if NSForumClient.activeEditBox == editBox then NSForumClient.activeEditBox = nil end end)
    
    local fmtBar = NSForumClient.CreateFormattingBar(parent, editBox)
    if fmtBar then
        fmtBar:SetWidth(parent:GetWidth() - 30)
        fmtBar:SetPoint("TOPLEFT", contentLabel, "BOTTOMLEFT", 0, -5)
        fmtBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, 0)
        contentScroll:SetPoint("TOPLEFT", fmtBar, "BOTTOMLEFT", 0, -5)
    else
        contentScroll:SetPoint("TOPLEFT", contentLabel, "BOTTOMLEFT", 0, -5)
    end
    contentScroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 45)
    editBox:SetWidth(contentScroll:GetWidth() - 10)
    editBox:SetHeight(400)
    contentScroll:EnableMouseWheel(true)
    local sb = CreateFrame("Slider", "NSForumCreateSlider_" .. fid, contentScroll)
    sb:SetOrientation("VERTICAL")
    sb:SetPoint("TOPRIGHT", contentScroll, "TOPRIGHT", -2, -2)
    sb:SetPoint("BOTTOMRIGHT", contentScroll, "BOTTOMRIGHT", -2, 2)
    sb:SetWidth(16)
    sb:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    sb:SetBackdrop({bgFile = "Interface\\Buttons\\UI-ScrollBar-Background"})
    sb:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    sb:SetValueStep(20)
    local function UpdateScrollRange() sb:SetMinMaxValues(0, math.max(0, editBox:GetHeight() - contentScroll:GetHeight())) end
    sb:SetScript("OnValueChanged", function(self, val) contentScroll:SetVerticalScroll(val) end)
    contentScroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local newVal = current - (delta * 20)
        if newVal < 0 then newVal = 0 end
        local maxScroll = select(2, sb:GetMinMaxValues())
        if maxScroll and newVal > maxScroll then newVal = maxScroll end
        self:SetVerticalScroll(newVal); sb:SetValue(newVal)
    end)
    contentScroll:SetScript("OnSizeChanged", UpdateScrollRange)
    editBox:SetScript("OnTextChanged", UpdateScrollRange)
    UpdateScrollRange()
    local createBtn = CreateFrame("Button", "NSForumCreateBtn_" .. fid, parent, "UIPanelButtonTemplate")
    createBtn:SetSize(110, 24)
    createBtn:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 10)
    createBtn:SetText("Создать тему")
    createBtn:SetScript("OnClick", function()
        if not IsInGuild() then UIErrorsFrame:AddMessage("Необходимо состоять в гильдии", 1, 0, 0, 1, 5); return end
        local t = titleBox:GetText()
        if not t or t == "" then UIErrorsFrame:AddMessage("Введите название темы", 1, 0.5, 0, 1, 5); return end
        local c = editBox:GetText()
        local escapedTitle = t:gsub("|", "&#124;"):gsub(",", "&#44;")
        local escapedContent = (c or ""):gsub("|", "&#124;"):gsub(",", "&#44;")
        NSForumClient.SendChunkedMessage("NEW_THREAD:", escapedTitle .. "|" .. escapedContent)
        titleBox:SetText(""); editBox:SetText("")
        NSForumClient.SetCurrentView("list")
        NSForumClient.RequestThreads()
    end)
    local cancelBtn = CreateFrame("Button", "NSForumCancelBtn_" .. fid, parent, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80, 24)
    cancelBtn:SetPoint("RIGHT", createBtn, "LEFT", -5, 0)
    cancelBtn:SetText("Отмена")
    cancelBtn:SetScript("OnClick", function() NSForumClient.SetCurrentView("list"); NSForumClient.RenderView() end)
end

-- ============================================
-- 7. РЕДАКТИРОВАНИЕ ТЕМЫ
-- ============================================
function NSForumClient.DrawEditThreadView(parent)
    local tId = NSForumClient.GetSelectedThreadId()
    local thread = nil
    for _, t in ipairs(NSForumClient.tempThreads) do if t.id == tId then thread = t; break end end
    if not thread then NSForumClient.SetCurrentView("list"); NSForumClient.RenderView(); return end
    local threadContent = ""
    for _, p in ipairs(NSForumClient.tempPosts) do if p.threadId == tId then threadContent = p.content or ""; break end end
    threadContent = threadContent:gsub("&#124;", "|"):gsub("&#44;", ",")
    local fid = NSForumFrameID
    local headerBg = parent:CreateTexture(nil, "ARTWORK")
    headerBg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    headerBg:SetHeight(28)
    headerBg:SetPoint("TOPLEFT", 2, -2)
    headerBg:SetPoint("TOPRIGHT", -2, -2)
    headerBg:SetGradientAlpha("HORIZONTAL", 0.2, 0.2, 0.2, 0.8, 0.3, 0.3, 0.3, 0.8)
    local headerText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLeftYellow")
    headerText:SetPoint("LEFT", headerBg, "LEFT", 10, 0)
    headerText:SetPoint("TOP", headerBg, "TOP", 0, -5)
    headerText:SetText("Редактирование темы")
    headerText:SetTextColor(unpack(COLORS.row_text))
    local titleLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -40)
    titleLabel:SetText("Название темы:")
    titleLabel:SetTextColor(unpack(COLORS.label_text))
    local titleBox = CreateFrame("EditBox", "NSForumEditTitleBox_" .. fid, parent, "InputBoxTemplate")
    titleBox:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 0, -5)
    titleBox:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, -40)
    titleBox:SetHeight(28)
    titleBox:SetAutoFocus(false)
    titleBox:SetMaxLetters(100)
    titleBox:SetFontObject("GameFontNormal")
    titleBox:SetTextInsets(8, 8, 4, 4)
    titleBox:SetTextColor(unpack(COLORS.row_text))
    titleBox:SetText((thread.title or ""):gsub("&#44;", ","))
    titleBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local contentLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentLabel:SetPoint("TOPLEFT", titleBox, "BOTTOMLEFT", 0, -20)
    contentLabel:SetText("Содержание:")
    contentLabel:SetTextColor(unpack(COLORS.label_text))
    local contentScroll = CreateFrame("ScrollFrame", "NSForumEditScroll_" .. fid, parent)
    local editBox = CreateFrame("EditBox", "NSForumEditContentBox_" .. fid, contentScroll)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(0)
    editBox:SetFontObject("GameFontNormal")
    editBox:SetTextInsets(8, 8, 8, 8)
    editBox:SetTextColor(unpack(COLORS.row_text))
    editBox:SetText(threadContent)
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    contentScroll:SetScrollChild(editBox)
    
    NSForumClient.activeEditBox = editBox
    editBox:SetScript("OnEditFocusLost", function() if NSForumClient.activeEditBox == editBox then NSForumClient.activeEditBox = nil end end)
    
    local fmtBar = NSForumClient.CreateFormattingBar(parent, editBox)
    if fmtBar then
        fmtBar:SetWidth(parent:GetWidth() - 30)
        fmtBar:SetPoint("TOPLEFT", contentLabel, "BOTTOMLEFT", 0, -5)
        fmtBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -15, 0)
        contentScroll:SetPoint("TOPLEFT", fmtBar, "BOTTOMLEFT", 0, -5)
    else
        contentScroll:SetPoint("TOPLEFT", contentLabel, "BOTTOMLEFT", 0, -5)
    end
    contentScroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 45)
    editBox:SetWidth(contentScroll:GetWidth() - 10)
    editBox:SetHeight(400)
    contentScroll:EnableMouseWheel(true)
    local sb = CreateFrame("Slider", "NSForumEditSlider_" .. fid, contentScroll)
    sb:SetOrientation("VERTICAL")
    sb:SetPoint("TOPRIGHT", contentScroll, "TOPRIGHT", -2, -2)
    sb:SetPoint("BOTTOMRIGHT", contentScroll, "BOTTOMRIGHT", -2, 2)
    sb:SetWidth(16)
    sb:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    sb:SetValueStep(20)
    local function UpdateScrollRange() sb:SetMinMaxValues(0, math.max(0, editBox:GetHeight() - contentScroll:GetHeight())) end
    sb:SetScript("OnValueChanged", function(self, val) contentScroll:SetVerticalScroll(val) end)
    contentScroll:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local newVal = current - (delta * 20)
        if newVal < 0 then newVal = 0 end
        local maxScroll = select(2, sb:GetMinMaxValues())
        if maxScroll and newVal > maxScroll then newVal = maxScroll end
        self:SetVerticalScroll(newVal); sb:SetValue(newVal)
    end)
    contentScroll:SetScript("OnSizeChanged", UpdateScrollRange)
    editBox:SetScript("OnTextChanged", UpdateScrollRange)
    UpdateScrollRange()
    local saveBtn = CreateFrame("Button", "NSForumSaveBtn_" .. fid, parent, "UIPanelButtonTemplate")
    saveBtn:SetSize(110, 24)
    saveBtn:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -15, 10)
    saveBtn:SetText("Сохранить")
    saveBtn:SetScript("OnClick", function()
        local newTitle = titleBox:GetText()
        if not newTitle or newTitle == "" then UIErrorsFrame:AddMessage("Введите название темы", 1, 0.5, 0, 1, 5); return end
        local newContent = editBox:GetText()
        local escapedTitle = newTitle:gsub("|", "&#124;"):gsub(",", "&#44;")
        local escapedContent = (newContent or ""):gsub("|", "&#124;"):gsub(",", "&#44;")
        NSForumClient.SendChunkedMessage("EDIT_THREAD:", tId .. "|" .. escapedTitle .. "|" .. escapedContent)
        NSForumClient.SetCurrentView("thread")
        NSForumClient.SetLoadingThread(true)
        NSForumClient.RequestThreadFull(tId)
    end)
    local cancelBtn = CreateFrame("Button", "NSForumEditCancelBtn_" .. fid, parent, "UIPanelButtonTemplate")
    cancelBtn:SetSize(80, 24)
    cancelBtn:SetPoint("RIGHT", saveBtn, "LEFT", -5, 0)
    cancelBtn:SetText("Отмена")
    cancelBtn:SetScript("OnClick", function() NSForumClient.SetCurrentView("thread"); NSForumClient.RenderView() end)
end

-- ============================================
-- 9. ИНКРЕМЕНТАЛЬНЫЕ ОБНОВЛЕНИЯ
-- ============================================
function NSForumClient.AddNewPostToView(postId)
    if not NSForumClient.viewFrame then return end
    local scrollFrame = nil
    local innerFrame = nil
    for _, child in ipairs({NSForumClient.viewFrame:GetChildren()}) do if child.GetScrollChild then scrollFrame = child; innerFrame = child:GetScrollChild(); break end end
    if not scrollFrame or not innerFrame then NSForumClient.RenderView(); return end
    local post = nil
    for _, p in ipairs(NSForumClient.tempPosts) do if p.id == postId then post = p; break end end
    if not post then return end
    local postCount = 0
    local maxBottomY = 5
    for _, child in ipairs({innerFrame:GetChildren()}) do
        local name = child:GetName()
        if name and name:find("NSForumPost_") then
            postCount = postCount + 1
            local pt, rel, relPt, x, y = child:GetPoint()
            if y then local absY = math.abs(y); local h = child.targetHeight or child:GetHeight() or 70; local bottomY = absY + h + 5; if bottomY > maxBottomY then maxBottomY = bottomY end end
        end
    end
    local newIndex = postCount + 1
    local fid = NSForumFrameID
    local rowY = -maxBottomY
    local postFrame = CreateFrame("Frame", "NSForumPost_" .. fid .. "_" .. postId, innerFrame)
    postFrame:SetWidth(innerFrame:GetWidth() or 600)
    postFrame:SetPoint("TOPLEFT", innerFrame, "TOPLEFT", 2, rowY)
    local bg = postFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Buttons\\White8x8")
    bg:SetVertexColor(unpack(COLORS.post_bg))
    bg:SetAllPoints(postFrame)
    local authorText = postFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    authorText:SetPoint("TOPLEFT", 10, -5)
    authorText:SetPoint("RIGHT", -10, 0)
    authorText:SetJustifyH("LEFT")
    authorText:SetText("|cffFFD700" .. post.author .. "|r  |cff808080" .. (post.date or "") .. "|r")
    local div = postFrame:CreateTexture(nil, "ARTWORK")
    div:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
    div:SetHeight(1)
    div:SetPoint("TOPLEFT", 10, -23)
    div:SetPoint("TOPRIGHT", -10, 0)
    local contentText = postFrame:CreateFontString(nil, "OVERLAY")
    contentText:SetPoint("TOPLEFT", 15, -28)
    contentText:SetPoint("RIGHT", postFrame, "RIGHT", -15, 0)
    contentText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    contentText:SetJustifyH("LEFT")
    local processedContent = post.content or ""
    
    -- Декодирование
    processedContent = string.gsub(processedContent, "&#124;", "|")
    processedContent = string.gsub(processedContent, "&#44;", ",")
    
    processedContent = string.gsub(processedContent, "!ц(%x%x%x%x%x%x%x%x)(.-)!цц", function(hex, text) return "|cff" .. hex .. text .. "|r" end)
    for tag, hex in pairs(COLOR_TAGS) do
        processedContent = string.gsub(processedContent, "!ц" .. tag .. "(.-)!цц", function(text) return hex .. text .. "|r" end)
    end
    processedContent = string.gsub(processedContent, "!р%d+", "")
    processedContent = string.gsub(processedContent, "!рр", "")
    processedContent = string.gsub(processedContent, "!цц", "")
    
    local blocks = NSForumClient.ParseContentBlocks(processedContent)
    local hasSpecialBlocks = false
    for _, block in ipairs(blocks) do if block.type == "copyable" or block.type == "link" then hasSpecialBlocks = true; break end end
    
    local contentHeight
    if hasSpecialBlocks then
        local currentY = -28
        contentText:Hide()
        for _, block in ipairs(blocks) do
            if block.type == "text" and block.content ~= "" then
                local textFrame = postFrame:CreateFontString(nil, "OVERLAY")
                textFrame:SetPoint("TOPLEFT", 15, currentY)
                textFrame:SetPoint("RIGHT", postFrame, "RIGHT", -15, 0)
                textFrame:SetFont("Fonts\\FRIZQT__.TTF", 14)
                textFrame:SetJustifyH("LEFT")
                textFrame:SetText(block.content)
                textFrame:SetTextColor(unpack(COLORS.row_text))
                currentY = currentY - (textFrame:GetStringHeight() or 14) - 5
            elseif block.type == "copyable" then
                local copyBlock = NSForumClient.CreateCopyableBlock(postFrame, block.content, currentY)
                currentY = currentY - (copyBlock:GetHeight() or 24) - 5
            elseif block.type == "link" then
                local linkBlock = NSForumClient.CreateLinkBlock(postFrame, block.linkPayload, block.linkText, currentY)
                currentY = currentY - (linkBlock:GetHeight() or 24) - 5
            end
        end
        contentHeight = math.abs(currentY) - 28
    else
        contentText:SetText(processedContent)
        contentText:SetTextColor(unpack(COLORS.row_text))
        contentHeight = contentText:GetStringHeight() or 14
    end
    local frameHeight = contentHeight + 30
    postFrame.targetHeight = frameHeight
    postFrame:SetHeight(frameHeight)
    local reactionBtn = CreateFrame("Button", "NSForumReactionBtn_" .. fid .. "_" .. postId, postFrame)
    reactionBtn:SetSize(24, 24)
    reactionBtn:SetPoint("BOTTOMRIGHT", -8, 4)
    reactionBtn:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
    reactionBtn:SetScript("OnClick", function() NSForumClient.ShowReactionPanel(postId, reactionBtn) end)
    postFrame:Show()
    local newTotalHeight = maxBottomY + frameHeight + 5
    innerFrame:SetHeight(math.max(newTotalHeight, scrollFrame:GetHeight() or 100))
    local sb = scrollFrame.scrollbar
    if sb then
        local scrollRange = math.max(0, newTotalHeight - (scrollFrame:GetHeight() or 100))
        sb:SetMinMaxValues(0, scrollRange)
        sb:SetValue(scrollRange)
        scrollFrame:SetVerticalScroll(scrollRange)
    end
    NSForumClient.AnimateNewPostAppear(postFrame, newIndex)
end

-- ============================================
-- РЕАКЦИИ
-- ============================================

function NSForumClient.ShowReactionPanel(postId, anchorFrame)
    if NSForumClient.reactionPanel then
        NSForumClient.reactionPanel:Hide()
        NSForumClient.reactionPanel:SetParent(nil)
        NSForumClient.reactionPanel = nil
    end

    local panel = CreateFrame("Frame", "NSForumReactionPanel", UIParent)
    panel:SetSize(220, 48)
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    panel:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    panel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    panel:SetFrameStrata("DIALOG")
    panel:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 10, 5)
    panel:EnableMouse(true)
    panel:Raise()

    local capturedPostId = postId
    local iconSize = 26
    local padding = 5
    local startX = 7
    local startY = -6

    for i, reaction in ipairs(REACTIONS) do
        local col = (i - 1) % 6
        local row = math.floor((i - 1) / 6)
        local x = startX + col * (iconSize + padding)
        local y = startY - row * (iconSize + padding)

        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(iconSize, iconSize)
        btn:SetPoint("TOPLEFT", x, y)
        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        btn:EnableMouse(true)
        btn:SetHitRectInsets(0, 0, 0, 0)
        btn:SetNormalTexture("Interface\\Buttons\\White8x8")
        btn:GetNormalTexture():SetVertexColor(0, 0, 0, 0.01)

        local tex = btn:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        tex:SetTexture(reaction.icon)

        btn:SetScript("OnClick", function()
            if panel:IsShown() then
                panel:Hide()
                panel:SetParent(nil)
                NSForumClient.reactionPanel = nil
            end
            if type(NSForumClient.AddReaction) == "function" then
                NSForumClient.AddReaction(capturedPostId, reaction.key)
            end
        end)

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(reaction.name, 1, 1, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    NSForumClient.reactionPanel = panel
    panel:Show()
end

function NSForumClient.AddReaction(postId, reactionKey)
    if not IsInGuild() then return end
    local author = UnitName("player")
    if not author then return end

    postId = tonumber(postId)
    if not postId then return end

    local threadId = nil
    for _, p in ipairs(NSForumClient.tempPosts) do
        if tonumber(p.id) == postId then
            threadId = p.threadId
            break
        end
    end
    if not threadId then return end

    if not NSForumClient.tempReactions then NSForumClient.tempReactions = {} end
    if not NSForumClient.tempReactions[postId] then NSForumClient.tempReactions[postId] = {} end
    if not NSForumClient.tempReactions[postId][reactionKey] then NSForumClient.tempReactions[postId][reactionKey] = {} end

    local reactionTable = NSForumClient.tempReactions[postId][reactionKey]
    local alreadyReacted = false
    for i, name in ipairs(reactionTable) do
        if name == author then
            table.remove(reactionTable, i)
            alreadyReacted = true
            break
        end
    end
    if not alreadyReacted then 
        table.insert(reactionTable, author) 
    end

    -- ОБНОВЛЯЕМ ОТОБРАЖЕНИЕ РЕАКЦИЙ
    NSForumClient.UpdateReactionsInView(postId)

    -- ОТПРАВЛЯЕМ НА СЕРВЕР
    local message = "REACTION:" .. threadId .. "|" .. postId .. "|" .. reactionKey
    SendAddonMessage("NSFORUM", message, "GUILD")
end

-- ============================================
-- СЕТЕВЫЕ ЗАПРОСЫ
-- ============================================

function NSForumClient.RequestThreads()
    if not IsInGuild() then return end
    DebugPrint("Requesting threads...")
    NSForumClient.tempThreads = {}
    local myName = UnitName("player")
    SendAddonMessage("NSFORUM", "REQ_THREADS:" .. (myName or ""), "GUILD")
end

function NSForumClient.RequestThreadFull(threadId)
    DebugPrint("Requesting full thread:", threadId)
    local myName = UnitName("player")
    if IsInGuild() and myName then
        SendAddonMessage("NSFORUM", "REQ_THREAD_FULL:" .. threadId .. "|" .. myName, "GUILD")
    end
end

-- ============================================
-- ОБРАБОТЧИК СООБЩЕНИЙ (с отладкой реакций)
-- ============================================

local cFrame = CreateFrame("Frame")
cFrame:RegisterEvent("CHAT_MSG_ADDON")
cFrame:SetScript("OnEvent", function(self, event, prefix, text, channel, sender)
    if event ~= "CHAT_MSG_ADDON" or prefix ~= "NSFORUM" or channel ~= "GUILD" then return end
    local action, data = strsplit(":", text, 2)
    local myName = UnitName("player")

    -- Игнорируем запросы, которые обрабатываются сервером
    if action == "REQ_THREADS" or action == "REQ_POSTS" or action == "REQ_THREAD_FULL" then return end

    if action == "SYNC_MODERATORS" then
        NSForumClient.tempModerators = {}
        if data and data ~= "" then
            for modName in string.gmatch(data, "[^,]+") do
                NSForumClient.tempModerators[modName] = true
            end
        end
        DebugPrint("Moderators synced:", #NSForumClient.tempModerators)
    elseif action == "SYNC_THREADS" then
        DebugPrint("SYNC_THREADS received, raw data length:", data and #data or 0)
        if not data then return end
        local targetName, threadsData = strsplit("|", data, 2)
        DebugPrint("SYNC_THREADS: targetName=", tostring(targetName), "myName=", tostring(myName), "threadsDataLen=", threadsData and #threadsData or 0)
        
        if targetName and targetName ~= "" and targetName ~= myName then
            DebugPrint("SYNC_THREADS: target mismatch, ignoring")
            return
        end

        local dataToParse = threadsData or data
        DebugPrint("SYNC_THREADS: parsing data, length:", #dataToParse)
        
        if dataToParse and dataToParse ~= "" then
            local entryCount = 0
            local existingThreads = {}
            for _, t in ipairs(NSForumClient.tempThreads) do
                existingThreads[t.id] = t
            end
            
            for entry in string.gmatch(dataToParse, "([^;]+)") do
                if entry:sub(-1) == ";" then entry = entry:sub(1, -2) end
                if entry == "" then break end
                
                entryCount = entryCount + 1
                local id, title, author, date, lastPostDate, postCount, pinned, pinnedBy = strsplit("|", entry, 8)
                
                if id and tonumber(id) then
                    local threadId = tonumber(id)
                    existingThreads[threadId] = {
                        id = threadId, title = title or "", author = author or "",
                        date = date or "", lastPostDate = lastPostDate or date or "",
                        postCount = tonumber(postCount) or 0, pinned = (pinned == "true"),
                        pinnedBy = (pinnedBy ~= "" and pinnedBy) or nil
                    }
                end
            end
            
            NSForumClient.tempThreads = {}
            for _, t in pairs(existingThreads) do table.insert(NSForumClient.tempThreads, t) end
            DebugPrint("SYNC_THREADS: parsed", entryCount, "entries, total threads:", #NSForumClient.tempThreads)
        else
            DebugPrint("SYNC_THREADS: no data to parse")
        end
        
        if NSForumClient.IsWindowOpen() and NSForumClient.GetCurrentView() == "list" then 
            NSForumClient.RenderView()
        end
    elseif action == "NEW_THREAD_BROADCAST" then
        DebugPrint("NEW_THREAD_BROADCAST:", data)
        if not data then return end
        if NSForumClient.IsWindowOpen() and NSForumClient.GetCurrentView() == "list" then NSForumClient.RequestThreads() end
    elseif action == "PIN_THREAD_BROADCAST" then
        if not data then return end
        local threadIdStr, pinnedBy = strsplit("|", data, 2)
        local threadIdNum = tonumber(threadIdStr)
        if not threadIdNum then return end
        for i, t in ipairs(NSForumClient.tempThreads) do
            if t.id == threadIdNum then
                NSForumClient.tempThreads[i].pinned = true
                NSForumClient.tempThreads[i].pinnedBy = pinnedBy
                break
            end
        end
        if NSForumClient.IsWindowOpen() and NSForumClient.GetCurrentView() == "list" then NSForumClient.RenderView() end
    elseif action == "UNPIN_THREAD_BROADCAST" then
        if not data then return end
        local threadIdNum = tonumber(data)
        if not threadIdNum then return end
        for i, t in ipairs(NSForumClient.tempThreads) do
            if t.id == threadIdNum then
                NSForumClient.tempThreads[i].pinned = false
                NSForumClient.tempThreads[i].pinnedBy = nil
                break
            end
        end
        if NSForumClient.IsWindowOpen() and NSForumClient.GetCurrentView() == "list" then NSForumClient.RenderView() end
    elseif action == "DELETE_THREAD_BROADCAST" then
        if not data then return end
        local threadIdNum = tonumber(data)
        if not threadIdNum then return end
        if NSForumClient.GetSelectedThreadId() == threadIdNum then
            NSForumClient.SetSelectedThreadId(nil)
            NSForumClient.tempPosts = {}
            NSForumClient.tempReactions = {}
            NSForumClient.SetLoadingThread(false)
            if NSForumClient.IsWindowOpen() then
                NSForumClient.SetCurrentView("list")
                NSForumClient.RequestThreads()
            end
        elseif NSForumClient.IsWindowOpen() and NSForumClient.GetCurrentView() == "list" then
            NSForumClient.RequestThreads()
        end
    elseif action == "SYNC_THREAD_FULL" then
        DebugPrint("SYNC_THREAD_FULL received")
        if not data then return end
        local targetName, rest = strsplit("|", data, 2)
        DebugPrint("SYNC_THREAD_FULL: targetName=", tostring(targetName), "myName=", tostring(myName))
        if targetName ~= myName then return end
        local threadIdStr, chunkInfo = strsplit("|", rest, 2)
        local threadIdNum = tonumber(threadIdStr)
        if not threadIdNum then return end
        
        DebugPrint("SYNC_THREAD_FULL: threadId=", threadIdNum, "chunkInfo start=", chunkInfo and string.sub(chunkInfo, 1, 30) or "nil")
        
        if chunkInfo and string.find(chunkInfo, "^START:") then
            local chunkParams = chunkInfo:sub(7)
            local totalChunksStr, chunkContent = strsplit("|", chunkParams, 2)
            local totalChunks = tonumber(totalChunksStr)
            DebugPrint("Starting chunk assembly: totalChunks=", totalChunks)
            local fullData = NSForumClient.AssembleChunks("SYNC_THREAD_FULL", sender, chunkContent, totalChunks, nil)
            if fullData then 
                DebugPrint("Chunk assembly complete! (single chunk)")
                NSForumClient.ProcessFullThreadData(threadIdNum, fullData) 
            end
        elseif chunkInfo and string.find(chunkInfo, "^CHUNK:") then
            local chunkParams = chunkInfo:sub(7)
            local chunkNumStr, chunkContent = strsplit("|", chunkParams, 2)
            local chunkNum = tonumber(chunkNumStr)
            DebugPrint("Received chunk:", chunkNum)
            local fullData = NSForumClient.AssembleChunks("SYNC_THREAD_FULL", sender, chunkContent, nil, chunkNum)
            if fullData then 
                DebugPrint("All chunks received! Total data length:", #fullData)
                NSForumClient.ProcessFullThreadData(threadIdNum, fullData) 
            end
        else
            DebugPrint("Single message (no chunks)")
            NSForumClient.ProcessFullThreadData(threadIdNum, chunkInfo or rest)
        end
    elseif action == "NEW_POST_BROADCAST" then
        DebugPrint("NEW_POST_BROADCAST:", data)
        if not data then return end
        local tId, pId, author, postDate, content = strsplit("|", data, 5)
        local threadIdNum = tonumber(tId)
        local postIdNum = tonumber(pId)
        if not threadIdNum or not postIdNum then return end
        if NSForumClient.IsWindowOpen() and NSForumClient.GetCurrentView() == "thread" and NSForumClient.GetSelectedThreadId() == threadIdNum then
            local found = false
            for i, p in ipairs(NSForumClient.tempPosts) do
                if p.id == postIdNum and p.threadId == threadIdNum then
                    NSForumClient.tempPosts[i] = { id = postIdNum, threadId = threadIdNum, author = author or "", date = postDate or "", content = content or "" }
                    found = true; break
                end
            end
            if not found then table.insert(NSForumClient.tempPosts, { id = postIdNum, threadId = threadIdNum, author = author or "", date = postDate or "", content = content or "" }) end
            NSForumClient.AddNewPostToView(postIdNum)
        end
        for i, t in ipairs(NSForumClient.tempThreads) do
            if t.id == threadIdNum then
                NSForumClient.tempThreads[i].lastPostDate = postDate
                NSForumClient.tempThreads[i].postCount = (NSForumClient.tempThreads[i].postCount or 0) + 1
                break
            end
        end
    elseif action == "NEW_REACTION_BROADCAST" then
        if not data then 
            return 
        end
        
        local tId, pId, reactionKey, reactionsData = strsplit("|", data, 4)
        local threadIdNum = tonumber(tId)
        local postIdNum = tonumber(pId)
        
        
        if not threadIdNum or not postIdNum or not reactionKey then 
            return 
        end
        
        if not NSForumClient.tempReactions then NSForumClient.tempReactions = {} end
        if not NSForumClient.tempReactions[postIdNum] then NSForumClient.tempReactions[postIdNum] = {} end
        
        NSForumClient.tempReactions[postIdNum][reactionKey] = {}
        if reactionsData and reactionsData ~= "" then
            local nameCount = 0
            for name in string.gmatch(reactionsData, "[^,]+") do
                if name ~= "" then 
                    table.insert(NSForumClient.tempReactions[postIdNum][reactionKey], name)
                    nameCount = nameCount + 1
                end
            end
        else
        end
        
        
        if NSForumClient.IsWindowOpen() and NSForumClient.GetCurrentView() == "thread" and NSForumClient.GetSelectedThreadId() == threadIdNum then
            NSForumClient.UpdateReactionsInView(postIdNum)
        else
        end
    end
end)

-- ============================================
-- 10. ОБРАБОТКА ПОЛНОЙ ТЕМЫ (БЕЗ ОТЛАДКИ)
-- ============================================
function NSForumClient.ProcessFullThreadData(threadId, fullData)
    local postsSection, reactionsSection = nil, nil
    local postsStart = string.find(fullData, "POSTS:")
    local reactionsStart = string.find(fullData, "|REACTIONS:")
    if postsStart then
        if reactionsStart then postsSection = string.sub(fullData, postsStart + 6, reactionsStart - 1); reactionsSection = string.sub(fullData, reactionsStart + 11)
        else postsSection = string.sub(fullData, postsStart + 6) end
    end
    local i = 1
    while i <= #NSForumClient.tempPosts do if NSForumClient.tempPosts[i].threadId == threadId then table.remove(NSForumClient.tempPosts, i) else i = i + 1 end end
    if postsSection and postsSection ~= "" then
        for postEntry in string.gmatch(postsSection, "([^,]+)") do
            local id, author, date, content = strsplit("|", postEntry, 4)
            if id and tonumber(id) then
                table.insert(NSForumClient.tempPosts, { id = tonumber(id), threadId = threadId, author = author or "", date = date or "", content = content or "" })
            end
        end
    end
    if reactionsSection and reactionsSection ~= "" then
        if not NSForumClient.tempReactions then NSForumClient.tempReactions = {} end
        reactionsSection = reactionsSection:gsub("|+$", "")
        for postReactions in string.gmatch(reactionsSection, "([^|]+)") do
            local postIdStr, rest = strsplit(":", postReactions, 2)
            local postId = tonumber(postIdStr)
            if postId and rest then
                NSForumClient.tempReactions[postId] = NSForumClient.tempReactions[postId] or {}
                for reactionBlock in string.gmatch(rest, "([^;]+)") do
                    local key, namesStr = strsplit(":", reactionBlock, 2)
                    if key and namesStr and namesStr ~= "" then
                        NSForumClient.tempReactions[postId][key] = {}
                        for name in string.gmatch(namesStr, "[^,]+") do if name ~= "" then table.insert(NSForumClient.tempReactions[postId][key], name) end end
                    end
                end
            end
        end
    end
    local threadExists = false
    for _, t in ipairs(NSForumClient.tempThreads) do if t.id == threadId then threadExists = true; break end end
    if not threadExists then
        table.insert(NSForumClient.tempThreads, { id = threadId, title = "Загрузка метаданных...", author = "...", date = "...", lastPostDate = "...", postCount = 0, pinned = false })
    end
    NSForumClient.SetLoadingThread(false)
    if NSForumClient.IsWindowOpen() and NSForumClient.GetCurrentView() == "thread" and NSForumClient.GetSelectedThreadId() == threadId then NSForumClient.RenderView() end
end

-- ============================================
-- ИНКРЕМЕНТАЛЬНЫЕ ОБНОВЛЕНИЯ (С ДЕКОДИРОВАНИЕМ ЗАПЯТЫХ)
-- ============================================
function NSForumClient.AddNewPostToView(postId)
    if not NSForumClient.viewFrame then return end
    
    local scrollFrame = nil
    local innerFrame = nil
    for _, child in ipairs({NSForumClient.viewFrame:GetChildren()}) do
        if child.GetScrollChild then
            scrollFrame = child
            innerFrame = child:GetScrollChild()
            break
        end
    end
    if not scrollFrame or not innerFrame then NSForumClient.RenderView(); return end
    
    local post = nil
    for _, p in ipairs(NSForumClient.tempPosts) do
        if p.id == postId then post = p; break end
    end
    if not post then return end
    
    local postCount = 0
    local maxBottomY = 5
    for _, child in ipairs({innerFrame:GetChildren()}) do
        local name = child:GetName()
        if name and name:find("NSForumPost_") then
            postCount = postCount + 1
            local pt, rel, relPt, x, y = child:GetPoint()
            if y then
                local absY = math.abs(y)
                local h = child.targetHeight or child:GetHeight() or 70
                local bottomY = absY + h + 5
                if bottomY > maxBottomY then maxBottomY = bottomY end
            end
        end
    end
    
    local newIndex = postCount + 1
    local fid = NSForumFrameID
    local rowY = -maxBottomY
    
    local postFrame = CreateFrame("Frame", "NSForumPost_" .. fid .. "_" .. postId, innerFrame)
    postFrame:SetWidth(innerFrame:GetWidth() or 600)
    postFrame:SetPoint("TOPLEFT", innerFrame, "TOPLEFT", 2, rowY)
    
    local bg = postFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Buttons\\White8x8")
    bg:SetVertexColor(unpack(COLORS.post_bg))
    bg:SetAllPoints(postFrame)
    
    local authorText = postFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    authorText:SetPoint("TOPLEFT", 10, -5)
    authorText:SetPoint("RIGHT", -10, 0)
    authorText:SetJustifyH("LEFT")
    authorText:SetText("|cffFFD700" .. post.author .. "|r  |cff808080" .. (post.date or "") .. "|r")
    
    local div = postFrame:CreateTexture(nil, "ARTWORK")
    div:SetTexture("Interface\\Common\\UI-TooltipDivider-Transparent")
    div:SetHeight(1)
    div:SetPoint("TOPLEFT", 10, -23)
    div:SetPoint("TOPRIGHT", -10, 0)
    
    local contentText = postFrame:CreateFontString(nil, "OVERLAY")
    contentText:SetPoint("TOPLEFT", 15, -28)
    contentText:SetPoint("RIGHT", postFrame, "RIGHT", -15, 0)
    contentText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    contentText:SetJustifyH("LEFT")
    
    local processedContent = post.content or ""
    
    -- ДЕКОДИРУЕМ &#124; -> | и &#44; -> ,
    processedContent = string.gsub(processedContent, "&#124;", "|")
    processedContent = string.gsub(processedContent, "&#44;", ",")
    
    processedContent = string.gsub(processedContent, "!ц(%x%x%x%x%x%x%x%x)(.-)!цц", function(hex, text) return "|cff" .. hex .. text .. "|r" end)
    for tag, hex in pairs(COLOR_TAGS) do
        processedContent = string.gsub(processedContent, "!ц" .. tag .. "(.-)!цц", function(text) return hex .. text .. "|r" end)
    end
    processedContent = string.gsub(processedContent, "!р%d+", "")
    processedContent = string.gsub(processedContent, "!рр", "")
    processedContent = string.gsub(processedContent, "!цц", "")
    
    local blocks = NSForumClient.ParseContentBlocks(processedContent)
    local hasSpecialBlocks = false
    for _, block in ipairs(blocks) do
        if block.type == "copyable" or block.type == "link" then
            hasSpecialBlocks = true
            break
        end
    end
    
    local contentHeight
    
    if hasSpecialBlocks then
        local currentY = -28
        contentText:Hide()
        
        for _, block in ipairs(blocks) do
            if block.type == "text" and block.content ~= "" then
                local textFrame = postFrame:CreateFontString(nil, "OVERLAY")
                textFrame:SetPoint("TOPLEFT", 15, currentY)
                textFrame:SetPoint("RIGHT", postFrame, "RIGHT", -15, 0)
                textFrame:SetFont("Fonts\\FRIZQT__.TTF", 14)
                textFrame:SetJustifyH("LEFT")
                textFrame:SetText(block.content)
                textFrame:SetTextColor(unpack(COLORS.row_text))
                currentY = currentY - (textFrame:GetStringHeight() or 14) - 5
            elseif block.type == "copyable" then
                local copyBlock = NSForumClient.CreateCopyableBlock(postFrame, block.content, currentY)
                currentY = currentY - (copyBlock:GetHeight() or 24) - 5
            elseif block.type == "link" then
                local linkBlock = NSForumClient.CreateLinkBlock(postFrame, block.linkData, block.linkText, currentY)
                currentY = currentY - (linkBlock:GetHeight() or 24) - 5
            end
        end
        
        contentHeight = math.abs(currentY) - 28
    else
        contentText:SetText(processedContent)
        contentText:SetTextColor(unpack(COLORS.row_text))
        contentHeight = contentText:GetStringHeight() or 14
    end
    
    local frameHeight = contentHeight + 30
    postFrame.targetHeight = frameHeight
    postFrame:SetHeight(frameHeight)
    
    local reactionBtn = CreateFrame("Button", "NSForumReactionBtn_" .. fid .. "_" .. postId, postFrame)
    reactionBtn:SetSize(24, 24)
    reactionBtn:SetPoint("BOTTOMRIGHT", -8, 4)
    reactionBtn:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
    reactionBtn:SetScript("OnClick", function() NSForumClient.ShowReactionPanel(postId, reactionBtn) end)
    
    postFrame:Show()
    
    local newTotalHeight = maxBottomY + frameHeight + 5
    innerFrame:SetHeight(math.max(newTotalHeight, scrollFrame:GetHeight() or 100))
    
    local sb = scrollFrame.scrollbar
    if sb then
        local scrollRange = math.max(0, newTotalHeight - (scrollFrame:GetHeight() or 100))
        sb:SetMinMaxValues(0, scrollRange)
        sb:SetValue(scrollRange)
        scrollFrame:SetVerticalScroll(scrollRange)
    end
    
    NSForumClient.AnimateNewPostAppear(postFrame, newIndex)
end

function NSForumClient.UpdateReactionsInView(postId)
    if not NSForumClient.viewFrame or not NSForumClient.IsWindowOpen() then return end

    local scrollFrame = nil
    local innerFrame = nil
    for _, child in ipairs({NSForumClient.viewFrame:GetChildren()}) do
        if child.GetScrollChild then
            scrollFrame = child
            innerFrame = child:GetScrollChild()
            break
        end
    end
    if not innerFrame then return end

    local postFrame = nil
    local targetId = tonumber(postId)
    for _, innerChild in ipairs({innerFrame:GetChildren()}) do
        if tonumber(innerChild.postId) == targetId then
            postFrame = innerChild
            break
        end
    end
    if not postFrame then return end

    -- ПРОВЕРЯЕМ, БЫЛА ЛИ УЖЕ ПАНЕЛЬ РЕАКЦИЙ ДО ОБНОВЛЕНИЯ
    local hadReactionsBefore = false
    for _, child in ipairs({postFrame:GetChildren()}) do
        if child.isReactionBar then
            hadReactionsBefore = true
            break
        end
    end

    -- Удаляем старую панель реакций
    for _, child in ipairs({postFrame:GetChildren()}) do
        if child.isReactionBar then
            child:Hide()
            child:SetParent(nil)
            if child:GetName() then _G[child:GetName()] = nil end
        end
    end

    local reactions = NSForumClient.tempReactions
    if not reactions or not reactions[targetId] then return end

    -- ПРОВЕРЯЕМ, ЕСТЬ ЛИ ХОТЬ ОДНА РЕАКЦИЯ ПОСЛЕ ОБНОВЛЕНИЯ
    local hasReactionsNow = false
    for _, reaction in ipairs(REACTIONS) do
        if reactions[targetId][reaction.key] and #reactions[targetId][reaction.key] > 0 then
            hasReactionsNow = true
            break
        end
    end

    local function RecalcScrollHeight()
        if not innerFrame or not scrollFrame then return end
        local maxH = 5
        for _, child in ipairs({innerFrame:GetChildren()}) do
            if child:IsShown() then
                local point, relativeTo, relativePoint, xOfs, yOfs = child:GetPoint()
                if yOfs then
                    local frameHeight = child.targetHeight or child:GetHeight() or 0
                    local absY = math.abs(yOfs)
                    local h = absY + frameHeight + 5
                    if h > maxH then maxH = h end
                end
            end
        end
        innerFrame:SetHeight(math.max(maxH, scrollFrame:GetHeight() or 100))
        local sb = scrollFrame.scrollbar
        if sb then
            local newMax = math.max(0, innerFrame:GetHeight() - scrollFrame:GetHeight())
            sb:SetMinMaxValues(0, newMax)
            if sb:GetValue() > newMax then sb:SetValue(newMax) end
        end
    end

    if hasReactionsNow then
        local reactionBtn = nil
        for _, child in ipairs({postFrame:GetChildren()}) do
            local name = child:GetName()
            if name and name:find("NSForumReactionBtn_") then reactionBtn = child; break end
        end

        local reactionBar = CreateFrame("Frame", nil, postFrame)
        reactionBar.isReactionBar = true
        reactionBar:SetHeight(24)
        reactionBar:SetPoint("BOTTOMLEFT", postFrame, "BOTTOMLEFT", 10, 4)
        if reactionBtn then 
            reactionBar:SetPoint("BOTTOMRIGHT", reactionBtn, "LEFT", -8, 0)
        else 
            reactionBar:SetPoint("BOTTOMRIGHT", postFrame, "BOTTOMRIGHT", -40, 4) 
        end

        local xOffset = 0
        for _, reaction in ipairs(REACTIONS) do
            local count = reactions[targetId][reaction.key] and #reactions[targetId][reaction.key] or 0
            if count > 0 then
                local icon = CreateFrame("Button", nil, reactionBar)
                icon:SetSize(20, 20)
                icon:SetPoint("LEFT", reactionBar, "LEFT", xOffset, 0)
                xOffset = xOffset + 24
                local tex = icon:CreateTexture(nil, "OVERLAY")
                tex:SetAllPoints()
                tex:SetTexture(reaction.icon)
                local countText = icon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                countText:SetPoint("LEFT", icon, "RIGHT", 2, 0)
                countText:SetText(tostring(count))
                countText:SetTextColor(0.7, 0.7, 0.7, 1)
                local capturedReactionKey = reaction.key
                icon:SetScript("OnClick", function() 
                    NSForumClient.AddReaction(targetId, capturedReactionKey) 
                end)
            end
        end
        reactionBar:Show()

        -- ИЗМЕНЯЕМ ВЫСОТУ ТОЛЬКО ЕСЛИ ПАНЕЛЬ РЕАКЦИЙ ПОЯВИЛАСЬ ВПЕРВЫЕ
        if not hadReactionsBefore then
            local contentH = postFrame._contentHeight or 14
            local baseH = postFrame._baseHeight or 30
            postFrame:SetHeight(contentH + baseH + 24)
            postFrame.targetHeight = postFrame:GetHeight()
        end
        
        -- ВСЕГДА ПЕРЕСЧИТЫВАЕМ ПОЛОЖЕНИЕ ВСЕХ ПОСТОВ ПОСЛЕ ЭТОГО
        local allPosts = {}
        for _, child in ipairs({innerFrame:GetChildren()}) do
            if child:IsShown() and child:GetName() and child:GetName():find("NSForumPost_") then
                local _, _, _, _, yOfs = child:GetPoint()
                table.insert(allPosts, {frame = child, y = yOfs or 0})
            end
        end
        
        -- Сортируем по Y (отрицательные значения, сверху вниз)
        table.sort(allPosts, function(a, b) return a.y > b.y end)
        
        -- Если высота изменилась (добавили панель), сдвигаем все посты ниже
        if not hadReactionsBefore then
            local accumulationY = 5
            for i, postData in ipairs(allPosts) do
                postData.frame:ClearAllPoints()
                postData.frame:SetPoint("TOPLEFT", innerFrame, "TOPLEFT", 2, -accumulationY)
                accumulationY = accumulationY + (postData.frame.targetHeight or postData.frame:GetHeight() or 70) + 5
            end
        end
        
        RecalcScrollHeight()
    else
        -- РЕАКЦИЙ НЕТ, НО РАНЬШЕ БЫЛИ - УМЕНЬШАЕМ ВЫСОТУ
        if hadReactionsBefore then
            local contentH = postFrame._contentHeight or 14
            local baseH = postFrame._baseHeight or 30
            postFrame:SetHeight(contentH + baseH)
            postFrame.targetHeight = postFrame:GetHeight()
            
            -- Пересчитываем позиции всех постов
            local allPosts = {}
            for _, child in ipairs({innerFrame:GetChildren()}) do
                if child:IsShown() and child:GetName() and child:GetName():find("NSForumPost_") then
                    local _, _, _, _, yOfs = child:GetPoint()
                    table.insert(allPosts, {frame = child, y = yOfs or 0})
                end
            end
            table.sort(allPosts, function(a, b) return a.y > b.y end)
            
            local accumulationY = 5
            for i, postData in ipairs(allPosts) do
                postData.frame:ClearAllPoints()
                postData.frame:SetPoint("TOPLEFT", innerFrame, "TOPLEFT", 2, -accumulationY)
                accumulationY = accumulationY + (postData.frame.targetHeight or postData.frame:GetHeight() or 70) + 5
            end
        end
        
        RecalcScrollHeight()
    end
end

-- ============================================
-- 1. ПАНЕЛЬ КОПИРОВАНИЯ ТЕКСТА
-- ============================================
function NSForumClient.ShowCopyPanel(text, anchorFrame)
    if NSForumClient.copyPanel then
        NSForumClient.copyPanel:Hide()
        NSForumClient.copyPanel:SetParent(nil)
        NSForumClient.copyPanel = nil
    end

    local panel = CreateFrame("Frame", "NSForumCopyPanel", UIParent)
    panel:SetSize(400, 200)
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    panel:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    panel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    panel:SetFrameStrata("DIALOG")
    panel:SetPoint("CENTER", UIParent, "CENTER")
    panel:EnableMouse(true)
    panel:Raise()

    local titleText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("TOP", 0, -10)
    titleText:SetText("Скопируйте текст")
    titleText:SetTextColor(1, 0.9, 0.4, 1)

    local scrollFrame = CreateFrame("ScrollFrame", "NSForumCopyScroll", panel)
    scrollFrame:SetPoint("TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -10, 40)

    local editBox = CreateFrame("EditBox", "NSForumCopyEditBox", scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(0)
    editBox:SetFontObject("GameFontNormal")
    editBox:SetTextInsets(8, 8, 8, 8)
    editBox:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background"})
    editBox:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
    editBox:SetTextColor(0.9, 0.9, 0.95, 1)
    editBox:SetText(text)
    editBox:SetWidth(380)
    editBox:SetHeight(120)

    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        panel:Hide()
        panel:SetParent(nil)
        NSForumClient.copyPanel = nil
    end)

    scrollFrame:SetScrollChild(editBox)
    scrollFrame:EnableMouseWheel(true)

    local sb = CreateFrame("Slider", "NSForumCopySlider", scrollFrame)
    sb:SetOrientation("VERTICAL")
    sb:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -2, -2)
    sb:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -2, 2)
    sb:SetWidth(16)
    sb:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    sb:SetBackdrop({bgFile = "Interface\\Buttons\\UI-ScrollBar-Background"})
    sb:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    sb:SetValueStep(20)

    local function UpdateScrollRange()
        sb:SetMinMaxValues(0, math.max(0, editBox:GetHeight() - scrollFrame:GetHeight()))
    end

    sb:SetScript("OnValueChanged", function(self, val)
        scrollFrame:SetVerticalScroll(val)
    end)

    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local newVal = current - (delta * 20)
        if newVal < 0 then newVal = 0 end
        local maxScroll = select(2, sb:GetMinMaxValues())
        if maxScroll and newVal > maxScroll then newVal = maxScroll end
        self:SetVerticalScroll(newVal)
        sb:SetValue(newVal)
    end)

    scrollFrame:SetScript("OnSizeChanged", UpdateScrollRange)
    editBox:SetScript("OnTextChanged", UpdateScrollRange)
    UpdateScrollRange()

    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function()
        panel:Hide()
        panel:SetParent(nil)
        NSForumClient.copyPanel = nil
    end)

    local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("BOTTOM", 0, 10)
    hint:SetText("Нажмите Ctrl+C для копирования или Esc для закрытия")
    hint:SetTextColor(0.7, 0.7, 0.7, 1)

    NSForumClient.copyPanel = panel
    panel:Show()
    editBox:SetFocus()
    editBox:HighlightText()
end

-- ============================================
-- ПАРСИНГ ТЕКСТА НА БЛОКИ
-- ============================================
function NSForumClient.ParseCopyableBlocks(content)
    local blocks = {}
    if not content or content == "" then return blocks end
    local pos = 1
    local textBefore = ""
    while pos <= #content do
        local startIdx, endIdx = string.find(content, "--[", pos, true)
        if not startIdx then
            textBefore = textBefore .. string.sub(content, pos)
            break
        end
        local closeIdx = string.find(content, "--]", endIdx + 1, true)
        if not closeIdx then
            textBefore = textBefore .. string.sub(content, pos)
            break
        end
        local beforeBlock = string.sub(content, pos, startIdx - 1)
        textBefore = textBefore .. beforeBlock
        local blockContent = string.sub(content, endIdx + 1, closeIdx - 1)
        if textBefore ~= "" then
            table.insert(blocks, { type = "text", content = textBefore })
        end
        table.insert(blocks, { type = "copyable", content = blockContent })
        textBefore = ""
        pos = closeIdx + 3
    end
    if textBefore ~= "" then
        table.insert(blocks, { type = "text", content = textBefore })
    end
    return blocks
end

-- ============================================
-- 2. ПАРСИНГ ТЕКСТА НА БЛОКИ
-- ============================================
function NSForumClient.ParseContentBlocks(content)
    local blocks = {}
    if not content or content == "" then return blocks end
    
    local pos = 1
    while pos <= #content do
        local copyStart = string.find(content, "--[", pos, true)
        local linkStart = string.find(content, "|H", pos, true)
        
        local nextSpecial = nil
        local nextType = nil
        
        if copyStart and linkStart then
            if copyStart < linkStart then nextSpecial = copyStart; nextType = "copyable"
            else nextSpecial = linkStart; nextType = "link" end
        elseif copyStart then nextSpecial = copyStart; nextType = "copyable"
        elseif linkStart then nextSpecial = linkStart; nextType = "link" end
        
        if not nextSpecial then
            local remaining = string.sub(content, pos)
            if remaining ~= "" then table.insert(blocks, { type = "text", content = remaining }) end
            break
        end
        
        local textBefore = string.sub(content, pos, nextSpecial - 1)
        if textBefore ~= "" then table.insert(blocks, { type = "text", content = textBefore }) end
        
        if nextType == "copyable" then
            local closeIdx = string.find(content, "--]", nextSpecial + 3, true)
            if not closeIdx then
                local remaining = string.sub(content, nextSpecial)
                if remaining ~= "" then table.insert(blocks, { type = "text", content = remaining }) end
                break
            end
            table.insert(blocks, { type = "copyable", content = string.sub(content, nextSpecial + 3, closeIdx - 1) })
            pos = closeIdx + 3
            
        elseif nextType == "link" then
            local linkDataEnd = string.find(content, "|h", nextSpecial + 2, true)
            if not linkDataEnd then
                table.insert(blocks, { type = "text", content = string.sub(content, nextSpecial) })
                break
            end
            local linkPayload = string.sub(content, nextSpecial + 2, linkDataEnd - 1)
            
            local bracketStart = string.find(content, "[", linkDataEnd + 2, true)
            if not bracketStart or bracketStart ~= linkDataEnd + 2 then
                table.insert(blocks, { type = "text", content = string.sub(content, nextSpecial) })
                break
            end
            local bracketEnd = string.find(content, "]", bracketStart + 1, true)
            if not bracketEnd then
                table.insert(blocks, { type = "text", content = string.sub(content, nextSpecial) })
                break
            end
            local closeTag = string.find(content, "|h", bracketEnd + 1, true)
            if not closeTag then
                table.insert(blocks, { type = "text", content = string.sub(content, nextSpecial) })
                break
            end
            
            table.insert(blocks, { 
                type = "link", 
                linkPayload = linkPayload, 
                linkText = string.sub(content, bracketStart + 1, bracketEnd - 1) 
            })
            pos = closeTag + 2
        end
    end
    return blocks
end

-- ============================================
-- 3. БЛОК ДЛЯ КОПИРОВАНИЯ
-- ============================================
function NSForumClient.CreateCopyableBlock(parent, text, yOffset)
    local blockFrame = CreateFrame("Button", nil, parent)
    blockFrame:SetPoint("TOPLEFT", 15, yOffset)
    blockFrame:SetPoint("RIGHT", parent, "RIGHT", -15, 0)
    
    local textObj = blockFrame:CreateFontString(nil, "OVERLAY")
    textObj:SetFont("Fonts\\FRIZQT__.TTF", 14)
    textObj:SetJustifyH("LEFT")
    textObj:SetText(text)
    textObj:SetTextColor(0.4, 0.8, 1, 1)
    
    local height = textObj:GetStringHeight() or 14
    blockFrame:SetHeight(height + 8)
    textObj:SetPoint("LEFT", 8, 0)
    textObj:SetPoint("RIGHT", -8, 0)
    
    local bg = blockFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Buttons\\White8x8")
    bg:SetVertexColor(0, 0, 0, 0.9)
    bg:SetAllPoints(blockFrame)
    
    blockFrame:SetScript("OnEnter", function(self)
        bg:SetVertexColor(0.15, 0.15, 0.15, 0.95)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Нажмите для копирования", 1, 1, 1)
        GameTooltip:Show()
    end)
    blockFrame:SetScript("OnLeave", function(self)
        bg:SetVertexColor(0, 0, 0, 0.9)
        GameTooltip:Hide()
    end)
    blockFrame:SetScript("OnClick", function()
        NSForumClient.ShowCopyPanel(text, blockFrame)
    end)
    blockFrame:Show()
    return blockFrame
end

-- ============================================
-- 4. БЛОК ССЫЛКИ
-- ============================================
function NSForumClient.CreateLinkBlock(parent, linkPayload, linkText, yOffset)
    local blockFrame = CreateFrame("Button", nil, parent)
    blockFrame:SetPoint("TOPLEFT", 15, yOffset)
    blockFrame:SetPoint("RIGHT", parent, "RIGHT", -15, 0)
    
    local textObj = blockFrame:CreateFontString(nil, "OVERLAY")
    textObj:SetFont("Fonts\\FRIZQT__.TTF", 14)
    textObj:SetJustifyH("LEFT")
    textObj:SetText(linkText)
    textObj:SetTextColor(1, 0.82, 0, 1)
    
    local height = textObj:GetStringHeight() or 14
    blockFrame:SetHeight(height + 8)
    textObj:SetPoint("LEFT", 8, 0)
    textObj:SetPoint("RIGHT", -8, 0)
    
    local bg = blockFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Buttons\\White8x8")
    bg:SetVertexColor(0, 0, 0, 0.9)
    bg:SetAllPoints(blockFrame)
    
    local capturedPayload = linkPayload
    local capturedText = linkText
    
    blockFrame:SetScript("OnEnter", function(self)
        bg:SetVertexColor(0.15, 0.15, 0.15, 0.95)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(capturedPayload)
        GameTooltip:Show()
    end)
    blockFrame:SetScript("OnLeave", function(self)
        bg:SetVertexColor(0, 0, 0, 0.9)
        GameTooltip:Hide()
    end)
    blockFrame:SetScript("OnClick", function()
        SetItemRef(capturedPayload, capturedText, "LeftButton")
    end)
    blockFrame:Show()
    return blockFrame
end

if not NSForumClient._linkHookInstalled then
    NSForumClient._linkHookInstalled = true
    local originalChatEditInsertLink = ChatEdit_InsertLink
    ChatEdit_InsertLink = function(link)
        if NSForumClient.activeEditBox and NSForumClient.activeEditBox:HasFocus() then
            NSForumClient.activeEditBox:Insert(link)
            return
        end
        if originalChatEditInsertLink then return originalChatEditInsertLink(link) end
    end
end

-- ============================================
-- СЛЕШ-КОМАНДЫ И ССЫЛКИ
-- ============================================

SLASH_NSFORUM1 = "/forum"
SLASH_NSFORUM2 = "/форум"
SlashCmdList["NSFORUM"] = function() NSForumClient.CreateForumWindow() end

function NSForumClient.OpenTopicById(threadId)
    if not threadId then
        print("|cffFF0000[Forum]|r Не указан ID темы!")
        return false
    end
    if not IsInGuild() then
        print("|cffFF0000[Forum]|r Вы должны быть в гильдии!")
        return false
    end
    DebugPrint("Opening topic by ID:", threadId)
    NSForumClient.SetSelectedThreadId(threadId)
    NSForumClient.SetCurrentView("thread")
    NSForumClient.SetLoadingThread(true)
    NSForumClient.CreateForumWindow()
    return true
end

SLASH_NSFORUMTOPIC1 = "/forumtopic"
SLASH_NSFORUMTOPIC2 = "/ft"
SlashCmdList["NSFORUMTOPIC"] = function(msg)
    local threadId = tonumber(msg:match("%d+"))
    if not threadId then
        print("|cffFF0000[Forum]|r Использование: /forumtopic <ID> или /ft <ID>")
        return
    end
    NSForumClient.OpenTopicById(threadId)
end

-- Система кэширования и подмены ссылок
NSForumClient.topicTitles = NSForumClient.topicTitles or {}

local linkCacheFrame = CreateFrame("Frame")
linkCacheFrame:RegisterEvent("CHAT_MSG_ADDON")
linkCacheFrame:SetScript("OnEvent", function(_, _, prefix, text, channel)
    if prefix == "NSFORUM" and channel == "GUILD" then
        if string.sub(text, 1, 7) == "ftCache" then
            local idStr, title = strsplit(" ", text:sub(9), 2)
            if idStr and title then NSForumClient.topicTitles[tonumber(idStr)] = title end
        elseif string.sub(text, 1, 8) == "itsLink:" then
            local idStr, title = strsplit(" ", text:sub(9), 2)
            if idStr and title then NSForumClient.topicTitles[tonumber(idStr)] = title end
        end
    end
end)

local function ForumLinkFilter(_, _, msg, ...)
    if type(msg) ~= "string" then return false end
    local function ReplaceLink(id)
        local tid = tonumber(id)
        if not tid then return "/forumtopic " .. id end
        local title = NSForumClient.topicTitles[tid]
        if not title then
            if IsInGuild() then SendAddonMessage("NSFORUM", "getMeLink:" .. tid, "GUILD") end
            return "|cffFFD700|Hforum:" .. tid .. "|h[Загрузка...]|h|r"
        end
        if #title > 80 then title = title:sub(1, 77) .. "..." end
        return "|cffFFD700|Hforum:" .. tid .. "|h[" .. title .. "]|h|r"
    end
    local changed = false
    msg = string.gsub(msg, "/forumtopic%s+(%d+)", function(id) changed = true; return ReplaceLink(id) end)
    msg = string.gsub(msg, "/ft%s+(%d+)", function(id) changed = true; return ReplaceLink(id) end)
    if changed then return false, msg, ... end
    return false
end

local chatFilterFrame = CreateFrame("Frame")
chatFilterFrame:RegisterEvent("PLAYER_LOGIN")
chatFilterFrame:SetScript("OnEvent", function()
    local channels = {
        "CHAT_MSG_CHANNEL", "CHAT_MSG_SAY", "CHAT_MSG_YELL",
        "CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_BN_WHISPER", "CHAT_MSG_BN_WHISPER_INFORM"
    }
    for _, ch in ipairs(channels) do ChatFrame_AddMessageEventFilter(ch, ForumLinkFilter) end
end)

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(chatFrame, link, text, button)
    local forumId = string.match(link, "^forum:(%d+)$")
    if forumId then
        local threadId = tonumber(forumId)
        if threadId and IsInGuild() then
            if not NSForumClient.IsWindowOpen() then NSForumClient.CreateForumWindow() end
            NSForumClient.OpenTopicById(threadId)
        end
    end
end)

local origSetItemRef = SetItemRef
SetItemRef = function(link, text, button, chatFrame)
    if link and button == "LeftButton" then
        local tid = tonumber(string.match(link, "^forum:(%d+)$"))
        if tid then
            if NSForumClient.OpenTopicById then NSForumClient.OpenTopicById(tid) end
            return
        end
    end
    if origSetItemRef then origSetItemRef(link, text, button, chatFrame) end
end

print("|cff00ff00[ForumClient v6.7.1 DEBUG]|r Loaded. Debug mode active.")









-- ============================================
-- ЧАТ РЕАКЦИИ - ФИНАЛЬНЫЙ РЕЛИЗ v2.9.4
-- ============================================
ns_reactions = ns_reactions or {}
NSForumClient.chatReactions = ns_reactions

local function CreateMessageKey(author, message)
    local a = tostring(author or ""):match("([^:]+)") or ""
    a = a:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):gsub("%s",""):lower()
    local m = tostring(message or "")
    m = m:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r",""):gsub("%s",""):lower()
    if #m > 50 then m = m:sub(1, 50) end
    return a .. "~" .. m
end

local function GetReactionsTooltipLines(msgKey)
    local data = ns_reactions[msgKey]
    if not data or not data.users then return nil end
    local lines = {}
    for _, r in ipairs(REACTIONS) do
        if data.users[r.key] and #data.users[r.key] > 0 then
            local names = table.concat(data.users[r.key], ", ")
            table.insert(lines, "|T" .. r.icon .. ":14:14|t " .. (r.name or r.key) .. ": " .. names)
        end
    end
    if #lines == 0 then return nil end
    return lines
end

function NSForumClient.GetReactionsIconString(msgKey)
    local data = ns_reactions[msgKey]
    if not data or not data.users then return "" end
    local parts = {}
    for _, r in ipairs(REACTIONS) do
        if data.users[r.key] and #data.users[r.key] > 0 then
            table.insert(parts, string.format("|T%s:14:14|t%d", r.icon, #data.users[r.key]))
        end
    end
    if #parts == 0 then return "" end
    return " " .. table.concat(parts, " ")
end

-- Функция проверки видимости региона в чате
local function IsRegionVisible(chatFrame, region)
    if not chatFrame or not region then return false end
    if not chatFrame:IsShown() then return false end
    if not region:IsShown() then return false end
    
    -- Используем GetRegions родителя для определения положения скролла
    -- Получаем координаты через GetPoint()
    local point, relativeTo, relativePoint, xOfs, yOfs = region:GetPoint()
    if not point then return false end
    
    -- Получаем высоту родительского фрейма (области сообщений)
    local parent = region:GetParent()
    if not parent then return false end
    
    -- Получаем высоту строки текста
    local height = region:GetHeight()
    if not height or height <= 0 then return false end
    
    -- Проверяем, не находится ли регион за пределами видимой области
    -- Используем chatFrame:GetVisibleLines() если доступен
    if chatFrame.GetVisibleLines then
        -- Этот метод может быть недоступен, пробуем альтернативный подход
    end
    
    -- Альтернативный метод: проверяем через GetTop/GetBottom с защитой
    local success, top = pcall(region.GetTop, region)
    local success2, bottom = pcall(region.GetBottom, region)
    local success3, chatTop = pcall(chatFrame.GetTop, chatFrame)
    local success4, chatBottom = pcall(chatFrame.GetBottom, chatFrame)
    
    if success and success2 and success3 and success4 then
        if top and bottom and chatTop and chatBottom then
            local margin = 5
            -- Проверяем, что регион видим в чате
            return (bottom >= chatBottom - margin) and (top <= chatTop + margin)
        end
    end
    
    -- Если pcall не удался, считаем что регион видим (пропускаем проверку)
    return true
end

-- ВАЖНО: ПЕРЕИМЕНОВАНО, ЧТОБЫ НЕ КОНФЛИКТОВАТЬ С ФОРУМОМ
function NSForumClient.ShowChatReactionPanel(msgKey, anchorButton)
    if NSForumClient.chatReactionPanel then
        NSForumClient.chatReactionPanel:Hide()
    end
    
    local panel = CreateFrame("Frame", nil, UIParent)
    panel:SetSize((#REACTIONS * 32) + 20, 40)
    panel:SetFrameStrata("FULLSCREEN_DIALOG")
    panel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = {left = 3, right = 3, top = 3, bottom = 3}
    })
    panel:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    panel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    if anchorButton then
        panel:SetPoint("BOTTOM", anchorButton, "TOP", 0, 5)
    else
        panel:SetPoint("CENTER")
    end
    
    local data = ns_reactions[msgKey]
    local myName = UnitName("player")
    
    for i = 1, #REACTIONS do
        local r = REACTIONS[i]
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(28, 28)
        btn:SetPoint("LEFT", 8 + (i-1) * 32, 0)
        btn:SetPoint("TOP", 0, -6)
        
        local tex = btn:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints()
        tex:SetTexture(r.icon)
        if data and data.users and data.users[r.key] then
            for _, name in ipairs(data.users[r.key]) do
                if name == myName then
                    tex:SetVertexColor(0.3, 0.5, 1, 1)
                end
            end
        end
        
        btn:SetScript("OnMouseDown", function()
            local now = GetTime()
            if now - (NSForumClient.lastReactionClick or 0) < 0.5 then return end
            NSForumClient.lastReactionClick = now
            panel:Hide()
            NSForumClient.AddChatReaction(msgKey, r.key)
        end)
        
        btn:SetScript("OnEnter", function()
            if data and data.users and data.users[r.key] and #data.users[r.key] > 0 then
                GameTooltip:SetOwner(btn, "ANCHOR_CURSOR")
                GameTooltip:SetText(r.name or r.key, 1, 1, 1)
                GameTooltip:AddLine(table.concat(data.users[r.key], ", "), 1, 1, 1, 1)
                GameTooltip:Show()
            end
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    
    local closer = CreateFrame("Frame", nil, UIParent)
    closer:SetAllPoints()
    closer:SetFrameStrata("FULLSCREEN")
    closer:SetFrameLevel(panel:GetFrameLevel() - 1)
    closer:EnableMouse(true)
    closer:SetScript("OnMouseDown", function()
        panel:Hide()
        closer:Hide()
    end)
    
    panel:SetScript("OnHide", function()
        closer:Hide()
        NSForumClient.chatReactionPanel = nil
    end)
    
    NSForumClient.chatReactionPanel = panel
    panel:Show()
end

function NSForumClient.AddChatReaction(msgKey, reactionKey)
    local myName = UnitName("player")
    if not myName then return end
    if not ns_reactions[msgKey] then ns_reactions[msgKey] = { users = {} } end
    if not ns_reactions[msgKey].users[reactionKey] then ns_reactions[msgKey].users[reactionKey] = {} end
    
    local list = ns_reactions[msgKey].users[reactionKey]
    local found = false
    for i = #list, 1, -1 do if list[i] == myName then table.remove(list, i); found = true; break end end
    if not found then table.insert(list, myName) end
    
    if IsInGuild() then
        SendAddonMessage("NSCHATREACT", "REACT:" .. msgKey .. ";;" .. reactionKey, "GUILD")
    end
    NSForumClient.UpdateMessageByKey(msgKey)
end

function NSForumClient.UpdateMessageByKey(msgKey)
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame and chatFrame:IsShown() then
            local regions = {chatFrame:GetRegions()}
            for _, region in ipairs(regions) do
                if region.GetText and region:GetObjectType() == "FontString" then
                    local text = region:GetText()
                    if text then
                        local cleanText = text:gsub(" |TInterface.-|t%d+", "")
                        if cleanText:find("Hchannel:GUILD") then
                            local authorFull = cleanText:match("|h%[([^%]]+)%]|h: ") or cleanText:match("|h%[([^%]]+)%]|h") or ""
                            local message = cleanText:match("]|h: (.+)$") or cleanText:match("]|h (.+)$") or ""
                            if authorFull ~= "" and message ~= "" and CreateMessageKey(authorFull, message) == msgKey then
                                local iconStr = NSForumClient.GetReactionsIconString(msgKey)
                                local newText = cleanText .. iconStr
                                if newText ~= text then pcall(function() region:SetText(newText) end) end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Приём реакций от других
local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("CHAT_MSG_ADDON")
addonFrame:SetScript("OnEvent", function(_, _, prefix, text, channel, sender)
    if prefix ~= "NSCHATREACT" or channel ~= "GUILD" then return end
    local myName = UnitName("player")
    if sender == myName then return end
    
    local action, data = strsplit(":", text, 2)
    if action ~= "REACT" or not data then return end
    
    local sepPos = string.find(data, ";;", 1, true)
    if not sepPos then return end
    local msgKey = string.sub(data, 1, sepPos - 1)
    local reactionKey = string.sub(data, sepPos + 2)
    
    if not msgKey or not reactionKey then return end
    if not ns_reactions[msgKey] then ns_reactions[msgKey] = { users = {} } end
    if not ns_reactions[msgKey].users[reactionKey] then ns_reactions[msgKey].users[reactionKey] = {} end
    
    local list = ns_reactions[msgKey].users[reactionKey]
    local found = false
    for i = #list, 1, -1 do if list[i] == sender then table.remove(list, i); found = true; break end end
    if not found then table.insert(list, sender) end
    
    NSForumClient.UpdateMessageByKey(msgKey)
end)

-- Функция для создания/обновления кнопок на конкретном chatFrame
local function UpdateButtonsForChatFrame(chatFrame)
    if not chatFrame or not chatFrame:IsShown() then return end
    if not chatFrame.reactionButtons then chatFrame.reactionButtons = {} end
    if not chatFrame.originalColors then chatFrame.originalColors = {} end
    if not chatFrame.buttonRegions then chatFrame.buttonRegions = {} end
    if not chatFrame.activeKeys then chatFrame.activeKeys = {} end
    
    for key, _ in pairs(chatFrame.activeKeys) do
        chatFrame.activeKeys[key] = false
    end
    
    -- Сначала скрываем все кнопки, потом покажем только видимые
    for key, btn in pairs(chatFrame.reactionButtons) do
        btn:Hide()
    end
    
    local regions = {chatFrame:GetRegions()}
    for _, region in ipairs(regions) do
        if region.GetText and region:GetObjectType() == "FontString" then
            local text = region:GetText()
            if text then
                -- Проверяем, видим ли регион в чате
                if IsRegionVisible(chatFrame, region) then
                    local cleanText = text:gsub(" |TInterface.-|t%d+", "")
                    if cleanText:find("Hchannel:GUILD") then
                        local af = cleanText:match("|h%[([^%]]+)%]|h: ") or cleanText:match("|h%[([^%]]+)%]|h") or ""
                        local ms = cleanText:match("]|h: (.+)$") or cleanText:match("]|h (.+)$") or ""
                        if af ~= "" and ms ~= "" then
                            local key = CreateMessageKey(af, ms)
                            if not ns_reactions[key] then ns_reactions[key] = { users = {} } end
                            chatFrame.activeKeys[key] = true
                            chatFrame.buttonRegions[key] = region
                            
                            if not chatFrame.originalColors[key] then
                                local r, g, b, a = region:GetTextColor()
                                chatFrame.originalColors[key] = {r = r, g = g, b = b, a = a}
                            end
                            
                            local btn = chatFrame.reactionButtons[key]
                            if not btn then
                                btn = CreateFrame("Button", nil, chatFrame)
                                btn:SetSize(16, 16)
                                btn:SetFrameStrata("DIALOG")
                                local icon = btn:CreateTexture(nil, "OVERLAY")
                                icon:SetAllPoints()
                                icon:SetTexture("Interface\\AddOns\\NSQC3\\libs\\emote_smile")
                                icon:SetVertexColor(0.5, 0.5, 0.5, 0.5)
                                
                                local savedKey = key
                                btn:SetScript("OnMouseDown", function()
                                    NSForumClient.ShowChatReactionPanel(savedKey, btn)
                                end)
                                
                                btn:SetScript("OnEnter", function()
                                    icon:SetVertexColor(1, 1, 1, 1)
                                    local savedRegion = chatFrame.buttonRegions[savedKey]
                                    if savedRegion then
                                        pcall(function() savedRegion:SetTextColor(1, 0, 0, 1) end)
                                    end
                                    local tooltipLines = GetReactionsTooltipLines(savedKey)
                                    if tooltipLines then
                                        GameTooltip:SetOwner(btn, "ANCHOR_CURSOR")
                                        GameTooltip:SetText("Реакции:", 1, 1, 1)
                                        for _, line in ipairs(tooltipLines) do
                                            GameTooltip:AddLine(line, 1, 1, 1, 1)
                                        end
                                        GameTooltip:Show()
                                    end
                                end)
                                
                                btn:SetScript("OnLeave", function()
                                    icon:SetVertexColor(0.5, 0.5, 0.5, 0.5)
                                    local savedRegion = chatFrame.buttonRegions[savedKey]
                                    if savedRegion then
                                        local origColor = chatFrame.originalColors[savedKey]
                                        if origColor then
                                            pcall(function() savedRegion:SetTextColor(origColor.r, origColor.g, origColor.b, origColor.a) end)
                                        end
                                    end
                                    GameTooltip:Hide()
                                end)
                                chatFrame.reactionButtons[key] = btn
                            end
                            
                            btn:ClearAllPoints()
                            btn:SetPoint("RIGHT", region, "RIGHT", -4, 0)
                            btn:Show()
                            
                            local iconStr = NSForumClient.GetReactionsIconString(key)
                            local newText = cleanText .. iconStr
                            if newText ~= text then
                                pcall(function() region:SetText(newText) end)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Событие нового сообщения
local guildChatFrame = CreateFrame("Frame")
guildChatFrame:RegisterEvent("CHAT_MSG_GUILD")
guildChatFrame:SetScript("OnEvent", function(self, event, msg, author, ...)
    local msgKey = CreateMessageKey(author, msg)
    if not ns_reactions[msgKey] then ns_reactions[msgKey] = { users = {} } end
    
    local delayFrame = CreateFrame("Frame")
    delayFrame.elapsed = 0
    delayFrame.attempts = 0
    delayFrame:SetScript("OnUpdate", function(df, elapsed)
        df.elapsed = df.elapsed + elapsed
        if df.elapsed < 0.3 then return end
        df.elapsed = 0
        df.attempts = df.attempts + 1
        if df.attempts > 5 then df:SetScript("OnUpdate", nil); df:Hide(); return end
        for i = 1, NUM_CHAT_WINDOWS do
            UpdateButtonsForChatFrame(_G["ChatFrame" .. i])
        end
    end)
end)

-- Автообновление
local autoRefresh = CreateFrame("Frame")
autoRefresh:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer < 0.5 then return end
    self.timer = 0
    for i = 1, NUM_CHAT_WINDOWS do
        UpdateButtonsForChatFrame(_G["ChatFrame" .. i])
    end
end)

-- Очистка при скрытии
for i = 1, NUM_CHAT_WINDOWS do
    local chatFrame = _G["ChatFrame" .. i]
    if chatFrame then
        chatFrame:HookScript("OnHide", function()
            if chatFrame.reactionButtons then
                for _, btn in pairs(chatFrame.reactionButtons) do
                    btn:Hide()
                end
            end
        end)
    end
end

































































































































