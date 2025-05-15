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

-- LSP and fallback treesitter autoformat
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    if next(vim.lsp.get_clients { bufnr = 0 }) ~= nil then
      vim.lsp.buf.format { async = false }
    else
      local pos = vim.api.nvim_win_get_cursor(0)
      vim.cmd 'normal! gg0=G'
      vim.api.nvim_win_set_cursor(0, pos)
    end
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

-- Bitbake server "kind of" works, but not all features, disable it for now
-- see also https://github.com/yoctoproject/vscode-bitbake/issues/380
-- maybe bitbake/getRecipeLocalFiles has to be implemented on nvim side
-- also it needs to run bitbake for some features ... maybe it's overkill?
--
-- sudo npm install -g language-server-bitbake
-- vim.api.nvim_create_autocmd('FileType', {
--   pattern = 'bitbake',
--   callback = function(args)
--     vim.lsp.start {
--       name = 'bitbake',
--       cmd = { 'language-server-bitbake', '--stdio' },
--       root_dir = function(fname)
--         return vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
--       end,
--       single_file_support = false,
--     }
--   end,
-- })

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
      local function my_on_attach(bufnr)
        local api = require 'nvim-tree.api'
        api.config.mappings.default_on_attach(bufnr)
        -- Remove <C-k> so tmux-navigation can use it
        vim.keymap.del('n', '<C-k>', { buffer = bufnr })
      end

      require('nvim-tree').setup {
        view = { adaptive_size = true },
        tab = { sync = { open = true } },

        on_attach = my_on_attach,
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
        component_separators = { left = '', right = '' },
        section_separators = { right = '', left = '' },
        disabled_filetypes = { 'fugitive', 'fugitiveblame', 'git', 'gitcommit', 'NvimTree' },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { 'filename' },
        lualine_x = { 'fileformat', 'filetype', 'lsp_status' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      -- in case we want to see buffer type in the statusline
      -- extensions = {
      --   {
      --     filetypes = { 'fugitive', 'fugitiveblame', 'git', 'gitcommit', 'NvimTree' },
      --     sections = {
      --       lualine_a = { 'filetype' },
      --     },
      --     inactive_sections = {
      --       lualine_a = { 'filetype' },
      --     },
      --   },
      -- },
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
  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    config = function()
      require('ufo').setup {
        provider_selector = function(bufnr, filetype, buftype)
          return { 'treesitter', 'indent' }
        end,
      }

      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.statuscolumn = '%=%{foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? "" : "") : " " }%l%s'
    end,
  },
}
