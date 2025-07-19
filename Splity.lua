-- Create the main frame to hold level splits
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
SplityFrame:SetBackdropColor(0, 0, 0, 0.8)
SplityFrame:SetMovable(true)
SplityFrame:EnableMouse(true)
SplityFrame:RegisterForDrag("LeftButton")
SplityFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
SplityFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
SplityFrame:Hide() -- Initially hidden, shown on first level up or with a slash command

-- Create a title for the frame
SplityFrame.title = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
SplityFrame.title:SetPoint("TOP", SplityFrame, "TOP", 0, -10)
SplityFrame.title:SetText("Level Splits")

-- Create a FontString for the total time
SplityFrame.totalTimeText = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
SplityFrame.totalTimeText:SetPoint("BOTTOM", SplityFrame, "BOTTOM", 0, 10)
SplityFrame.totalTimeText:SetText("Total Time: 00:00:00")

-- Table to hold the FontString objects for each level line
local levelTextLines = {}
local totalTimePlayed = 0

-- Function to format seconds into HH:MM:SS
local function formatTime(seconds)
    local h = floor(seconds / 3600)
    local m = floor((seconds % 3600) / 60)
    local s = floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- Function to update the display
function Splity_UpdateDisplay()
    -- Clear any existing level text lines
    for i, line in ipairs(levelTextLines) do
        line:Hide()
    end

    local displayIndex = 1
    -- We need to sort the keys to display levels in order
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
        levelTextLines[displayIndex]:SetText("Level "..level..": "..time)
        levelTextLines[displayIndex]:Show()
        displayIndex = displayIndex + 1
    end

    -- Update total time
    SplityFrame.totalTimeText:SetText("Total Time: " .. formatTime(totalTimePlayed))
end


-- Create a frame to handle our events
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(event, arg1)
    if event == "PLAYER_LOGIN" then
        -- Initialize our saved data if it doesn't exist
        if SplityData == nil then
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
        SplityFrame:Show() -- Show the frame when the player levels up
    end
end)
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")

-- Frame to update the total time every second
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self, elapsed)
    totalTimePlayed = totalTimePlayed + elapsed
    
    -- Update the display text, but not too frequently to avoid performance issues
    self.timeSinceLastUpdate = (self.timeSinceLastUpdate or 0) + elapsed
    if self.timeSinceLastUpdate > 1 then
        SplityFrame.totalTimeText:SetText("Total Time: " .. formatTime(totalTimePlayed))
        self.timeSinceLastUpdate = 0
    end
end)


-- Slash command to show/hide the frame
SLASH_Splity1 = "/Splity"
SlashCmdList["Splity"] = function()
    if SplityFrame:IsShown() then
        SplityFrame:Hide()
    else
        SplityFrame:Show()
    end
end

-- On logout, save the total time played
local logoutFrame = CreateFrame("Frame")
logoutFrame:RegisterEvent("PLAYER_LOGOUT")
logoutFrame:SetScript("OnEvent", function()
    if SplityData then
        SplityData.totalTime = totalTimePlayed
    end
end)```