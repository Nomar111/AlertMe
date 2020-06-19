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
		short = "gain",
		options_display = true,
		options_name = "On aura gain or refresh",
		options_order = 1,
		spell_aura = "Aura",
	},
	["SPELL_AURA_REFRESH"] = {
		short = "gain",
		options_display = false,
	},
	["SPELL_AURA_REMOVED"] = {
		short = "removed",
		options_display = false,
	},
	["SPELL_DISPEL"] = {
		short = "dispel",
		options_display = true,
		options_name = "On dispel",
		options_order = 2,
		spell_aura = "Spell",
	},
	["SPELL_CAST_START"] = {
		short = "start",
		options_display = true,
		options_name = "On cast start",
		options_order = 3,
		spell_aura = "Spell",
	},
	["SPELL_CAST_SUCCESS"] = {
		short = "success",
		options_display = true,
		options_name = "On cast success",
		options_order = 4,
		spell_aura = "Spell",
	},
	["SPELL_INTERRUPT"] = {
		short = "interrupt",
		options_display = true,
		options_name = "On interrupt",
		options_order = 5,
		spell_aura = "Spell",
	},
}

function A:GetEventSettingByShort(short, setting)
	for i,v in pairs(A.Events) do
		--dprint(1, v.short, "short", short)
		if v.short == short and v[setting] ~= nil then
			return v[setting]
		end
	end
end
