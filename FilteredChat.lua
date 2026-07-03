-- Список доступных каналов
local CHANNELS = {
    { name = "Офицерский", event = "CHAT_MSG_OFFICER" },
    { name = "Гильдия", event = "CHAT_MSG_GUILD" },
    { name = "Группа", event = "CHAT_MSG_PARTY" },
    { name = "Рейд", event = "CHAT_MSG_RAID" },
    { name = "Рейд лидер", event = "CHAT_MSG_RAID_LEADER" },
    { name = "Общий", event = "CHAT_MSG_SAY" },
    { name = "Крик", event = "CHAT_MSG_YELL" },
    { name = "Шепот", event = "CHAT_MSG_WHISPER" },
    { name = "Каналы", event = "CHAT_MSG_CHANNEL" },
}

-- Формат хранения фильтра: { text = "слово", channels = { ["CHAT_MSG_OFFICER"] = true, ... } }

-- Сразу создаём главное окно
local frame = CreateFrame("Frame", "FilteredChatFrame", UIParent)
frame:SetSize(320, 350)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetFrameStrata("MEDIUM")
frame:Hide()

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("Фильтрация чата")

local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

local input = CreateFrame("EditBox", "FilteredChatInput", frame, "InputBoxTemplate")
input:SetSize(250, 20)
input:SetPoint("TOPLEFT", 15, -40)
input:SetMaxLetters(255)
input:SetScript("OnEscapePressed", function() input:ClearFocus() end)
input:SetScript("OnEnterPressed", function() OpenChannelSelect() end)

local addBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
addBtn:SetSize(30, 20)
addBtn:SetPoint("LEFT", input, "RIGHT", 5, 0)
addBtn:SetText("+")
addBtn:SetScript("OnClick", function() OpenChannelSelect() end)

local scrollFrame = CreateFrame("ScrollFrame", "FilteredChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(285, 230)
scrollFrame:SetPoint("TOPLEFT", 15, -70)
scrollFrame:SetPoint("BOTTOMRIGHT", -20, 45)

local scrollChild = CreateFrame("Frame", "FilteredChatFilterList", scrollFrame)
scrollChild:SetSize(265, 230)
scrollFrame:SetScrollChild(scrollChild)

local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
clearBtn:SetSize(120, 22)
clearBtn:SetPoint("BOTTOM", 0, 12)
clearBtn:SetText("Очистить все")
clearBtn:SetScript("OnClick", function() ClearAll() end)

frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then self:StartMoving() end
end)
frame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then self:StopMovingOrSizing() end
end)
frame:SetScript("OnShow", function() RefreshFilterList() end)

-- Создание окна выбора каналов
local channelFrame = CreateFrame("Frame", nil, UIParent)
channelFrame:SetSize(250, 310)
channelFrame:SetPoint("CENTER")
channelFrame:SetMovable(true)
channelFrame:EnableMouse(true)
channelFrame:SetFrameStrata("HIGH")
channelFrame:Hide()

channelFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local channelTitle = channelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
channelTitle:SetPoint("TOP", 0, -15)
channelTitle:SetText("Выберите каналы")

local channelCloseBtn = CreateFrame("Button", nil, channelFrame, "UIPanelCloseButton")
channelCloseBtn:SetPoint("TOPRIGHT", -5, -5)
channelCloseBtn:SetScript("OnClick", function() channelFrame:Hide() end)

local checkboxes = {}
local filterTextForChannel = ""

for i, ch in ipairs(CHANNELS) do
    local cb = CreateFrame("CheckButton", nil, channelFrame, "ChatConfigCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 20, -40 - ((i-1) * 25))
    cb:SetChecked(true)
    
    local cbText = channelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cbText:SetPoint("LEFT", cb, "RIGHT", 5, 0)
    cbText:SetText(ch.name)
    
    checkboxes[ch.event] = cb
end

local saveBtn = CreateFrame("Button", nil, channelFrame, "UIPanelButtonTemplate")
saveBtn:SetSize(100, 22)
saveBtn:SetPoint("BOTTOM", 0, 15)
saveBtn:SetText("Добавить")
saveBtn:SetScript("OnClick", function()
    local channels = {}
    for _, ch in ipairs(CHANNELS) do
        if checkboxes[ch.event]:GetChecked() then
            channels[ch.event] = true
        end
    end
    
    if filterTextForChannel ~= "" then
        AddFilterWithChannels(filterTextForChannel, channels)
        channelFrame:Hide()
    end
end)

channelFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then self:StartMoving() end
end)
channelFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then self:StopMovingOrSizing() end
end)

-- Функция открытия окна выбора каналов
function OpenChannelSelect()
    local text = FilteredChatInput:GetText()
    if not text or text == "" then return end
    
    filterTextForChannel = text
    
    for _, ch in ipairs(CHANNELS) do
        checkboxes[ch.event]:SetChecked(true)
    end
    
    channelFrame:Show()
end

-- Функция фильтрации
local function FilterMessage(_, event, msg)
    if not nsDbc or not nsDbc["фильтры"] then return false end
    if not msg then return false end
    
    local lowerMsg = string.lower(msg)
    
    for _, filterData in ipairs(nsDbc["фильтры"]) do
        if filterData and filterData.text and filterData.text ~= "" then
            if filterData.channels and filterData.channels[event] then
                if string.find(lowerMsg, string.lower(filterData.text), 1, true) then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Регистрируем фильтр для всех каналов
for _, ch in ipairs(CHANNELS) do
    ChatFrame_AddMessageEventFilter(ch.event, FilterMessage)
end

