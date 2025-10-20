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

GpDb = {}
GpDb.__index = GpDb

function GpDb:new(input_table)
    local new_object = {
        gp_data = {},
        sort_column = "nick",
        sort_ascending = true,
        visible_rows = 20,
        selected_indices = {},
        last_selected_index = nil,
        logData = {},
        filterText = "",
        updateTimer = nil  -- Добавляем поле для управления таймером
    }
    setmetatable(new_object, self)
    
    new_object:_CreateWindow()
    new_object:_CreateRaidSelectionWindow()
    new_object:_CreateLogWindow()
    
    return new_object
end

function GpDb:AddRawLogEntry(rawLogString)
    if not self.logWindow then
        self:_CreateLogWindow()
    end

    -- Парсим: "1760908142 Шеф Тест 5 1Ic"
    local words = {}
    for word in rawLogString:gmatch("%S+") do
        table.insert(words, word)
    end

    if #words < 4 then return end

    local unixTime = tonumber(words[1])
    local rl = words[2]
    local raid = words[3]
    local gpValue = tonumber(words[4]) or 0

    -- Цели — всё, что после 4-го слова
    local targets = {}
    for i = 5, #words do
        table.insert(targets, words[i])
    end
    local targetsStr = table.concat(targets, " ")

    -- Форматируем время из unixtime
    local formattedTime = "|cFFA0A0A0" .. date("%d %H:%M:%S", unixTime) .. "|r"

    -- Получаем цвет класса для РЛ
    local function GetClassColor(name)
        if not name or type(name) ~= "string" or name == "" then 
            return "|cFFFFFFFF" 
        end
        for i = 1, GetNumGuildMembers() do
            local guildName, _, _, _, _, _, _, _, _, _, classFileName = GetGuildRosterInfo(i)
            if guildName and guildName == name then
                local color = RAID_CLASS_COLORS[classFileName]
                if color then
                    return string.format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
                end
                break
            end
        end
        return "|cFFFFFFFF"
    end

    local formattedRl = GetClassColor(rl) .. (rl or "Неизвестно") .. "|r"
    local gpColor = gpValue >= 0 and "|cFF00FF00" or "|cFFFF0000"
    local formattedGp = gpColor .. tostring(gpValue) .. "|r"
    local formattedRaid = "|cFFFFFF00" .. (raid or "Неизвестно") .. "|r"

    -- Декодируем цели (если есть NSQS_dict)
    local formattedTargets = {}
    for _, code in ipairs(targets) do
        local playerName = code
        if NSQS_dict then
            for name, info in pairs(NSQS_dict) do
                if info[2] == code then
                    playerName = name
                    break
                end
            end
        end
        table.insert(formattedTargets, GetClassColor(playerName) .. playerName .. "|r")
    end
    local formattedTargetsText = table.concat(formattedTargets, " ")

    local logText = string.format("%s | %s | %s | %s | %s",
        formattedTime,
        formattedRl,
        formattedGp,
        formattedRaid,
        formattedTargetsText)

    table.insert(self.logData, {
        text = logText,
        raw = {
            time = unixTime,
            rl = rl,
            gp = gpValue,
            raid = raid,
            targets = targetsStr
        }
    })

    if #self.logData > 2000 then
        table.remove(self.logData, 1)
    end

    if self.logWindow and self.logWindow:IsShown() then
        self:UpdateLogDisplay()
        self.logWindow.scrollFrame:SetVerticalScroll(self.logWindow.scrollFrame:GetVerticalScrollRange())
    end
end

function GpDb:_CreateLogWindow()
    -- Основное окно логов
    self.logWindow = CreateFrame("Frame", "GpDbLogWindow", self.window)
    self.logWindow:SetFrameStrata("DIALOG")
    self.logWindow:SetSize(600, self.window:GetHeight())
    self.logWindow:SetPoint("TOPLEFT", self.window, "TOPRIGHT", 5, 0)
    self.logWindow:SetMovable(false)
    self.logWindow:Hide()
    -- Фон окна
    self.logWindow.background = self.logWindow:CreateTexture(nil, "BACKGROUND")
    self.logWindow.background:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.logWindow.background:SetVertexColor(0.1, 0.1, 0.1)
    self.logWindow.background:SetAlpha(0.9)
    self.logWindow.background:SetAllPoints(true)
    -- Граница окна
    self.logWindow.borderFrame = CreateFrame("Frame", nil, self.logWindow)
    self.logWindow.borderFrame:SetPoint("TOPLEFT", -3, 3)
    self.logWindow.borderFrame:SetPoint("BOTTOMRIGHT", 3, -3)
    self.logWindow.borderFrame:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    -- Кнопка закрытия
    self.logWindow.closeButton = CreateFrame("Button", nil, self.logWindow, "UIPanelCloseButton")
    self.logWindow.closeButton:SetPoint("TOPRIGHT", -5, -5)
    self.logWindow.closeButton:SetScript("OnClick", function() 
        self.logWindow:Hide() 
    end)
    -- Фильтры
    self.logWindow.filters = CreateFrame("Frame", nil, self.logWindow)
    self.logWindow.filters:SetPoint("TOPLEFT", 10, -5)
    self.logWindow.filters:SetPoint("RIGHT", -10, 0)
    self.logWindow.filters:SetHeight(30)
    -- Поле "Количество"
    self.logWindow.countFilter = CreateFrame("EditBox", nil, self.logWindow.filters, "InputBoxTemplate")
    self.logWindow.countFilter:SetSize(60, 20)
    self.logWindow.countFilter:SetPoint("LEFT", self.logWindow.filters, "LEFT")
    self.logWindow.countFilter:SetAutoFocus(false)
    self.logWindow.countFilter:SetText("Кол-во")
    self.logWindow.countFilter:SetScript("OnEscapePressed", function() self.logWindow.countFilter:ClearFocus() end)
    self.logWindow.countFilter:SetScript("OnEnterPressed", function() 
        self.logWindow.countFilter:ClearFocus() 
        self:UpdateLogDisplay()
    end)
    -- Поле "День" (вместо "Время")
    self.logWindow.timeFilter = CreateFrame("EditBox", nil, self.logWindow.filters, "InputBoxTemplate")
    self.logWindow.timeFilter:SetSize(70, 20)
    self.logWindow.timeFilter:SetPoint("LEFT", self.logWindow.countFilter, "RIGHT", 5, 0)
    self.logWindow.timeFilter:SetAutoFocus(false)
    self.logWindow.timeFilter:SetText("День")
    self.logWindow.timeFilter:SetScript("OnEscapePressed", function() self.logWindow.timeFilter:ClearFocus() end)
    self.logWindow.timeFilter:SetScript("OnEnterPressed", function() 
        self.logWindow.timeFilter:ClearFocus() 
        self:UpdateLogDisplay()
    end)
    -- Поле "РЛ"
    self.logWindow.rlFilter = CreateFrame("EditBox", nil, self.logWindow.filters, "InputBoxTemplate")
    self.logWindow.rlFilter:SetSize(70, 20)
    self.logWindow.rlFilter:SetPoint("LEFT", self.logWindow.timeFilter, "RIGHT", 5, 0)
    self.logWindow.rlFilter:SetAutoFocus(false)
    self.logWindow.rlFilter:SetText("РЛ")
    self.logWindow.rlFilter:SetScript("OnEscapePressed", function() self.logWindow.rlFilter:ClearFocus() end)
    self.logWindow.rlFilter:SetScript("OnEnterPressed", function() 
        self.logWindow.rlFilter:ClearFocus() 
        self:UpdateLogDisplay()
    end)
    -- Поле "Рейд"
    self.logWindow.raidFilter = CreateFrame("EditBox", nil, self.logWindow.filters, "InputBoxTemplate")
    self.logWindow.raidFilter:SetSize(100, 20)
    self.logWindow.raidFilter:SetPoint("LEFT", self.logWindow.rlFilter, "RIGHT", 5, 0)
    self.logWindow.raidFilter:SetAutoFocus(false)
    self.logWindow.raidFilter:SetText("Рейд")
    self.logWindow.raidFilter:SetScript("OnEscapePressed", function() self.logWindow.raidFilter:ClearFocus() end)
    self.logWindow.raidFilter:SetScript("OnEnterPressed", function() 
        self.logWindow.raidFilter:ClearFocus() 
        self:UpdateLogDisplay()
    end)
    -- Поле "Ник"
    self.logWindow.nameFilter = CreateFrame("EditBox", nil, self.logWindow.filters, "InputBoxTemplate")
    self.logWindow.nameFilter:SetSize(100, 20)
    self.logWindow.nameFilter:SetPoint("LEFT", self.logWindow.raidFilter, "RIGHT", 5, 0)
    self.logWindow.nameFilter:SetAutoFocus(false)
    self.logWindow.nameFilter:SetText("Ник")
    self.logWindow.nameFilter:SetScript("OnEscapePressed", function() self.logWindow.nameFilter:ClearFocus() end)
    self.logWindow.nameFilter:SetScript("OnEnterPressed", function() 
        self.logWindow.nameFilter:ClearFocus() 
        self:UpdateLogDisplay()
    end)
    -- Кнопка "Показать"
    self.logWindow.showButton = CreateFrame("Button", nil, self.logWindow.filters, "UIPanelButtonTemplate")
    self.logWindow.showButton:SetSize(80, 22)
    self.logWindow.showButton:SetPoint("LEFT", self.logWindow.nameFilter, "RIGHT", 5, 0)
    self.logWindow.showButton:SetText("Показать")
    self.logWindow.showButton:SetScript("OnClick", function()
        local function processFilterText(text, placeholder)
            if text == placeholder or text == "" then
                return "_"
            end
            if text:find("%s") then
                text = text:gsub("%s+", "_")
            end
            return text
        end

        local count = processFilterText(self.logWindow.countFilter:GetText(), "Кол-во")
        local time = processFilterText(self.logWindow.timeFilter:GetText(), "День")
        local rl = processFilterText(self.logWindow.rlFilter:GetText(), "РЛ")
        local raid = processFilterText(self.logWindow.raidFilter:GetText(), "Рейд")
        
        -- === Преобразуем имя → код через officerNote ===
        local nameInput = self.logWindow.nameFilter:GetText()
        local name = "_"
        if nameInput ~= "" and nameInput ~= "Ник" then
            local foundCode = nil
            -- Ищем игрока по имени в гильдии
            for i = 1, GetNumGuildMembers() do
                local guildName, _, _, _, _, _, _, officerNote = GetGuildRosterInfo(i)
                if guildName and officerNote then
                    -- Убираем серверную часть из имени (если есть)
                    local plainName = guildName:match("^(.-)-") or guildName
                    if plainName == nameInput then
                        -- Парсим officerNote: ожидаем формат "что-то КОД ..."
                        local words = {}
                        for w in officerNote:gmatch("%S+") do
                            table.insert(words, w)
                        end
                        if #words >= 2 then
                            foundCode = words[2]
                            break
                        end
                    end
                end
            end
            name = foundCode or nameInput  -- если не нашли — отправляем как есть (на случай ручного ввода кода)
        end

        local request = count .. " " .. time .. " " .. rl .. " " .. raid .. " " .. name
        print("|cFF00FF00[Клиент] Запрос логов:|r", request)
        self:ClearLog()
        SendAddonMessage("NSShowMeLogs", request, "GUILD")
    end)
    -- Область с прокруткой для логов
    self.logWindow.scrollFrame = CreateFrame("ScrollFrame", "GpDbLogScrollFrame", self.logWindow, "UIPanelScrollFrameTemplate")
    self.logWindow.scrollFrame:SetPoint("TOPLEFT", 0, -35)
    self.logWindow.scrollFrame:SetPoint("BOTTOMRIGHT", 0, 10)
    self.logWindow.scrollChild = CreateFrame("Frame")
    self.logWindow.scrollChild:SetSize(580, 1000)
    self.logWindow.scrollFrame:SetScrollChild(self.logWindow.scrollChild)
    -- Создаем строки для отображения логов
    self.logRows = {}
    for i = 1, 2000 do
        local row = CreateFrame("Frame", "GpDbLogRow"..i, self.logWindow.scrollChild)
        row:SetSize(580, 40)
        row:SetPoint("TOPLEFT", 0, -((i-1)*40))
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.text:SetAllPoints(true)
        row.text:SetJustifyH("LEFT")
        row.text:SetJustifyV("TOP")
        row.text:SetWordWrap(true)
        row.text:SetText("")
        self.logRows[i] = row
    end
end

function GpDb:ClearLog()
    -- Очищаем данные лога
    self.logData = {}
    
    -- Очищаем фильтры
    self.logWindow.countFilter:SetText("Кол-во")
    self.logWindow.timeFilter:SetText("День")
    self.logWindow.rlFilter:SetText("РЛ")
    self.logWindow.raidFilter:SetText("Рейд")
    self.logWindow.nameFilter:SetText("Ник")
    
    -- Обновляем отображение
    self:UpdateLogDisplay()
    
    print("|cFFFF0000ГП:|r Лог успешно очищен")
end

