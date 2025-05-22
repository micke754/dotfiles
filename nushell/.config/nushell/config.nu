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

$env.PATH = (
  $env.PATH
  | append ~/.cargo/bin
  | append /home/kmichaels/.local/bin
)

$env.XDG_CONFIG_HOME = "/home/kmichaels/.config"

# Topiary Nushell Fmt
$env.TOPIARY_CONFIG_FILE = ($env.XDG_CONFIG_HOME | path join topiary languages.ncl)
$env.TOPIARY_LANGUAGE_DIR = ($env.XDG_CONFIG_HOME | path join topiary languages)

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
alias hx = helix
alias la = uutils-ls -a

$env.config.show_banner = false
$env.config.buffer_editor = "helix"
$env.config.edit_mode = "vi"
$env.config.shell_integration.osc133 = false
$env.EDITOR = "helix"

# Starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Zoxide
zoxide init --cmd cd nushell | save -f ~/.zoxide.nu

# Zoxide
source ~/.zoxide.nu

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
