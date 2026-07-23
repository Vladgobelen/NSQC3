-- FilteredChat.lua
-- В .toc файле должно быть: ## SavedVariables: nsDbc

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

-- Безопасный lower для русского текста, если доступна UTF-8 функция.
local function SafeLower(text)
    if type(text) ~= "string" then
        return ""
    end

    if type(string.utf8lower) == "function" then
        return string.utf8lower(text)
    end

    return string.lower(text)
end

-- ============================================================
-- ===== Таймер без C_Timer ===================================
-- ============================================================

local FC_timers = {}

local FC_timerFrame = CreateFrame("Frame")
FC_timerFrame:Hide()
FC_timerFrame:SetScript("OnUpdate", function(self)
    local now = GetTime()

    for i = #FC_timers, 1, -1 do
        local timer = FC_timers[i]

        if timer and timer.finish <= now then
            table.remove(FC_timers, i)

            if timer.callback then
                timer.callback()
            end
        end
    end

    if #FC_timers == 0 then
        self:Hide()
    end
end)

local function FC_After(seconds, callback)
    if type(callback) ~= "function" then
        return
    end

    seconds = tonumber(seconds) or 0

    -- Защита от NaN.
    if seconds ~= seconds then
        seconds = 0
    end

    if seconds <= 0 then
        callback()
        return
    end

    table.insert(FC_timers, {
        finish = GetTime() + seconds,
        callback = callback,
    })

    FC_timerFrame:Show()
end

local function FC_Print(msg)
    local chat = DEFAULT_CHAT_FRAME or ChatFrame1
    if chat then
        chat:AddMessage(msg)
    end
end

-- ============================================================
-- ===== Ядро функции "Слои" ==================================
-- ============================================================

local FC_STRATAS = {
    "BACKGROUND",
    "LOW",
    "MEDIUM",
    "HIGH",
    "DIALOG",
    "FULLSCREEN",
    "FULLSCREEN_DIALOG",
    "TOOLTIP",
}

local FC_STRATA_NAMES = {
    BACKGROUND = "Фон (BACKGROUND)",
    LOW = "Низкий (LOW)",
    MEDIUM = "Средний (MEDIUM)",
    HIGH = "Высокий (HIGH)",
    DIALOG = "Диалог (DIALOG)",
    FULLSCREEN = "Полный экран (FULLSCREEN)",
    FULLSCREEN_DIALOG = "Полный экран, диалог (FULLSCREEN_DIALOG)",
    TOOLTIP = "Подсказка (TOOLTIP)",
}

local FC_originalLayers = {}

local FC_layerFrame
local FC_layerDropDown
local FC_layerObjectLabel
local FC_currentLayerFrame
local FC_captureToken = 0

local function FC_IsValidStrata(value)
    for _, strata in ipairs(FC_STRATAS) do
        if strata == value then
            return true
        end
    end

    return false
end

local function FC_GetStrataIndex(value)
    for i, strata in ipairs(FC_STRATAS) do
        if strata == value then
            return i
        end
    end

    return nil
end

local function FC_EnsureLayerTables()
    if type(nsDbc) ~= "table" then
        nsDbc = {}
    end

    if type(nsDbc["слои"]) ~= "table" then
        nsDbc["слои"] = {}
    end

    if type(nsDbc["слои_оригиналы"]) ~= "table" then
        nsDbc["слои_оригиналы"] = {}
    end
end

local function FC_IsUsableRegion(region)
    if not region then
        return false
    end

    if region.IsForbidden and type(region.IsForbidden) == "function" and region:IsForbidden() then
        return false
    end

    return true
end

local function FC_CanSetStrata(frame)
    if not frame or not frame.SetFrameStrata then
        return false
    end

    if frame.IsProtected
        and type(frame.IsProtected) == "function"
        and frame:IsProtected()
        and InCombatLockdown
        and InCombatLockdown() then
        return false
    end

    return true
end

local function FC_NormalizeToFrame(region)
    if not FC_IsUsableRegion(region) then
        return nil
    end

    if region.IsObjectType and region:IsObjectType("Frame") then
        return region
    end

    if region.GetParent then
        return FC_NormalizeToFrame(region:GetParent())
    end

    return nil
end

local function FC_GetMouseFrame()
    local focus

    -- Для 3.3.5 основной вариант: GetMouseFocus().
    -- GetMouseFoci оставлен на случай, если код будет использоваться в новых клиентах.
    if GetMouseFoci then
        local foci = GetMouseFoci()
        if foci and foci[1] then
            focus = foci[1]
        end
    elseif GetMouseFocus then
        focus = GetMouseFocus()
    end

    local frame = FC_NormalizeToFrame(focus)

    if not frame then
        return nil
    end

    if frame == WorldFrame or frame == UIParent then
        return nil
    end

    return frame
end

local function FC_GetObjectKey(frame)
    if not frame then
        return nil
    end

    -- Лучший вариант: фрейм имеет имя.
    if frame.GetName then
        local name = frame:GetName()
        if name and name ~= "" then
            return name
        end
    end

    -- Запасной вариант для безымянных фреймов:
    -- путь от ближайшего именованного родителя через индексы детей.
    local path = {}
    local current = frame

    while current do
        local parent = current.GetParent and current:GetParent()
        if not parent then
            break
        end

        local children = { parent:GetChildren() }
        local index

        for i, child in ipairs(children) do
            if child == current then
                index = i
                break
            end
        end

        if not index then
            return nil
        end

        table.insert(path, 1, index)

        if parent.GetName then
            local parentName = parent:GetName()
            if parentName and parentName ~= "" then
                return parentName .. "|FCChild|" .. table.concat(path, ",")
            end
        end

        current = parent
    end

    return nil
