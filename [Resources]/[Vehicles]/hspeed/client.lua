-- This resource lifts the cap on topspeed for aircraft, especially Hydra, and allows players to toggle it off back to normal with /airvel


local speeds = {
	[1] = {name = "Default Throttle", value = 1.5, color = {255, 255, 0}},
	[2] = {name = "Full Throttle", value = 13.41, color = {0, 255, 0}},
	[3] = {name = "Turbo Throttle", value = 30, color = {255, 0, 0}}
}
local currentMode = 1


addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		setAircraftMaxVelocity(speeds[currentMode].value)
		local c = speeds[currentMode].color
		outputChatBox("·"..speeds[currentMode].name, c[1], c[2], c[3])
	end
)


addEventHandler("onClientResourceStop", resourceRoot,
	function ()
		setAircraftMaxVelocity(speeds[1].value)
	end
)


addCommandHandler("airvel",
	function()
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if vehicle and getElementModel(vehicle) == 520 then -- Hydra model ID
			currentMode = currentMode % 3 + 1
			setAircraftMaxVelocity(speeds[currentMode].value)
			local c = speeds[currentMode].color
			outputChatBox("·"..speeds[currentMode].name, c[1], c[2], c[3])
		else
			outputChatBox("Throttle toggle only works in Hydra.", 255, 0, 0)
		end
	end
)

bindKey("1", "down", function()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and getElementModel(vehicle) == 520 then -- Hydra model ID
		-- Disable airbrake if active
		if airbrakeActive then
			airbrakeActive = false
			if airbrakeTimer then
				killTimer(airbrakeTimer)
				airbrakeTimer = nil
			end
			setAircraftMaxVelocity(speeds[currentMode].value)
			outputChatBox("·Airbrake disabled by throttle switch", 255, 255, 255)
		end
		currentMode = currentMode % 3 + 1
		setAircraftMaxVelocity(speeds[currentMode].value)
		local c = speeds[currentMode].color
		outputChatBox("·"..speeds[currentMode].name, c[1], c[2], c[3])
	else
		outputChatBox("Throttle toggle only works in Hydra.", 255, 0, 0)
	end
end)

local airbrakeActive = false
local previousMode = 1
local airbrakeTimer = nil

bindKey("3", "down", function()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and getElementModel(vehicle) == 520 then -- Hydra model ID
		if not airbrakeActive then
			airbrakeActive = true
			previousMode = currentMode
			setAircraftMaxVelocity(0.8)
			outputChatBox("·Airbrake activated", 0, 150, 255)
		else
			airbrakeActive = false
			if airbrakeTimer then
				killTimer(airbrakeTimer)
				airbrakeTimer = nil
			end
			setAircraftMaxVelocity(speeds[previousMode].value)
			local c = speeds[previousMode].color
			outputChatBox("·Airbrake deactivated, throttle restored", c[1], c[2], c[3])
		end
	else
		outputChatBox("Airbrake only works in Hydra.", 255, 0, 0)
	end
end)

addEventHandler("onClientVehicleExit", root, function(player)
	if player == localPlayer then
		airbrakeActive = false
		if airbrakeTimer then
			killTimer(airbrakeTimer)
			airbrakeTimer = nil
		end
		currentMode = 1
		setAircraftMaxVelocity(speeds[1].value)
		local c = speeds[1].color
		outputChatBox("·Throttle reset to default", c[1], c[2], c[3])
	end
end)