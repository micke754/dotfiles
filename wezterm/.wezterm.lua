-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
-- config.initial_cols = 120
-- config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 16
config.font = wezterm.font("FiraCode Nerd Font Propo")
-- config.font = wezterm.font("IosevkaTerm Nerd Font Propo")
-- config.color_scheme = "kanagawabones"
config.color_scheme = "Oxocarbon Dark (Gogh)"
-- Window decorations
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Finally, return the configuration to wezterm:
return config
