return {
	-- Treesitter for syntax highlighting and motions
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				highlight = { enable = true },
				incremental_selection = { enable = true },
			})
		end,
	},
}
