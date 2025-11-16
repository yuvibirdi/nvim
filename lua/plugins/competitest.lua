return {
  'xeluxee/competitest.nvim',
  dependencies = 'MunifTanjim/nui.nvim',
  config = function() require('competitest').setup {
    runner_ui = {
      interface = "split"},
      compile_command = {
        cpp = { exec = "g++", args = { "-D_GLIBCXX_DEBUG -D_GLIBCXX_DEBUG_PEDANTIC -std=c++17 -I/usr/local/include/ -Wall -Wextra -Wshadow -Wconversion -Wfloat-equal -Wduplicated-cond -Wlogical-op -DLOCAL -Wl,-stack_size,0x10000000 -g -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX15.sdk", "$(FNAME)", "-o", "$(FNOEXT)" } },
      },
    } end,
  }