end

local function FC_GetFrameByKey(key)
    if key == nil then
        return nil
    end

    if type(key) ~= "string" then
        key = tostring(key)
    end

    if key == "" then
        return nil
    end

    -- Прямой именованный фрейм.
    local direct = _G[key]
    if direct then
        local frame = FC_NormalizeToFrame(direct)
        if frame then
            return frame
        end
    end

    -- Путь вида: ParentName|FCChild|1,3,2
    local base, path = key:match("^(.-)|FCChild|(.+)$")
    if not base or not path then
        return nil
    end

    local current = _G[base]
    if not current or not current.GetChildren then
        return nil
    end

    for indexText in path:gmatch("([^,]+)") do
        local index = tonumber(indexText)
        if not index then
            return nil
        end

        local children = { current:GetChildren() }
        current = children[index]

        if not current then
            return nil
        end
    end

    return FC_NormalizeToFrame(current)
end

local function FC_GetObjectDisplayName(frame)
    if not frame then
        return "нет объекта"
    end

    if frame.GetName then
        local name = frame:GetName()
        if name and name ~= "" then
            return name
        end
    end

    local objectType = (frame.GetObjectType and frame:GetObjectType()) or "Frame"
    local parent = frame.GetParent and frame:GetParent()

    if parent and parent.GetName then
        local parentName = parent:GetName()
        if parentName and parentName ~= "" then
            return objectType .. " внутри " .. parentName
        end
    end

    return objectType
end

local function FC_GetCaptureDelay()
    if type(nsDbc) == "table" then
        local rawDelay = nsDbc["время"]
            or nsDbc["задержка"]
            or nsDbc["таймер"]
            or nsDbc["delay"]

        local delay = tonumber(rawDelay)

        if delay and delay >= 0 then
            return delay
        end
    end

    return 5
end

local function FC_ApplySavedLayers()
    if type(nsDbc) ~= "table" then
        return
    end

    FC_EnsureLayerTables()

    for key, strata in pairs(nsDbc["слои"]) do
        if FC_IsValidStrata(strata) then
            local frame = FC_GetFrameByKey(key)

            if frame and frame.SetFrameStrata then
                if not nsDbc["слои_оригиналы"][key] then
                    nsDbc["слои_оригиналы"][key] = frame:GetFrameStrata()
                end

                if FC_CanSetStrata(frame) then
                    frame:SetFrameStrata(strata)
                end
            end
        else
            nsDbc["слои"][key] = nil
            nsDbc["слои_оригиналы"][key] = nil
        end
    end
end

local function FC_SetLayerByKey(key, strata)
    if key == nil then
        return
    end

    if not FC_IsValidStrata(strata) then
        return
    end

    FC_EnsureLayerTables()

    local frameObj = FC_GetFrameByKey(key)

    if frameObj then
        if not FC_CanSetStrata(frameObj) then
            FC_Print("|cFFFFFF00FilteredChat:|r нельзя изменить слой этого объекта сейчас.")
            return
        end

        if not nsDbc["слои_оригиналы"][key] then
            nsDbc["слои_оригиналы"][key] = frameObj.GetFrameStrata and frameObj:GetFrameStrata() or "MEDIUM"
        end

        frameObj:SetFrameStrata(strata)
    end

    nsDbc["слои"][key] = strata

    if FilteredChat_RefreshLayerList then
        FilteredChat_RefreshLayerList()
    end
end

local function FC_RemoveLayerByKey(key)
    if key == nil then
        return
    end

    FC_EnsureLayerTables()

    local frameObj = FC_GetFrameByKey(key)

    if frameObj then
        if not FC_CanSetStrata(frameObj) then
            FC_Print("|cFFFFFF00FilteredChat:|r нельзя сбросить слой этого объекта сейчас.")
            return
        end

        local restore = nsDbc["слои_оригиналы"][key]

        if not FC_IsValidStrata(restore) then
            restore = "MEDIUM"
        end

        frameObj:SetFrameStrata(restore)
    end

    nsDbc["слои"][key] = nil
    nsDbc["слои_оригиналы"][key] = nil

    if FilteredChat_RefreshLayerList then
        FilteredChat_RefreshLayerList()
    end
end

local function FC_ChangeLayerByKey(key, direction)
    if key == nil then
        return
    end

    FC_EnsureLayerTables()

    local current = nsDbc["слои"][key]
    local frameObj = FC_GetFrameByKey(key)

    if not FC_IsValidStrata(current) then
        if frameObj and frameObj.GetFrameStrata then
            current = frameObj:GetFrameStrata()
        else
            current = "MEDIUM"
        end
    end

    local currentIndex = FC_GetStrataIndex(current) or FC_GetStrataIndex("MEDIUM") or 3
    local newIndex = currentIndex + (tonumber(direction) or 0)

    if newIndex < 1 or newIndex > #FC_STRATAS then
        return
    end

    FC_SetLayerByKey(key, FC_STRATAS[newIndex])
end

-- Forward declarations, потому что UI-колбеки создаются раньше самих функций.
local FC_SetLayerForObject
local FC_RemoveLayerForObject
local FC_UpdateLayerPopup
local FC_OpenLayerPopup
local FC_StartLayerCapture

