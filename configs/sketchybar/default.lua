local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
	updates = "on",
	icon = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 14.0,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
		background = { image = { corner_radius = 8 } },
	},
	label = {
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Semibold"],
			size = 13.0,
		},
		color = colors.white,
		padding_left = settings.paddings,
		padding_right = settings.paddings,
	},
	background = {
		height = 24,
		corner_radius = 8,
		border_width = 2,
		border_color = colors.bg2,
		image = {
			corner_radius = 8,
			border_color = colors.grey,
			border_width = 1,
		},
	},
	padding_left = 4,
	padding_right = 4,
	scroll_texts = true,
})
