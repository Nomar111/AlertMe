-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
A.Glows = {pixel={},particle={}}

	-- if ti.dstIsHostile then
	-- 	local unitFrame = A.GetUnitFrame(ti.dstName)
	-- 	if not unitFrame then
	-- 		unitFrame = A.GetUnitFrame(A:GetUnitNameShort(ti.dstName))
	-- 	end
	-- 	if not unitFrame then
	-- 		unitFrame = A.GetUnitFrame(ti.dstGUID)
	-- 	end
	-- 	unitFrame = A.GetUnitFrame(ti.dstGUID)
	--
	-- 	if unitFrame then
	-- 		dprint(1, "A.GetUnitFrame", unitFrame)
	-- 	else
	-- 		dprint(1, "A.GetUnitFrame", "no unit frame found", ti.dstName, A:GetUnitNameShort(ti.dstName), ti.dstGUID)
	-- 	end
	-- end

function A:DisplayGlows(ti, alerts, eventInfo, snapShot)
	dprint(2, "A:DisplayGlows", ti.relSpellName, eventInfo.short, "snapShot", snapShot)
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
					A.Libs.LCG.PixelGlow_Start(targetFrame, color, number, frequency, nil, thickness, ofs_x, ofs_y, border ,id)
					A.Glows.pixel[id] = targetFrame
				else
					local db = P.glow.particle[alert.showGlow-4]
					local color, number, frequency, scale, ofs_x, ofs_y  = db.color, db.number, db.frequency, db.scale, db.ofs_x, db.ofs_y
					dprint(1, "AutoCastGlow_Start", targetFrame, nil, nil, nil, nil, nil, nil, id)
					A.Libs.LCG.AutoCastGlow_Start(targetFrame, nil, nil, nil, nil, nil, nil, id)
					A.Glows.particle[id] = targetFrame
				end
			end
		end
	end
end

function A:HideGlow(ti, eventInfo)
	dprint(1, "A:HideGlow", ti.dstName, eventInfo.short)
	local id = ti.dstGUID..ti.spellName
	if A.Glows.pixel[id] then
		A.Libs.LCG.PixelGlow_Stop(A.Glows.pixel[id],id)
		A.Glows.pixel[id] = nil
	elseif A.Glows.particle[id] then
		A.Libs.LCG.AutoCastGlow_Stop(A.Glows.particle[id], id)
		A.Glows.particle[id] = nil
	end
end

function A:HideAllGlows()
	dprint(3, "A:HideAllGlows")
	for id, frame in pairs(A.Glows.pixel) do
		A.Libs.LCG.PixelGlow_Stop(frame, id)
	end
	A.Glows.pixel = nil
	A.Glows.pixel = {}
	for id, frame in pairs(A.Glows.particle) do
		A.Libs.LCG.AutoCastGlow_Stop(frame, id)
	end
	A.Glows.particle = nil
	A.Glows.particle = {}
end