local function FC_LayerDropDown_Initialize(self, level)
    if not FC_currentLayerFrame or not FC_currentLayerFrame.GetFrameStrata then
        return
    end

    level = level or UIDROPDOWNMENU_MENU_LEVEL or UIDROPDOWN_MENU_LEVEL or 1

    local current = FC_currentLayerFrame:GetFrameStrata()

    for _, strata in ipairs(FC_STRATAS) do
        local info = UIDropDownMenu_CreateInfo and UIDropDownMenu_CreateInfo() or {}

        info.text = FC_STRATA_NAMES[strata] or strata
        info.value = strata
        info.checked = (current == strata) and 1 or nil

        info.func = function()
            if not FC_currentLayerFrame then
                return
            end

            if UIDropDownMenu_SetSelectedValue then
                UIDropDownMenu_SetSelectedValue(FC_layerDropDown, strata)
            end

            if UIDropDownMenu_SetText then
                UIDropDownMenu_SetText(FC_layerDropDown, FC_STRATA_NAMES[strata] or strata)
            end

            FC_SetLayerForObject(FC_currentLayerFrame, strata)
        end

        UIDropDownMenu_AddButton(info, level)
    end
end

-- ============================================================
-- ===== Popup-окно выбора слоя ===============================
-- ============================================================

FC_layerFrame = CreateFrame("Frame", "FilteredChatLayerFrame", UIParent)
FC_layerFrame:SetSize(360, 180)
FC_layerFrame:SetPoint("CENTER")
FC_layerFrame:SetMovable(true)
FC_layerFrame:EnableMouse(true)
FC_layerFrame:SetFrameStrata("DIALOG")

if FC_layerFrame.SetClampedToScreen then
    FC_layerFrame:SetClampedToScreen(true)
end

FC_layerFrame:Hide()

FC_layerFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = {
        left = 4,
        right = 4,
        top = 4,
        bottom = 4,
    },
})

local FC_layerTitle = FC_layerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
FC_layerTitle:SetPoint("TOP", 0, -15)
FC_layerTitle:SetText("Изменение слоя")

local FC_layerCloseBtn = CreateFrame("Button", nil, FC_layerFrame, "UIPanelCloseButton")
FC_layerCloseBtn:SetPoint("TOPRIGHT", -5, -5)
FC_layerCloseBtn:SetScript("OnClick", function()
    FC_layerFrame:Hide()
end)

FC_layerObjectLabel = FC_layerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
FC_layerObjectLabel:SetPoint("TOPLEFT", 15, -45)
FC_layerObjectLabel:SetWidth(270)
FC_layerObjectLabel:SetJustifyH("LEFT")

if FC_layerObjectLabel.SetWordWrap then
    FC_layerObjectLabel:SetWordWrap(false)
end

FC_layerObjectLabel:SetText("Объект: -")

local FC_layerUpBtn = CreateFrame("Button", nil, FC_layerFrame, "UIPanelButtonTemplate")
FC_layerUpBtn:SetSize(32, 22)
FC_layerUpBtn:SetPoint("TOPRIGHT", -15, -40)
FC_layerUpBtn:SetText("^")

FC_layerUpBtn:SetScript("OnClick", function()
    if not FC_currentLayerFrame then
        return
    end

    local parent = FC_currentLayerFrame.GetParent and FC_currentLayerFrame:GetParent()
    parent = FC_NormalizeToFrame(parent)

    if parent then
        FC_OpenLayerPopup(parent)
    else
        FC_Print("|cFFFFFF00FilteredChat:|r у объекта нет родителя выше.")
    end
end)

FC_layerUpBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("На уровень выше")
    GameTooltip:Show()
end)

FC_layerUpBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

FC_layerDropDown = CreateFrame("Frame", "FilteredChatLayerDropDown", FC_layerFrame, "UIDropDownMenuTemplate")
FC_layerDropDown:SetPoint("TOPLEFT", FC_layerObjectLabel, "BOTTOMLEFT", -15, -10)

if UIDropDownMenu_SetWidth then
    UIDropDownMenu_SetWidth(FC_layerDropDown, 220)
end

UIDropDownMenu_Initialize(FC_layerDropDown, FC_LayerDropDown_Initialize)

local FC_layerRemoveBtn = CreateFrame("Button", nil, FC_layerFrame, "UIPanelButtonTemplate")
FC_layerRemoveBtn:SetSize(32, 22)
FC_layerRemoveBtn:SetPoint("BOTTOMRIGHT", -15, 15)
FC_layerRemoveBtn:SetText("X")

FC_layerRemoveBtn:SetScript("OnClick", function()
    if FC_currentLayerFrame then
        FC_RemoveLayerForObject(FC_currentLayerFrame)
    end
end)

FC_layerRemoveBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Удалить сохраненный слой")
    GameTooltip:AddLine("Сбрасывает настройку для выбранного объекта.", 1, 1, 1, true)
    GameTooltip:Show()
end)

FC_layerRemoveBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

FC_layerFrame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end)

FC_layerFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
    end
end)

FC_layerFrame:SetScript("OnHide", function(self)
    self:StopMovingOrSizing()
end)

FC_layerFrame:SetScript("OnShow", function()
    if FC_currentLayerFrame then
        FC_UpdateLayerPopup(FC_currentLayerFrame)
    end
end)

