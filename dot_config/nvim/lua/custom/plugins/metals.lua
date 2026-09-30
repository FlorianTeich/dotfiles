local function gh(repo)
  return 'https://github.com/' .. repo
end

-- Install nvim-metals through Neovim's native package manager.
vim.pack.add {
  gh 'scalameta/nvim-metals',
}

-- Allow nvim-metals to display setup and error messages.
vim.opt_global.shortmess:remove 'F'

local metals = require 'metals'
local dap = require 'dap'

local metals_config = metals.bare_config()

-- Kickstart includes fidget.nvim for standard LSP progress messages.
metals_config.init_options.statusBarProvider = 'off'

-- Enable completion through kickstart's blink.cmp configuration.
metals_config.capabilities = require('blink.cmp').get_lsp_capabilities()

metals_config.settings = {
  showImplicitArguments = true,
  showInferredType = true,
  superMethodLensesEnabled = true,
}

-- Register the Scala debug adapter whenever Metals attaches.
metals_config.on_attach = function()
  metals.setup_dap()
end

-- Configurations shown when calling require('dap').continue().
dap.configurations.scala = {
  {
    type = 'scala',
    request = 'launch',
    name = 'Run or test current file',
    metals = {
      runType = 'runOrTestFile',
    },
  },
  {
    type = 'scala',
    request = 'launch',
    name = 'Run current target',
    metals = {
      runType = 'run',
    },
  },
  {
    type = 'scala',
    request = 'launch',
    name = 'Test current file',
    metals = {
      runType = 'testFile',
    },
  },
  {
    type = 'scala',
    request = 'launch',
    name = 'Test current target',
    metals = {
      runType = 'testTarget',
    },
  },
  {
    type = 'scala',
    request = 'attach',
    name = 'Attach to localhost:5005',
    hostName = 'localhost',
    port = 5005,

    -- Set this to your actual Metals build target when needed.
    -- Find target names using :MetalsRunDoctor.
    buildTarget = 'root',
  },
}

local metals_group =
  vim.api.nvim_create_augroup('nvim-metals', { clear = true })

vim.api.nvim_create_autocmd('FileType', {
  group = metals_group,
  pattern = { 'scala', 'sbt', 'java' },
  callback = function(args)
    metals.initialize_or_attach(metals_config)

    local function map(lhs, rhs, description)
      vim.keymap.set('n', lhs, rhs, {
        buffer = args.buf,
        desc = 'Metals: ' .. description,
      })
    end

    map('<leader>md', '<cmd>MetalsRunDoctor<cr>', 'Run doctor')
    map('<leader>mi', '<cmd>MetalsImportBuild<cr>', 'Import build')
    map('<leader>mr', '<cmd>MetalsRestartServer<cr>', 'Restart server')
    map('<leader>ml', '<cmd>MetalsLogsToggle<cr>', 'Toggle logs')
  end,
})

-- vim: ts=2 sts=2 sw=2 et
