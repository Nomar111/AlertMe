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
			use = true,
			width = 400,
			height = 42,
			align = "CENTER",
			fading = true,
			point = "CENTER",
			point_x = 0,
			point_y = -130,
			maxlines = 200,
			timevisible = 10,
			bg_aplpha = 0.1
			-- --aura_env.scrollframe:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE, MONOCHROME")
		    --font = ("Interface\\AddOns\\SharedMedia\\Fonts\\Roboto_Condensed\\RobotoCondensed-Regular.ttf", 14)
			    -- --aura_env.scrollframe:SetFontObject("GameFontWhite")
			    -- f:SetMaxLines(200)

		},
		test = false,
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
					source_units = 5,
					source_exclude = 1,
					target_units = 5,
					target_exclude = 1,
					dummy = 1,
					show_bar = true,
					chat_channels = 1,
					system_messages = 2,
					whisper_destination = 1,
					scrolling_text = true,
					sound_selection = 1,
					sound_file = "",
				},
			},
		},
	},
	events = {
		dd_value = 3,
		dd_items = {[1] = "Eins", [2] = "Zwei"},
	}
}
