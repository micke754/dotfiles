return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { { "nvim-lua/plenary.nvim" } },
		config = function()
			require("telescope").setup({})
			vim.keymap.set("n", "<Space>f", require("telescope.builtin").find_files, { desc = "Find Files" })
			vim.keymap.set("n", "<Space>g", require("telescope.builtin").live_grep, { desc = "Live Grep" })
			vim.keymap.set("n", "<Space>b", require("telescope.builtin").buffers, { desc = "Find Buffers" })
			vim.keymap.set("n", "<Space>d", require("telescope.builtin").diagnostics, { desc = "Diagnostics Picker" })
			vim.keymap.set(
				"n",
				"<Space>s",
				require("telescope.builtin").lsp_document_symbols,
				{ desc = "Symbols Picker" }
			)
		end,
	},
}
