-- get engine environment
local A, O = unpack(select(2, ...))
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
		displaySettings = false,
		dstWhisper = false,
		relSpellName = "spellName",
		units = {"src"},
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
						["spellNames"] = {
							["Blessing of Protection"] = {
								["icon"] = 135964,
								["soundFile"] = "None",
							},
							["Blessing of Freedom"] = {
								["icon"] = 135968,
							},
							["Free Action"] = {
								["icon"] = 134715,
							},
							["Invulnerability"] = {
								["icon"] = 135896,
							},
						},
						["soundFile"] = "Purge",
						["name"] = "Dispel Enemy Buffs",
						["chatChannels"] = 4,
						["soundSelection"] = 2,
						["created"] = true,
					},
				},
			},
			["success"] = {
				["selectedAlert"] = "1602031069",
				["alertDetails"] = {
					["1602031069"] = {
						["msgOverride"] = "May the force be with you!",
						["dstWhisper"] = 2,
						["addonMessages"] = 2,
						["created"] = true,
						["name"] = "Whisper buff target",
						["dstUnits"] = 2,
						["soundSelection"] = 1,
						["spellNames"] = {
							["Power Infusion"] = {
								["icon"] = 135939,
							},
							["Innervate"] = {
								["icon"] = 136048,
							},
						},
					},
				},
			},
			["interrupt"] = {
				["selectedAlert"] = "1602863497",
				["alertDetails"] = {
					["1602863497"] = {
						["addonMessages"] = 2,
						["created"] = true,
						["name"] = "Enemy by me",
						["dstUnits"] = 3,
						["chatChannels"] = 4,
					},
					["1601740297"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["addonMessages"] = 2,
						["soundFile"] = "Kick",
						["name"] = "Myself interrupted",
						["chatChannels"] = 4,
						["soundSelection"] = 2,
						["msgOverride"] = "I am interrupted --%extraSchool locked for %lockout s",
					},
					["1601740258"] = {
						["srcUnits"] = 2,
						["created"] = true,
						["srcExclude"] = 2,
						["soundFile"] = "Countered",
						["name"] = "Enemy by friendly",
						["dstUnits"] = 3,
						["soundSelection"] = 2,
					},
				},
			},
			["start"] = {
				["selectedAlert"] = "1596266126",
				["alertDetails"] = {
					["1596266126"] = {
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
						["srcUnits"] = 3,
						["created"] = true,
						["name"] = "Enemy, Announce",
						["chatChannels"] = 4,
						["showBar"] = false,
					},
					["1601739802"] = {
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
						["srcUnits"] = 3,
						["created"] = true,
						["name"] = "Enemy, NoAnnounce",
						["showBar"] = false,
					},
					["1602863290"] = {
						["spellNames"] = {
							["Polymorph"] = {
								["icon"] = 136071,
							},
							["Hibernate"] = {
								["icon"] = 136090,
							},
						},
						["addonMessages"] = 2,
						["created"] = true,
						["name"] = "MySpellAnnounce",
						["chatChannels"] = 4,
						["soundSelection"] = 1,
					},
				},
			},
			["gain"] = {
				["selectedAlert"] = "1601737160",
				["alertDetails"] = {
					["1601739154"] = {
						["msgOverride"] = "I am affected by %spellName",
						["srcUnits"] = 3,
						["addonMessages"] = 2,
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
							["Sap"] = {
								["icon"] = 132310,
							},
							["Reckless Charge"] = {
								["icon"] = 136010,
							},
							["Blind"] = {
								["icon"] = 136175,
							},
						},
						["name"] = "CC on me",
						["soundSelection"] = 1,
						["created"] = true,
						["showBar"] = false,
					},
					["1601739067"] = {
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
						["srcUnits"] = 3,
						["addonMessages"] = 2,
						["name"] = "EnemyBuffs, NoAnnounce",
						["dstUnits"] = 1,
						["created"] = true,
					},
					["1601737160"] = {
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
							["Recklessness"] = {
								["icon"] = 132109,
								["soundFile"] = "Recklessness",
							},
							["Blessing of Protection"] = {
								["icon"] = 135964,
								["soundFile"] = "Blessing of Protection",
							},
						},
						["srcUnits"] = 3,
						["addonMessages"] = 2,
						["name"] = "EnemyBuffs, Announce",
						["dstUnits"] = 1,
						["created"] = true,
					},
					["1601739380"] = {
						["created"] = true,
						["spellNames"] = {
							["Blind"] = {
								["icon"] = 136175,
								["soundFile"] = "Blind Friend",
							},
						},
						["srcUnits"] = 3,
						["addonMessages"] = 2,
						["showBar"] = false,
						["name"] = "Friend blinded",
						["dstUnits"] = 2,
						["dstExclude"] = 2,
					},
					["1601739528"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["addonMessages"] = 2,
						["spellNames"] = {
							["Stealth"] = {
								["icon"] = 132320,
								["soundFile"] = "Stealth",
							},
							["Prowl"] = {
								["icon"] = 132089,
								["soundFile"] = "Stealth",
							},
							["Evocation"] = {
								["icon"] = 136075,
								["soundFile"] = "Evocation",
							},
						},
						["name"] = "Sound only",
						["dstUnits"] = 3,
						["showBar"] = false,
					},
				},
			},
		},
	}
end
