if vim.env.SSH_CONNECTION then
  vim.g.clipboard = 'osc52'
  vim.opt.clipboard = 'unnamedplus'
end

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- Auto-cd to the directory of the current file
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= "" and vim.fn.isdirectory(bufname) == 0 then
      local dir = vim.fn.fnamemodify(bufname, ":p:h")
      if vim.fn.isdirectory(dir) == 1 then
        vim.cmd.cd(dir)
      end
    end
  end,
})
