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
		fontSize = 14,
		font = "Roboto Condensed Regular",
		timeVisible = 10,
		alpha = 0,
		showIcon = true,
	},
	bars = {
		["**"] = {
			width = 165,
			height = 17,
			enabled = true,
			unlocked = false,
			showIcon = true,
			alpha = 0.8,
			timeVisible = true,
			shadowColor = {0, 0, 0, 0.1},
			textColor = {1, 1, 1, 1},
			backgroundColor = {0, 0, 0, 0.4},
			spacing = 5,
			goodColor = {0, 1, 0, 0.75},
			badColor = {1, 0, 0, 0.75},
		},
		casts = {
			point = "CENTER",
			ofs_x = 220,
			ofs_y = 160,
			fill = true,
			growUp = true,
			texture = "Diagonal",
			label = "Casting bars",
		},
		auras = {
			point = "CENTER",
			ofs_x = 220,
			ofs_y = 135,
			fill = false,
			growUp = false,
			texture = "BantoBar",
			label = "Aura bars"
		},
		barType = "auras",
	},
	messages = {
		enabled = true,
		chatEnabled = true,
		gain = A.messages.gain,
		dispel = A.messages.dispel,
		start =  A.messages.start,
		success =  A.messages.success,
		missed =  A.messages.missed,
		interrupt =  A.messages.interrupt,
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
			name = "Glow Preset",
			type = "pixel",
			color = {0.95, 0.95, 0.32, 1},
			number = 10,
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
					addonMessages = 3,
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
					addonMessages = 3,
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
