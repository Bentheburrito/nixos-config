# Development Neovim setup

{ pkgs, ... }:
{
  # NeoVim setup
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      # luafile ${/home/snowful/.config/nvim/init.lua}
      customRC = ''
lua <<EOF
print("nvim config v6")

--- THEME ---
local onedark = require('onedark')
onedark.setup {
    style = 'darker'
}
onedark.load()

--- OPTIONS ---
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.colorcolumn = "80,120"

-- set everything to be Elixir's 2-space indentation system by default. Should probably configure to be lang-specific
vim.o.expandtab = true -- expand tab input with spaces characters
vim.o.smartindent = true -- syntax aware indentations for newline inserts
vim.o.tabstop = 2 -- num of space characters per tab
vim.o.shiftwidth = 2 -- spaces per indentation level
-- disable netrw in favor of nvim-tree file explorer
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

--- KEY MAPPING ---
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>fl", vim.cmd.NvimTreeFocus)
-- helpful lsp keybinds re: https://github.com/neovim/nvim-lspconfig#suggested-configuration
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

--- AUTO-COMPLETE ---
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

--- FILE EXPLORER ---
require("nvim-tree").setup()

--- TREESITTER ---
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

--- LSP STUFF ---
local lsp_zero = require('lsp-zero').preset({}) -- Is this preset needed?..

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- lsp_zero.setup()
require('lspconfig').elixirls.setup({cmd = { "${pkgs.elixir-ls}/bin/elixir-ls" };})
-- local elixir = require("elixir")
-- local elixirls = require("elixir.elixirls")
-- elixir.setup()

require('lspconfig').elmls.setup({cmd = { "${pkgs.elmPackages.elm-language-server}/bin/elm-language-server" }})
-- require('lspconfig').rust_analyzer.setup({})

vim.g.rustaceanvim = {
  server = {
    capabilities = lsp_zero.get_capabilities()
  },
}

--- TELESCOPE / FUZZY SEARCH STUFF ---
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- format on save
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
-- vim.api.nvim_create_autocmd('BufWritePre', {
-- 	buffer = vim.fn.bufnr(),
-- 	callback = function()
-- 		vim.lsp.buf.format({ timeout_ms = 3000 })
-- 	end,
-- })

--- GIT ---
require('gitsigns').setup()

EOF
      '';
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [
          # Syntax Highlighting
          (nvim-treesitter.withPlugins (plugins: with plugins; [ nix bash rust elixir elm eex heex json lua ]))
          ## Highlight token/word that the cursor is on
          vim-illuminate
          # LSP/Autocomplete
          lsp-zero-nvim
          nvim-cmp
          nvim-lspconfig
          cmp-nvim-lsp
          luasnip
          ## The actual LSPs
          elixir-tools-nvim # since elixir-ls path is used in the cmd in config above, do I even need this?? Try deleting later
          plenary-nvim # mystery plugin required else elixir ls breaks
          rustaceanvim
          # Fuzzy Search
          telescope-nvim
          # Themes
       	  onedark-nvim
          # File Explorer
          nvim-tree-lua
          nvim-web-devicons
          # Tmux integration
          vim-tmux-navigator
          # Git integration
          gitsigns-nvim
        ];
      };
    };
  };
}
