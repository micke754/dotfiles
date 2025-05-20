# env.nu
#
# Installed by:
# version = "0.104.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

# Paths

$env.PATH = (
  $env.PATH
  | append ~/.cargo/bin
  | append /home/kmichaels/.local/bin
)

$env.XDG_CONFIG_HOME = "/home/kmichaels/.config"

# Topiary Nushell Fmt
$env.TOPIARY_CONFIG_FILE = ($env.XDG_CONFIG_HOME | path join topiary languages.ncl)
$env.TOPIARY_LANGUAGE_DIR = ($env.XDG_CONFIG_HOME | path join topiary languages)

# Zoxide
zoxide init --cmd cd nushell | save -f ~/.zoxide.nu

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
