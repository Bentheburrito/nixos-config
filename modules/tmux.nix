
{ pkgs, ... }:
{
  # tmux setup
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";
    shortcut = "Space";
    # Set 24-bit color support. Might need to do "tmux-direct" if italics don't 
    # work re: https://search.nixos.org/options?channel=23.11&show=programs.tmux.terminal&from=0&size=50&sort=relevance&type=packages&query=programs.tmux
    terminal = "alacritty";
    plugins = with pkgs.tmuxPlugins; [ sensible vim-tmux-navigator onedark-theme yank ]; 
    extraConfig = ''
      # need this in addition to `terminal = "xterm-256color"` option for some reason
      set-option -sa terminal-overrides ",alacritty*:Tc"

      # Enable mouse
      set -g mouse on

      # Shift + Alt + H or L to switch windows
      bind -n M-H previous-window
      bind -n M-L next-window

      # Plugins that require additional config before running
      # run-shell ${pkgs.tmuxPlugins.sensible}/share/tmux-plugins/sensible/sensible.tmux
    '';
  };
}
