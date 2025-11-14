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
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
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

    local function ensure_yazi_binary()
      if vim.fn.executable('yazi') == 1 then
        return
      end

      local uname = vim.loop.os_uname().sysname
      if uname ~= 'Linux' then
        vim.notify('Yazi binary missing and auto-install only runs on Linux', vim.log.levels.WARN)
        return
      end

      local bin_dir = local_bin
      if vim.fn.isdirectory(bin_dir) == 0 then
        vim.fn.mkdir(bin_dir, 'p')
      end

      local download_url = 'https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.tar.xz'
      local install_cmd = table.concat({
        'set -e',
        'tmpdir=$(mktemp -d)',
        'trap "rm -rf \"$tmpdir\"" EXIT',
        'curl -fsSL ' .. download_url .. ' -o "$tmpdir/yazi.tar.xz"',
        'tar -xJf "$tmpdir/yazi.tar.xz" -C "$tmpdir"',
        'cp "$tmpdir"/yazi-x86_64-unknown-linux-gnu/yazi ' .. vim.fn.shellescape(bin_dir .. '/yazi'),
        'chmod +x ' .. vim.fn.shellescape(bin_dir .. '/yazi'),
      }, ' && ')

      vim.notify('Installing Yazi locally (no root required)...', vim.log.levels.INFO)
      vim.fn.system({ 'sh', '-c', install_cmd })
      if vim.v.shell_error ~= 0 then
        vim.notify('Failed to install Yazi automatically. Please install it manually.', vim.log.levels.ERROR)
      else
        vim.notify('Yazi installed to ' .. bin_dir .. '/yazi', vim.log.levels.INFO)
      end
    end

    ensure_yazi_binary()

    if local_bin ~= "" and vim.fn.isdirectory(local_bin) == 1 then
      local current_path = vim.env.PATH or ""
      if not current_path:match(vim.pesc(local_bin)) then
        vim.env.PATH = local_bin .. ":" .. current_path
      end
    end
  end,
}
