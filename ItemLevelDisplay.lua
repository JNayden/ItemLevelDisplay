

print("###[Addon Title: " .. "ItemLevelDisplay 4.3.4]###")
print("--[ Item frame usage: ]--")
print("--[ Lock: /il l ]--")
print("--[ Unlock: /il ul ]--")
print("--[ Reset position: /il rs ]--")
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

local function CreateItemLevelFrame()
    if not itemLevelFrame then
        itemLevelFrame = CreateFrame("Frame", "MyAddon_ItemLevelFrame", UIParent)
        itemLevelFrame:SetSize(200, 75)
        itemLevelFrame:SetPoint("BOTTOMRIGHT", -300, 100)
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

local function InspectPlayer(unit)
    if CanInspect(unit) then
        NotifyInspect(unit)
        C_Timer.After(1, function() -- Delay to allow the inspection to complete
            local averageItemLevel = GetAverageItemLevel(unit)
            print("Average item level of " .. UnitName(unit) .. ": " .. averageItemLevel)
        end)
    else
        print("Cannot inspect " .. UnitName(unit))
    end
end
local function HandleSlashCommand(msg)
    -- Check if the command is "reset position"
    if msg == "rs" then
        -- Code to reset the position of your addon frame
        print("Addon position reset")
        itemLevelFrame:SetPoint("BOTTOMRIGHT", -300, 100)
    
    elseif msg == "l" then
        -- Print a message indicating an unknown command
        print("ItemLevel frame is locked")
        itemLevelFrame:SetMovable(false)
    
    elseif msg == "ul" then
        -- Print a message indicating an unknown command
        print("ItemLevel frame is locked")
        itemLevelFrame:SetMovable(true)
    else
    print("Unknown command. Usage: /il l or /il ul")
    end
end

SLASH_ITEMLEVEL1 = "/il"
SlashCmdList["ITEMLEVEL"] = HandleSlashCommand
frame:RegisterEvent("INSPECT_READY")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")


frame:SetScript("OnEvent", function(self, event, ...)
    if event == "UPDATE_MOUSEOVER_UNIT" then
		-- inspectedUnit = "mouseover"
		local inspectedUnit = "mouseover"
        local unitExists = UnitExists(inspectedUnit)
        local isPlayer = UnitIsPlayer(inspectedUnit)
        
        if unitExists and isPlayer  then
            NotifyInspect(inspectedUnit)
			UpdateItemLevel(inspectedUnit)
			GetItemLevelFromArmory(inspectedUnit)
        end
    end
end)