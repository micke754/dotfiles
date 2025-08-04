# config.nu
#
# Installed by:
# version = "0.104.0"
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
# config settings
$env.config.show_banner = false
$env.config.buffer_editor = "hx"
$env.config.edit_mode = "vi"
$env.config.shell_integration.osc133 = false
$env.config.use_kitty_protocol = false
$env.EDITOR = "hx"
# $env.NVIM_APPNAME = "hex-vim"

# Paths

$env.PATH = (
  $env.PATH
  | append ~/.cargo/bin
  | append ~/.local/bin
  | append ~/Bash-Scripts
  | append ~/.bun/bin
)

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
alias bat = bat --decorations never
alias copy = pbcopy
alias ga = git add -A
alias gd = git diff 
alias gl = git log --oneline --graph -n 10
alias gs = git status 
alias la = lsd -a
alias ll = lsd -l
alias lt = lsd --tree --depth 2
alias npl = nix profile list
alias paste = pbpaste


# Starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Zoxide
source ~/.zoxide.nu

def "fgs" [] {
    # Find all .git directories recursively and get their full paths.
    # Use `^find` to invoke the external 'find' utility.
    let git_dirs = (^find . -type d -name ".git" | lines)

    for git_dir in $git_dirs {
        # Get the parent directory of the .git directory, which is the repository root.
        let repo_root = ($git_dir | path dirname)

        # Execute 'git status -s' within the repository root's context.
        # The 'do' block creates a temporary scope where 'cd' changes the directory
        # only for commands run within that block.
        # 'str trim' removes leading/trailing whitespace, ensuring accurate checking for non-empty status.
        let status_output = (
            do {
                cd $repo_root
                git status -s
            } | str trim
        )

        # Check if the status output is not empty (i.e., there are changes).
        if not ($status_output | is-empty) {
            # Print an empty line for separation, then the header and the status.
            print ""
            print $"GIT STATUS IN ($repo_root)"
            print $status_output
        }
    }
}




# Az trigger and monitor pipelines

def "trigger-and-monitor-pipeline" [
  pipeline_name: string # The name of the Azure DevOps pipeline
  branch_name: string # The branch to trigger the pipeline on
  --debug # Optional: Enable debug logging for Azure CLI commands
  --parameters: list<string> = [] # Optional: List of pipeline parameters (e.g., ["key1=value1", "key2=value2"])
] {

  # Store the start time for duration calculation
  let start_time = (date now)

  echo $"Triggering pipeline: ($pipeline_name) on branch ($branch_name)..."

  # Build optional flags for 'az pipelines run'
  let debug_flag = if $debug { ["--debug"] } else { [] }
  let params_flags = if (not ($parameters | is-empty)) { ["--parameters"] | append $parameters } else { [] }

  # Execute 'az pipelines run' with conditional flags
  let run_output = (
    try {
      az pipelines run --name $pipeline_name --branch $branch_name ...$debug_flag ...$params_flags --output json | from json
    } catch {
      echo "Error: Azure CLI command failed or returned invalid JSON for triggering pipeline."
      exit 1
    }
  )

  let run_id = $run_output.id
  let run_web_url = $run_output.url

  if ($run_id | is-empty) {
    echo "Failed to trigger pipeline or get run ID."
    exit 1
  }

  echo $"Pipeline run ID: ($run_id)"
  echo $"Monitor in browser: ($run_web_url)"
  echo "------------------------------------"

  mut status = "notStarted"
  mut result = "unknown"

  while ($status != "completed" and $status != "cancelling") {
    echo $"Checking status of run ($run_id)" # Print without newline
    for _ in 1..3 {
      print -n "." # Add dots for visual feedback
      sleep 0.5sec
    }
    print "" # Newline after dots

    let current_run_details = (
      try {
        ^az pipelines runs show --id $run_id ...$debug_flag --query '{status:status, result:result}' -o json | from json
      } catch {
        echo "Error: Azure CLI command failed or returned invalid JSON for checking status."
        # exit 1
      }
    )

    $status = $current_run_details.status
    $result = $current_run_details.result

    echo $"Current Status: ($status)"
    if ($status == "completed") {
      echo $"Final Result: ($result)"
    }

    # Only sleep if the pipeline is not yet completed or cancelling
    if ($status != "completed" and $status != "cancelling") {
      sleep 15sec # Wait for 15 seconds before checking again
    }
  }

  echo "------------------------------------"
  let end_time = (date now)
  let elapsed_duration = ($end_time - $start_time)
  echo $"Pipeline run ($run_id) has finished with status: ($status) and result: ($result)."
  echo $"Total time elapsed: ($elapsed_duration)"

  if ($result == "succeeded") {
    echo "Pipeline completed successfully!"
    # exit 0
  } else {
    echo "Pipeline finished with a non-success result."
    # exit 1 # Indicate failure
  }
}

def "mods-gd" [] {
  git diff
  | mods --no-cache --quiet --temp 0.5 --model lite """
  Generate a commit message for these changes using the conventional commits format; don't use backticks. Below is a template of the format:
    <type>[optional scope]: <description>

    [optional body]

    [optional footer(s)]
  """
  | str trim
  | pbcopy
}

def "gc" [] {
  # Get staged and unstaged changes
  let diff_output = (git diff HEAD)

  # Get untracked files
  let untracked = (git ls-files --others --exclude-standard)

  # Combine diff and untracked info for commit message generation
  let input_for_mods = if ($diff_output | is-empty) {
    if ($untracked | is-empty) {
      ""
    } else {
      $"Untracked files:\n($untracked | str join '\n')"
    }
  } else {
    $diff_output
  }

  if ($input_for_mods == "") {
    echo "No changes to commit."
    
  }

  # Generate commit message
  echo $input_for_mods
  | mods --model lite --no-cache """
  Generate a commit message for these changes using the conventional commits format; don't use backticks. Below is a template of the format:
    <type>[optional scope]: <description>

    [optional body]

    [optional footer(s)]
  """
  | str trim
  | pbcopy --clipboard

  # Run git commit with all changes staged
  git commit -a
}


def "mc" [] {
  mods --list; mods --continue (pbcopy)
}

def "ms" [] {
  mods --list; mods --show (pbcopy) | hx
}

def "msl" [] {
  mods --show-last; mods --show (pbcopy) | hx
}

def nix-profile-replace [
  flake_dir: string
] {
  let clean_name: string = ($flake_dir | str trim --right --char "/")

  print $"Removing profile: ($clean_name)"
  nix profile remove $clean_name | tee { print } | complete

  print $"Installing from ($clean_name)/"
  nix profile install $"(clean_name)/"  | tee { print } | complete
  
  print $"Running garbage collection..."
  nix-collect-garbage | tee { print } | complete

  print "SUCCESS: Profile replaced and garbage collected."
}

# Completions

# $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense' # optional, but useful
let carapace_completer = {|spans|
    carapace $spans.0 nushell ...$spans | from json
}

let fish_completer = {|spans|
    fish --command $"complete '--do-complete=($spans | str join ' ')'"
    | from tsv --flexible --noheaders --no-infer
    | rename value description
    | update value {
        if ($in | path exists) {$'"($in | str replace "\"" "\\\"" )"'} else {$in}
    }
}

$env.config.completions.external = {
  completer: $fish_completer
  enable: true
  
}

$env.config.completions.external = {
  completer:  $carapace_completer
  enable:  false
  
}
