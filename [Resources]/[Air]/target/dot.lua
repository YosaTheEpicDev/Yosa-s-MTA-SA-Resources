function creteCircleMaterial( resolution, holow )
	local sres = Vector2(resolution,resolution)
	local material = dxCreateTexture ( sres.x,sres.y )
	local point = sres/2
	local pixels = dxGetTexturePixels( material )
	for x=0,sres.x do
		for y=0,sres.y do
			local len = (Vector2(x,y)-point).length
			if len < point.x and len > (point.x/(holow or 2)) then
				dxSetPixelColor( pixels, x, y, 255, 255, 0 )
			end
		end
	end
	dxSetTexturePixels( material, pixels )
	return material
end


local lp = localPlayer
local size = 8  -- length of each crosshair arm (smaller)
local gap = 3   -- gap in the center (smaller)

addEventHandler( "onClientRender", root, function( )
	if lp.vehicle then
		local mdl = lp.vehicle.model
		if mdl == 425 or mdl == 432 or mdl == 476 or mdl == 447 or mdl == 601 or mdl == 520 then
			local m = lp.vehicle.matrix
			local aimEnd, aimStart
			if mdl == 432 or mdl == 601 then
				local cp = Vector3(getVehicleComponentPosition( lp.vehicle, "misc_c" ,"world"))
				local cr = Vector3(getVehicleComponentRotation( lp.vehicle, "misc_c" ,"world"))
				m = Matrix(cp,cr)
				if mdl == 432 then
					aimEnd = m:transformPosition(0,100,0)
					aimStart = m:transformPosition(0,0,0)
				else
					aimEnd = m:transformPosition(0,100,0)
					aimStart = m:transformPosition(0,0,0)
				end
			else
				aimEnd = m:transformPosition(0,200,-.5)
				aimStart = m:transformPosition(0,0,-.5)
			end
			local hit,x,y,z = processLineOfSight( aimStart, aimEnd, true, true, true, true, true, true, false, true, lp.vehicle )
			local startHit = Vector3(x,y,z)
			local aimEnd = hit and startHit or aimEnd
			local scn = Vector2(getScreenFromWorldPosition( aimEnd ))
			if scn.length > 0 then
				local color = tocolor(255,255,0)
				-- Draw a hollow plus (+) crosshair, no center dot
				dxDrawLine(scn.x - size, scn.y, scn.x - gap, scn.y, color, 2)
				dxDrawLine(scn.x + gap, scn.y, scn.x + size, scn.y, color, 2)
				dxDrawLine(scn.x, scn.y - size, scn.x, scn.y - gap, color, 2)
				dxDrawLine(scn.x, scn.y + gap, scn.x, scn.y + size, color, 2)

				-- Distance measurer and color logic for Rhino
				if mdl == 432 then
					local dist
					if hit then
						dist = (aimEnd - aimStart).length
					else
						dist = 100
					end
					local distText
					if not hit or dist >= 100 then
						distText = "100m+"
					else
						distText = string.format("%.1fm", dist)
					end
					local textX = scn.x + size + 10
					local textY = scn.y + size + 10
					local crossColor = color
					if dist <= 65 then
						crossColor = tocolor(255,0,0)
					end
					-- Redraw crosshair in new color if needed
					dxDrawLine(scn.x - size, scn.y, scn.x - gap, scn.y, crossColor, 2)
					dxDrawLine(scn.x + gap, scn.y, scn.x + size, scn.y, crossColor, 2)
					dxDrawLine(scn.x, scn.y - size, scn.x, scn.y - gap, crossColor, 2)
					dxDrawLine(scn.x, scn.y + gap, scn.x, scn.y + size, crossColor, 2)
					dxDrawText(distText, textX, textY, textX+100, textY+20, tocolor(255,255,255,200), 1, "default-bold", "left", "top")
				end
			end
		end
	end
end )