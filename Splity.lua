-- Print to chat
DEFAULT_CHAT_FRAME:AddMessage("Splity Addon is loading!")

-- Create frame
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
SplityFrame:Hide()

-- Title text
local title = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10)
title:SetText("Level Splits")

-- Total time text
local totalText = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
totalText:SetPoint("BOTTOM", 0, 10)
totalText:SetText("Total Time: 00:00:00")

-- Utility
local function FormatTime(seconds)
  local h = floor(seconds / 3600)
  local m = floor((seconds % 3600) / 60)
  local s = floor(seconds % 60)
  return string.format("%02d:%02d:%02d", h, m, s)
end

local levelLines = {}
local totalTime = 0

-- Display update
function Splity_UpdateDisplay()
  for _, line in ipairs(levelLines) do line:Hide() end

  local i = 1
  local sorted = {}
  for k in pairs(SplityData.times) do table.insert(sorted, k) end
  table.sort(sorted)

  for _, level in ipairs(sorted) do
    local time = SplityData.times[level]
    if not levelLines[i] then
      levelLines[i] = SplityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      levelLines[i]:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 10, -i * 15)
    end
    levelLines[i]:SetText("Level " .. level .. ": " .. time)
    levelLines[i]:Show()
    i = i + 1
  end

  totalText:SetText("Total Time: " .. FormatTime(totalTime))
end

-- Event handler
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LEVEL_UP")
f:RegisterEvent("PLAYER_LOGOUT")

f:SetScript("OnEvent", function()
  if event == "PLAYER_LOGIN" then
    if not SplityData then SplityData = { times = {}, totalTime = 0 } end
    totalTime = SplityData.totalTime or 0
    Splity_UpdateDisplay()
  elseif event == "PLAYER_LEVEL_UP" then
    local lvl = arg1
    SplityData.times[lvl] = FormatTime(totalTime)
    Splity_UpdateDisplay()
    SplityFrame:Show()
  elseif event == "PLAYER_LOGOUT" then
    SplityData.totalTime = totalTime
  end
end)

-- Timer
local update = CreateFrame("Frame")
update:SetScript("OnUpdate", function()
  totalTime = totalTime + arg1
  update.timeSince = (update.timeSince or 0) + arg1
  if update.timeSince > 1 then
    totalText:SetText("Total Time: " .. FormatTime(totalTime))
    update.timeSince = 0
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
