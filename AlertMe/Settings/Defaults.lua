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
		},
		chat_frames = {
			["*"] = true,
		},
			scrolling_text = {
			enabled = true,
			width = 600,
			align = 1,
			fading = true,
			point = "CENTER",
			point_x = 0,
			point_y = -150,
			maxlines = 300,
			visible_lines = 3,
			font_size = 13,
			timevisible = 10,
			alpha = 0.1
		},
		test = false,
	},
	events = {
		msg_gain = "%dstName gained %spellName",
		msg_dispel = "%extraSpellName dispelled on %dstName -- by %srcName",
		msg_start = "%srcName starts to cast %spellName",
		msg_success = "%srcName casted %spellName on %dstName",
		msg_interrupt = "%srcName interrupted %dstName -- %extraSchool locked for %lockout s",
		chatPrefix = "** ",
		chatPostfix = " **",
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
