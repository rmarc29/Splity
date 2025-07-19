-- Turtle WoW uses some Vanilla API, but allow for tweaks
DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Splity Addon is loading...|r")

-- Create main UI frame
local SplityFrame = CreateFrame("Frame", "SplityFrame", UIParent)
SplityFrame:SetWidth(200)
SplityFrame:SetHeight(300)
SplityFrame:SetPoint("CENTER")
SplityFrame:SetBackdrop({
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 32, edgeSize = 16,
  insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
SplityFrame:SetMovable(true)
SplityFrame:EnableMouse(true)
SplityFrame:RegisterForDrag("LeftButton")
SplityFrame:SetScript("OnDragStart", function() self:StartMoving() end)
SplityFrame:SetScript("OnDragStop", function() self:StopMovingOrSizing() end)
SplityFrame:Show() 

-- Title
local title = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("Level Splits")

-- Total time
local totalText = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
totalText:SetPoint("BOTTOM", 0, 10)
totalText:SetText("Total Time: 00:00:00")

-- Table for text lines
local levelLines = {}
local totalTime = 0

-- Format seconds into HH:MM:SS
local function FormatTime(seconds)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)
  local s = math.floor(seconds % 60)
  return string.format("%02d:%02d:%02d", h, m, s)
end

-- Update the display
function Splity_UpdateDisplay()
  for _, line in ipairs(levelLines) do line:Hide() end

  local i = 1
  local sorted = {}
  for lvl in pairs(SplityData.times) do table.insert(sorted, lvl) end
  table.sort(sorted)

  for _, lvl in ipairs(sorted) do
    local t = SplityData.times[lvl]
    if not levelLines[i] then
      levelLines[i] = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      levelLines[i]:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 10, -15 * i)
    end
    levelLines[i]:SetText("Level " .. lvl .. ": " .. t)
    levelLines[i]:Show()
    i = i + 1
  end

  totalText:SetText("Total Time: " .. FormatTime(totalTime))
end

-- Main event frame
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_LOGOUT")

f:SetScript("OnEvent", function()
  if event == "PLAYER_LOGIN" then
    if not SplityData then
      SplityData = { times = {}, totalTime = 0 }
    end
    totalTime = SplityData.totalTime or 0
    Splity_UpdateDisplay()

  elseif event == "PLAYER_LEVEL_UP" then
    local lvl = arg1 or UnitLevel("player") -- fallback in case arg1 fails
    SplityData.times[lvl] = FormatTime(totalTime)
    Splity_UpdateDisplay()
    SplityFrame:Show()

  elseif event == "PLAYER_LOGOUT" then
    SplityData.totalTime = totalTime
  end
end)

-- Time update
local updater = CreateFrame("Frame")
updater:SetScript("OnUpdate", function()
  totalTime = totalTime + arg1
  updater.timer = (updater.timer or 0) + arg1
  if updater.timer > 1 then
    totalText:SetText("Total Time: " .. FormatTime(totalTime))
    updater.timer = 0
  end
end)

-- Slash command
SLASH_SPLITY1 = "/splity"
SlashCmdList["SPLITY"] = function()
  if SplityFrame:IsVisible() then
    SplityFrame:Hide()
  else
    SplityFrame:Show()
  end
end
