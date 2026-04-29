GameClient = {}
GameClient.__index = GameClient

function GameClient:new()
    local self = setmetatable({}, GameClient)
    self.active = false
    self.ownerName = nil
    self.starterName = nil
    return self
end

function GameClient:StartGame(ownerName, starterName)
    self.ownerName = ownerName
    self.starterName = starterName
    self.active = true
    SendAddonMessage("NSQC3_GAME", ownerName .. " " .. starterName, "GUILD")
end

function GameClient:EndGame(ownerName, playerName)
    self.active = false
    if ns_game_table then
        ns_game_table.active = false
        ns_game_table.winner = ownerName
    end
    local message = ownerName .. " " .. playerName
    SendAddonMessage("NSQC3_GAME_END", message, "GUILD")
end

function GameClient:IsActive()
    return self.active
end

-- ============================================
-- ДЕЙСТВИЯ С ДОСКОЙ
-- ============================================
function GameClient:DoAction(a, p)
    if not self.active then return end
    if not adaptiveFrame or not adaptiveFrame.children or not ns_game_table then return end
    
    local f, t, v, o = p.f or 0, p.t or 0, p.v or 0, p.o or ""
    
    local r, g, b = 1, 1, 1
    if ns_game_table.name1 and o == ns_game_table.name1 then r, g, b = 1, 0.25, 0.25
    elseif ns_game_table.name2 and o == ns_game_table.name2 then r, g, b = 0.25, 0.55, 1 end
    
    if a == "M" or a == "C" then
        PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\dices.mp3")
        if f and f ~= 0 then self:_Clear(f) end
        if a == "C" then self:_Clear(t) end
        self:_Set(t, v, o, r, g, b)
        self:_Glow(f, t, r, g, b)
    elseif a == "S" then
        self:_Set(t, v, o, r, g, b)
    elseif a == "R" then
        self:_Clear(f)
    end
end

-- ============================================
-- ПОДСВЕТКА ВОЗМОЖНЫХ ХОДОВ
-- ============================================
function GameClient:HighlightMoves(g, r, f)
    local a = adaptiveFrame
    if not a or not a.children then return end
    
    self:_ClearHighlights()
    
    local s = _G.ns_move_st
    s.ac = f
    s.hl = {}
    
    local onGreen = _G.ns_game_funcs._onGreenClick
    local onRed = _G.ns_game_funcs._onRedClick
    local onClear = _G.ns_game_funcs._onClear
    
    for _, x in ipairs(g) do
        local b = a.children[x]
        if b and b.frame then
            local t = b.frame:GetNormalTexture()
            if t then t:SetVertexColor(0.2, 1, 0.2) end
            table.insert(s.hl, x)
            b._oc = b.frame:GetScript("OnClick")
            b.frame:SetScript("OnClick", function(_, k)
                if k == "RightButton" then
                    if onClear then onClear() end
                    self:_ClearHighlights()
                    return
                end
                if onGreen then onGreen(f, x) end
                self:_ClearHighlights()
            end)
        end
    end
    
    for _, x in ipairs(r) do
        local b = a.children[x]
        if b and b.frame then
            local t = b.frame:GetNormalTexture()
            if t then t:SetVertexColor(1, 0.2, 0.2) end
            table.insert(s.hl, x)
            b._oc = b.frame:GetScript("OnClick")
            b.frame:SetScript("OnClick", function(_, k)
                if k == "RightButton" then
                    if onClear then onClear() end
                    self:_ClearHighlights()
                    return
                end
                if onRed then onRed(f, x) end
                self:_ClearHighlights()
            end)
        end
    end
end

-- ============================================
-- ПРИВАТНЫЕ МЕТОДЫ
-- ============================================
function GameClient:_Clear(x)
    if not x or x == 0 then return end
    local c = adaptiveFrame.children[x]
    if not c or not c.SetTexture then return end
    
    if c.frame._Border then c.frame._Border:Hide() end
    c.frame:SetScript("OnUpdate", nil)
    c.frame:SetAlpha(1)
    
    local bd = ns_game_table.board[x]
    local bg = bd and bd.miniTex
    if (not bg or bg == "") and adaptiveFrame.GetCellIcon and type(adaptiveFrame.GetCellIcon) == "function" then 
        bg = adaptiveFrame:GetCellIcon(x, 2) 
    end
    if (not bg or bg == "") then
        local nt = c.frame:GetNormalTexture()
        if nt then 
            local pt = nt:GetTexture() 
            if pt then 
                bg = pt:match("([^\\/]+)$") 
                if bg then bg = bg:gsub("%%.tga$", "") end 
            end 
        end
    end
    if bg and bg ~= "" then 
        c:SetTexture(bg, bg) 
    else 
        c.frame:SetNormalTexture(nil) 
    end
    if c.SetTextT then c:SetTextT("") end
    if c.SetMultiLineTooltip then c:SetMultiLineTooltip({}) end
    if c.SetOnEnter then c:SetOnEnter(function() end) end
    if c.SetOnClick then c:SetOnClick(function() end) end
    if adaptiveFrame.SetCellIcon then adaptiveFrame:SetCellIcon(x, nil, 2) end
    ns_game_table.board[x] = nil
