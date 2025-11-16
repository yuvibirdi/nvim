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

    -- Persistent cache setup
    local cache_dir = vim.fn.stdpath('cache') .. '/telescope'
    local cache_file = cache_dir .. '/home_files.json'
    local home_dir = vim.fn.expand('~')
    
    -- Create cache directory if it doesn't exist
    vim.fn.mkdir(cache_dir, 'p')

    local home_cache = {
      files = {},
      timestamp = 0,
    }

    -- Load cache from disk on startup
    local function load_cache()
      local file = io.open(cache_file, 'r')
      if file then
        local content = file:read('*a')
        file:close()
        local ok, data = pcall(vim.json.decode, content)
        if ok and data then
          home_cache = data
          print('Telescope: Loaded ' .. #home_cache.files .. ' cached files')
        end
      end
    end

    -- Save cache to disk
    local function save_cache()
      local file = io.open(cache_file, 'w')
      if file then
        file:write(vim.json.encode(home_cache))
        file:close()
        print('Telescope: Saved ' .. #home_cache.files .. ' files to cache')
      end
    end

    -- Build cache in background
    local function build_cache()
      print('Telescope: Building home directory cache...')
      
      local find_cmd
      if vim.fn.executable('fd') == 1 then
        find_cmd = string.format(
          'fd --type f --hidden --absolute-path --max-depth 6 ' ..
          '--exclude .git --exclude node_modules --exclude Library ' ..
          '--exclude .cache --exclude .cargo --exclude .npm --exclude .Trash ' ..
          '--exclude .local/share --exclude .mozilla --exclude .vscode ' ..
          '--exclude Downloads --exclude Movies --exclude Music --exclude Pictures ' ..
          '--exclude Documents . %s 2>/dev/null',
          home_dir
        )
      elseif vim.fn.executable('rg') == 1 then
        find_cmd = string.format(
          'rg --files --hidden --follow --glob "!.git/*" %s 2>/dev/null',
          home_dir
        )
      else
        print('Telescope: ERROR - Neither fd nor rg found!')
        return
      end

      vim.fn.jobstart(find_cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
          if data then
            local files = {}
            for _, line in ipairs(data) do
              if line ~= '' then
                table.insert(files, line)
              end
            end
            
            home_cache.files = files
            home_cache.timestamp = os.time()
            save_cache()
          end
        end,
        on_exit = function()
          print('Telescope: Cache built with ' .. #home_cache.files .. ' files')
        end,
      })
    end

    -- Load cache on startup
    load_cache()
    
    -- Build cache in background on startup (after 2 seconds)
    vim.defer_fn(function()
      build_cache()
    end, 2000)

    -- Telescope setup
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
          'Library/.*',
          '%.cache/.*',
        },
        path_display = function(opts, path)
          if path:sub(1, #home_dir) == home_dir then
            return '~' .. path:sub(#home_dir + 1)
          end
          return path
        end,
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

    -- Custom cached finder
    local function find_files_cached()
      if #home_cache.files > 0 then
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values

        pickers.new({}, {
          prompt_title = 'Find Files (cached)',
          finder = finders.new_table({
            results = home_cache.files,
            entry_maker = function(entry)
              local display_path = entry
              if entry:sub(1, #home_dir) == home_dir then
                display_path = '~' .. entry:sub(#home_dir + 1)
              end
              return {
                value = entry,
                display = display_path,
                ordinal = entry,
                path = entry,
              }
            end,
          }),
          sorter = conf.file_sorter({}),
          previewer = conf.file_previewer({}),
        }):find()
      else
        -- Fallback to regular find_files
        builtin.find_files()
      end
    end

    -- Try git files first, fallback to cached
    local function project_files()
      local ok = pcall(builtin.git_files, { show_untracked = true })
      if not ok then
        find_files_cached()
      end
    end

    -- Commands
    vim.api.nvim_create_user_command('TelescopeRebuildCache', function()
      build_cache()
    end, { desc = 'Rebuild Telescope cache' })

    vim.api.nvim_create_user_command('TelescopeClearCache', function()
      home_cache = { files = {}, timestamp = 0 }
      os.remove(cache_file)
      print('Telescope: Cache cleared')
    end, { desc = 'Clear Telescope cache' })

    -- Keymaps
    local opts = { noremap = true, silent = true }
    
    -- File finding
    vim.keymap.set('n', '<leader>ff', project_files, { desc = 'Find Files' })
    vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent Files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Grep Files' })
    
    -- Buffer management
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'List Buffers' })
    
    -- Git
    vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Git Commits' })
    vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Git Status' })
  end,
}
