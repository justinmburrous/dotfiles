#Env
set -x EDITOR vim
set PATH /opt/homebrew/sbin /opt/homebrew/bin $PATH # Used for M1 Mac
set -x GOPATH ~/workspace/gopath
set -x PATH $PATH ~/bin
set -x PATH $PATH $GOPATH/bin
set -x PATH $PATH ~/.npm-packages/bin
set -x PATH $PATH ~/.cargo/bin
set -x PATH $PATH ~/bin
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
fish_add_path /opt/homebrew/opt/openjdk/bin
set -x KUBE_EDITOR "nvim"

# Platform specific config.
switch (uname)
case Linux
  set -x PATH $PATH /opt/go/bin
  set -x PATH $PATH /opt/sbt/bin
  set -x PATH $PATH /opt/android-studio/bin
  set -x PATH $PATH /opt/goland/bin
  set -x PATH $PATH /opt/protoc/bin
case Darwin
case *
  echo "Warning, unknown platform detected in fish config. setup"
end

# Aliases
alias gitca="git commit -a"
alias gita="git add ."
alias gitd="git diff"
alias gitc="git commit"
alias gitb="git branch"
alias gits="git status"
alias gitl="git log --pretty=oneline"
alias k="kubectl"

# Functions
function fish_prompt
  echo -e $USER"@"(hostname)":"(basename $PWD) "\n> "
end

function clear
  if test (random 0 1000) = 0
    sl
  else
    /usr/bin/clear
  end
end

function ws
  # Fuzzy search workspace, go there
  cd "$HOME/workspace"
  cd (ls | fzf)
end

# Wrapper around git functions
function git
  set gitbin (which git)
  set subcmd $argv[1]

  # Set remote to 'github' when repo is clones from Github
  if string match $subcmd "clone"
    set remote $argv[2]

    if string match -r 'github.com' $remote
      $gitbin clone -o 'github' "$argv[2]"
    else
      $gitbin clone remote
    end

  # Normal operations
  else if string match $subcmd "backup"
    set current_branch (git branch | sed -n -e 's/^\* \(.*\)/\1/p')

    set timestamp (date '+%Y-%m-%d-%H-%M-%S')
    set backup_branch "$current_branch-backup-$timestamp"
    git checkout -b $backup_branch


    git add .
    git commit -m "backup-$timestamp"
    if string match (git remote show) "github"
      echo "github remote set, pushing"
      git push github $backup_branch
    else
      echo "unknown remote set, skipping"
    end

  else
    $gitbin $argv
  end
end

# short-cut to nvm helper using bass
function nvm
  bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
end

# Turn off shell greeting
set -U fish_greeting "🐟"

# CDK
set -x JSII_SILENCE_WARNING_UNTESTED_NODE_VERSION 1
