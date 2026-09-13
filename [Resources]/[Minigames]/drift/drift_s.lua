addEvent("givePlayerDriftMoney", true)
addEventHandler("givePlayerDriftMoney", resourceRoot, function(amount)
    if not client or not isElement(client) then return end
    if type(amount) ~= "number" or amount <= 0 then return end

    -- Cap to prevent abuse (optional)
    if amount > 100000 then amount = 100000 end

    givePlayerMoney(client, amount)
end)