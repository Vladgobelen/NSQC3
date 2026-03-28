-- Клиентская часть мини-игры
-- Отправка сигналов серверу через чат аддонов

local GameClient = {}
GameClient.__index = GameClient

function GameClient:new()
    local self = setmetatable({}, GameClient)
    return self
end

function GameClient:StartGame(ownerName, starterName)
    -- Отправляем сигнал серверу через чат аддонов в гильдию
    -- Формат сообщения: START:ownerName:starterName
    local message = "START:" .. ownerName .. ":" .. starterName
    
    -- Используем встроенную функцию отправки сообщений аддона через гильдию
    SendAddonMessage("NSQC3_GAME", message, "GUILD")
end

return GameClient