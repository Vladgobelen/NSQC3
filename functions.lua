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
    -- Проверяем, что unixTime является числом
    if type(unixTime) ~= "number" then
        return "Invalid input"
    end

    -- Получаем текущее время в формате таблицы
    local dateTable = date("*t", unixTime)

    -- Проверяем, что dateTable успешно создана
    if not dateTable then
        return "Invalid Unix time"
    end

    -- Форматируем дату и время в строку
    local formattedDate = string.format(
        "%04d-%02d-%02d %02d:%02d:%02d",
        dateTable.year,
        dateTable.month,
        dateTable.day,
        dateTable.hour,
        dateTable.min,
        dateTable.sec
    )

    return formattedDate
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
    C_Timer(10, function()
        UpdateAddOnMemoryUsage()
    end, true)
    -- Создаем фрейм для иконки
    local miniMapButton = CreateFrame("Button", nil, Minimap)
    miniMapButton:SetSize(32, 32)  -- Размер иконки
    miniMapButton:SetFrameLevel(8)  -- Уровень фрейма
    miniMapButton:SetMovable(true)  -- Разрешаем перемещение

    -- Устанавливаем текстуры для иконки
    miniMapButton:SetNormalTexture("Interface\\AddOns\\NSQC\\emblem.tga")
    miniMapButton:SetPushedTexture("Interface\\AddOns\\NSQC\\emblem.tga")
    miniMapButton:SetHighlightTexture("Interface\\AddOns\\NSQC\\emblem.tga")

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
    local function CreateTooltip(self)
        SendAddonMessage("NSQC_VERSION_REQUEST", "", "GUILD")  -- Отправляем запрос
        local myNome = GetUnitName("player")

        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cFF6495EDNSQC3|cFF808080-|cff00BFFF" .. NSQC3_version .. "." .. NSQC3_subversion .. " |cffbbbbbbОЗУ: |cff00BFFF" .. string.format("%.0f", GetAddOnMemoryUsage("NSQC3")) .. " |cffbbbbbbкб")
        
        -- Если есть информация о последней версии, добавляем её в тултип
        if latestVersion then
            GameTooltip:AddLine("|cFF6495EDАктуальная версия аддона: |cff00BFFF" .. latestVersion .. "." .. latestSubVersion)
        else
            GameTooltip:AddLine("|cFF6495EDАктуальная версия: |cffff0000Неизвестно")
        end
        
        GameTooltip:AddLine("|cFF6495EDСредний уровень предметов: |cff00BFFF" .. string.format("%d", CalculateAverageItemLevel(myNome)))
        
        if GS_Data ~= nil and GS_Data[GetRealmName()] and GS_Data[GetRealmName()].Players[myNome] then
            GameTooltip:AddLine("|cFF6495EDGearScore: |cff00BFFF" .. string.format("%d", GS_Data[GetRealmName()].Players[myNome].GearScore))
        end
        
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cffFF8C00ЛКМ|cffFFFFE0 - открыть аддон")
        GameTooltip:AddLine("|cffF4A460ПКМ|cffFFFFE0 - показать настройки")
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
        sendAch("Великий открыватор", -1)
        SendAddonMessage("getFld ", "", "guild")
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
        nsDBC_settings:mod_key("minibtn_x", position.radius * math.cos(position.angle))
        nsDBC_settings:mod_key("minibtn_y", position.radius * math.sin(position.angle))
    end)

    -- Восстановление позиции иконки после перезагрузки
    local function SetInitialPosition()
        local savedX = nsDBC_settings:get_key("minibtn_x") or 0
        local savedY = nsDBC_settings:get_key("minibtn_y") or 0
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

-- Функция для создания таймера
function C_Timer(duration, callback, isLooping)
    -- Создаем фрейм для таймера
    local timerFrame = CreateFrame("Frame")
    
    -- Устанавливаем продолжительность таймера
    timerFrame.duration = duration
    timerFrame.elapsed = 0
    timerFrame.isLooping = isLooping or false  -- По умолчанию таймер не циклический
    
    -- Обработчик OnUpdate для отслеживания времени
    timerFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        
        -- Проверяем, прошло ли нужное время
        if self.elapsed >= self.duration then
            -- Выполняем переданную функцию (callback)
            if type(callback) == "function" then
                callback()
            end
            
            -- Если таймер циклический, сбрасываем время
            if self.isLooping then
                self.elapsed = 0
            else
                -- Уничтожаем фрейм после выполнения, если таймер не циклический
                self:SetScript("OnUpdate", nil)
                self = nil
            end
        end
    end)
end

