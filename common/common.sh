function create_base_directories(){
  echo "Creating base directories"
  mkdir -p "$HOME/bin"
  mkdir -p "$HOME/workspace"
}

function install_scripts(){
  echo "Installing scripts"
  for f in ./scripts/*; do
    ln -fs "$( basedir )/scripts/$(basename $f)" "$HOME/bin/$(basename $f)"
  done
}

