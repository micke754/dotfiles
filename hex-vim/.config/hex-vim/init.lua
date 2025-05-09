-- init.lua

-- Helix-like keybindings
vim.g.mapleader = " " -- Leader key

-- Ensure lazy.nvim is installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins using lazy.nvim
require("lazy").setup("plugins.core")
-- require("plugins")

-- Load core configurations
require("core.options")
require("core.keymaps")
