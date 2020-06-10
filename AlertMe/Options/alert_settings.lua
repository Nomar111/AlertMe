dprint(2, "alert_details.lua")
-- upvalues
local _G = _G
local dprint, tinsert, pairs, GetTime, time, tostring = dprint, table.insert, pairs, GetTime, time, tostring
local type, unpack = type, unpack
-- get engine environment
local A, _, O = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

local alert_settings = O:CreateGroup("Alert Settings")
