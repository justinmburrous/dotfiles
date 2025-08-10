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

if [ $SYSTEM_TYPE == "Linux" ]; then

  LINUX_OS_TYPE=$(grep "^NAME=" /etc/os-release | cut -d "=" -f2- | tr -d '"')

  if [ "$LINUX_OS_TYPE" == "Ubuntu" ]; then

    echo "Detected Ubuntu System"
    source ./common/ubuntu.sh
    ubuntu_install

  elif [ "$LINUX_OS_TYPE" == "Arch Linux" ]; then

    echo "Detected Arch system"
    source ./common/arch.sh
    arch_install

  else

    echo "Unknown Linux type, exiting"
    exit 1

  fi

elif [ $SYSTEM_TYPE == "Darwin" ]; then

  source ./common/osx.sh
  brew_install

else

  echo "Unknown uname $SYSTEM_TYPE"
  exit 1

fi

echo "installing common functions"

create_base_directories
install_utils
install_dev_tools
install_scripts

echo "Done!"
