require("config.options")

-- Async conda base lookup at startup (non-blocking)
vim.g.conda_base = nil
vim.fn.jobstart({ "conda", "info", "--base" }, {
  stdout_buffered = true,
  on_stdout = function(_, data)
    if data and data[1] and data[1] ~= "" then
      vim.g.conda_base = vim.trim(data[1])
    end
  end,
})

require("config.lazy")
require("config.keybindings")
