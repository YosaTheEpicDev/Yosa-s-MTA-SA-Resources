-- When a player enters a vehicle, apply their custom plate (if any)
function onPlayerVehicleEnter(...)
    -- Determine vehicle and player robustly across different event signatures
    local vehicle, player
    local firstArg = select(1, ...)
    if isElement(source) then
        local t = getElementType(source)
        if t == "vehicle" then
            vehicle = source
        elseif t == "player" then
            player = source
        end
    end
    if not vehicle and isElement(firstArg) and getElementType(firstArg) == "vehicle" then
        vehicle = firstArg
    end
    if not player then
        if vehicle then
            player = getVehicleOccupant(vehicle, 0) or getVehicleOccupant(vehicle)
        end
    end
    if not vehicle and player then
        vehicle = getPedOccupiedVehicle(player)
    end
    if not vehicle or not isElement(vehicle) then return end

    local driver = getVehicleOccupant(vehicle, 0) or getVehicleOccupant(vehicle)
    if not driver then return end
    local plate = getElementData(driver, "customPlate") or getPlayerName(driver)
    if plate and #plate > 8 then
        plate = string.sub(plate, 1, 8)
    end
    setVehiclePlateText(vehicle, plate)
    -- Reapply after short delays to override other scripts that reset plates
    setTimer(function()
        if isElement(vehicle) then
            setVehiclePlateText(vehicle, plate)
        end
    end, 500, 1)
    setTimer(function()
        if isElement(vehicle) then
            setVehiclePlateText(vehicle, plate)
        end
    end, 1500, 1)
end

addEventHandler("onPlayerVehicleEnter", root, onPlayerVehicleEnter)
addEventHandler("onVehicleEnter", root, onPlayerVehicleEnter)

-- Helper to apply a player's plate to their current vehicle (if any)
local function applyPlayerPlateToCurrentVehicle(player)
    local veh = getPedOccupiedVehicle(player)
    if veh then
        local plate = getElementData(player, "customPlate") or getPlayerName(player)
        if plate and #plate > 8 then
            plate = string.sub(plate, 1, 8)
        end
        setVehiclePlateText(veh, plate)
    end
end

-- Command handler: /plate <text>
addCommandHandler("plate",
    function(player, cmd, ...)
        if not player then return end
        -- Only allow changing plates while the player is inside a vehicle
        local currentVeh = getPedOccupiedVehicle(player)
        if not currentVeh then
            outputChatBox("You must be in a vehicle to change your plate.", player, 255, 0, 0)
            return
        end
        local text = table.concat({...}, " ") or ""
        text = text:gsub("^%s+",""):gsub("%s+$","")
        if text == "" then
            outputChatBox("Usage: /plate <text> (max 8 chars). Use '/plate clear' to reset.", player, 255, 200, 0)
            return
        end
        if string.lower(text) == "clear" then
            removeElementData(player, "customPlate")
            outputChatBox("Custom plate cleared.", player, 0, 200, 0)
            applyPlayerPlateToCurrentVehicle(player)
            return
        end

        -- Sanitize: allow letters, numbers, spaces, dash and underscore
        local clean = text:gsub("[^%w%s%-%_]", "")
        if #clean == 0 then
            outputChatBox("Plate contains no valid characters.", player, 255, 0, 0)
            return
        end
        if #clean > 8 then
            outputChatBox("Plate too long. Maximum 8 characters.", player, 255, 0, 0)
            return
        end

        setElementData(player, "customPlate", clean)
        outputChatBox("Plate set to: " .. clean, player, 0, 200, 0)
        applyPlayerPlateToCurrentVehicle(player)
        -- Also reapply after short delays in case vehicle plates are changed by other resources
        setTimer(function() applyPlayerPlateToCurrentVehicle(player) end, 500, 1)
        setTimer(function() applyPlayerPlateToCurrentVehicle(player) end, 1500, 1)
    end
)

-- Reapply when vehicles respawn (in case they lose custom plates)
addEventHandler("onVehicleRespawn", root,
    function()
        local vehicle = source
        if not vehicle or not isElement(vehicle) then return end
        local player = getVehicleOccupant(vehicle)
        if player then
            applyPlayerPlateToCurrentVehicle(player)
        end
    end
)

-- When resource starts, ensure plates are applied for players already in vehicles
addEventHandler("onResourceStart", resourceRoot,
    function()
        for _, player in ipairs(getElementsByType("player")) do
            applyPlayerPlateToCurrentVehicle(player)
        end
    end
)