-- Добавление фильтра с указанием каналов
function AddFilterWithChannels(text, channels)
    if not text or text == "" then return end
    
    if not nsDbc then nsDbc = {} end
    if not nsDbc["фильтры"] then nsDbc["фильтры"] = {} end
    
    local lowerText = string.lower(text)
    for i, filterData in ipairs(nsDbc["фильтры"]) do
        -- Пропускаем повреждённые данные
        if filterData and type(filterData) == "table" and filterData.text then
            if string.lower(filterData.text) == lowerText then
                FilteredChatInput:SetText("")
                FilteredChatInput:ClearFocus()
                return
            end
        else
            -- Удаляем повреждённые данные
            nsDbc["фильтры"][i] = nil
        end
    end
    
    -- Чистим массив от nil
    local newFilters = {}
    for _, filterData in ipairs(nsDbc["фильтры"]) do
        if filterData and type(filterData) == "table" and filterData.text then
            table.insert(newFilters, filterData)
        end
    end
    nsDbc["фильтры"] = newFilters
    
    table.insert(nsDbc["фильтры"], { text = text, channels = channels })
    FilteredChatInput:SetText("")
    FilteredChatInput:ClearFocus()
    RefreshFilterList()
end

function AddFilter()
    OpenChannelSelect()
end

function RemoveFilter(index)
    if not nsDbc or not nsDbc["фильтры"] then return end
    table.remove(nsDbc["фильтры"], index)
    RefreshFilterList()
end

function ClearAll()
    if not nsDbc then nsDbc = {} end
    nsDbc["фильтры"] = {}
    RefreshFilterList()
end

-- Получение списка каналов в виде строки
local function GetChannelsString(channels)
    if not channels then return "Все каналы" end
    
    local names = {}
    for _, ch in ipairs(CHANNELS) do
        if channels[ch.event] then
            table.insert(names, ch.name)
        end
    end
    
    if #names == 0 then return "Нет каналов"
    elseif #names == #CHANNELS then return "Все каналы"
    else return table.concat(names, ", ")
    end
end

-- Обновление списка фильтров
function RefreshFilterList()
    local scrollChild = FilteredChatFilterList
    local scrollFrame = FilteredChatScrollFrame
    
    if not scrollChild or not scrollFrame then return end
    if not nsDbc then nsDbc = {} end
    if not nsDbc["фильтры"] then nsDbc["фильтры"] = {} end
    
    local children = {scrollChild:GetChildren()}
    for _, child in ipairs(children) do
        if child then child:Hide() end
    end
    
    local ENTRY_HEIGHT = 25
    local count = #nsDbc["фильтры"]
    scrollChild:SetHeight(math.max(count * ENTRY_HEIGHT, 10))
    
    for i, filterData in ipairs(nsDbc["фильтры"]) do
        if filterData and filterData.text then
            local btn = CreateFrame("Frame", nil, scrollChild)
            btn:SetWidth(260)
            btn:SetHeight(ENTRY_HEIGHT)
            btn:SetPoint("TOPLEFT", 0, -((i-1) * ENTRY_HEIGHT))
            
            local text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            text:SetPoint("LEFT", 5, 0)
            text:SetWidth(205)
            text:SetJustifyH("LEFT")
            text:SetText(filterData.text)
            
            local removeBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
            removeBtn:SetWidth(25)
            removeBtn:SetHeight(20)
            removeBtn:SetPoint("RIGHT", -5, 0)
            removeBtn:SetText("-")
            
            local index = i
            removeBtn:SetScript("OnClick", function() RemoveFilter(index) end)
            
            btn:EnableMouse(true)
            btn:SetScript("OnEnter", function()
                text:SetTextColor(1, 1, 0)
                GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                GameTooltip:SetText("Фильтр: " .. filterData.text, 1, 1, 1)
                GameTooltip:AddLine("Каналы: " .. GetChannelsString(filterData.channels), 0, 1, 0)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function()
                text:SetTextColor(1, 1, 1)
                GameTooltip:Hide()
            end)
        end
    end
    
    scrollFrame:UpdateScrollChildRect()
end

-- Меню ПКМ по иконке
local function AddCustomMenuItems()
    local dropdownMenu = _G["PlayerFrameDropDown"]
    if not dropdownMenu then return end
    
    local info = {}
    info.text = "Фильтрация чата"
    info.func = function()
        CloseDropDownMenus()
        if FilteredChatFrame then FilteredChatFrame:Show() end
    end
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL)
end

hooksecurefunc("ToggleDropDownMenu", function(level, value, dropDownFrame)
    if dropDownFrame and dropDownFrame:GetName() == "PlayerFrameDropDown" then
        AddCustomMenuItems()
    end
end)

-- Слэш-команды
SLASH_FC1 = "/fc"
SlashCmdList["FC"] = function()
    if FilteredChatFrame then
        if FilteredChatFrame:IsShown() then
            FilteredChatFrame:Hide()
        else
            FilteredChatFrame:Show()
        end
    end
end

-- Инициализация при загрузке
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "FilteredChat" then return end
    if not nsDbc then nsDbc = {} end
    if not nsDbc["фильтры"] then nsDbc["фильтры"] = {} end
    
    -- Конвертируем старые фильтры (строки) в новый формат
    for i, filterData in ipairs(nsDbc["фильтры"]) do
        if type(filterData) == "string" then
            local allChannels = {}
            for _, ch in ipairs(CHANNELS) do
                allChannels[ch.event] = true
            end
            nsDbc["фильтры"][i] = { text = filterData, channels = allChannels }
        end
    end
end)