-- Simple toggleterm-based compiler for competitive programming
return {
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup({
        size = 20,
        direction = 'horizontal',
        close_on_exit = false,
        persist_mode = true,
      })

      local Terminal = require('toggleterm.terminal').Terminal
      local compile_term = Terminal:new({
        direction = 'horizontal',
        close_on_exit = false,
        hidden = true,
        display_name = 'Compile',
      })

      local function detect_cpp_compiler()
        local prefer = { 'g++-15', 'g++-14', 'g++-13', 'g++-12', 'g++-11', 'g++-10', 'g++-9', 'g++' }
        for _, bin in ipairs(prefer) do
          if vim.fn.executable(bin) == 1 then
            return bin
          end
        end
        return 'g++'
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

      local function build_c_flags()
        return table.concat({ '-std=c11', '-O2', '-Wall', '-Wextra', '-g' }, ' ')
      end

      local function ensure_input_file(dir)
        local input_path = dir .. '/input.txt'
        if vim.fn.filereadable(input_path) == 0 then
          vim.fn.writefile({}, input_path)
        end
        return input_path
      end

      local function send_to_terminal(cmd)
        compile_term:open()
        compile_term:send(cmd .. '\n', true)
      end

      local function compile_current_file()
        local filetype = vim.bo.filetype
        local filepath = vim.fn.expand('%:p')
        if filepath == '' then
          vim.notify('Save the file before compiling.', vim.log.levels.WARN)
          return
        end

        local filename = vim.fn.expand('%:t:r')
        local dir = vim.fn.expand('%:p:h')
        local input_path = ensure_input_file(dir)

        local shell_dir = vim.fn.shellescape(dir)
        local shell_src = vim.fn.shellescape(filepath)
        local shell_bin = vim.fn.shellescape(filename)
        local shell_input = vim.fn.shellescape(input_path)

        local compile_cmd
        if filetype == 'cpp' or filetype == 'cxx' then
          compile_cmd = string.format('%s %s %s -o %s', detect_cpp_compiler(), build_cpp_flags(), shell_src, shell_bin)
        elseif filetype == 'c' then
          compile_cmd = string.format('%s %s %s -o %s', detect_c_compiler(), build_c_flags(), shell_src, shell_bin)
        elseif filetype == 'tex' then
          compile_cmd = string.format('pdflatex -interaction=nonstopmode %s', shell_src)
        elseif filetype == 'markdown' or filetype == 'md' then
          compile_cmd = string.format('pandoc %s -o %s.pdf', shell_src, shell_bin)
        else
          vim.notify('No compile command for filetype: ' .. filetype, vim.log.levels.WARN)
          return
        end

        local run_cmd
        if filetype == 'cpp' or filetype == 'cxx' or filetype == 'c' then
          run_cmd = string.format('./%s < %s', shell_bin, shell_input)
        end

        local full_cmd
        if run_cmd then
          full_cmd = string.format('cd %s && %s && %s', shell_dir, compile_cmd, run_cmd)
        else
          full_cmd = string.format('cd %s && %s', shell_dir, compile_cmd)
        end

        send_to_terminal(full_cmd)
      end

      vim.keymap.set('n', '<leader>cc', compile_current_file, { desc = 'Compile current file' })
      vim.keymap.set('n', '<leader>v', function()
        compile_term:toggle()
      end, { desc = 'Toggle compile terminal' })
    end,
  },
}
