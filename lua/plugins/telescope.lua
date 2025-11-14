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

    -- Cache for directory file listings
    local dir_cache = {}
    local cache_ttl = 300 -- 5 minutes in seconds

    local function get_cache_key()
      return vim.fn.getcwd()
    end

    local function is_cache_valid(cache_entry)
      if not cache_entry then return false end
      local age = os.time() - cache_entry.timestamp
      return age < cache_ttl
    end

    local function has_executable(cmd)
      return vim.fn.executable(cmd) == 1
    end

    local find_command
    if has_executable('fd') then
      find_command = {
        'fd',
        '--type', 'f',
        '--hidden',
        '--absolute-path',
        '--max-depth', '6',
        '--exclude', '.git',
        '--exclude', 'node_modules',
        '--exclude', 'Library',
        '--exclude', '.cache',
        '--exclude', '.cargo',
        '--exclude', '.npm',
        '--exclude', '.Trash',
        '--exclude', '.local/share',
        '--exclude', '.mozilla',
        '--exclude', '.vscode',
        '--exclude', 'Downloads',
        '--exclude', 'Movies',
        '--exclude', 'Music',
        '--exclude', 'Pictures',
        '--exclude', 'Documents',
      }
      print("Telescope: Using fd for find_command")
    elseif has_executable('rg') then
      find_command = { 'rg', '--files', '--hidden', '--follow', '--glob', '!.git/*' }
      print("Telescope: Using rg for find_command")
    else
      print("Telescope: WARNING - Neither fd nor rg found, will use fallback")
    end

    if find_command then
      print("Telescope: find_command = " .. vim.inspect(find_command))
    end

    telescope.setup({
      defaults = {
        file_ignore_patterns = {
          
          '%.git/.*',
          'node_modules/.*',
          '%.DS_Store',
          'imessage_export/.*',
          'Library/.*',
        },
        path_display = function(opts, path)
          local home = vim.fn.expand('~')
          if path:sub(1, #home) == home then
            return '~' .. path:sub(#home + 1)
          end
          return path
        end,
        prompt_prefix = '>> ',
      },
      pickers = {
        find_files = {
          find_command = find_command,
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        }
      },
      sorting_strategy = "ascending",
      layout_config = {
        prompt_position = "top",
      },
    })
    
    telescope.load_extension('fzf')
    
    local function cached_find_files()
      local cache_key = get_cache_key()
      local cache_entry = dir_cache[cache_key]

      if is_cache_valid(cache_entry) then
        print("Telescope: Using cached results for " .. cache_key .. " (" .. #cache_entry.files .. " files)")
        local pickers = require('telescope.pickers')
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values

        pickers.new({}, {
          prompt_title = 'Find Files (cached)',
          finder = finders.new_table({
            results = cache_entry.files,
            entry_maker = function(entry)
              local display_path = entry
              local home = vim.fn.expand('~')
              if entry:sub(1, #home) == home then
                display_path = '~' .. entry:sub(#home + 1)
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
        print("Telescope: Building cache for " .. cache_key)
        builtin.find_files({ find_command = find_command })

        -- Build cache in background
        vim.defer_fn(function()
          local handle = io.popen(table.concat(find_command, ' ') .. ' 2>/dev/null')
          if handle then
            local result = handle:read('*a')
            handle:close()

            local files = {}
            for line in result:gmatch('[^\n]+') do
              table.insert(files, line)
            end

            dir_cache[cache_key] = {
              files = files,
              timestamp = os.time(),
            }

            print("Telescope: Cached " .. #files .. " files for " .. cache_key)
          end
        end, 100)
      end
    end

    local function project_files()
      local ok = pcall(builtin.git_files, { show_untracked = true })
      if not ok then
        cached_find_files()
      end
    end

    -- Manual cache invalidation command
    vim.api.nvim_create_user_command('TelescopeClearCache', function()
      dir_cache = {}
      print('Telescope cache cleared')
    end, {})

    vim.keymap.set('n', '<leader>ff', project_files, { desc = 'Find project files' })
  end,
}
