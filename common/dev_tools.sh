function install_dev_tools(){
  configure_vim
  configure_nvim
  configure_aws_cli
  configure_npm
  configure_rust
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

function configure_npm(){
  echo "Configuring NPM"
  ln -fs "$( basedir )/nodejs/npmrc" "$HOME/.npmrc"

  echo "Configuring Node Version Manager (NVM)"
  # Note: This uses the nvm function with fish and Bass to work, see fish config
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  fish -c "nvm install v22"
  fish -c "nvm install v20"
  fish -c "nvm install v18"
  fish -c "nvm install v16"
}

function configure_rust(){
  echo "Installing and configuring rust"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

