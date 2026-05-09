#!/usr/bin/env bash

set -e
set -x

echo "Starting install"

function basedir(){
  dotfile_base_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
  echo $dotfile_base_dir
}

SYSTEM_TYPE=$(uname)
ARCH_TYPE="$(uname -p)"

source ./common/common.sh
source ./common/dev_tools.sh
source ./common/utils.sh

# if [ $SYSTEM_TYPE == "Linux" ]; then

#   LINUX_OS_TYPE=$(grep "^NAME=" /etc/os-release | cut -d "=" -f2- | tr -d '"')

#   if [ "$LINUX_OS_TYPE" == "Ubuntu" ]; then

#     echo "Detected Ubuntu System"
#     source ./common/ubuntu.sh
#     ubuntu_install

#     create_base_directories
#     install_utils
#     install_dev_tools
#     install_scripts

#   elif [ "$LINUX_OS_TYPE" == "Arch Linux" ]; then

#     echo "Detected Arch system"
#     source ./common/arch.sh

#     arch_common_install

#     HOSTNAME="$(hostname)"


#     if [ "$HOSTNAME" == "archserver" ]; then

#       arch_server_install

#     else

#       arch_install

#       create_base_directories
#       install_utils
#       install_dev_tools
#       install_scripts

#     fi

#   else

#     echo "Unknown Linux type, exiting"
#     exit 1

#   fi

# elif [ $SYSTEM_TYPE == "Darwin" ]; then

#   source ./common/osx.sh
#   brew_install

#   create_base_directories
#   install_utils
#   install_dev_tools
#   install_scripts

# else

#   echo "Unknown uname $SYSTEM_TYPE"
#   exit 1

# fi

echo "installing common functions"

EXTRAS_FILE="$( basedir )/extras.json"

if [ ! -f "$EXTRAS_FILE" ]; then
  echo "extras.json does not exist at $EXTRAS_FILE, skipping extra repos"
else
  echo "Found extras.json, processing extra repos"

  mkdir -p "$HOME/workspace"

  jq -c '.[]' "$EXTRAS_FILE" | while read -r entry; do
    repo=$(echo "$entry" | jq -r '.repo')
    directory=$(echo "$entry" | jq -r '.directory')
    target="$HOME/workspace/$directory"

    if [ -d "$target" ]; then
      echo "$target already exists, skipping clone"
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
  done
fi

echo "Done!"
