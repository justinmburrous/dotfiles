#Env
set -x EDITOR vim
set -x GOPATH ~/workspace/gopath
set -x PATH $PATH ~/bin
set -x PATH $PATH $GOPATH/bin
set -x PATH $PATH ~/.npm-packages/bin
set -x PATH $PATH ~/.cargo/bin
set -g fish_user_paths "/usr/local/sbin" $fish_user_paths
set -x KUBE_EDITOR "nvim"

# Keyboard re-map
if [ (uname) = "Linux" ];
  setxkbmap -option caps:escape
end

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
alias gits="git status"
alias gitl="git log --pretty=oneline"
alias k="kubectl"

# Functions
function fish_prompt
  echo -e $USER ":" (basename $PWD) "\n> "
end

function clear
  if test (random 0 1000) = 0
    sl
  else
    /usr/bin/clear
  end
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
  else
    $gitbin $argv
  end
end

set -x KUBECONFIG $HOME/.kube/pinode

# Turn off shell greeting
set fish_greeting

