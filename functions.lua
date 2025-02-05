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
        sendAch(1, -1)
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
    -- Создаем родительский фрейм
    parentFrame = CreateFrame("Frame", nil, UIParent)
    parentFrame:SetSize(800, 600)
    parentFrame:SetPoint("CENTER")

    --Создаем адаптивный фрейм
    fBtnFrame = AdaptiveFrame:Create(parentFrame)
    fBtnFrame:SetPoint("CENTER")

    --Создаем 100 кнопок
    nsqc_fBtn = {}
    for i = 1, 100 do
        nsqc_fBtn[i] = ButtonManager:new("Button" .. i, fBtnFrame, 64, 64, "", "")
        --nsqc_fBtn[i]:SetTextT("|cffFF8C00" .. i)
        --nsqc_fBtn[i]:SetTooltip("This is Button " .. i)
    end

    --Добавляем кнопки в сетку (10 кнопок в линии)
    fBtnFrame:AddGrid(nsqc_fBtn, 100, 10, 0)

    fBtnFrame:Hide()
    -- Создаем фрейм для отслеживания движения
    local movementFrame = CreateFrame("Frame")
    movementFrame.targetAlpha = 1.0  -- Целевая прозрачность
    movementFrame.currentAlpha = 1.0  -- Текущая прозрачность
    movementFrame.alphaSpeed = 2.0  -- Скорость изменения прозрачности (чем больше, тем быстрее)

    movementFrame:SetScript("OnUpdate", function(self, elapsed)
        -- Получаем текущие координаты персонажа
        local _, x, y = GetPlayerMapPosition("player")

        -- Если координаты изменились, персонаж движется
        if x ~= self.lastX or y ~= self.lastY then
            if not self.isMoving then
                -- Персонаж начал движение
                self.isMoving = true
                self.targetAlpha = 0.5 -- Устанавливаем целевую прозрачность 50%
            end
        else
            if self.isMoving then
                -- Персонаж остановился
                self.isMoving = false
                self.targetAlpha = 1.0  -- Устанавливаем целевую прозрачность 100%
            end
        end

        -- Плавное изменение прозрачности
        if self.currentAlpha ~= self.targetAlpha then
            -- Вычисляем новое значение прозрачности
            self.currentAlpha = self.currentAlpha + (self.targetAlpha - self.currentAlpha) * self.alphaSpeed * elapsed

            -- Устанавливаем новую прозрачность
            fBtnFrame:SetAlpha(self.currentAlpha)
        end

        -- Сохраняем текущие координаты для следующей проверки
        self.lastX, self.lastY = x, y
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

function sendAch(id, arg, re)
    if not re then
        if nsDBC_ach:get_key(id)['dateEarned'] == "Не получена" then
            SendAddonMessage("NSQC3_ach ", id .. " " .. arg, "guild")
        end
    else
        SendAddonMessage("NSQC3_ach ", id .. " " .. arg, "guild")
    end
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

