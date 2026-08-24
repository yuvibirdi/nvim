local is_linux = vim.uv.os_uname().sysname == 'Linux'

return {
  'ibhagwan/fzf-lua',
  dependencies = {
    {
      'junegunn/fzf',
      build = './install --bin',
      cond = is_linux,
    },
  },
  keys = {
    {
      '<leader>ff',
      function()
        local fzf = require('fzf-lua')
        local cwd = vim.uv.cwd()
        local git_root = vim.fs.root(cwd, '.git')

        if git_root then
          fzf.git_files({
            cwd = git_root,
            cmd = 'git ls-files --cached --others --exclude-standard',
            file_icons = false,
            git_icons = false,
            previewer = false,
          })
        else
          fzf.files({
            cwd = cwd,
            cmd = "rg --files --color=never --glob '!node_modules'",
            file_icons = false,
            previewer = false,
          })
        end
      end,
      desc = 'Find Files',
    },
  },
  opts = is_linux and {
    fzf_bin = vim.fn.stdpath('data') .. '/lazy/fzf/bin/fzf',
  } or {},
}
