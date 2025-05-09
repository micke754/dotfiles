return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				integrations = {
					cmp = true,
					mini = true,
					treesitter = true,
				},
			})
		end,
	},
}
