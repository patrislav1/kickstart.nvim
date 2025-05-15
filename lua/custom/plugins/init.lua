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

-- LSP for Tcl
vim.filetype.add {
  pattern = {
    ['.*.xdc'] = 'xdc',
    ['.*.upf'] = 'upf',
  },
}

vim.treesitter.language.register('tcl', 'xdc')

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'tcl,sdc,xdc,upf',
  callback = function(args)
    vim.lsp.start {
      name = 'tclint',
      cmd = { 'tclsp' },
      root_dir = vim.fs.root(args.buf, { 'tclint.toml', '.tclint', 'pyproject.toml' }) or vim.fn.getcwd(),
    }
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
  {
    'alexghergh/nvim-tmux-navigation',
    config = function()
      require('nvim-tmux-navigation').setup {
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
          left = '<C-h>',
          down = '<C-j>',
          up = '<C-k>',
          right = '<C-l>',
          last_active = '<C-\\>',
          next = '<C-Space>',
        },
      }

      local function tmux_command(command)
        local tmux_socket = vim.fn.split(vim.env.TMUX, ',')[1]
        return vim.fn.system('tmux -S ' .. tmux_socket .. ' ' .. command)
      end

      local nvim_tmux_nav_group = vim.api.nvim_create_augroup('NvimTmuxNavigation', {})

      vim.api.nvim_create_autocmd({ 'VimEnter', 'VimResume' }, {
        group = nvim_tmux_nav_group,
        callback = function()
          tmux_command 'set-option -p @is_vim yes'
        end,
      })

      vim.api.nvim_create_autocmd({ 'VimLeave', 'VimSuspend' }, {
        group = nvim_tmux_nav_group,
        callback = function()
          tmux_command 'set-option -p -u @is_vim'
        end,
      })
    end,
  },
}
