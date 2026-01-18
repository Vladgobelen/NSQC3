-- Функция обработки события PLAYER_ENTERING_WORLD
-- @param self: Фрейм, который вызвал событие
-- @param event: Тип события (в данном случае "PLAYER_ENTERING_WORLD")
-- @param isLogin: Флаг, указывающий, что игрок вошел в мир
-- @param isReload: Флаг, указывающий, что интерфейс был перезагружен
local function OnEvent(self, event, isLogin, isReload)
    if arg1 == "NSQC3" then
        NSQC3_version = 3; NSQC3_subversion = 5
        SendAddonMessage("NSQC_VERSION_REQUEST", "", "GUILD")
        nsDbc = nsDbc or {}
        ---
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
        
        local timerFrame = CreateFrame("Frame")
local timer = 0
timerFrame:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer >= 2 then
        GuildRecruiter.instance = GuildRecruiter.new()
        nsDbc["набор в гильдию"] = nsDbc["набор в гильдию"] or {}
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
        --questManagerClient = QuestManagerClient:new()
        nsDbc.skills3 = nsDbc.skills3 or {}
        sq = SpellQueue:Create("MySpellQueue", 600, 350, "CENTER")
        sq:SetIconsTable()
        local appearanceSettings = {
            width = 200,
            height = 32,
            scale = 1,
            alpha = 0.9,
            inactiveAlpha = 0.4,
            iconSpacing = 0,
            glowSizeOffset = 10,
            highlightSizeOffset = 15,
            glowAlpha = 0.3,
            healthColor = {1, 0, 0},
            healthBarHeight = 3,
            healthBarOffset = 3,
            resourceColor = {0, 0.8, 1},
            resourceBarHeight = 3,
            resourceBarOffset = 0,
            targetHealthColor = {1, 0, 0},
            targetHealthHeight = 3,
            targetHealthBarOffset = -3,
            targetResourceColor = {0.5, 0, 1},
            targetResourceHeight = 3,
            targetResourceBarOffset = 0,
            iconSize = 32,
            comboSize = 18,
            poisonSize = 16,
            timeLinePosition = 15,
            comboSize = 6,
            comboSpacing = 0,
            comboOffset = {x = 0, y = 24},
            poisonSize = 6,
            poisonSpacing = 0,
            poisonOffset = {x = 0, y = 24},
            healthBarHeight = 3,
            healthBarOffset = 6,
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
        -- Clear the timer
        self:SetScript("OnUpdate", nil)
        self:Hide()
    end
end)
timerFrame:Show()
        local nsqc3TimerFrame = CreateFrame("Frame")
nsqc3TimerFrame:SetScript("OnUpdate", function(self, elapsed)
    self.total = (self.total or 0) + elapsed
    if self.total >= 1 then
        self.total = self.total - 1  -- поддерживаем точность при небольших задержках

        -- Основная логика, которая должна выполняться каждую секунду
        if ns_dbc:getKey("настройки", "hunterTarget") == 1 then
            hunterCheck()
        end

        if nsqc3Timer then
            if adaptiveFrame and adaptiveFrame:IsVisible() then
                for i = 1, 100 do
                    local child = adaptiveFrame.children[i]
                    if child and child.frame and child.frame:GetNormalTexture() then
                        local tex = child.frame:GetNormalTexture():GetTexture()
                        if tex and tex:sub(-3) == "stl" then
                            child:SetTextT(nsqc3Timer)
                        end
                    end
                end
            end

            if nsqc3Timer >= 1 then
                nsqc3Timer = nsqc3Timer - 1
            else
                nsqc3Timer = nil
            end
        end

        -- Если таймер закончился и нет других причин продолжать — скрываем
        if not nsqc3Timer and ns_dbc:getKey("настройки", "hunterTarget") ~= 1 then
            self:Hide()
        end
    end
end)

-- Функция для запуска таймера (вызывай её, когда нужно начать отсчёт)
function StartNsqc3Timer()
    if not nsqc3TimerFrame:IsShown() then
        nsqc3TimerFrame.total = 0
        nsqc3TimerFrame:Show()
    end
end

        -- C_Timer(10, function()
            
        -- end, true)

        C_Timer.NewTicker(100, function()
            UpdateAddOnMemoryUsage()
            time100()
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




