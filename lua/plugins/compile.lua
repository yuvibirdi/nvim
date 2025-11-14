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

      -- Resolve toolchain per platform
      local function detect_cpp_compiler()
        local prefer = { 'g++-15', 'g++-14', 'g++-13', 'g++-12', 'g++-11', 'g++-10', 'g++-9', 'g++' }
        for _, bin in ipairs(prefer) do
          if vim.fn.executable(bin) == 1 then
            return bin
          end
        end
        return 'g++'
      end

      local function build_cpp_flags()
        local uname = vim.loop.os_uname().sysname
        if uname == 'Darwin' then
          return table.concat({
            '-D_GLIBCXX_DEBUG',
            '-D_GLIBCXX_DEBUG_PEDANTIC',
            '-std=gnu++20',
            '-I/usr/local/include/',
            '-Wall', '-Wextra', '-Wshadow', '-Wconversion', '-Wfloat-equal', '-Wduplicated-cond', '-Wlogical-op',
            '-DLOCAL',
            '-Wl,-stack_size,0x10000000',
            '-g',
          }, ' ')
        else
          return table.concat({
            '-std=gnu++20',
            '-O2',
            '-pipe',
            '-Wall', '-Wextra', '-Wshadow', '-Wconversion',
            '-DLOCAL',
            '-g',
          }, ' ')
        end
      end

      local function detect_c_compiler()
        local prefer = { 'gcc-14', 'gcc-13', 'gcc-12', 'gcc-11', 'gcc-10', 'gcc-9', 'gcc' }
        for _, bin in ipairs(prefer) do
          if vim.fn.executable(bin) == 1 then
            return bin
          end
        end
        return 'gcc'
      end

      local function build_c_flags()
        return table.concat({ '-std=c11', '-O2', '-Wall', '-Wextra', '-g' }, ' ')
      end

      -- Quick compile commands based on filetype
      local function compile_current_file()
        local filetype = vim.bo.filetype
        local filepath = vim.fn.expand('%:p')
        local filename = vim.fn.expand('%:t:r')
        local dir = vim.fn.expand('%:p:h')
        local cwd = vim.fn.shellescape(dir)
        local path = vim.fn.shellescape(filepath)
        local output = vim.fn.shellescape(filename)

        local cmd
        if filetype == 'cpp' or filetype == 'cxx' then
          cmd = string.format('cd %s && %s %s %s -o %s && echo "Compiled: %s"',
            cwd,
            detect_cpp_compiler(),
            build_cpp_flags(),
            path,
            output,
            filename)
        elseif filetype == 'c' then
          cmd = string.format('cd %s && %s %s %s -o %s && echo "Compiled: %s"',
            cwd,
            detect_c_compiler(),
            build_c_flags(),
            path,
            output,
            filename)
        elseif filetype == 'tex' then
          cmd = string.format('cd %s && pdflatex -interaction=nonstopmode %s', cwd, path)
        elseif filetype == 'markdown' or filetype == 'md' then
          cmd = string.format('cd %s && pandoc %s -o %s.pdf', cwd, path, output)
        end

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
