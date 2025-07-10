-- plugins/mini.lua

return {
	"echasnovski/mini.nvim",
	version = false,
	config = function()
		require("mini.basics").setup({
			-- Enhance default Neovim behavior
			options = {
				basic = true,
				extra_ui = true,
			},
			mappings = {
				-- Disable some default mappings to use custom ones
				basic = true,
				windows = true,
				move_with_alt = true,
			},
		}) -- Basic settings
		require("mini.move").setup({}) -- Move text/blocks
		-- require("mini.ai").setup({}) -- Enhanced text objects
		-- require("mini.surround").setup({}) -- Surround management
		-- require("mini.comment").setup({}) -- Commenting
		require("mini.clue").setup({
			triggers = {
				{ mode = "n", keys = "<Leader>" },
				{ mode = "x", keys = "<Leader>" },
				{ mode = "n", keys = "m" },
				{ mode = "x", keys = "m" },
			},
		}) -- Keymap hints
		-- require("mini.files").setup({}) -- File tree
		require("mini.starter").setup({}) -- Starting screen
		require("mini.animate").setup({}) -- Smooth animations
		-- require("mini.completion").setup({}) -- Completion
		-- require("mini.align").setup({}) -- Alignment
		require("mini.bufremove").setup({}) -- Buffer removal
		require("mini.indentscope").setup({}) -- Indent scope visualization
	end,
}
