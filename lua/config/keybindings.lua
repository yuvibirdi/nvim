-- Keybindings
-- A helper function to make setting keymaps easier
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Quick buffer controls without extra plugins
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Buffer Next" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Buffer Previous" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
