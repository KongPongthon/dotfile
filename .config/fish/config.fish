source /usr/share/cachyos-fish-config/cachyos-config.fish

# Dracula Fish Syntax Highlighting
set -g fish_color_normal f8f8f2
set -g fish_color_command 8be9fd
set -g fish_color_keyword ff79c6
set -g fish_color_quote f1fa8c
set -g fish_color_redirection f8f8f2
set -g fish_color_end ff79c6
set -g fish_color_error ff5555
set -g fish_color_param bd93f9
set -g fish_color_comment 6272a4
set -g fish_color_selection --background=44475a
set -g fish_color_search_match --background=44475a
set -g fish_color_operator 50fa7b
set -g fish_color_escape ff79c6
set -g fish_color_autosuggestion 6272a4

# Added by Antigravity CLI installer
set -gx PATH "$HOME/.local/bin" $PATH

# Theme Switcher (palette picker)
function theme
    theme-switcher $argv
end

if type -q mise
    mise activate fish | source
end

if type -q zoxide
    zoxide init fish | source
end

if type -q atuin
    atuin init fish --disable-up-arrow | source
end
