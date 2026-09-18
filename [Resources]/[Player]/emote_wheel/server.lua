-- Emote sync server handler
addEvent('onServerCall', true)
addEventHandler('onServerCall', root,
	function(fnName, ...)
		if fnName == 'setPedAnimation' then
			setPedAnimation(source, ...)
		end
	end
)
