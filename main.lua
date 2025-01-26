-- Функция обработки события PLAYER_ENTERING_WORLD
-- @param self: Фрейм, который вызвал событие
-- @param event: Тип события (в данном случае "PLAYER_ENTERING_WORLD")
-- @param isLogin: Флаг, указывающий, что игрок вошел в мир
-- @param isReload: Флаг, указывающий, что интерфейс был перезагружен
local function OnEvent(self, event, isLogin, isReload)
    NSQCMenu()          -- Вызов функции для отображения меню
    set_miniButton()    -- Вызов функции для настройки мини-кнопки
end

-- Создаем фрейм и регистрируем событие PLAYER_ENTERING_WORLD
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)

-- Таблица триггеров для обработки сообщений
local triggersByAddress = {
    ["message:тест"] = {
        {
            keyword = {
                { word = "тест", position = 1, source = "message" }
            },
            func = "OnTestTrigger",
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
            stopOnMatch = true  -- Прервать обработку после этого триггера
        }
    }
}

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











-- -- Создаем родительский фрейм
-- parentFrame = CreateFrame("Frame", nil, UIParent)
-- parentFrame:SetSize(800, 600)
-- parentFrame:SetPoint("CENTER")

-- Создаем адаптивный фрейм
-- fBtnFrame = AdaptiveFrame:Create(parentFrame)
-- fBtnFrame:SetPoint("CENTER")

-- Создаем 100 кнопок
-- nsqc_fBtn = {}
-- for i = 1, 100 do
--     nsqc_fBtn[i] = nsqc_ButtonManager:new("Button" .. i, fBtnFrame, 64, 64, "Btn " .. i, "Interface\\AddOns\\NSQC\\libs\\t.tga")
--     nsqc_fBtn[i]:SetTextT(i)
--     nsqc_fBtn[i]:SetTooltip("This is Button " .. i)
-- end

-- Добавляем кнопки в сетку (10 кнопок в линии)
--fBtnFrame:AddGrid(nsqc_fBtn, 100, 10, 0)









-- -- Создаем фрейм для отслеживания движения
-- local movementFrame = CreateFrame("Frame")
-- movementFrame.targetAlpha = 1.0  -- Целевая прозрачность
-- movementFrame.currentAlpha = 1.0  -- Текущая прозрачность
-- movementFrame.alphaSpeed = 2.0  -- Скорость изменения прозрачности (чем больше, тем быстрее)

-- movementFrame:SetScript("OnUpdate", function(self, elapsed)
--     -- Получаем текущие координаты персонажа
--     local _, x, y = GetPlayerMapPosition("player")

--     -- Если координаты изменились, персонаж движется
--     if x ~= self.lastX or y ~= self.lastY then
--         if not self.isMoving then
--             -- Персонаж начал движение
--             self.isMoving = true
--             self.targetAlpha = 0.5 -- Устанавливаем целевую прозрачность 50%
--         end
--     else
--         if self.isMoving then
--             -- Персонаж остановился
--             self.isMoving = false
--             self.targetAlpha = 1.0  -- Устанавливаем целевую прозрачность 100%
--         end
--     end

--     -- Плавное изменение прозрачности
--     if self.currentAlpha ~= self.targetAlpha then
--         -- Вычисляем новое значение прозрачности
--         self.currentAlpha = self.currentAlpha + (self.targetAlpha - self.currentAlpha) * self.alphaSpeed * elapsed

--         -- Устанавливаем новую прозрачность
--         fBtnFrame:SetAlpha(self.currentAlpha)
--     end

--     -- Сохраняем текущие координаты для следующей проверки
--     self.lastX, self.lastY = x, y
-- end)