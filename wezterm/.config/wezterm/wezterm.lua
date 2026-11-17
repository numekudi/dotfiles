local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- Why not "Hack Nerd Font Mono": the Mono variant shrinks icons to one cell, making them hard to read.
-- Why not rely on implicit fallback: fontconfig picks "Noto Serif CJK SC" (serif + Chinese glyph shapes) for Japanese.
config.font = wezterm.font_with_fallback({
	"Hack Nerd Font",
	"Noto Sans Mono CJK JP",
})

return config
