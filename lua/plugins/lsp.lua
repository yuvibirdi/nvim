-- Minimal, laser-focused C++ LSP stack tuned for Linux + clangd
return {
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'hrsh7th/cmp-nvim-lsp' },
    config = function()

      vim.diagnostic.config({
        float = { border = 'rounded', source = 'if_many' },
        severity_sort = true,
        virtual_text = false,
        signs = false,
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local function detect_compilers()
        local bins = { 'clang++', 'clang', 'g++', 'c++' }
        local seen = {}
        local paths = {}
        for _, bin in ipairs(bins) do
          local path = vim.fn.exepath(bin)
          if path ~= nil and path ~= '' and not seen[path] then
            table.insert(paths, path)
            seen[path] = true
          end
        end
        return paths
      end

      local function extract_include_dirs(output)
        local dirs = {}
        local capture = false
        for line in output:gmatch('[^\r\n]+') do
          if line:find('#include <...> search starts here:') then
            capture = true
          elseif capture then
            if line:find('End of search list.') then
              break
            end
            local dir = line:gsub('^%s+', ''):gsub('%s+$', '')
            if dir ~= '' then
              table.insert(dirs, dir)
            end
          end
        end
        return dirs
      end

      local fallback_flag_cache
      local function compute_fallback_flags()
        if fallback_flag_cache then
          return fallback_flag_cache
        end

        local flags = {
          '-std=gnu++20',
          '-Wall',
          '-Wextra',
          '-Wconversion',
          '-Wshadow',
          '-DLOCAL',
        }

        local compiler = detect_compilers()[1]
        if compiler then
          local ok, result = pcall(function()
            local exec = vim.system({ compiler, '-E', '-x', 'c++', '/dev/null', '-v' }, { text = true }):wait()
            local dump = table.concat({ exec.stdout or '', exec.stderr or '' }, '\n')
            return extract_include_dirs(dump)
          end)

          if ok and result then
            for _, dir in ipairs(result) do
              table.insert(flags, '-isystem')
              table.insert(flags, dir)
            end
          end
        end

        fallback_flag_cache = flags
        return flags
      end

      local drivers = {}
      for _, compiler in ipairs(detect_compilers()) do
        local dir = vim.fn.fnamemodify(compiler, ':h')
        if dir ~= '' then
          table.insert(drivers, dir .. '/clang*')
          table.insert(drivers, dir .. '/clang++*')
          table.insert(drivers, dir .. '/g++*')
        end
      end
      if #drivers == 0 then
        drivers = { '/usr/bin/clang*', '/usr/bin/clang++*', '/usr/bin/g++*' }
      end

      local clangd_cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--completion-style=detailed',
        '--fallback-style=llvm',
        '--header-insertion=never',
        '--log=error',
        '--pch-storage=disk',
        '--limit-references=5000',
        '--limit-results=500',
        '--query-driver=' .. table.concat(drivers, ','),
      }

      local function on_attach(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
        end

        map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
        map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
        map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('[d', vim.diagnostic.goto_prev, 'Prev Diagnostic')
        map(']d', vim.diagnostic.goto_next, 'Next Diagnostic')
        map('<leader>e', vim.diagnostic.open_float, 'Explain Diagnostic')

        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
          end,
        })
      end

      local function root_dir(fname)
        return vim.fs.root(fname, { 'compile_commands.json', '.clangd', '.git' })
          or vim.fs.dirname(fname)
      end

      vim.lsp.config('clangd', {
        cmd = clangd_cmd,
        capabilities = capabilities,
        on_attach = on_attach,
        init_options = {
          clangdFileStatus = true,
          fallbackFlags = compute_fallback_flags(),
        },
        filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
        root_dir = root_dir,
      })

      vim.lsp.enable('clangd')
    end,
  },

  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = 'menu,menuone,noinsert' },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-Space>'] = cmp.mapping.complete({}),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'buffer', keyword_length = 2 },
        },
      })
    end,
  },
}
