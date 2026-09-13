
addEventHandler("onPlayerJoin",root,
function ()
	bindKey(source,"mouse1","down",nitro)
	bindKey(source,"mouse1","up",nitro)
	bindKey(source,"lctrl","down",nitro)
	bindKey(source,"lctrl","up",nitro)
	bindKey(source,"lalt","down",nitro)
	bindKey(source,"lalt","up",nitro)
end)
 

addEventHandler("onResourceStart",resourceRoot,
function ()
	for index, player in ipairs(getElementsByType("player")) do
		  bindKey(player,"mouse1","down",nitro)
		  bindKey(player,"mouse1","up",nitro)
		  bindKey(player,"lctrl","down",nitro)
		  bindKey(player,"lctrl","up",nitro)
		  bindKey(player,"lalt","down",nitro)
		  bindKey(player,"lalt","up",nitro)
	end
end)
 

-- List of unsupported vehicle models (attack vehicles, etc.)
local unsupportedVehicleModels = {
	[432] = true, -- Rhino
	[601] = true, -- SWAT
	-- Add more attack vehicle model IDs here if needed
}

local unsupportedVehicleTypes = {
	["Boat"] = true,
	["Helicopter"] = true,
	["Train"] = true,
}

local nitroState = {}

function nitro(thePlayer, key, state)
	if isPedInVehicle(thePlayer) then
		local id = 1010
		local theVehicle = getPedOccupiedVehicle(thePlayer)
		local model = getElementModel(theVehicle)
		local vType = getVehicleType(theVehicle)
		-- Block unsupported vehicles
		if unsupportedVehicleModels[model] or unsupportedVehicleTypes[vType] then
			return
		end
		if key == "n" and state == "down" then
			-- Toggle master nitro state
			nitroState[thePlayer] = not nitroState[thePlayer]
			if nitroState[thePlayer] then
				addVehicleUpgrade(theVehicle, id)
				outputChatBox("Nitro activated", thePlayer, 0, 255, 0)
			else
				removeVehicleUpgrade(theVehicle, id)
				outputChatBox("Nitro deactivated", thePlayer, 255, 0, 0)
			end
		elseif (key == "lctrl" or key == "lalt") and state == "down" then
			-- Toggle nitro with lctrl or lalt, only if N is toggled ON
			if nitroState[thePlayer] then
				local upgrades = getVehicleUpgrades(theVehicle)
				local hasNitro = false
				for _, upgrade in ipairs(upgrades) do
					if upgrade == id then
						hasNitro = true
						break
					end
				end
				if hasNitro then
					removeVehicleUpgrade(theVehicle, id)
				else
					addVehicleUpgrade(theVehicle, id)
				end
			end
		elseif key == "mouse1" then
			-- Only allow mouse1 if N is toggled ON (hold-to-activate)
			if nitroState[thePlayer] then
				if state == "down" then
					addVehicleUpgrade(theVehicle, id)
				elseif state == "up" then
					removeVehicleUpgrade(theVehicle, id)
				end
			end
		end
	end
end

addEventHandler("onPlayerJoin",root,
function ()
	bindKey(source,"n","down",nitro)
end)


addEventHandler("onResourceStart",resourceRoot,
function ()
	for index, player in ipairs(getElementsByType("player")) do
		bindKey(player,"n","down",nitro)
	end
end)