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
alias grep='grep --color=auto'
alias hx='helix'

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
