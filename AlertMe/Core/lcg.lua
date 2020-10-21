-- get engine environment
local A, O = unpack(select(2, ...))
-- upvalues
local _G = _G
-- set engine as new global environment
setfenv(1, _G.AlertMe)
A.Glows = {}

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
	dprint(1, "A:DisplayGlows", ti.relSpellName, eventInfo.short, ti.dstName, "snapShot", snapShot)
	local targetFrame = A.Libs.LGF.GetUnitFrame(ti.dstGUID)
	if not targetFrame then
		dprint(1, "DisplayGlows", "no target frame found for", ti.dstName)
		return
	end
	local frames = {}
	--frames = _G.UIParent:GetChildren()
	VDT_AddData(frames, "frames")
	VDT_AddData(_G.UIParent:GetChildren(), "UIParent")
	for i,frame in pairs(_G.UIParent:GetChildren()) do
		tinsert(frames, frame)
	end
	local id = ti.dstGUID..ti.spellName
	for _, alert in pairs(alerts) do
		if alert.showGlow >= 1 and eventInfo.displaySettings == true then
			local name, icon, _, _, duration, expirationTime, _, _, _, spellId, remaining = A:GetUnitAura(ti, eventInfo)
			if not duration and snapShot then
				spellId = A.Libs.LCD:GetLastRankSpellIDByName(ti.relSpellName)
				remaining = A.Libs.LCD:GetDurationForRank(ti.relSpellName, spellID, ti.srcGUID) --_, _, icon = GetSpellInfo(spellId)
			end
			if remaining and remaining >= 2 then
				local db = P.glow[alert.showGlow]
				local color, number, frequency, thickness, ofs_x, ofs_y, border = db.color, db.number, db.frequency, db.thickness, db.ofs_x, db.ofs_y, db.border
				A.Libs.LCG.PixelGlow_Start(targetFrame, color, number, frequency, nil, thickness, ofs_x, ofs_y, border ,id)
				A.Glows[id] = targetFrame
				-- remove glow effect after remaining time in case aura_reomved doesnt get triggered
				C_Timer.After(remaining, function()
					A:HideGlow(ti, eventInfo)
				end)
			end
		end
	end
end

function A:HideGlow(ti, eventInfo)
	dprint(1, "A:HideGlow", "name", ti.dstName, "event", eventInfo.short, "spell", ti.spellName)
	local id = ti.dstGUID..ti.spellName
	if A.Glows[id] then
		dprint(1, "A:HideGlow", "PixelGlow_Stop", id)
		A.Libs.LCG.PixelGlow_Stop(A.Glows[id],id)
		A.Glows[id] = nil
	end
end

function A:HideAllGlows()
	dprint(3, "A:HideAllGlows")
	for id, frame in pairs(A.Glows) do
		A.Libs.LCG.PixelGlow_Stop(frame, id)
	end
	A.Glows = nil
	A.Glows = {}
end
