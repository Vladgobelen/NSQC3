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
            stopOnMatch = false
        }
    },
    ["message:-ачивка"] = {
        {
            keyword = {  -- Ключевые слова, которые должны быть в сообщении
                { word = "-ачивка", position = 1, source = "message" },
            },
            func = "statisticAchievment",  -- Функция, которая будет вызвана при срабатывании триггера
            conditions = {
                function(text, sender)
                    local myNome = GetUnitName("player")
                    return text:match(WORD_POSITION_LAST) == myNome
                end
            },
            chatType = {"GUILD"},  -- Тип чата, на который реагирует триггер
            stopOnMatch = false
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
                    local target = prefix:match(WORD_POSITION_PATTERNS[3])
                    local sender = prefix:match(WORD_POSITION_PATTERNS[2])
                    local myNome = GetUnitName("player")
                    if target == myNome and sender ~= myNome then
                        PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\00t.ogg")
                    end
                    return true
                end,
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
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
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:GetCurrentLocation() == "участок"
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_crftStart"] = {
        {
            keyword = {
                { word = "ns_crftStart", position = 1, source = "prefix" },
            },
            func = "ns_crftStart",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local lok = channel:match(WORD_POSITION_PATTERNS[3])
                    return adaptiveFrame:GetCurrentLocation():match(WORD_POSITION_PATTERNS[2]) == lok
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_crftFail"] = {
        {
            keyword = {
                { word = "ns_crftFail", position = 1, source = "prefix" },
            },
            func = "ns_crftFail",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local lok = channel:match(WORD_POSITION_PATTERNS[3])
                    return adaptiveFrame:GetCurrentLocation() == lok
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_crftFinish"] = {
        {
            keyword = {
                { word = "ns_crftFinish", position = 1, source = "prefix" },
            },
            func = "ns_crftFinish",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local lok = channel:match(WORD_POSITION_PATTERNS[3])
                    return adaptiveFrame:GetCurrentLocation() == lok
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsqc_00h1"] = {
        {
            keyword = {
                { word = "nsqc_00h1", position = 1, source = "prefix" },
            },
            func = "nsqc_00h1",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local lok = prefix:match(WORD_POSITION_PATTERNS[4])
                    if prefix:match(WORD_POSITION_PATTERNS[2]) == GetUnitName("player") then
                        return true
                    else
                        return adaptiveFrame:GetCurrentLocation():match(WORD_POSITION_PATTERNS[2]) == lok
                    end
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsqc_00h2"] = {
        {
            keyword = {
                { word = "nsqc_00h2", position = 1, source = "prefix" },
            },
            func = "nsqc_00h2",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local lok = prefix:match(WORD_POSITION_PATTERNS[4])
                    if prefix:match(WORD_POSITION_PATTERNS[2]) == GetUnitName("player") then
                        return true
                    else
                        return adaptiveFrame:GetCurrentLocation():match(WORD_POSITION_PATTERNS[2]) == lok
                    end
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsqc_00hNIL1"] = {
        {
            keyword = {
                { word = "nsqc_00hNIL1", position = 1, source = "prefix" },
            },
            func = "nsqc_00hNIL1",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local lok = prefix:match(WORD_POSITION_PATTERNS[4])
                    if prefix:match(WORD_POSITION_PATTERNS[2]) == GetUnitName("player") then
                        return true
                    else
                        return adaptiveFrame:GetCurrentLocation():match(WORD_POSITION_PATTERNS[2]) == lok
                    end
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsqc_00hNIL2"] = {
        {
            keyword = {
                { word = "nsqc_00hNIL2", position = 1, source = "prefix" },
            },
            func = "nsqc_00hNIL2",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local lok = prefix:match(WORD_POSITION_PATTERNS[4])
                    if prefix:match(WORD_POSITION_PATTERNS[2]) == GetUnitName("player") then
                        return true
                    else
                        return adaptiveFrame:GetCurrentLocation():match(WORD_POSITION_PATTERNS[2]) == lok
                    end
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
    ["prefix:nsqc_RawResCount"] = {
        {
            keyword = {
                { word = "nsqc_RawResCount", position = 1, source = "prefix" },
            },
            func = "nsqc_RawResCount",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[3])
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
    ["prefix:ns_0kb"] = {
        {
            keyword = {
                { word = "ns_0kb", position = 1, source = "prefix" },
            },
            func = "ns_0kb",
            conditions = {
                function(channel, text, sender, prefix)
                    local target = prefix:match(WORD_POSITION_PATTERNS[3])
                    local sender = prefix:match(WORD_POSITION_PATTERNS[2])
                    local myNome = GetUnitName("player")
                    if target == myNome and sender ~= myNome then
                        PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\0kb.ogg")
                    end
                    return true
                end,
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_0ka"] = {
        {
            keyword = {
                { word = "ns_0ka", position = 1, source = "prefix" },
            },
            func = "ns_0ka",
            conditions = {
                function(channel, text, sender, prefix)
                    local target = prefix:match(WORD_POSITION_PATTERNS[3])
                    local sender = prefix:match(WORD_POSITION_PATTERNS[2])
                    local myNome = GetUnitName("player")
                    if target == myNome and sender ~= myNome then
                        PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\0ka.ogg")
                    end
                    return true
                end,
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_q00hstart"] = {
        {
            keyword = {
                { word = "ns_q00hstart", position = 1, source = "prefix" },
            },
            func = "ns_q00hstart",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == GetUnitName("player")
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_q00hresume"] = {
        {
            keyword = {
                { word = "ns_q00hresume", position = 1, source = "prefix" },
            },
            func = "ns_q00hresume",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == GetUnitName("player")
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:nsqc_timer"] = {
        {
            keyword = {
                { word = "nsqc_timer", position = 1, source = "prefix" },
            },
            func = "nsqc_timer",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == GetUnitName("player")
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_bonusQuest"] = {
        {
            keyword = {
                { word = "ns_bonusQuest", position = 1, source = "prefix" },
            },
            func = "ns_bonusQuest",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod3 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod3 == mFldName
                end,
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == GetUnitName("player")
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_bonusQuestFinal"] = {
        {
            keyword = {
                { word = "ns_bonusQuestFinal", position = 1, source = "prefix" },
            },
            func = "ns_bonusQuestFinal",
            conditions = {
                function(channel, text, sender, prefix)
                    return adaptiveFrame:isVisible()
                end,
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == GetUnitName("player")
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:uT"] = {
        {
            keyword = {
                { word = "uT", position = 1, source = "prefix" },
            },
            func = "uT",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == GetUnitName("player")
                end,
                function(channel, text, sender, prefix)
                    return gPoint(text)
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:fS"] = {
        {
            keyword = {
                { word = "fS", position = 1, source = "prefix" },
            },
            func = "fS",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[3])
                    return kod2 == GetUnitName("player") or kod2 == "*"
                end,
                function(channel, text, sender, prefix)
                    return gPoint(text)
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:uTH"] = {
        {
            keyword = {
                { word = "uTH", position = 1, source = "prefix" },
            },
            func = "uTH",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == GetUnitName("player")
                end,
                function(channel, text, sender, prefix)
                    return gPoint(text)
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:fSF"] = {
        {
            keyword = {
                { word = "fSF", position = 1, source = "prefix" },
            },
            func = "fSF",
            conditions = {
                function(channel, text, sender, prefix)
                    return gPoint(text)
                end,
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[3])
                    print(kod2 == "*")
                    return kod2 == GetUnitName("player") or kod2 == "*"
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_setBtnM"] = {
        {
            keyword = {
                { word = "ns_setBtnM", position = 1, source = "prefix" },
            },
            func = "ns_setBtnM",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == GetUnitName("player")
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
    ["prefix:ns_qxxx"] = {
        {
            keyword = {
                { word = "ns_qxxx", position = 1, source = "prefix" },
            },
            func = "ns_qxxx",
            conditions = {
                function(channel, text, sender, prefix)
                    local kod2 = prefix:match(WORD_POSITION_PATTERNS[2])
                    return kod2 == GetUnitName("player")
                end,
            },
            chatType = {"ADDON"},
            stopOnMatch = true,  -- Прервать обработку после этого триггера
        }
    },
}

-- Обработчики аддона
function fS(channel, text, sender, full_prefix)
    adjustLayoutData(full_prefix, text, false)
end

function fSF(channel, text, sender, full_prefix)
    adjustLayoutData(full_prefix, text, true)
end

function ns_qxxx(channel, text, sender, prefix)
    questManagerClient.questWindow:Hide()
end

function statisticAchievment(channel, text, sender)
    achievementHelper:SearchAndShowAchievements(text:match(WORD_POSITION_MIDDLE), "OFFICER")
end

function ns_setBtnM(channel, text, sender, prefix)
    CreateBonusQuestTurnInButtons()
end

function uT(channel, text, sender, prefix)
    getUnixTime(prefix:match(WORD_POSITION_PATTERNS[1]), text, _, sender, false)
end

function uTH(channel, text, sender, prefix)
    getUnixTime(prefix:match(WORD_POSITION_PATTERNS[1]), text, _, sender, true)
end

function ns_bonusQuestFinal(channel, text, sender, prefix)
    questManagerClient:ShowBonusQuest(text:match("^(.*)%s+%S+$"), text:match("%S+$"))
end

function ns_bonusQuest(channel, text, sender, prefix)
    questManagerClient:GetRandomProfessionSkill()
end

function nsqc_timer(channel, text, sender, prefix)
    if text ~= "-1" then
        nsqc3Timer = tonumber(text)
        for i = 1, 100 do
            if adaptiveFrame.children[i].frame:GetNormalTexture():GetTexture():sub(-3) == "NIL" then
                nsqc3Timer = nsqc3Timer + 3600
            end
        end
    else
        nsqc3Timer = nil
    end
end

function ns_q00hresume(channel, text, sender, prefix)
    questManagerClient:ShowQuest("Хижина", "Нужно выполнить ачивку: \n" ..GetAchievementLink(tonumber(text)))
end

function ns_q00hstart(channel, text, sender, prefix)
    -- Проверяем, что text является числом (ID достижения)
    local achievementID = tonumber(text)
    
    -- Получаем информацию о достижении
    local _, name, _, completed = GetAchievementInfo(achievementID)
    local link = GetAchievementLink(achievementID)
    if not name then
        SendChatMessage(sender.. ", достижение с ID " ..achievementID.. " не найдено.", "OFFICER")
        return
    end
    
    if completed then
        SendAddonMessage("ns_achivComplit " .. mFldName, achievementID, "guild")
    else
        questManagerClient:ShowQuest("Хижина", "Нужно выполнить ачивку: \n" ..link)
        SendAddonMessage("ns_isAchiv00h ", achievementID, "guild")
    end
end

function ns_crftFinish(channel, text, sender, prefix)
    local target = prefix:match(WORD_POSITION_PATTERNS[3])
    local obj = text:match(WORD_POSITION_PATTERNS[1])
    local id = tonumber(text:match(WORD_POSITION_PATTERNS[2]))

    SendAddonMessage("NSQC3_clcl " .. mFldName .. " " .. id, "00h", "guild")
end

function ns_crftFail(channel, text, sender, prefix)
    local target = prefix:match(WORD_POSITION_PATTERNS[3])
    local obj = text:match(WORD_POSITION_PATTERNS[1])
    local id = tonumber(text:match(WORD_POSITION_PATTERNS[2]))
    SendAddonMessage("NSQC3_clcl " .. mFldName .. " " .. id, "00h", "guild")
end

function ns_crftStart(channel, text, sender, prefix)
    local target = prefix:match(WORD_POSITION_PATTERNS[3])
    local obj = text:match(WORD_POSITION_PATTERNS[1])
    local id = tonumber(text:match(WORD_POSITION_PATTERNS[2]))
    adaptiveFrame.children[id]:SetTexture(obj, obj)
end

function nsqc_00h1(channel, text, sender, prefix)
    for i = 1, 50 do
        adaptiveFrame.children[i]:SetTexture(text:sub((i*3)-2, i*3), text:sub((i*3)-2, i*3))
        
        adaptiveFrame.children[i]:SetOnEnter(function()
            fBtnEnter(i, adaptiveFrame.children[i].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[i]:SetOnClick(function()
            fBtnClick(i, adaptiveFrame.children[i].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[i]:SetMultiLineTooltip(mFldObj:getKey(adaptiveFrame:getTexture(i)).tooltips)
        adaptiveFrame.children[i]:SetTextT("")
    end
end

function nsqc_00h2(channel, text, sender, prefix)
    for i = 1, 50 do
        local j = i + 50
        adaptiveFrame.children[j]:SetTexture(text:sub((i*3)-2, i*3), text:sub((i*3)-2, i*3))
        adaptiveFrame.children[j]:SetOnEnter(function()
            fBtnEnter(j, adaptiveFrame.children[j].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[j]:SetOnClick(function()
            fBtnClick(j, adaptiveFrame.children[j].frame:GetNormalTexture():GetTexture():sub(-3))
        end)
        adaptiveFrame.children[j]:SetMultiLineTooltip(mFldObj:getKey(adaptiveFrame:getTexture(j)).tooltips)
        adaptiveFrame.children[i]:SetTextT("")
    end
    adaptiveFrame:SetText(mFldName .. " - хижина - " .. prefix:match(WORD_POSITION_PATTERNS[4]))
    mFld:setArg("onEnterFlag", nil)
    adaptiveFrame:SetupPopupTriggers()
end

function nsqc_00hNIL1(channel, text, sender, prefix)
    for i = 1, 50 do
        if text:sub((i*3)-2, i*3) == "NIL" then
            adaptiveFrame.children[i]:SetTexture(text:sub((i*3)-2, i*3), text:sub((i*3)-2, i*3))
        end
    end
end

function nsqc_00hNIL2(channel, text, sender, prefix)
    for i = 1, 50 do
        local j = i + 50
        if text:sub((i*3)-2, i*3) == "NIL" then
            adaptiveFrame.children[j]:SetTexture(text:sub((i*3)-2, i*3), text:sub((i*3)-2, i*3))
        end
    end
end

function ns_0ka(channel, text, sender, prefix)
    local id = tonumber(text:match(WORD_POSITION_PATTERNS[1]))
    local num = tonumber(text:match(WORD_POSITION_PATTERNS[2]))
    adaptiveFrame.children[id]:SetTextT(num, "808080")
end
function ns_0kb(channel, text, sender, prefix)
    local id = tonumber(text:match(WORD_POSITION_PATTERNS[1]))
    adaptiveFrame:SetCellIcon(id, "0ka", 7, "участок")
    adaptiveFrame.children[id]:SetTextT("500", "FF0000")
    PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\0kb.ogg")
end

function nsqc_RawResCount(channel, text, sender, prefix)
    local resources = {
        "Бревна", 
        "Трава", 
        "Камень", 
        "Бетон", 
        "Самогон", 
        "Доски", 
        "Кирпич"
    }
    for index, resource in ipairs(resources) do
        local current_count = adaptiveFrame:GetSideTextCount(resource)
        local new_count = tonumber(text:match(WORD_POSITION_PATTERNS[index]))
        
        if tonumber(current_count) ~= new_count then
            adaptiveFrame:RemoveSideText(resource)
            
            for i = 1, new_count do
                adaptiveFrame:AddSideText(resource)
            end
        end
    end
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
    local flag = tonumber(prefix:match(WORD_POSITION_PATTERNS[5]))
    local obj = text:match(WORD_POSITION_PATTERNS[1])
    local objHP = text:match(WORD_POSITION_PATTERNS[2])
    adaptiveFrame.children[id]:SetTexture(obj, obj)
    if mFldObj:getKey(adaptiveFrame:getTexture(id)).viewHP > en10(objHP) then
        adaptiveFrame.children[id]:SetTextT(en10(objHP))
    end
    adaptiveFrame.children[id]:SetMultiLineTooltip(mFldObj:getKey(adaptiveFrame:getTexture(id)).tooltips)
    if flag then
        adaptiveFrame:SetCellIcon(id, "00f", 7, "участок")
    end
    adaptiveFrame:SetupPopupTriggers()
end

function objEnParent(channel, text, sender, prefix)
    local nik = prefix:match(WORD_POSITION_PATTERNS[2])
    local id = tonumber(prefix:match(WORD_POSITION_PATTERNS[4]))
    local obj = text:match(WORD_POSITION_PATTERNS[1])
    local objHP = text:match(WORD_POSITION_PATTERNS[2])
    local res = text:match(WORD_POSITION_PATTERNS[3])
    adaptiveFrame.children[id]:SetTexture(obj, obj)
    if objHP ~= nil then
        adaptiveFrame.children[id]:SetTextT(en10(objHP))
    else
        adaptiveFrame.children[id]:SetTextT("")
    end
    adaptiveFrame.children[id]:SetMultiLineTooltip(mFldObj:getKey(adaptiveFrame:getTexture(id)).tooltips)
    if res ~= nil then
        adaptiveFrame:SetCellIcon(id, res, 7, "участок")
    else
        adaptiveFrame:SetCellIcon(id, nil, 7, "участок")
    end
    adaptiveFrame:SetupPopupTriggers()
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
    adaptiveFrame:SetupPopupTriggers()
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
        if i == 3 then
        end
        if text:sub((i*3)-2, i*3) ~= "nil" then
            adaptiveFrame:SetCellIcon(i, text:sub((i*3)-2, i*3), 7, "участок")
        else
            adaptiveFrame:SetCellIcon(i, nil, 7, "участок")
        end
    end
end
function nsqc_RawRes2(channel, text, sender, prefix)
    for i = 1, 50 do
        local j = i + 50
        if text:sub((i*3)-2, i*3) ~= "nil" then
            adaptiveFrame:SetCellIcon(j, text:sub((i*3)-2, i*3), 7, "участок")
        else
            adaptiveFrame:SetCellIcon(j, nil, 7, "участок")
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
