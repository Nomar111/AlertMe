-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function A:InitLCG()
	dprint(3, "A:InitLCG")
	A.Glows = {pixel={},particle={}}
end

function A:DisplayGlows(ti, alerts, eventInfo, snapShot)
	dprint(3, "A:DisplayGlows", ti.relSpellName, eventInfo.short, "snapShot", snapShot)
	local targetFrame = A.Libs.LGF.GetUnitFrame(ti.dstGUID)
	if not targetFrame then
		dprint(1, "DisplayGlows", "no target frame found for", ti.dstName. ti.dstGUID)
		return
	end
	local id = ti.dstGUID..ti.spellName
	for _, alert in pairs(alerts) do
		if alert.showGlow >= 1 and eventInfo.displaySettings == true then
			local name, _, _, _, duration = A:GetUnitAura(ti, eventInfo)
			if duration or snapShot then
				--A:ShowGlow()
				if alert.showGlow <= 4 then
					local db = P.glow.pixel[alert.showGlow]
					local color, number, frequency, thickness, ofs_x, ofs_y, border = db.color, db.number, db.frequency, db.thickness, db.ofs_x, db.ofs_y, db.border
					A.Libs.LCG:PixelGlow_Start(targetFrame, color, number, frequency, nil, thickness, ofs_x, ofs_y, border ,id)
					A.Glows.pixel[id] = targetFrame
				else
					local db = P.glow.Particle[alert.showGlow-4]
					local color, number, frequency, scale, ofs_x, ofs_y  = db.color, db.number, db.frequency, db.scale, db.ofs_x, db.ofs_y
					A.Libs.LCG:AutoCastGlow_Start(targetFrame, color, number, frequency, scale, ofs_x, ofs_y, id)
					A.Glows.particle[id] = targetFrame
				end
			end
		end
	end
end

function A:HideGlow(ti, eventInfo)
	dprint(3, "A:HideGlow", ti.dstName, eventInfo.short)
	local id = ti.dstGUID..ti.spellName
	if A.Glows.pixel[id] then
		PixelGlow_Stop(A.Glows.pixel[id],id)
		A.Glows.pixel[id] = nil
	elseif A.Glows.particle[id] then
		AutoCastGlow_Stop(A.Glows.pixel[id], id)
		A.Glows.pixel[id] = nil
	end
end
