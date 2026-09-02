# Personal zsh — Oh-My-Zsh + Starship + pokemon greeting
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""
zstyle ':omz:update' mode disabled
DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    sudo
    extract
    colored-man-pages
)

fpath=(~/.zfunc $fpath)

source "$ZSH/oh-my-zsh.sh"

export PATH="$HOME/.local/bin:$HOME/Workspace/bin:$PATH"

if command -v lsd >/dev/null 2>&1; then
    alias ls='lsd'
    alias ll='lsd -l'
    alias la='lsd -la'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias ws='cd ~/Workspace'
alias wsw='cd ~/Workspace/work'
alias wsp='cd ~/Workspace/personal'
alias wsn='cd ~/Workspace/notes'
alias theme='theme-switcher'

HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS SHARE_HISTORY

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh --disable-up-arrow)"
fi

yy() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

if command -v pokemon-colorscripts >/dev/null 2>&1; then
    if command -v fastfetch >/dev/null 2>&1 && [ -f "$HOME/.config/fastfetch/config-pokemon.jsonc" ]; then
        pokemon-colorscripts --no-title -s -r | fastfetch -c "$HOME/.config/fastfetch/config-pokemon.jsonc" --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
    else
        pokemon-colorscripts --no-title -s -r
    fi
elif command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
