-- upvalues
local _G, IsAddOnLoaded, C_Timer = _G, IsAddOnLoaded, C_Timer
-- set addon environment
setfenv(1, _G.AlertMe)
-- set container for glows
A.glows = {}

local function getBattleGroundTargetsFrame(ti)
	-- check if BGTC is loaded
	if not IsAddOnLoaded("BattlegroundTargets") then return end
	local name = ti.dstName
	local nameShort = getShortName(ti.dstName)
	local frames = { _G.UIParent:GetChildren() }
	for _, frame in ipairs(frames) do
		if frame.name4button then
			if frame.name4button == name or frame.name4button == nameShort then
				return frame
			end
		end
	end
end

function A:displayGlows(ti, alerts, eventInfo, snapShot)
	if not P.glow.enabled then return end
	local targetFrame = A.Libs.LGF.GetUnitFrame(ti.dstGUID)
	if not targetFrame and ti.dstIsHostile and P.glow.bgtEnabled then
		targetFrame = getBattleGroundTargetsFrame(ti)
	end
	if not targetFrame then	return 	end-- no battlegroundstarget classic frame found
	-- set id and loop thorugh alerts (same as bars)
	local id = ti.dstGUID..ti.spellName
	for _, alert in pairs(alerts) do
		if alert.showGlow >= 1 and eventInfo.displaySettings.enabled and eventInfo.displaySettings.glow then
			local name, icon, _, _, duration, expirationTime, _, _, _, spellId, remaining = A:getUnitAura(ti, eventInfo)
			if not duration and snapShot then
				spellId = A.Libs.LCD:GetLastRankSpellIDByName(ti.relSpellName)
				remaining = A.Libs.LCD:GetDurationForRank(ti.relSpellName, spellID, ti.srcGUID) --_, _, icon = GetSpellInfo(spellId)
			end
			if remaining and remaining >= 2 then
				local db = P.glow[alert.showGlow]
				local color, number, frequency, thickness, ofs_x, ofs_y, border = db.color, db.number, db.frequency, db.thickness, db.ofs_x, db.ofs_y, db.border
				A.Libs.LCG.PixelGlow_Start(targetFrame, color, number, frequency, nil, thickness, ofs_x, ofs_y, border ,id)
				A.glows[id] = targetFrame
				-- remove glow effect after remaining time in case aura_reomved doesnt get triggered
				C_Timer.After(remaining, function()
					A:hideGlow(ti, eventInfo)
				end)
			end
		end
	end
end

function A:hideGlow(ti, eventInfo)
	local id = ti.dstGUID..ti.spellName
	if A.glows[id] then
		A.Libs.LCG.PixelGlow_Stop(A.glows[id],id)
		A.glows[id] = nil
	end
end

function A:hideAllGlows()
	for id, frame in pairs(A.glows) do
		A.Libs.LCG.PixelGlow_Stop(frame, id)
	end
	A.glows = nil
	A.glows = {}
end
