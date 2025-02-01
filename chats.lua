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
    ["prefix:nsqc_fld1"] = {
        {
            keyword = {
                { word = "nsqc_fld1", position = 1, source = "prefix" },
            },
            func = "displayFld1",
            conditions = {
                function(text, sender, channel, prefix)
                    local kodMsg = mysplit(prefix)
                    local myNome = GetUnitName("player")
                    return kodMsg[2] == myNome
                end
            },
            chatType = "ADDON",
            stopOnMatch = true  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsqc_fld2"] = {
        {
            keyword = {
                { word = "nsqc_fld2", position = 1, source = "prefix" },
            },
            func = "displayFld2",
            conditions = {
                function(text, sender, channel, prefix)
                    local kodMsg = mysplit(prefix)
                    local myNome = GetUnitName("player")
                    return kodMsg[2] == myNome
                end
            },
            chatType = "ADDON",
            stopOnMatch = true  -- Прервать обработку после этого триггера
        }
    }
}

function displayFld1(text, sender, channel, prefix)
    mFld = AdaptiveFrame:new()
    for i = 1, 50 do
        mFld:setArg(i, text:sub((i*3)-2, i*3))
        nsqc_fBtn[i]:SetTexture(text:sub((i*3)-2, i*3), text:sub((i*3)-2, i*3))
    end
end
function displayFld2(text, sender, channel, prefix)
    for i = 1, 50 do
        mFld:setArg(i+50, text:sub((i*3)-2, i*3))      
        nsqc_fBtn[i+50]:SetTexture(text:sub((i*3)-2, i*3), text:sub((i*3)-2, i*3))
    end
    fBtnFrame:Show()
end

function OnAnyTrigger()
    --print('111')
end
function OnTestTrigger(text, sender, channel, prefix)
    SendChatMessage("Триггер 'тест' сработал!", "GUILD")
end

-- Функция-условие: проверяет, является ли игрок лидером гильдии
-- @return: true, если игрок является лидером гильдии, иначе false


-- Создаем экземпляр ChatHandler с таблицей триггеров и указанием типов чатов для отслеживания
local chatHandler = ChatHandler:new(triggersByAddress, {"GUILD", "ADDON"})
