-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
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
