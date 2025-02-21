-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Force OSC52 support
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy '+',
    ['*'] = require('vim.ui.clipboard.osc52').copy '*',
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste '+',
    ['*'] = require('vim.ui.clipboard.osc52').paste '*',
  },
}

-- Allow line wrap when using cursor keys
vim.opt.whichwrap:append '<,>,h,l,[,]'

-- Clear search highlighting on <CR> in normal mode, but not in quickfix or nowrite windows
vim.api.nvim_exec2(
  [[
  augroup CustomClearHighlight
    autocmd!
    autocmd FileType * if &buftype != 'quickfix' && &modifiable | nnoremap <buffer> <CR> :nohl<CR> | endif
  augroup END
]],
  {}
)

-- Add window handling hotkeys somewhat similar to tmux
vim.keymap.set('n', '<leader>%', ':vsplit<cr>', { noremap = true, silent = true, desc = 'Split vertically' })
vim.keymap.set('n', '<leader>"', ':split<cr>', { noremap = true, silent = true, desc = 'Split horizontally' })

-- LSP autoformat
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    vim.lsp.buf.format { async = false }
  end,
})

-- Set LSP log level to debug LSP/formatting issues. The log will be at ~/.local/state/nvim/lsp.log
-- vim.lsp.set_log_level("trace")

return {
  -- Git related plugins
  'tpope/vim-fugitive',
  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    lazy = false,
    config = function()
      require('onedark').setup {
        -- Set a style preset. 'dark' is default.
        style = 'warmer', -- dark, darker, cool, deep, warm, warmer, light
      }
      require('onedark').load()
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup {
        view = { adaptive_size = true },
      }
      vim.api.nvim_set_keymap('n', '<leader><CR>', ':NvimTreeToggle<CR>', { noremap = true, silent = true, desc = 'Toggle nvim-tree' })
      vim.api.nvim_set_keymap('n', '<leader><TAB>', ':NvimTreeFindFile<CR>', { noremap = true, silent = true, desc = 'Find file in nvim-tree' })
    end,
  },
  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        extensions = 'nvim-tree',
      },
    },
  },
}