function GpDb:_CreateWindow()
    -- Создаем основной фрейм окна
    self.window = CreateFrame("Frame", "GpTrackerWindow", UIParent)
    self.window:SetFrameStrata("DIALOG")
    self.window:SetSize(400, 600) -- Увеличена высота для размещения фильтра
    self.window:SetPoint("LEFT", 5, 100)
    self.window:SetMovable(true)
    self.window:EnableMouse(true)
    self.window:RegisterForDrag("LeftButton")
    self.window:SetScript("OnDragStart", self.window.StartMoving)
    self.window:SetScript("OnDragStop", self.window.StopMovingOrSizing)
    self.window:Hide()
    -- 1. Непрозрачный чёрный фон
    self.window.background = self.window:CreateTexture(nil, "BACKGROUND")
    self.window.background:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.window.background:SetVertexColor(0, 0, 0)
    self.window.background:SetAlpha(1)
    self.window.background:SetAllPoints(true)
    -- 2. Граница окна
    self.window.borderFrame = CreateFrame("Frame", nil, self.window)
    self.window.borderFrame:SetPoint("TOPLEFT", -3, 3)
    self.window.borderFrame:SetPoint("BOTTOMRIGHT", 3, -3)
    self.window.borderFrame:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    -- 3. Заголовок окна
    self.window.title = self.window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.window.title:SetPoint("TOP", 0, -15)
    self.window.title:SetText("")
    -- 4. Кнопка закрытия
    self.window.closeButton = CreateFrame("Button", nil, self.window, "UIPanelCloseButton")
    self.window.closeButton:SetPoint("TOPRIGHT", -5, -5)
    self.window.closeButton:SetScript("OnClick", function() self.window:Hide() end)
    -- 4.1 Кнопка логов (справа от кнопки закрытия)
    self.window.logButton = CreateFrame("Button", nil, self.window, "UIPanelButtonTemplate")
    self.window.logButton:SetSize(24, 24)
    self.window.logButton:SetPoint("RIGHT", self.window.closeButton, "LEFT", -5, 0)
    self.window.logButton:SetText("L")
    self.window.logButton:SetScript("OnClick", function() 
        self:ToggleLogWindow() 
    end)
    -- 5. Чекбокс "Только рейд"
    self.window.raidOnlyCheckbox = CreateFrame("CheckButton", nil, self.window, "UICheckButtonTemplate")
    self.window.raidOnlyCheckbox:SetPoint("TOPLEFT", 10, -15)
    self.window.raidOnlyCheckbox:SetSize(24, 24)
    self.window.raidOnlyCheckbox.text = self.window.raidOnlyCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.window.raidOnlyCheckbox.text:SetPoint("LEFT", self.window.raidOnlyCheckbox, "RIGHT", 5, 0)
    self.window.raidOnlyCheckbox.text:SetText("Только рейд")
    self.window.raidOnlyCheckbox:SetScript("OnClick", function()
        if self.window.raidOnlyCheckbox:GetChecked() then
            self.window.guildCheckbox:SetChecked(false)
            self.window.guildCheckbox:Disable()
            self.window.offCheckbox:SetChecked(false)
            self.window.offCheckbox:Disable()
        else
            self.window.guildCheckbox:Enable()
        end
        self:_UpdateFromGuild()
        self:UpdateWindow()
    end)
    -- 5.0.5 Чекбокс "Гильдия"
    self.window.guildCheckbox = CreateFrame("CheckButton", nil, self.window, "UICheckButtonTemplate")
    self.window.guildCheckbox:SetPoint("LEFT", self.window.raidOnlyCheckbox.text, "RIGHT", 10, 0)
    self.window.guildCheckbox:SetSize(24, 24)
    self.window.guildCheckbox.text = self.window.guildCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.window.guildCheckbox.text:SetPoint("LEFT", self.window.guildCheckbox, "RIGHT", 5, 0)
    self.window.guildCheckbox.text:SetText("Гильдия")
    self.window.guildCheckbox:SetScript("OnClick", function()
        if self.window.guildCheckbox:GetChecked() then
            self.window.offCheckbox:Enable()
        else
            self.window.offCheckbox:SetChecked(false)
            self.window.offCheckbox:Disable()
        end
        self:_UpdateFromGuild()
        self:UpdateWindow()
    end)
    -- 5.0.6 Чекбокс "Off"
    self.window.offCheckbox = CreateFrame("CheckButton", nil, self.window, "UICheckButtonTemplate")
    self.window.offCheckbox:SetPoint("LEFT", self.window.guildCheckbox.text, "RIGHT", 10, 0)
    self.window.offCheckbox:SetSize(24, 24)
    self.window.offCheckbox.text = self.window.offCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.window.offCheckbox.text:SetPoint("LEFT", self.window.offCheckbox, "RIGHT", 5, 0)
    self.window.offCheckbox.text:SetText("Off")
    self.window.offCheckbox:Disable()
    self.window.offCheckbox:SetScript("OnClick", function()
        self:_UpdateFromGuild()
        self:UpdateWindow()
    end)
    -- 5.1 Поле фильтрации по нику
    self.window.filterLabel = self.window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.window.filterLabel:SetPoint("TOPLEFT", self.window.raidOnlyCheckbox, "BOTTOMLEFT", 0, -10)
    self.window.filterLabel:SetText("Фильтр:")
    self.window.filterEditBox = CreateFrame("EditBox", nil, self.window, "InputBoxTemplate")
    self.window.filterEditBox:SetPoint("TOPLEFT", self.window.filterLabel, "BOTTOMLEFT", 0, -5)
    self.window.filterEditBox:SetPoint("RIGHT", self.window.closeButton, "LEFT", -40, 0)
    self.window.filterEditBox:SetHeight(20)
    self.window.filterEditBox:SetAutoFocus(false)
    self.window.filterEditBox:SetText("")
    self.window.filterEditBox:SetScript("OnTextChanged", function(editBox)
        self.filterText = editBox:GetText():lower()
        self:_UpdateFromGuild()
    end)
    self.window.filterEditBox:SetScript("OnEscapePressed", function() 
        self.window.filterEditBox:SetText("")
        self.window.filterEditBox:ClearFocus() 
    end)
    self.window.filterEditBox:SetScript("OnEnterPressed", function() 
        self.window.filterEditBox:ClearFocus() 
    end)
    -- 5.2 Кнопка очистки фильтра
    self.window.filterClearButton = CreateFrame("Button", nil, self.window, "UIPanelButtonTemplate")
    self.window.filterClearButton:SetSize(80, 22)
    self.window.filterClearButton:SetPoint("TOPRIGHT", self.window.filterEditBox, "BOTTOMRIGHT", 60, 20)
    self.window.filterClearButton:SetText("Очистить")
    self.window.filterClearButton:SetScript("OnClick", function()
        self.window.filterEditBox:SetText("")
        self.filterText = ""
        self:_UpdateFromGuild()
    end)
    -- 6. Область с прокруткой
    self.window.scrollFrame = CreateFrame("ScrollFrame", "ScrollFrame", self.window, "UIPanelScrollFrameTemplate")
    self.window.scrollFrame:SetPoint("TOPLEFT", 0, -85)  -- Больший отступ сверху
    self.window.scrollFrame:SetPoint("BOTTOMRIGHT", 0, 60)  -- Больший отступ снизу
    self.window.scrollChild = CreateFrame("Frame")
    self.window.scrollChild:SetSize(380, 500)
    self.window.scrollFrame:SetScrollChild(self.window.scrollChild)
    -- 7. Ползунок прокрутки
    self.window.scrollBar = _G[self.window.scrollFrame:GetName().."ScrollBar"]
    self.window.scrollBar:SetPoint("TOPLEFT", self.window.scrollFrame, "TOPRIGHT", -20, -16)
    self.window.scrollBar:SetPoint("BOTTOMLEFT", self.window.scrollFrame, "BOTTOMRIGHT", -20, 16)
    -- 8. Строка с количеством отображаемых игроков
    self.window.countText = self.window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.window.countText:SetPoint("BOTTOMLEFT", 10, 40)
    self.window.countText:SetPoint("BOTTOMRIGHT", -10, 40)
    self.window.countText:SetJustifyH("LEFT")
    self.window.countText:SetText("")
    -- 9. Строка с общим количеством игроков с ГП
    self.window.totalText = self.window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.window.totalText:SetPoint("BOTTOMLEFT", 10, 20)
    self.window.totalText:SetPoint("BOTTOMRIGHT", -10, 20)
    self.window.totalText:SetJustifyH("LEFT")
    self.window.totalText:SetText("")
    -- 10. Настройка таблицы
    self:_SetupTable()
end

function GpDb:_SetupTable()
    -- Исправляем заголовки для правильной сортировки
    local headers = {
        {text = "Ник", column = "nick"},
        {text = "ГП", column = "gp"}
    }
    
    for i, header in ipairs(headers) do
        local btn = CreateFrame("Button", nil, self.window.scrollChild)
        btn:SetSize(i == 1 and 290 or 50, 20)
        btn:SetPoint("TOPLEFT", (i-1)*290 + (i == 2 and 10 or 0), -5) -- Добавляем отступ сверху
        btn:SetNormalFontObject("GameFontNormal")
        btn:SetHighlightFontObject("GameFontHighlight")
        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetAllPoints(true)
        text:SetText(header.text)
        btn:SetScript("OnClick", function()
            self:SortData(header.column)
            self:UpdateWindow()
        end)
    end

    -- Создаем строки таблицы с системой выделения
    self.rows = {}
    for i = 1, 999 do
        local row = CreateFrame("Button", "GpDbRow"..i, self.window.scrollChild)
        row:SetSize(350, 20)
        row:SetPoint("TOPLEFT", 0, -25 - (i-1)*25)
        
        -- Настройки для кликов
        row:EnableMouse(true)
        row:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        
        -- Текстура для выделения
        row:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
        row:GetHighlightTexture():SetVertexColor(0.4, 0.4, 0.8, 0.4)
        
        -- Текстура для выбранного состояния
        row.selection = row:CreateTexture(nil, "BACKGROUND")
        row.selection:SetAllPoints(true)
        row.selection:SetTexture("Interface\\Buttons\\WHITE8X8")
        row.selection:SetVertexColor(0.3, 0.3, 0.7, 0.7)
        row.selection:Hide()
        
        -- Поля текста
        row.nick = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.nick:SetPoint("LEFT", 10, 0)
        row.nick:SetWidth(290)
        row.nick:SetJustifyH("LEFT")

        row.gp = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.gp:SetPoint("RIGHT", 5, 0)
        row.gp:SetWidth(50)
        row.gp:SetJustifyH("RIGHT")

        -- Переменная для отслеживания времени последнего клика
        row.lastClickTime = 0
        
        -- Обработчик кликов
        row:SetScript("OnClick", function(_, button, down)
            local offset = FauxScrollFrame_GetOffset(self.window.scrollFrame)
            local dataIndex = i + offset
            -- Проверяем валидность данных
            if not self.gp_data or not self.gp_data[dataIndex] then return end
            -- Получаем текущее время
            local currentTime = GetTime()
            -- Проверяем двойной клик (только ЛКМ и только если в рейде)
            if button == "LeftButton" and IsInRaid() and (currentTime - row.lastClickTime) < 0.5 then
                -- Двойной клик - выделяем все элементы
                self:ClearSelection()
                for idx = 1, #self.gp_data do
                    self.selected_indices[idx] = true
                end
                self.last_selected_index = dataIndex
                -- Обновляем интерфейс
                self:_UpdateSelectionCount()
                self:RefreshRowHighlights()
                self:UpdateRaidWindowVisibility()
                -- Обновляем список выбранных игроков
                if self.raidWindow and self.raidWindow:IsShown() then
                    self:_UpdateSelectedPlayersText()
                end
                -- Сбрасываем время клика
                row.lastClickTime = 0
                return
            end
            -- Запоминаем время клика для проверки двойного клика
            row.lastClickTime = currentTime
            if button == "LeftButton" then
                local wasSelected = self.selected_indices[dataIndex]
                -- SHIFT+ЛКМ - выделение диапазона
                if IsShiftKeyDown() then
                    if not self.last_selected_index then
                        self:ClearSelection()
                        self.selected_indices[dataIndex] = true
                        self.last_selected_index = dataIndex
                    else
                        local startIdx = math.min(self.last_selected_index, dataIndex)
                        local endIdx = math.max(self.last_selected_index, dataIndex)
                        if not IsControlKeyDown() then
                            self:ClearSelection()
                        end
                        for idx = startIdx, endIdx do
                            if self.gp_data[idx] then
                                self.selected_indices[idx] = true
                            end
                        end
                    end
                -- CTRL+ЛКМ - добавление/удаление из выделения
                elseif IsControlKeyDown() then
                    -- Изменяем состояние выделения
                    self.selected_indices[dataIndex] = not wasSelected
                    -- Очищаем несуществующие выделения
                    for idx in pairs(self.selected_indices) do
                        if not self.gp_data[idx] then
                            self.selected_indices[idx] = nil
                        end
                    end
                    -- Обновляем last_selected_index
                    if self.selected_indices[dataIndex] then
                        self.last_selected_index = dataIndex
                    else
                        self.last_selected_index = nil
                        for idx in pairs(self.selected_indices) do
                            if self.selected_indices[idx] then
                                self.last_selected_index = idx
                                break
                            end
                        end
                    end
                -- Обычный клик
                else
                    if wasSelected then
                        self:ClearSelection()
                    else
                        self:ClearSelection()
                        self.selected_indices[dataIndex] = true
                        self.last_selected_index = dataIndex
                    end
                end
                -- Принудительное обновление интерфейса
                self:_UpdateSelectionCount()
                self:RefreshRowHighlights()
                self:UpdateRaidWindowVisibility()
                -- Обновляем список выбранных игроков
                if self.raidWindow and self.raidWindow:IsShown() then
                    self:_UpdateSelectedPlayersText()
                end
            end
        end)

        self.rows[i] = row
    end

    -- Модифицируем обработчик скрытия окна
    self.window:SetScript("OnHide", function()
        -- Сбрасываем выделение
        self:ClearSelection()
        -- Скрываем окно рейда, если оно было открыто
        if self.raidWindow and self.raidWindow:IsShown() then
            self.raidWindow:Hide()
        end
        -- Скрываем окно логов, если оно было открыто
        if self.logWindow and self.logWindow:IsShown() then
            self.logWindow:Hide()
        end
    end)
end

function GpDb:ToggleLogWindow()
    if not self.logWindow then
        self:_CreateLogWindow()
    end
    if self.logWindow:IsShown() then
        self.logWindow:Hide()
    else
        self.logWindow:Show()
        local selectedCodes = {}
        for index in pairs(self.selected_indices) do
            if self.gp_data[index] and self.gp_data[index].playerID then
                table.insert(selectedCodes, self.gp_data[index].playerID)
            end
        end
        if #selectedCodes > 0 then
            local codeFilter = table.concat(selectedCodes, "_")
            print("|cFF00FF00[Клиент] Запрос логов по кодам игроков:|r", codeFilter)
            self:ClearLog()
            -- Отправляем ПУСТЫЕ значения для первых 4 полей, коды — в 5-м
            SendAddonMessage("NSShowMeLogs", "    " .. codeFilter, "GUILD")
        else
            self:UpdateLogDisplay()
        end
        if self.raidWindow and self.raidWindow:IsShown() then
            self.logWindow:SetHeight(self.window:GetHeight() / 2)
        else
            self.logWindow:SetHeight(self.window:GetHeight())
        end
    end
end

function GpDb:UpdateLogDisplay()
    if not self.logWindow or not self.logWindow:IsShown() then return end
    
    -- Вычисляем общую высоту
    local totalHeight = 0
    local rowHeights = {}
    
    -- Сначала вычисляем высоту всех строк
    for i, entry in ipairs(self.logData) do
        local tempText = self.logWindow.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tempText:SetWidth(580)
        tempText:SetText(entry.text)
        tempText:SetWordWrap(true)
        local textHeight = tempText:GetStringHeight() + 5
        rowHeights[i] = textHeight
        totalHeight = totalHeight + textHeight
        tempText:Hide()
    end

    -- Позиционируем строки (старые сверху, новые снизу)
    local currentY = 0
    for i = 1, #self.logRows do
        local dataIndex = i -- Отображаем записи по порядку (1=самая старая)
        if dataIndex <= #self.logData then
            local entry = self.logData[dataIndex]
            local textHeight = rowHeights[dataIndex]
            
            self.logRows[i]:SetHeight(textHeight)
            self.logRows[i]:SetPoint("TOPLEFT", 0, -currentY)
            self.logRows[i].text:SetText(entry.text)
            self.logRows[i]:Show()
            
            currentY = currentY + textHeight
        else
            self.logRows[i]:Hide()
        end
    end

    -- Обновляем высоту контента
    self.logWindow.scrollChild:SetHeight(totalHeight)
    self.logWindow.scrollFrame:UpdateScrollChildRect()
end

function GpDb:_UpdateSelectionCount()
    local count = 0
    -- Считаем ТОЛЬКО действительно выделенные и существующие элементы
    for idx, selected in pairs(self.selected_indices) do
        if selected and self.gp_data[idx] then
            count = count + 1
        else
            self.selected_indices[idx] = nil -- Очищаем невалидные
        end
    end
    
    -- Обновляем текст
    self.window.countText:SetText(string.format("Выделено: %d", count))
    
    -- Если нет выделений - сбрасываем last_selected_index
    if count == 0 then
        self.last_selected_index = nil
    end
    
    return count
end

function GpDb:IsValidIndex(index)
    return index and type(index) == "number" and self.gp_data and self.gp_data[index]
end

function GpDb:RefreshRowHighlights()
    local offset = FauxScrollFrame_GetOffset(self.window.scrollFrame)
    
    for i, row in ipairs(self.rows) do
        local dataIndex = i + offset
        if dataIndex <= #self.gp_data then
            if self.selected_indices[dataIndex] then
                row.selection:Show()
                row:GetHighlightTexture():SetAlpha(0.2) -- Снижаем прозрачность ховера при выделении
            else
                row.selection:Hide()
                row:GetHighlightTexture():SetAlpha(0.4) -- Возвращаем стандартную прозрачность
            end
        end
    end
    
    -- Обновляем счетчик выделенных
    local selectedCount = 0
    for _ in pairs(self.selected_indices) do selectedCount = selectedCount + 1 end
    self.window.countText:SetText(string.format("Выделено: %d", selectedCount))
end

function GpDb:ClearSelection()
    self.selected_indices = {}
    self.last_selected_index = nil
    self:_UpdateSelectionCount()
    self:RefreshRowHighlights()
    self:UpdateRaidWindowVisibility()
end

function GpDb:GetSelectedEntries()
    local selected = {}
    for index, _ in pairs(self.selected_indices) do
        if index <= #self.gp_data then
            table.insert(selected, self.gp_data[index])
        end
    end
    return selected
end

function GpDb:AddLogEntry(timeStr, gpValue, rl, raid, targets, isDecoded)
    -- Проверяем наличие окна логов
    if not self.logWindow then
        self:_CreateLogWindow()
    end

    local function GetClassColor(name)
        if not name or type(name) ~= "string" or name == "" then 
            return "|cFFFFFFFF" 
        end
        for i = 1, GetNumGuildMembers() do
            local guildName, _, _, _, _, _, _, _, _, _, classFileName = GetGuildRosterInfo(i)
            if guildName and guildName == name then
                local color = RAID_CLASS_COLORS[classFileName]
                if color then
                    return string.format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
                end
                break
            end
        end
        return "|cFFFFFFFF"
    end

    local gpNumValue = tonumber(gpValue) or 0
    local formattedTime = "|cFFA0A0A0" .. (timeStr or "??:??") .. "|r"
    local formattedRl = GetClassColor(rl) .. (rl or "Неизвестно") .. "|r"
    local gpColor = gpNumValue >= 0 and "|cFF00FF00" or "|cFFFF0000"
    local formattedGp = gpColor .. tostring(gpNumValue) .. "|r"
    local formattedRaid = "|cFFFFFF00" .. (raid or "Неизвестно") .. "|r"

    -- Форматируем цели
    local formattedTargets = {}
    if type(targets) == "string" then
        for word in targets:gmatch("%S+") do
            local playerName = word
            -- Декодируем ТОЛЬКО если это не серверная запись (isDecoded == nil или false)
            if not isDecoded then
                -- Пытаемся найти имя по коду в officerNote
                for i = 1, GetNumGuildMembers() do
                    local name, _, _, _, _, _, _, officerNote = GetGuildRosterInfo(i)
                    if name and officerNote then
                        local words = {}
                        for w in officerNote:gmatch("%S+") do
                            table.insert(words, w)
                        end
                        if #words >= 2 and words[2] == word then
                            playerName = name
                            break
                        end
                    end
                end
            end
            table.insert(formattedTargets, GetClassColor(playerName) .. playerName .. "|r")
        end
    end
    local formattedTargetsText = table.concat(formattedTargets, " ")

    local logText = string.format("%s | %s | %s | %s | %s", 
        formattedTime, 
        formattedRl,
        formattedGp,
        formattedRaid, 
        formattedTargetsText)

    table.insert(self.logData, {
        text = logText,
        raw = {
            time = timeStr,
            rl = rl,
            gp = gpNumValue,
            raid = raid,
            targets = targets
        }
    })

    if #self.logData > 2000 then
        table.remove(self.logData, 1)
    end

    if self.logWindow and self.logWindow:IsShown() then
        self:UpdateLogDisplay()
        self.logWindow.scrollFrame:SetVerticalScroll(self.logWindow.scrollFrame:GetVerticalScrollRange())
    end