FC_UpdateLayerPopup = function(frame)
    FC_currentLayerFrame = frame

    if not FC_layerFrame or not FC_layerObjectLabel then
        return
    end

    if not frame then
        FC_layerObjectLabel:SetText("Объект: нет объекта")
        return
    end

    FC_layerObjectLabel:SetText("Объект: " .. FC_GetObjectDisplayName(frame))

    if frame.GetFrameStrata then
        local strata = frame:GetFrameStrata()

        if FC_layerDropDown then
            if UIDropDownMenu_SetSelectedValue then
                UIDropDownMenu_SetSelectedValue(FC_layerDropDown, strata)
            end

            if UIDropDownMenu_SetText then
                UIDropDownMenu_SetText(FC_layerDropDown, FC_STRATA_NAMES[strata] or strata)
            end
        end
    end
end

FC_OpenLayerPopup = function(frame)
    frame = FC_NormalizeToFrame(frame)

    if not frame then
        FC_Print("|cFFFFFF00FilteredChat:|r не удалось выбрать объект.")
        return
    end

    if frame == UIParent or frame == WorldFrame then
        FC_Print("|cFFFFFF00FilteredChat:|r нельзя выбрать UIParent или WorldFrame.")
        return
    end

    local key = FC_GetObjectKey(frame)

    if key then
        FC_EnsureLayerTables()

        local saved = nsDbc["слои"][key]

        if saved and FC_IsValidStrata(saved) then
            if not nsDbc["слои_оригиналы"][key] then
                nsDbc["слои_оригиналы"][key] = frame.GetFrameStrata and frame:GetFrameStrata() or "MEDIUM"
            end

            if FC_CanSetStrata(frame) then
                frame:SetFrameStrata(saved)
            end
        elseif not nsDbc["слои_оригиналы"][key] then
            nsDbc["слои_оригиналы"][key] = frame.GetFrameStrata and frame:GetFrameStrata() or "MEDIUM"
        end
    end

    FC_currentLayerFrame = frame
    FC_layerFrame:Show()
    FC_UpdateLayerPopup(frame)

    if FilteredChat_RefreshLayerList then
        FilteredChat_RefreshLayerList()
    end
end

FC_SetLayerForObject = function(frame, strata)
    frame = FC_NormalizeToFrame(frame)

    if not frame or not frame.SetFrameStrata then
        return
    end

    if not FC_IsValidStrata(strata) then
        return
    end

    local key = FC_GetObjectKey(frame)

    if key then
        FC_SetLayerByKey(key, strata)

        if FC_layerFrame and FC_layerFrame:IsShown() then
            FC_UpdateLayerPopup(frame)
        end

        return
    end

    -- Объект без имени: можно применить только в текущей сессии.
    if not FC_CanSetStrata(frame) then
        FC_Print("|cFFFFFF00FilteredChat:|r нельзя изменить слой этого объекта сейчас.")
        return
    end

    if not FC_originalLayers[frame] then
        FC_originalLayers[frame] = frame:GetFrameStrata()
        FC_Print("|cFFFFFF00FilteredChat:|r объект без имени, настройка слоя не сохранится после перезагрузки.")
    end

    frame:SetFrameStrata(strata)

    if FC_layerFrame and FC_layerFrame:IsShown() then
        FC_UpdateLayerPopup(frame)
    end

    if FilteredChat_RefreshLayerList then
        FilteredChat_RefreshLayerList()
    end
end

FC_RemoveLayerForObject = function(frame)
    frame = FC_NormalizeToFrame(frame)

    if not frame then
        return
    end

    local key = FC_GetObjectKey(frame)

    if key then
        FC_RemoveLayerByKey(key)

        if FC_layerFrame and FC_layerFrame:IsShown() then
            FC_UpdateLayerPopup(frame)
        end

        return
    end

    -- Объект без имени: сброс только в текущей сессии.
    if not FC_CanSetStrata(frame) then
        FC_Print("|cFFFFFF00FilteredChat:|r нельзя сбросить слой этого объекта сейчас.")
        return
    end

    local restore = FC_originalLayers[frame]
        or (frame.GetFrameStrata and frame:GetFrameStrata())
        or "MEDIUM"

    if not FC_IsValidStrata(restore) then
        restore = "MEDIUM"
    end

    FC_originalLayers[frame] = nil
    frame:SetFrameStrata(restore)

    if FC_layerFrame and FC_layerFrame:IsShown() then
        FC_UpdateLayerPopup(frame)
    end
end

FC_StartLayerCapture = function()
    local delay = FC_GetCaptureDelay()

    FC_captureToken = FC_captureToken + 1
    local token = FC_captureToken

    if FilteredChatFrame then
        FilteredChatFrame:Hide()
    end

    if FC_layerFrame then
        FC_layerFrame:Hide()
    end

    FC_Print("|cFF00FF00FilteredChat:|r наведите мышь на объект. Захват через " .. format("%.1f", delay) .. " сек.")

    FC_After(delay, function()
        if token ~= FC_captureToken then
            return
        end

        local frame = FC_GetMouseFrame()

        if not frame then
            FC_Print("|cFFFFFF00FilteredChat:|r не удалось определить объект под курсором.")
            return
        end

        FC_OpenLayerPopup(frame)
    end)
end

-- Публичные функции для меню и slash-команд.
FilteredChat_StartLayerCapture = FC_StartLayerCapture
FilteredChat_ApplySavedLayers = FC_ApplySavedLayers

FilteredChat_CancelLayerCapture = function()
    FC_captureToken = FC_captureToken + 1
end

-- ============================================================
-- ===== Окно выбора каналов для фильтра ======================
-- ============================================================

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
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local channelTitle = channelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
channelTitle:SetPoint("TOP", 0, -15)
channelTitle:SetText("Выберите каналы")

