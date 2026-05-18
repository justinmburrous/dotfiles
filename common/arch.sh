function arch_common_install(){
  echo "Running Arch (common) install"

  sudo pacman -Syu --noconfirm --needed - < $( basedir )/package_lists/arch_common.txt

  echo "Done Arch (common) install"
}

function arch_server_install(){
  echo "Running Arch (server) install"

  echo "Checking $arch_packages list"

  sudo pacman -Syu --noconfirm --needed - < $( basedir )/package_lists/arch_server.txt
  
  echo "Done Arch (server) install"
}

function arch_install(){
  echo "Running Arch Install"

  echo "Checking $arch_packages list"

  sudo pacman -Syu --noconfirm --needed - < $( basedir )/package_lists/arch_desktop.txt

  echo "Starting services"
  sudo systemctl start NetworkManager.service
  sudo systemctl enable NetworkManager.service


  # Set wifi regdomain to US
  sudo iw reg set US

  echo "Done Arch install"
}
