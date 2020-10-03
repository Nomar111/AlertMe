dprint(3,"auras.lua")
-- upvalues
local UnitName, UnitAura, GetTime, GetSpellInfo, print = UnitName, UnitAura, GetTime, GetSpellInfo, print
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)
