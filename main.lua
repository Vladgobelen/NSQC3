NSQC3_version = 1; NSQC3_subversion = 0 
-- Функция обработки события PLAYER_ENTERING_WORLD
-- @param self: Фрейм, который вызвал событие
-- @param event: Тип события (в данном случае "PLAYER_ENTERING_WORLD")
-- @param isLogin: Флаг, указывающий, что игрок вошел в мир
-- @param isReload: Флаг, указывающий, что интерфейс был перезагружен
local function OnEvent(self, event, isLogin, isReload)
    if arg1 == "NSQC3" then
        NSQCMenu()          -- Вызов функции для отображения меню
        createFld()
        mFld = mDB:new()
        getPoint()
        nsDbc = nsDbc or {}
        nsDBC_table = nsDBC_table or create_table:new("nsDbc")
        nsDBC_settings = nsDBC_settings or NsDb:new(nsDBC_table:get_table(), nil, "настройки", nil, 100000)
        nsDBC_ach_table = nsDBC_ach_table or create_table:new("nsqc3_ach")
        nsDBC_ach = nsDBC_ach or NsDb:new(nsDBC_ach_table:get_table(), nil, nil, nil, 100000)
        set_miniButton()    -- Вызов функции для настройки мини-кнопки
        CustomAchievementsStatic = {
            ["Общие"] = {
                ["Великий открыватор"] = {
                    index = 1,
                    uniqueIndex = 1,  -- Уникальный индекс
                    name = "Великий открыватор",
                    description = "Найдите кнопку аддона у миникарты и нажмите ее jkfdjskfjdk jkfdjskfj;dskjf fjkdsjfk;dsjfk fjdksjfkdsjfk;ds fdkjsfk dskfjdsf",
                    texture = "Interface\\AddOns\\NSQC3\\emblem.tga",
                    rewardPoints = 1,
                    requiredAchievements = {},
                    send_txt = "нашел кнопку гильдейского аддона и даже сам открыл ее. В первый раз!",
                    category = "Общие",
                },
            },
            ["Чат"] = {
                ["Копирайтер"] = {
                    index = 2,
                    uniqueIndex = 2,  -- Уникальный индекс
                    name = "Копирайтер",
                    description = "Пишите в гильдчате",
                    texture = "Interface\\AddOns\\NSQC3\\libs\\chat_master.tga",
                    rewardPoints = 50,
                    requiredAchievements = {},
                    send_txt = "",
                    subAchievements = {"Пассив", "Актив", "Не читатель", "Нейросеть"},
                    category = "Чат"
                },
                ["Пассив"] = {
                    index = 3,
                    uniqueIndex = 3,  -- Уникальный индекс
                    name = "Пассив",
                    description = "Напишите 100 сообщений в гильдчате",
                    texture = "Interface\\AddOns\\NSQC3\\libs\\100.tga",
                    rewardPoints = 1,
                    requiredAchievements = {},
                    send_txt = "",
                    category = "Чат"
                },
                ["Актив"] = {
                    index = 4,
                    uniqueIndex = 4,  -- Уникальный индекс
                    name = "Актив",
                    description = "Напишите 1000 сообщений в гильдчате",
                    texture = "Interface\\AddOns\\NSQC3\\libs\\1000.tga",
                    rewardPoints = 5,
                    requiredAchievements = {},
                    send_txt = "",
                    category = "Чат"
                },
                ["Не читатель"] = {
                    index = 5,
                    uniqueIndex = 5,  -- Уникальный индекс
                    name = "Не читатель",
                    description = "Напишите 10000 сообщений в гильдчате",
                    texture = "Interface\\AddOns\\NSQC3\\libs\\10000.tga",
                    rewardPoints = 10,
                    requiredAchievements = {},
                    send_txt = "",
                    category = "Чат"
                },
                ["Нейросеть"] = {
                    index = 6,
                    uniqueIndex = 6,  -- Уникальный индекс
                    name = "Нейросеть",
                    description = "Напишите 100000 сообщений в гильдчате",
                    texture = "Interface\\AddOns\\NSQC3\\libs\\100000.tga",
                    rewardPoints = 50,
                    requiredAchievements = {},
                    send_txt = "",
                    category = "Чат"
                },
            },
            ["Поле"] = {
                ["Медитация"] = {
                    index = 7,
                    uniqueIndex = 7,  -- Уникальный индекс
                    name = "Медитация",
                    description = "Кликайте всякое",
                    texture = "Interface\\AddOns\\NSQC3\\libs\\click.tga",
                    rewardPoints = 50,
                    requiredAchievements = {},
                    send_txt = "",
                    category = "Поле",
                    subAchievements = {3, 4, 5, 6},
                },
            }
        }
        C_Timer(5, function()
            if AchievementMicroButton:IsEnabled() == 1 then
                AchievementMicroButton:Click()
                AchievementFrameCloseButton:Click()
            end
        end)
    end
    if arg1 == "Blizzard_AchievementUI" then
        setFrameAchiv()
    end
    --self:UnregisterEvent("ADDON_LOADED")
