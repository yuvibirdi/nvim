return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Detect OS
      local is_mac = vim.fn.has("macunix") == 1
      local is_linux = vim.fn.has("unix") == 1 and not is_mac

      -- Platform-specific clangd args
      local clangd_cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      }

      local init_opts = {}

      if is_linux then
        -- Ubuntu/Linux: Query g++ for system headers
        table.insert(clangd_cmd, "--query-driver=/usr/bin/g++,/usr/bin/gcc,/usr/bin/c++")

        -- Fallback flags for Ubuntu - explicitly include the g++ headers
        init_opts.fallbackFlags = {
          "-std=c++17",
          "-stdlib=libstdc++",
          "-isystem/usr/include/c++/13",
          "-isystem/usr/include/x86_64-linux-gnu/c++/13",
          "-isystem/usr/lib/gcc/x86_64-linux-gnu/13/include",
        }
      elseif is_mac then
        table.insert(clangd_cmd, "--query-driver=/opt/homebrew/bin/g++-15")
        -- local xcode_sdk = vim.fn.trim(vim.fn.system("xcrun --show-sdk-path"))
        -- if vim.v.shell_error == 0 and xcode_sdk ~= "" then  -- FIXED TYPO HERE
          init_opts.fallbackFlags = {
            "-std=c++17",
        --     "-isystem" .. xcode_sdk .. "/usr/include/c++/v1",
        --     "-isystem" .. xcode_sdk .. "/usr/include",
            "-isystem/opt/homebrew/include/c++/15/aarch64-apple-darwin24",
            "-D_GLIBCXX_HOSTED=1"
        --     "-isysroot" .. xcode_sdk,
        --     "-std=c++17",
          }
        -- end
      end

      vim.lsp.config('clangd', {
        cmd = clangd_cmd,
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          ".git",
        },
        init_options = init_opts,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.enable('clangd')

      -- LSP keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { noremap = true, silent = true }
          local bufnr = ev.buf

          -- Navigation
          vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)

          -- Actions
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)

          -- Diagnostics (ERRORS!)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

          -- Signature help
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
        end,
      })
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      -- CRITICAL: Set completeopt BEFORE cmp.setup()
      vim.opt.completeopt = { "menu", "menuone", "noselect" }
      
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        
        -- ADD THIS: Configure completion behavior
        completion = {
          completeopt = "menu,menuone,noselect",
          keyword_length = 1,  -- Start suggesting after 1 character
        },
        
        -- ADD THIS: Performance settings
        performance = {
          debounce = 150,
          throttle = 60,
        },
        
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },  -- ADD PRIORITY
          { name = "luasnip", priority = 750 },
        }, {
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
        
        -- ADD THIS: Formatting to see where completions come from
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      })
      
      -- ADD THIS: Set up LSP-specific completion for C++
      cmp.setup.filetype({ "cpp", "c" }, {
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000, keyword_length = 1 },
          { name = "luasnip", priority = 750 },
        }, {
          { name = "buffer", priority = 500 },
        }),
      })
    end,
  },
}
