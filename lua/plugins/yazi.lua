---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  version = "*", -- use the latest stable version
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      "<leader>dd",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      -- Open in the current working directory
      "<leader>dw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    {
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  ---@type YaziConfig | {}
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = true,
    keymaps = {
      show_help = "<f1>",
    },
    hooks = {
      yazi_closed_successfully = function(chosen_file, config, state)
        if chosen_file then
          local dir = vim.fn.fnamemodify(chosen_file, ":h")
          vim.cmd("cd " .. dir)
          vim.notify("Changed directory to: " .. dir, vim.log.levels.INFO)
        end
      end,
    },
  },
  -- 👇 if you use `open_for_directories=true`, this is recommended
  init = function()
    -- mark netrw as loaded so it's not loaded at all.
    --
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    vim.g.loaded_netrwPlugin = 1

    -- ensure a locally installed yazi (e.g. ~/.local/bin/yazi) is discoverable
    local local_bin = vim.fn.expand("~/.local/bin")
    if local_bin ~= "" then
      if vim.fn.isdirectory(local_bin) == 0 then
        vim.fn.mkdir(local_bin, 'p')
      end
      local current_path = vim.env.PATH or ""
      if not current_path:match(vim.pesc(local_bin)) then
        vim.env.PATH = local_bin .. ":" .. current_path
      end
    end
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local arg = vim.fn.argv(0)
        if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
          vim.cmd("cd " .. arg)
          vim.defer_fn(function()
            vim.cmd("Yazi")
          end, 10)
        end
      end,
    })
  end,
}
