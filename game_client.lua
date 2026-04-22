-- Клиентская часть мини-игры
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
    
    -- Формат: "ВЛАДЕЛЕЦ ИГРОК"
    local message = ownerName .. " " .. starterName
    SendAddonMessage("NSQC3_GAME", message, "GUILD")
end

function GameClient:EndGame(ownerName, playerName)
    -- Формат: "END ВЛАДЕЛЕЦ ИГРОК" (полный аналог StartGame)
    local message = ownerName .. " " .. playerName
    SendAddonMessage("NSQC3_GAME_END", message, "GUILD")
end

function GameClient:IsActive()
    return self.active
end

