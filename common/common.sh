function create_base_directories(){
  echo "Creating base directories"
  mkdir -p "$HOME/bin"
  mkdir -p "$HOME/workspace"
}

function install_scripts(){
  echo "Installing scripts"
  local scripts_dir="$( basedir )/scripts"
  if [ ! -d "$scripts_dir" ]; then
    echo "No scripts directory found, skipping"
    return 0
  fi
  for f in "$scripts_dir"/*; do
    ln -fs "$f" "$HOME/bin/$(basename "$f")"
  done
}

