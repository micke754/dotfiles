-- plugins/files.lua

return {
	{
		"echasnovski/mini.files",
		version = false,
		opts = {
			mappings = {
				close = "q",
				show_help = "g?",
				trim_left = "<",
				trim_right = ">",
			},
		},
		config = function(_, opts)
			require("mini.files").setup(opts)

			-- Set up keybindings for current and root directory
			vim.keymap.set("n", "<space>e", function()
				require("mini.files").open(vim.loop.cwd())
			end, { desc = "Open file tree in current directory" })

			vim.keymap.set("n", "<space>E", function()
				require("mini.files").open(vim.fn.getcwd())
			end, { desc = "Open file tree in root directory" })
		end,
	},
}
