return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
  },
  config = function()
    local telescope = require('telescope')
    local builtin = require('telescope.builtin')
    local actions = require('telescope.actions')

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<Esc>"] = actions.close,
          },
        },
        file_ignore_patterns = {
          '%.git/.*',
          'node_modules/.*',
          '%.DS_Store',
        },
        layout_config = {
          horizontal = { preview_width = 0.6 },
          prompt_position = "top",
        },
        sorting_strategy = "ascending",
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        }
      },
    })

    telescope.load_extension('fzf')

    local function project_files()
      local ok = pcall(builtin.git_files, { show_untracked = true })
      if not ok then
        builtin.find_files()
      end
    end

    vim.keymap.set('n', '<leader>ff', project_files, { desc = 'Find Files' })
    vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent Files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Grep Files' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'List Buffers' })
    vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git Commits' })
    vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git Status' })
  end,
}