end

function GameClient:_Set(x, v, o, r, g, b)
    if not x or x == 0 then return end
    local c = adaptiveFrame.children[x]
    if not c or not c.SetTexture then return end
    
    local bgName = nil
    local nt = c.frame:GetNormalTexture()
    if nt then 
        local pt = nt:GetTexture() 
        if pt then 
            bgName = pt:match("([^\\/]+)$") 
            if bgName then bgName = bgName:gsub("%%.tga$", "") end 
        end 
    end
    if (not bgName or bgName == "" or bgName == tostring(v)) then 
        local bd = ns_game_table.board[x]
        bgName = bd and bd.miniTex 
    end
    if (not bgName or bgName == "") and adaptiveFrame.GetCellIcon and type(adaptiveFrame.GetCellIcon) == "function" then 
        bgName = adaptiveFrame:GetCellIcon(x, 2) 
    end
    
    c:SetTexture(tostring(v), tostring(v))
    
    if not c.frame._Border then
        c.frame._Border = CreateFrame("Frame", nil, c.frame)
        c.frame._Border:SetAllPoints()
        c.frame._Border:SetFrameLevel(c.frame:GetFrameLevel() + 2)
        c.frame._Border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 3, insets = {left = 3, right = 3, top = 3, bottom = 3}})
    end
    c.frame._Border:SetBackdropBorderColor(r, g, b, 1)
    c.frame._Border:Show()
    
    if adaptiveFrame.SetCellIcon then adaptiveFrame:SetCellIcon(x, bgName, 2, nil, true) end
    
    local tt = "Кость: " .. v .. "\nВладелец: " .. o
    if c.SetTextT then c:SetTextT("") end
    if c.SetMultiLineTooltip then c:SetMultiLineTooltip({tt}) end
    if c.SetOnClick then c:SetOnClick(function() if type(fBtnClick) == "function" then fBtnClick(x, tostring(v)) end end) end
    
    ns_game_table.board[x] = {dice = v, owner = o, miniTex = bgName, mainTex = tostring(v), lastUpdated = GetTime(), cellIndex = x}
end

function GameClient:_Glow(f, t, r, g, b)
    self:_ClearGlow()
    self._lh = {}
    
    local function pulse(x)
        if not x or x == 0 then return end
        local c = adaptiveFrame.children[x]
        if not c or not c.frame then return end
        
        table.insert(self._lh, x)
        local startTime = GetTime()
        
        c.frame:SetScript("OnUpdate", function(frame)
            local elapsed = GetTime() - startTime
            if elapsed > 3 then
                frame:SetAlpha(1)
                frame:SetScript("OnUpdate", nil)
                return
            end
            frame:SetAlpha(0.3 + 0.7 * math.abs(math.sin(elapsed * 6)))
        end)
    end
    
    pulse(f)
    pulse(t)
end

function GameClient:_ClearHighlights()
    local s = _G.ns_move_st
    if s and s.hl then
        for _, x in ipairs(s.hl) do
            local b = adaptiveFrame and adaptiveFrame.children and adaptiveFrame.children[x]
            if b and b.frame then
                local t = b.frame:GetNormalTexture()
                if t then t:SetVertexColor(1, 1, 1) end
                b.frame:SetScript("OnClick", b._oc)
                b._oc = nil
            end
        end
    end
    if s then s.ac = nil; s.hl = nil end
end

function GameClient:_ClearGlow()
    if self._lh then
        for _, x in ipairs(self._lh) do
            local c = adaptiveFrame and adaptiveFrame.children and adaptiveFrame.children[x]
            if c and c.frame then
                c.frame:SetScript("OnUpdate", nil)
                c.frame:SetAlpha(1)
            end
        end
    end
    self._lh = nil
end