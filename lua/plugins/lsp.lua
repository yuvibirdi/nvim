return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Treat CUDA sources/headers as the `cuda` filetype so clangd attaches.
      vim.filetype.add({
        extension = {
          cu = "cuda",
          cuh = "cuda",
        },
      })

      -- Python LSP (ruff - Rust-based)
      vim.lsp.config('ruff', {
        cmd = { "ruff", "server" },
        filetypes = { "python" },
        root_markers = {
          "pyproject.toml",
          "ruff.toml",
          ".ruff.toml",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          ".git",
        },
        settings = {
          ruff = {
            lint = { enable = true },
            format = { enable = true },
          },
        },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.enable('ruff')

      -- Zuban for Python autocomplete (Jedi successor, Rust-based)
      vim.lsp.config('zuban', {
        cmd = { "zuban", "server" },
        filetypes = { "python" },
        root_markers = {
          "pyproject.toml",
          "mypy.ini",
          "setup.py",
          "setup.cfg",
          "requirements.txt",
          ".git",
        },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.enable('zuban')

      -- C/C++/CUDA LSP (clangd — clangd is the CUDA language server)
      vim.lsp.config('clangd', {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          -- Let clangd interrogate nvcc + the host compiler so it can resolve
          -- CUDA and toolchain system headers for .cu/.cuh files (e.g. on Jetson).
          -- Nonexistent drivers (e.g. on macOS) are ignored.
          "--query-driver=/usr/local/cuda/bin/nvcc,/usr/bin/g++,/usr/bin/gcc,/usr/bin/clang*",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_markers = {
          "compile_commands.json",
          "compile_flags.txt",
          ".clangd",
          "CMakeLists.txt",
          "Makefile",
          ".git",
        },
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      vim.lsp.enable('clangd')

      -- LSP keybindings
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { noremap = true, silent = true }
          local bufnr = ev.buf

          vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)

          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)

          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
          vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

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
      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          completeopt = "menu,menuone,noselect",
          keyword_length = 1,
        },
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
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip", priority = 750 },
        }, {
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
        }),
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
    end,
  },
}
