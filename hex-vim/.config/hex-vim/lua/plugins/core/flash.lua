return {
	{
		"folke/flash.nvim",
		opts = {},
		keys = {
			{
				"gw",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash Jump",
			},
		},
	},
}
