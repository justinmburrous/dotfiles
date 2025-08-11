function arch_server_install(){
  echo "Running Arch (server) install"

  echo "Checking $arch_packages list"

  sudo pacman -Syu --noconfirm --needed - < $( basedir )/package_lists/arch_common.txt
  sudo pacman -Syu --noconfirm --needed - < $( basedir )/package_lists/arch_server.txt
  
  echo "Done Arch (server) install"
}

function arch_install(){
  echo "Running Arch Install"

  echo "Checking $arch_packages list"

  sudo pacman -Syu --noconfirm --needed - < $( basedir )/package_lists/arch_common.txt
  sudo pacman -Syu --noconfirm --needed - < $( basedir )/package_lists/arch_desktop.txt

  hyprland_setup

  # Set wifi regdomain to US
  sudo iw reg set US

  echo "Done Arch install"
}

function hyprland_setup(){
  echo "Configuring Hyprland"

  ln -fs "$( basedir )/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"

  echo "Hyprland config done"
}
