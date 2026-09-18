-- util.lua for emote resource

function createServerCallInterface()
    return setmetatable(
        {},
        {
            __index = function(t, k)
                t[k] = function(...) triggerServerEvent('onServerCall', localPlayer, k, ...) end
                return t[k]
            end
        }
    )
end
