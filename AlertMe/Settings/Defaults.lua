-- set addon environment
setfenv(1, _G.AlertMe)

-- set default options
D.profile = {
	general = {
		zones = {
			["*"] = true,
			["instance"] = false,
		},
		minimap = { hide = false },
		minimapPos = {},
		enabled = true,
		debugLevel = 0,
		debugLevelLog = 0,
		debugLog = false,
	},
	scrolling = {
		enabled = true,
		movable = false,
		width = 600,
		align = 1,
		fading = true,
		point = "CENTER",
		ofs_x = 0,
		ofs_y = -150,
		maxLines = 300,
		visibleLines = 3,
		fontSize = 15,
		font = "Roboto Condensed Regular",
		timeVisible = 10,
		alpha = 0,
		showIcon = true,
	},
	bars = {
		["**"] = {
			enabled = true,
			unlocked = false,
			showIcon = true,
			alpha = 0.8,
			timeVisible = true,
			shadowColor = {0, 0, 0, 0.1},
			textColor = {1, 1, 1, 1},
			backgroundColor = {0, 0, 0, 0.4}
		},
		spells = {
			point = "CENTER",
			ofs_x = 100,
			ofs_y = 200,
			width = 160,
			height = 18,
			fill = true,
			texture = "Diagonal",
			goodColor = {0, 1, 0, 1},
			badColor = {1, 0, 0, 1},
		},
		auras = {
			point = "CENTER",
			ofs_x = 280,
			ofs_y = 200,
			width = 160,
			height = 18,
			fill = false,
			texture = "BantoBar",
			goodColor = {0, 1, 0, 0.7},
			badColor = {1, 0, 0, 0.7},
		},
		barType = "auras"
	},
	messages = {
		enabled = true,
		chatEnabled = true,
		gain = "%dstName gained %spellName",
		dispel = "%extraSpellName dispelled on %dstName -- by %srcName",
		start = "%srcName starts to cast %spellName",
		success = "%srcName has casted %spellName on %dstName",
		interrupt = "%srcName interrupted %dstName -- %extraSchool locked for %lockout s",
		prefix = "** ",
		postfix = " **",
		chatFrames = {
			["*"] = false,
		},
	},
	glow = {
		selectedGlow = 1,
		bgtEnabled = true,
		enabled = true,
		['*'] = {
			type = "pixel",
			color = {0.95, 0.95, 0.32, 1},
			number = 8,
			frequency = 0.25,
			thickness = 2,
			ofs_x = -1,
			ofs_y = -1,
			border = false,
		},
	},
	options = {
		lastMenu = "ShowAlerts"
	},
	dummy = {
		name = ""
	},
	alerts = {
		['*'] = {
			selectedAlert = nil,
			alertDetails = {
				['*'] = {
					name = "New alert",
					active = true,
					spellNames = {
						['*'] = {
							icon = "",
							soundFile = "None",
						}
					},
					srcUnits = 5,
					srcExclude = 1,
					dstUnits = 5,
					dstExclude = 1,
					created = false,
					showBar = true,
					showGlow = -1,
					chatChannels = 1,
					addonMessages = 1,
					dstWhisper = 1,
					scrollingText = true,
					soundSelection = 3,
					soundFile = "None",
					msgOverride = "",
				},
			},
		},
		start = {
			selectedAlert = nil,
			alertDetails = {
				['*'] = {
					name = "New alert",
					active = true,
					spellNames = {
						['*'] = {
							icon = "",
							soundFile = "None",
						}
					},
					srcUnits = 5,
					srcExclude = 1,
					dstUnits = 5,
					dstExclude = 1,
					created = false,
					showBar = false,
					showGlow = -1,
					chatChannels = 1,
					addonMessages = 1,
					dstWhisper = 1,
					scrollingText = true,
					soundSelection = 3,
					soundFile = "None",
					msgOverride = "",
				},
			},
		},
	},
	log = {}
}
