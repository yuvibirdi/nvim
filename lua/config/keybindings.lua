-- Keybindings
-- A helper function to make setting keymaps easier
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end



-- Our base options
local base_opts = { noremap = true, silent = true }

-- Quick buffer controls without extra plugins
vim.keymap.set("n", "<leader>bk", "<cmd>bdelete<cr>", vim.tbl_extend("force", base_opts, { desc = "Kill Buffer" }))
vim.keymap.set("n", "<leader>bo", "<cmd>%bd|e#|bd#<cr>", vim.tbl_extend("force", base_opts, { desc = "Delete Other Buffers" }))
-- Navigation
vim.keymap.set("n", "<space>wh", "<C-w>h", vim.tbl_extend("force", base_opts, { desc = "Window Go Left" }))
vim.keymap.set("n", "<space>wj", "<C-w>j", vim.tbl_extend("force", base_opts, { desc = "Window Go Down" }))
vim.keymap.set("n", "<space>wk", "<C-w>k", vim.tbl_extend("force", base_opts, { desc = "Window Go Up" }))
vim.keymap.set("n", "<space>wl", "<C-w>l", vim.tbl_extend("force", base_opts, { desc = "Window Go Right" }))

-- Splits
vim.keymap.set("n", "<space>wv", "<C-w>v", vim.tbl_extend("force", base_opts, { desc = "Vertical Split" }))
vim.keymap.set("n", "<space>ws", "<C-w>s", vim.tbl_extend("force", base_opts, { desc = "Horizontal Split" }))

-- Close
vim.keymap.set("n", "<space>wq", "<C-w>q", vim.tbl_extend("force", base_opts, { desc = "Close Window" }))
vim.keymap.set("n", "<space>wo", "<C-w>o", vim.tbl_extend("force", base_opts, { desc = "Close Other Windows" }))

-- Resize
vim.keymap.set("n", "<space>w=", "<C-w>=", vim.tbl_extend("force", base_opts, { desc = "Equalize Sizes" }))
vim.keymap.set("n", "<space>w+", "<C-w>+", vim.tbl_extend("force", base_opts, { desc = "Increase Height" }))
vim.keymap.set("n", "<space>w-", "<C-w>-", vim.tbl_extend("force", base_opts, { desc = "Decrease Height" }))
vim.keymap.set("n", "<space>w>", "<C-w>>", vim.tbl_extend("force", base_opts, { desc = "Increase Width" }))
vim.keymap.set("n", "<space>w<", "<C-w><", vim.tbl_extend("force", base_opts, { desc = "Decrease Width" }))

-- Other useful commands
vim.keymap.set("n", "<space>ww", "<C-w>w", vim.tbl_extend("force", base_opts, { desc = "Cycle Windows" }))
vim.keymap.set("n", "<space>wr", "<C-w>r", vim.tbl_extend("force", base_opts, { desc = "Rotate Windows" }))
vim.keymap.set("n", "<space>wx", "<C-w>x", vim.tbl_extend("force", base_opts, { desc = "Exchange Windows" }))
vim.keymap.set("n", "<space>wT", "<C-w>T", vim.tbl_extend("force", base_opts, { desc = "Move to New Tab" }))
