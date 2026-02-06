return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } }, -- optional: you can also use fzf-lua, snacks, mini-pick instead.
    },
    ft = "python", -- Load when opening Python files
    config = function()
      local conda_base = vim.g.conda_base
      local search_config = {}

      if conda_base then
        search_config.conda_envs = {
          command = "fd 'bin/python$' " .. conda_base .. "/envs --full-path --color never",
          type = "anaconda",
        }
      end

      require("venv-selector").setup({
        search = search_config,
        options = { debug = true },
      })
    end,
  },
}