function sendAch(name, arg, re)
    if not re then
        if customAchievements:GetAchievementData(name)['dateEarned'] == "Не получена" then
            SendAddonMessage("NSQC3_ach " .. arg, name, "guild")
        end
    else
        SendAddonMessage("NSQC3_ach " .. arg, name, "guild")
    end
end

local set = true

function fBtnClick(id, obj)
    if not set then
        return
    end
    set = false

    if arg2 then
        print("Функция запущена с параметрами:", id, obj)
    end

    if not arg2 then

    end

    C_Timer(.3, function()
        set = true
    end)
end

function getPoint()
    SendAddonMessage("getPoint","", "guild")
end

function gPoint(name)
    for i=1,#mFld:getArg("gPoint") do
        if name==mFld:getArg("gPoint")[i] then
            return 1
        end
    end
end

function isMod(obj)
    return ns_tooltips[obj].mod
end

-- Таблица для преобразования чисел в символы
local _convertTable3 = {
    [0] = "0", [1] = "2", [2] = "3", [3] = "4", [4] = "5",
    [5] = "6", [6] = "7", [7] = "8", [8] = "9", [9] = ":",
    [10] = ";", [11] = "<", [12] = "=", [13] = ">", [14] = "?",
    [15] = "@", [16] = "A", [17] = "B", [18] = "C", [19] = "D",
    [20] = "E", [21] = "F", [22] = "G", [23] = "H", [24] = "I",
    [25] = "J", [26] = "K", [27] = "L", [28] = "M", [29] = "N",
    [30] = "O", [31] = "P", [32] = "Q", [33] = "R", [34] = "S",
    [35] = "T", [36] = "U", [37] = "V", [38] = "W", [39] = "X",
    [40] = "Y", [41] = "Z", [42] = "[", [43] = "\\", [44] = "]",
    [45] = "^", [46] = "_", [47] = "`", [48] = "a", [49] = "b",
    [50] = "c", [51] = "d", [52] = "e", [53] = "f", [54] = "g",
    [55] = "h", [56] = "i", [57] = "j", [58] = "k", [59] = "l",
    [60] = "m", [61] = "n", [62] = "o", [63] = "p", [64] = "q",
    [65] = "r", [66] = "s", [67] = "t", [68] = "u", [69] = "v",
    [70] = "w", [71] = "x", [72] = "y", [73] = "z", [74] = "{",
    [75] = "|", [76] = "}", [77] = "~", [78] = "!", [79] = "#",
    [80] = "$", [81] = "%", [82] = "&", [83] = "'", [84] = "(",
    [85] = ")", [86] = "*", [87] = "+", [88] = ",", [89] = "-",
}

-- Локализация часто используемых функций
local abs = math.abs
local floor = math.floor
local sub = string.sub

-- Создание обратной таблицы один раз при инициализации
local _reverseConvertTable3 = {}
for k, v in pairs(_convertTable3) do
    _reverseConvertTable3[v] = k
end

-- Кодирование числа в строку
function en90(dec)
    if dec == 0 then return "0" end

    local isNegative = dec < 0
    dec = abs(dec)

    -- Используем таблицу для сборки символов
    local buffer = {}
    repeat
        local remainder = dec % 90
        dec = floor(dec / 90)
        table.insert(buffer, 1, _convertTable3[remainder]) -- Добавляем символ в начало
    until dec == 0

    if isNegative then
        table.insert(buffer, 1, "-") -- Добавляем знак "-" для отрицательных чисел
    end

    -- Собираем строку из таблицы только один раз
    return table.concat(buffer)
end

-- Декодирование строки в число
function en10(encoded)
    if #encoded == 0 then return 0 end

    local isNegative = sub(encoded, 1, 1) == "-"
    local cleanEncoded = isNegative and sub(encoded, 2) or encoded

    local number = 0
    for i = 1, #cleanEncoded do
        local char = sub(cleanEncoded, i, i)
        local value = _reverseConvertTable3[char] or 0 -- Получаем значение из обратной таблицы
        number = number * 90 + value
    end

    return isNegative and -number or number
end





local lastName = nil -- Переменная для хранения предыдущего значения

GuildMemberDetailFrame:HookScript("OnUpdate", function(self, elapsed)
    if GuildMemberDetailFrame:IsVisible() then
        local selectedName = GuildFrame.selectedName
        if selectedName and selectedName ~= lastName then
            lastName = selectedName -- Обновляем предыдущее значение
            print("Имя изменилось на:", selectedName)
            -- Ваш код для обработки изменения
        end
    end
end)









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

-- Пример использования:
-- Отобразить текстуру "Interface\\Icons\\INV_Misc_QuestionMark" на 5 секунд

