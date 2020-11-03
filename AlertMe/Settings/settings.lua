-- set addon environment
setfenv(1, _G.AlertMe)

-- create A.events and A.menus tables and merge them
A.events = {}
A.events.SPELL_AURA_APPLIED = {
	handle = "gain",
	barType = "auras",
	extraArgs = { "auraType" },
	checkedSpell = "spellName",
	actions = { "ChatAnnounce","DisplayAuraBars","DisplayGlows","PlaySound" },
}
A.events.SPELL_AURA_REFRESH = A.events.SPELL_AURA_APPLIED		-- handled completely the same as apply
A.events.SPELL_AURA_REMOVED = {
	handle = "removed",
	barType = "auras",
	optArgs = { "auraType" },
	checkedSpell = "spellName",
	-- speecial A.events doesn't need most of the options, as the normal way of processing is being completely bypasse
}
A.events.SPELL_AURA_BROKEN =  A.events.SPELL_AURA_REMOVED		-- handled the same as removed
A.events.SPELL_AURA_BROKEN_SPELL = A.events.SPELL_AURA_REMOVED
A.events.SPELL_DISPEL = {
	handle = "dispel",
	barType = "auras",
	extraArgs = { "extraSpellId", "extraSpellName", "extraSchool", "auraType" },
	checkedSpell = "extraSpellName",
	actions = { "ChatAnnounce", "HideGUI", "PlaySound" },
}
A.events.SPELL_CAST_START = {
	handle = "start",
	barType = "spells",
	checkedSpell = "spellName",
	actions = { "ChatAnnounce", "DisplayAuraBars", "DisplayGlows", "PlaySound" },
}
A.events.SPELL_CAST_SUCCESS = {
	handle = "success",
	barType = "spells",
	checkedSpell = "spellName",
	actions = { "ChatAnnounce", "PlaySound" }, -- progress bar gets called by unit_cast A.events
}
A.events.SPELL_INTERRUPT = {
	handle = "interrupt",
	extraArgs = { "extraSpellId", "extraSpellName", "extraSchool" },
	checkedSpell = "spellName",
	actions = { "ChatAnnounce", "PlaySound" }, -- progress bar gets called by unit_cast A.events
}
A.events.SPELL_MISSED = {
	handle = "missed",
	extraArgs = { "missType", "isOffHand", "amountMissed", "critical" },
	checkedSpell = "spellName",
	actions = { "ChatAnnounce", "PlaySound" },
}
-- the settings per options category. match to A.events by handle
A.menus = {}
A.menus.gain = {
	type = "aura",
	text = "On aura gain/refresh",
	order = 1,
	spellSelection = true,
	unitSelection =	{ "src", "dst" },
	displayOptions = { glow = true, bar = true },
	dstWhisper = true,
}
A.menus.dispel = {
	type = "aura",
	text = "On dispel",
	order = 2,
	spellSelection = true,
	unitSelection =	{ "src","dst" },
	dstWhisper = true,
}
A.menus.start = {
	type = "spell",
	text = "On cast start",
	order = 3,
	spellSelection = true,
	unitSelection =	{ "src" },
	displayOptions = { bar = true },
}
A.menus.success = {
	type = "spell",
	text = "On cast success",
	order = 4,
	spellSelection = true,
	unitSelection =	{ "src", "dst" },
	dstWhisper = true,
}
A.menus.missed = {
	type = "spell",
	text = "On spell missed",
	order = 5,
	spellSelection = true,
	unitSelection =	{ "src", "dst" },
	dstWhisper = true,
}
A.menus.interrupt = {
	type = "spell",
	text = "On interrupt",
	order = 6,
	spellSelection = true,
	unitSelection =	{ "src", "dst" },
	dstWhisper = true,
}

A.messages = {
	gain = "%dstName gained %spellName",
	dispel = "%extraSpellName dispelled on %dstName -- by %srcName",
	start = "%srcName casts %spellName",
	success = "%srcName used %spellName on %dstName",
	missed = "%srcName's %spellName missed on %dstName (%missType)",
	interrupt = "%srcName interrupted %dstName -- %extraSchool locked for %lockout s",
}

A.missTypes = {
	ABSORB = "absorbed",
	BLOCK = "blocked",
	DEFLECT = "deflected",
	DODGE = "dodged",
	EVADE = "evaded",
	IMMUNE = "immune",
	MISS = "missed",
	PARRY = "parried",
	REFLECT = "reflected",
	RESIST = "resisted"
}



-- merge event and menu settings into A.events  to have an easier time afterwards
for _, event in pairs(A.events) do
	local menu = A.menus[event.handle]
	if menu and type(menu) == "table" then
		for i, setting in pairs(menu) do
			if not event[i] then				-- don't overwrite existing settings if in conflict
				event[i] = setting
			end
		end
	end
end

-- lockouts
A.lockouts = {
	["Counterspell"] = "10",
	["Spell Lock"] = "8",
	["Shield Bash"] = "6",
	["Pummel"] = "4",
	["Earth Shock"] = "2",
	["Feral Charge Effect"] = "4",
	["Kick"] = "5",
}

