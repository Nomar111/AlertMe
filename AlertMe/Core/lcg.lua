-- upvalues
local _G, IsAddOnLoaded, C_Timer = _G, IsAddOnLoaded, C_Timer
-- set addon environment
setfenv(1, _G.AlertMe)
-- set container for glows
A.glows = {}

local function getBattleGroundTargetsFrame(cleu)
	-- check if BGTC is loaded
	if not IsAddOnLoaded("BattlegroundTargets") then return end
	local name = cleu.dstName
	local nameShort = GetShortName(cleu.dstName)
	local frames = { _G.UIParent:GetChildren() }
	for _, frame in ipairs(frames) do
		if frame.name4button then
			if frame.name4button == name or frame.name4button == nameShort then
				return frame
			end
		end
	end
end

function A:DisplayGlows(cleu, evi, alerts, snapShot)
	-- check event and glow options
	if not P.glow.enabled or not evi.displayOptions or not evi.displayOptions.glow then return end
	-- get target frame of destination unit
	local targetFrame = A.Libs.LGF.GetUnitFrame(cleu.dstGUID)
	if not targetFrame and cleu.dstIsHostile and P.glow.bgtEnabled then		-- get BGT enemy unitframe
		targetFrame = getBattleGroundTargetsFrame(cleu)
	end
	if not targetFrame then	return end										-- no unitframe available
	-- set id and loop thorugh alerts (same as bars)
	local id = cleu.dstGUID..cleu.spellName
	for _, alert in pairs(alerts) do
		if alert.showGlow >= 1 then
			-- get relevant spell info
			local name, icon, _, _, duration, expirationTime, _, _, _, spellId, remaining = A:GetUnitAura(cleu, evi)
			if not duration and snapShot then
				spellId = A.Libs.LCD:GetLastRankSpellIDByName(cleu.checkedSpell)
				remaining = A.Libs.LCD:GetDurationForRank(cleu.checkedSpell, spellID, cleu.srcGUID)
			end
			-- only display glow if a remaining time can be gotten
			if remaining and remaining >= 1 then
				local db = P.glow[alert.showGlow]
				local color, number, frequency, thickness, ofs_x, ofs_y, border = db.color, db.number, db.frequency, db.thickness, db.ofs_x, db.ofs_y, db.border
				A.Libs.LCG.PixelGlow_Start(targetFrame, color, number, frequency, nil, thickness, ofs_x, ofs_y, border ,id)
				A.glows[id] = targetFrame
				-- remove glow effect after remaining time in case aura_removed doesnt get triggered
				C_Timer.After(remaining, function()
					A:HideGlow(cleu, evi)
				end)
			end
		end
	end
end

function A:HideGlow(cleu, evi)
	local id = cleu.dstGUID..cleu.spellName
	if A.glows[id] then
		A.Libs.LCG.PixelGlow_Stop(A.glows[id], id)
		A.glows[id] = nil
	end
end

function A:HideAllGlows()
	for id, frame in pairs(A.glows) do
		A.Libs.LCG.PixelGlow_Stop(frame, id)
	end
	A.glows = nil
	A.glows = {}
end
