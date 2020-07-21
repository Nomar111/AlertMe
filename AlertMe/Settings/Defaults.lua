dprint(2,"defaults.lua")
-- get engine environment
local _, D = unpack(select(2, ...))
-- set engine as new global environment
setfenv(1, _G.AlertMe)

-- set default options
D.profile = {
	general = {
		zones = {
			["*"] = true,
		}
	},
	scrolling = {
		enabled = true,
		interactive = true,
		width = 600,
		align = 1,
		fading = true,
		point = "CENTER",
		ofs_x = 0,
		ofs_y = -150,
		maxLines = 300,
		visibleLines = 3,
		fontSize = 14,
		timeVisible = 10,
		alpha = 0.1
	},
	bars = {
		["**"] = {
			enabled = true,
			unlocked = false,
			showIcon = true,
			width = 160,
			height = 17,
			alpha = 0.7,
			fill = false,
			timeVisible = true,
			texture = "Banto",
			shadowColor = {0, 0, 0, 0.1},
			goodColor = {0, 1, 0, 0.7},
			badColor = {1, 0, 0, 0.7},
			textColor = {1, 1, 1, 1},
			backgroundColor = {0, 0, 0, 0.4}
		},
		spell = {
			point = "CENTER",
			ofs_x = 200,
			ofs_y = 150,
		},
		auras = {
			point = "CENTER",
			ofs_x = 0,
			ofs_y = 150,
		}
	},
	messages = {
		msgGain = "%dstName gained %spellName",
		msgDispel = "%extraSpellName dispelled on %dstName -- by %srcName",
		msgStart = "%srcName starts to cast %spellName",
		msgSuccess = "%srcName casted %spellName on %dstName",
		msgInterrupt = "%srcName interrupted %dstName -- %extraSchool locked for %lockout s",
		msgPrefix = "** ",
		msgPostfix = " **",
		chatFrames = {
			["*"] = true,
		},
	},
	alerts = {
		["**"] = {
			alert_dd_value = "",
			alert_dd_list = {},
			alert_details = {
				['*'] = {
					active = true,
					spells = {
						['*'] = {
							icon = "",
							sound = "",
						}
					},
					srcUnits = 5,
					srcExclude = 1,
					dstUnits = 5,
					dstExclude = 1,
					dummy = 1,
					show_bar = true,
					chat_channels = 1,
					system_messages = 2,
					whisper_destination = 1,
					scrolling_text = true,
					sound_selection = 1,
					sound_file = "",
					override = "",
				},
			},
		},
	},
}
