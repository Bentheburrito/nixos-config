# A minimal Neovim setup

{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = mkDefault ''
      lua <<EOF
      print("minimal nvim config")

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

      --- KEY MAPPING ---
      vim.g.mapleader = " "
      vim.keymap.set("n", "<leader>fl", vim.cmd.NvimTreeFocus)
      -- helpful lsp keybinds re: https://github.com/neovim/nvim-lspconfig#suggested-configuration
      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

      EOF
      '';
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [
          # Themes
       	  onedark-nvim
          # Tmux integration
          vim-tmux-navigator
        ];
      };
    };
  };
}