end

function GpDb:UpdateRaidWindowVisibility()
    if not self.raidWindow then return end
    -- Проверяем звание игрока
    local hasOfficerRank = self:_CheckOfficerRank()
    if not hasOfficerRank then
        if self.raidWindow:IsShown() then
            self.raidWindow:Hide()
            -- Восстанавливаем полный размер окна логов
            if self.logWindow and self.logWindow:IsShown() then
                self.logWindow:SetHeight(self.window:GetHeight())
            end
        end
        return
    end
    local hasSelection = next(self.selected_indices) ~= nil
    if not hasSelection then
        if self.raidWindow:IsShown() then
            self.raidWindow:Hide()
            -- Восстанавливаем полный размер окна логов
            if self.logWindow and self.logWindow:IsShown() then
                self.logWindow:SetHeight(self.window:GetHeight())
            end
        end
        return
    end
    local inRaid = IsInRaid()
    local raidOnlyChecked = self.window.raidOnlyCheckbox:GetChecked()
    local shouldShow = not inRaid or raidOnlyChecked
    if shouldShow and inRaid then
        local raidMembers = {}
        for i = 1, GetNumGroupMembers() do
            local name = GetRaidRosterInfo(i)
            if name then
                raidMembers[name] = true
            end
        end
        for index in pairs(self.selected_indices) do
            local entry = self.gp_data[index]
            if entry and not raidMembers[entry.original_nick] then
                shouldShow = false
                print("|cFFFF0000ГП:|r Некоторые выделенные игроки не в рейде")
                break
            end
        end
    end
    if shouldShow then
        if not self.raidWindow:IsShown() then
            self.raidWindow:Show()
            self:RestoreRaidWindowState() -- Восстанавливаем состояния при показе
            self:_UpdateSelectedPlayersText() -- Обновляем список игроков
            -- Корректируем размер окна логов
            if self.logWindow and self.logWindow:IsShown() then
                self.logWindow:SetHeight(self.window:GetHeight() / 2)
            end
        end
    else
        if self.raidWindow:IsShown() then
            self.raidWindow:Hide()
        end
        -- Корректируем размер окна логов
        if self.logWindow and self.logWindow:IsShown() then
            self.logWindow:SetHeight(self.window:GetHeight())
        end
    end
    -- Обновляем информацию об игроке
    if self.raidWindow and self.raidWindow:IsShown() then
        self:_UpdatePlayerInfo()
    end
end

