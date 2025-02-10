-- -----------------------------------------------------------------
-- -- Примеры использования всех классов
-- -----------------------------------------------------------------

-- ---------------------------
-- -- 0. Класс create_table
-- ---------------------------
-- -- Создание управляемой таблицы с указателями
-- local myTable = create_table:new("GlobalData", true) -- true = с таблицей-указателем

-- -- Получаем основную таблицу и таблицу-указатель
-- local mainTable = myTable:get_table()
-- local pointerTable = myTable:get_table_p()

-- ------------------
-- -- 1. Класс NsDb
-- ------------------
-- local myTable = create_table:new("GlobalData", true) -- true = с таблицей-указателем
-- local nsDb = NsDb:new(myTable:get_table(), myTable:get_table_p(), "data", 100, 10)

-- local myTable = create_table:new("GlobalData", nil) -- nil = без таблицы-указателей
-- local nsDb = NsDb:new(myTable:get_table(), nil, "data", 100, 10)

-- -- Добавление данных
-- nsDb:add_str("Hello World")          -- Новая строка
-- nsDb:add_dict("player", "user123")   -- Добавление в словарь
-- nsDb:add_fdict({"apple", "banana"})  -- Хеш-таблица

-- -- Получение данных
-- print("Строка 1:", nsDb:getLine(1))       -- Hello World
-- print("Уникальность:", nsDb:is_unique("Hello World")) -- false
-- print("Размер таблицы:", nsDb:Len())      -- 1

-- ----------------------------
-- -- 2. Класс ButtonManager
-- ----------------------------
-- local btn = ButtonManager:new(
--   "TestButton", 
--   UIParent, 
--   150, 50, 
--   "Нажми меня!", 
--   nil,  -- Текстура (nil = стандартный стиль)
--   UIParent
-- )

-- -- Настройка кнопки
-- btn:SetPosition("CENTER", 0, -100)
-- btn:SetOnClick(function() 
--   print("Кнопка активирована!") 
-- end)
-- btn:SetTooltip("Тестовая кнопка\nДвойной клик - скрыть")

-- ---------------------------
-- -- 3. Класс AdaptiveFrame
-- ---------------------------
-- local adaptiveFrame = AdaptiveFrame:Create(UIParent, 600, 400)

-- -- Создание 12 кнопок для сетки
-- local gridButtons = {}
-- for i = 1, 12 do
--   gridButtons[i] = ButtonManager:new(
--     "GridBtn"..i, 
--     adaptiveFrame, 
--     80, 30, 
--     "Btn "..i
--   )
-- end

-- -- Добавление сетки 4x3
-- adaptiveFrame:AddGrid(gridButtons, 12, 4) -- 4 колонки
-- adaptiveFrame:Show()

-- -------------------------------
-- -- 4. Класс UniversalInfoFrame
-- -------------------------------
-- local infoFrame = UniversalInfoFrame:new(1, {}) -- Обновление каждую секунду

-- -- Динамические данные
-- infoFrame:AddText("ФПС", function() 
--   return string.format("%.1f", GetFramerate() or 0) 
-- end, true)

-- infoFrame:AddText("Латентность", function() 
--   return select(3, GetNetStats()).." мс" 
-- end, false)

-- -- Статические данные
-- infoFrame:AddText("Версия", "1.0.0", true)
-- infoFrame:Show()

-- ----------------------------
-- -- 5. Класс ChatHandler
-- ----------------------------
-- -- Обработчик команды "!ping"
-- function HandlePing(_, sender)
--   SendChatMessage("pong!", "WHISPER", nil, sender)
-- end

-- -- Настройка триггеров
-- local chatTriggers = {
--   ["message:!ping"] = {
--     {
--       keyword = {{word = "!ping", position = 1, source = "message"}},
--       func = "HandlePing",
--       conditions = {function(_, sender) 
--         return not UnitIsUnit(sender, "player") 
--       end}
--     }
--   }
-- }

-- -- Инициализация обработчика
-- ChatHandler:new(chatTriggers, {"WHISPER", "SAY", "GUILD"})