local channelCloseBtn = CreateFrame("Button", nil, channelFrame, "UIPanelCloseButton")
channelCloseBtn:SetPoint("TOPRIGHT", -5, -5)
channelCloseBtn:SetScript("OnClick", function()
    channelFrame:Hide()
end)

local checkboxes = {}
local filterTextForChannel = ""

for i, ch in ipairs(CHANNELS) do
    local cb = CreateFrame("CheckButton", nil, channelFrame, "ChatConfigCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 20, -40 - ((i - 1) * 25))
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
    if button == "LeftButton" then
        self:StartMoving()
    end
end)

channelFrame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
    end
end)

-- ============================================================
-- ===== Функции фильтрации чата ==============================
-- ============================================================

function OpenChannelSelect()
    local rawText = FilteredChatInput:GetText()
    if not rawText then
        return
    end

    local text = rawText:match("^%s*(.-)%s*$")
    if not text or text == "" then
        return
    end

    filterTextForChannel = text

    for _, ch in ipairs(CHANNELS) do
        checkboxes[ch.event]:SetChecked(true)
    end

    channelFrame:Show()
end

local function FilterMessage(_, event, msg)
    if type(nsDbc) ~= "table" or type(nsDbc["фильтры"]) ~= "table" then
        return false
    end

    if type(msg) ~= "string" or msg == "" then
        return false
    end

    local lowerMsg = SafeLower(msg)

    for _, filterData in ipairs(nsDbc["фильтры"]) do
        if type(filterData) == "table"
            and type(filterData.text) == "string"
            and filterData.text ~= ""
            and type(filterData.channels) == "table"
            and filterData.channels[event] then

            if string.find(lowerMsg, SafeLower(filterData.text), 1, true) then
                return true
            end
        end
    end

    return false
end

-- Регистрируем фильтр для всех каналов.
if ChatFrame_AddMessageEventFilter then
    for _, ch in ipairs(CHANNELS) do
        ChatFrame_AddMessageEventFilter(ch.event, FilterMessage)
    end
end

function AddFilterWithChannels(text, channels)
    if type(text) ~= "string" then
        return
    end

    text = text:match("^%s*(.-)%s*$")
    if not text or text == "" then
        return
    end

    if type(nsDbc) ~= "table" then
        nsDbc = {}
    end

    if type(nsDbc["фильтры"]) ~= "table" then
        nsDbc["фильтры"] = {}
    end

    local lowerText = SafeLower(text)
    local newFilters = {}
    local duplicate = false

    for _, filterData in ipairs(nsDbc["фильтры"]) do
        if type(filterData) == "table"
            and type(filterData.text) == "string"
            and filterData.text ~= "" then

            if SafeLower(filterData.text) == lowerText then
                duplicate = true
            end

            table.insert(newFilters, filterData)
        end
    end

    nsDbc["фильтры"] = newFilters

    if duplicate then
        FilteredChatInput:SetText("")
        FilteredChatInput:ClearFocus()
        return
    end

    table.insert(nsDbc["фильтры"], {
        text = text,
        channels = channels,
    })

    FilteredChatInput:SetText("")
    FilteredChatInput:ClearFocus()
    RefreshFilterList()
end

function AddFilter()
    OpenChannelSelect()
end

function RemoveFilter(index)
    if type(index) ~= "number" then
        return
    end

    if type(nsDbc) ~= "table" or type(nsDbc["фильтры"]) ~= "table" then
        return
    end

    table.remove(nsDbc["фильтры"], index)
    RefreshFilterList()
end

function ClearAll()
    if type(nsDbc) ~= "table" then
        nsDbc = {}
    end

    nsDbc["фильтры"] = {}
    RefreshFilterList()
end

local function GetChannelsString(channels)
    if type(channels) ~= "table" then
        return "Все каналы"
    end

    local names = {}

    for _, ch in ipairs(CHANNELS) do
        if channels[ch.event] then
            table.insert(names, ch.name)
        end
    end

    if #names == 0 then
        return "Нет каналов"
    elseif #names == #CHANNELS then
        return "Все каналы"
    else
        return table.concat(names, ", ")
    end
end

function RefreshFilterList()
    local scrollChild = FilteredChatFilterList
    local scrollFrame = FilteredChatScrollFrame

    if not scrollChild or not scrollFrame then
        return
    end

    if type(nsDbc) ~= "table" then
        nsDbc = {}
    end

    if type(nsDbc["фильтры"]) ~= "table" then
        nsDbc["фильтры"] = {}
    end

    local children = { scrollChild:GetChildren() }
    for _, child in ipairs(children) do
        if child then
            child:Hide()
        end
    end

    local ENTRY_HEIGHT = 25
    local count = #nsDbc["фильтры"]
    scrollChild:SetHeight(math.max(count * ENTRY_HEIGHT, 10))

    for i, filterData in ipairs(nsDbc["фильтры"]) do
        if type(filterData) == "table" and type(filterData.text) == "string" then
            local btn = CreateFrame("Frame", nil, scrollChild)
            btn:SetWidth(410)
            btn:SetHeight(ENTRY_HEIGHT)
            btn:SetPoint("TOPLEFT", 0, -((i - 1) * ENTRY_HEIGHT))

            local text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            text:SetPoint("LEFT", 5, 0)
            text:SetWidth(340)
            text:SetJustifyH("LEFT")
            text:SetText(filterData.text)

            local removeBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
            removeBtn:SetWidth(25)
            removeBtn:SetHeight(20)
            removeBtn:SetPoint("RIGHT", -5, 0)
            removeBtn:SetText("-")

            local index = i
            removeBtn:SetScript("OnClick", function()
                RemoveFilter(index)
            end)

            btn:EnableMouse(true)

            btn:SetScript("OnEnter", function()
                text:SetTextColor(1, 1, 0)

                GameTooltip:SetOwner(btn, "ANCHOR_RIGHT")
                GameTooltip:SetText("Фильтр: " .. filterData.text, 1, 1, 1)
                GameTooltip:AddLine("Каналы: " .. GetChannelsString(filterData.channels), 0, 1, 0, true)
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

-- ============================================================
-- ===== Главное окно настроек с вкладками ====================
-- ============================================================

local frame = CreateFrame("Frame", "FilteredChatFrame", UIParent)
frame:SetSize(480, 420)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetFrameStrata("MEDIUM")
frame:Hide()

if frame.SetClampedToScreen then
    frame:SetClampedToScreen(true)
end

frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("Настройки FilteredChat")

local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)
closeBtn:SetScript("OnClick", function()
    frame:Hide()
end)

