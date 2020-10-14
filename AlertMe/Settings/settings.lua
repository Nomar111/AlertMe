--dprint(3, "settings.lua")
-- get engine environment
local A, D, O, S = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- central table with event options
A.Events = {
	["SPELL_AURA_APPLIED"] = {
		short = "gain",
		optionsDisplay = true,
		optionsText = "On aura gain or refresh",
		optionsOrder = 1,
		type = "aura",
		spellSelection = true,
		unitSelection = true,
		displaySettings = true,
		dstWhisper = true,
		optionalArgs = {"auraType"},
		relSpellName = "spellName",
		units = {"src","dst"},
		actions = {"chatAnnounce", "displayBars", "playSound"},
	},
	["SPELL_AURA_REFRESH"] = {
		short = "refresh",
		masterEvent = "SPELL_AURA_APPLIED",
		optionsDisplay = false,
	},
	["SPELL_AURA_REMOVED"] = {
		short = "removed",
		optionsDisplay = false,
		optionalArgs = {"auraType"},
		relSpellName = "spellName",
		units = {},
		spellSelection = false,
		unitSelection == false,
		displaySettings = true,
		actions = {"hideBars"},
	},
	["SPELL_AURA_BROKEN"] = {
		short = "broken",
		masterEvent = "SPELL_AURA_REMOVED",
		optionsDisplay = false,
	},
	["SPELL_AURA_BROKEN_SPELL"] = {
		short = "broken_spell",
		masterEvent = "SPELL_AURA_REMOVED",
		optionsDisplay = false,
	},
	["SPELL_DISPEL"] = {
		short = "dispel",
		optionsDisplay = true,
		optionsText = "On dispel",
		optionsOrder = 2,
		type = "spell",
		spellSelection = true,
		unitSelection == true,
		displaySettings = false,
		dstWhisper = false,
		optionalArgs = {"extraSpellId","extraSpellName","extraSchool","auraType"},
		relSpellName = "extraSpellName",
		units = {"src","dst"},
		actions = {"chatAnnounce", "hideBars", "playSound"},
	},
	["SPELL_CAST_START"] = {
		short = "start",
		optionsDisplay = true,
		optionsText = "On cast start",
		optionsOrder = 3,
		type = "spell",
		spellSelection = true,
		unitSelection = true,
		displaySettings = true,
		dstWhisper = false,
		relSpellName = "spellName",
		units = {"src"},
		--msg = P.events.msgCastStart,
		actions = {"chatAnnounce", "playSound"},
	},
	["SPELL_CAST_SUCCESS"] = {
		short = "success",
		optionsDisplay = true,
		optionsText = "On cast success",
		optionsOrder = 4,
		type = "spell",
		spellSelection = true,
		unitSelection = true,
		displaySettings = false,
		dstWhisper = true,
		relSpellName = "spellName",
		units = {"src","dst"},
		actions = {"chatAnnounce", "playSound"},

	},
	["SPELL_INTERRUPT"] = {
		short = "interrupt",
		optionsDisplay = true,
		optionsText = "On interrupt",
		optionsOrder = 5,
		type = "spell",
		spellSelection = false,
		unitSelection = true,
		displaySettings = false,
		dstWhisper = false,
		optionalArgs = {"extraSpellId","extraSpellName","extraSchool"},
		relSpellName = "spellName",
		units = {"src","dst"},
		actions = {"chatAnnounce", "playSound"},
		--msg = P.events.msgInterrupt,
		--actions = {A:GetLockout(), A:ChatAnnounce(), A:PlaySound()},
	},
}

A.EventsShort = {}
for event, tbl in pairs(A.Events) do
	A.EventsShort[tbl.short] = {
		event = event,
		masterEvent = tbl.masterEvent,
		optionsDisplay = tbl.optionsDisplay,
		optionsText = tbl.optionsText,
		optionsOrder = tbl.optionsOrder,
		type = tbl.type,
		spellSelection = tbl.spellSelection,
		unitSelection = tbl.unitSelection,
		displaySettings = tbl.displaySettings,
		dstWhisper = tbl.dstWhisper,
		optionalArgs = tbl.optionalArgs,
		relSpellName = tbl.relSpellName,
		units = tbl.units,
		actions = tbl.actions,
	}
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

