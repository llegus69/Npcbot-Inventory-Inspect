-- ============================================================
-- NPCBotInventory - UI.lua
-- Compatible con WotLK 3.3.5 (sin SetColorTexture)
-- ============================================================

local NBI = NPCBotInventory

local C = {
    bg     = {0.05, 0.05, 0.08, 0.97},
    header = {0.08, 0.08, 0.13, 1},
    gold   = {1,    0.82, 0.0,  1},
    white  = {1,    1,    1,    1},
    grey   = {0.55, 0.55, 0.55, 1},
    green  = {0.2,  0.9,  0.4,  1},
    border = {0.3,  0.25, 0.15, 1},
}

local PANEL_W  = 180
local GEAR_W   = 360
local GEAR_H   = 520
local SLOT_SZ  = 36
local SLOT_PAD = 6

-- ============================================================
-- HELPERS
-- ============================================================
local function SetStyle(frame)
    frame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(C.bg[1], C.bg[2], C.bg[3], C.bg[4])
    frame:SetBackdropBorderColor(C.border[1], C.border[2], C.border[3], 1)
end

local function MakeDraggable(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
end

local function Divider(parent, y)
    local d = parent:CreateTexture(nil, "ARTWORK")
    d:SetHeight(1)
    d:SetPoint("TOPLEFT",  parent, "TOPLEFT",  8, y)
    d:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, y)
    d:SetTexture(C.gold[1], C.gold[2], C.gold[3], 0.4)  -- SetTexture con RGBA en 3.3.5
end

local function Header(parent, text)
    local h = CreateFrame("Frame", nil, parent)
    h:SetPoint("TOPLEFT",  parent, "TOPLEFT",  0, 0)
    h:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    h:SetHeight(34)
    h:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background" })
    h:SetBackdropColor(C.header[1], C.header[2], C.header[3], C.header[4])
    local t = h:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    t:SetPoint("LEFT", h, "LEFT", 12, 0)
    t:SetText(text)
    t:SetTextColor(C.gold[1], C.gold[2], C.gold[3])
    Divider(parent, -34)
    return t
end

local function SolidTexture(parent, r, g, b, a, layer)
    local tex = parent:CreateTexture(nil, layer or "BACKGROUND")
    tex:SetTexture(r, g, b, a or 1)
    return tex
end

-- ============================================================
-- VENTANA DE EQUIPO
-- ============================================================
local gearFrame = CreateFrame("Frame", "NBI_GearFrame", UIParent)
gearFrame:SetSize(GEAR_W, GEAR_H)
gearFrame:SetPoint("CENTER")
gearFrame:SetFrameStrata("MEDIUM")
SetStyle(gearFrame)
MakeDraggable(gearFrame)
gearFrame:Hide()

local gearTitle = Header(gearFrame, "Bot Gear")

local gearClose = CreateFrame("Button", nil, gearFrame, "UIPanelCloseButton")
gearClose:SetPoint("TOPRIGHT", gearFrame, "TOPRIGHT", 1, 1)
gearClose:SetScript("OnClick", function() gearFrame:Hide() end)

local gearScroll = CreateFrame("ScrollFrame", "NBI_GearScroll", gearFrame, "UIPanelScrollFrameTemplate")
gearScroll:SetPoint("TOPLEFT",     gearFrame, "TOPLEFT",     8, -42)
gearScroll:SetPoint("BOTTOMRIGHT", gearFrame, "BOTTOMRIGHT", -26, 8)

local gearContent = CreateFrame("Frame", nil, gearScroll)
gearContent:SetSize(GEAR_W - 40, 10)
gearScroll:SetScrollChild(gearContent)

gearFrame.slots = {}

