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
local triggers = {
    {
        keyword = {
            { word = "тест", position = 1 },  -- Первое слово должно быть "тест"
            { word = "124", position = 3 }    -- Третье слово должно быть "124"
        },
        func = "OnRaidTrigger",               -- Функция, которая будет вызвана при срабатывании триггера
        conditions = {
            --"IsGuildLeader"                 -- Дополнительные условия (закомментировано)
        }
    },
    {
        keyword = {
            { word = "MyAddon", position = 1, source = "prefix" },  -- Первое слово в prefix должно быть "MyAddon"
            { word = "рейд", position = 2, source = "message" }     -- Второе слово в message должно быть "рейд"
        },
        func = "OnAddonRaidTrigger",                               -- Функция, которая будет вызвана при срабатывании триггера
        conditions = {
            function(text, sender, channel, prefix) return sender == "Хефе" end  -- Условие: отправитель должен быть "Хефе"
        }
    }
}

-- Функция для обработки триггера с префиксом "MyAddon" и сообщением "рейд"
-- @param text: Текст сообщения
-- @param sender: Имя отправителя
-- @param channel: Канал сообщения
-- @param prefix: Префикс сообщения (для ADDON-сообщений)
function OnAddonRaidTrigger(text, sender, channel, prefix)
    SendChatMessage("все работает123", "OFFICER")  -- Отправка сообщения в офицерский канал
end

-- Функция для обработки триггера с ключевыми словами "тест" и "124"
-- @param text: Текст сообщения
-- @param sender: Имя отправителя
-- @param channel: Канал сообщения
-- @param prefix: Префикс сообщения (для ADDON-сообщений)
function OnRaidTrigger(text, sender, channel, prefix)
    SendChatMessage("все работает", "OFFICER")  -- Отправка сообщения в офицерский канал
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
local chatHandler = ChatHandler:new(triggers, {"GUILD", "ADDON"})












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