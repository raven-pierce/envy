local colors = require("colors")

local handle = io.popen("yabai -m query --displays | jq -r '.[] | select(.id != 1) | .index' | tr '\\n' ',' | sed 's/,$//'")
local display_str = handle:read("*a")
handle:close()

-- Now configure the bar
sbar.bar({
  height = 28,
  topmost = "window",
  color = colors.transparent,
  display = display_str,
})
