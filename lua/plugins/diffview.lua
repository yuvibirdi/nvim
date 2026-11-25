return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    {
      "<leader>gd",
      function()
        -- Toggle: open the diff of the working tree, or close it if already open.
        if next(require("diffview.lib").views) == nil then
          vim.cmd("DiffviewOpen")
        else
          vim.cmd("DiffviewClose")
        end
      end,
      desc = "Diff View (toggle)",
    },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current file)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "File History (branch)" },
  },
  opts = {
    enhanced_diff_hl = true,
    hooks = {
      diff_buf_win_enter = function(bufnr, winid)
        vim.wo[winid].foldenable = false
        vim.keymap.set("n", "<C-j>", function() vim.cmd("normal! ]c") end, { buffer = bufnr, desc = "Next change" })
        vim.keymap.set("n", "<C-k>", function() vim.cmd("normal! [c") end, { buffer = bufnr, desc = "Prev change" })
      end,
    },
  },
}