frame:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        self:StartMoving()
    end
end)

frame:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        self:StopMovingOrSizing()
    end
end)

frame:SetScript("OnHide", function(self)
    self:StopMovingOrSizing()
end)

-- Вкладки.
local filtersTab = CreateFrame("Frame", nil, frame)
filtersTab:SetPoint("TOPLEFT", 10, -75)
filtersTab:SetPoint("BOTTOMRIGHT", -10, 10)
filtersTab:Hide()

local framesTab = CreateFrame("Frame", nil, frame)
framesTab:SetPoint("TOPLEFT", 10, -75)
framesTab:SetPoint("BOTTOMRIGHT", -10, 10)
framesTab:Hide()

local layersTab = CreateFrame("Frame", nil, frame)
layersTab:SetPoint("TOPLEFT", 10, -75)
layersTab:SetPoint("BOTTOMRIGHT", -10, 10)
layersTab:Hide()

local tabFrames = { filtersTab, framesTab, layersTab }
local tabButtons = {}
local FC_currentTab = 1
local FC_SelectTab

FC_SelectTab = function(index)
    FC_currentTab = index

    for i, btn in ipairs(tabButtons) do
        if i == index then
            btn:Disable()
        else
            btn:Enable()
        end
    end

    for i, tabFrame in ipairs(tabFrames) do
        if i == index then
            tabFrame:Show()
        else
            tabFrame:Hide()
        end
    end

    if index == 1 then
        RefreshFilterList()
    elseif index == 3 then
        if FilteredChat_RefreshLayerList then
            FilteredChat_RefreshLayerList()
        end
    end
end

local function FC_CreateTabButton(text, index, width, relativeTo, xOffset)
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(width, 24)
    btn:SetText(text)

    if relativeTo then
        btn:SetPoint("TOPLEFT", relativeTo, "TOPRIGHT", xOffset or 5, 0)
    else
        btn:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)
    end

    btn:SetScript("OnClick", function()
        FC_SelectTab(index)
    end)

    table.insert(tabButtons, btn)

    return btn
end

local tabFilters = FC_CreateTabButton("Фильтры", 1, 110)
local tabFrames = FC_CreateTabButton("Фреймы", 2, 110, tabFilters, 5)
FC_CreateTabButton("Слои", 3, 110, tabFrames, 5)

-- ============================================================
-- ===== Вкладка "Фильтры" ====================================
-- ============================================================

local input = CreateFrame("EditBox", "FilteredChatInput", filtersTab, "InputBoxTemplate")
input:SetSize(350, 20)
input:SetPoint("TOPLEFT", 0, 0)
input:SetMaxLetters(255)
input:SetScript("OnEscapePressed", function()
    input:ClearFocus()
end)
input:SetScript("OnEnterPressed", function()
    OpenChannelSelect()
end)

local addBtn = CreateFrame("Button", nil, filtersTab, "UIPanelButtonTemplate")
addBtn:SetSize(30, 20)
addBtn:SetPoint("LEFT", input, "RIGHT", 5, 0)
addBtn:SetText("+")
addBtn:SetScript("OnClick", function()
    OpenChannelSelect()
end)

local filterScroll = CreateFrame("ScrollFrame", "FilteredChatScrollFrame", filtersTab, "UIPanelScrollFrameTemplate")
filterScroll:SetPoint("TOPLEFT", 0, -30)
filterScroll:SetPoint("BOTTOMRIGHT", -20, 40)

local filterChild = CreateFrame("Frame", "FilteredChatFilterList", filterScroll)
filterChild:SetSize(410, 10)
filterScroll:SetScrollChild(filterChild)

local clearBtn = CreateFrame("Button", nil, filtersTab, "UIPanelButtonTemplate")
clearBtn:SetSize(120, 22)
clearBtn:SetPoint("BOTTOM", 0, 10)
clearBtn:SetText("Очистить все")
clearBtn:SetScript("OnClick", function()
    ClearAll()
end)

-- ============================================================
-- ===== Вкладка "Фреймы" =====================================
-- ============================================================

-- Если у тебя уже есть своя вкладка "Фреймы" для прозрачности/перемещения,
-- перенеси её содержимое сюда.
local framesPlaceholderText = framesTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
framesPlaceholderText:SetPoint("TOP", 0, -20)
framesPlaceholderText:SetWidth(420)
framesPlaceholderText:SetJustifyH("CENTER")