function A:InitExamples()
	A.db.profiles.Examples = {
		["alerts"] = {
			["dispel"] = {
				["selectedAlert"] = "1601740147",
				["alertDetails"] = {
					["1601740147"] = {
						["created"] = true,
						["soundFile"] = "Purge",
						["name"] = "Dispel Enemy Buffs",
						["soundSelection"] = 2,
						["spellNames"] = {
							["Blessing of Protection"] = {
								["icon"] = 135964,
								["soundFile"] = "Purge",
							},
							["Blessing of Freedom"] = {
								["icon"] = 135968,
							},
							["Invulnerability"] = {
								["icon"] = 135896,
							},
							["Free Action"] = {
								["icon"] = 134715,
							},
						},
					},
				},
			},
			["success"] = {
				["selectedAlert"] = "1602031069",
				["alertDetails"] = {
					["1602031069"] = {
						["spellNames"] = {
							["Innervate"] = {
								["icon"] = 136048,
							},
						},
						["dstWhisper"] = 2,
						["msgOverride"] = "May the force be with you!",
						["name"] = "Innervate whisper",
						["dstUnits"] = 2,
						["soundSelection"] = 1,
						["created"] = true,
					},
				},
			},
			["interrupt"] = {
				["selectedAlert"] = "1601740297",
				["alertDetails"] = {
					["1601740297"] = {
						["msgOverride"] = "I am interrupted --%extraSchool locked for %lockout s",
						["srcUnits"] = 3,
						["soundFile"] = "Kick",
						["name"] = "Myself by Enemy",
						["soundSelection"] = 2,
						["created"] = true,
					},
					["1601740258"] = {
						["srcUnits"] = 2,
						["created"] = true,
						["soundFile"] = "Countered",
						["name"] = "Enemy",
						["dstUnits"] = 3,
						["soundSelection"] = 2,
					},
				},
			},
			["gain"] = {
				["selectedAlert"] = "1601739528",
				["alertDetails"] = {
					["1601739154"] = {
						["spellNames"] = {
							["Mind Control"] = {
								["icon"] = 136206,
							},
							["Freezing Trap Effect"] = {
								["icon"] = 135834,
							},
							["Silence"] = {
								["icon"] = 135975,
							},
							["Blind"] = {
								["icon"] = 136175,
							},
							["Reckless Charge"] = {
								["icon"] = 136010,
							},
							["Sap"] = {
								["icon"] = 132310,
							},
						},
						["srcUnits"] = 3,
						["created"] = true,
						["name"] = "CC on me",
						["soundSelection"] = 1,
						["msgOverride"] = "I am affected by %spellName",
						["showBar"] = false,
					},
					["1601739528"] = {
						["spellNames"] = {
							["Stealth"] = {
								["icon"] = 132320,
								["soundFile"] = "Stealth",
							},
							["Evocation"] = {
								["icon"] = 136075,
								["soundFile"] = "Evocation",
							},
							["Prowl"] = {
								["icon"] = 132089,
								["soundFile"] = "Stealth",
							},
						},
						["srcUnits"] = 3,
						["created"] = true,
						["name"] = "Sound only",
						["dstUnits"] = 3,
						["showBar"] = false,
					},
					["1601737160"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["name"] = "EnemyBuffs, Announce",
						["dstUnits"] = 1,
						["spellNames"] = {
							["Free Action"] = {
								["icon"] = 134715,
								["soundFile"] = "Free Action",
							},
							["Invulnerability"] = {
								["icon"] = 135896,
								["soundFile"] = "Invulnerability",
							},
							["Blessing of Freedom"] = {
								["icon"] = 135968,
								["soundFile"] = "Blessing of Freedom",
							},
							["Blessing of Protection"] = {
								["icon"] = 135964,
								["soundFile"] = "Blessing of Protection",
							},
							["Recklessness"] = {
								["icon"] = 132109,
								["soundFile"] = "Recklessness",
							},
						},
					},
					["1602026476"] = {
						["created"] = true,
						["srcUnits"] = 2,
						["name"] = "debug",
						["dstUnits"] = 1,
						["spellNames"] = {
							["Death Wish"] = {
								["icon"] = 136146,
								["soundFile"] = "Death Wish",
							},
							["Shield Wall"] = {
								["icon"] = 132362,
								["soundFile"] = "Shield Wall",
							},
							["Recklessness"] = {
								["icon"] = 132109,
								["soundFile"] = "Recklessness",
							},
						},
					},
					["1601739380"] = {
						["spellNames"] = {
							["Blind"] = {
								["icon"] = 136175,
								["soundFile"] = "Blind Friend",
							},
						},
						["created"] = true,
						["srcUnits"] = 3,
						["name"] = "Friend blinded",
						["dstUnits"] = 2,
						["dstExclude"] = 2,
					},
					["1601739067"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["name"] = "EnemyBuffs, NoAnnounce",
						["dstUnits"] = 1,
						["spellNames"] = {
							["Divine Shield"] = {
								["icon"] = 135896,
								["soundFile"] = "Divine Shield",
							},
							["Evasion"] = {
								["icon"] = 136205,
								["soundFile"] = "Evasion",
							},
							["Perception"] = {
								["icon"] = 136090,
								["soundFile"] = "Perception",
							},
							["Sprint"] = {
								["icon"] = 132307,
								["soundFile"] = "Sprint",
							},
						},
					},
					["1596266053"] = {
						["created"] = true,
						["spellNames"] = {
							["Mark of the Wild"] = {
								["icon"] = 136078,
								["soundFile"] = "None",
							},
						},
						["soundFile"] = "Sprint",
						["name"] = "MotW",
						["soundSelection"] = 1,
						["showBar"] = false,
					},
				},
			},
			["start"] = {
				["selectedAlert"] = "1596266126",
				["alertDetails"] = {
					["1596266126"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["spellNames"] = {
							["Mind Control"] = {
								["icon"] = 136206,
								["soundFile"] = "Mind Control",
							},
							["Resurrection"] = {
								["icon"] = 135955,
								["soundFile"] = "Resurrection",
							},
							["Mana Burn"] = {
								["icon"] = 136170,
								["soundFile"] = "Mana Burn",
							},
						},
						["name"] = "Enemy casts, announce",
						["showBar"] = false,
					},
					["1601739802"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["spellNames"] = {
							["Scare Beast"] = {
								["icon"] = 132118,
								["soundFile"] = "Scare Beast",
							},
							["Presence of Mind"] = {
								["icon"] = 136031,
								["soundFile"] = "Presence of Mind",
							},
							["Aimed Shot"] = {
								["icon"] = 135130,
								["soundFile"] = "Aimed Shot",
							},
							["Hibernate"] = {
								["icon"] = 136090,
								["soundFile"] = "Hibernate",
							},
						},
						["name"] = "Enemy casts, no announce",
						["showBar"] = false,
					},
				},
			},
		},
	}
end
