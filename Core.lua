-- ============================================================
-- NPCBotInventory - Core.lua
-- Logica de datos: captura mensajes, guarda y carga inventarios
-- ============================================================

NPCBotInventory = NPCBotInventory or {}
local NBI = NPCBotInventory

NBI.botInventories = {}
NBI.botStats       = {}
NBI.playerName     = nil
NBI.lastCallTime   = 0

-- ============================================================
-- CARGA de SavedVariables al iniciar
-- ============================================================
local function OnAddonLoaded(addonName)
    if addonName ~= "NPCBotInventory" then return end

    NBI.playerName = UnitName("player")

    BotInventoryDB = BotInventoryDB or {}
    BotInventoryDB[NBI.playerName] = BotInventoryDB[NBI.playerName] or {}
    for botName, inventory in pairs(BotInventoryDB[NBI.playerName]) do
        NBI.botInventories[botName] = inventory
    end

    NBIStatsDB = NBIStatsDB or {}
    NBIStatsDB[NBI.playerName] = NBIStatsDB[NBI.playerName] or {}
    for botName, stats in pairs(NBIStatsDB[NBI.playerName]) do
        NBI.botStats[botName] = stats
    end

    if NBI.OnDataLoaded then
        NBI.OnDataLoaded()
    end
end

-- ============================================================
-- CAPTURA de CHAT_MSG_MONSTER_WHISPER
-- ============================================================
local function OnChatMessage(self, event, message, sender)
    if event ~= "CHAT_MSG_MONSTER_WHISPER" then return end

    local currentTime = GetTime()

    -- Nueva sesion de consulta si han pasado mas de 2 segundos
    if (currentTime - NBI.lastCallTime) >= 2 then
        NBI.botInventories[sender] = {}
        NBI.botStats[sender]       = ""
    end

    -- 1. Intentar parsear como stat: "Strength: 450", "Critical: 24.5%" o "GS 1234"
    -- Acepta separador ":" o espacio simple
    local key, val = message:match("^([%a][%a%s]-)%s*[:%s]%s*([%d%.]+%%?)%s*$")
    if key and val then
        NBI.botStats[sender] = (NBI.botStats[sender] or "") .. key .. ": " .. val .. "\n"

        -- Persistir stats
        NBIStatsDB[NBI.playerName] = NBIStatsDB[NBI.playerName] or {}
        NBIStatsDB[NBI.playerName][sender] = NBI.botStats[sender]

        NBI.lastCallTime = currentTime
        return
    end

    -- 2. Intentar parsear como item link: contiene |H...|h[...]|h
    local link = string.match(message, "|H(.*)|h%[(.-)%]|h")
    if link then
        NBI.botInventories[sender] = NBI.botInventories[sender] or {}
        table.insert(NBI.botInventories[sender], link)

        BotInventoryDB[NBI.playerName] = BotInventoryDB[NBI.playerName] or {}
        BotInventoryDB[NBI.playerName][sender] = NBI.botInventories[sender]

        if NBI.OnBotDataUpdated then
            NBI.OnBotDataUpdated(sender)
        end
    end

    NBI.lastCallTime = currentTime
end

-- ============================================================
-- Borrar todos los inventarios y stats
-- ============================================================
function NBI.ClearAll()
    if BotInventoryDB[NBI.playerName] then
        wipe(BotInventoryDB[NBI.playerName])
    end
    if NBIStatsDB[NBI.playerName] then
        wipe(NBIStatsDB[NBI.playerName])
    end
    wipe(NBI.botInventories)
    wipe(NBI.botStats)
    if NBI.OnDataCleared then
        NBI.OnDataCleared()
    end
    print("|cff00ff96[NPCBotInventory]|r Inventarios y stats borrados.")
end

-- ============================================================
-- EVENTOS
-- ============================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        OnAddonLoaded(...)
    elseif event == "CHAT_MSG_MONSTER_WHISPER" then
        OnChatMessage(self, event, ...)
    end
end)
