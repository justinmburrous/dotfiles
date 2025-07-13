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

  # Install fisher
  fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"

  # Install other plugins
  fish -c "fisher install edc/bass"

  # Update anything remaining
  fish -c "fisher update"
}

function configure_ghostty(){
  echo "Configure ghostty"
  mkdir -p "$HOME/.config/ghostty"
  ln -fs "$( basedir )/ghostty/config" "$HOME/.config/ghostty/config"
}

function configure_git(){
  echo "Configuring git"
  ln -fs "$( basedir )/git/gitconfig" "$HOME/.gitconfig"
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

  echo "Setting up venv for nvim"
  python3 -m venv ~/.venv/neovim
  . ~/.venv/neovim/bin/activate
  pip3 install --upgrade pynvim
  deactivate
}

function configure_aws_cli(){
  echo "Setup AWS cli & boto3"
  python3 -m venv ~/.venv/aws
  . ~/.venv/aws/bin/activate
  pip3 install --upgrade awscli boto3 botocore
  deactivate
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
  mkdir -p "$HOME/.ssh/"
  ln -fs "$( basedir )/ssh/config" "$HOME/.ssh/config"
}

function configure_npm(){
  echo "Configuring NPM"
  ln -fs "$( basedir )/nodejs/npmrc" "$HOME/.npmrc"
}

function configure_rust(){
  echo "Installing and configuring rust"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

function configure_node_version_manager(){
  echo "Configuring Node Version Manager (NVM)"
  # Note: This uses the nvm function with fish and Bass to work, see fish config
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  fish -c "nvm install v22"
  fish -c "nvm install v20"
  fish -c "nvm install v18"
  fish -c "nvm install v16"
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


function arch_install(){
  echo "Running Arch install"

  sudo pacman -Syu

  echo "Checking $arch_packages  list"
  arch_packages=$( basedir )/package_lists/arch.txt

  while read package_name; do
    sudo pacman --noconfirm -S $package_name
  done < $arch_packages

  echo "Done Arch install"

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
  configure_ghostty
  configure_git
  configure_vim
  configure_nvim
  configure_aws_cli
  configure_tmux
  configure_ssh
  configure_npm
  configure_node_version_manager
  configure_rust
  install_scripts
  configure_tpm
}

if [ $SYSTEM_TYPE == "Linux" ]; then
  LINUX_OS_TYPE=$(grep "^NAME=" /etc/os-release | cut -d "=" -f2- | tr -d '"')

  if [ "$LINUX_OS_TYPE" == "Ubuntu" ]; then
    echo "Detected Ubuntu System"

    ubuntu_install
    nix_install
  elif [ "$LINUX_OS_TYPE" == "Arch Linux" ]; then
    echo "Detected Arch system"

    arch_install
    nix_install
  else
    echo "Unknown Linux type, exiting"
    exit 1
  fi

elif [ $SYSTEM_TYPE == "Darwin" ]; then
  brew_install
  nix_install
else
  echo "Unknown uname $SYSTEM_TYPE"
  exit 1
fi

echo "Done!"
