#!/bin/bash

set -e
# set -x

echo "Starting install"

SYSTEM_TYPE=$(uname)

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
  ln -fs "$( basedir )/fish/config.fish" "$HOME/.config/fish/config.fish"
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
    git clone https://github.com/VundleVim/Vundle.vim.git
  fi

  ln -fs "$( basedir )/vim/vimrc" "$HOME/.vimrc"
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

function configure_tmux(){
  echo "Configure Tmux"
  ln -fs "$( basedir )/tmux/tmux.conf" "$HOME/.tmux.conf"
}

function configure_ssh(){
  echo "Configuring SSH"
  ln -fs "$( basedir )/ssh/config" "$HOME/.ssh/config"
}

function symlink_config(){
  echo "Symlinking config files"
  configure_fish
  configure_git
  configure_vim
  configure_nvim
  configure_tmux
  configure_ssh
}

function brew_install(){
  echo "Doing Homebrew install"
  brew_packages="$( basedir )/package_lists/brew_packages.txt"

  set +e # checks for install via exit code
  BREW_INSTALLED_PACKAGES=$(brew list)
  while read package_name; do
    echo $BREW_INSTALLED_PACKAGES | grep -w $package_name > /dev/null
    if [ $? -ne 0 ];
    then
      echo "Installing: $package_name"
      brew install $package_name
    else
      echo "$package_name already installed"
    fi
  done < $brew_packages
  set -e
}

function osx_install(){
  echo "Updating Homebrew"
  brew update
  brew doctor
  brew_install
}

function ubuntu_install(){
  echo "Running Ubuntu install"

  sudo apt-get update

  echo "installing PPAs list"
  ppa_list=$( basedir )/package_lists/ppa_list.txt

  set +e
  while read ppa_repo; do
    echo "Adding $ppa_repo"
    sudo add-apt-repository $ppa_repo
  done < $ppa_list

  sudo apt-get update

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

  set -e
}

function nix_install(){
  create_base_directories
  symlink_config
  install_scripts
}

if [ $SYSTEM_TYPE == "Linux" ]; then
  nix_install
  ubuntu_install
elif [ $SYSTEM_TYPE == "Darwin" ]; then
  nix_install
  osx_install
else
  echo "Unknown uname"
  exit 1
fi

echo "Done!"
