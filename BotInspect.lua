-- ============================================================
-- NPCBotInventory - BotInspect.lua
-- Ventana paperdoll: slots detectados automaticamente + stats
-- Compatible con WotLK 3.3.5
-- ============================================================

local NBI = NPCBotInventory

-- ============================================================
-- MAPA: equipSlot (string de GetItemInfo) -> nombre del slot
-- ============================================================
local EQUIP_SLOT_MAP = {
    INVTYPE_HEAD       = "Head",
    INVTYPE_NECK       = "Neck",
    INVTYPE_SHOULDER   = "Shoulder",
    INVTYPE_CLOAK      = "Back",
    INVTYPE_CHEST      = "Chest",
    INVTYPE_ROBE       = "Chest",
    INVTYPE_BODY       = "Shirt",
    INVTYPE_TABARD     = "Tabard",
    INVTYPE_WRIST      = "Wrist",
    INVTYPE_HAND       = "Hands",
    INVTYPE_WAIST      = "Waist",
    INVTYPE_LEGS       = "Legs",
    INVTYPE_FEET       = "Feet",
    INVTYPE_FINGER     = "Finger1",   -- el segundo anillo se gestiona abajo
    INVTYPE_TRINKET    = "Trinket1",  -- el segundo amuleto se gestiona abajo
    INVTYPE_WEAPON     = "MainHand",
    INVTYPE_2HWEAPON   = "MainHand",
    INVTYPE_WEAPONMAINHAND = "MainHand",
    INVTYPE_WEAPONOFFHAND  = "OffHand",
    INVTYPE_SHIELD     = "OffHand",
    INVTYPE_HOLDABLE   = "OffHand",
    INVTYPE_RANGED     = "Ranged",
    INVTYPE_RANGEDRIGHT = "Ranged",
    INVTYPE_THROWN     = "Ranged",
    INVTYPE_RELIC      = "Ranged",
}

-- Layout visual: posicion de cada slot en la ventana
local SLOT_LAYOUT = {
    { name = "Head",      label = "Head",        x = -148, y =  155 },
    { name = "Neck",      label = "Neck",        x = -148, y =  108 },
    { name = "Shoulder",  label = "Shoulder",    x = -148, y =   61 },
    { name = "Back",      label = "Back",        x = -148, y =   14 },
    { name = "Chest",     label = "Chest",       x = -148, y =  -33 },
    { name = "Shirt",     label = "Shirt",       x = -148, y =  -80 },
    { name = "Tabard",    label = "Tabard",      x = -148, y = -127 },
    { name = "Wrist",     label = "Wrist",       x = -148, y = -174 },
    { name = "Hands",     label = "Hands",       x =   58, y =  155 },
    { name = "Waist",     label = "Waist",       x =   58, y =  108 },
    { name = "Legs",      label = "Legs",        x =   58, y =   61 },
    { name = "Feet",      label = "Feet",        x =   58, y =   14 },
    { name = "Finger1",   label = "Ring 1",      x =   58, y =  -33 },
    { name = "Finger2",   label = "Ring 2",      x =   58, y =  -80 },
    { name = "Trinket1",  label = "Trinket 1",   x =   58, y = -127 },
    { name = "Trinket2",  label = "Trinket 2",   x =   58, y = -174 },
    { name = "MainHand",  label = "Main Hand",   x = -148, y = -221 },
    { name = "OffHand",   label = "Off Hand",    x =   58, y = -221 },
    { name = "Ranged",    label = "Ranged",      x =  -45, y = -221 },
}

local SLOT_SZ  = 37
local WIN_W    = 500
local WIN_H    = 580
local STATS_X  = 120   -- inicio del panel de stats desde el centro

local QUALITY_COLOR = {
    [0] = {0.62, 0.62, 0.62},
    [1] = {1,    1,    1   },
    [2] = {0.12, 1,    0   },
    [3] = {0,    0.44, 0.87},
    [4] = {0.64, 0.21, 0.93},
    [5] = {1,    0.5,  0   },
}

-- ============================================================
-- HELPER
-- ============================================================
local function GoldBorder(frame)
    frame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(0.08, 0.08, 0.1, 1)
    frame:SetBackdropBorderColor(0.5, 0.42, 0.1, 1)
