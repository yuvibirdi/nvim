return {
  "echasnovski/mini.map",
  version = false,
  event = "VeryLazy",
  config = function()
    local map = require("mini.map")
    map.setup({
      integrations = {
        map.gen_integration.gitsigns(),
        map.gen_integration.diagnostic(),
      },
      symbols = {
        encode = map.gen_encode_symbols.dot("4x2"),
      },
      window = {
        width = 10,
        winblend = 25,
        show_integration_count = false,
      },
    })
    map.open()
    vim.keymap.set("n", "<leader>mm", map.toggle, { desc = "Toggle Minimap" })
  end,
}