end

-- Создаем фрейм и регистрируем событие PLAYER_ENTERING_WORLD
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnEvent)





-- function CreateButtonsFromTable(buttonsTable)
--     for buttonName, buttonParams in pairs(buttonsTable) do
--         -- Создаем кнопку
--         local button = ButtonManager:new(
--             buttonName, -- Имя кнопки
--             buttonParams.parent, -- Родительский фрейм
--             buttonParams.size.width, -- Ширина
--             buttonParams.size.height, -- Высота
--             buttonParams.text, -- Текст
--             buttonParams.texture -- Текстура (если есть)
--         )

--         -- Устанавливаем позицию кнопки
--         if buttonParams.position then
--             button:SetPosition(
--                 buttonParams.position[1], -- Точка привязки
--                 buttonParams.position[2], -- Относительный фрейм
--                 buttonParams.position[3], -- Относительная точка
--                 buttonParams.position[4], -- Смещение по X
--                 buttonParams.position[5]  -- Смещение по Y
--             )
--         end

--         -- Устанавливаем обработчик нажатия
--         if buttonParams.onClick then
--             button:SetOnClick(buttonParams.onClick)
--         end

--         buttonParams:SetScript("OnMouseWheel", function(self, delta)
--             print(arg1,arg2,arg3,arg4)
--         end)

--         -- Устанавливаем обработчик OnEnter, если он указан
--         if buttonParams.OnEnter then
--             button.frame:SetScript("OnEnter", buttonParams.OnEnter)
--             button.frame:SetScript("OnLeave", function()
--                 GameTooltip:Hide()
--             end)
--         end

--         -- Делаем кнопку перемещаемой, если movable = true
--         if buttonParams.movable then
--             button:SetMovable(true)
--         else
--             button:SetMovable(false)
--         end
--     end
-- end

-- addonButtons = {
--     ["myButton"] = {
--         size = {width = 64, height = 64},
--         parent = UIParent,
--         position = {"CENTER", nil, "CENTER", 0, 0},
--         text = "Абвг",
--         texture = "Interface\\AddOns\\NSQC\\emblem.tga",
--         onClick = function()
--             print(">")
--         end,
--         OnEnter = function(self)
--             GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--             GameTooltip:SetText("Это моя кнопка")
--             GameTooltip:Show()
--         end,
--         movable = true, -- Кнопка перемещаемая
--     },
--     ["Кнопка2"] = {
--         size = {width = 120, height = 40},
--         parent = UIParent,
--         position = {"CENTER", nil, "CENTER", 0, -50},
--         text = "Еще кнопка",
--         onClick = function()
--             print("Вторая кнопка нажата!")
--         end,
--         OnEnter = function(self)
--             GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
--             GameTooltip:SetText("Это вторая кнопка")
--             GameTooltip:AddLine("Дополнительная информация", 1, 1, 1, true)
--             GameTooltip:Show()
--         end,
--         movable = false, -- Кнопка не перемещаемая
--     },
-- }

-- CreateButtonsFromTable(addonButtons)




