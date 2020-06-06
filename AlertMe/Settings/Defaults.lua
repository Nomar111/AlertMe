dprint(3,"Defaults.lua")
-- get engine environment
local _, D = unpack(select(2, ...)); --Import: Engine, Defaults
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- set default options
D.general = {
	Test = 1
}

-- D.general = {}
-- D.general.Test = 1
