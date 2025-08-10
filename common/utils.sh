function install_utils(){
  configure_ssh
  configure_git
  configure_fish 
  configure_ghostty
  configure_tmux
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
      echo "Unknown arch, exiting fish shell install"
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

function configure_tmux(){
  echo "Configure Tmux"
  ln -fs "$( basedir )/tmux/tmux.conf" "$HOME/.tmux.conf"

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

function configure_ssh(){
  echo "Configuring SSH"
  mkdir -p "$HOME/.ssh/"
  ln -fs "$( basedir )/ssh/config" "$HOME/.ssh/config"
}