if framesPlaceholderText.SetWordWrap then
    framesPlaceholderText:SetWordWrap(true)
end

framesPlaceholderText:SetText(
)

-- ============================================================
-- ===== Вкладка "Слои" =======================================
-- ============================================================

local addLayerBtn = CreateFrame("Button", nil, layersTab, "UIPanelButtonTemplate")
addLayerBtn:SetSize(160, 22)
addLayerBtn:SetPoint("TOPLEFT", 0, 0)
addLayerBtn:SetText("Добавить слой")
addLayerBtn:SetScript("OnClick", function()
    if FilteredChat_StartLayerCapture then
        FilteredChat_StartLayerCapture()
    end
end)

local refreshLayerBtn = CreateFrame("Button", nil, layersTab, "UIPanelButtonTemplate")
refreshLayerBtn:SetSize(110, 22)
refreshLayerBtn:SetPoint("LEFT", addLayerBtn, "RIGHT", 5, 0)
refreshLayerBtn:SetText("Обновить")
refreshLayerBtn:SetScript("OnClick", function()
    if FilteredChat_RefreshLayerList then
        FilteredChat_RefreshLayerList()
    end
end)

local layerScroll = CreateFrame("ScrollFrame", "FilteredChatLayerScrollFrame", layersTab, "UIPanelScrollFrameTemplate")
layerScroll:SetPoint("TOPLEFT", 0, -35)
layerScroll:SetPoint("BOTTOMRIGHT", -20, 10)

local layerChild = CreateFrame("Frame", "FilteredChatLayerList", layerScroll)
layerChild:SetSize(410, 10)
layerScroll:SetScrollChild(layerChild)

local layerEmptyText = layersTab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
layerEmptyText:SetPoint("TOP", 0, -60)
layerEmptyText:SetText("Нет сохраненных объектов.")
layerEmptyText:Hide()

function RefreshLayerList()
    local scrollChild = FilteredChatLayerList
    local scrollFrame = FilteredChatLayerScrollFrame

    if not scrollChild or not scrollFrame then
        return
    end

    FC_EnsureLayerTables()

    local children = { scrollChild:GetChildren() }
    for _, child in ipairs(children) do
        if child then
            child:Hide()
        end
    end

    local keys = {}

    for key in pairs(nsDbc["слои"]) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return tostring(a) < tostring(b)
    end)

    if #keys == 0 then
        layerEmptyText:Show()
    else
        layerEmptyText:Hide()
    end

    local ENTRY_HEIGHT = 26
    scrollChild:SetHeight(math.max(#keys * ENTRY_HEIGHT, 10))

    for i, key in ipairs(keys) do
        local strata = nsDbc["слои"][key]

        if not FC_IsValidStrata(strata) then
            strata = "MEDIUM"
        end

        local frameObj = FC_GetFrameByKey(key)
        local keyText = tostring(key)
        local displayName = frameObj and FC_GetObjectDisplayName(frameObj) or keyText

        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetWidth(410)
        row:SetHeight(ENTRY_HEIGHT)
        row:SetPoint("TOPLEFT", 0, -((i - 1) * ENTRY_HEIGHT))
        row:EnableMouse(true)

        local nameLabel = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        nameLabel:SetPoint("LEFT", 5, 0)
        nameLabel:SetWidth(210)
        nameLabel:SetJustifyH("LEFT")
        nameLabel:SetText(displayName)

        local layerLabel = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        layerLabel:SetPoint("LEFT", nameLabel, "RIGHT", 5, 0)
        layerLabel:SetWidth(110)
        layerLabel:SetJustifyH("LEFT")
        layerLabel:SetText(strata)
        layerLabel:SetTextColor(0.8, 0.8, 0.8)

        local xBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        xBtn:SetSize(24, 22)
        xBtn:SetPoint("RIGHT", -5, 0)
        xBtn:SetText("X")

        local minusBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        minusBtn:SetSize(24, 22)
        minusBtn:SetPoint("RIGHT", xBtn, "LEFT", -3, 0)
        minusBtn:SetText("-")

        local plusBtn = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        plusBtn:SetSize(24, 22)
        plusBtn:SetPoint("RIGHT", minusBtn, "LEFT", -3, 0)
        plusBtn:SetText("+")

        local strataIndex = FC_GetStrataIndex(strata) or FC_GetStrataIndex("MEDIUM") or 3

        if strataIndex >= #FC_STRATAS then
            plusBtn:Disable()
        else
            plusBtn:Enable()
        end

        if strataIndex <= 1 then
            minusBtn:Disable()
        else
            minusBtn:Enable()
        end

        plusBtn:SetScript("OnClick", function()
            FC_ChangeLayerByKey(key, 1)
        end)

        minusBtn:SetScript("OnClick", function()
            FC_ChangeLayerByKey(key, -1)
        end)

        xBtn:SetScript("OnClick", function()
            FC_RemoveLayerByKey(key)
        end)

        plusBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Повысить слой")
            GameTooltip:Show()
        end)

        plusBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        minusBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Понизить слой")
            GameTooltip:Show()
        end)

        minusBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        xBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Удалить объект")
            GameTooltip:AddLine("Удаляет объект из настроек и сбрасывает его слой.", 1, 1, 1, true)
            GameTooltip:Show()
        end)

        xBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        row:SetScript("OnEnter", function()
            nameLabel:SetTextColor(1, 1, 0)

            GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
            GameTooltip:SetText("Объект: " .. keyText, 1, 1, 1)
            GameTooltip:AddLine("Слой: " .. (FC_STRATA_NAMES[strata] or strata), 0, 1, 0)

            if frameObj then
                GameTooltip:AddLine("Объект найден.", 0, 1, 0)
            else
                GameTooltip:AddLine("Объект не найден. Он мог быть безымянным, динамическим или еще не создан.", 1, 0, 0, true)
            end

            GameTooltip:Show()
        end)

        row:SetScript("OnLeave", function()
            nameLabel:SetTextColor(1, 1, 1)
            GameTooltip:Hide()
        end)
    end

    scrollFrame:UpdateScrollChildRect()
