-- get engine environment
local A, O = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

function A:InitLCG()
	dprint(3, "A:InitLCG")
	A.GetUnitFrame = A.Libs.LGF.GetUnitFrame
	A.GetUnitNameplate = A.Libs.LGF.GetUnitNameplate(unit)
end

-- if ti.dstGUID then
-- 	local unitFrame = A.GetUnitFrame(ti.dstGUID)
-- 	dprint(1, "A.GetUnitFrame", unitFrame)
-- 	VDT_AddData(unitFrame, "unitFrame")
-- end




-- aura_env.glowStart = function(frame)
--     if glow_type == 3 then
--         LCG.AutoCastGlow_Start(frame, aura_env.config.glowCol, aura_env.config.numGroups, aura_env.config.shineSpeed, aura_env.config.scale, aura_env.config.shineXOff, aura_env.config.shineYOff, aura_env.id)
--     elseif glow_type == 2 then
--         LCG.PixelGlow_Start(frame, aura_env.config.glowCol, aura_env.config.numLines, aura_env.config.pixelSpeed, nil, aura_env.config.thickness, aura_env.config.pixelXOff, aura_env.config.pixelYOff, aura_env.config.border, aura_env.id)
--     else
--         WeakAuras.ShowOverlayGlow(frame, aura_env.config.glowCol)
--     end
-- end

-- if glow_type == 3 then
--     aura_env.glowStop = LCG.AutoCastGlow_Stop
-- elseif glow_type == 2 then
--     aura_env.glowStop = LCG.PixelGlow_Stop
-- else
--     aura_env.glowStop = WeakAuras.HideOverlayGlow
-- end

-- NOTUSED
 ----------------------------------------------------------------
-- ------------ Generic GetFrame with caching ---------------------
-- ----------------------------------------------------------------
-- GetFrames(target)
--  return table of all frames for unit=target or {}
--
-- GetFrame(target)
--  return one frame for unit=target or nil
--  unitframe addon priority is defined with `frame_priority`
--  if it can't find a priority patterns, it select a random matching frame
-- NOTUSED
--
-- local frame_priority = {
--     -- raid frames
--     [1] = "^Vd1", -- vuhdo
--     [2] = "^Healbot", -- healbot
--     [3] = "^GridLayout", -- grid
--     [4] = "^Grid2Layout", -- grid2
--     [5] = "^ElvUF_Raid40Group", -- elv40
--     [6] = "^ElvUF_RaidGroup", -- elv
--     [7] = "^oUF_bdGrid", -- bdgrid
--     [8] = "^oUF.*raid", -- generic oUF
--     [9] = "^LimeGroup", -- lime
--     [10] = "^SUFHeaderraid", -- suf
--     [11] = "^CompactRaid", -- blizz
--     -- party frames
--     [12] = "^SUFHeaderparty", --suf
--     [13] = "^ElvUF_PartyGroup", -- elv
--     [14] = "^oUF.*party", -- generic oUF
--     [15] = "^PitBull4_Groups_Party", -- pitbull4
--     [16] = "^CompactParty", -- blizz
--     -- player frame
--     [17] = "^SUFUnitplayer",
--     [18] = "^PitBull4_Frames_Player",
--     [19] = "^ElvUF_Player",
--     [20] = "^oUF.*player",
--     [21] = "^PlayerFrame",
-- }
--
-- WA_GetFramesCache = WA_GetFramesCache or {}
-- if not WA_GetFramesCacheListener then
--     WA_GetFramesCacheListener = CreateFrame("Frame")
--     local f = WA_GetFramesCacheListener
--     f:RegisterEvent("PLAYER_REGEN_DISABLED")
--     f:RegisterEvent("PLAYER_REGEN_ENABLED")
--     f:RegisterEvent("GROUP_ROSTER_UPDATE")
--     f:SetScript("OnEvent", function(self, event, ...)
--             WA_GetFramesCache = {}
--     end)
-- end
--
-- local function GetFrames(target)
--     local function FindButtonsForUnit(frame, target)
--         local results = {}
--         if type(frame) == "table" and not frame:IsForbidden() then
--             local type = frame:GetObjectType()
--             if type == "Frame" or type == "Button" then
--                 for _,child in ipairs({frame:GetChildren()}) do
--                     for _,v in pairs(FindButtonsForUnit(child, target)) do
--                         tinsert(results, v)
--                     end
--                 end
--             end
--             if type == "Button" then
--                 local unit = frame:GetAttribute('unit')
--                 if unit and frame:IsVisible() and frame:GetName() then
--                     WA_GetFramesCache[frame] = unit
--                     if UnitIsUnit(unit, target) then
--                         -- print("F:", frame:GetName())
--                         tinsert(results, frame)
--                     end
--                 end
--             end
--         end
--         return results
--     end
--
--     if not UnitExists(target) then
--         if type(target) == "string" and target:find("Player") then
--             target = select(6,GetPlayerInfoByGUID(target))
--         else
--             return {}
--         end
--     end
--
--     local results = {}
--     for frame, unit in pairs(WA_GetFramesCache) do
--         --print("from cache:", frame:GetName())
--         if UnitIsUnit(unit, target) then
--             if frame:GetAttribute('unit') == unit then
--                 tinsert(results, frame)
--             else
--                 results = {}
--                 break
--             end
--         end
--     end
--
--     return #results > 0 and results or FindButtonsForUnit(UIParent, target)
-- end
--
-- local isElvUI = IsAddOnLoaded("ElvUI")
-- local function WhyElvWhy(frame)
--     if isElvUI and frame and frame:GetName():find("^ElvUF_") and frame.Health then
--         return frame.Health
--     else
--         return frame
--     end
-- end
--
--
-- function aura_env.GetFrame(target)
--     local frames = GetFrames(target)
--     if not frames then return nil end
--     for i=1,#frame_priority do
--         for _,frame in pairs(frames) do
--             if (frame:GetName()):find(frame_priority[i]) then
--                 return WhyElvWhy(frame)
--             end
--         end
--     end
--     return WhyElvWhy(frames[1])
-- end