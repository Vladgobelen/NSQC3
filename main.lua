-- Функция обработки события PLAYER_ENTERING_WORLD
-- @param self: Фрейм, который вызвал событие
-- @param event: Тип события (в данном случае "PLAYER_ENTERING_WORLD")
-- @param isLogin: Флаг, указывающий, что игрок вошел в мир
-- @param isReload: Флаг, указывающий, что интерфейс был перезагружен
local function OnEvent(self, event, isLogin, isReload)
    if arg1 == "NSQC3" then
        NSQCMenu()          -- Вызов функции для отображения меню
        set_miniButton()    -- Вызов функции для настройки мини-кнопки
        createFld()
        nsqc3_ach = nsqc3_ach or {}
    end
    if arg1 == "Blizzard_AchievementUI" then
        setFrameAchiv()
        customAchievements:AddAchievement(
            1,
            "Охотник на тени1",
            "Победите 100 теневых существ\nДополнительная строка\nЕще одна строка",
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            100,
            "2023-10-01",
            "2023-10-05",
            100
        )
        customAchievements:AddAchievement(
            2,
            "Охотник на тени2",
            "Победите 100 теневых существ\nДополнительная строка\nЕще одна строка",
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            10,
            "2023-10-01",
            nil,
            100
        )
        customAchievements:AddAchievement(
            3,
            "Охотник на тени1",
            "Победите 100 теневых существ\nДополнительная строка\nЕще одна строка",
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            88,
            "2023-10-01",
            nil,
            150
        )
        customAchievements:AddAchievement(
            4,
            "Охотник на тени1",
            "Победите 100 теневых существ\nДополнительная строка\nЕще одна строка",
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            100,
            "2023-10-01",
            "2023-10-05",
            100
        )
        customAchievements:AddAchievement(
            5, 
            "Охотник на тени5", 
            "Победите 100 теневых существ\nстрока номер два с описанием", 
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            50, 
            "2023-10-01", 
            nil, 
            60
        )
        customAchievements:AddAchievement(
            6, 
            "Охотник на тени6", 
            "Победите 100 теневых существ\nстрока номер два с описанием", 
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            50, 
            "2023-10-01", 
            nil, 
            60
        )
        customAchievements:AddAchievement(
            7, 
            "Охотник на тени7", 
            "Победите 100 теневых существ\nстрока номер два с описанием", 
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            50, 
            "2023-10-01", 
            nil, 
            60
        )
        customAchievements:AddAchievement(
            8, 
            "Охотник на тени8", 
            "Победите 100 теневых существ\nстрока номер два с описанием", 
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            50, 
            "2023-10-01", 
            nil, 
            60
        )
        customAchievements:AddAchievement(
            9, 
            "Охотник на тени9", 
            "Победите 100 теневых существ\nстрока номер два с описанием", 
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            50, 
            "2023-10-01", 
            nil, 
            60
        )
        customAchievements:AddAchievement(
            10, 
            "Охотник на тени10", 
            "Победите 100 теневых существ\nстрока номер два с описанием", 
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            50, 
            "2023-10-01", 
            nil, 
            60
        )
        customAchievements:AddAchievement(
            11, 
            "Охотник на тени11", 
            "Победите 100 теневых существ\nстрока номер два с описанием", 
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            50, 
            "2023-10-01", 
            nil, 
            60
        )
        customAchievements:AddAchievement(
            12, 
            "Охотник на тени12", 
            "Победите 100 теневых существ\nстрока номер два с описанием", 
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            100, 
            "2023-10-01", 
            "2023-10-01", 
            60
        )
        customAchievements:AddAchievement(
            13, 
            "Получи первые ачивки13", 
            "Все", 
            "Interface\\Icons\\Ability_Rogue_ShadowStrikes", 
            12, 
            "2023-10-01", 
            nil, 
            300,
            { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }  -- Вложенные ачивки с ID 2 и 3
        )
    end
    --self:UnregisterEvent("ADDON_LOADED")
end

-- Создаем фрейм и регистрируем событие PLAYER_ENTERING_WORLD
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", OnEvent)





function CreateButtonsFromTable(buttonsTable)
    for buttonName, buttonParams in pairs(buttonsTable) do
        -- Создаем кнопку
        local button = ButtonManager:new(
            buttonName, -- Имя кнопки
            buttonParams.parent, -- Родительский фрейм
            buttonParams.size.width, -- Ширина
            buttonParams.size.height, -- Высота
            buttonParams.text, -- Текст
            buttonParams.texture -- Текстура (если есть)
        )

        -- Устанавливаем позицию кнопки
        if buttonParams.position then
            button:SetPosition(
                buttonParams.position[1], -- Точка привязки
                buttonParams.position[2], -- Относительный фрейм
                buttonParams.position[3], -- Относительная точка
                buttonParams.position[4], -- Смещение по X
                buttonParams.position[5]  -- Смещение по Y
            )
        end

        -- Устанавливаем обработчик нажатия
        if buttonParams.onClick then
            button:SetOnClick(buttonParams.onClick)
        end

        -- Устанавливаем обработчик OnEnter, если он указан
        if buttonParams.OnEnter then
            button.frame:SetScript("OnEnter", buttonParams.OnEnter)
            button.frame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)
        end

        -- Делаем кнопку перемещаемой, если movable = true
        if buttonParams.movable then
            button:SetMovable(true)
        else
            button:SetMovable(false)
        end
    end
end

addonButtons = {
    -- ["myButton"] = {
    --     size = {width = 64, height = 64},
    --     parent = UIParent,
    --     position = {"CENTER", nil, "CENTER", 0, 0},
    --     text = "Абвг",
    --     texture = "Interface\\AddOns\\NSQC\\emblem.tga",
    --     onClick = function()
    --         print(">")
    --     end,
    --     OnEnter = function(self)
    --         GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    --         GameTooltip:SetText("Это моя кнопка")
    --         GameTooltip:Show()
    --     end,
    --     movable = true, -- Кнопка перемещаемая
    -- },
    -- ["Кнопка2"] = {
    --     size = {width = 120, height = 40},
    --     parent = UIParent,
    --     position = {"CENTER", nil, "CENTER", 0, -50},
    --     text = "Еще кнопка",
    --     onClick = function()
    --         print("Вторая кнопка нажата!")
    --     end,
    --     OnEnter = function(self)
    --         GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    --         GameTooltip:SetText("Это вторая кнопка")
    --         GameTooltip:AddLine("Дополнительная информация", 1, 1, 1, true)
    --         GameTooltip:Show()
    --     end,
    --     movable = false, -- Кнопка не перемещаемая
    -- },
}

CreateButtonsFromTable(addonButtons)




