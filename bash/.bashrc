#
# ~/.bashrc
#

set -o vi
# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

# Environment variables
export EDITOR=helix
# export GEMINI_API_KEY=$(pass google/gemini-api-key)

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
export PATH="/home/kmichaels/.bun/bin:$PATH"

# Set up fzf key bindings and fuzzy completion
# eval "$(fzf --bash)"
FZF_ALT_C_COMMAND= eval "$(fzf --bash)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# # DBEE Nvim
# export DBEE_CONNECTIONS='[
#     {
#         "name": "{{ exec `echo Hidden Database` }}",
#         "url": "postgres://{{ env \"SECRET_DB_USER\" }}:{{ env `SECRET_DB_PASS` }}@localhost:5432/{{ env `SECRET_DB_NAME` }}?sslmode=disable",
#         "type": "databricks"
#     }
# ]'

# Export secrets
# export SECRET_DB_NAME="secretdb"
# export SECRET_DB_USER="secretuser"
# export SECRET_DB_PASS="secretpass"
# export DBEE_URL=token:dapXXXX-X@adb-XXXX.XX.azuredatabricks.net:443/sql/1.0/warehouses/XXX?catalog=XXX
