return {
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")

			-- Pyright for Python
			lspconfig.basedpyright.setup({})

			-- Ruff for linting and diagnostics
			lspconfig.ruff.setup({
				settings = {
					args = { "--fix", "--quiet" }, -- Customize arguments if needed
				},
			})

			-- Lua Language Server
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})
		end,
	},
}
