-- Локальные переменные для оптимизации
local strlower = strlower
local utf8sub, utf8len = string.utf8sub, string.utf8len
local mysplit = mysplit
local addStrQ, addStr = addStrQ, addStr
local pairs = pairs
local table_insert = table.insert
local string_gmatch, string_lower = string.gmatch, string.lower
local math_abs, math_floor = math.abs, math.floor
-- Создаем фрейм для обработки сообщений в гильдейском чате
local GC_Sniffer = CreateFrame("Frame")
GC_Sniffer:RegisterEvent("CHAT_MSG_GUILD")

-- Обработчик событий
GC_Sniffer:SetScript("OnEvent", function(self, event, message, sender)
    local msg = mysplit(message)
	
    msg = nil
    dmsg = nil
end)












