-- Keybindings
-- A helper function to make setting keymaps easier
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- # Requirement 2: IBuffer-like system
-- <leader>bi -> "buffer index" (shows the list)
map("n", "<leader>bi", function()
  require("telescope.builtin").buffers()
end, { desc = "Find Buffer (IBuffer)" })

-- <leader>bn -> "buffer next"
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Buffer Next" })

-- <leader>bp -> "buffer previous"
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Buffer Previous" })


-- # Bonus: Project Switching
-- A map for your new project.nvim plugin
map("n", "<leader>fp", function()
  require("telescope").extensions.projects.projects()
end, { desc = "Find Projects" })
