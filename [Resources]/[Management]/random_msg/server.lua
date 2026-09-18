
local t = 1 -- Time among messages (Minutes)
local msgs = {
	"Become a #33CC33NaijaLane#00B7EB VIP today by Donating #99E699$#ffffff5", 
	"Get a Clan for #99E699$#ffffff10 ",
	"Special Events are held on weekends",
	"See anyone misbehaving? use /report to alert an #FF6666admin ", 
	"Use F3 To check out the Server Rules",
	"Find any Bugs?, Be a good Lad and Report it to the on duty #FF6666Admins ",
	"Have what it takes to be a Moderator?, appy on our Discord Server ",
	"Use F2 To open up the Help menu ",
	"Run Ads on our server starting from $1 ",
	"Join our #7A6FE0 Discord server #33CC33discord.gg/g3hYgcXD"
} -- Messages

setTimer(function ()
	outputChatBox("#CC0000• #00B7EB"..msgs[math.random(1,#msgs)], getRootElement(), 255, 255, 255, true)
end, (t*1000)*60, 0)


-- Debug command to show a random server message immediately
addCommandHandler("rsmdebug", function(player)
	-- Only allow if run from server console or by an admin (optional, remove check if not needed)
	-- Uncomment the following lines to restrict to admins only:
	-- if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then return end

	outputChatBox("#CC0000• #00B7EB"..msgs[math.random(1,#msgs)], player, 255, 255, 255, true)
end)