local function ShowBotGear(botName)
    local inventory = NBI.botInventories[botName]
    if not inventory then return end

    gearTitle:SetText(botName .. "'s Gear")

    for _, s in ipairs(gearFrame.slots) do
        s.frame:Hide()
    end

    local cols  = 2
    local cellW = math.floor((GEAR_W - 50) / cols)
    local cellH = SLOT_SZ + 18

    for i, link in ipairs(inventory) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        local x   = 6 + col * cellW
        local y   = -8 - row * (cellH + SLOT_PAD)

        if not gearFrame.slots[i] then
            local cont = CreateFrame("Button", nil, gearContent)
            cont:SetSize(cellW - 4, cellH)
            cont:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight", "ADD")

            local iconBg = CreateFrame("Frame", nil, cont)
            iconBg:SetSize(SLOT_SZ, SLOT_SZ)
            iconBg:SetPoint("TOPLEFT", cont, "TOPLEFT", 2, -2)
            iconBg:SetBackdrop({
                bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 8, edgeSize = 8,
                insets = { left = 2, right = 2, top = 2, bottom = 2 },
            })
            iconBg:SetBackdropColor(0.1, 0.1, 0.1, 1)

            local icon = iconBg:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(iconBg)
            icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

            local nameLabel = cont:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            nameLabel:SetPoint("LEFT",  iconBg, "RIGHT", 6, 2)
            nameLabel:SetPoint("RIGHT", cont,   "RIGHT", -2, 2)
            nameLabel:SetJustifyH("LEFT")
            nameLabel:SetTextColor(C.white[1], C.white[2], C.white[3])

            local qBar = cont:CreateTexture(nil, "BORDER")
            qBar:SetHeight(2)
            qBar:SetPoint("BOTTOMLEFT",  iconBg, "BOTTOMLEFT",  0, -3)
            qBar:SetPoint("BOTTOMRIGHT", iconBg, "BOTTOMRIGHT", 0, -3)
            qBar:SetTexture(0.4, 0.4, 0.4, 0.5)

            gearFrame.slots[i] = { frame = cont, icon = icon, name = nameLabel, qBar = qBar }
        end

        local s = gearFrame.slots[i]
        s.frame:ClearAllPoints()
        s.frame:SetPoint("TOPLEFT", gearContent, "TOPLEFT", x, y)
        s.frame:Show()

        local _, itemName, quality, _, _, _, _, _, _, texture = GetItemInfo(link)
        if not texture then
            itemName = string.match(link, "%[(.-)%]") or "Unknown"
            texture  = "Interface\\Icons\\INV_Misc_QuestionMark"
        end

        s.icon:SetTexture(texture)
        s.name:SetText(itemName or "")

        if quality then
            local qr, qg, qb = GetItemQualityColor(quality)
            s.qBar:SetTexture(qr, qg, qb, 1)
        else
            s.qBar:SetTexture(0.4, 0.4, 0.4, 0.5)
        end

        s.frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(link)
            GameTooltip:Show()
        end)
        s.frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    local rows = math.ceil(#inventory / cols)
    gearContent:SetHeight(rows * (cellH + SLOT_PAD) + 20)
    gearFrame:Show()
    gearFrame:Raise()
end

-- ============================================================
-- PANEL DE LISTA DE BOTS
-- ============================================================
local listPanel = CreateFrame("Frame", "NBI_ListPanel", UIParent)
listPanel:SetSize(PANEL_W, 420)
listPanel:SetPoint("CENTER", UIParent, "CENTER", -300, 0)
listPanel:SetFrameStrata("MEDIUM")
SetStyle(listPanel)
MakeDraggable(listPanel)
listPanel:Hide()

Header(listPanel, "NPCBots")

local listClose = CreateFrame("Button", nil, listPanel, "UIPanelCloseButton")
listClose:SetPoint("TOPRIGHT", listPanel, "TOPRIGHT", 1, 1)
listClose:SetScript("OnClick", function()
    listPanel:Hide()
    gearFrame:Hide()
end)

local listScroll = CreateFrame("ScrollFrame", "NBI_ListScroll", listPanel, "UIPanelScrollFrameTemplate")
listScroll:SetPoint("TOPLEFT",     listPanel, "TOPLEFT",     6, -42)
listScroll:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT", -26, 44)

local listContent = CreateFrame("Frame", nil, listScroll)
listContent:SetSize(PANEL_W - 36, 10)
listScroll:SetScrollChild(listContent)

listPanel.botButtons = {}

local function RefreshBotList()
    for _, btn in pairs(listPanel.botButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    wipe(listPanel.botButtons)

    local names = {}
    for name in pairs(NBI.botInventories) do
        table.insert(names, name)
    end
    table.sort(names)

    local btnH = 26
    local yOff = -4

    for _, botName in ipairs(names) do
        local btn = CreateFrame("Button", nil, listContent)
        btn:SetSize(PANEL_W - 40, btnH)
        btn:SetPoint("TOPLEFT", listContent, "TOPLEFT", 2, yOff)

        local bg = SolidTexture(btn, 0.12, 0.12, 0.18, 0.8, "BACKGROUND")
        bg:SetAllPoints()

        local hl = SolidTexture(btn, C.gold[1], C.gold[2], C.gold[3], 0.15, "HIGHLIGHT")
        hl:SetAllPoints()

        local dot = SolidTexture(btn, C.green[1], C.green[2], C.green[3], 1, "ARTWORK")
        dot:SetSize(6, 6)
        dot:SetPoint("LEFT", btn, "LEFT", 6, 0)

        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("LEFT",  btn, "LEFT",  18, 0)
        lbl:SetPoint("RIGHT", btn, "RIGHT", -40, 0)
        lbl:SetJustifyH("LEFT")
        lbl:SetTextColor(C.white[1], C.white[2], C.white[3])
        lbl:SetText(botName)

        local count = NBI.botInventories[botName] and #NBI.botInventories[botName] or 0
        local cnt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        cnt:SetPoint("RIGHT", btn, "RIGHT", -28, 0)
        cnt:SetTextColor(C.grey[1], C.grey[2], C.grey[3])
        cnt:SetText("(" .. count .. ")")

        -- Boton de inspect (abre paperdoll del bot)
        local inspBtn = CreateFrame("Button", nil, btn, "UIPanelButtonTemplate")
        inspBtn:SetSize(22, 18)
        inspBtn:SetPoint("RIGHT", btn, "RIGHT", -2, 0)
        inspBtn:SetText("i")
        inspBtn:SetScript("OnClick", function(self)
            if NPCBotInventory.OpenInspect then
                NPCBotInventory.OpenInspect(botName)
            end
        end)
        inspBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Open paperdoll inspect")
            GameTooltip:Show()
        end)
        inspBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btn:SetScript("OnClick", function()
            gearFrame:ClearAllPoints()
            gearFrame:SetPoint("TOPLEFT", listPanel, "TOPRIGHT", 4, 0)
            ShowBotGear(botName)
        end)
        btn:SetScript("OnEnter", function()
            lbl:SetTextColor(C.gold[1], C.gold[2], C.gold[3])
        end)
        btn:SetScript("OnLeave", function()
            lbl:SetTextColor(C.white[1], C.white[2], C.white[3])
        end)

        table.insert(listPanel.botButtons, btn)
        yOff = yOff - btnH - 2
    end

    listContent:SetHeight(math.abs(yOff) + 8)
    listPanel:SetHeight(math.min(math.max(math.abs(yOff) + 90, 120), 500))
end

-- Boton borrar todo
StaticPopupDialogs["NBI_CONFIRM_CLEAR"] = {
    text           = "Borrar todos los inventarios de bot?",
    button1        = "Si, borrar",
    button2        = "Cancelar",
    OnAccept       = function() NBI.ClearAll() end,
    timeout        = 0,
    whileDead      = true,
    hideOnEscape   = true,
    preferredIndex = 3,
}

local clearBtn = CreateFrame("Button", nil, listPanel, "UIPanelButtonTemplate")
clearBtn:SetSize(PANEL_W - 20, 24)
clearBtn:SetPoint("BOTTOM", listPanel, "BOTTOM", 0, 10)
clearBtn:SetText("Borrar todo")
clearBtn:SetScript("OnClick", function()
    StaticPopup_Show("NBI_CONFIRM_CLEAR")
end)

-- ============================================================
-- BOTON FLOTANTE
-- ============================================================
local toggleBtn = CreateFrame("Button", "NBI_ToggleButton", UIParent, "UIPanelButtonTemplate")
toggleBtn:SetSize(130, 28)
toggleBtn:SetText("Bot Inventory")
toggleBtn:SetFrameStrata("HIGH")
MakeDraggable(toggleBtn)
toggleBtn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Guardar posicion para la proxima sesion
    local point, _, relPoint, x, y = self:GetPoint()
    NBIButtonPos = { point = point, relPoint = relPoint, x = x, y = y }
    if listPanel:IsShown() then
        listPanel:ClearAllPoints()
        listPanel:SetPoint("TOP", self, "BOTTOM", 0, -4)
    end
end)
toggleBtn:SetScript("OnClick", function()
    if listPanel:IsShown() then
        listPanel:Hide()
        gearFrame:Hide()
    else
        listPanel:ClearAllPoints()
        listPanel:SetPoint("TOP", toggleBtn, "BOTTOM", 0, -4)
        RefreshBotList()
        listPanel:Show()
    end
end)