function GpDb:UpdateWindow()
    if not self.window or not self.rows then return end

    local offset = FauxScrollFrame_GetOffset(self.window.scrollFrame)
    
    -- Уменьшаем количество отображаемых строк
    local visibleRows = math.floor((self.window.scrollFrame:GetHeight() - 30) / 25)
    self.visible_rows = visibleRows
    
    for i = 1, self.visible_rows do
        local row = self.rows[i]
        local dataIndex = i + offset
        
        if dataIndex <= #self.gp_data then
            local entry = self.gp_data[dataIndex]
            
            -- Обновляем текст
            row.nick:SetText(entry.nick)
            row.gp:SetText(tostring(entry.gp))
            
            -- Цвета текста
            if entry.classColor then
                row.nick:SetTextColor(entry.classColor.r, entry.classColor.g, entry.classColor.b)
            else
                row.nick:SetTextColor(1, 1, 1)
            end
            
            row:Show()
        else
            row:Hide()
        end
    end

    -- Обновляем выделения
    self:RefreshRowHighlights()
    
    -- Обновление скролла
    FauxScrollFrame_Update(self.window.scrollFrame, #self.gp_data, self.visible_rows, 25)
    self:UpdateRaidWindowVisibility()
end

function GpDb:GetNumSelected()
    local count = 0
    for idx in pairs(self.selected_indices) do
        if self.gp_data[idx] then  -- Проверяем что элемент существует
            count = count + 1
        else
            self.selected_indices[idx] = nil  -- Очищаем несуществующие
        end
    end
    print(string.format("GetNumSelected: найдено %d элементов", count))
    return count
end

function GpDb:Show()
    self.window:Show()
    
    -- Автоматически устанавливаем галочку "Только рейд" если мы в рейде
    self.window.raidOnlyCheckbox:SetChecked(IsInRaid())
    
    self:_UpdateFromGuild()
    self:UpdateWindow()
end

function GpDb:Hide()
    self.window:Hide()
end

function GpDb:_UpdateFromGuild()
    -- Всегда начинаем с чистого списка
    self.gp_data = {}
    local totalWithGP = 0
    local totalMembers = GetNumGuildMembers()
    -- Синхронизируем галочку с текущим состоянием рейда
    local inRaid = IsInRaid()
    self.window.raidOnlyCheckbox:SetChecked(inRaid)
    local raidOnlyMode = inRaid and self.window.raidOnlyCheckbox:GetChecked()
    local showAllGuild = self.window.guildCheckbox:GetChecked()
    local showOfflineOnly = showAllGuild and self.window.offCheckbox:GetChecked()

    -- Блокировка галочки "Гильдия" и "Off", если включён "Только рейд"
    if raidOnlyMode then
        self.window.guildCheckbox:SetChecked(false)
        self.window.guildCheckbox:Disable()
        self.window.offCheckbox:SetChecked(false)
        self.window.offCheckbox:Disable()
    else
        self.window.guildCheckbox:Enable()
        if not showAllGuild then
            self.window.offCheckbox:SetChecked(false)
            self.window.offCheckbox:Disable()
        else
            self.window.offCheckbox:Enable()
        end
    end

    if not IsInGuild() then
        print("|cFFFF0000ГП:|r Вы не состоите в гильдии")
        self:UpdateWindow()
        return
    end

    -- Обновляем данные гильдии
    GuildRoster()

    -- Сохраняем self в локальную переменную для замыкания
    local db = self

    -- Для 3.3.5 используем простой таймер без возможности отмены
    local timerFrame = CreateFrame("Frame")
    timerFrame:SetScript("OnUpdate", function(selfFrame, elapsed)
        selfFrame.elapsed = (selfFrame.elapsed or 0) + elapsed
        if selfFrame.elapsed >= 0.01 then
            selfFrame:SetScript("OnUpdate", nil)

            -- Собираем полный список членов гильдии для быстрой проверки
            local guildRosterInfo = {}
            for j = 1, GetNumGuildMembers() do
                local name, _, _, _, _, _, publicNote, officerNote, _, _, classFileName = GetGuildRosterInfo(j)
                if name then
                    -- Удаляем серверную часть имени для уникальности
                    local plainName = name:match("^(.-)-") or name
                    -- Парсим офицерскую заметку для получения ID
                    local playerID = nil
                    if officerNote then
                        local words = {}
                        for word in officerNote:gmatch("%S+") do
                            table.insert(words, word)
                        end
                        if #words >= 2 then
                            playerID = words[2] -- Берем ID из второго слова
                        end
                    end
                    guildRosterInfo[plainName] = {
                        publicNote = publicNote,
                        officerNote = officerNote,
                        classFileName = classFileName,
                        playerID = playerID,
                        online = select(9, GetGuildRosterInfo(j))
                    }
                end
            end

            -- Режим "Только рейд" и мы в рейде
            if raidOnlyMode then
                local numRaidMembers = GetNumGroupMembers()
                local raidCheckPassed = true
                local invalidPlayers = {}
                -- Проверяем всех игроков рейда на принадлежность к гильдии
                for i = 1, numRaidMembers do
                    local raidName, _, _, _, _, classFileName = GetRaidRosterInfo(i)
                    if raidName then
                        -- Удаляем серверную часть имени для сравнения
                        local plainName = raidName:match("^(.-)-") or raidName
                        if not guildRosterInfo[plainName] then
                            raidCheckPassed = false
                            table.insert(invalidPlayers, raidName)
                        end
                    end
                end
                -- Если есть чужие игроки - сообщаем и выходим
                if not raidCheckPassed then
                    print("|cFFFF0000ГП:|r В рейде есть не члены гильдии: "..table.concat(invalidPlayers, ", "))
                    db.window.countText:SetText("Отображается игроков: 0 (в рейде есть не члены гильдии)")
                    db.window.totalText:SetText(string.format("Всего игроков с ГП: %d (из %d в гильдии)", totalWithGP, totalMembers))
                    db:UpdateWindow()
                    return
                end
                -- Заполняем данные ВСЕХ игроков рейда
                for i = 1, numRaidMembers do
                    local raidName, _, _, _, _, classFileName = GetRaidRosterInfo(i)
                    if raidName then
                        local plainName = raidName:match("^(.-)-") or raidName
                        local guildInfo = guildRosterInfo[plainName]
                        if guildInfo then
                            local gp = 0
                            local publicNote = guildInfo.publicNote or ""
                            -- Парсим ГП из officerNote
                            if guildInfo.officerNote then
                                local words = {}
                                for word in guildInfo.officerNote:gmatch("%S+") do
                                    table.insert(words, word)
                                end
                                if #words >= 3 then
                                    gp = tonumber(words[3]) or 0
                                end
                            end
                            if gp > 0 then
                                totalWithGP = totalWithGP + 1
                            end
                            local displayName = raidName
                            if publicNote and publicNote ~= "" then
                                displayName = raidName .. " |cFFFFFF00(" .. publicNote .. ")|r"
                            end
                            table.insert(db.gp_data, {
                                nick = displayName,
                                original_nick = plainName,
                                gp = gp,
                                classColor = RAID_CLASS_COLORS[classFileName] or {r=1, g=1, b=1},
                                classFileName = classFileName,
                                playerID = guildInfo.playerID
                            })
                        end
                    end
                end
            elseif showAllGuild then
                -- Режим "Гильдия": показываем всех членов гильдии
                for i = 1, GetNumGuildMembers() do
                    local name, _, _, _, _, _, publicNote, officerNote, _, _, classFileName = GetGuildRosterInfo(i)
                    local online = select(9, GetGuildRosterInfo(i))
                    if name then
                        -- === ИСПРАВЛЕННАЯ ЛОГИКА ФИЛЬТРАЦИИ ===
                        if not showOfflineOnly and not online then
                            -- Пропускаем офлайн, если "Off" выключена
                        else
                            -- Отображаем: всех, если "Off" включена; только онлайн — если выключена
                            local plainName = name:match("^(.-)-") or name
                            local gp = 0
                            local playerID = nil
                            if officerNote then
                                local words = {}
                                for word in officerNote:gmatch("%S+") do
                                    table.insert(words, word)
                                end
                                if #words >= 3 then
                                    gp = tonumber(words[3]) or 0
                                end
                                if #words >= 2 then
                                    playerID = words[2]
                                end
                            end
                            if gp > 0 then
                                totalWithGP = totalWithGP + 1
                            end
                            local displayName = name
                            if publicNote and publicNote ~= "" then
                                displayName = name .. " |cFFFFFF00(" .. publicNote .. ")|r"
                            end
                            table.insert(db.gp_data, {
                                nick = displayName,
                                original_nick = plainName,
                                gp = gp,
                                classColor = RAID_CLASS_COLORS[classFileName] or {r=1, g=1, b=1},
                                classFileName = classFileName,
                                playerID = playerID
                            })
                        end
                    end
                end
            else
                -- Обычный режим - показываем только игроков с ГП
                for i = 1, GetNumGuildMembers() do
                    local name, _, _, _, _, _, publicNote, officerNote, _, _, classFileName = GetGuildRosterInfo(i)
                    if name and officerNote and officerNote ~= "" then
                        -- Удаляем серверную часть имени
                        local plainName = name:match("^(.-)-") or name
                        local words = {}
                        for word in officerNote:gmatch("%S+") do
                            table.insert(words, word)
                        end
                        if #words >= 3 then
                            local gp = tonumber(words[3]) or 0
                            local playerID = words[2]
                            if gp ~= 0 then
                                totalWithGP = totalWithGP + 1
                                local displayName = name
                                if publicNote and publicNote ~= "" then
                                    displayName = name .. " |cFFFFFF00(" .. publicNote .. ")|r"
                                end
                                table.insert(db.gp_data, {
                                    nick = displayName,
                                    original_nick = plainName,
                                    gp = gp,
                                    classColor = RAID_CLASS_COLORS[classFileName] or {r=1, g=1, b=1},
                                    classFileName = classFileName,
                                    playerID = playerID
                                })
                            end
                        end
                    end
                end
            end

            -- Применяем фильтр
            if db.filterText and db.filterText ~= "" then
                local filteredData = {}
                for _, entry in ipairs(db.gp_data) do
                    local nickMatch = string.find(entry.original_nick:lower(), db.filterText, 1, true)
                    local displayMatch = string.find(entry.nick:lower(), db.filterText, 1, true)
                    if nickMatch or displayMatch then
                        table.insert(filteredData, entry)
                    end
                end
                db.gp_data = filteredData
            end

            -- Обновляем UI
            db.window.countText:SetText(string.format("Отображается игроков: %d", #db.gp_data))
            db.window.totalText:SetText(string.format("Всего игроков с ГП: %d (из %d в гильдии)", totalWithGP, GetNumGuildMembers()))
            db:ClearSelection()
            db:SortData()
            db:UpdateWindow()
        end
    end)
end

function GpDb:Show()
    self.window:Show()
    
    -- Автоматически включаем режим "Только рейд" если мы в рейде
    if IsInRaid() then
        self.window.raidOnlyCheckbox:SetChecked(true)
    else
        self.window.raidOnlyCheckbox:SetChecked(false)
    end
    
    -- Принудительно обновляем данные гильдии перед показом
    GuildRoster()
    C_Timer(0.01, function()
        self:_UpdateFromGuild()
        self:UpdateWindow()
    end)
end

function GpDb:AddGpEntry(nick, gp, playerID)
    table.insert(self.gp_data, {
        nick = nick,
        original_nick = nick,
        gp = tonumber(gp) or 0,
        playerID = playerID -- Добавляем ID игрока
    })
    self:SortData()
    self:UpdateWindow()
end

function GpDb:UpdateGpEntry(nick, new_gp)
    for _, entry in ipairs(self.gp_data) do
        if entry.original_nick == nick then
            entry.gp = tonumber(new_gp) or 0
            break
        end
    end
    self:SortData()
    self:UpdateWindow()
end

function GpDb:RemoveGpEntry(nick)
    for i, entry in ipairs(self.gp_data) do
        if entry.original_nick == nick then
            table.remove(self.gp_data, i)
            break
        end
    end
    self:UpdateWindow()
end

function GpDb:FindGpEntry(nick)
    for _, entry in ipairs(self.gp_data) do
        if entry.original_nick == nick then
            return entry.gp
        end
    end
    return nil
end

function GpDb:ClearAll()
    self.gp_data = {}
    self:UpdateWindow()
end

function GpDb:SortData(column)
    if column then
        if self.sort_column == column then
            self.sort_ascending = not self.sort_ascending
        else
            self.sort_column = column
            self.sort_ascending = true
        end
    end

    table.sort(self.gp_data, function(a, b)
        local valA, valB
        
        if self.sort_column == "nick" then
            -- Используем оригинальное имя для сортировки
            valA = string.lower(a.original_nick or "")
            valB = string.lower(b.original_nick or "")
        else
            valA = a.gp or 0
            valB = b.gp or 0
        end

        if self.sort_ascending then
            return valA < valB
        else
            return valA > valB
        end
    end)
    self:ClearSelection()
    self:UpdateWindow()
end

function GpDb:UpdateWindow()
    if not self.window or not self.rows then return end
    
    for i, row in ipairs(self.rows) do
        local entry = self.gp_data[i]
        if entry then
            row.nick:SetText(entry.nick)
            if entry.classColor then
                -- Применяем цвет класса только к имени (до скобок)
                local plainName = entry.nick:match("^[^|]+") or entry.nick
                row.nick:SetText(plainName)
                row.nick:SetTextColor(entry.classColor.r, entry.classColor.g, entry.classColor.b)
                
                -- Добавляем публичную заметку с желтым цветом
                local notePart = entry.nick:match("|c.+$")
                if notePart then
                    local fullText = row.nick:GetText() .. " " .. notePart
                    row.nick:SetText(fullText)
                end
            else
                row.nick:SetTextColor(1, 1, 1)
            end
            
            row.gp:SetText(tostring(entry.gp))
            row.gp:SetTextColor(1, 1, 1)
            
            row:Show()
        else
            row:Hide()
        end
    end
    
    self.window.scrollChild:SetHeight(#self.gp_data * 25)
    self.window.scrollFrame:UpdateScrollChildRect()
end

function GpDb:SaveToNsDb()
    for _, entry in ipairs(self.gp_data) do
        self.ns_db:addStaticStr("GP_DATA", entry.original_nick, nil, tostring(entry.gp))
    end
end

function GpDb:LoadFromNsDb()
    self.gp_data = {}
    local data = self.ns_db.input_table["GP_DATA"]
    if data then
        for nick, gp in pairs(data) do
            table.insert(self.gp_data, {
                nick = nick,
                original_nick = nick,
                gp = tonumber(gp) or 0
            })
        end
    end
    self:SortData()
    self:UpdateWindow()
end

function GpDb:_CreateRaidSelectionWindow()
    -- Создаем основное окно
    self.raidWindow = CreateFrame("Frame", "GpDbRaidWindow", self.window)
    self.raidWindow:SetFrameStrata("DIALOG")
    self.raidWindow:SetSize(500, self.window:GetHeight() * 0.5)
    self.raidWindow:SetPoint("BOTTOMLEFT", self.window, "BOTTOMRIGHT", 5, 0)
    self.raidWindow:SetMovable(false)
    -- Фон окна — ИСПРАВЛЕНО: используем CreateTexture
    self.raidWindow.background = self.raidWindow:CreateTexture(nil, "BACKGROUND")
    self.raidWindow.background:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.raidWindow.background:SetVertexColor(0, 0, 0)
    self.raidWindow.background:SetAlpha(1)
    self.raidWindow.background:SetAllPoints(true)
    -- Граница окна
    self.raidWindow.borderFrame = CreateFrame("Frame", nil, self.raidWindow)
    self.raidWindow.borderFrame:SetPoint("TOPLEFT", -3, 3)
    self.raidWindow.borderFrame:SetPoint("BOTTOMRIGHT", 3, -3)
    self.raidWindow.borderFrame:SetBackdrop({
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        insets = {left = 4, right = 4, top = 4, bottom = 4}
    })
    -- Кнопка закрытия
    self.raidWindow.closeButton = CreateFrame("Button", nil, self.raidWindow, "UIPanelCloseButton")
    self.raidWindow.closeButton:SetPoint("TOPRIGHT", -5, -5)
    self.raidWindow.closeButton:SetScript("OnClick", function() 
        self.raidWindow:Hide() 
    end)
    -- Выпадающий список рейдов
    self.raidWindow.dropdown = CreateFrame("Frame", "GpDbRaidDropdown", self.raidWindow, "UIDropDownMenuTemplate")
    self.raidWindow.dropdown:SetPoint("TOPLEFT", 10, -10)
    self.raidWindow.dropdown:SetPoint("RIGHT", -260, 0)
    self.raidWindow.dropdown:SetHeight(32)
    -- Функция обновления текста в выпадающем списке
    local function UpdateDropdownText()
        if self.raidWindow.selectedRaidId then
            for i = 1, GetNumSavedInstances() do
                local name, id = GetSavedInstanceInfo(i)
                if id == self.raidWindow.selectedRaidId then
                    UIDropDownMenu_SetText(self.raidWindow.dropdown, string.format("%d: %s", id, name))
                    return
                end
            end
        else
            UIDropDownMenu_SetText(self.raidWindow.dropdown, "Выберите рейд")
        end
    end
    -- Функция инициализации выпадающего списка
    local function InitializeDropdown(frame, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        for i = 1, GetNumSavedInstances() do
            local name, id, _, _, _, _, _, _, players = GetSavedInstanceInfo(i)
            if name and id then
                info.text = string.format("%d: %s (%d)", id, name, players)
                info.arg1 = {id = id, name = name, players = players}
                info.func = function(_, arg1)
                    self.raidWindow.selectedRaidId = arg1.id
                    self.raidWindow.selectedRaidName = arg1.name
                    self.raidWindow.selectedRaidPlayers = arg1.players
                    if self.saveSelectionEnabled then
                        self.lastSelectionType = "raid"
                        self.lastRaidId = arg1.id
                        self.lastRaidName = arg1.name
                        self.lastRaidPlayers = arg1.players
                    end
                    UpdateDropdownText()
                    self.raidWindow.editBox:SetText("")
                end
                info.checked = (self.raidWindow.selectedRaidId == id)
                UIDropDownMenu_AddButton(info)
            end
        end
        info.text = "Очистить выбор"
        info.func = function()
            self.raidWindow.selectedRaidId = nil
            self.raidWindow.selectedRaidName = nil
            if self.saveSelectionEnabled then
                self.lastSelectionType = nil
                self.lastRaidId = nil
                self.lastRaidName = nil
                self.lastRaidPlayers = 0
            end
            UpdateDropdownText()
        end
        info.notCheckable = true
        UIDropDownMenu_AddButton(info)
    end
    UIDropDownMenu_Initialize(self.raidWindow.dropdown, InitializeDropdown)
    UIDropDownMenu_SetWidth(self.raidWindow.dropdown, 200)
    UIDropDownMenu_SetButtonWidth(self.raidWindow.dropdown, 224)
    UIDropDownMenu_JustifyText(self.raidWindow.dropdown, "LEFT")
    UpdateDropdownText()
    -- Текст "Другое"
    self.raidWindow.otherText = self.raidWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.raidWindow.otherText:SetPoint("TOPLEFT", self.raidWindow.dropdown, "BOTTOMLEFT", 0, -10)
    self.raidWindow.otherText:SetText("Другое:")
    -- Поле ввода "Другое"
    self.raidWindow.editBox = CreateFrame("EditBox", nil, self.raidWindow, "InputBoxTemplate")
    self.raidWindow.editBox:SetPoint("TOPLEFT", self.raidWindow.otherText, "BOTTOMLEFT", 0, -5)
    self.raidWindow.editBox:SetPoint("RIGHT", -260, 0)
    self.raidWindow.editBox:SetHeight(20)
    self.raidWindow.editBox:SetAutoFocus(false)
    self.raidWindow.editBox:SetScript("OnTextChanged", function(editBox)
        if editBox:GetText() ~= "" then
            if self.saveSelectionEnabled then
                self.lastSelectionType = "other"
                self.lastOtherText = editBox:GetText()
            end
            self.raidWindow.selectedRaidId = nil
            self.raidWindow.selectedRaidName = nil
            UpdateDropdownText()
        end
    end)
    -- Галочка "Сохранить выбор"
    self.raidWindow.saveCheckbox = CreateFrame("CheckButton", nil, self.raidWindow, "UICheckButtonTemplate")
    self.raidWindow.saveCheckbox:SetPoint("TOPLEFT", self.raidWindow.editBox, "BOTTOMLEFT", 0, -10)
    self.raidWindow.saveCheckbox:SetSize(24, 24)
    self.raidWindow.saveCheckbox.text = self.raidWindow.saveCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.raidWindow.saveCheckbox.text:SetPoint("LEFT", self.raidWindow.saveCheckbox, "RIGHT", 5, 0)
    self.raidWindow.saveCheckbox.text:SetText("Сохранить выбор")
    self.raidWindow.saveCheckbox:SetChecked(true)
    self.saveSelectionEnabled = true
    self.raidWindow.saveCheckbox:SetScript("OnClick", function()
        self.saveSelectionEnabled = self.raidWindow.saveCheckbox:GetChecked()
    end)
    -- Текст с выбранными игроками
    self.raidWindow.selectedPlayersText = self.raidWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    self.raidWindow.selectedPlayersText:SetPoint("TOPLEFT", self.raidWindow.saveCheckbox, "BOTTOMLEFT", 0, -5)
    self.raidWindow.selectedPlayersText:SetPoint("RIGHT", -260, 0)
    self.raidWindow.selectedPlayersText:SetHeight(70)
    self.raidWindow.selectedPlayersText:SetJustifyH("LEFT")
    self.raidWindow.selectedPlayersText:SetJustifyV("TOP")
    self.raidWindow.selectedPlayersText:SetWordWrap(true)
    -- Кнопки быстрого ввода ГП
    local quickGPValues = {5, 10, 20, 25, 50, 100}
    local lastQuickButton
    for i, value in ipairs(quickGPValues) do
        local btn = CreateFrame("Button", nil, self.raidWindow, "UIPanelButtonTemplate")
        btn:SetSize(27, 20)
        btn:SetText(tostring(value))
        if i == 1 then
            btn:SetPoint("BOTTOMLEFT", self.raidWindow.selectedPlayersText, "BOTTOMLEFT", 0, -20)
        else
            btn:SetPoint("LEFT", lastQuickButton, "RIGHT", 2, 0)  -- уменьшен отступ до 2
        end
        btn:SetScript("OnClick", function()
            self.raidWindow.gpEditBox:SetText(tostring(value))
            self.raidWindow.gpEditBox:HighlightText()
        end)
        lastQuickButton = btn
    end
    -- Кнопка минуса
    local minusBtn = CreateFrame("Button", nil, self.raidWindow, "UIPanelButtonTemplate")
    minusBtn:SetSize(40, 22)
    minusBtn:SetText("-/+")
    minusBtn:SetPoint("LEFT", lastQuickButton, "RIGHT", 2, 0)  -- уменьшен отступ до 2
    minusBtn:SetScript("OnClick", function()
        local currentValue = tonumber(self.raidWindow.gpEditBox:GetText()) or 0
        self.raidWindow.gpEditBox:SetText(tostring(-currentValue))
        self.raidWindow.gpEditBox:HighlightText()
    end)
    lastQuickButton = minusBtn

    -- Кнопка процента
    local percentBtn = CreateFrame("Button", nil, self.raidWindow, "UIPanelButtonTemplate")
    percentBtn:SetSize(27, 20)
    percentBtn:SetText("%")
    percentBtn:SetPoint("LEFT", lastQuickButton, "RIGHT", 2, 0)  -- уменьшен отступ до 2
    percentBtn:SetScript("OnClick", function()
        local inputText = self.raidWindow.gpEditBox:GetText()
        local percentValue = tonumber(inputText)
        if not percentValue or percentValue <= 0 then
            print("|cFFFF0000ГП:|r Укажите положительное число для процента")
            return
        end

        local selected = self:GetSelectedEntries()
        if #selected ~= 1 then
            print("|cFFFF0000ГП:|r Процент можно применить только к одному игроку")
            return
        end

        local playerGp = selected[1].gp or 0
        local newGp = math.floor(playerGp * percentValue / 100)
        self.raidWindow.gpEditBox:SetText(tostring(newGp))
        self.raidWindow.gpEditBox:HighlightText()
    end)

    -- Поле ввода ГП
    self.raidWindow.gpEditBox = CreateFrame("EditBox", nil, self.raidWindow, "InputBoxTemplate")
    self.raidWindow.gpEditBox:SetPoint("BOTTOMLEFT", 10, 5)
    self.raidWindow.gpEditBox:SetSize(100, 20)
    self.raidWindow.gpEditBox:SetAutoFocus(false)
    self.raidWindow.gpEditBox:SetScript("OnEscapePressed", function() self.raidWindow.gpEditBox:ClearFocus() end)
    self.raidWindow.gpEditBox:SetScript("OnEnterPressed", function() self.raidWindow.gpEditBox:ClearFocus() end)
    -- Кнопка "Начислить"
    self.raidWindow.awardButton = CreateFrame("Button", nil, self.raidWindow, "UIPanelButtonTemplate")
    self.raidWindow.awardButton:SetPoint("BOTTOMRIGHT", -10, 5)
    self.raidWindow.awardButton:SetSize(100, 22)
    self.raidWindow.awardButton:SetText("Начислить")
    self.raidWindow.awardButton:SetScript("OnClick", function()
        if not self:_CheckOfficerRank() then
            print("|cFFFF0000ГП:|r Только офицеры могут начислять ГП")
            self.raidWindow:Hide()
            return
        end
        if next(self.selected_indices) == nil then
            print("|cFFFF0000ГП:|r Нет выделенных игроков")
            self.raidWindow:Hide()
            return
        end
        local gpValue = tonumber(self.raidWindow.gpEditBox:GetText())
        if not gpValue then
            print("|cFFFF0000ГП:|r Укажите значение ГП")
            return
        end
        if not self.raidWindow.selectedRaidId and not (self.lastOtherText or ""):match("%S") then
            print("|cFFFF0000ГП:|r Нужно выбрать рейд или указать причину")
            return
        end
        if not self.saveSelectionEnabled then
            self.lastSelectionType = nil
            self.lastRaidId = nil
            self.lastRaidName = nil
            self.lastRaidPlayers = 0
            self.lastOtherText = nil
            self.lastGPValue = 0
        else
            self.lastGPValue = gpValue
        end
        local logStr
        if self.raidWindow.selectedRaidId then
            local cleanRaidName = (self.raidWindow.selectedRaidName or ""):gsub("%s+", "_")
            logStr = string.format("%04d_%s_%d %d", 
                self.raidWindow.selectedRaidId, 
                cleanRaidName, 
                self.raidWindow.selectedRaidPlayers or 0,
                gpValue)
        else
            local cleanOtherText = (self.lastOtherText or ""):gsub("%s+", "_")
            logStr = string.format("%s %d", cleanOtherText, gpValue)
        end
        for index in pairs(self.selected_indices) do
            if self.gp_data[index] then
                local nick = self.gp_data[index].original_nick
                local playerID = self.gp_data[index].playerID or "UNKNOWN"
                SendAddonMessage("nsGP1" .. " " .. gpValue, nick, "guild")
                logStr = logStr .. " " .. playerID
                self:AddLogEntry(gpValue, date("%H:%M"), UnitName("player"), 
                    self.raidWindow.selectedRaidName or self.raidWindow.editBox:GetText(), nick)
            end
        end
        SendAddonMessage("nsGPlog", logStr, "guild")
        for _, entry in ipairs(self:GetSelectedEntries()) do
            entry.gp = (entry.gp or 0) + gpValue
        end
        self:UpdateWindow()
        self.raidWindow:Hide()
    end)
    self.raidWindow:SetScript("OnHide", function()
        if self.logWindow and self.logWindow:IsShown() then
            self.logWindow:SetHeight(self.window:GetHeight())
        end
    end)
    self.raidWindow:Hide()
end

function GpDb:_UpdatePlayerInfo()
    if not self.raidWindow or not self.raidWindow:IsShown() then return end
    local selected = self:GetSelectedEntries()
    if #selected ~= 1 then
        if self.raidWindow.playerInfoContainer then
            self.raidWindow.playerInfoContainer:Hide()
        end
        return
    end
    local nick = selected[1].original_nick
    local found = false
    local playerData = nil
    local rosterIndex = nil
    for i = 1, GetNumGuildMembers() do
        local name, rankName, rankIndex, level, classFileName, zone, publicNote, officerNote, online = GetGuildRosterInfo(i)
        if name then
            local plainName = name:match("^(.-)-") or name
            if plainName == nick then
                found = true
                rosterIndex = i
                playerData = {
                    name = name,
                    rankName = rankName,
                    rankIndex = rankIndex,
                    level = level,
                    classFileName = classFileName,
                    publicNote = publicNote or "",
                    officerNote = officerNote or "",
                    online = online,
                    index = i
                }
                break
            end
        end
    end
    if not found then
        if self.raidWindow.playerInfoContainer then
            self.raidWindow.playerInfoContainer:Hide()
        end
        return
    end
    -- Создаём контейнер и элементы ОДИН РАЗ
    if not self.raidWindow.playerInfoContainer then
        self.raidWindow.playerInfoContainer = CreateFrame("Frame", nil, self.raidWindow)
        self.raidWindow.playerInfoContainer:SetPoint("TOPRIGHT", -10, -30)
        self.raidWindow.playerInfoContainer:SetSize(230, 220)
        -- Класс
        self.raidWindow.classText = self.raidWindow.playerInfoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        self.raidWindow.classText:SetPoint("TOPLEFT", 0, -5)
        self.raidWindow.classText:SetWidth(230)
        -- Уровень
        self.raidWindow.levelText = self.raidWindow.playerInfoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        self.raidWindow.levelText:SetPoint("TOPLEFT", 0, -25)
        self.raidWindow.levelText:SetWidth(230)
        -- Офлайн (новая строка)
        self.raidWindow.offlineText = self.raidWindow.playerInfoContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        self.raidWindow.offlineText:SetPoint("TOPLEFT", 0, -45)
        self.raidWindow.offlineText:SetWidth(230)
        -- Звание с кнопками
        self.raidWindow.rankFrame = CreateFrame("Frame", nil, self.raidWindow.playerInfoContainer)
        self.raidWindow.rankFrame:SetSize(230, 20)
        self.raidWindow.rankFrame:SetPoint("TOPLEFT", 0, -65)
        self.raidWindow.minusBtn = CreateFrame("Button", nil, self.raidWindow.rankFrame, "UIPanelButtonTemplate")
        self.raidWindow.minusBtn:SetSize(20, 20)
        self.raidWindow.minusBtn:SetPoint("LEFT", 0, 0)
        self.raidWindow.minusBtn:SetText("-")
        self.raidWindow.rankText = self.raidWindow.rankFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        self.raidWindow.rankText:SetPoint("LEFT", self.raidWindow.minusBtn, "RIGHT", 5, 0)
        self.raidWindow.rankText:SetPoint("RIGHT", -25, 0)
        self.raidWindow.plusBtn = CreateFrame("Button", nil, self.raidWindow.rankFrame, "UIPanelButtonTemplate")
        self.raidWindow.plusBtn:SetSize(20, 20)
        self.raidWindow.plusBtn:SetPoint("RIGHT", 0, 0)
        self.raidWindow.plusBtn:SetText("+")
        -- Публичная заметка
        self.raidWindow.publicBtn = CreateFrame("Button", nil, self.raidWindow.playerInfoContainer, "UIPanelButtonTemplate")
        self.raidWindow.publicBtn:SetSize(230, 20)
        self.raidWindow.publicBtn:SetPoint("TOPLEFT", 0, -90)
        -- Офицерская заметка
        self.raidWindow.officerBtn = CreateFrame("Button", nil, self.raidWindow.playerInfoContainer, "UIPanelButtonTemplate")
        self.raidWindow.officerBtn:SetSize(230, 20)
        self.raidWindow.officerBtn:SetPoint("TOPLEFT", 0, -115)
    else
        self.raidWindow.playerInfoContainer:Show()
    end
    -- === ОБНОВЛЕНИЕ ТЕКСТОВ И ОБРАБОТЧИКОВ ===
    local db = self
    -- Класс
    local className = "Класс: ?"
    if playerData.classFileName then
        local color = RAID_CLASS_COLORS[playerData.classFileName]
        if color then
            local hex = string.format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
            className = hex .. playerData.classFileName .. "|r"
        else
            className = "|cFFFFFFFF" .. playerData.classFileName .. "|r"
        end
    end
    self.raidWindow.classText:SetText(className)
    -- Уровень
    self.raidWindow.levelText:SetText("Уровень: " .. (playerData.level or "?"))
    -- Офлайн
    local offlineStr = "Офлайн: "
    if playerData.online then
        offlineStr = offlineStr .. "в сети"
    else
        local years, months, days, hours = GetGuildRosterLastOnline(rosterIndex)
        if years ~= nil then
            if years > 0 then
                offlineStr = string.format("Офлайн: %dг %dм %dд %dч", years, months, days, hours)
            elseif months > 0 then
                offlineStr = string.format("Офлайн: %dм %dд %dч", months, days, hours)
            else
                offlineStr = string.format("Офлайн: %dд %dч", days, hours)
            end
        else
            offlineStr = offlineStr .. "—"
        end
    end
    self.raidWindow.offlineText:SetText(offlineStr)
    -- Звание
    self.raidWindow.rankText:SetText("Звание: " .. (playerData.rankName or "?"))
    -- Кнопки повышения/понижения — обновляем обработчики (чтобы playerData был актуальным)
    self.raidWindow.minusBtn:SetScript("OnClick", function()
        if not db:_CheckOfficerRank() then
            print("|cFFFF0000ГП:|r Только офицеры могут менять звания")
            return
        end
        GuildDemote(playerData.name)
        C_Timer.After(0.5, function() db:_UpdatePlayerInfo() end)
    end)
    self.raidWindow.plusBtn:SetScript("OnClick", function()
        if not db:_CheckOfficerRank() then
            print("|cFFFF0000ГП:|r Только офицеры могут менять звания")
            return
        end
        GuildPromote(playerData.name)
        C_Timer.After(0.5, function() db:_UpdatePlayerInfo() end)
    end)
    -- Публичная заметка
    self.raidWindow.publicBtn:SetText("Публ.: " .. (playerData.publicNote ~= "" and playerData.publicNote or "—"))
    self.raidWindow.publicBtn:SetScript("OnClick", function()
        StaticPopupDialogs["GP_EDIT_PUBLIC_NOTE"] = {
            text = "Изменить публичную заметку для " .. playerData.name,
            button1 = "OK",
            button2 = "Отмена",
            hasEditBox = true,
            editBoxWidth = 200,
            OnShow = function(self)
                self.editBox:SetText(playerData.publicNote)
                self.editBox:SetFocus()
            end,
            OnAccept = function(self)
                local newNote = self.editBox:GetText()
                if not db:_CheckOfficerRank() then
                    print("|cFFFF0000ГП:|r Только офицеры могут редактировать заметки")
                    return
                end
                GuildRosterSetPublicNote(playerData.index, newNote)
                GuildRoster()
                local frame = CreateFrame("Frame")
                frame:SetScript("OnEvent", function()
                    db:_UpdatePlayerInfo()
                    frame:UnregisterEvent("GUILD_ROSTER_UPDATE")
                end)
                frame:RegisterEvent("GUILD_ROSTER_UPDATE")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true
        }
        StaticPopup_Show("GP_EDIT_PUBLIC_NOTE")
    end)
    -- Офицерская заметка
    self.raidWindow.officerBtn:SetText("Оф.: " .. (playerData.officerNote ~= "" and playerData.officerNote or "—"))
    self.raidWindow.officerBtn:SetScript("OnClick", function()
        StaticPopupDialogs["GP_EDIT_OFFICER_NOTE"] = {
            text = "Изменить офицерскую заметку для " .. playerData.name,
            button1 = "OK",
            button2 = "Отмена",
            hasEditBox = true,
            editBoxWidth = 200,
            OnShow = function(self)
                self.editBox:SetText(playerData.officerNote)
                self.editBox:SetFocus()
            end,
            OnAccept = function(self)
                local newNote = self.editBox:GetText()
                if not db:_CheckOfficerRank() then
                    print("|cFFFF0000ГП:|r Только офицеры могут редактировать заметки")
                    return
                end
                GuildRosterSetOfficerNote(playerData.index, newNote)
                GuildRoster()
                local frame = CreateFrame("Frame")
                frame:SetScript("OnEvent", function()
                    db:_UpdatePlayerInfo()
                    frame:UnregisterEvent("GUILD_ROSTER_UPDATE")
                end)
                frame:RegisterEvent("GUILD_ROSTER_UPDATE")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true
        }
        StaticPopup_Show("GP_EDIT_OFFICER_NOTE")
    end)
end

function GpDb:_UpdateSelectedPlayersText()
    if not self.raidWindow then return end
    
    local selected = self:GetSelectedEntries()
    local names = {}
    
    for _, entry in ipairs(selected) do
        table.insert(names, entry.original_nick)
    end
    
    local text = table.concat(names, ", ")
    
    -- Создаем или обновляем текстовый элемент
    if not self.raidWindow.selectedPlayersText then
        self.raidWindow.selectedPlayersText = self.raidWindow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        self.raidWindow.selectedPlayersText:SetPoint("TOPLEFT", self.raidWindow.saveCheckbox, "BOTTOMLEFT", 0, -5)
        self.raidWindow.selectedPlayersText:SetPoint("RIGHT", -10, 0)
        self.raidWindow.selectedPlayersText:SetHeight(80)
        self.raidWindow.selectedPlayersText:SetJustifyH("LEFT")
        self.raidWindow.selectedPlayersText:SetJustifyV("TOP")
        self.raidWindow.selectedPlayersText:SetWordWrap(true)
        
        -- Создаем фрейм-контейнер для обработки событий мыши
        self.raidWindow.selectedPlayersTextContainer = CreateFrame("Frame", nil, self.raidWindow)
        self.raidWindow.selectedPlayersTextContainer:SetAllPoints(self.raidWindow.selectedPlayersText)
        self.raidWindow.selectedPlayersTextContainer:SetScript("OnEnter", function()
            if self.raidWindow.selectedPlayersText.tooltip then
                GameTooltip:SetOwner(self.raidWindow.selectedPlayersTextContainer, "ANCHOR_RIGHT")
                GameTooltip:SetText("Выбранные игроки:")
                GameTooltip:AddLine(self.raidWindow.selectedPlayersText.tooltip, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        self.raidWindow.selectedPlayersTextContainer:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    -- Устанавливаем текст с обрезкой если нужно
    if #text > 60 then
        local shortText = string.sub(text, 1, 600) .. "..."
        self.raidWindow.selectedPlayersText:SetText(shortText)
        self.raidWindow.selectedPlayersText.tooltip = text
    else
        self.raidWindow.selectedPlayersText:SetText(text)
        self.raidWindow.selectedPlayersText.tooltip = nil
    end
end

function GpDb:RestoreRaidWindowState()
    if not self.raidWindow then return end
    
    -- Восстанавливаем значения из сохраненных состояний
    if self.lastSelectionType == "raid" and self.lastRaidId then
        UIDropDownMenu_SetText(self.raidWindow.dropdown, string.format("%d: %s", self.lastRaidId, self.lastRaidName))
        self.raidWindow.editBox:SetText("")
        self.raidWindow.selectedRaidId = self.lastRaidId
        self.raidWindow.selectedRaidName = self.lastRaidName
        self.raidWindow.selectedRaidPlayers = self.lastRaidPlayers
    elseif self.lastSelectionType == "other" and self.lastOtherText then
        UIDropDownMenu_SetText(self.raidWindow.dropdown, "Выберите рейд")
        self.raidWindow.editBox:SetText(self.lastOtherText)
        self.raidWindow.selectedRaidId = nil
        self.raidWindow.selectedRaidName = nil
    else
        UIDropDownMenu_SetText(self.raidWindow.dropdown, "Выберите рейд")
        self.raidWindow.editBox:SetText("")
        self.raidWindow.selectedRaidId = nil
        self.raidWindow.selectedRaidName = nil
    end
    
    -- Всегда отображаем lastGPValue, даже если 0
    if not self.lastGPValue then
        self.lastGPValue = 0
    end
    self.raidWindow.gpEditBox:SetText(tostring(self.lastGPValue))
    self.raidWindow.saveCheckbox:SetChecked(self.saveSelectionEnabled)
    
    -- Обновляем список выбранных игроков
    self:_UpdateSelectedPlayersText()
end

function GpDb:_CheckOfficerRank()
    if not IsInGuild() then return false end
    
    local playerName = UnitName("player")
    for i = 1, GetNumGuildMembers() do
        local name, _, rankIndex = GetGuildRosterInfo(i)
        if name and name == playerName then
            -- Получаем информацию о звании
            local rankName = GuildControlGetRankName(rankIndex + 1) -- rankIndex начинается с 0
            -- Проверяем, является ли звание офицерским (Капитан или Лейтенант)
            if rankName == "Капитан" or rankName == "Лейтенант" then
                return true
            end
            break
        end
    end
    return false
end

-- Добавляем метод для показа/скрытия окна
function GpDb:ToggleRaidWindow()
    -- Проверяем звание игрока
    if not self:_CheckOfficerRank() then
        print("|cFFFF0000ГП:|r Только офицеры могут начислять ГП")
        if self.raidWindow and self.raidWindow:IsShown() then
            self.raidWindow:Hide()
        end
        return
    end
    
    if not self.raidWindow then
        self:_CreateRaidSelectionWindow()
    end
    
    local inRaid = IsInRaid()
    local raidOnlyChecked = self.window.raidOnlyCheckbox:GetChecked()
    local hasSelection = next(self.selected_indices) ~= nil
    
    if not hasSelection and not self.raidWindow:IsShown() then
        self.raidWindow:Show()
        UIDropDownMenu_Initialize(self.raidWindow.dropdown, nil)
        return
    end
    
    if hasSelection then
        if inRaid and not raidOnlyChecked then
            print("|cFFFF0000ГП:|r Для начисления ГП в рейде включите 'Только рейд'")
            self.raidWindow:Hide()
            return
        end
        
        if self.raidWindow:IsShown() then
            self.raidWindow:Hide()
        else
            self.raidWindow:Show()
            UIDropDownMenu_Initialize(self.raidWindow.dropdown, nil)
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
    C_Timer.After(0.5, UpdateNucleotideButtonState)
    self.UpdateNucleotideButtonState = UpdateNucleotideButtonState
    -- === КНОПКА: переключение видимости маркера игрока ===
    self.togglePlayerMarkerButton = CreateFrame("Button", nil, self.frame)
    self.togglePlayerMarkerButton:SetSize(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
    self.togglePlayerMarkerButton:SetPoint("TOPRIGHT", self.nucleotideButton, "BOTTOMRIGHT", 0, -5)
    self.togglePlayerMarkerButton:SetNormalTexture("Interface\\ICONS\\Ability_Mage_Invisibility")
    self.togglePlayerMarkerButton:SetPushedTexture("Interface\\ICONS\\Ability_Mage_Invisibility")
    self.togglePlayerMarkerButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    self.drawPlayerMarker = true  -- ✅ флаг: разрешено ли отображать маркер игрока

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
        self.drawPlayerMarker = not self.drawPlayerMarker
        if self.playerMarker then
            if self.drawPlayerMarker then
                self.playerMarker:Show()
            else
                self.playerMarker:Hide()
                self.playerMarker = nil  -- удаляем, чтобы не мешался
            end
        end
        UpdatePlayerMarkerButtonState()
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
    -- Кнопка крафта
    self.craftButton = CreateFrame("Button", nil, self.frame)
    self.craftButton:SetSize(CRAFT_BUTTON_SIZE, CRAFT_BUTTON_SIZE)
    self.craftButton:SetPoint("TOPRIGHT", self.togglePlayerMarkerButton, "BOTTOMRIGHT", 0, -5)
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

----------------------------------------
----------------------------------------
----------------------------------------

---------------------------------------
---------------------------------------
---------------------------------------

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
    if obj[methodName] and type(obj[methodName]) == "function" then
        -- Метод появился — вызываем callback
        callback()
    else
        -- Метода ещё нет — ждём 5 секунд и проверяем снова
        C_Timer.After(5, function()
            WaitForMethodAndCall(obj, methodName, callback)
        end)
    end
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
    self:StartPlayerPositionTracking()
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

-- Константы
local COMBO_TEXTURE = "Interface\\AddOns\\NSQC3\\libs\\00t.tga" 
local POISON_TEXTURE = "IInterface\\AddOns\\NSQC3\\libs\\00t.tga"

local DEBUG = false -- включить отладку
local function debug(msg)
    if DEBUG then print("SQ_DEBUG:", msg) end
end

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
    COMBO_EMPTY = {0.1, 0.1, 0.1},      -- Черный
    COMBO_FILLED = {1.0, 0.5, 0.0},     -- Оранжевый
    COMBO_FULL = {0.5, 0.0, 1.0},       -- Фиолетовый
    POISON_EMPTY = {0.1, 0.1, 0.1},     -- Черный
    POISON_FILLED = {0.0, 1.0, 0.0},    -- Зеленый
    POISON_FULL = {0.5, 0.0, 1.0}       -- Фиолетовый
}

local RESOURCE_TYPES = {
    MANA = 0,      -- Правильный индекс для маны
    RAGE = 1,      -- Правильный индекс для ярости
    FOCUS = 2,     -- Добавлено для полноты
    ENERGY = 3,    -- Энергия
    RUNIC_POWER = 6,-- Сила рун (правильный индекс для WotLK)
    RUNES = 5,     -- Руны
    COMBO_POINTS = 14 -- Комбо-поинты
}

local RESOURCE_NAMES = {
    [0] = "Мана",
    [1] = "Ярость",
    [3] = "Энергия",
    [6] = "Сила рун",
    [5] = "Руны",
    [14] = "Комбо-поинты"
}

local RESOURCE_TYPES = {
    DEATHKNIGHT = 6,  -- Сила рун
    DRUID = 0,        -- Мана/Энергия (в зависимости от формы)
    HUNTER = 2,       -- Фокус
    MAGE = 0,         -- Мана
    PALADIN = 0,      -- Мана
    PRIEST = 0,       -- Мана
    ROGUE = 3,        -- Энергия
    SHAMAN = 0,       -- Мана
    WARLOCK = 0,      -- Мана
    WARRIOR = 1       -- Ярость
}

local PLAYER_KEY = UnitName("player")
local RETURN_DELAY = 0.1
local DEBUFF_UPDATE_DELAY = 0.5

local READY_ALPHA = 1.0
local COOLDOWN_ALPHA = 0.6
local DEBUFF_ALPHA = 0.3
local READY_GLOW_COLOR = {0, 1, 0, 0.3}
local COOLDOWN_GLOW_COLOR = {1, 0, 0, 0.2}
local INACTIVE_ALPHA = 0.2
local BUFF_PRIORITY_POSITION = -100

local MODE_COMBAT_ONLY = 1
local MODE_ALWAYS_VISIBLE = 2


function SpellQueue:UpdateDebuffState(spellName)
    local spell = self.spells[spellName]
    if not spell or not spell.data.debuf then return end
    
    -- Получаем имя дебаффа (если указано) или имя скилла
    local debuffName = type(spell.data.debuf) == "string" and spell.data.debuf or spellName
    
    -- Проверяем наличие дебаффа на цели
    local hasDebuff = self:HasDebuff(debuffName)
    
    -- Запоминаем предыдущее состояние
    local hadDebuff = spell.hasDebuff
    
    -- Обновляем состояние дебаффа
    spell.hasDebuff = hasDebuff
    
    -- Устанавливаем прозрачность в зависимости от состояния дебаффа
    if hasDebuff then
        spell.icon:SetAlpha(DEBUFF_ALPHA)
    elseif hadDebuff then -- Если дебафф только что спал
        if spell.isReady then
            spell.icon:SetAlpha(READY_ALPHA)
        else
            spell.icon:SetAlpha(COOLDOWN_ALPHA)
        end
    end
end

function SpellQueue:ScheduleDebuffCheck(spellName)
    -- Создаем таймер для проверки дебаффа с задержкой
    C_Timer(DEBUFF_UPDATE_DELAY, function()
        local spell = self.spells[spellName]
        if not spell or not spell.data.debuf then return end
        
        self:UpdateDebuffState(spellName)
    end)
end

function SpellQueue:HasDebuff(debuffName)
    if not UnitExists("target") or not UnitCanAttack("player", "target") then return false end
    
    for i = 1, 40 do
        local name = UnitDebuff("target", i)
        if not name then break end
        if name == debuffName then return true end
    end
    return false
end

function SpellQueue:UpdateBuffState(spellName, isActive)
    local spell = self.spells[spellName]
    if not spell or spell.data.buf ~= 1 then return end
    
    -- Получаем имя баффа (если указано) или имя скилла
    local buffName = type(spell.data.buf) == "string" and spell.data.buf or spellName
    
    -- Если событие не связано с нашим баффом - игнорируем
    if isActive and type(spell.data.buf) == "string" and spellName ~= buffName then
        return
    end
    
    spell.hasBuff = isActive
    if isActive then
        spell.active = false
        spell.isReady = false
        spell.icon:Hide()
        spell.glow:Hide()
        spell.cooldownText:Hide()
    else
        local remaining, fullDuration = self:GetSpellCooldown(spellName)
        spell.active = remaining and remaining > 0
        spell.isReady = not spell.active
        self:UpdateSpellPosition(spellName)
        if spell.active or spell.isReady then
            spell.icon:Show()
            spell.glow:Show()
        end
    end
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
        -- Базовые настройки фрейма
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
    self.frame:SetClampedToScreen(true)
    debug(string.format("Initial features: %d", self.features))
    -- Настройка размеров и позиционирования
    frame:SetWidth(self.width)
    frame:SetHeight(self.height)
    if _G.nsDbc.SpellQueuePosition then
        -- Восстанавливаем сохраненную позицию
        local pos = _G.nsDbc.SpellQueuePosition
        frame:SetPoint(pos.point, UIParent, pos.relativePoint, ns_dbc:getKey("настройки", "Skill Queue position", "x"), ns_dbc:getKey("настройки", "Skill Queue position", "y"))
    else
        -- Дефолтное позиционирование
        frame:SetPoint(self.anchorPoint)
    end
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetAlpha(INACTIVE_ALPHA)
    frame:SetScale(self.scale)
    frame:Hide()

    self.isClickThrough = false

    -- Фоновый цвет
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture(0.1, 0.1, 0.1, 0.8)
    bg:SetVertexColor(0.1, 0.1, 0.1)
    bg:SetAlpha(0.8)
    self.background = bg

    -- Временная шкала
    local timeLine = frame:CreateTexture(nil, "OVERLAY")
    timeLine:SetHeight(2)
    timeLine:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, height/2 - 10)
    timeLine:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, height/2 - 10)
    timeLine:SetTexture(1, 1, 0.5)
    timeLine:SetVertexColor(1, 1, 0.5)
    timeLine:SetAlpha(0.3)
    self.timeLine = timeLine

    -- Нулевая точка
    local zeroPoint = frame:CreateTexture(nil, "OVERLAY")
    zeroPoint:SetWidth(2)
    zeroPoint:SetHeight(1)
    zeroPoint:SetPoint("LEFT", frame, "LEFT", 0, 0)
    zeroPoint:SetTexture(1, 0.2, 0.2)
    zeroPoint:SetVertexColor(1, 0.2, 0.2)
    zeroPoint:SetAlpha(0.5)
    self.zeroPoint = zeroPoint

    -- Удаляем старые элементы
    self.comboPoints = nil
    self.poisonStacks = nil
    
    -- Создаем новые элементы
    self:CreateComboPoisonElements()

    -- Полосы здоровья и ресурсов
    self:CreateResourceBars()
    
    -- Комбо-поинты
    self.comboPoints = {}
    local comboSize = self.height * 0.8
    for i = 1, 5 do
        local point = frame:CreateTexture(nil, "OVERLAY")
        point:SetSize(comboSize, comboSize)
        point:SetTexture("Interface\\TargetingFrame\\UI-Combopoint")
        point:SetPoint("LEFT", frame, "LEFT", -comboSize * (6 - i), 0)
        point:SetVertexColor(0.1, 0.1, 0.1)
        point:Hide()
        table.insert(self.comboPoints, point)
    end

    -- Стаки ядов
    self.poisonStacks = {}
    local poisonSize = self.height * 0.8
    for i = 1, 5 do
        local stack = frame:CreateTexture(nil, "OVERLAY")
        stack:SetSize(poisonSize, poisonSize)
        stack:SetTexture("Interface\\TargetingFrame\\UI-Combopoint")
        stack:SetPoint("RIGHT", frame, "RIGHT", poisonSize * (i - 3), 0)
        stack:SetVertexColor(0.1, 0.1, 0.1)
        stack:Hide()
        table.insert(self.poisonStacks, stack)
    end

    -- Кнопка настроек
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

    -- Система обновления
    frame:SetScript("OnUpdate", function(_, elapsed)
        if self.frame:IsShown() then
            -- Обновление скиллов
            for spellName, spell in pairs(self.spells) do
                if spell.active and not spell.isReady then
                    self:UpdateSpellPosition(spellName)
                end
            end
            
            -- Обновление новых элементов
            self:UpdateResourceBars()
            self:UpdateComboPoints()
            self:UpdatePoisonStacks()
            
            -- Плавное обновление прозрачности
            if self.frame:GetAlpha() ~= self.alpha then
                self.frame:SetAlpha(self.alpha)
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

function SpellQueue:ApplyDisplayMode()
    if self.displayMode == MODE_ALWAYS_VISIBLE then
        self.frame:SetAlpha(INACTIVE_ALPHA)
        self.frame:Show()
    else
        self.frame:Hide()
    end
end

function SpellQueue:CreateResourceBars()
    -- Полоса здоровья игрока
    self.healthBar = self.frame:CreateTexture(nil, "OVERLAY")
    self.healthBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.healthBar:SetHeight(5)
    self.healthBar:SetWidth(self.width)
    self.healthBar:SetPoint("TOP", self.frame, "TOP", 0, 10)
    self.healthBar:SetVertexColor(1, 0, 0)
    self.healthBar:Hide()

    -- Полоса ресурса игрока
    self.resourceBar = self.frame:CreateTexture(nil, "OVERLAY")
    self.resourceBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.resourceBar:SetHeight(5)
    self.resourceBar:SetWidth(self.width)
    self.resourceBar:SetPoint("TOP", self.healthBar, "BOTTOM", 0, -1)
    self.resourceBar:Hide()

    -- Полоса здоровья цели
    self.targetHealthBar = self.frame:CreateTexture(nil, "OVERLAY")
    self.targetHealthBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.targetHealthBar:SetHeight(5)
    self.targetHealthBar:SetWidth(self.width)
    self.targetHealthBar:SetPoint("BOTTOM", self.frame, "BOTTOM", 0, -10)
    self.targetHealthBar:SetVertexColor(1, 0, 0)
    self.targetHealthBar:Hide()

    -- Полоса ресурса цели
    self.targetResourceBar = self.frame:CreateTexture(nil, "OVERLAY")
    self.targetResourceBar:SetTexture("Interface\\Buttons\\WHITE8X8")
    self.targetResourceBar:SetHeight(5)
    self.targetResourceBar:SetWidth(self.width)
    self.targetResourceBar:SetPoint("BOTTOM", self.targetHealthBar, "TOP", 0, 1)
    self.targetResourceBar:Hide()
end

function SpellQueue:CreateComboPoints()
    self.comboPoints = {}
    local comboSize = 14 -- Размер точки
    local baseX = 20 -- Стартовое смещение слева
    local yOffset = -10 -- Смещение по вертикали
    
    for i = 1, 5 do
        local point = self.frame:CreateTexture(nil, "BACKGROUND")
        point:SetTexture("Interface\\TargetingFrame\\UI-Combopoint") -- Стандартная текстура WoW
        point:SetSize(comboSize, comboSize)
        -- Привязка к нижней части фрейма с горизонтальным смещением
        point:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", baseX + (i-1)*25, yOffset)
        point:SetVertexColor(0.2, 0.2, 0.2) -- Цвет неактивных точек
        table.insert(self.comboPoints, point)
    end
    debug("Комбо-поинты созданы")
end


function SpellQueue:CreatePoisonStacks()
    self.poisonStacks = {}
    local poisonSize = self.height * 0.8
    debug(string.format("Creating poison stacks (size: %d)", poisonSize))
    
    for i = 1, 5 do
        local stack = self.frame:CreateTexture(nil, "OVERLAY")
        stack:SetSize(poisonSize, poisonSize)
        stack:SetTexture("Interface\\TargetingFrame\\UI-Combopoint")
        stack:SetPoint("RIGHT", self.frame, "RIGHT", -poisonSize * (i - 3), 0)
        stack:SetVertexColor(0.1, 0.1, 0.1)
        stack:SetAlpha(1.0)
        debug(string.format("Poison stack %d position: %d", i, -poisonSize * (i - 3)))
        table.insert(self.poisonStacks, stack)
    end
end


function SpellQueue:GetPlayerResourceType()
    local _, class = UnitClass("player")
    debug(string.format("Class: %s", class))
    
    if class == "DRUID" then
        local form = GetShapeshiftForm()
        debug(string.format("Druid form: %d", form))
        -- 1: Медведь, 3: Кошка, 4: Лунный облик
        if form == 1 then
            debug("Bear form - Rage")
            return 1 -- RAGE
        elseif form == 3 then
            debug("Cat form - Energy")
            return 3 -- ENERGY
        else
            debug("Other form - Mana")
            return 0 -- MANA
        end
    end
    
    local resource = RESOURCE_TYPES[class] or 0
    debug(string.format("Resource type: %d (%s)", resource, RESOURCE_NAMES[resource] or "unknown"))
    return resource
end


function SpellQueue:GetTargetResourceType()
    if UnitIsPlayer("target") then
        local _, class = UnitClass("target")
        return RESOURCE_TYPES[class] or 0
    end
    return 0 -- Для NPC используем ману по умолчанию
end

function SpellQueue:UpdateResourceBars()
    -- Для игрока
    if bit.band(self.features, FEATURE_HP) ~= 0 then
        local maxHP = UnitHealthMax("player")
        local hp = maxHP > 0 and (UnitHealth("player") / maxHP) or 0
        debug(string.format("Player HP: %.1f%%", hp*100))
        self.healthBar:SetWidth(self.width * hp)
        self.healthBar:Show()
    else
        self.healthBar:Hide()
    end

    if bit.band(self.features, FEATURE_RESOURCE) ~= 0 then
        local resourceType = self:GetPlayerResourceType()
        local current = UnitPower("player", resourceType)
        local max = UnitPowerMax("player", resourceType)
        debug(string.format("Player resource: %d/%d (type %d)", current, max, resourceType))
        
        local colorName = self.resourceTypeNames[resourceType] or "UNKNOWN"
        local color = FEATURE_COLORS[colorName] or {1,1,1} -- дефолтный белый если нет цвета
        debug(string.format("Resource color: %s", colorName))
        
        self.resourceBar:SetWidth(max > 0 and (current/max)*self.width or 0)
        self.resourceBar:SetVertexColor(unpack(color))
        self.resourceBar:Show()
    else
        self.resourceBar:Hide()
    end

    -- Для цели
    if UnitExists("target") then
        debug("Target exists")
        if bit.band(self.features, FEATURE_TARGET) ~= 0 then
            -- Здоровье цели
            local maxHP = UnitHealthMax("target")
            local hp = maxHP > 0 and (UnitHealth("target") / maxHP) or 0
            debug(string.format("Target HP: %.1f%%", hp*100))
            self.targetHealthBar:SetWidth(self.width * hp)
            self.targetHealthBar:Show()
            
            -- Ресурс цели
            local resourceType = self:GetTargetResourceType()
            local current = UnitPower("target", resourceType)
            local max = UnitPowerMax("target", resourceType)
            debug(string.format("Target resource: %d/%d (type %d)", current, max, resourceType))
            
            local colorName = self.resourceTypeNames[resourceType] or "UNKNOWN"
            local color = FEATURE_COLORS[colorName] or {1,1,1}
            self.targetResourceBar:SetWidth(max > 0 and (current/max)*self.width or 0)
            self.targetResourceBar:SetVertexColor(unpack(color))
            self.targetResourceBar:Show()
        else
            debug("Target features disabled")
            self.targetHealthBar:Hide()
            self.targetResourceBar:Hide()
        end
    else
        debug("No target")
        self.targetHealthBar:Hide()
        self.targetResourceBar:Hide()
    end
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

function SpellQueue:UpdatePoisonStacks()
    if bit.band(self.features, FEATURE_POISON) == 0 then 
        self.poisonFrame:Hide()
        return 
    end
    self.poisonFrame:Show()
    
    -- Проверяем наличие яда на оружии
    local hasPoison = self:HasWeaponEnchant()
    local stacks = hasPoison and 5 or 0 -- Пример: всегда 5 стаков если есть яд
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
    -- Возвращает true если есть хотя бы один яд на оружии
    local hasMainHandEnchant, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
    return hasMainHandEnchant or hasOffHandEnchant
end

function SpellQueue:ToggleDisplayMode()
    self.displayMode = (self.displayMode == MODE_COMBAT_ONLY) and MODE_ALWAYS_VISIBLE or MODE_COMBAT_ONLY
    ns_dbc:modKey("настройки", "Skill Queue mode", self.displayMode)
    self:ApplyDisplayMode()
    print("SpellQueue: Режим "..(self.displayMode == MODE_ALWAYS_VISIBLE and "'Всегда видимый'" or "'Только в бою'"))
end

function SpellQueue:RegisterAllEvents()
    if not self.combatRegistered then
        self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        
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
            end
        end)
        self.combatRegistered = true
    end
end

function SpellQueue:ProcessCombatLogEvent(...)
    local args = {...}
    local timestamp, eventType = args[1], args[2]
    if args[3] ~= UnitGUID("player") then return end
    local spellName = eventType:find("SPELL") and args[10] or "Атака ближнего боя"
    
    if eventType == "SPELL_CAST_SUCCESS" then
        self:SpellUsed(spellName)
    elseif eventType == "SPELL_AURA_APPLIED" and args[12] == "BUFF" then
        self:UpdateBuffState(spellName, true)
    elseif eventType == "SPELL_AURA_REMOVED" and args[12] == "BUFF" then
        self:UpdateBuffState(spellName, false)
    elseif eventType == "SPELL_AURA_APPLIED" and args[12] == "DEBUFF" then
        -- Проверяем все дебаффы сразу при наложении
        self:CheckAllDebuffs()
    elseif eventType == "SPELL_AURA_REMOVED" and args[12] == "DEBUFF" then
        -- Проверяем все дебаффы сразу при снятии
        self:CheckAllDebuffs()
    elseif eventType == "SPELL_DAMAGE" then
        self:SpellUsed(spellName)
    end
end

function SpellQueue:CheckAllDebuffs()
    -- Проверяем все скиллы с дебафами, независимо от их состояния
    for spellName, spell in pairs(self.spells) do
        if spell.data.debuf then
            self:UpdateDebuffState(spellName)
        end
    end
end

function SpellQueue:LeaveCombat()
    self.inCombat = false
    if self.displayMode == MODE_COMBAT_ONLY then
        self.frame:SetAlpha(INACTIVE_ALPHA)
        self.frame:Hide()
    else
        -- В режиме всегда видимой продолжаем обновление
        self.frame:SetAlpha(self.alpha)
        self.frame:Show()
    end
end

function SpellQueue:EnterCombat()
    self.inCombat = true
    self.frame:SetAlpha(self.alpha)
    self.frame:Show()
    for spellName, _ in pairs(self.spells) do
        self:UpdateSpellPosition(spellName)
    end
    self:UpdateSpellsPriority()
end

function SpellQueue:SetIconsTable(tblIcons)
    -- Отладочный вывод входящей таблицы
    if type(tblIcons) ~= "table" then
        print("ERROR: tblIcons is not a table!")
        return
    end
    
    -- Базовые настройки фрейма
    self.tblIcons = tblIcons or {}
    self.spells = self.spells or {}
    
    -- Очистка предыдущих элементов
    for spellName, spell in pairs(self.spells) do
        if spell.icon then spell.icon:Hide() end
        if spell.glow then spell.glow:Hide() end
        if spell.cooldownText then spell.cooldownText:Hide() end
    end
    wipe(self.spells)
    
    -- Создание новых элементов
    local createdCount = 0
    for spellName, spellData in pairs(self.tblIcons) do
        -- Проверка валидности данных
        if type(spellName) == "string" and type(spellData) == "table" then
            local iconSize = self.iconSize or (self.height - 10)
            local glowSize = iconSize + (self.glowSizeOffset or 10)
            local highlightSize = iconSize + (self.highlightSizeOffset or 15)
            
            local icon = self.frame:CreateTexture(nil, "OVERLAY")
            icon:SetTexture(spellData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
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

            -- Создаем полную копию данных скилла, включая ресурсы
            local newData = {
                pos = spellData.pos or 0,
                buf = spellData.buf or 0,
                debuf = spellData.debuf or nil,
                combo = spellData.combo or 0,
                icon = spellData.icon or "Interface\\Icons\\INV_Misc_QuestionMark",
                name = spellName,
                resource = spellData.resource and {
                    type = spellData.resource.type,
                    amount = spellData.resource.amount
                } or nil
            }

            self.spells[spellName] = {
                data = newData,
                icon = icon,
                glow = glow,
                cooldownText = cooldownText,
                highlight = highlight,
                active = false,
                remaining = 0,
                total = 0,
                position = 0,
                isReady = false,
                hasBuff = false,
                hasDebuff = false,
                startTime = nil,
                endTime = nil
            }
            createdCount = createdCount + 1
        end
    end
end

function SpellQueue:HasEnoughResource(spellName)
    local spell = self.spells[spellName]
    if not spell or not spell.data.resource then return true end
    
    local resourceType = spell.data.resource.type
    local requiredAmount = spell.data.resource.amount or 0
    
    -- Для силы рун используем специальный индекс
    if resourceType == RESOURCE_TYPES.RUNIC_POWER then
        local current = UnitPower("player", 6)
        return current >= requiredAmount
    end
    
    -- Для рун считаем количество доступных
    if resourceType == RESOURCE_TYPES.RUNES then
        return self:GetAvailableRunes() >= requiredAmount
    end
    
    -- Для остальных ресурсов
    local current = UnitPower("player", resourceType)
    return current >= requiredAmount
end

function SpellQueue:GetAvailableRunes()
    local count = 0
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown(i)
        if runeReady or (start == 0 and duration == 0) then
            count = count + 1
        end
    end
    return count
end

function SpellQueue:HasEnoughRunes(required)
    local count = 0
    for i = 1, 6 do
        local start, duration, runeReady = GetRuneCooldown(i)
        if runeReady or (start == 0 and duration == 0) then
            count = count + 1
            if count >= required then
                return true
            end
        end
    end
    return count >= required
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
    -- Полностью отключаем или включаем взаимодействие с мышью
    self.frame:EnableMouse(not self.isClickThrough)
    self.frame:SetMovable(not self.isClickThrough)
    
    if self.isClickThrough then
        self.frame:RegisterForDrag() -- Отменяем регистрацию драга
    else
        self.frame:RegisterForDrag("LeftButton") -- Возвращаем драг
    end
    
    -- Обновляем кнопку настроек
    if self.configButton then
        self.configButton:EnableMouse(not self.isClickThrough)
    end
end


function SpellQueue:SetupDrag()
    self.frame:SetScript("OnMouseDown", function(frame, button)
        if self.isClickThrough then return end
        if not self.isAnchored and button == "LeftButton" then
            frame:StartMoving()
        end
    end)
    
    self.frame:SetScript("OnMouseUp", function(frame, button)
        if self.isClickThrough then return end
        
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

    -- Кнопка настроек
    local configButton = CreateFrame("Button", nil, self.frame)
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
end

function SpellQueue:SetClickThrough(enable)
    self.isClickThrough = enable == 1
    self:UpdateClickThrough()
    print(string.format("SpellQueue: ClickThrough %s", self.isClickThrough and "enabled" or "disabled"))
end

function SpellQueue:SpellUsed(spellName)
    local spell = self.spells[spellName]
    if not spell then return end
    
    -- Принудительное обновление кулдауна
    local remaining = self:GetSpellCooldown(spellName)
    spell.active = remaining and remaining > 0
    spell.isReady = not spell.active
    
    -- Проверяем все скиллы с дебафами сразу после использования скилла
    self:CheckAllDebuffs()
    
    self:UpdateSpellPosition(spellName)
    self:UpdateSpellsPriority()
    
    -- Добавляем проверку на рыцаря смерти и запуск таймера
    --if self.playerClass == "DEATHKNIGHT" then
        C_Timer(0.1, function()
            self:ForceUpdateAllSpells()
        end)
    --end
end

function SpellQueue:UpdateSpellPosition(spellName)
    local spell = self.spells[spellName]
    if not spell then return end

    -- Проверка на комбо-поинты
    if spell.data.combo and spell.data.combo > 0 then
        if not self:HasEnoughComboPoints(spell.data.combo) then
            spell.icon:Hide()
            spell.glow:Hide()
            spell.cooldownText:Hide()
            return
        end
    end
    
    -- Проверка на ресурсы
    if spell.data.resource then
        if not self:HasEnoughResource(spellName) then
            spell.icon:Hide()
            spell.glow:Hide()
            spell.cooldownText:Hide()
            return
        end
    end

    -- Проверка на бафф
    if spell.data.buf == 1 then
        spell.hasBuff = self:HasBuff(spellName)
        if spell.hasBuff then
            spell.active = false
            spell.isReady = false
            spell.icon:Hide()
            spell.glow:Hide()
            spell.cooldownText:Hide()
            return
        end
    end

    local remaining, fullDuration = self:GetSpellCooldown(spellName)
    spell.active = remaining and remaining > 0
    spell.isReady = not spell.active

    -- Обновляем текст кулдауна
    if remaining and remaining > 0 then
        if remaining > 3 then
            spell.cooldownText:SetText(math.floor(remaining))
        else
            spell.cooldownText:SetText(string.format("%.1f", remaining))
        end
        spell.cooldownText:Show()
    else
        spell.cooldownText:Hide()
    end

    -- Не меняем прозрачность для дебаффов, если они активны
    if not spell.data.debuf or not spell.hasDebuff then
        if spell.isReady then
            spell.icon:SetAlpha(READY_ALPHA)
            spell.glow:SetVertexColor(unpack(READY_GLOW_COLOR))
        else
            spell.icon:SetAlpha(COOLDOWN_ALPHA)
            spell.glow:SetVertexColor(unpack(COOLDOWN_GLOW_COLOR))
        end
    end

    if spell.isReady then
        -- Если скилл готов - используем стандартное позиционирование
        self:UpdateSpellsPriority()
    else
        -- Рассчитываем стартовую позицию скилла (без учета кулдауна)
        local startPos = (spell.data.pos or 0) * (self.height - 10)
        
        -- Рассчитываем текущую позицию в зависимости от кулдауна
        if fullDuration > 10 then
            if remaining > 10 then
                -- Движемся от конца второго участка (100%) к концу первого участка (80%)
                local progress = (remaining - 10) / (fullDuration - 10)
                spell.position = self.width * (0.8 + (0.2 * progress))
            else
                -- Движемся от конца первого участка (80%) к стартовой позиции скилла
                local progress = remaining / 10
                spell.position = startPos + (self.width * 0.8 - startPos) * progress
            end
        else
            -- Для коротких кулдаунов (<10 сек) движемся от конца первого участка (80%) к стартовой позиции
            local progress = remaining / fullDuration
            spell.position = startPos + (self.width * 0.8 - startPos) * progress
        end

        -- Ограничиваем максимальную позицию
        local maxPosition = self.width - (self.height - 10)
        spell.position = math.min(spell.position, maxPosition)

        -- Позиционируем иконку
        spell.icon:ClearAllPoints()
        spell.icon:SetPoint("LEFT", self.frame, "LEFT", spell.position, 0)
    end

    spell.icon:Show()
    spell.glow:Show()
end

function SpellQueue:GetSpellCooldown(spellName)
    local start, duration, enabled = GetSpellCooldown(spellName)
    if start == 0 or duration == 0 then
        return 0, 0
    end
    local now = GetTime()
    local remaining = (start + duration) - now
    return remaining > 0 and remaining or 0, duration
end

function SpellQueue:HasBuff(buffName)
    for i = 1, 40 do
        local name = UnitBuff("player", i)
        if not name then break end
        if name == buffName then return true end
    end
    return false
end

function SpellQueue:UpdateSpellsPriority()
    local iconSize = self.iconSize or (self.height - 10)
    local spacing = self.iconSpacing or 5
    local maxPosition = self.width - iconSize
    
    -- Группируем скиллы по позициям из данных
    local positionGroups = {}
    for spellName, spell in pairs(self.spells) do
        -- Проверка на комбо-поинты
        if spell.data.combo and spell.data.combo > 0 then
            if not self:HasEnoughComboPoints(spell.data.combo) then
                do break end
            end
        end
        
        if spell.isReady and not (spell.data.buf == 1 and spell.hasBuff) then
            local pos = spell.data.pos or 0
            positionGroups[pos] = positionGroups[pos] or {}
            table.insert(positionGroups[pos], spell)
        end
    end

    -- Обрабатываем приоритетные позиции (отрицательные)
    local buffGroup = positionGroups[BUFF_PRIORITY_POSITION]
    if buffGroup then
        table.sort(buffGroup, function(a, b) return a.data.name < b.data.name end)
        for i, spell in ipairs(buffGroup) do
            spell.position = 0
            spell.icon:ClearAllPoints()
            spell.icon:SetPoint("LEFT", self.frame, "LEFT", 0, 0)
            spell.icon:Show()
        end
    end

    -- Обрабатываем обычные позиции
    for pos, spells in pairs(positionGroups) do
        if pos ~= BUFF_PRIORITY_POSITION then
            table.sort(spells, function(a, b) return a.data.name < b.data.name end)
            
            -- Базовая позиция из настроек (от левого края)
            -- Учитываем iconSize вместо жестко заданного self.height - 10
            local baseX = pos * (iconSize + spacing)
            
            for i, spell in ipairs(spells) do
                -- Смещение внутри группы
                local offset = (i-1) * (iconSize + spacing)
                spell.position = math.min(baseX + offset, maxPosition)
                
                -- Позиционирование иконки от левого края
                spell.icon:ClearAllPoints()
                spell.icon:SetPoint("LEFT", self.frame, "LEFT", spell.position, 0)
                spell.icon:Show()
            end
        end
    end
    
    -- Обновляем позиции скиллов с кулдаунами
    for spellName, spell in pairs(self.spells) do
        if spell.active and not spell.isReady then
            self:UpdateSpellPosition(spellName)
        end
    end
end

function SpellQueue:CreateConfigWindow()
    local configFrame = CreateFrame("Frame", "SpellQueueConfig", UIParent)
    configFrame.parent = self
    configFrame.spellQueue = self
    configFrame:SetSize(350, 450)
    configFrame:SetPoint("CENTER")
    configFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame:Hide()

    -- Заголовок
    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Настройки SpellQueue")

    -- Кнопка закрытия в правом верхнем углу
    local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() configFrame:Hide() end)

    -- Поле ввода названия с кнопкой удаления
    local nameLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", 15, -45)
    nameLabel:SetText("Название скилла:")
    
    local editBox = CreateFrame("EditBox", "SpellQueueEditBox", configFrame, "InputBoxTemplate")
    editBox:SetSize(180, 20)
    editBox:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -5)
    editBox:SetAutoFocus(false)
    
    -- Кнопка удаления скилла
    local deleteButton = CreateFrame("Button", "SpellQueueDeleteButton", configFrame, "UIPanelButtonTemplate")
    deleteButton:SetSize(80, 22)
    deleteButton:SetPoint("LEFT", editBox, "RIGHT", 5, 0)
    deleteButton:SetText("Удалить")
    deleteButton:SetScript("OnClick", function()
        local spellName = editBox:GetText()
        if not spellName or spellName == "" then return end
        
        local name = GetSpellInfo(spellName)
        if not name then 
            message("Скилл не найден!")
            return 
        end
        
        if _G.nsDbc.skills3[PLAYER_KEY] and _G.nsDbc.skills3[PLAYER_KEY][name] then
            _G.nsDbc.skills3[PLAYER_KEY][name] = nil
            self:UpdateSkillTables()
            message("Скилл "..name.." удален!")
            editBox:SetText("")
        else
            message("Скилл "..name.." не найден в списке!")
        end
    end)

    -- Выпадающий список позиций
    local posLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    posLabel:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", 0, -15)
    posLabel:SetText("Позиция:")
    
    local posDropdown = CreateFrame("Frame", "SpellQueuePosDropdown", configFrame, "UIDropDownMenuTemplate")
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

    -- Чекбокс баффа с полем ввода
    local buffCheckButton = CreateFrame("CheckButton", "SpellQueueBuffCheckButton", configFrame, "UICheckButtonTemplate")
    buffCheckButton:SetSize(24, 24)
    buffCheckButton:SetPoint("TOPLEFT", posDropdown, "BOTTOMLEFT", 15, -10)
    buffCheckButton.text = buffCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    buffCheckButton.text:SetText("Бафф")
    buffCheckButton.text:SetPoint("LEFT", buffCheckButton, "RIGHT", 5, 0)
    
    local buffNameEditBox = CreateFrame("EditBox", "SpellQueueBuffNameEditBox", configFrame, "InputBoxTemplate")
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

    -- Чекбокс дебаффа с полем ввода
    local debuffCheckButton = CreateFrame("CheckButton", "SpellQueueDebuffCheckButton", configFrame, "UICheckButtonTemplate")
    debuffCheckButton:SetSize(24, 24)
    debuffCheckButton:SetPoint("TOPLEFT", buffCheckButton, "BOTTOMLEFT", 0, -10)
    debuffCheckButton.text = debuffCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    debuffCheckButton.text:SetText("Дебафф")
    debuffCheckButton.text:SetPoint("LEFT", debuffCheckButton, "RIGHT", 5, 0)
    
    local debuffNameEditBox = CreateFrame("EditBox", "SpellQueueDebuffNameEditBox", configFrame, "InputBoxTemplate")
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

    -- Чекбокс комбо-поинтов
    local comboCheckButton = CreateFrame("CheckButton", "SpellQueueComboCheckButton", configFrame, "UICheckButtonTemplate")
    comboCheckButton:SetSize(24, 24)
    comboCheckButton:SetPoint("TOPLEFT", debuffCheckButton, "BOTTOMLEFT", 0, -10)
    comboCheckButton.text = comboCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    comboCheckButton.text:SetText("Комбо-поинты:")
    comboCheckButton.text:SetPoint("LEFT", comboCheckButton, "RIGHT", 5, 0)
    
    -- Выпадающий список комбо-поинтов (скрыт по умолчанию)
    local comboDropdown = CreateFrame("Frame", "SpellQueueComboDropdown", configFrame, "UIDropDownMenuTemplate")
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

    -- Чекбокс ресурса
    local resourceCheckButton = CreateFrame("CheckButton", "SpellQueueResourceCheckButton", configFrame, "UICheckButtonTemplate")
    resourceCheckButton:SetSize(24, 24)
    resourceCheckButton:SetPoint("TOPLEFT", comboCheckButton, "BOTTOMLEFT", 0, -10)
    resourceCheckButton.text = resourceCheckButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resourceCheckButton.text:SetText("Ресурс:")
    resourceCheckButton.text:SetPoint("LEFT", resourceCheckButton, "RIGHT", 5, 0)
    
    -- Выпадающий список ресурсов (скрыт по умолчанию)
    local resourceDropdown = CreateFrame("Frame", "SpellQueueResourceDropdown", configFrame, "UIDropDownMenuTemplate")
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
            {text = "Руны", value = 5},
            {text = "Комбо-поинты", value = 14}
        }
        
        for _, resource in ipairs(resources) do
            info.text = resource.text
            info.value = resource.value
            info.func = function() 
                UIDropDownMenu_SetSelectedValue(resourceDropdown, resource.value) 
            end
            UIDropDownMenu_AddButton(info)
        end
    end
    UIDropDownMenu_Initialize(resourceDropdown, ResourceDropDown_Initialize)
    UIDropDownMenu_SetSelectedValue(resourceDropdown, 0)
    
    -- Поле ввода количества ресурса (скрыто по умолчанию)
    local resourceAmountEditBox = CreateFrame("EditBox", "SpellQueueResourceAmountEditBox", configFrame, "InputBoxTemplate")
    resourceAmountEditBox:SetSize(50, 20)
    resourceAmountEditBox:SetPoint("LEFT", resourceDropdown, "RIGHT", 10, 0)
    resourceAmountEditBox:SetAutoFocus(false)
    resourceAmountEditBox:Hide()
    resourceAmountEditBox:SetText("0")
    
    -- Обработчик изменения состояния чекбокса ресурса
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

    -- Кнопка добавления
    local addButton = CreateFrame("Button", "SpellQueueAddButton", configFrame, "UIPanelButtonTemplate")
    addButton:SetSize(120, 25)
    addButton:SetPoint("BOTTOM", 0, 85)
    addButton:SetText("Добавить")
    addButton:SetScript("OnClick", function()
        local spellName = editBox:GetText()
        if not spellName or spellName == "" then return end
        
        local name, _, icon = GetSpellInfo(spellName)
        if not name then 
            message("Скилл не найден!")
            return 
        end
        
        local comboValue = 0
        if comboCheckButton:GetChecked() then
            comboValue = UIDropDownMenu_GetSelectedValue(comboDropdown)
        end
        
        -- Определяем параметр ресурса
        local resourceValue = nil
        if resourceCheckButton:GetChecked() then
            local amount = tonumber(resourceAmountEditBox:GetText()) or 0
            resourceValue = {
                type = UIDropDownMenu_GetSelectedValue(resourceDropdown),
                amount = amount
            }
        end
        
        -- Определяем параметр баффа
        local buffParam = nil
        if buffCheckButton:GetChecked() then
            local buffName = buffNameEditBox:GetText()
            buffParam = buffName ~= "" and buffName or 1
        end
        
        -- Определяем параметр дебаффа
        local debuffParam = nil
        if debuffCheckButton:GetChecked() then
            local debuffName = debuffNameEditBox:GetText()
            debuffParam = debuffName ~= "" and debuffName or 1
        end
        
        _G.nsDbc.skills3[PLAYER_KEY][name] = {
            pos = UIDropDownMenu_GetSelectedValue(posDropdown),
            buf = buffParam,
            debuf = debuffParam,
            combo = comboValue,
            resource = resourceValue,
            icon = icon
        }
        
        _G.SpellQueueInstance:UpdateSkillTables()
        
        if _G.SpellQueueInstance.inCombat then
            _G.SpellQueueInstance:UpdateAllSpells()
        end
        
        -- Сбрасываем поля формы
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
        
        message("Скилл "..name.." добавлен!")
    end)

    self.configFrame = configFrame
end

function SpellQueue:UpdateSkillTables()
    -- Инициализация nsDbc
    _G.nsDbc = _G.nsDbc or {}
    _G.nsDbc.skills3 = _G.nsDbc.skills3 or {}
    _G.nsDbc.skills3[PLAYER_KEY] = _G.nsDbc.skills3[PLAYER_KEY] or {}

    -- Создаём объединённую таблицу
    local combined = {}
    
    -- Копируем скиллы из tblIcons
    if self.tblIcons then
        for k, v in pairs(self.tblIcons) do
            combined[k] = v
            -- Добавляем поле resource если его нет
            if not combined[k].resource then
                combined[k].resource = nil
            end
        end
    end
    
    -- Копируем сохранённые скиллы из nsDbc.skills3
    if _G.nsDbc.skills3[PLAYER_KEY] then
        for k, v in pairs(_G.nsDbc.skills3[PLAYER_KEY]) do
            if not combined[k] then
                combined[k] = v
                -- Добавляем поле resource если его нет
                if not combined[k].resource then
                    combined[k].resource = nil
                end
            else
                print(string.format("  Skipped (duplicate): %s", k))
            end
        end
    end
    
    -- Обновляем отображение
    self:SetIconsTable(combined)
end

function SpellQueue:ForceUpdateAllSpells()
    -- Принудительно обновляем размеры фрейма
    self.frame:SetWidth(self.width)
    self.frame:SetHeight(self.height)
    
    -- Обновляем все видимые элементы
    self:UpdateComboPoints()
    self:UpdatePoisonStacks()
    self:UpdateResourceBars()
    
    -- Основная логика обновления заклинаний
    for spellName, spell in pairs(self.spells) do
        -- Проверка на ресурсы
        if spell.data.resource then
            if not self:HasEnoughResource(spellName) then
                spell.icon:Hide()
                spell.glow:Hide()
                spell.cooldownText:Hide()
                do break end
            end
        end
        
        -- Проверка на комбо-поинты
        if spell.data.combo and spell.data.combo > 0 then
            if not self:HasEnoughComboPoints(spell.data.combo) then
                spell.icon:Hide()
                spell.glow:Hide()
                spell.cooldownText:Hide()
                do break end
            end
        end
        
        -- Обновляем кулдаун
        local remaining, fullDuration = self:GetSpellCooldown(spellName)
        spell.active = remaining and remaining > 0
        spell.isReady = not spell.active
        
        -- Обновляем баффы
        if spell.data.buf == 1 then
            spell.hasBuff = self:HasBuff(spellName)
        end
        
        -- Обновляем дебаффы
        if spell.data.debuf then
            self:UpdateDebuffState(spellName)
        elseif spell.isReady then
            spell.icon:SetAlpha(READY_ALPHA)
        else
            spell.icon:SetAlpha(COOLDOWN_ALPHA)
        end
        
        -- Перерисовываем позицию
        self:UpdateSpellPosition(spellName)
    end
    
    -- Финализируем обновления
    self:UpdateSpellsPriority()
    self.frame:Show() -- Гарантируем видимость
end

function SpellQueue:SetAppearanceSettings(options)
    -- Сохраняем основные настройки glow
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

    -- Обновляем все glow-текстуры
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

    -- Основные параметры панели
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

    -- Настройки прозрачности
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

    -- Полоса здоровья игрока
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

    -- Полоса ресурса игрока
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

    -- Полоса здоровья цели
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

    -- Полоса ресурса цели
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

    -- Комбо-поинты
    if options.comboSize or options.comboSpacing or options.comboOffset then
        local size = options.comboSize or 6
        local spacing = options.comboSpacing or 0
        local offsetX = options.comboOffset and options.comboOffset.x or 0
        local offsetY = options.comboOffset and options.comboOffset.y or 24
        
        for i, square in ipairs(self.comboSquares) do
            square:SetSize(size, size)
            square:ClearAllPoints()
            square:SetPoint("BOTTOM", self.comboFrame, "BOTTOM", 0, (i-1)*(size + spacing))
        end
        
        self.comboFrame:SetPoint("RIGHT", self.frame, "LEFT", offsetX, offsetY)
    end

    -- Яды
    if options.poisonSize or options.poisonSpacing or options.poisonOffset then
        local size = options.poisonSize or 6
        local spacing = options.poisonSpacing or 0
        local offsetX = options.poisonOffset and options.poisonOffset.x or 0
        local offsetY = options.poisonOffset and options.poisonOffset.y or 24
        
        for i, square in ipairs(self.poisonSquares) do
            square:SetSize(size, size)
            square:ClearAllPoints()
            square:SetPoint("BOTTOM", self.poisonFrame, "BOTTOM", 0, (i-1)*(size + spacing))
        end
        
        self.poisonFrame:SetPoint("LEFT", self.frame, "RIGHT", offsetX, offsetY)
    end

    -- Временная линия
    if options.timeLinePosition then
        self.timeLine:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, self.height/2 - options.timeLinePosition)
    end

    -- Принудительное обновление
    self:ForceUpdateAllSpells()
end

function SpellQueue:CreateComboPoisonElements()
    -- Настройки
    local square_size = 12
    local spacing = 4
    local total_height = (square_size + spacing) * 5 - spacing
    
    -- Фрейм для комбо-поинтов (слева)
    self.comboFrame = CreateFrame("Frame", nil, self.frame)
    self.comboFrame:SetSize(square_size, total_height)
    self.comboFrame:SetPoint("RIGHT", self.frame, "LEFT", -10, 0)
    
    -- Комбо-поинты
    self.comboSquares = {}
    for i = 1, 5 do
        local square = self.comboFrame:CreateTexture(nil, "OVERLAY")
        square:SetSize(square_size, square_size)
        square:SetTexture("Interface\\Buttons\\WHITE8X8")
        square:SetPoint("BOTTOM", self.comboFrame, "BOTTOM", 0, (i-1)*(square_size + spacing))
        square:SetVertexColor(unpack(FEATURE_COLORS.COMBO_EMPTY))
        table.insert(self.comboSquares, square)
    end

    -- Фрейм для ядов (справа)
    self.poisonFrame = CreateFrame("Frame", nil, self.frame)
    self.poisonFrame:SetSize(square_size, total_height)
    self.poisonFrame:SetPoint("LEFT", self.frame, "RIGHT", 10, 0)
    
    -- Яды
    self.poisonSquares = {}
    for i = 1, 5 do
        local square = self.poisonFrame:CreateTexture(nil, "OVERLAY")
        square:SetSize(square_size, square_size)
        square:SetTexture("Interface\\Buttons\\WHITE8X8")
        square:SetPoint("BOTTOM", self.poisonFrame, "BOTTOM", 0, (i-1)*(square_size + spacing))
        square:SetVertexColor(unpack(FEATURE_COLORS.POISON_EMPTY))
        table.insert(self.poisonSquares, square)
    end
end

function SpellQueue:UpdateGlowSettings()
    if not self.iconSize then return end
    
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

function ProkIconManager:Initialize(externalIconsTable)
    self.externalIconsTable = externalIconsTable or {}
    
    -- Копируем проки из внешней таблицы во внутреннюю
    for name, iconData in pairs(self.externalIconsTable) do
        self.icons[name] = iconData
        
        local profile = self.settings[iconData.profil or 1]
        local width = profile.Rx == 0 and GetScreenWidth() or profile.Rx
        local height = profile.Ry == 0 and GetScreenHeight() or profile.Ry
        
        -- Формируем полный путь к текстуре
        local texturePath = iconData.icon
        if not strfind(texturePath:lower(), "^interface\\") then
            texturePath = "Interface\\AddOns\\NSQC\\libs\\" .. texturePath:gsub("%.tga$", "") .. ".tga"
        end
        
        if not self.frames[name] then
            self.frames[name] = CreateFrame("Frame", nil, UIParent)
            self.frames[name].texture = self.frames[name]:CreateTexture(nil, "BACKGROUND")
            self.frames[name].texture:SetAllPoints()
            self.frames[name]:SetFrameStrata("HIGH")
        end
        
        self.frames[name]:SetSize(width, height)
        self.frames[name]:ClearAllPoints()
        self.frames[name]:SetPoint("CENTER", UIParent, "CENTER", profile.x, profile.y)
        self.frames[name].texture:SetTexture(texturePath)
        self.frames[name]:Show() -- Показываем сразу, HandleSpellEvent потом скроет если нужно
    end
    
    -- Инициализация фрейма событий
    self.eventFrame = self.eventFrame or CreateFrame("Frame")
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.eventFrame:RegisterEvent("UNIT_AURA")
    
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local _, subEvent, _, _, _, _, _, destGUID, _, _, _, spellID, spellName = ...
            local isPlayer = (destGUID == UnitGUID("player"))
            
            if not isPlayer then return end
            
            if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_CAST_SUCCESS" or 
               subEvent == "SPELL_AURA_REMOVED" or subEvent == "SPELL_AURA_REFRESH" then
                
                for name, icon in pairs(self.icons) do
                    if spellName == icon.name or spellName == icon.skill then
                        self:HandleSpellEvent(subEvent, icon, spellName)
                    end
                end
            end
            
        elseif event == "UNIT_AURA" and ... == "player" then
            for _, icon in pairs(self.icons) do
                self:HandleSpellEvent("UNIT_AURA", icon)
            end
        end
    end)
    
    -- Принудительно проверяем баффы после загрузки
    for _, icon in pairs(self.icons) do
        self:HandleSpellEvent("UNIT_AURA", icon)
    end
end

function ProkIconManager:HandleSpellEvent(event, iconData, spellName)
    -- Удаляем проверку по таймеру и переводим полностью на обработку событий
    if event == "SPELL_AURA_APPLIED" or event == "SPELL_CAST_SUCCESS" or 
       event == "SPELL_AURA_REFRESH" or event == "UNIT_AURA" then
        
        -- Проверяем наличие баффа в реальном времени
        local shouldShow = false
        for i = 1, 40 do
            local name, _, _, count = UnitBuff("player", i)
            if name and (name == iconData.name or name == iconData.skill) then
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
            
            self:ShowIcon(iconData.name, width, height, profile.x, profile.y, iconData.icon)
        else
            self:HideIcon(iconData.name)
        end
        
    elseif event == "SPELL_AURA_REMOVED" then
        -- Мгновенно скрываем иконку при спадении баффа
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
    self.configFrame:SetSize(400, 242) -- Увеличил высоту для нормального отображения
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
        if self.icons[self.input_name:GetText()] then
            self.icons[self.input_name:GetText()] = nil
            if self.externalIconsTable then
                self.externalIconsTable[self.input_name:GetText()] = nil
            end
            self:ResetForm()
            print("Иконка удалена:", self.input_name:GetText())
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

    -- Выбор текстуры с вложенным меню
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
                    CloseDropDownMenus() -- Закрытие всех уровней меню
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

    -- Кнопка добавления
    local addBtn = CreateFrame("Button", nil, self.configFrame, "UIPanelButtonTemplate")
    addBtn:SetSize(120, 24)
    addBtn:SetPoint("BOTTOM", 0, 20)
    addBtn:SetText("Добавить")
    addBtn:SetScript("OnClick", function() 
        self:AddNewIcon() 
        CloseDropDownMenus() -- Закрытие меню при добавлении
        self:ForceHideAllIcons()
    end)    
end

function ProkIconManager:CreateInputField(label, fieldName, yOffset, isNumeric)
    local labelText = self.configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", 20, -yOffset)
    labelText:SetText(label..":")

    local input = CreateFrame("EditBox", nil, self.configFrame, "InputBoxTemplate")
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
    
    local iconData = {
        name = name,
        skill = self.input_skill:GetText() or "",
        icon = self.selectedIcon,
        stack = tonumber(self.input_stack:GetText()) or 0,
        profil = UIDropDownMenu_GetSelectedValue(self.profileDropdown) or 1
    }
    
    -- Добавляем в обе таблицы
    self.icons[name] = iconData
    if self.externalIconsTable then
        self.externalIconsTable[name] = iconData
    end
    
    print(string.format("Добавлена иконка: %s (стаки: %d, профиль: %s)", 
          name, iconData.stack, self.settings[iconData.profil].name))
    
    -- Показываем иконку
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

function ProkIconManager:ResetForm()
    self.input_name:SetText("")
    self.input_skill:SetText("")
    self.input_stack:SetText("")
    self.selectedIcon = nil
    UIDropDownMenu_SetSelectedValue(self.profileDropdown, 1)
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

------------------------------------------------


