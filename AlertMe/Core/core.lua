dprint(3,"core.lua")
-- upvalues
local _G = _G
-- get engine environment
local A, D = unpack(select(2, ...)); --Import: Engine, Defaults

-- init function
function A:Initialize()

end

-- central table with event options
A.Events = {
	["SPELL_AURA_APPLIED"] = {
		handle = "gain",
		name = "Aura gain or refresh",
		options = true,
	},
	["SPELL_AURA_REFRESH"] = {
		handle = "gain",
		name = "Aura gain or refresh",
		options = false,
	},
	["SPELL_AURA_REMOVED"] = {
		handle = "removed",
		name = "Aura removed",
		options = false,
	},
	["SPELL_DISPEL"] = {
		handle = "dispel",
		name = "Dispel",
		options = true,
	},
	["SPELL_CAST_START"] = {
		handle = "start",
		name = "Cast start",
		options = true,
	},
	["SPELL_CAST_SUCCESS"] = {
		handle = "success",
		name = "Cast success",
		options = true,
	},
	["SPELL_INTERRUPT"] = {
		handle = "interrupt",
		name = "Cast success",
		options = true,
	},
}
