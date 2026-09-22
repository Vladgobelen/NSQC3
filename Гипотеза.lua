-- ============================================================
--  Гильд-бот: отвечает в офицерский чат по ключевым словам
--  WoW 3.3.5a (WotLK), клиент 12340
--  string.lower работает с кириллицей (локализованный клиент)
-- ============================================================

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_GUILD")

-- ============================================================
--  НАСТРОЙКИ
-- ============================================================

-- Задержка между сообщениями (сек). Blizzard режет спам.
local SEND_DELAY = 0.25

-- Триггер для поиска спеков: "кто шарит <спек>"
-- Пишем только строчными буквами.
local TRIGGER = "шарит"

-- ============================================================
--  ПРОСТЫЕ КОМАНДЫ (точное совпадение сообщения)
-- ============================================================
-- Ключ — сообщение строчными буквами.

local COMMANDS = {
    ["-макрос сакра"] = {
        "#showtooltip Священная жертва",
        "/cast Священная жертва",
        "/cancelaura Священная жертва",
    },
}

-- ============================================================
--  СПЕКИ
-- ============================================================
-- Ключи (keys) пишем ТОЛЬКО строчными буквами.
-- Ники (players) можно писать как угодно — они выводятся как есть.

local SPECS = {
    {
        title = "Рдру:",
        keys = { "рдру" },
        players = { "-Гневсись", "-Равсакс", "-Роллсройс", "-Сотта" },
    },
    {
        title = "Адк:",
        keys = { "адк" },
        players = { "-Анхулик", "-Воинствующий" },
    },
    {
        title = "ППал:",
        keys = { "ппал" },
        players = { "-Бабблти", "-Кошей", "-Палотенчег", "-Рачелло", "-Сорняк", "-Цинтро" },
    },
    {
        title = "ГДК:",
        keys = { "гдк" },
        players = { "-Анхулик", "-Годдек", "-Делдуват", "-Антизуку", "-Феркен" },
    },
    {
        title = "ФДК:",
        keys = { "фдк" },
        players = { "-Годдек", "-Феркен" },
    },
    {
        title = "РПАЛ:",
        keys = { "рпал" },
        players = { "-Zuqu", "-Кошей", "-Олегфистинг", "-Палотенчег", "-Сорняк", "-Цинтро" },
    },
    {
        title = "ХПАЛ:",
        keys = { "хпал" },
        players = { "-Zuqu", "-Адскаясися", "-Бабблти" },
    },
    {
        title = "ММ:",
        keys = { "мм" },
        players = { "-Ореха", "-Бумшакалака" },
    },
    {
        title = "ЭЛЕМ:",
        keys = { "элем" },
        players = { "-Сиран" },
    },
    {
        title = "РШАМ:",
        keys = { "ршам" },
        players = { "-Ахинеяичушь", "-Зогтар", "-Равчек", "-Сиран" },
    },
    {
        title = "ЭНХ:",
        keys = { "энх" },
        players = { "-Годшам", "-Зогтар" },
    },
    {
        title = "МУТИК:",
        keys = { "мути" },
        players = { "-Брагол", "-Нуббади", "-Тенегорн" },
    },
    {
        -- Крог = комбат-рога. Требует ДВА слова, чтобы не путать с "мути".
        title = "КРОГ:",
        keys = { "крог", "комбат" },
        players = { "-Брагол", "-Годрог", "-Йобище" },
    },
    {
        title = "КОТ:",
        keys = { "кота" },
        players = { "-Ярогэ", "-Роллсройс", "-Сулимо" },
    },
    {
        title = "СОВА:",
        keys = { "сова", "сове" },
        players = { "-Равсакс", "-Сотта", "-Стаяблох" },
    },
    {
        title = "ШП:",
        keys = { "шп" },
        players = { "-Дренаж", "-Нехилнет", "-Опездал", "-Свитифокс" },
    },
    {
        title = "ХОЛИ:",
        keys = { "холи" },
        players = { "-Teostra" },
    },
    {
        title = "ДЦ:",
        keys = { "дц" },
        players = { "-Нехилнет", "-Покастунья", "-Свитифокс" },
    },
    {
        title = "ФАЕРМАГ:",
        keys = { "фаермаг", "фаер", "фмаг" },
        players = { "-Варлокмаг", "-Книпус", "-Либерда", "-Мелкор" },
    },
    {
        title = "ДЕМОНЛОК:",
        keys = { "демон", "демонлок" },
        players = { "-Ехинацея", "-Зогтар", "-Ногтибомжихи" },
    },
    {
        title = "АФФЛИ:",
        keys = { "аффли", "афлик" },
        players = { "-Алтарник", "-Вакакака", "-Зогтар", "-Ногтибомжихи", "-Пунья" },
    },
}

-- ============================================================
--  УТИЛИТЫ
-- ============================================================

local function Has(text, word)
    return string.find(text, word, 1, true) ~= nil
end

-- ============================================================
--  ОЧЕРЕДЬ ОТПРАВКИ
-- ============================================================
-- Blizzard ограничивает частоту сообщений, поэтому шлём по одному
-- с паузой SEND_DELAY через OnUpdate (в 3.3.5 C_Timer нет).

local queue = {}
local sending = false

local pump = CreateFrame("Frame")
local elapsed = 0

local function PumpOnUpdate(self, dt)
    elapsed = elapsed + dt
    if elapsed < SEND_DELAY then
        return
    end
    elapsed = 0

    if #queue == 0 then
        sending = false
        self:Hide()
        return
    end

    local msg = table.remove(queue, 1)
    SendChatMessage(msg, "OFFICER")
end

pump:SetScript("OnUpdate", PumpOnUpdate)
pump:Hide()

local function SendOfficerMessage(message)
    table.insert(queue, message)
    if sending then
        return
    end
    sending = true
    elapsed = 0
    pump:Show()
end

-- ============================================================
--  ЛОГИКА
-- ============================================================

local function SendSpec(spec)
    SendOfficerMessage(spec.title)
    for _, player in ipairs(spec.players) do
        SendOfficerMessage(player)
    end
end

local function FindSpec(msg)
    if not Has(msg, TRIGGER) then
        return nil
    end

    for _, spec in ipairs(SPECS) do
        local matched = true
        for _, key in ipairs(spec.keys) do
            if not Has(msg, key) then
                matched = false
                break
            end
        end
        if matched then
            return spec
        end
    end

    return nil
end

-- ============================================================
--  ОБРАБОТЧИК СОБЫТИЙ
-- ============================================================

frame:SetScript("OnEvent", function(self, event, msg, author)
    if not msg then
        return
    end

    -- Приводим входящее сообщение к нижнему регистру один раз.
    local lower = string.lower(msg)

    -- 1. Простые команды
    local command = COMMANDS[lower]
    if command then
        for _, line in ipairs(command) do
            SendOfficerMessage(line)
        end
        return
    end

    -- 2. Поиск спека
    local spec = FindSpec(lower)
    if spec then
        SendSpec(spec)
        return
    end
end)