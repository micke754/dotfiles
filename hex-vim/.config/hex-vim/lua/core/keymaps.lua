-- Insert mode shortcut for Escape
vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape insert mode" })

-- Visual selections
vim.keymap.set("n", "mip", "vip", { noremap = true, desc = "Select in paragraph (Helix-style)" })
vim.keymap.set("n", "miw", "viw", { noremap = true, desc = "Select in word (Helix-style)" })

-- Buffer management
vim.keymap.set(
	"n",
	"<Space>wq",
	":lua require('mini.bufremove').delete(0, false)<CR>",
	{ noremap = true, desc = "Quit buffer" }
)
vim.keymap.set("n", "<Space>qq", ":qa<CR>", { noremap = true, desc = "Quit all buffers" })
vim.keymap.set("n", "<Space>ww", ":w<CR>", { noremap = true, desc = "Save buffer" })

-- Movement improvements
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, desc = "Scroll down and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, desc = "Scroll up and center" })
vim.keymap.set("n", "ge", "G", { noremap = true, desc = "Scroll to end" })

-- Searching
vim.keymap.set("n", "<Space>/", ":noh<CR>", { noremap = true, desc = "Clear search highlighting" })
