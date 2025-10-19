local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}
local japanese = { "一", "二", "三", "四", "五", "六", "七", "八", "九", "十" }

for i = 1, 10, 1 do
	local space = sbar.add("space", "space." .. i, {
		position = "center",
		space = i,
		icon = {
			font = { family = settings.font.icons },
			string = japanese[i],
			padding_left = 16,
			padding_right = 8,
			color = colors.arise,
			highlight_color = colors.peach,
			align = "center",
		},
		label = {
			padding_right = 16,
			color = colors.grey,
			highlight_color = colors.arise,
			font = "sketchybar-app-font:Regular:16.0",
			y_offset = 0,
		},
		padding_right = 1,
		padding_left = 1,
		background = {
			color = colors.transparent,
			border_width = 1,
			height = 24,
			border_color = colors.grey,
		},
	})

	spaces[i] = space

	-- Padding space
	sbar.add("space", "space.padding." .. i, {
		position = "center",
		space = i,
		script = "",
		width = settings.group_paddings,
	})


	space:subscribe("space_change", function(env)
		local selected = env.SELECTED == "true"
		space:set({
			icon = { highlight = selected },
			label = { highlight = selected },
			background = { border_color = selected and colors.grey or colors.bg2 },
		})
		space_bracket:set({
			background = { border_color = selected and colors.peach or colors.bg2 },
		})
	end)

	space:subscribe("mouse.clicked", function(env)
		local op = (env.BUTTON == "right") and "--destroy" or "--focus"
		sbar.exec("yabai -m space " .. op .. " " .. env.SID)
	end)
end

-- Observer for updating app icons in spaces
local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

space_window_observer:subscribe("space_windows_change", function(env)
	local icon_line = ""
	local no_app = true
	
	for app, count in pairs(env.INFO.apps) do
		no_app = false
		local lookup = app_icons[app]
		local icon = lookup or app_icons["Default"]
		icon_line = icon_line .. icon
	end

	if no_app then
		icon_line = "—"
	end
	
	sbar.animate("tanh", 30, function()
		spaces[env.INFO.space]:set({ label = icon_line })
	end)
end)