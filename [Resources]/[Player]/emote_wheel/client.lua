-- client.lua
-- Load util.lua for createServerCallInterface
if fileExists and loadstring then
    local utilPath = ":[NGL]player/emote/util.lua"
    if fileExists(utilPath) then
        loadstring(exports['[NGL]player']:getResourceFile(utilPath))()
    end
end
-- Emote Wheel — optimized and cleaned (N key) — wave fixed to KISSING:gfwave2

---------------------------------------------------
-- Config
---------------------------------------------------
local openKey = "n"
local spokeCount = 8
local wheelRadius = 200
local innerRadius = 70
local animSpeed = 8
local textScale = 1.0
local font = "bankgothic"
local textColor = tocolor(255,255,255,220)
local highlightColor = tocolor(100,255,100,255)
local tickColor = tocolor(255,255,255,160)

---------------------------------------------------
-- State
---------------------------------------------------
local sx, sy = guiGetScreenSize()
local centerX, centerY = sx/2, sy/2
local isOpen = false
local anim = 0
local selectedIndex = 1
local lastTick = getTickCount()

---------------------------------------------------
-- Helpers
---------------------------------------------------
local function clamp(v,a,b) return (v<a and a) or (v>b and b) or v end

local function getRawAngle(mx,my)
    local dx, dy = mx - centerX, my - centerY
    local ang = math.deg(math.atan2(dy, dx))
    if ang < 0 then ang = ang + 360 end
    return ang
end

local function angleToIndexTop(angle)
    local shifted = angle - 270
    if shifted < 0 then shifted = shifted + 360 end
    local sectorSize = 360 / spokeCount
    local idx = math.floor((shifted + sectorSize/2) / sectorSize) + 1
    if idx < 1 then idx = 1 end
    if idx > spokeCount then idx = spokeCount end
    return idx
end

---------------------------------------------------
-- Emote Definitions (verified / fixed)
---------------------------------------------------
local emotes = {
    { label = "Dance", group = "DANCING", anim = "DAN_Loop_A" },
    { label = "Sit 1", group = "sunbathe", anim = "parksit_m_idlec", enter = "parksit_m_in" },
    { label = "Sit 2", group = "sunbathe", anim = "parksit_w_idlec", enter = "parksit_w_in" },
    { label = "Lean 1", group = "BD_FIRE", anim = "m_smklean_loop" },
    { label = "Wave", group = "KISSING", anim = "gfwave2" },      -- <-- FIXED: correct group
    { label = "Stripper Dance", group = "STRIP", anim = "strip_A" },
    { label = "Zen", group = "PARK", anim = "Tai_Chi_Loop" },
    { label = "Lean 2", group = "GANGS", anim = "leanIDLE" },
}

---------------------------------------------------
-- Animation Control
---------------------------------------------------
local server = createServerCallInterface and createServerCallInterface() or nil

-- Track if emote was started by wheel
local wheelEmoteActive = false

local function stopAnim()
    if server then
        server.setPedAnimation(localPlayer, false)
    else
        setPedAnimation(localPlayer)
    end
    wheelEmoteActive = false
end

local function playSit(e)
    stopAnim()
    wheelEmoteActive = true
    if server then
        server.setPedAnimation(localPlayer, e.group, e.enter or e.anim, 0, false, false, false, false)
        setTimer(function()
            server.setPedAnimation(localPlayer, e.group, e.anim, -1, true, false, false, false)
        end, 400, 1)
    else
        setPedAnimation(localPlayer, e.group, e.enter or e.anim, 0, false, false, false, false)
        setTimer(function()
            setPedAnimation(localPlayer, e.group, e.anim, -1, true, false, false, false)
        end, 400, 1)
    end
end

local function selectEmote(e)
    if not e or not e.group or not e.anim then return end
    stopAnim()
    wheelEmoteActive = true
    if e.group == "sunbathe" then
        playSit(e)
    else
        if server then
            server.setPedAnimation(localPlayer, e.group, e.anim, -1, true, false, false, false)
        else
            setPedAnimation(localPlayer, e.group, e.anim, -1, true, false, false, false)
        end
    end