end

-- ============================================================
-- VENTANA PRINCIPAL
-- ============================================================
local inspectFrame = CreateFrame("Frame", "NBI_InspectFrame", UIParent)
inspectFrame:SetSize(WIN_W, WIN_H)
inspectFrame:SetPoint("CENTER")
inspectFrame:SetFrameStrata("DIALOG")
inspectFrame:SetMovable(true)
inspectFrame:EnableMouse(true)
inspectFrame:RegisterForDrag("LeftButton")
inspectFrame:SetScript("OnDragStart", inspectFrame.StartMoving)
inspectFrame:SetScript("OnDragStop",  inspectFrame.StopMovingOrSizing)
inspectFrame:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
inspectFrame:SetBackdropColor(0.05, 0.05, 0.08, 0.98)
inspectFrame:SetBackdropBorderColor(0.4, 0.35, 0.1, 1)
inspectFrame:Hide()

-- Cabecera
local inspectHeader = CreateFrame("Frame", nil, inspectFrame)
inspectHeader:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  0, 0)
inspectHeader:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 0, 0)
inspectHeader:SetHeight(38)
inspectHeader:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
inspectHeader:SetBackdropColor(0.08, 0.07, 0.03, 1)

local inspectTitle = inspectHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
inspectTitle:SetPoint("CENTER", inspectHeader, "CENTER", 0, 0)
inspectTitle:SetTextColor(1, 0.82, 0, 1)
inspectTitle:SetText("Bot Inspect")

local sep = inspectFrame:CreateTexture(nil, "ARTWORK")
sep:SetHeight(1)
sep:SetPoint("TOPLEFT",  inspectFrame, "TOPLEFT",  10, -38)
sep:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", -10, -38)
sep:SetTexture(0.5, 0.42, 0.1, 0.6)

local inspectClose = CreateFrame("Button", nil, inspectFrame, "UIPanelCloseButton")
inspectClose:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", 2, 2)
inspectClose:SetScript("OnClick", function() inspectFrame:Hide() end)

-- Fondo central decorativo
local centerBg = CreateFrame("Frame", nil, inspectFrame)
centerBg:SetSize(140, 360)
centerBg:SetPoint("CENTER", inspectFrame, "CENTER", -45, -15)
centerBg:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
centerBg:SetBackdropColor(0.05, 0.05, 0.1, 0.5)
centerBg:SetBackdropBorderColor(0.3, 0.25, 0.1, 0.6)

local botNameLabel = centerBg:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
botNameLabel:SetPoint("TOP", centerBg, "TOP", 0, -10)
botNameLabel:SetTextColor(1, 0.82, 0, 1)
botNameLabel:SetText("")

local botGSLabel = centerBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
botGSLabel:SetPoint("TOP", botNameLabel, "BOTTOM", 0, -4)
botGSLabel:SetTextColor(0.2, 0.9, 0.4, 1)
botGSLabel:SetText("")

local botTypeLabel = centerBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
botTypeLabel:SetPoint("TOP", botGSLabel, "BOTTOM", 0, -4)
botTypeLabel:SetTextColor(0.5, 0.5, 0.5, 1)
botTypeLabel:SetText("NPCBot")

-- ============================================================
-- RETRATO DEL BOT: busca el bot por nombre entre party1-party4
-- Si esta en el grupo muestra su retrato 3D, si no un icono
-- ============================================================
local portraitModel = CreateFrame("PlayerModel", "NBI_PortraitModel", centerBg)
portraitModel:SetSize(110, 180)
portraitModel:SetPoint("TOP", botTypeLabel, "BOTTOM", 0, -8)
portraitModel:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
portraitModel:SetBackdropColor(0.05, 0.05, 0.1, 0.8)
portraitModel:SetBackdropBorderColor(0.4, 0.35, 0.1, 0.8)

-- Placeholder cuando el bot no esta en el grupo
local portraitPlaceholder = centerBg:CreateTexture(nil, "ARTWORK")
portraitPlaceholder:SetSize(64, 64)
portraitPlaceholder:SetPoint("CENTER", portraitModel, "CENTER", 0, 0)
portraitPlaceholder:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
portraitPlaceholder:SetAlpha(0.3)

