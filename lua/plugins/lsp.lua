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

      local function linux_clangd_config()
        if vim.loop.os_uname().sysname ~= 'Linux' then
          return nil
        end

        local function first_line(cmd)
          local output = vim.fn.systemlist(cmd)
          if type(output) == 'table' and output[1] and output[1] ~= '' then
            return vim.fn.trim(output[1])
          end
        end

        local function add_isystem(list, path)
          if path and path ~= '' and vim.fn.isdirectory(path) == 1 then
            table.insert(list, '-isystem')
            table.insert(list, path)
          end
        end

        local gcc_version = first_line('g++ -dumpfullversion -dumpversion') or first_line('g++ -dumpversion')
        local multiarch = first_line('g++ -print-multiarch') or first_line('g++ -dumpmachine')
        local gcc_include = first_line('g++ -print-file-name=include')

        local fallback_flags = {
          '-std=gnu++20',
          '-Wall',
          '-Wextra',
          '-Wconversion',
          '-Wshadow',
          '-DLOCAL',
        }

        add_isystem(fallback_flags, '/usr/include')
        add_isystem(fallback_flags, '/usr/local/include')

        if gcc_include then
          add_isystem(fallback_flags, gcc_include)
        end

        if gcc_version then
          add_isystem(fallback_flags, string.format('/usr/include/c++/%s', gcc_version))
          if multiarch and multiarch ~= '' then
            add_isystem(fallback_flags, string.format('/usr/include/%s/c++/%s', multiarch, gcc_version))
            add_isystem(fallback_flags, string.format('/usr/lib/gcc/%s/%s/include', multiarch, gcc_version))
            add_isystem(fallback_flags, string.format('/usr/lib/gcc/%s/%s/include-fixed', multiarch, gcc_version))
          end
        end

        return {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
            '--header-insertion=never',
            '--query-driver=/usr/bin/g++*,/usr/bin/clang++*',
          },
          init_options = {
            fallbackFlags = fallback_flags,
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        }
      end

      local function default_clangd_config()
        return {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
          init_options = {
            fallbackFlags = { '-std=gnu++20' },
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        }
      end

      local clangd_config = linux_clangd_config() or default_clangd_config()

      -- Configure LSP servers
      local servers = {
        { 'clangd', clangd_config },
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
