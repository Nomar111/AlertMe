dprint(3,"settings.lua")
-- upvalues
local _G, CreateFrame, date, dprint, pairs = _G, CreateFrame, date, dprint, pairs
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)


-- central table with event options
A.Events = {
	["SPELL_AURA_APPLIED"] = {
		short = "gain",
		options_display = true,
		options_name = "On aura gain or refresh",
		options_order = 1,
		spell_aura = "Aura",
		spell_selection = true,
		unit_selection = true,
		source_units = true,
		target_units = true,
		display_settings = true,
		whisper_destination = true,
		optionalArgs = {"auraType"},
		relSpellName = "spellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgAuraGain,
		--actions = {A:ChatAnnounce(), A:PlaySound(), A:ShowAuraBar()},
	},
	["SPELL_AURA_REFRESH"] = {
		short = "gain",
		options_display = false,
		optionalArgs = {"auraType"},
		relSpellName = "spellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgAuraGain,
		--actions = {A:ChatAnnounce(), A:PlaySound(), A:ShowAuraBar()},
	},
	["SPELL_AURA_REMOVED"] = {
		short = "removed",
		options_display = false,
		optionalArgs = {"auraType"},
		relSpellName = "spellName",
		checkedUnits = {},
		--msg = P.events.msgAuraGain,
		--actions = {A:HideBar()},
	},
	["SPELL_DISPEL"] = {
		short = "dispel",
		options_display = true,
		options_name = "On dispel",
		options_order = 2,
		spell_aura = "Spell",
		spell_selection = true,
		unit_selection = true,
		source_units = true,
		target_units = true,
		display_settings = false,
		whisper_destination = false,
		optionalArgs = {"extraSpellId","extraSpellName","extraSchool","auraType"},
		relSpellName = "extraSpellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgAuraDispel,
		--actions = {A:ChatAnnounce(), A:PlaySound(), A:HideAuraBar()},
	},
	["SPELL_CAST_START"] = {
		short = "start",
		options_display = true,
		options_name = "On cast start",
		options_order = 3,
		spell_aura = "Spell",
		spell_selection = true,
		unit_selection = true,
		source_units = true,
		display_settings = true,
		whisper_destination = false,
		relSpellName = "spellName",
		checkedUnits = {"src"},
		--msg = P.events.msgCastStart,
		--actions = {A:ChatAnnounce(), A:PlaySound(), A:ShowCastBar()},
	},
	["SPELL_CAST_SUCCESS"] = {
		short = "success",
		options_display = true,
		options_name = "On cast success",
		options_order = 4,
		spell_aura = "Spell",
		spell_selection = true,
		unit_selection = true,
		source_units = true,
		target_units = true,
		display_settings = false,
		whisper_destination = true,
		relSpellName = "spellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgCastSuccess,
		--actions = {A:ChatAnnounce(), A:PlaySound()},
	},
	["SPELL_INTERRUPT"] = {
		short = "interrupt",
		options_display = true,
		options_name = "On interrupt",
		options_order = 5,
		spell_aura = "Spell",
		spell_selection = false,
		unit_selection = true,
		source_units = true,
		target_units = true,
		display_settings = false,
		whisper_destination = false,
		optionalArgs = {"extraSpellId","extraSpellName","extraSchool"},
		relSpellName = "spellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgInterrupt,
		--actions = {A:GetLockout(), A:ChatAnnounce(), A:PlaySound()},
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

-- lockouts
A.Lockouts = {
	["Counterspell"] = "10",
    ["Spell Lock"] = "8",
    ["Shield Bash"] = "6",
    ["Pummel"] = "4",
    ["Earth Shock"] = "2",
    ["Feral Charge Effect"] = "4",
    ["Kick"] = "5",
}

-- colors
A.Colors = {
	red = {
		hex = "FFde4037",
		rgb = {1,0,0}
	},
    green = {
		hex = "FF27d942",
		rgb = {0,1,0}
	},
	yellow = {
		hex = "FFcfac67",
		rgb = {0,1,1}
	},
	white = {
		hex = "FFFFFFFF",
		rgb = {1,1,1}
	},
	blue = {
		hex = "FF657ddb",
		rgb = {0,0,1}
	},
	gold = {
		hex = "FFDAA520",
		rgb = {218/255,165/255,32/255}
	}
}
