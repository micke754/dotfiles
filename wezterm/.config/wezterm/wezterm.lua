-- Pull in the wezterm API
local wezterm = require("wezterm")
local font_size = 14

-- Combined status: leader indicator (left) + zoom + time + battery (right)
wezterm.on("update-status", function(window, pane)
	-- Leader indicator (left side)
	local leader = ""
	if window:leader_is_active() then
		leader = "󰀘 "
	end

	window:set_left_status(wezterm.format({
		{ Foreground = { Color = "#e0def4" } },
		{ Background = { Color = "#191724" } },
		{ Text = leader },
	}))

	-- Zoom detection (right side)
	local zoom = ""
	local tab = pane:tab()
	if tab then
		local panes_info = tab:panes_with_info()
		if #panes_info > 1 then
			for _, pane_info in ipairs(panes_info) do
				if pane_info.is_zoomed then
					zoom = "󰍉 "
					break
				end
			end
		end
	end

	local date = wezterm.strftime(" %m-%d  %H:%M ")
	local battery = ""
	for _, b in ipairs(wezterm.battery_info()) do
		battery = string.format(" %.0f%% ", b.state_of_charge * 100)
		break
	end

	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#e0def4" } },
		{ Background = { Color = "#191724" } },
		{ Text = zoom .. date .. battery },
	}))
end)
-- zoom .. date .. battery
-- This will hold the configuration.
local config = wezterm.config_builder()

config.default_prog = { "zsh", "-c", "/Users/kmichaels/.nix-profile/bin/nu" }

-- Window spacing
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- Window decorations
config.window_decorations = "RESIZE"
-- config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- or, changing the font size and color scheme.
config.font_size = font_size

config.font = wezterm.font("MartianMono Nerd Font Propo")

-- config.color_scheme = "Rosé Pine (base16)"
config.color_scheme = "tokyonight_night"
-- config.color_scheme = "rose-pine"
-- config.color_scheme = "catppuccin-mocha"

config.window_frame = {
	active_titlebar_bg = "#191724", -- Rose Pine base
	inactive_titlebar_bg = "#1f1d2e", -- Rose Pine surface
	active_titlebar_fg = "#e0def4", -- Rose Pine text
	inactive_titlebar_fg = "#6e6a86", -- Rose Pine subtle
	font_size = font_size,
	font = wezterm.font("MartianMono Nerd Font Propo"),
}

config.colors = {
	tab_bar = {
		background = "#191724", -- Rose Pine base to match your theme
	},
}

-- Keyboard magic
config.enable_kitty_keyboard = true
local action = wezterm.action

-- Keys
config.disable_default_key_bindings = true

config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {

	-- Control Palette
	{ key = "p", mods = "CTRL|SHIFT", action = action.ActivateCommandPalette },
	{ key = "Space", mods = "CTRL|SHIFT", action = action.QuickSelect },

	-- Copy selection to clipboard
	{ key = "c", mods = "SHIFT|CTRL", action = action.CopyTo("Clipboard") },
	-- Paste from clipboard
	{ key = "v", mods = "SHIFT|CTRL", action = action.PasteFrom("Clipboard") },

	-- Pane splitting (like tmux)
	{ key = '"', mods = "LEADER", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "'", mods = "LEADER", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- Pane navigation (like tmux)
	{ key = "LeftArrow", mods = "LEADER", action = action.ActivatePaneDirection("Left") },
	{ key = "RightArrow", mods = "LEADER", action = action.ActivatePaneDirection("Right") },
	{ key = "UpArrow", mods = "LEADER", action = action.ActivatePaneDirection("Up") },
	{ key = "DownArrow", mods = "LEADER", action = action.ActivatePaneDirection("Down") },
	{ key = "o", mods = "LEADER", action = action.ActivatePaneDirection("Next") },

	-- Tab management (like tmux windows)
	{ key = "c", mods = "LEADER", action = action.SpawnTab("CurrentPaneDomain") },
	{ key = "x", mods = "LEADER", action = action.CloseCurrentPane({ confirm = true }) },
	{ key = "&", mods = "LEADER", action = action.CloseCurrentTab({ confirm = true }) },
	{ key = "d", mods = "LEADER", action = action.DetachDomain("CurrentPaneDomain") },

	-- Tab navigation
	{ key = "n", mods = "LEADER", action = action.ActivateTabRelative(1) },
	{ key = "N", mods = "LEADER", action = action.ActivateTabRelative(-1) },
	{ key = "l", mods = "LEADER", action = action.ActivateLastTab },

	-- Tab numbers (0-9)
	{ key = "1", mods = "LEADER", action = action.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = action.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = action.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = action.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = action.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = action.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = action.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = action.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = action.ActivateTab(8) },

	-- Resizing
	{ key = "LeftArrow", mods = "SHIFT|CTRL", action = action.AdjustPaneSize({ "Left", 2 }) },
	{ key = "DownArrow", mods = "SHIFT|CTRL", action = action.AdjustPaneSize({ "Down", 2 }) },
	{ key = "UpArrow", mods = "SHIFT|CTRL", action = action.AdjustPaneSize({ "Up", 2 }) },
	{ key = "RightArrow", mods = "SHIFT|CTRL", action = action.AdjustPaneSize({ "Right", 2 }) },

	-- Font size adjustment (Cmd + +/-)
	{ key = "=", mods = "SUPER", action = action.IncreaseFontSize },
	{ key = "-", mods = "SUPER", action = action.DecreaseFontSize },

	-- Copy mode (like tmux)
	{ key = "[", mods = "LEADER", action = action.ActivateCopyMode },

	-- Zoom pane (like tmux)
	{ key = "z", mods = "LEADER", action = action.TogglePaneZoomState },
	{ key = "s", mods = "LEADER", action = action.ShowLauncherArgs({ flags = "WORKSPACES" }) },
	{ key = "w", mods = "LEADER", action = action.ShowLauncherArgs({ flags = "WORKSPACES" }) },
	{
		key = "$",
		mods = "LEADER",
		action = action.PromptInputLine({
			description = "Enter new name for workspace",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:perform_action(action.SwitchToWorkspace({ name = line }), pane)
				end
			end),
		}),
	},
}

-- Finally, return the configuration to wezterm:
return config
