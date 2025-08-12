function brew_install(){
  echo "Updating Homebrew"
  brew update

  echo "Doing Homebrew install"
  BREWFILE="$( basedir )/package_lists/brew_packages.txt"

  brew bundle install --upgrade --file $BREWFILE

  echo "Running brew doctor"
  brew doctor
}
