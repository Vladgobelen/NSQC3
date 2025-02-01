-- Функция обработки события PLAYER_ENTERING_WORLD
-- @param self: Фрейм, который вызвал событие
-- @param event: Тип события (в данном случае "PLAYER_ENTERING_WORLD")
-- @param isLogin: Флаг, указывающий, что игрок вошел в мир
-- @param isReload: Флаг, указывающий, что интерфейс был перезагружен
local function OnEvent(self, event, isLogin, isReload)
    NSQCMenu()          -- Вызов функции для отображения меню
    set_miniButton()    -- Вызов функции для настройки мини-кнопки
    createFld()
end

-- Создаем фрейм и регистрируем событие PLAYER_ENTERING_WORLD
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)

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




