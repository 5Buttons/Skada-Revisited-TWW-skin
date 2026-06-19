local addonName = "SkadaTWW"
local mediaPath = [[Interface\AddOns\SkadaTWW\Textures]]

local LSM = LibStub("LibSharedMedia-3.0", true)
if LSM then
    LSM:Register("statusbar", "TWWBar",         mediaPath .. [[\bar]])
    LSM:Register("statusbar", "TWWHeader",      mediaPath .. [[\header]])
    LSM:Register("background", "TWWBackground", mediaPath .. [[\background]])
    LSM:Register("font", "Friz Quadrata TT",   [[Fonts\FRIZQT__.TTF]])
end

-- TWW visual settings to apply to every Skada window
local TWW_SETTINGS = {
    bartexture     = "TWWBar",
    barheight      = 28,
    barspacing     = 4,
    classcolorbars = true,
    classicons     = true,
    specicons      = true,
    barfont        = "Friz Quadrata TT",
    barfontsize    = 11,
    barfontflags   = "",
    numfont        = "Friz Quadrata TT",
    numfontsize    = 11,
    numfontflags   = "",
    barbgcolor     = {r = 0.05, g = 0.05, b = 0.05, a = 0.5},
    -- title bar
    title = {
        texture       = "TWWHeader",
        height        = 32,
        font          = "Friz Quadrata TT",
        fontsize      = 13,
        fontflags     = "",
        color         = {r = 1.0,   g = 0.82,  b = 0.0,   a = 1},
        textcolor     = {r = 1.0,   g = 0.82,  b = 0.0,   a = 1},
        bordertexture = "None",
    },
    -- window background: fully transparent (TWW style)
    background = {
        texture      = "Solid",
        color        = {r = 0.094, g = 0.094, b = 0.094, a = 0},
        bordercolor  = {r = 0.0,   g = 0.0,   b = 0.0,   a = 0},
        bordertexture = "None",
    },
}

local function applyToWindow(db)
    db.bartexture     = TWW_SETTINGS.bartexture
    db.barheight      = TWW_SETTINGS.barheight
    db.barspacing     = TWW_SETTINGS.barspacing
    db.classcolorbars = TWW_SETTINGS.classcolorbars
    db.classicons     = TWW_SETTINGS.classicons
    db.specicons      = TWW_SETTINGS.specicons
    db.barfont        = TWW_SETTINGS.barfont
    db.barfontsize    = TWW_SETTINGS.barfontsize
    db.barfontflags   = TWW_SETTINGS.barfontflags
    db.numfont        = TWW_SETTINGS.numfont
    db.numfontsize    = TWW_SETTINGS.numfontsize
    db.numfontflags   = TWW_SETTINGS.numfontflags
    db.barbgcolor     = db.barbgcolor or {}
    db.barbgcolor.r   = TWW_SETTINGS.barbgcolor.r
    db.barbgcolor.g   = TWW_SETTINGS.barbgcolor.g
    db.barbgcolor.b   = TWW_SETTINGS.barbgcolor.b
    db.barbgcolor.a   = TWW_SETTINGS.barbgcolor.a

    db.title = db.title or {}
    for k, v in pairs(TWW_SETTINGS.title) do
        if type(v) == "table" then
            db.title[k] = db.title[k] or {}
            for k2, v2 in pairs(v) do
                db.title[k][k2] = v2
            end
        else
            db.title[k] = v
        end
    end

    db.background = db.background or {}
    for k, v in pairs(TWW_SETTINGS.background) do
        if type(v) == "table" then
            db.background[k] = db.background[k] or {}
            for k2, v2 in pairs(v) do
                db.background[k][k2] = v2
            end
        else
            db.background[k] = v
        end
    end
end

-- hook UpdateOrientationLayout so any bar group has _textYOffset
-- i hope this doesnt fuck performance kekw
local SLB = LibStub("SpecializedLibBars-1.0", true)
if SLB then
    local orig = SLB.barPrototype.UpdateOrientationLayout
    local LEFT_TO_RIGHT = 1
    SLB.barPrototype.UpdateOrientationLayout = function(self, orientation)
        orig(self, orientation)
        local offset = self.ownerGroup and self.ownerGroup._textYOffset or 0
        if offset == 0 then return end
        if orientation == LEFT_TO_RIGHT then
            self.timerLabel:SetPoint("RIGHT", self, "RIGHT", -5, offset)
            self.label:SetPoint("LEFT",  self, "LEFT",  5,  offset)
        else
            self.timerLabel:SetPoint("LEFT",  self, "LEFT",  5,  offset)
            self.label:SetPoint("RIGHT", self, "RIGHT", -5, offset)
        end
    end

    SLB.barListPrototype.SetBarTextYOffset = function(self, offset)
        self._textYOffset = offset or 0
        for _, bar in pairs(self:GetBars()) do
            bar:UpdateOrientationLayout(self.orientation or LEFT_TO_RIGHT)
        end
    end
    local origNewBar = SLB.barListPrototype.NewBar
    SLB.barListPrototype.NewBar = function(self, name, text, value, maxVal, icon)
        local bar, isNew = origNewBar(self, name, text, value, maxVal, icon)
        if self._textYOffset and self._textYOffset ~= 0 then
            bar:UpdateOrientationLayout(self.orientation or LEFT_TO_RIGHT)
        end
        return bar, isNew
    end
end

local TEXT_Y_OFFSET = 6

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    if Skada and Skada.windowdefaults then
        applyToWindow(Skada.windowdefaults)
    end

    if Skada and Skada.db and Skada.db.profile and Skada.db.profile.windows then
        for _, db in ipairs(Skada.db.profile.windows) do
            applyToWindow(db)
        end
    end

    if Skada and Skada.ApplySettings then
        Skada:ApplySettings()
    end

    if Skada and Skada.windows then
        for _, win in ipairs(Skada.windows) do
            if win.bargroup and win.bargroup.SetBarTextYOffset then
                win.bargroup:SetBarTextYOffset(TEXT_Y_OFFSET)
            end
        end
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cff8080ffSkada TWW Skin|r applied.")
end)
