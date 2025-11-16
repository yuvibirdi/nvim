vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- Window management keymaps (Ctrl-w -> Space-w)
local opts = { noremap = true, silent = true }

-- Navigation
vim.api.nvim_set_keymap("n", "<space>wh", "<C-w>h", opts)  -- Go left
vim.api.nvim_set_keymap("n", "<space>wj", "<C-w>j", opts)  -- Go down
vim.api.nvim_set_keymap("n", "<space>wk", "<C-w>k", opts)  -- Go up
vim.api.nvim_set_keymap("n", "<space>wl", "<C-w>l", opts)  -- Go right

-- Splits
vim.api.nvim_set_keymap("n", "<space>wv", "<C-w>v", opts)  -- Vertical split
vim.api.nvim_set_keymap("n", "<space>ws", "<C-w>s", opts)  -- Horizontal split

-- Close
vim.api.nvim_set_keymap("n", "<space>wq", "<C-w>q", opts)  -- Close window
vim.api.nvim_set_keymap("n", "<space>wo", "<C-w>o", opts)  -- Close other windows

-- Resize
vim.api.nvim_set_keymap("n", "<space>w=", "<C-w>=", opts)  -- Equalize sizes
vim.api.nvim_set_keymap("n", "<space>w+", "<C-w>+", opts)  -- Increase height
vim.api.nvim_set_keymap("n", "<space>w-", "<C-w>-", opts)  -- Decrease height
vim.api.nvim_set_keymap("n", "<space>w>", "<C-w>>", opts)  -- Increase width
vim.api.nvim_set_keymap("n", "<space>w<", "<C-w><", opts)  -- Decrease width

-- Other useful commands
vim.api.nvim_set_keymap("n", "<space>ww", "<C-w>w", opts)  -- Cycle windows
vim.api.nvim_set_keymap("n", "<space>wr", "<C-w>r", opts)  -- Rotate windows
vim.api.nvim_set_keymap("n", "<space>wx", "<C-w>x", opts)  -- Exchange windows
vim.api.nvim_set_keymap("n", "<space>wT", "<C-w>T", opts)  -- Move to new tab
