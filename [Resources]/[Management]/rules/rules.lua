-- Coded By datyeyeboi & CodeScribe
-- 27/05/23
-- Made For NaijaLane Freeroam, Inspired By SAAF & GRAUFROAM

local isTextVisible = false

function toggleTextVisibility()
    isTextVisible = not isTextVisible

    if isTextVisible then
        addEventHandler("onClientRender", root, drawText)
        showChat(true)
    else
        removeEventHandler("onClientRender", root, drawText)
        showChat(true)
    end
end

function drawText()
    local screenWidth, screenHeight = guiGetScreenSize()
    dxDrawText("Server Rules!", 10, 180, screenWidth, screenHeight, tocolor(255, 255, 255), 1.5, "bankgothic")
    dxDrawText("1. Don't be Annoying", 10, 230, screenWidth, screenHeight, tocolor(255, 255, 255), 1, "bankgothic")
    dxDrawText("2. Do not spam or advertise", 10, 260, screenWidth, screenHeight, tocolor(255, 255, 255), 1, "bankgothic")
    dxDrawText("3. Do not abuse your Nickname", 10, 290, screenWidth, screenHeight, tocolor(255, 255, 255), 1, "bankgothic")
    dxDrawText("4. Do not Cheat ", 10, 320, screenWidth, screenHeight, tocolor(255, 255, 255), 1, "bankgothic")
    dxDrawText("5. Do not Disturb No-DM Players/No-DM Staff ", 10, 350, screenWidth, screenHeight, tocolor(255, 255, 255), 1, "bankgothic")
    dxDrawText("6. Do not Leech the server ", 10, 380, screenWidth, screenHeight, tocolor(255, 255, 255), 1, "bankgothic")
end

addEventHandler("onClientRender", root,
    function()
        if isTextVisible then
            drawText()
        end
    end
)

-- The F was there for debugging, remove it in final build
addEventHandler("onClientKey", root,
    function(key, state)
        if key == "F3" and state then
            toggleTextVisibility()
        end
    end
)

addCommandHandler("rules",
-- For The GUI and whatever the fuck, im a Lazy Nigga
    function()
        toggleTextVisibility()
    end
)
