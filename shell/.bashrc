#
# ~/.bashrc
#

[[ $- != *i* ]] && return

# Interactive terminals use zsh (this repo's primary shell).
if [ -t 1 ] && [ -x "$(command -v zsh)" ] && [ -z "$ZSH_VERSION" ]; then
    exec zsh
fi

export PATH="$HOME/.local/bin:$PATH"
alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init bash --disable-up-arrow)"
fi

alias theme="theme-switcher"
