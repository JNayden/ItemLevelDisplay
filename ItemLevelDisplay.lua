

print("###[Addon Title: " .. "ItemLevelDisplay 4.3.4]###")
print("--[ Item frame usage: ]--")
print("--[ Lock: /il l ]--")
print("--[ Unlock: /il ul ]--")
print("--[ Reset position: /il rs ]--")
local function initSavedVars()
    if HaveWeMetCount == nil or HaveWeMetCount1 == nil or HaveWeMetCount2 == nil then
        HaveWeMetCount = 380.7821044921875
        HaveWeMetCount1 = 113.6243209838867
        HaveWeMetCount2 = "BOTTOM"
    end
end
initSavedVars()
-- print("Version: " .. "1.0.0")
-- print("Interface Version: " .. "40300")
-- print("Author: " .. "Nayden")
local function GetAverageItemLevel(unit)
    local totalItemLevel = 0
    local numItems = 0
    
    for slotID = 1, 17 do -- Iterate through all equipment slots
        local itemLink = GetInventoryItemLink(unit, slotID)
        if itemLink then
            local _, _, _, itemLevel = GetItemInfo(itemLink)
            if itemLevel then
                totalItemLevel = totalItemLevel + itemLevel
                numItems = numItems + 1
            end
        end
    end
    
    if numItems > 0 then
        return totalItemLevel / numItems
    else
        return 0
    end
end

posXGlobalIndex = 0
posYGlobalIndex = 1
local function CreateItemLevelFrame()
    if not itemLevelFrame then
        itemLevelFrame = CreateFrame("Frame", "MyAddon_ItemLevelFrame", UIParent)
        itemLevelFrame:SetSize(250, 75)
        itemLevelFrame:SetPoint(HaveWeMetCount2, HaveWeMetCount, HaveWeMetCount1)
        -- print("1" .. HaveWeMetCount .. " " .. HaveWeMetCount1)
       
        local inspectedUnit = "mouseover"
        itemLevelFrame:EnableMouse(true)
        
        itemLevelFrame.text = itemLevelFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        itemLevelFrame.text:SetAllPoints(itemLevelFrame)
        itemLevelFrame.text:SetText("Item Level: --")
        itemLevelFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 16) -- Change 12 to your desired font size

        local backdrop = {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Background texture path
            -- bgFile = nil,
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", -- Border texture path
            tile = true, -- Tile the background texture
            tileSize = 32, -- Size of each tile for tiling the background texture
            edgeSize = 16, -- Size of the border
            insets = { left = 5, right = 5, top = 5, bottom = 5 } -- Insets for the border
        }
        
        -- Apply the backdrop to the item frame
        itemLevelFrame:SetMovable(true)
        itemLevelFrame:SetBackdrop(backdrop)
        itemLevelFrame:RegisterForDrag("LeftButton");
        itemLevelFrame:SetScript("OnDragStart", itemLevelFrame.StartMoving) 
        itemLevelFrame:SetScript("OnDragStop", itemLevelFrame.StopMovingOrSizing)
        itemLevelFrame:SetClampedToScreen(true)
    end
end

local function SetTextColor(itemLevel)
    local red, green, blue
    if itemLevel >= 378 and itemLevel <= 409 then
        local range = 409 - 378
        local value = (itemLevel - 378) / range
        
        if value <= 0.5 then
            -- Calculate light blue to dark blue gradient
            red = 0
            green = value * 2
            blue = 1
        elseif value <= 0.75 then
            -- Calculate dark blue to purple gradient
            value = (value - 0.5) * 4
            red = value
            green = 0
            blue = 1
        else
            -- Calculate purple to red gradient
            value = (value - 0.75) * 4
            red = 1
            green = 0
            blue = 1 - value
        end
    elseif itemLevel > 409 then
        red, green, blue = 1, 0, 0  -- Red for levels higher than 409
    else
        red, green, blue = 1, 1, 1  -- Default color (white)
    end
    itemLevelFrame.text:SetTextColor(red, green, blue)
end
local function round(number, decimals)
    local multiplier = 10^(decimals or 0)
    return math.floor(number * multiplier + 0.5) / multiplier
