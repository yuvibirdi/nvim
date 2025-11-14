-- Fast compilation system for various file types
return {
  {
    'stevearc/overseer.nvim',
    opts = {},
    config = function()
      local overseer = require('overseer')

      overseer.setup({
        templates = { 'builtin' },
        strategy = {
          "toggleterm",
          direction = "horizontal",
          open_on_start = true,
        },
      })

      -- Quick compile commands based on filetype
      local function compile_current_file()
        local filetype = vim.bo.filetype
        local filepath = vim.fn.expand('%:p')
        local filename = vim.fn.expand('%:t:r')
        local dir = vim.fn.expand('%:p:h')

        local commands = {
          cpp = string.format('cd %s && g++-15 -D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -std=c++17 -I/usr/local/include/ -Wall -Wextra -Wshadow -Wconversion -Wfloat-equal -Wduplicated-cond -Wlogical-op -DLOCAL -Wl,-stack_size,0x10000000 -g  %s -o %s && echo "Compiled: %s"',
            vim.fn.shellescape(dir),
            vim.fn.shellescape(filepath),
            vim.fn.shellescape(filename),
            filename),
          c = string.format('cd %s && gcc -std=c11 -Wall -O2 %s -o %s && echo "Compiled: %s"',
            vim.fn.shellescape(dir),
            vim.fn.shellescape(filepath),
            vim.fn.shellescape(filename),
            filename),
          tex = string.format('cd %s && pdflatex -interaction=nonstopmode %s',
            vim.fn.shellescape(dir),
            vim.fn.shellescape(filepath)),
          markdown = string.format('cd %s && pandoc %s -o %s.pdf',
            vim.fn.shellescape(dir),
            vim.fn.shellescape(filepath),
            vim.fn.shellescape(filename)),
        }

        local cmd = commands[filetype]
        if cmd then
          overseer.run_template({ name = 'shell', params = { cmd = cmd } })
        else
          vim.notify('No compile command for filetype: ' .. filetype, vim.log.levels.WARN)
        end
      end

      -- Build entire project (looks for Makefile, CMakeLists.txt, etc.)
      local function build_project()
        local dir = vim.fn.getcwd()

        -- Check for various build systems
        if vim.fn.filereadable('Makefile') == 1 then
          overseer.run_template({ name = 'shell', params = { cmd = 'make' } })
        elseif vim.fn.filereadable('CMakeLists.txt') == 1 then
          overseer.run_template({
            name = 'shell',
            params = { cmd = 'cmake -B build && cmake --build build' }
          })
        elseif vim.fn.filereadable('build.sh') == 1 then
          overseer.run_template({ name = 'shell', params = { cmd = './build.sh' } })
        elseif vim.fn.filereadable('package.json') == 1 then
          overseer.run_template({ name = 'shell', params = { cmd = 'npm run build' } })
        elseif vim.fn.filereadable('Cargo.toml') == 1 then
          overseer.run_template({ name = 'shell', params = { cmd = 'cargo build' } })
        else
          vim.notify('No build system found', vim.log.levels.WARN)
        end
      end

      -- Keybindings
      vim.keymap.set('n', '<leader>cc', compile_current_file, { desc = 'Compile Current File' })
      vim.keymap.set('n', '<leader>cb', build_project, { desc = 'Build Project' })
      vim.keymap.set('n', '<leader>cr', '<cmd>OverseerRun<cr>', { desc = 'Run Task' })
      vim.keymap.set('n', '<leader>ct', '<cmd>OverseerToggle<cr>', { desc = 'Toggle Task List' })
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      direction = 'horizontal',
      close_on_exit = false,
    },
  },
}
