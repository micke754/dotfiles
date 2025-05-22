# config.nu
#
# Installed by:
# version = "0.104.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave

# Paths

# $env.PATH = (
#   $env.PATH
#   | append ~/.cargo/bin
#   | append ~/kmichaels/.local/bin
# )

# $env.XDG_CONFIG_HOME = "~/kmichaels/.config"

# # Topiary Nushell Fmt
# $env.TOPIARY_CONFIG_FILE = ($env.XDG_CONFIG_HOME | path join topiary languages.ncl)
# $env.TOPIARY_LANGUAGE_DIR = ($env.XDG_CONFIG_HOME | path join topiary languages)

# Yazi Stuff
def --env y [...args] {
  let tmp = (mktemp -t "yazi-cwd.XXXXXX")
  yazi ...$args --cwd-file $tmp
  let cwd = (open $tmp)
  if $cwd != "" and $cwd != $env.PWD {
    cd $cwd
  }
  rm -fp $tmp
}

def --env find-git-status [...args] {
  # Find all .git directories recursively and get their full paths.
  # Use `^find` to invoke the external 'find' utility.
  let git_dirs = (^find . -type d -name ".git" | lines)

  for git_dir in $git_dirs {
    # Get the parent directory of the .git directory, which is the repository root.
    let repo_root = ($git_dir | path dirname)

    # Execute 'git status -s' within the repository root's context.
    # The 'do' block creates a temporary scope where 'cd' changes the directory
    # only for commands run within that block.
    # 'str trim' removes leading/trailing whitespace, including newlines,
    # ensuring accurate checking for non-empty status.
    let status_output = (
      do {
        cd $repo_root
        git status -s
      } | str trim
    )

    # Check if the status output is not empty (i.e., there are changes).
    # Use `not` directly on the boolean result of `is-empty`.
    if not ($status_output | is-empty) {
      # Print an empty line for separation, then the header and the status.
      print ""
      print $"GIT STATUS IN ($repo_root)"
      print $status_output
    }
  }
}

# Aliases

# alias hx = helix
alias la = uutils-ls -a

$env.config.show_banner = false
$env.config.buffer_editor = "hx"
$env.config.edit_mode = "vi"
$env.config.shell_integration.osc133 = false
$env.EDITOR = "hx"

# Starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Zoxide
source ~/.zoxide.nu
