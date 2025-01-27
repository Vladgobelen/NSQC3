-- Таблица триггеров для обработки сообщений
local triggersByAddress = {
    ["*"] = {  -- Триггер для любого сообщения
        {
            func = "OnAnyTrigger",  -- Функция для любого сообщения
            keyword = {},  -- Пустая таблица, так как ключевые слова не нужны
            conditions = {
            },
            chatType = "GUILD",
            stopOnMatch = false,  -- Не прерывать обработку других триггеров
            forbiddenWords = { "запрет", "стоп", "нельзя" }  -- Триггер не сработает, если в сообщении есть эти слова
        }
    },
    ["message:тест"] = {
        {
            keyword = {
                { word = "тест", position = 1, source = "message" }
            },
            func = "OnTestTrigger",
            chatType = "GUILD",
            stopOnMatch = true  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:MyAddon"] = {
        {
            keyword = {
                { word = "MyAddon", position = 1, source = "prefix" },
                { word = "рейд", position = 2, source = "message" }
            },
            func = "OnAddonRaidTrigger",
            conditions = {
                function(text, sender, channel, prefix) return sender == "Хефе" end  -- Отправитель должен быть "Хефе"
            },
            chatType = "ADDON",
            stopOnMatch = true  -- Прервать обработку после этого триггера
        }
    }
}

function OnAnyTrigger()
    --print('111')
end
function OnTestTrigger(text, sender, channel, prefix)
    SendChatMessage("Триггер 'тест' сработал!", "GUILD")
end

function OnAddonRaidTrigger(text, sender, channel, prefix)
    SendChatMessage("Триггер 'MyAddon:рейд' сработал!", "GUILD")
end

-- Функция-условие: проверяет, является ли игрок лидером гильдии
-- @return: true, если игрок является лидером гильдии, иначе false
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

-- Создаем экземпляр ChatHandler с таблицей триггеров и указанием типов чатов для отслеживания
local chatHandler = ChatHandler:new(triggersByAddress, {"GUILD", "ADDON"})
