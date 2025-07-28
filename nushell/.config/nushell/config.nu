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

# Environment Stuff
# Paths

$env.PATH = (
  $env.PATH
  | append ~/.cargo/bin
  | append /home/kmichaels/.local/bin
  | append /home/kmichaels/Bash-Scripts
  | append /home/kmichaels/.bun/bin
  # | append /home/kmichaels/Open-Source/Mods/dist
)
# Helps gpg to know what prompt to use
$env.GPG_TTY = (tty)

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
# alias hx = helix
alias bat = bat --decorations never
alias copy = xsel --clipboard
alias ga = git add -A
alias gd = git diff
alias gl = git log --oneline --graph -n 10
alias gs = git status
alias la = eza -a
alias validate = databricks bundle validate
alias npl = nix profile list

# alias gemini = npx https://github.com/google-gemini/gemini-cli

$env.config.show_banner = false
$env.config.buffer_editor = "hx"
$env.config.edit_mode = "vi"
$env.config.shell_integration.osc133 = false
$env.EDITOR = "hx"

# Starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# Zoxide
zoxide init --cmd cd nushell | save -f ~/.zoxide.nu

# Zoxide
source ~/.zoxide.nu

def practice [] {
  ttyper -l english-ngrams -w 10 
}

def "mods-gd-continue" [] {
  git diff
  | mods --model lite -C """
  Generate a commit message for these changes using the conventional commits format; don't use backticks. Below is a template of the format:
    <type>[optional scope]: <description>

    [optional body]

    [optional footer(s)]
  """
  | str trim
  | xsel --clipboard
}

def "mods-gd" [] {
  git diff
  | mods --model lite --no-cache """
  Generate a commit message for these changes using the conventional commits format; don't use backticks. Below is a template of the format:
    <type>[optional scope]: <description>

    [optional body]

    [optional footer(s)]
  """
  | str trim
  | xsel --clipboard
}

def "gc" [] {
  # Checking if gitleaks is installed
  if (which gitleaks | is-empty ) {
    print "⚠️ gitleaks not found"
    return
  }

  let is_leaked = (
    try {
      let result = gitleaks detect --verbose --exit-code 1 | complete
      if $result.exit_code == 1 {
        true # Secrets found
      } else if $result.exit_code == 0 {
        false # No secrets detected
      } else {
        print "❌ Gitleaks command failed"
        return
      }
    } catch {
      print "❌ Error running gitleaks"
      return
    }
  )

  if $is_leaked == true {
    print "❌ Gitleaks detected potential secrets. Commit aborted for security."
    print "Run 'gitleaks detect --verbose' to see details."
    return
   
  } else if $is_leaked == false {
    print "✅ Gitleaks scan passed - no secrets detected."
  } else {
    return
  }
  
  
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
    print "No changes to commit."
    
  }


  # Generate commit message
  $input_for_mods
  | mods --model lite --no-cache """
  Generate a conventional commit message for these changes. Use this format:

  <type>[optional scope]: <description>

  Guidelines:
  - type: feat, fix, docs, style, refactor, perf, test, chore, ci
  - scope: optional, indicates what part of codebase (e.g., auth, api, ui)
  - description: imperative mood, lowercase, no period at end
  - Keep first line under 50 characters
  - Add body if changes need explanation
  - Add footer for breaking changes: 'BREAKING CHANGE: description'

  Examples:
  feat(auth): add OAuth2 login support
  fix: resolve memory leak in user session
  docs: update installation instructions
  """
  | str trim
  | xsel --clipboard

  # Run git commit with all changes staged
  git commit -a

  # Add typing practice
  print "\n🎯 Time for some typing practice!"
  print "Complete 25 English n-grams:"
  sleep 1sec
  practice
  
}

def "mc" [] {
  mods --list; mods --continue (xsel --clipboard)
}

def "ms" [] {
  mods --list; mods --show (xsel --clipboard) | hx
}

def "msl" [] {
  mods --show-last; mods --show (xsel --clipboard) | hx
}

def "agenda" [] {
  gcalcli agenda now | tail -n +3 | str trim | head -n 7
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


# Az trigger and monitor pipelines

def "trigger-and-monitor-pipeline" [
  pipeline_name: string
  branch_name: string
  --debug
  --parameters: list<string> = []
] {
  let start_time = (date now)
  echo $"Triggering pipeline: ($pipeline_name) on branch ($branch_name)..."

  let debug_flag = if $debug { ["--debug"] } else { [] }
  let params_flags = if (not ($parameters | is-empty)) { ["--parameters"] | append $parameters } else { [] }

  let run_output = (
    try {
      az pipelines run --name $pipeline_name --branch $branch_name ...$debug_flag ...$params_flags --output json | from json
    } catch {
      echo "Error: Azure CLI command failed or returned invalid JSON for triggering pipeline."
      exit 1
    }
  )

  if ($run_output == nothing) {
    echo $"Error: Failed to trigger pipeline. Branch ($branch_name) may not exist or other error occurred."
    exit 1
  }

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
    echo $"Checking status of run ($run_id)"
    for _ in 1..3 {
      print -n "."
      sleep 0.5sec
    }
    print ""

    let current_run_details = (
      try {
        ^az pipelines runs show --id $run_id ...$debug_flag --query '{status:status, result:result}' -o json | from json
      } catch {
        echo "Error: Azure CLI command failed or returned invalid JSON for checking status."
      }
    )

    $status = $current_run_details.status
    $result = $current_run_details.result

    echo $"Current Status: ($status)"
    if ($status == "completed") {
      echo $"Final Result: ($result)"
    }

    if ($status != "completed" and $status != "cancelling") {
      sleep 15sec
    }
  }

  echo "------------------------------------"
  let end_time = (date now)
  let elapsed_duration = ($end_time - $start_time)
  echo $"Pipeline run ($run_id) has finished with status: ($status) and result: ($result)."
  echo $"Total time elapsed: ($elapsed_duration)"

  if ($result == "succeeded") {
    echo "Pipeline completed successfully!"
    true
  } else {
    echo "Pipeline finished with a non-success result."
    false
  }
}

# Completions
let carapace_completer = {|spans|
  carapace $spans.0 nushell ...$spans | from json
}

let fish_completer = {|spans|
  fish --command $"complete '--do-complete=($spans | str join ' ')'"
  | from tsv --flexible --noheaders --no-infer
  | rename value description
  | update value {
    if ($in | path exists) { $'"($in | str replace "\"" "\\\"")"' } else { $in }
  }
}

$env.config.completions.external =  {
  enable: false
  completer: $carapace_completer
}
$env.config.completions.external =  {
  enable: true
  completer: $fish_completer
}