local portraitLabel = centerBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
portraitLabel:SetPoint("TOP", portraitModel, "BOTTOM", 0, -4)
portraitLabel:SetTextColor(0.45, 0.45, 0.45, 1)
portraitLabel:SetText("Not in party")

-- Funcion: busca el unitId del bot por nombre entre los miembros del grupo
local function FindBotUnitId(botName)
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) then
            local name = UnitName(unit)
            if name and name == botName then
                return unit
            end
        end
    end
    -- Comprobar tambien "player" por si acaso
    if UnitName("player") == botName then
        return "player"
    end
    return nil
end

inspectFrame.portraitModel = portraitModel
inspectFrame.FindBotUnitId = FindBotUnitId

-- ============================================================
-- SLOTS DE EQUIPO
-- ============================================================
inspectFrame.slotFrames = {}

for _, slotInfo in ipairs(SLOT_LAYOUT) do
    local sf = CreateFrame("Button", "NBI_Slot_" .. slotInfo.name, inspectFrame)
    sf:SetSize(SLOT_SZ, SLOT_SZ)
    sf:SetPoint("CENTER", inspectFrame, "CENTER", slotInfo.x, slotInfo.y - 10)
    GoldBorder(sf)

    local icon = sf:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT",     sf, "TOPLEFT",     3, -3)
    icon:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", -3,  3)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-PaperDoll-Slot-" .. slotInfo.name)

    local qbar = sf:CreateTexture(nil, "OVERLAY")
    qbar:SetHeight(3)
    qbar:SetPoint("BOTTOMLEFT",  sf, "BOTTOMLEFT",  2, 1)
    qbar:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", -2, 1)
    qbar:SetTexture(0.4, 0.4, 0.4, 0)

    local lbl = inspectFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOP", sf, "BOTTOM", 0, -1)
    lbl:SetTextColor(0.45, 0.45, 0.45, 1)
    lbl:SetText(slotInfo.label)

    sf.icon      = icon
    sf.qbar      = qbar
    sf.slotLabel = lbl
    sf.link      = nil
    sf.slotName  = slotInfo.name

    sf:SetScript("OnEnter", function(self)
        if self.link then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:Show()
        end
    end)
    sf:SetScript("OnLeave", function() GameTooltip:Hide() end)

    inspectFrame.slotFrames[slotInfo.name] = sf
end

-- ============================================================
-- PANEL DE ESTADISTICAS
-- ============================================================
local STATS_W = 148
local statsPanel = CreateFrame("Frame", nil, inspectFrame)
statsPanel:SetSize(STATS_W, WIN_H - 60)
statsPanel:SetPoint("TOPRIGHT", inspectFrame, "TOPRIGHT", -10, -48)
statsPanel:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
statsPanel:SetBackdropColor(0.06, 0.06, 0.1, 0.95)
statsPanel:SetBackdropBorderColor(0.3, 0.25, 0.1, 0.8)

local statsPanelTitle = statsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
statsPanelTitle:SetPoint("TOP", statsPanel, "TOP", 0, -8)
statsPanelTitle:SetTextColor(1, 0.82, 0, 1)
statsPanelTitle:SetText("Estadisticas")

local statsDivider = statsPanel:CreateTexture(nil, "ARTWORK")
statsDivider:SetHeight(1)
statsDivider:SetPoint("TOPLEFT",  statsPanel, "TOPLEFT",  4, -22)
statsDivider:SetPoint("TOPRIGHT", statsPanel, "TOPRIGHT", -4, -22)
statsDivider:SetTexture(0.5, 0.42, 0.1, 0.5)

inspectFrame.statLabels = {}

local function CreateStatRow(parent, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(STATS_W - 10, 16)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOffset)

    local keyLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    keyLabel:SetPoint("LEFT",  row, "LEFT",  2, 0)
    keyLabel:SetPoint("RIGHT", row, "RIGHT", -40, 0)
    keyLabel:SetTextColor(0.75, 0.75, 0.75, 1)
    keyLabel:SetJustifyH("LEFT")
    keyLabel:SetWordWrap(false)

    local valLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valLabel:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    valLabel:SetTextColor(1, 1, 1, 1)
    valLabel:SetJustifyH("RIGHT")

    row.key = keyLabel
    row.val = valLabel
    row:Hide()
    return row
