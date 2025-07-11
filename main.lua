-- Функция обработки события PLAYER_ENTERING_WORLD
-- @param self: Фрейм, который вызвал событие
-- @param event: Тип события (в данном случае "PLAYER_ENTERING_WORLD")
-- @param isLogin: Флаг, указывающий, что игрок вошел в мир
-- @param isReload: Флаг, указывающий, что интерфейс был перезагружен
local function OnEvent(self, event, isLogin, isReload)
    if arg1 == "NSQC3" then
        NSQC3_version = 1; NSQC3_subversion = 0
        SendAddonMessage("NSQC_VERSION_REQUEST", "", "GUILD")
        nsDbc = nsDbc or {}
        ns_dbc = ns_dbc or NsDb:new(nsDbc)
        NS3Menu(NSQC3_version, NSQC3_subversion)         -- Вызов функции для отображения меню
        createFld()
        mFld = mDB:new()
        
        nsCm = mDB:new()

        gpDb = gpDb or GpDb:new({})

        nsDBC_ach_table = nsDBC_ach_table or create_table:new("nsqc3_ach")
        nsDBC_ach = nsDBC_ach or NsDb:new(nsDBC_ach_table:get_table(), nil, nil, nil, 100000)
        mFldObj = mFldObj or NsDb:new(ns_tooltips, nil, nil, nil, 100000)
        set_miniButton()    -- Вызов функции для настройки мини-кнопки
        
        C_Timer(2, function()
            achievementHelper = AchievementHelper:new()
            questWhatchPanel()
            nsDbc.proks = nsDbc.proks or {}
            ProkIconManager:Initialize(nsDbc.proks)
            if UnitLevel("player") >= 10 then
                if AchievementMicroButton:IsEnabled() == 1 then
                    AchievementMicroButton:Click()
                    AchievementFrameCloseButton:Click()
                end
            end
            getPoint()
            questManagerClient = QuestManagerClient:new()
            nsDbc.skills3 = nsDbc.skills3 or {}
            sq = SpellQueue:Create("MySpellQueue", 600, 350, "CENTER")
            sq:SetIconsTable()
            local appearanceSettings = {
                -- Основные параметры
                width = 200,              -- Ширина всей панели
                height = 32,              -- Высота панели
                scale = 1,                -- Масштаб интерфейса
                alpha = 0.9,              -- Прозрачность в бою
                inactiveAlpha = 0.4,      -- Прозрачность вне боя
                iconSpacing = 0,          -- расстояние между иконками
                glowSizeOffset = 10,      -- На сколько больше иконки будет glow
                highlightSizeOffset = 15, -- На сколько больше иконки будет highlight
                glowAlpha = 0.3,          -- Прозрачность glow
                
                -- Игрок
                healthColor = {1, 0, 0},                 -- Цвет здоровья игрока (RGB)
                healthBarHeight = 3,                     -- Высота полосы здоровья
                healthBarOffset = 3,                     -- Смещение от верха панели
                
                resourceColor = {0, 0.8, 1},             -- Цвет ресурса (мана/ярость и т.д.)
                resourceBarHeight = 3,                   -- Высота полосы ресурса
                resourceBarOffset = 0,                   -- Смещение от полосы здоровья
                
                -- Цель
                targetHealthColor = {1, 0, 0},         -- Цвет здоровья цели
                targetHealthHeight = 3,                  -- Высота полосы здоровья цели
                targetHealthBarOffset = -3,              -- Смещение от низа панели (отрицательное - вверх)
                
                targetResourceColor = {0.5, 0, 1},       -- Цвет ресурса цели
                targetResourceHeight = 3,                -- Высота полосы ресурса цели
                targetResourceBarOffset = 0,             -- Смещение от полосы здоровья цели
                
                -- Другие элементы
                iconSize = 32,              -- Размер иконок способностей
                comboSize = 18,             -- Размер комбо-поинтов
                poisonSize = 16,            -- Размер стаков ядов
                timeLinePosition = 15,      -- Позиция временной линии
                -- Комбо-поинты
                comboSize = 6,               -- Размер квадрата
                comboSpacing = 0,            -- Расстояние между квадратами
                comboOffset = {x = 0, y = 24}, -- Смещение от панели
                
                -- Яды
                poisonSize = 6,              -- Размер квадрата
                poisonSpacing = 0,           -- Расстояние между квадратами
                poisonOffset = {x = 0, y = 24}, -- Смещение от панели
                healthBarHeight = 3,          -- высота полоски хп игрока
                healthBarOffset = 6,          -- расстояние полоски хп до панели
                resourceBarHeight = 3,
                resourceBarOffset = 0,
                targetHealthBarHeight = 3,
                targetHealthBarOffset = -6,
                targetResourceBarHeight = 3,
                targetResourceBarOffset = 0,
                clickThrough = 0
            }
            if not ns_dbc:getKey("настройки", "Skill Queue") then
                ns_dbc:modKey("настройки", "Skill Queue", appearanceSettings)
            end
            sq:SetAppearanceSettings(ns_dbc:getKey("настройки", "Skill Queue"))
            sq:UpdateSkillTables()
            sq:ForceUpdateAllSpells()
            sq:ApplyDisplayMode()
            nsDbc['frames'] = nsDbc['frames'] or {}
            RestoreFramePositions(nsDbc['frames'])
        end)

        C_Timer(1, function()
            if ns_dbc:getKey("настройки", "hunterTarget") == 1 then
                hunterCheck()
            end
            if nsqc3Timer then
                if adaptiveFrame:isVisible() then
                    for i = 1, 100 do
                        if adaptiveFrame.children[i].frame:GetNormalTexture():GetTexture():sub(-3) == "stl" then
                            adaptiveFrame.children[i]:SetTextT(nsqc3Timer)
                        end
                    end
                end
                if nsqc3Timer >=1 then
                    nsqc3Timer = nsqc3Timer - 1
                else
                    nsqc3Timer = nil
                end
            end
        end, true)

        -- C_Timer(10, function()
            
        -- end, true)

        C_Timer(100, function()
            UpdateAddOnMemoryUsage()
            time100()
        end, true)
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
--         texture = "Interface\\AddOns\\NSQC3\\emblem.tga",
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




