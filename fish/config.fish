#Env
set -x EDITOR vim
set -x GOPATH ~/workspace/gopath
set -x PATH $PATH ~/bin
set -x PATH $PATH $GOPATH/bin
set -x PATH $PATH /opt/go/bin
set -x PATH $PATH /opt/sbt/bin
set -x PATH $PATH /opt/android-studio/bin
set -x PATH $PATH /opt/goland/bin

# Aliases
alias gitca="git commit -a"
alias gita="git add ."
alias gitd="git diff"
alias gitc="git commit"
alias gits="git status"