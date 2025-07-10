local enabled = true

local plugin = {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		local map_multistep = require("mini.keymap").map_multistep
		-- Create a test mapping
		-- map_multistep("n", "e", { "Esc", "v", "e" })
		-- map_multistep("i", "<Tab>", { "pmenu_next" })
		-- map_multistep("i", "<Tab>", { "pmenu_next" })
		-- map_multistep("i", "<S-Tab>", { "pmenu_prev" })
		-- map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
		-- map_multistep("i", "<BS>", { "minipairs_bs" })

		local map_combo = require("mini.keymap").map_combo

		-- Support most common modes. This can also contain 't', but would
		-- only mean to press `<Esc>` inside terminal.
		local mode = { "i", "c", "x", "s" }
		map_combo(mode, "jj", "<BS><BS><Esc>")
		local mode = { "n", "v" }
		map_combo("n", "mm", "%")
	end,
}

if enabled == false then
	return {}
else
	return plugin
end
