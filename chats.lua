-- Таблица триггеров для обработки сообщений
local triggersByAddress = {
    ["*"] = {  -- Триггер для любого сообщения
        {
            func = "OnAnyTrigger1",  -- Функция для любого сообщения
            keyword = {},  -- Пустая таблица, так как ключевые слова не нужны
            conditions = {
            },
            chatType = {"GUILD"},
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
            chatType = {"ADDON"},
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
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsqc_RawRes1"] = {
        {
            keyword = {
                { word = "nsqc_RawRes1", position = 1, source = "prefix" },
            },
            func = "nsqc_RawRes1",
            conditions = {
                function(channel, text, sender, prefix)
                    local kodMsg = mysplit(prefix)
                    local myNome = GetUnitName("player")
                    return kodMsg[2] == myNome
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsqc_RawRes2"] = {
        {
            keyword = {
                { word = "nsqc_RawRes2", position = 1, source = "prefix" },
            },
            func = "nsqc_RawRes2",
            conditions = {
                function(channel, text, sender, prefix)
                    local kodMsg = mysplit(prefix)
                    local myNome = GetUnitName("player")
                    return kodMsg[2] == myNome
                end
            },
            chatType = {"ADDON"},
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
            chatType = {"GUILD"},  -- Тип чата, на который реагирует триггер
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
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    local myNome = GetUnitName("player")
                    return kod2 == myNome
                end
            },
            chatType = {"ADDON"},
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
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:sendObj1"] = {
        {
            keyword = {
                { word = "sendObj1", position = 1, source = "prefix" },
            },
            func = "showHPonEnter",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    local myNome = GetUnitName("player")
                    return kod2 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:sendObj2"] = {
        {
            keyword = {
                { word = "sendObj2", position = 1, source = "prefix" },
            },
            func = "showHPonEnter1",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    local myNome = GetUnitName("player")
                    return kod2 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:sendObj21"] = {
        {
            keyword = {
                { word = "sendObj21", position = 1, source = "prefix" },
            },
            func = "showHPonEnter2",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:newObjHP"] = {
        {
            keyword = {
                { word = "newObjHP", position = 1, source = "prefix" },
            },
            func = "newObjHP",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:objEnParent"] = {
        {
            keyword = {
                { word = "objEnParent", position = 1, source = "prefix" },
            },
            func = "objEnParent",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:postroit"] = {
        {
            keyword = {
                { word = "postroit", position = 1, source = "prefix" },
            },
            func = "postroit_c",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsYourLog"] = {
        {
            keyword = {
                { word = "nsYourLog", position = 1, source = "prefix" },
            },
            func = "nsYourLog",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    local myNome = GetUnitName("player")
                    return kod2 == myNome
                end,
                function(channel, text, sender, prefix)
                    if not gpDb_old then
                        return true
                    else
                        return false
                    end
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns85UID"] = {
        {
            keyword = {
                { word = "ns85UID", position = 1, source = "prefix" },
            },
            func = "ns85UID",
            conditions = {
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
}

function ns85UID(channel, text, sender, prefix)
    local name = text:match(WORD_POSITION_PATTERNS[1])
    local id = text:match(WORD_POSITION_PATTERNS[2])
    print(name, id)
end

function nsYourLog(channel, text, sender, prefix)
    local timestamp, rl, raid_id, gp, targets = text:match("^(%d+)%s+(%S+)%s+(%S+)%s+([-+]?%d+)%s+(.+)$")
    
    if not timestamp then
        print("Не удалось распарсить строку:", text)
        return
    end
    
    -- Преобразуем timestamp в "ЧЧ:ММ"
    local time = date("%H:%M", timestamp)
    
    -- Преобразуем raid_id в читаемое название (убираем цифры в начале, если есть)
    local raid = raid_id:gsub("^%d+_", "")
    
    -- Обрабатываем targets
    local decodedTargets = {}
    for word in targets:gmatch("%S+") do
        -- Проверяем, есть ли этот ID в таблице соответствия
        if gpDb and gpDb.nsUnitID_tbl and gpDb.nsUnitID_tbl[word] then
            table.insert(decodedTargets, gpDb.nsUnitID_tbl[word])
        else
            table.insert(decodedTargets, word)
        end
    end
    
    -- Собираем обратно в строку
    local finalTargets = table.concat(decodedTargets, " ")
    
    gpDb:AddLogEntry(time, gp, rl, raid, finalTargets)
end

function postroit_c(channel, text, sender, prefix)
    local id = tonumber(prefix:match(WORD_POSITION_PATTERNS[4]))
    local obj = text:match(WORD_POSITION_PATTERNS[1])
    local objHP = text:match(WORD_POSITION_PATTERNS[2])
    print(obj, objHP)
    adaptiveFrame.children[id]:SetTexture(obj, obj)
    if mFldObj:getKey(adaptiveFrame:getTexture(id)).viewHP > en10(objHP) then
        adaptiveFrame.children[id]:SetTextT(en10(objHP))
    end
    adaptiveFrame.children[id]:SetMultiLineTooltip(mFldObj:getKey(adaptiveFrame:getTexture(id)).tooltips)
    --setTooltip(BT4Button1, "Текст", 1)
end

function objEnParent(channel, text, sender, prefix)
    local nik = prefix:match(WORD_POSITION_PATTERNS[2])
    local id = tonumber(prefix:match(WORD_POSITION_PATTERNS[4]))
    local obj = text:match(WORD_POSITION_PATTERNS[1])
    local objHP = text:match(WORD_POSITION_PATTERNS[2])
    adaptiveFrame.children[id]:SetTexture(obj, obj)
    adaptiveFrame.children[id]:SetTextT(en10(objHP))
    adaptiveFrame.children[id]:SetMultiLineTooltip(mFldObj:getKey(adaptiveFrame:getTexture(id)).tooltips)
    adaptiveFrame:SetCellIcon(id, "00t", 7, "участок")
end

function newObjHP(channel, text, sender, prefix)
    local nik = prefix:match(WORD_POSITION_PATTERNS[2])
    local id = tonumber(prefix:match(WORD_POSITION_PATTERNS[4]))
    adaptiveFrame.children[id]:SetTextT(en10(text))
end

function showHPonEnter(channel, text, sender, prefix)
    j = 2
    for i = 1, 100 do
        if adaptiveFrame:getTexture(i) == text:sub(1, 3) then
            local hp = en10(text:sub(j*3-2, j*3))
            if mFldObj:getKey(adaptiveFrame:getTexture(i)).viewHP > hp then
                adaptiveFrame.children[i]:SetTextT(en10(text:sub(j*3-2, j*3)))
            end
            j = j + 1
        end
    end
end
function showHPonEnter1(channel, text, sender, prefix)
    for i = 1, 50 do
        local hp = en10(text:sub(i*3-2, i*3))
        if mFldObj:getKey(adaptiveFrame:getTexture(i)).viewHP then
            if mFldObj:getKey(adaptiveFrame:getTexture(i)).viewHP > hp then
                adaptiveFrame.children[i]:SetTextT(en10(text:sub(i*3-2, i*3)))
            end
        end
    end
end
function showHPonEnter2(channel, text, sender, prefix)
    for i = 1, 50 do
        local hp = en10(text:sub(i*3-2, i*3))
        if mFldObj:getKey(adaptiveFrame:getTexture(i+50)).viewHP then
            if mFldObj:getKey(adaptiveFrame:getTexture(i+50)).viewHP > hp then
                adaptiveFrame.children[i+50]:SetTextT(en10(text:sub(i*3-2, i*3)))
            end
        end
    end
end

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
        
        adaptiveFrame.children[i]:SetOnEnter(function()
            fBtnEnter(i, adaptiveFrame.children[i].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[i]:SetOnClick(function()
            fBtnClick(i, adaptiveFrame.children[i].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[i]:SetMultiLineTooltip(mFldObj:getKey(adaptiveFrame:getTexture(i)).tooltips)
    end
end
function displayFld2(channel, text, sender, prefix)
    for i = 1, 50 do
        local j = i + 50
        --mFld:setArg(i, text:sub((i*3)-2, i*3))
        adaptiveFrame.children[j]:SetTexture(text:sub((i*3)-2, i*3), text:sub((i*3)-2, i*3))
        adaptiveFrame.children[j]:SetMultiLineTooltip(mFldObj:getKey(adaptiveFrame:getTexture(j)).tooltips)
        adaptiveFrame.children[j]:SetOnEnter(function()
            fBtnEnter(j, adaptiveFrame.children[j].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[j]:SetOnClick(function()
            fBtnClick(j, adaptiveFrame.children[j].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[j]:SetMultiLineTooltip(mFldObj:getKey(adaptiveFrame:getTexture(j)).tooltips)
    end
    adaptiveFrame:Show()
    adaptiveFrame:SetText(mFldName .. " - участок")
    mFld:setArg("onEnterFlag", nil)
end

function nsqc_RawRes1(channel, text, sender, prefix)
    for i = 1, 50 do
        if text:sub((i*3)-2, i*3) ~= "nil" then
            adaptiveFrame:SetCellIcon(i, text:sub((i*3)-2, i*3), 7, "участок")
        end
    end
end
function nsqc_RawRes2(channel, text, sender, prefix)
    for i = 1, 50 do
        local j = i + 50
        if text:sub((i*3)-2, i*3) ~= "nil" then
            adaptiveFrame:SetCellIcon(j, text:sub((i*3)-2, i*3), 7, "участок")
        end
    end
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

function OnTestTrigger(channel, text, sender, prefix)
    SendChatMessage("Триггер 'тест' сработал!", "GUILD")
end

-- Создаем экземпляр ChatHandler с таблицей триггеров и указанием типов чатов для отслеживания
local chatHandler = ChatHandler:new(triggersByAddress, {"GUILD", "ADDON"})