-- ============================================================
-- CALLBACKS desde Core.lua
-- ============================================================
function NBI.OnDataLoaded()
    -- Restaurar posicion del boton o usar posicion segura por defecto
    toggleBtn:ClearAllPoints()
    if NBIButtonPos then
        toggleBtn:SetPoint(NBIButtonPos.point, UIParent, NBIButtonPos.relPoint, NBIButtonPos.x, NBIButtonPos.y)
    else
        -- Esquina superior derecha, siempre visible
        toggleBtn:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -220, -100)
    end

    RefreshBotList()
    if next(NBI.botInventories) ~= nil then
        listPanel:ClearAllPoints()
        listPanel:SetPoint("TOP", toggleBtn, "BOTTOM", 0, -4)
        listPanel:Show()
    end
end

function NBI.OnBotDataUpdated(botName)
    if listPanel:IsShown() then RefreshBotList() end
    if gearFrame:IsShown()  then ShowBotGear(botName) end
end

function NBI.OnDataCleared()
    gearFrame:Hide()
    RefreshBotList()
end

-- ============================================================
-- SLASH COMMANDS
-- ============================================================
SLASH_NBOTINV1 = "/botinv"
SLASH_NBOTINV2 = "/npcbotinv"
SlashCmdList["NBOTINV"] = function(msg)
    msg = msg:trim()
    if msg == "" then
        if listPanel:IsShown() then
            listPanel:Hide()
            gearFrame:Hide()
        else
            listPanel:ClearAllPoints()
            listPanel:SetPoint("TOP", toggleBtn, "BOTTOM", 0, -4)
            RefreshBotList()
            listPanel:Show()
        end
    else
        if NBI.botInventories[msg] then
            ShowBotGear(msg)
        else
            print("|cffFFD700[NPCBotInventory]|r Bot '" .. msg .. "' no encontrado.")
        end
    end
end

print("|cffFFD700[NPCBotInventory]|r Cargado. Usa /botinv para abrir.")
