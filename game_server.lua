-- Серверная часть мини-игры
-- Обработка сообщений от клиентов

local GameServer = {}
GameServer.__index = GameServer

function GameServer:new()
    local self = setmetatable({}, GameServer)
    return self
end

function GameServer:StartGame(ownerName, starterName)
    -- Метод принимает имена игроков и печатает их
    print("Игра началась!")
    print("Владелец участка: " .. tostring(ownerName))
    print("Тот кто стартовал: " .. tostring(starterName))
end

return GameServer
