--Coded By Datyeyeboi and Codescribe
--I saw it in Graufroam and decided to recreate it


local invisibleModels = {441, 464, 501, 465, 564} -- Add the model IDs for the RC vehicles that should make the player invisible

function togglePlayerVisibility(cunt, seat)
    if seat == 0 and isInvisibleModel(getElementModel(cunt)) then
        setElementAlpha(source, 0) -- Set player's alpha to 0 (invisible)
    end
end
addEventHandler("onPlayerVehicleEnter", getRootElement(), togglePlayerVisibility)

function restorePlayerVisibility(cunt, seat)
    if seat == 0 and isInvisibleModel(getElementModel(cunt)) then
        setElementAlpha(source, 255) -- Set player's alpha to 255 (visible)
    end
end
addEventHandler("onPlayerVehicleExit", getRootElement(), restorePlayerVisibility)

function restorePlayerVisibilityOnDeath()
    setElementAlpha(source, 255) -- Set player's alpha to 255 (visible) when they die
end
addEventHandler("onPlayerWasted", getRootElement(), restorePlayerVisibilityOnDeath)

function isInvisibleModel(modelID)
    for _, model in ipairs(invisibleModels) do
        if model == modelID then
            return true
        end
    end
    return false
end
