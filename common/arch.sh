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

  hyprland_setup

  # Set wifi regdomain to US
  sudo iw reg set US

  echo "Done Arch install"
}

function hyprland_setup(){
  echo "Configuring Hyprland"

  mkdir -p ~/.config/hypr
  ln -fs "$( basedir )/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"
  ln -fs "$( basedir )/hyprland/hypridle.conf" "$HOME/.config/hypr/hypridle.conf"
  ln -fs "$( basedir )/hyprland/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf"

  echo "Hyprland config done"
}
