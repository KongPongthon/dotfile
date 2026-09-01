# Personal minimal zsh — Oh-My-Zsh + pokemon
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source "$ZSH/oh-my-zsh.sh"

# Prefer lsd over ls when available
if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
  alias ll='lsd -l'
  alias la='lsd -la'
fi

alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Pokemon greeting (pretty)
if command -v pokemon-colorscripts >/dev/null 2>&1; then
  if command -v fastfetch >/dev/null 2>&1 && [[ -f "$HOME/.config/fastfetch/config-pokemon.jsonc" ]]; then
    pokemon-colorscripts --no-title -s -r | fastfetch -c "$HOME/.config/fastfetch/config-pokemon.jsonc" --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
  else
    pokemon-colorscripts --no-title -s -r
  fi
elif command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

# History
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS SHARE_HISTORY

# Local overrides
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