end

for i = 1, 24 do
    inspectFrame.statLabels[i] = CreateStatRow(statsPanel, -26 - (i - 1) * 18)
end

-- ============================================================
-- STATS CALCULADOS: suma GetItemStats de todos los items
-- ============================================================

-- Orden de visualizacion y nombre legible de cada stat
local STAT_DISPLAY = {
    { key = "ITEM_MOD_STRENGTH_SHORT",             label = "Strength"         },
    { key = "ITEM_MOD_AGILITY_SHORT",              label = "Agility"          },
    { key = "ITEM_MOD_STAMINA_SHORT",              label = "Stamina"          },
    { key = "ITEM_MOD_INTELLECT_SHORT",            label = "Intellect"        },
    { key = "ITEM_MOD_SPIRIT_SHORT",               label = "Spirit"           },
    { key = "ITEM_MOD_ATTACK_POWER_SHORT",         label = "Attack Power"     },
    { key = "ITEM_MOD_SPELL_POWER_SHORT",          label = "Spell Power"      },
    { key = "ITEM_MOD_CRIT_RATING_SHORT",          label = "Crit Rating"      },
    { key = "ITEM_MOD_HIT_RATING_SHORT",           label = "Hit Rating"       },
    { key = "ITEM_MOD_HASTE_RATING_SHORT",         label = "Haste Rating"     },
    { key = "ITEM_MOD_EXPERTISE_RATING_SHORT",     label = "Expertise"        },
    { key = "ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT", label = "Armor Pen"   },
    { key = "ITEM_MOD_DODGE_RATING_SHORT",         label = "Dodge Rating"     },
    { key = "ITEM_MOD_PARRY_RATING_SHORT",         label = "Parry Rating"     },
    { key = "ITEM_MOD_BLOCK_RATING_SHORT",         label = "Block Rating"     },
    { key = "ITEM_MOD_RESILIENCE_RATING_SHORT",    label = "Resilience"       },
    { key = "ITEM_MOD_MANA_REGENERATION_SHORT",    label = "MP5"              },
    { key = "ITEM_MOD_HEALTH_REGEN",               label = "HP5"              },
}

-- Color por tipo de stat
local STAT_COLOR = {
    Strength        = {1,    0.82, 0   },
    Agility         = {1,    0.82, 0   },
    Stamina         = {1,    0.82, 0   },
    Intellect       = {1,    0.82, 0   },
    Spirit          = {1,    0.82, 0   },
    ["Attack Power"]    = {0.9,  0.5,  0.1},
    ["Spell Power"]     = {0.5,  0.5,  1  },
    ["Crit Rating"]     = {0.2,  0.9,  0.4},
    ["Hit Rating"]      = {0.2,  0.9,  0.4},
    ["Haste Rating"]    = {0.2,  0.9,  0.4},
    Expertise           = {0.2,  0.9,  0.4},
    ["Armor Pen"]       = {0.8,  0.8,  0.8},
    ["Dodge Rating"]    = {0.4,  0.7,  1  },
    ["Parry Rating"]    = {0.4,  0.7,  1  },
    ["Block Rating"]    = {0.4,  0.7,  1  },
    Resilience          = {0.8,  0.3,  0.3},
    MP5                 = {0.3,  0.6,  1  },
    HP5                 = {0.3,  1,    0.3},
}

local function CalcItemStats(inventory)
    local totals = {}
    local statBuf = {}

    for _, link in ipairs(inventory) do
        -- Construir link completo para GetItemStats
        local fullLink = "|Hitem:" .. link:match("item:(.-)$") .. "|h[x]|h"
        -- GetItemStats necesita el link en formato |H...|h
        wipe(statBuf)
        GetItemStats(fullLink, statBuf)
        for statKey, val in pairs(statBuf) do
            totals[statKey] = (totals[statKey] or 0) + val
        end
    end
    return totals
end

