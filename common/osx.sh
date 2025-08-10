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
