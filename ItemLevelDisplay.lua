local frame = CreateFrame("Frame")

local inspectedUnit -- Variable to store the unit being inspected
local itemLevelFrame -- Frame for displaying item level

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
        itemLevelFrame:SetBackdrop(backdrop)
        
        -- Optional: Set backdrop color
        -- itemLevelFrame:SetBackdropColor(1, 1, 0, 1) -- Adjust the color and opacity as needed
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
    
    -- if unit == "player" or unit == nil then -- Check if it's the player or if the unit is nil (e.g., during an inspection)
    --     itemLevelFrame.text:SetText("") -- Clear the text
    --     itemLevelFrame:Hide() -- Hide the frame
    --     return
    -- end
    
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

local function GetItemLevelFromArmory(unit)
	local playerName = UnitName(unit)
	-- print(playerName)

	-- local http = require("socket.http")
	local armory_url = "https://db.whitemane.org/armory/maelstrom/" .. playerName
	-- print(armory_url)
	-- local response, status_code = http.request(armory_url)
	
	-- if status_code == 200 then
	-- 	local armory_html = response
	-- 	-- Extract item level using pattern matching
	-- 	local item_level = armory_html:match('<div class="item%-level">(.-)</div>')
	-- 	if item_level then
	-- 		-- Send item level to webhook endpoint
	-- 		local webhook_url = "https://example.com/webhook"
	-- 		local payload = "item_level=" .. item_level
	-- 		local res, status = http.request {
	-- 			url = webhook_url,
	-- 			method = "POST",
	-- 			headers = {
	-- 				["Content-Type"] = "application/x-www-form-urlencoded",
	-- 				["Content-Length"] = #payload
	-- 			},
	-- 			source = ltn12.source.string(payload)
	-- 		}
	-- 		if status == 200 then
	-- 			print("Item level sent to webhook successfully.")
	-- 		else
	-- 			print("Failed to send item level to webhook.")
	-- 		end
	-- 	else
	-- 		print("Item level not found in HTML.")
	-- 	end
	-- else
	-- 	print("Failed to fetch Armory page.")
	-- end
end
frame:RegisterEvent("INSPECT_READY")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")


-- PlayerI = 0
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "UPDATE_MOUSEOVER_UNIT" then
		-- inspectedUnit = "mouseover"
		local inspectedUnit = "mouseover"
        local unitExists = UnitExists(inspectedUnit)
        local isPlayer = UnitIsPlayer(inspectedUnit)
        
        if unitExists and isPlayer  then
			-- PlayerName[tostring(PlayerI)] = UnitName(inspectedUnit)
			-- PlayerI= PlayerI + 1
            NotifyInspect(inspectedUnit)
			UpdateItemLevel(inspectedUnit)
			GetItemLevelFromArmory(inspectedUnit)
			
            -- Store the player's name in a global variable or SavedVariable
            -- MyAddonPlayerName = UnitName("player")
			
			-- print('added to list' .. PlayerI)
			-- table.insert(PlayerName, UnitName(inspectedUnit))
        end

    -- elseif event == "UPDATE_MOUSEOVER_UNIT" then
    --     inspectedUnit = "mouseover"
    --     UpdateItemLevel(inspectedUnit)
    end
end)


-- if event == "INSPECT_READY" then
		
-- 	UpdateItemLevel("mouseover")
-- elseif event == "UPDATE_MOUSEOVER_UNIT" then
-- 	local unit = "mouseover"
-- 	local unitExists = UnitExists(unit)
-- 	local isPlayer = UnitIsPlayer(unit)
	
-- 	if unitExists and isPlayer then
-- 		InspectPlayer(unit) -- Trigger inspection
-- 		UpdateItemLevel(unit)
-- 	end
-- end