-- ============================================================
-- FUNCION PRINCIPAL
-- ============================================================
function NBI.OpenInspect(botName)
    local inventory = NBI.botInventories[botName]

    if not inventory then
        print("|cffFFD700[NPCBotInventory]|r No data for: " .. botName)
        return
    end

    inspectTitle:SetText(botName)
    botNameLabel:SetText(botName)
    botGSLabel:SetText("")
    botTypeLabel:SetText("NPCBot")

    -- Buscar el bot en el grupo y cargar su retrato
    local unitId = FindBotUnitId(botName)
    if unitId then
        portraitModel:SetUnit(unitId)
        portraitPlaceholder:SetAlpha(0)
        portraitLabel:SetText(unitId)
    else
        portraitModel:ClearModel()
        portraitPlaceholder:SetAlpha(0.3)
        portraitLabel:SetText("Not in party")
    end

    -- Limpiar slots
    for _, sf in pairs(inspectFrame.slotFrames) do
        sf.icon:SetTexture("Interface\\PaperDollInfoFrame\\UI-PaperDoll-Slot-" .. sf.slotName)
        sf.icon:SetTexCoord(0, 1, 0, 1)
        sf.qbar:SetTexture(0.4, 0.4, 0.4, 0)
        sf.link = nil
        sf:SetBackdropBorderColor(0.5, 0.42, 0.1, 1)
    end

    -- Rellenar slots detectando el tipo de cada item automaticamente
    if inventory then
        for _, link in ipairs(inventory) do
            local _, _, _, _, _, _, _, _, equipSlot, texture = GetItemInfo(link)

            if not equipSlot then
                local itemID = link:match("item:(%d+)")
                if itemID then GetItemInfo(tonumber(itemID)) end
            end

            if equipSlot and equipSlot ~= "" then
                local slotName = EQUIP_SLOT_MAP[equipSlot]

                if slotName == "Finger1" and inspectFrame.slotFrames["Finger1"].link then
                    slotName = "Finger2"
                end
                if slotName == "Trinket1" and inspectFrame.slotFrames["Trinket1"].link then
                    slotName = "Trinket2"
                end

                if slotName then
                    local sf = inspectFrame.slotFrames[slotName]
                    if sf and not sf.link then
                        if texture then
                            sf.icon:SetTexture(texture)
                            sf.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                        end
                        sf.link = link

                        local _, _, quality = GetItemInfo(link)
                        if quality and QUALITY_COLOR[quality] then
                            local qc = QUALITY_COLOR[quality]
                            sf:SetBackdropBorderColor(qc[1], qc[2], qc[3], 1)
                            sf.qbar:SetTexture(qc[1], qc[2], qc[3], 0.9)
                        end
                    end
                end
            end
        end
    end

    -- Calcular y mostrar stats sumados de todos los items
    for _, row in ipairs(inspectFrame.statLabels) do
        row:Hide()
    end

    -- GS desde botStats
    local statsText = NBI.botStats and NBI.botStats[botName]
    if statsText then
        local gs = statsText:match("GS%s*:%s*(%d+)")
        if gs then
            botGSLabel:SetText("GS: " .. gs)
        end
    end

    -- Stats calculados desde los items
    if inventory and #inventory > 0 then
        local totals = CalcItemStats(inventory)
        local rowIndex = 1
        for _, statInfo in ipairs(STAT_DISPLAY) do
            local val = totals[statInfo.key]
            if val and val > 0 then
                local row = inspectFrame.statLabels[rowIndex]
                if row then
                    row.key:SetText(statInfo.label)
                    row.val:SetText("+" .. val)
                    local color = STAT_COLOR[statInfo.label]
                    if color then
                        row.val:SetTextColor(color[1], color[2], color[3])
                    else
                        row.val:SetTextColor(0.9, 0.9, 0.9)
                    end
                    row:Show()
                    rowIndex = rowIndex + 1
                end
            end
        end
    end

    inspectFrame:Show()
    inspectFrame:Raise()
end

-- ============================================================
-- SLASH COMMAND
-- ============================================================
local origSlash = SlashCmdList["NBOTINV"]
SlashCmdList["NBOTINV"] = function(msg)
    msg = msg:trim()
    local botName = msg:match("^inspect%s+(.+)$")
    if botName then
        NBI.OpenInspect(botName)
        return
    end
    origSlash(msg)
end

print("|cffFFD700[NPCBotInventory]|r BotInspect loaded. /botinv inspect <name>")
