-- Таблица триггеров для обработки сообщений
local triggersByAddress = {
    ["*"] = {  -- Триггер для любого сообщения
        {
            func = "OnAnyTrigger1",  -- Функция для любого сообщения
            keyword = {},  -- Пустая таблица, так как ключевые слова не нужны
            conditions = {
            },
            chatType = { "GUILD"},
            stopOnMatch = false,  -- Не прерывать обработку других триггеров
            forbiddenWords = {},  -- Триггер не сработает, если в сообщении есть эти слова
        }
    },
    ["prefix:nsqc_fld1"] = {
        {
            keyword = {
                { word = "nsqc_fld1", position = 1, source = "prefix" },
            },
            func = "displayFld1",
            conditions = {
                function(channel, text, sender, prefix)
                    local kodMsg = mysplit(prefix)
                    local myNome = GetUnitName("player")
                    return kodMsg[2] == myNome
                end
            },
            chatType = { "ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsqc_fld2"] = {
        {
            keyword = {
                { word = "nsqc_fld2", position = 1, source = "prefix" },
            },
            func = "displayFld2",
            conditions = {
                function(channel, text, sender, prefix)
                    local kodMsg = mysplit(prefix)
                    local myNome = GetUnitName("player")
                    return kodMsg[2] == myNome
                end
            },
            chatType = { "ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["message:\"стат"] = {
        {
            keyword = {  -- Ключевые слова, которые должны быть в сообщении
                { word = "\"стат", position = 1, source = "message" },  -- Первое слово должно быть "\"стат"
                { word = "ачивка", position = 2, source = "message" },  -- Второе слово должно быть "количество"
            },
            func = "sendAchRez",  -- Функция, которая будет вызвана при срабатывании триггера
            conditions = {
                function(channel, text, sender, prefix)
                    local msg = mysplit(text)
                    for i = 1, customAchievements:GetAchievementCount() do
                        if string.find(customAchievements:GetAchievementFullData(i)["name"]:lower(), msg[3]:lower()) then
                            customAchievements:SendAchievementCompletionMessage(i)
                            return true
                        end
                    end
                end
            },
            chatType = { "GUILD"},  -- Тип чата, на который реагирует триггер
            stopOnMatch = false  -- Прервать обработку других триггеров после срабатывания этого222
        }
    },
    ["prefix:NSQC3_ach_сomp"] = {
        {
            keyword = {
                { word = "NSQC3_ach_сomp", position = 1, source = "prefix" },
            },
            func = "achive_complit",
            conditions = {
                function(channel, text, sender, prefix)
                    local kodMsg = mysplit(prefix)
                    local myNome = GetUnitName("player")
                    return kodMsg[2] == myNome
                end
            },
            chatType = { "ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:sendPoint"] = {
        {
            keyword = {
                { word = "sendPoint", position = 1, source = "prefix" },
            },
            func = "sendPoint",
            conditions = {
            },
            chatType = { "ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    }
}

function sendPoint(channel, text, sender, prefix)
    local temp = mysplit(text)
    mFld:setArg("gPoint", temp)
end

function achive_complit(channel, text, sender, prefix)
    local kodMsg = mysplit(prefix)
    kodMsg[3] = tonumber(kodMsg[3]) -- 
    if kodMsg[3] == -1 then
        --customAchievements:AddAchievement(msg[1])
        customAchievements:setData(text, "dateEarned", date("%d/%m/%Y %H:%M"))
        customAchievements:setData(text, "dateCompleted", date("%d/%m/%Y %H:%M"))
        customAchievements:ShowAchievementAlert(text)
        PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\lvlUp.ogg")
    else
        if customAchievements:GetAchievementData(text)["dateEarned"] == "Не получена" then
            customAchievements:setData(text, "dateEarned", date("%d/%m/%Y %H:%M"))
        end
        customAchievements:setData(text, "dateCompleted", kodMsg[3])
    end
end

function displayFld1(channel, text, sender, prefix)
    for i = 1, 50 do
        --mFld:setArg(i, text:sub((i*3)-2, i*3))
        adaptiveFrame.children[i]:SetTexture(text:sub((i*3)-2, i*3), text:sub((i*3)-2, i*3))
        adaptiveFrame.children[i]:SetMultiLineTooltip(mFldObj:get_key(adaptiveFrame:getTexture(i)).tooltips)
        adaptiveFrame.children[i]:SetOnEnter(function()
            fBtnEnter(i, adaptiveFrame.children[i].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[i]:SetOnClick(function()
            fBtnClick(i, adaptiveFrame.children[i].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
    end
end
function displayFld2(channel, text, sender, prefix)
    for i = 1, 50 do
        local j = i + 50
        --mFld:setArg(i, text:sub((i*3)-2, i*3))
        adaptiveFrame.children[j]:SetTexture(text:sub((i*3)-2, i*3), text:sub((i*3)-2, i*3))
        adaptiveFrame.children[j]:SetMultiLineTooltip(mFldObj:get_key(adaptiveFrame:getTexture(j)).tooltips)
        adaptiveFrame.children[j]:SetOnEnter(function()
            fBtnEnter(j, adaptiveFrame.children[j].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[j]:SetOnClick(function()
            fBtnClick(j, adaptiveFrame.children[j].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
    end
    adaptiveFrame:Show()
end

function OnAnyTrigger1(channel, text, sender, prefix)
    local myNome = GetUnitName("player")
    if myNome == sender then
        sendAch("Копирайтер", 1, 1)
    end
    -- local msg = mysplit(text)
    -- if string.find(string.lower(text), "привет") then
    --     infoFrame1 = infoFrame1 or UniversalInfoFrame:new(5, testQ['uniFrame'])
    --     infoFrame1:AddText("Клиент", 'GetAddOnMemoryUsage("NSQS")', true)
    --     print(sender .. " написал: " .. text)
    -- end
end
function OnAnyTrigger2(channel, text, sender, prefix)
    -- local msg = mysplit(text)
    -- if string.lower(msg[1]) == "привет" then
    -- if string.find(string.lower(text), "привет") then
    --     SendChatMessage(sender .. " написал: " .. text, "CHANNEL", nil, 5)
    -- end
end
function OnAnyTrigger3(channel, text, sender, prefix)
    -- local msg = mysplit(text)
    -- if string.lower(msg[1]) == "привет" then
    --     SendChatMessage(sender .. " написал: " .. text, "CHANNEL", nil, 5)
    -- end
end

function OnTestTrigger(channel, text, sender, prefix)
    SendChatMessage("Триггер 'тест' сработал!", "GUILD")
end

-- Создаем экземпляр ChatHandler с таблицей триггеров и указанием типов чатов для отслеживания
local chatHandler = ChatHandler:new(triggersByAddress, {"GUILD", "ADDON"})