end

---------------------------------------------------
-- Wheel Toggle
---------------------------------------------------
local function setWheel(open)
    if open and isPedInVehicle(localPlayer) then return end
    if open == isOpen then return end
    isOpen = open
    showCursor(open)
end

bindKey(openKey, "down", function()
    if isPedInVehicle(localPlayer) then return end
    if isPedFalling and isPedFalling(localPlayer) then return end
    if isPedJumping and isPedJumping(localPlayer) then return end
    if isPedSwimming and isPedSwimming(localPlayer) then return end
    -- Parachute check: weapon or animation
    local weapon = getPedWeapon and getPedWeapon(localPlayer)
    if weapon == 46 then return end -- 46 is parachute
    local animBlock, animName = getPedAnimation and getPedAnimation(localPlayer)
    if animBlock == "PARACHUTE" then return end
    -- Underwater check
    local px, py, pz = getElementPosition(localPlayer)
    local waterLevel = getWaterLevel and getWaterLevel(px, py, pz)
    if waterLevel and pz < waterLevel - 0.5 then return end
    setWheel(true)
end)
bindKey(openKey, "up", function()
    if isOpen then
        selectEmote(emotes[selectedIndex])
    end
    setWheel(false)
end)

-- Bind Shift key to cancel only wheel emotes
bindKey("lshift", "down", function()
    if wheelEmoteActive then
        stopAnim()
        if isOpen then
            setWheel(false)
        end
    end
end)

---------------------------------------------------
-- Click Selection
---------------------------------------------------
addEventHandler("onClientClick", root, function(btn, state, ax, ay)
    if not isOpen or state ~= "down" then return end
    if btn ~= "left" then
        setWheel(false)
        return
    end

    local mx, my = ax, ay
    local dx, dy = mx - centerX, my - centerY
    local dist = math.sqrt(dx*dx + dy*dy)

    if dist <= wheelRadius + 160 then
        local rawAng = getRawAngle(mx, my)
        selectedIndex = angleToIndexTop(rawAng)
        selectEmote(emotes[selectedIndex])
    end

    setWheel(false)
end)

---------------------------------------------------
-- Rendering
---------------------------------------------------
addEventHandler("onClientRender", root, function()
    local now = getTickCount()
    local dt = (now - lastTick) / 1000
    lastTick = now

    if isOpen then
        anim = clamp(anim + dt * animSpeed, 0, 1)
    else
        anim = clamp(anim - dt * animSpeed, 0, 1)
    end
    if anim <= 0.001 then return end

    for i = 1, spokeCount do
        local angleDeg = (i-1)*(360/spokeCount) - 90
        local rad = math.rad(angleDeg)
        local innerX = centerX + math.cos(rad)*innerRadius
        local innerY = centerY + math.sin(rad)*innerRadius
        local outerX = centerX + math.cos(rad)*(innerRadius + 40)
        local outerY = centerY + math.sin(rad)*(innerRadius + 40)
        dxDrawLine(innerX, innerY, outerX, outerY, tickColor, 3)
    end

    local cx, cy = getCursorPosition()
    if cx and cy then
        cx, cy = cx * sx, cy * sy
        local rawAng = getRawAngle(cx, cy)
        selectedIndex = angleToIndexTop(rawAng)
    end

    for i = 1, spokeCount do
        local angleDeg = (i-1)*(360/spokeCount) - 90
        local rad = math.rad(angleDeg)
        local labelR = wheelRadius + 50
        local x = centerX + math.cos(rad)*labelR
        local y = centerY + math.sin(rad)*labelR

        local e = emotes[i]
        local label = e and e.label or "Empty"
        local color = (i == selectedIndex) and highlightColor or textColor

        dxDrawText(label, x - 120, y - 12, x + 120, y + 12,
            color, textScale, font, "center", "center", false, false, false, true)
    end
end)
