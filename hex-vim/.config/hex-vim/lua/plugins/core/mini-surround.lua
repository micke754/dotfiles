return {
	{
		"echasnovski/mini.surround",
		version = false,
		opts = {
			mappings = {
				add = "ms", -- Add surrounding
				delete = "md", -- Delete surrounding
				replace = "mr", -- Replace surrounding
				find = "sf", -- Find surrounding (to the right)
				find_left = "sF", -- Find surrounding (to the left)
				highlight = "sh", -- Highlight surrounding
				update_n_lines = "sn", -- Update `n_lines`
			},
		},
		config = function(_, opts)
			require("mini.surround").setup(opts)
		end,
	},
}
