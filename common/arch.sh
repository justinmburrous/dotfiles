function arch_install(){
  echo "Running Arch install"

  echo "Checking $arch_packages list"

  sudo pacman -Syu --noconfirm --needed - < $( basedir )/package_lists/arch.txt


  # Set wifi regdomain to US
  sudo iw reg set US

  hyprland_setup
  
  echo "Done Arch install"
}

function hyprland_setup(){
  echo "Configuring Hyprland"

  ln -fs "$( basedir )/hyprland/hyprland.conf" "$HOME/.config/hypr/hyprland.conf"

  echo "Hyprland config done"
}