-- colors
A.colors = {
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
			["gain"] = {
				["selectedAlert"] = "1601737160",
				["alertDetails"] = {
					["1601739154"] = {
						["msgOverride"] = "I am affected by %spellName",
						["srcUnits"] = 3,
						["addonMessages"] = 3,
						["spellNames"] = {
							["Mind Control"] = {
								["icon"] = 136206,
							},
							["Blind"] = {
								["icon"] = 136175,
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
							["Freezing Trap Effect"] = {
								["icon"] = 135834,
							},
						},
						["name"] = "CC on Me",
						["chatChannels"] = 4,
						["soundSelection"] = 1,
						["created"] = true,
						["showBar"] = false,
					},
					["1601739528"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["spellNames"] = {
							["Presence of Mind"] = {
								["icon"] = 136031,
								["soundFile"] = "Presence of Mind",
							},
							["Prowl"] = {
								["icon"] = 132089,
								["soundFile"] = "Stealth",
							},
							["Evocation"] = {
								["icon"] = 136075,
								["soundFile"] = "Evocation",
							},
							["Stealth"] = {
								["icon"] = 132320,
								["soundFile"] = "Stealth",
							},
						},
						["name"] = "Sound only",
						["dstUnits"] = 3,
						["showBar"] = false,
					},
					["1601737160"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["addonMessages"] = 3,
						["name"] = "EnemyBuffs, Announce",
						["dstUnits"] = 1,
						["chatChannels"] = 4,
						["spellNames"] = {
							["Free Action"] = {
								["icon"] = 134715,
								["soundFile"] = "Free Action",
							},
							["Blessing of Protection"] = {
								["icon"] = 135964,
								["soundFile"] = "Blessing of Protection",
							},
							["Blessing of Freedom"] = {
								["icon"] = 135968,
								["soundFile"] = "Blessing of Freedom",
							},
							["Invulnerability"] = {
								["icon"] = 135896,
								["soundFile"] = "Invulnerability",
							},
							["Recklessness"] = {
								["icon"] = 132109,
								["soundFile"] = "Recklessness",
							},
						},
					},
					["1601739380"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["showBar"] = false,
						["name"] = "CC on Friend",
						["dstUnits"] = 2,
						["spellNames"] = {
							["Polymorph"] = {
								["icon"] = 136071,
								["soundFile"] = "Sheep Friend",
							},
							["Sap"] = {
								["icon"] = 132310,
								["soundFile"] = "Sap Friend",
							},
							["Blind"] = {
								["icon"] = 136175,
								["soundFile"] = "Blind Friend",
							},
							["Wyvern Sting"] = {
								["icon"] = 135125,
								["soundFile"] = "Wyvern Sting",
							},
						},
						["dstExclude"] = 2,
					},
					["1601739067"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["addonMessages"] = 2,
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
				},
			},
			["success"] = {
				["selectedAlert"] = "1602031069",
				["alertDetails"] = {
					["1602031069"] = {
						["created"] = true,
						["dstWhisper"] = 2,
						["addonMessages"] = 2,
						["msgOverride"] = "May the force be with you!",
						["name"] = "Powerup Friend",
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
				["selectedAlert"] = "1601740297",
				["alertDetails"] = {
					["1602872688"] = {
						["addonMessages"] = 3,
						["created"] = true,
						["soundFile"] = "Countered",
						["name"] = "Enemy by Me",
						["dstUnits"] = 3,
						["chatChannels"] = 4,
						["soundSelection"] = 2,
					},
					["1601740297"] = {
						["msgOverride"] = "I am interrupted --%extraSchool locked for %lockout s",
						["srcUnits"] = 3,
						["addonMessages"] = 3,
						["soundFile"] = "Kick",
						["name"] = "Myself Interrupted",
						["chatChannels"] = 4,
						["soundSelection"] = 1,
						["created"] = true,
					},
					["1601740258"] = {
						["srcUnits"] = 2,
						["created"] = true,
						["srcExclude"] = 2,
						["soundFile"] = "Countered",
						["name"] = "Enemy by Friend",
						["dstUnits"] = 3,
						["soundSelection"] = 2,
					},
				},
			},
			["dispel"] = {
				["selectedAlert"] = "1601740147",
				["alertDetails"] = {
					["1601740147"] = {
						["created"] = true,
						["addonMessages"] = 3,
						["soundFile"] = "Purge",
						["name"] = "Dispel Enemy Buffs",
						["chatChannels"] = 4,
						["soundSelection"] = 2,
						["spellNames"] = {
							["Blessing of Protection"] = {
								["icon"] = 135964,
								["soundFile"] = "None",
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
			["start"] = {
				["selectedAlert"] = "1601739802",
				["alertDetails"] = {
					["1596266126"] = {
						["created"] = true,
						["srcUnits"] = 3,
						["addonMessages"] = 3,
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
						["name"] = "Enemy, Announce",
						["chatChannels"] = 4,
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
						["name"] = "Enemy, NoAnnounce",
						["showBar"] = false,
					},
				},
			},
		},
	}
end
