-- Minimal Drift Script (client-side)
-- Only shows drift counter and gives money for drifting.

local player = getLocalPlayer()
local screenW, screenH = guiGetScreenSize()

-- === CONFIGURATION ===
local rewardScale = 0.1        -- reduce payout by 90%
local bannedVehicles = { 432, 532 }
local driftColor = tocolor(97, 251, 97)
local driftWhite = tocolor(255, 255, 255)
local driftGreen = tocolor(97, 251, 97)
local driftRed = tocolor(255, 60, 60)

-- === INTERNAL VARS ===
local vehicle
local driftScore = 0
local lastDriftTime = 0
local TempCol = driftWhite
local driftStartPos = nil
local driftEndPos = nil
local driftStartTick = nil
local driftEndTick = nil
local driftDamaged = false

-- === HELPERS ===
local function isValidVehicle()
    local veh = getPedOccupiedVehicle(player)
    if not veh or getVehicleOccupant(veh, 0) ~= player or getVehicleType(veh) ~= "Automobile" then
        return false
    end
    local id = getElementModel(veh)
    for _, v in ipairs(bannedVehicles) do
        if id == v then return false end
    end
    return veh
end

-- === DRIFT CALCULATION ===
local function getDriftAngle()
    local vx, vy, vz = getElementVelocity(vehicle)
    local speed = math.sqrt(vx * vx + vy * vy)
    if not isVehicleOnGround(vehicle) then return 0, speed end

    local rx, ry, rz = getElementRotation(vehicle)
    local sn, cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))
    local cosX = (sn * vx + cs * vy) / speed

    if speed <= 0.2 then return 0, speed end
    if cosX > 0.966 or cosX < 0 then return 0, speed end
    return math.deg(math.acos(cosX)) * 0.5, speed
end


local driftRenderActive = false
local driftDamageHandlerActive = false

local function driftRender()
    -- Attach vehicle damage handler only once
    if not driftDamageHandlerActive then
        addEventHandler("onClientVehicleDamage", root, function(attacker, weapon, loss)
            if vehicle and getPedOccupiedVehicle(player) == vehicle and driftScore > 0 then
                driftDamaged = true
            end
        end)
        driftDamageHandlerActive = true
    end
    vehicle = isValidVehicle()
    if not vehicle then
        if driftRenderActive then
            removeEventHandler("onClientRender", root, driftRender)
            driftRenderActive = false
        end
        return
    end

    -- ...existing code...

    local tick = getTickCount()
    local angle, speed = getDriftAngle()

    if angle ~= 0 then
        driftScore = driftScore + math.floor(angle * speed * rewardScale)
        lastDriftTime = tick
        -- Start drift
        if not driftStartPos then
            local px, py, pz = getElementPosition(vehicle)
            driftStartPos = {px, py, pz}
            driftStartTick = tick
        end
        -- Update end drift position
        local px, py, pz = getElementPosition(vehicle)
        driftEndPos = {px, py, pz}
        driftEndTick = tick
    end

    -- drift ends after idle time
    if tick - lastDriftTime > 750 and driftScore > 0 then
        -- Calculate drift distance
        local distance = 0
        if driftStartPos and driftEndPos then
            local dx = driftEndPos[1] - driftStartPos[1]
            local dy = driftEndPos[2] - driftStartPos[2]
            local dz = driftEndPos[3] - driftStartPos[3]
            distance = math.sqrt(dx*dx + dy*dy + dz*dz)
        end
        -- Calculate drift time
        local driftTime = 0
        if driftStartTick and driftEndTick then
            driftTime = (driftEndTick - driftStartTick) / 1000
        end
        local reward = driftScore
        local color = driftWhite
        if driftDamaged then
            reward = 0
            color = driftRed
        else
            color = driftGreen
        end
        if reward > 0 then
            triggerServerEvent("givePlayerDriftMoney", resourceRoot, reward)
        end
        driftScore = 0
        driftStartPos = nil
        driftEndPos = nil
        driftStartTick = nil
        driftEndTick = nil
        setTimer(function()
            lastDriftInfo = nil
        end, 2000, 1)
        lastDriftInfo = {cash = reward, dist = distance, time = driftTime, color = color}
        driftDamaged = false
    end

    -- draw simple drift info
    if driftScore > 0 then
        local x1, y1, x2, y2 = screenW * 0.1, screenH * 0.9, screenW * 0.9, screenH * 0.8
        local dist = 0
        if driftStartPos and driftEndPos then
            local dx = driftEndPos[1] - driftStartPos[1]
            local dy = driftEndPos[2] - driftStartPos[2]
            local dz = driftEndPos[3] - driftStartPos[3]
            dist = math.sqrt(dx*dx + dy*dy + dz*dz)
        end
        local driftTime = 0
        if driftStartTick and driftEndTick then
            driftTime = (driftEndTick - driftStartTick) / 1000
        end
        local color = driftWhite
        if driftDamaged then
            color = driftRed
        end
        dxDrawText(string.format("DRIFT REWARD: %d $ DISTANCE: %.1fM TIME %.1fS", driftScore, dist, driftTime),
            x1, y1, x2, y2, color, 0.8, "bankgothic", "center", "bottom", false, true, false)
    elseif lastDriftInfo then
        local x1, y1, x2, y2 = screenW * 0.1, screenH * 0.9, screenW * 0.9, screenH * 0.8
        dxDrawText(string.format("DRIFT REWARD: %d $ DISTANCE: %.1fM TIME %.1fS", lastDriftInfo.cash, lastDriftInfo.dist, lastDriftInfo.time),
            x1, y1, x2, y2, lastDriftInfo.color or driftWhite, 0.8, "bankgothic", "center", "bottom", false, true, false)
    end
end

-- Attach/detach driftRender based on vehicle entry/exit
addEventHandler("onClientVehicleEnter", root, function(thePlayer, seat)
    if thePlayer == player and seat == 0 and isValidVehicle() then
        if not driftRenderActive then
            addEventHandler("onClientRender", root, driftRender)
            driftRenderActive = true
        end
    end
end)

addEventHandler("onClientVehicleExit", root, function(thePlayer, seat)
    if thePlayer == player and driftRenderActive then
        removeEventHandler("onClientRender", root, driftRender)
        driftRenderActive = false
    end
end)

-- Safety: If player is already in a valid vehicle on resource start
if isValidVehicle() then
    addEventHandler("onClientRender", root, driftRender)
    driftRenderActive = true
end
