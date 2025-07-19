print("Splity Addon is loading!")

-- Create the main frame
SplityFrame = CreateFrame("Frame", "SplityFrame", UIParent)
SplityFrame:SetWidth(200)
SplityFrame:SetHeight(300)
SplityFrame:SetPoint("CENTER", UIParent, "CENTER")
SplityFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
SplityFrame:SetBackdropColor(0, 0, 0)

SplityFrame:SetMovable(true)
SplityFrame:EnableMouse(true)
SplityFrame:RegisterForDrag("LeftButton")
SplityFrame:SetScript("OnDragStart", function() this:StartMoving() end)
SplityFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
SplityFrame:Hide() -- Hidden by default

-- Title text
SplityFrame.title = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
SplityFrame.title:SetPoint("TOP", SplityFrame, "TOP", 0, -10)
SplityFrame.title:SetText("Level Splits")

-- Total time text
SplityFrame.totalTimeText = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
SplityFrame.totalTimeText:SetPoint("BOTTOM", SplityFrame, "BOTTOM", 0, 10)
SplityFrame.totalTimeText:SetText("Total Time: 00:00:00")

-- Storage for lines
local levelTextLines = {}
local totalTimePlayed = 0

-- Time formatting
local function formatTime(seconds)
    local h = floor(seconds / 3600)
    local m = floor((seconds % 3600) / 60)
    local s = floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- Update display
function Splity_UpdateDisplay()
    for i, line in ipairs(levelTextLines) do
        line:Hide()
    end

    local displayIndex = 1
    local sortedLevels = {}
    for level in pairs(SplityData.times) do
        table.insert(sortedLevels, level)
    end
    table.sort(sortedLevels)

    for _, level in ipairs(sortedLevels) do
        local time = SplityData.times[level]
        if not levelTextLines[displayIndex] then
            levelTextLines[displayIndex] = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            levelTextLines[displayIndex]:SetPoint("TOPLEFT", SplityFrame.title, "BOTTOMLEFT", 10, - (displayIndex * 15))
        end
        levelTextLines[displayIndex]:SetText("Level " .. level .. ": " .. time)
        levelTextLines[displayIndex]:Show()
        displayIndex = displayIndex + 1
    end

    SplityFrame.totalTimeText:SetText("Total Time: " .. formatTime(totalTimePlayed))
end

-- Event frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        if not SplityData then
            SplityData = {
                times = {},
                totalTime = 0
            }
        end
        totalTimePlayed = SplityData.totalTime or 0
        Splity_UpdateDisplay()

    elseif event == "PLAYER_LEVEL_UP" then
        local playerLevel = arg1
        SplityData.times[playerLevel] = formatTime(totalTimePlayed)
        Splity_UpdateDisplay()
        SplityFrame:Show()
    end
end)

-- Time tracker
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function()
    totalTimePlayed = totalTimePlayed + arg1
    updateFrame.timeSinceLastUpdate = (updateFrame.timeSinceLastUpdate or 0) + arg1
    if updateFrame.timeSinceLastUpdate > 1 then
        SplityFrame.totalTimeText:SetText("Total Time: " .. formatTime(totalTimePlayed))
        updateFrame.timeSinceLastUpdate = 0
    end
end)

-- Slash command
SLASH_SPLITY1 = "/splity"
SlashCmdList["SPLITY"] = function()
    if SplityFrame:IsShown() then
        SplityFrame:Hide()
    else
        SplityFrame:Show()
    end
end

-- Save on logout
local logoutFrame = CreateFrame("Frame")
logoutFrame:RegisterEvent("PLAYER_LOGOUT")
logoutFrame:SetScript("OnEvent", function()
    if SplityData then
        SplityData.totalTime = totalTimePlayed
    end
end)
