#!/usr/bin/env bash

set -e
# set -x

echo "Starting install"

SYSTEM_TYPE=$(uname)
ARCH_TYPE="$(uname -p)"

function create_base_directories(){
  echo "Creating base directories"
  mkdir -p "$HOME/bin"
  mkdir -p "$HOME/workspace"
}

function basedir(){
  dotfile_base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  echo $dotfile_base_dir
}

function configure_fish(){
  echo "Configuring fish shell"
  mkdir -p "$HOME/.config/fish"
  ln -fs "$( basedir )/fish/config.fish" "$HOME/.config/fish/config.fish"

  if [ $SYSTEM_TYPE == "Linux" ]; then
    FISH_SHELL_PATH="/usr/bin/fish"

  elif [ $SYSTEM_TYPE == "Darwin" ]; then
    # check OSX platform
    if [ $ARCH_TYPE == "i386" ]; then
      FISH_SHELL_PATH="/usr/local/bin/fish"
    elif [ $ARCH_TYPE == "arm" ]; then
      FISH_SHELL_PATH="/opt/homebrew/bin/fish"
    else
      echo "Unknown arch. exiting fish shell install"
      exit 1
    fi

  else
    echo "Unknown uname, exiting fish shell install"
    exit 1
  fi

  if grep "$FISH_SHELL_PATH" /etc/shells;
  then
    echo "fish shell $FISH_SHELL_PATH already in /etc/shells"
  else
    echo "Adding fish shell $FISH_SHELL_PATH to /etc/shells"
    sudo bash -c "echo $FISH_SHELL_PATH >> /etc/shells"
  fi

  if [ $SHELL = $FISH_SHELL_PATH ]; then
    echo "fish shell already configured"
  else
    echo "setting fish shell path to $FISH_SHELL_PATH"
    chsh -s $FISH_SHELL_PATH
  fi
}

function configure_git(){
  echo "Configuring git"
  git config --global user.name "Justin Burrous"
  git config --global user.email justinmburrous@gmail.com
  git config --global core.excludesfile "$HOME/.gitignore_global"
  git config --global core.editor nvim
  git config --global init.defaultBranch main
  ln -fs "$( basedir )/git/global_ignore" "$HOME/.gitignore_global"
}

function configure_vim(){
  echo "Configure vim"
  VUNDLE_DIR="$HOME/.vim/bundle/Vundle.vim"
  if [ ! -d $VUNDLE_DIR ]; then
    echo "Pulling Vundle plugin"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  fi

  ln -fs "$( basedir )/vim/vimrc" "$HOME/.vimrc"

  vim +PluginInstall +qall
  vim +PluginUpdate +qall
  vim +PluginClean +qall
}

function configure_nvim(){
  echo "Configuring nvim"
  mkdir -p ~/.config/nvim
  ln -fs "$( basedir )/nvim/init.vim" "$HOME/.config/nvim/init.vim"
}

function install_scripts(){
  echo "Installing scripts"
  for f in ./scripts/*; do
    ln -fs "$( basedir )/scripts/$(basename $f)" "$HOME/bin/$(basename $f)"
  done
}

function configure_tpm(){
  echo "Configuring TMUX plugin manager (TPM)"
  if [ -d ~/.tmux/plugins/tpm ]
  then
    echo "TPM already installed"
  else
    echo "Will install TPM"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  fi

  echo "Updating TPM plugins"
  # Install, update, clean plugins
  ~/.tmux/plugins/tpm/bin/install_plugins
  ~/.tmux/plugins/tpm/bin/update_plugins all
  ~/.tmux/plugins/tpm/bin/clean_plugins
}

function configure_tmux(){
  echo "Configure Tmux"
  ln -fs "$( basedir )/tmux/tmux.conf" "$HOME/.tmux.conf"
}

function configure_ssh(){
  echo "Configuring SSH"
  ln -fs "$( basedir )/ssh/config" "$HOME/.ssh/config"
}

function configure_ssh(){
  echo "Configuring NPM"
  npm set init-author-email "justinmburrous@gmail.com"
  npm set init-author-name "justinmburrous"
  npm set init-license "MIT"
  npm set prefix "~/.npm-packages"
}

function brew_install(){
  echo "Updating homebrew"
  brew update

  echo "Doing Homebrew install"
  BREW_DESIRED_PACKAGES="$( basedir )/package_lists/brew_packages.txt"

  set +e # checks for install via exit code
  BREW_INSTALLED_PACKAGES=$(brew list)
  while read package_name; do
    if brew ls --versions $package_name; then
      echo "$package_name already installed"
    else
      echo "Installing: $package_name"
      brew install $package_name
    fi
  done < $BREW_DESIRED_PACKAGES
  set -e

  echo "Running brew doctor"
  brew doctor
}


function ubuntu_install(){
  echo "Running Ubuntu install"

  sudo apt-get update -y

  echo "installing PPAs list"
  ppa_list=$( basedir )/package_lists/ppa_list.txt

  set +e
  while read ppa_repo; do
    echo "Adding $ppa_repo"
    sudo add-apt-repository $ppa_repo
  done < $ppa_list

  sudo apt-get update -y

  echo "checking $ubuntu_packages list"
  ubuntu_packages=$( basedir )/package_lists/apt.txt

  APT_INSTALLED_PACKAGES=$(apt list --installed)
  while read package_name; do
    echo $APT_INSTALLED_PACKAGES | grep -w $package_name > /dev/null
    if [ $? -ne 0 ]; then
      echo "Installing $package_name"
      sudo apt-get install -y $package_name
    else
      echo "$package_name already installed"
    fi
  done < $ubuntu_packages

  sudo apt-get upgrade -y

  set -e
}

function nix_install(){
  create_base_directories
  configure_fish
  configure_git
  configure_vim
  configure_nvim
  configure_tmux
  configure_ssh
  configure_npm
  install_scripts
  configure_tpm
}

if [ $SYSTEM_TYPE == "Linux" ]; then
  ubuntu_install
  nix_install
elif [ $SYSTEM_TYPE == "Darwin" ]; then
  brew_install
  nix_install
else
  echo "Unknown uname $SYSTEM_TYPE"
  exit 1
fi

echo "Done!"
