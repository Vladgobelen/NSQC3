-- Клиентская часть мини-игры
-- Отправка сигналов серверу через чат аддонов

GameClient = {}
GameClient.__index = GameClient

function GameClient:new()
    local self = setmetatable({}, GameClient)
    return self
end

function GameClient:StartGame(ownerName, starterName)
    -- Отправляем сигнал серверу через чат аддонов в гильдию
    -- Формат сообщения: START:ownerName:starterName
    local message = ownerName .. " " .. starterName
    -- Используем встроенную функцию отправки сообщений аддона через гильдию
    SendAddonMessage("NSQC3_GAME", message, "GUILD")
end

function GameClient:EndGame()
    -- Отправляем сигнал завершения игры серверу через чат аддонов в гильдию
    -- Формат сообщения: END:ownerName:starterName
    local ownerName = UnitName("player")
    local message = "END " .. ownerName
    -- Используем встроенную функцию отправки сообщений аддона через гильдию
    SendAddonMessage("NSQC3_GAME", message, "GUILD")
end