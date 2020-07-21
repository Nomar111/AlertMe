dprint(3,"settings.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- central table with event options
A.Events = {
	["type_APPLIED"] = {
		short = "gain",
		optionsDisplay = true,
		optionsText = "On aura gain or refresh",
		optionsOrder = 1,
		type = "Aura",
		spellSelection = true,
		unitSelection = true,
		srcUnits = true,
		dstUnits = true,
		displaySettings = true,
		dstwhisper = true,
		optionalArgs = {"auraType"},
		relSpellName = "spellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgAuraGain,
		--actions = {A:ChatAnnounce(), A:PlaySound(), A:ShowAuraBar()},
	},
	["type_REFRESH"] = {
		short = "gain",
		optionsDisplay = false,
		optionalArgs = {"auraType"},
		relSpellName = "spellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgAuraGain,
		--actions = {A:ChatAnnounce(), A:PlaySound(), A:ShowAuraBar()},
	},
	["type_REMOVED"] = {
		short = "removed",
		optionsDisplay = false,
		optionalArgs = {"auraType"},
		relSpellName = "spellName",
		checkedUnits = {},
		--msg = P.events.msgAuraGain,
		--actions = {A:HideBar()},
	},
	["SPELL_DISPEL"] = {
		short = "dispel",
		optionsDisplay = true,
		optionsText = "On dispel",
		optionsOrder = 2,
		type = "Spell",
		spellSelection = true,
		unitSelection = true,
		srcUnits = true,
		dstUnits = true,
		displaySettings = false,
		dstWhisper = false,
		optionalArgs = {"extraSpellId","extraSpellName","extraSchool","auraType"},
		relSpellName = "extraSpellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgAuraDispel,
		--actions = {A:ChatAnnounce(), A:PlaySound(), A:HideAuraBar()},
	},
	["SPELL_CAST_START"] = {
		short = "start",
		optionsDisplay = true,
		optionsText = "On cast start",
		optionsOrder = 3,
		type = "Spell",
		spellSelection = true,
		unitSelection = true,
		srcUnits = true,
		displaySettings = true,
		dstWhisper = false,
		relSpellName = "spellName",
		checkedUnits = {"src"},
		--msg = P.events.msgCastStart,
		--actions = {A:ChatAnnounce(), A:PlaySound(), A:ShowCastBar()},
	},
	["SPELL_CAST_SUCCESS"] = {
		short = "success",
		optionsDisplay = true,
		optionsText = "On cast success",
		optionsOrder = 4,
		type = "Spell",
		spellSelection = true,
		unitSelection = true,
		srcUnits = true,
		dstUnits = true,
		displaySettings = false,
		dstWhisper = true,
		relSpellName = "spellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgCastSuccess,
		--actions = {A:ChatAnnounce(), A:PlaySound()},
	},
	["SPELL_INTERRUPT"] = {
		short = "interrupt",
		optionsDisplay = true,
		optionsText = "On interrupt",
		optionsOrder = 5,
		type = "Spell",
		spellSelection = false,
		unitSelection = true,
		srcUnits = true,
		dstUnits = true,
		displaySettings = false,
		dstWhisper = false,
		optionalArgs = {"extraSpellId","extraSpellName","extraSchool"},
		relSpellName = "spellName",
		checkedUnits = {"src","dst"},
		--msg = P.events.msgInterrupt,
		--actions = {A:GetLockout(), A:ChatAnnounce(), A:PlaySound()},
	},
}

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
