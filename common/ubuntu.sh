function ubuntu_install(){
  echo "Running Ubuntu install"

  echo "installing PPAs list"
  ppa_list=$( basedir )/package_lists/ppa_list.txt

  while read ppa_repo; do
    echo "Adding $ppa_repo"
    sudo add-apt-repository $ppa_repo
  done < $ppa_list

  xargs sudo apt-get install -U -y < package_lists/apt.txt

  sudo apt-get upgrade -y
}
