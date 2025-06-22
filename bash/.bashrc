#
# ~/.bashrc
#

set -o vi
# If not running interactively, don't do anything
[[ $- != *i* ]] && return


PS1='[\u@\h \W]\$ '

# Environment variables
export EDITOR=helix

# Aliases
alias ls='ls --color=auto'
alias la='eza -a'
alias grep='grep --color=auto'
# alias hx='helix'
alias cl='clear'

# Starship
eval "$(starship init bash)"

# Zoxide
eval "$(zoxide init --cmd cd bash)"

# Yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# PATH
export PATH="/home/kmichaels/.local/bin:$PATH"
export PATH="/home/kmichaels/.cargo/bin:$PATH"

# Set up fzf key bindings and fuzzy completion
# eval "$(fzf --bash)"
FZF_ALT_C_COMMAND= eval "$(fzf --bash)"

source '/home/kmichaels/.bash_completions/sqlfmt.sh'

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
