dprint(3,"core.lua")
-- upvalues
local _G = _G
-- get engine environment
local A, D = unpack(select(2, ...)); --Import: Engine, Defaults

-- init function
function A:Initialize()
	--dprint(2, "A:Initialize")
	--dprint(2, D.general.Test)
end
