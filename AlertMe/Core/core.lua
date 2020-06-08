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
		options_display = true,
		options_name = "On aura gain or refresh",
		options_order = 1,
	},
	["SPELL_AURA_REFRESH"] = {
		handle = "gain",
		options_display = false,
	},
	["SPELL_AURA_REMOVED"] = {
		handle = "removed",
		options_display = false,
	},
	["SPELL_DISPEL"] = {
		handle = "dispel",
		options_display = true,
		options_name = "On dispel",
		options_order = 2,
	},
	["SPELL_CAST_START"] = {
		handle = "start",
		options_display = true,
		options_name = "On cast start",
		options_order = 3,
	},
	["SPELL_CAST_SUCCESS"] = {
		handle = "success",
		options_display = true,
		options_name = "On cast start",
		options_order = 4,
	},
	["SPELL_INTERRUPT"] = {
		handle = "interrupt",
		options_display = true,
		options_name = "On cast success",
		options_order = 5,
	},
}
