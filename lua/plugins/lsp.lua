-- Fast and feature-rich LSP configuration (Neovim 0.11+ native API)
return {
  -- LSP installer (optional but convenient)
  {
    'williamboman/mason.nvim',
    config = true,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'clangd', 'texlab', 'pyright', 'rust_analyzer', 'lua_ls' },
      })
    end,
  },

  -- Useful status updates for LSP
  { 'j-hui/fidget.nvim', opts = {} },

  -- LSP Configuration using native Neovim 0.11+ API
  {
    'neovim/nvim-lspconfig', -- Still provides server configs
    config = function()
      -- Global LSP settings
      vim.lsp.config('*', {
        root_markers = { '.git', '.hg' },
      })

      -- Diagnostics: prefer floats over noisy signs/virtual text
      vim.diagnostic.config({
        float = { border = 'rounded', source = 'if_many' },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '!!',
            [vim.diagnostic.severity.WARN] = '??',
            [vim.diagnostic.severity.INFO] = 'ii',
            [vim.diagnostic.severity.HINT] = '..',
          },
        },
        virtual_text = false,
      })

      local function trim(str)
        return (str or ''):gsub('^%s+', ''):gsub('%s+$', '')
      end

      local function linux_cpp_fallback_flags()
        if vim.loop.os_uname().sysname ~= 'Linux' then
          return nil
        end

        if vim.fn.executable('g++') == 0 then
          return { '-std=gnu++20' }
        end

        local version = trim(vim.fn.system('g++ -dumpfullversion 2>/dev/null'))
        if version == '' then
          version = trim(vim.fn.system('g++ -dumpversion'))
        end

        local target = trim(vim.fn.system('g++ -print-multiarch 2>/dev/null'))
        if target == '' then
          target = trim(vim.fn.system('g++ -dumpmachine'))
        end

        local function path_exists(path)
          return path ~= '' and vim.fn.isdirectory(path) == 1
        end

        local include_paths = {}
        local base = '/usr/include/c++/' .. version
        if path_exists(base) then table.insert(include_paths, base) end

        local target_base = string.format('/usr/include/%s/c++/%s', target, version)
        if path_exists(target_base) then table.insert(include_paths, target_base) end

        local gcc_include = string.format('/usr/lib/gcc/%s/%s/include', target, version)
        if path_exists(gcc_include) then table.insert(include_paths, gcc_include) end

        local gcc_fixed = string.format('/usr/lib/gcc/%s/%s/include-fixed', target, version)
        if path_exists(gcc_fixed) then table.insert(include_paths, gcc_fixed) end

        local fallback = { '-std=gnu++20', '-Wall', '-Wextra', '-Wconversion' }
        for _, path in ipairs(include_paths) do
          table.insert(fallback, '-isystem')
          table.insert(fallback, path)
        end

        return fallback
      end

      local linux_fallback_flags = linux_cpp_fallback_flags()

      -- Configure LSP servers
      local servers = {
        {
          'clangd',
          {
            cmd = {
              'clangd',
              '--background-index',
              '--clang-tidy',
              '--header-insertion=iwyu',
              '--completion-style=detailed',
              '--function-arg-placeholders',
              '--fallback-style=llvm',
            },
            init_options = {
                fallbackFlags = linux_fallback_flags or { '-std=gnu++20' },
              usePlaceholders = true,
              completeUnimported = true,
              clangdFileStatus = true,
            },
          },
        },
        {
          'texlab',
          {
            settings = {
              texlab = {
                build = {
                  executable = 'pdflatex',
                  args = { '-pdf', '-interaction=nonstopmode', '-synctex=1', '%f' },
                  onSave = true,
                },
                forwardSearch = {
                  executable = 'zathura',
                  args = { '--synctex-forward', '%l:1:%f', '%p' },
                },
                chktex = {
                  onOpenAndSave = true,
                  onEdit = false,
                },
              },
            },
          },
        },
        { 'pyright' },
        {
          'rust_analyzer',
          {
            settings = {
              ['rust-analyzer'] = {
                checkOnSave = {
                  command = 'clippy',
                },
              },
            },
          },
        },
        {
          'lua_ls',
          {
            settings = {
              Lua = {
                runtime = { version = 'LuaJIT' },
                workspace = {
                  checkThirdParty = false,
                  library = {
                    '${3rd}/luv/library',
                    unpack(vim.api.nvim_get_runtime_file('', true)),
                  },
                },
                completion = {
                  callSnippet = 'Replace',
                },
                diagnostics = { disable = { 'missing-fields' } },
              },
            },
          },
        },
      }

      -- Configure and enable each server
      for _, lsp in ipairs(servers) do
        local name, config = lsp[1], lsp[2]
        if config then
          vim.lsp.config(name, config)
        end
        vim.lsp.enable(name)
      end

      -- LSP keybindings (using LspAttach autocmd)
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
          end

          map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
          map('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          map('<leader>ds', vim.lsp.buf.document_symbol, '[D]ocument [S]ymbols')
          map('<leader>ws', vim.lsp.buf.workspace_symbol, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('[d', vim.diagnostic.goto_prev, 'Prev Diagnostic')
          map(']d', vim.diagnostic.goto_next, 'Next Diagnostic')
          map('<leader>e', vim.diagnostic.open_float, 'Explain Diagnostic')
          map('<leader>q', vim.diagnostic.setloclist, 'Diag Quickfix')

          -- Enable completion (native to Neovim 0.11+)
          if client and client.supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
          end

          -- Format on save
          if client and client.supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      })
    end,
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- LSP completion source
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
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
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete({}),
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
          { name = 'buffer', keyword_length = 3 },
        },
      })
    end,
  },
}
