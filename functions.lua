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
    if type(unixTime) ~= "number" then
        return "Invalid input", nil, nil
    end

    -- Получаем таблицу даты (в WoW используется date(), а не os.date())
    local dateTable = date("*t", unixTime)
    if not dateTable then
        return "Invalid Unix time", nil, nil
    end

    -- Форматируем дату в строку
    local dateString = string.format("%04d-%02d-%02d %02d:%02d:%02d",
        dateTable.year, dateTable.month, dateTable.day,
        dateTable.hour, dateTable.min, dateTable.sec)

    -- Корректируем день недели (в WoW воскресенье = 1, понедельник = 2, и т.д.)
    -- Приводим к стандарту ISO: понедельник = 1, воскресенье = 7
    local dayOfWeek = dateTable.wday - 1
    if dayOfWeek == 0 then dayOfWeek = 7 end

    -- Вычисляем номер недели (по ISO 8601)
    -- В WoW нет встроенной функции, поэтому реализуем вручную
    local function getISOWeekNumber(y, m, d)
        -- Простая реализация (может не учитывать все крайние случаи)
        local jan1 = date("*t", time({year = y, month = 1, day = 1}))
        local firstThursday
        if jan1.wday <= 5 then  -- Пятница или раньше
            firstThursday = 11 - jan1.wday
        else  -- Суббота или воскресенье
            firstThursday = 4 + (7 - jan1.wday)
        end
        
        local dayOfYear = dateTable.yday
        local weekNum = math.floor((dayOfYear - firstThursday + 10) / 7)
        
        if weekNum < 1 then
            -- Это последняя неделя предыдущего года
            return getISOWeekNumber(y - 1, 12, 31)
        elseif weekNum > 52 and (date("*t", time({year = y, month = 12, day = 31}))).yday - firstThursday < 4 then
            -- Это первая неделя следующего года
            return 1
        else
            return weekNum
        end
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
    local miniMapButton = CreateFrame("Button", nil, Minimap)
    miniMapButton:SetSize(32, 32)  -- Размер иконки
    miniMapButton:SetFrameLevel(8)  -- Уровень фрейма
    miniMapButton:SetMovable(true)  -- Разрешаем перемещение

    -- Устанавливаем текстуры для иконки
    miniMapButton:SetNormalTexture("Interface\\AddOns\\NSQC3\\emblem.tga")
    miniMapButton:SetPushedTexture("Interface\\AddOns\\NSQC3\\emblem.tga")
    miniMapButton:SetHighlightTexture("Interface\\AddOns\\NSQC3\\emblem.tga")

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
    local panel = {}
    for i = 1, 100 do
        -- Функция-триггер, которая проверяет параметры кнопки
        local trigger1 = function(parentButton)
            local texture = parentButton:GetNormalTexture():GetTexture()
            if texture == "Interface\\AddOns\\NSQC3\\libs\\00t" then
                return true, {
                    {texture = "Interface\\Icons\\Spell_Nature_Thorns", func = function() print("Действие 1") end},
                    {texture = "Interface\\Icons\\Spell_Nature_HealingTouch", func = function() print("Действие 2") end}
                }
            end
            return false
        end
        -- Триггер 2: Проверка имени
        local trigger2 = function(parentButton)
            local name = parentButton:GetName()
            if name and name:find("1") then
                return true, {
                    {
                        texture = "Interface\\Icons\\Spell_Nature_Regeneration",
                        func = function() print("Специальное действие") end,
                        tooltip = "Это кнопка Spell_Nature_Regeneration" -- Добавляем текст тултипа
                    }
                }
            end
            return false
        end
        local panel = PopupPanel:Create(50, 50, 6, 0) -- 4 кнопки в ряд
        panel:Show(adaptiveFrame.children[i].frame, {trigger1, trigger2})
    end

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

function fBtnEnter(id, obj)
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

function getPoint()
    SendAddonMessage("getPoint","", "guild")
end

function gPoint(name)
    for i=1,#mFld:getArg("gPoint") do
        if name == mFld:getArg("gPoint")[i] then
            return 1
        end
    end
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
                SendAddonMessage("getFld " .. mFldName, "", "guild")
                for i = 1, 100 do
                    adaptiveFrame.children[i]:SetTextT("")
                end
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







-- Base85 with custom encoding table for WoW 3.3.5 (Lua 5.1)

local Base85 = {}

-- Your custom encoding table
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

-- Helper function to convert a 32-bit integer to 5 base85 characters
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
