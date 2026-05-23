#!/usr/bin/env bash

set -e
# set -x

echo "Starting install"

DOTFILE_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

function basedir(){
  echo "$DOTFILE_BASE_DIR"
}

SYSTEM_TYPE=$(uname)
ARCH_TYPE="$(uname -p)"

source "$DOTFILE_BASE_DIR/common/common.sh"
source "$DOTFILE_BASE_DIR/common/dev_tools.sh"
source "$DOTFILE_BASE_DIR/common/utils.sh"

FORCE=false
while getopts "f" opt; do
  case $opt in
    f) FORCE=true ;;
    *) echo "Usage: $0 [-f]"; exit 1 ;;
  esac
done

CURRENT_BRANCH=$(git -C "$DOTFILE_BASE_DIR" rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "main" ]; then
  if [ "$FORCE" = true ]; then
    echo "WARNING: Bypassing branch check — not on main (on '$CURRENT_BRANCH')"
  else
    echo "ERROR: You are not on \`main\` you must use \`-f\`"
    exit 1
  fi
fi

REMOTE_NAME=$(git -C "$DOTFILE_BASE_DIR" remote | grep -E '^(origin|github)$' | head -1)
if [ -z "$REMOTE_NAME" ]; then
  echo "ERROR: Could not find a remote named 'origin' or 'github'"
  exit 1
fi
git -C "$DOTFILE_BASE_DIR" fetch "$REMOTE_NAME" main --quiet
LOCAL=$(git -C "$DOTFILE_BASE_DIR" rev-parse HEAD)
REMOTE=$(git -C "$DOTFILE_BASE_DIR" rev-parse "$REMOTE_NAME/main")
if [ "$LOCAL" != "$REMOTE" ]; then
  if [ "$FORCE" = true ]; then
    echo "WARNING: Bypassing remote sync check — local is not up to date with origin/main"
  else
    echo "ERROR: Local repo is not up to date with origin/main. Please pull before installing, or use \`-f\` to bypass."
    exit 1
  fi
fi

if [ $SYSTEM_TYPE == "Linux" ]; then

  LINUX_OS_TYPE=$(grep "^NAME=" /etc/os-release | cut -d "=" -f2- | tr -d '"')

  if [ "$LINUX_OS_TYPE" == "Ubuntu" ]; then

    echo "Detected Ubuntu System"
    source ./common/ubuntu.sh
    ubuntu_install

    create_base_directories
    install_utils
    install_dev_tools
    install_scripts

  elif [ "$LINUX_OS_TYPE" == "Arch Linux" ]; then

    echo "Detected Arch system"
    source ./common/arch.sh

    arch_common_install

    HOSTNAME="$(hostname)"


    if [ "$HOSTNAME" == "archserver" ]; then

      arch_server_install

    else

      arch_install

      create_base_directories
      install_utils
      install_dev_tools
      install_scripts

    fi

  else

    echo "Unknown Linux type, exiting"
    exit 1

  fi

elif [ $SYSTEM_TYPE == "Darwin" ]; then

  source ./common/osx.sh
  brew_install

  create_base_directories
  install_utils
  install_dev_tools
  install_scripts

else

  echo "Unknown uname $SYSTEM_TYPE"
  exit 1

fi

echo "installing common functions"

EXTRAS_FILE="$( basedir )/extras.csv"

if [ ! -f "$EXTRAS_FILE" ]; then
  echo "extras.csv does not exist at $EXTRAS_FILE, skipping extra repos"
else
  echo "Found extras.csv, processing extra repos"

  mkdir -p "$HOME/workspace"

  while IFS=',' read -r directory repo; do
    target="$HOME/workspace/$directory"

    if [ -d "$target" ]; then
      echo "$target already exists, checking for uncommitted changes"
      if ! git -C "$target" diff --quiet || ! git -C "$target" diff --cached --quiet; then
        echo "ERROR: $target has uncommitted changes, aborting"
        exit 1
      fi
      echo "Pulling latest changes in $target"
      git -C "$target" pull --rebase
    else
      echo "Cloning $repo into $target"
      git clone "$repo" "$target"
    fi

    if [ -f "$target/install.sh" ]; then
      echo "Running $target/install.sh"
      ( cd "$target" && ./install.sh )
    else
      echo "No install.sh found in $target, skipping"
    fi
  done < "$EXTRAS_FILE"
fi

echo "Done!"