end
local function UpdateItemLevel(unit)
    if not itemLevelFrame then
        CreateItemLevelFrame()
    end
    
    local averageItemLevel = GetAverageItemLevel(unit)
    if averageItemLevel > 0 then -- Only display if the item level is greater than 0
		SetTextColor(averageItemLevel)
        itemLevelFrame.text:SetText(UnitName(unit) .. "'s Item Level: " .. round(averageItemLevel, 1))
        itemLevelFrame:Show() -- Show the frame
    else
        itemLevelFrame.text:SetText("") -- Clear the text
        itemLevelFrame:Hide() -- Hide the frame
    end
end

-- local function InspectPlayer(unit)
--     if CanInspect(unit) then
--         NotifyInspect(unit)
--         -- C_Timer.After(1, function() -- Delay to allow the inspection to complete
--         --     local averageItemLevel = GetAverageItemLevel(unit)
--         --     print("Average item level of " .. UnitName(unit) .. ": " .. averageItemLevel)
--         -- end)
--     end
-- end
local function HandleSlashCommand(msg)
    -- Check if the command is "reset position"
    if msg == "rs" then
        -- Code to reset the position of your addon frame
        print("Addon position reset")
        itemLevelFrame:SetSize(200, 75)
        itemLevelFrame:SetPoint("BOTTOMRIGHT", -400, 100)
        itemLevelFrame:EnableMouse(true)
        
        itemLevelFrame.text:SetAllPoints(itemLevelFrame)

        itemLevelFrame:SetMovable(true)
    
    elseif msg == "l" then
        -- Print a message indicating an unknown command
        print("ItemLevel frame is locked")
        itemLevelFrame:SetMovable(false)
    
    elseif msg == "ul" then
        -- Print a message indicating an unknown command
        print("ItemLevel frame is unlocked")
        itemLevelFrame:SetMovable(true)
    else
    print("Unknown command. Usage: /il l or /il ul")
    end
end

SLASH_ITEMLEVEL1 = "/il"
SlashCmdList["ITEMLEVEL"] = HandleSlashCommand


local isInspecting = false -- Flag to indicate if a player is currently being inspected
local inspectingUnit = nil -- Variable to store the unit currently being inspected
local inspectTrigger = nil -- Variable to store the trigger of the inspection

-- Function to handle inspection
local function InspectPlayer(unit, trigger)
    if not isInspecting and  CanInspect(unit)then
        NotifyInspect(unit)
        inspectingUnit = unit
        inspectTrigger = trigger
        isInspecting = true
    end
end
frame:RegisterEvent("INSPECT_READY")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")

local inspectedUnit = "mouseover"
frame:SetScript("OnEvent", function(self, event, ...)

    if itemLevelFrame then 
    local function OnFrameMoved(self)
            local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
            HaveWeMetCount = xOfs
            HaveWeMetCount1 = yOfs
            HaveWeMetCount2 = point
            print("Frame position: ", point, relativePoint, xOfs, yOfs)
        end

        -- Register event for frame drag start
        itemLevelFrame:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)

        -- Register event for frame drag stop
        itemLevelFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            OnFrameMoved(self)
        end)
    end
    if event == "UPDATE_MOUSEOVER_UNIT" then
        -- inspectedUnit = "mouseover"
        -- InspectUnit("target")
        local unitExists = UnitExists(inspectedUnit)
        local isPlayer = UnitIsPlayer(inspectedUnit)
        -- print(isInspecting)
        
        if unitExists and isPlayer  then
            if isInspecting and inspectingUnit ~= inspectedUnit then
                ClearInspectPlayer()
                isInspecting = false
            end
            InspectPlayer(inspectedUnit, "mouseover")
        end
    elseif  event == "INSPECT_READY" then
        isInspecting = false
        isInspecting = false
        inspectedUnit = "mouseover"
        local unitExists = UnitExists(inspectedUnit)
        local isPlayer = UnitIsPlayer(inspectedUnit)
        
        if unitExists and isPlayer  then
            if inspectTrigger == "mouseover" then
                -- Inspection triggered by mouseover
                InspectPlayer(inspectedUnit, "mouseover")
                UpdateItemLevel(inspectedUnit)
            elseif inspectTrigger == "target" then
            end
            -- NotifyInspect(inspectedUnit)
            -- print(HaveWeMetCount .. HaveWeMetCount1 .. HaveWeMetCount2)
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        isInspecting = false
        inspectedUnit = "target"
        local unitExists = UnitExists(inspectedUnit)
        local isPlayer = UnitIsPlayer(inspectedUnit)
        print(inspectedUnit)
        if unitExists and isPlayer then
            -- Do something with the target player
        end
    else
        print("Unknown command. Usage: /il l or /il ul")
    end
end)