end

FilteredChat_RefreshLayerList = RefreshLayerList

-- ============================================================
-- ===== Открытие настроек ====================================
-- ============================================================

frame:SetScript("OnShow", function()
    FC_SelectTab(FC_currentTab or 1)
end)

function FilteredChat_OpenSettings(tab)
    if not FilteredChatFrame then
        return
    end

    if tab == "layers" then
        FC_currentTab = 3
    elseif tab == "frames" then
        FC_currentTab = 2
    else
        FC_currentTab = 1
    end

    if FilteredChatFrame:IsShown() then
        FC_SelectTab(FC_currentTab)
    else
        FilteredChatFrame:Show()
    end
end

-- ============================================================
-- ===== Меню ПКМ по иконке игрока ============================
-- ============================================================

local function AddCustomMenuItems(level)
    local dropdownMenu = _G["PlayerFrameDropDown"]
    if not dropdownMenu then
        return
    end

    local menuLevel = level or UIDROPDOWNMENU_MENU_LEVEL or UIDROPDOWN_MENU_LEVEL or 1

    local info = {}
    info.text = "Фильтрация чата"
    info.func = function()
        CloseDropDownMenus()
        FilteredChat_OpenSettings("filters")
    end
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info, menuLevel)

    info = {}
    info.text = "Слои"
    info.func = function()
        CloseDropDownMenus()
        FilteredChat_OpenSettings("layers")
    end
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info, menuLevel)

    info = {}
    info.text = "Изменить слой"
    info.func = function()
        CloseDropDownMenus()

        if FilteredChat_StartLayerCapture then
            FilteredChat_StartLayerCapture()
        end
    end
    info.notCheckable = 1
    UIDropDownMenu_AddButton(info, menuLevel)
end

hooksecurefunc("ToggleDropDownMenu", function(level, value, dropDownFrame)
    if dropDownFrame and dropDownFrame.GetName and dropDownFrame:GetName() == "PlayerFrameDropDown" then
        local menuLevel = level or UIDROPDOWNMENU_MENU_LEVEL or UIDROPDOWN_MENU_LEVEL or 1

        if menuLevel == 1 then
            AddCustomMenuItems(menuLevel)
        end
    end
end)

-- ============================================================
-- ===== Слэш-команды =========================================
-- ============================================================

SLASH_FC1 = "/fc"
SlashCmdList["FC"] = function()
    if not FilteredChatFrame then
        return
    end

    if FilteredChatFrame:IsShown() then
        FilteredChatFrame:Hide()
    else
        FilteredChat_OpenSettings("filters")
    end
end

SLASH_FCLAYER1 = "/fclayer"
SlashCmdList["FCLAYER"] = function(msg)
    msg = string.lower(msg or "")

    if msg == "apply" then
        if FilteredChat_ApplySavedLayers then
            FilteredChat_ApplySavedLayers()
            FC_Print("|cFF00FF00FilteredChat:|r сохраненные слои применены.")
        end
    elseif msg == "cancel" then
        if FilteredChat_CancelLayerCapture then
            FilteredChat_CancelLayerCapture()
            FC_Print("|cFFFFFF00FilteredChat:|r захват объекта отменен.")
        end
    elseif msg == "list" then
        FilteredChat_OpenSettings("layers")
    else
        if FilteredChat_StartLayerCapture then
            FilteredChat_StartLayerCapture()
        end
    end
end

-- ============================================================
-- ===== Инициализация при загрузке ===========================
-- ============================================================

local FC_layerInit = CreateFrame("Frame")
FC_layerInit:RegisterEvent("ADDON_LOADED")
FC_layerInit:RegisterEvent("PLAYER_LOGIN")

FC_layerInit:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" then
        if addonName ~= "FilteredChat" then
            return
        end

        FC_EnsureLayerTables()
    elseif event == "PLAYER_LOGIN" then
        FC_EnsureLayerTables()

        -- Часть фреймов может появиться чуть позже.
        FC_After(1, FC_ApplySavedLayers)
        FC_After(4, FC_ApplySavedLayers)
    end
end)

-- Если код выполняется уже после входа в игру.
if IsLoggedIn() then
    FC_EnsureLayerTables()
    FC_After(1, FC_ApplySavedLayers)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "FilteredChat" then
        return
    end

    if type(nsDbc) ~= "table" then
        nsDbc = {}
    end

    if type(nsDbc["фильтры"]) ~= "table" then
        nsDbc["фильтры"] = {}
    end

    -- Конвертируем старые фильтры-строки в новый формат.
    for i, filterData in ipairs(nsDbc["фильтры"]) do
        if type(filterData) == "string" then
            local allChannels = {}

            for _, ch in ipairs(CHANNELS) do
                allChannels[ch.event] = true
            end

            nsDbc["фильтры"][i] = {
                text = filterData,
                channels = allChannels,
            }
        end
    end
end)