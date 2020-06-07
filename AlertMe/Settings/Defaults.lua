dprint(3,"defaults.lua")
-- get engine environment
local _, D = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- set default options
D.profile = {
	setting = true,
}

-- D.general = {}
-- D.general.Test = 1
