if [[ $USER == "root" ]]; then
  echo "Please do not run as root."
  exit 1
fi

# Useful variables
wine_install_path="$HOME/.local/share/affinity-wine"
wine_version="affinity-photo3-wine9.13-part3"
# Defining text styles for readablity
bold=$(tput bold); normal=$(tput sgr0)


# Files and directories to delete
setup_script="affinity-linux-setup.sh"
uninstall_script="affinity-linux-uninstall.sh"
files=("$HOME/.local/bin/rum" "$HOME/.local/bin/launch-affinity" "temp_wineinstall" "/opt/wines/$wine_version" "$wine_install_path" "$HOME/.local/share/applications/Affinity Photo 2.desktop" "$HOME/.local/share/applications/Affinity Designer 2.desktop" "$HOME/.local/share/applications/Affinity Publisher 2.desktop")

# Checking if file exists and asking to delete it
function CheckFiles {
  IFS=""
  # Checking if any marked files exist
  declare -i counter=0
  for file in ${files[*]}; do
    if [[ -f "$file" ]] || [[ -d "$file" ]]; then
      counter+=1
    fi
  done
  if (( $counter == 0 )); then
    echo "No files marked for deletion found."
    exit
  fi
  
  # Listing files to be deleted
  echo "Files to be deleted:"
  for file in ${files[*]}; do
    if [[ -f "$file" ]] || [[ -d "$file" ]]; then
      echo "- $file"
    fi
  done
  Ask "Proceed?" && RemoveFiles
  unset IFS
}
function RemoveFiles {
  for file in ${files[*]}; do
    if [[ -f "$file" ]] || [[ -d "$file" ]]; then
      if [[ -w "$file" ]]; then
        RemoveFile "$file"
      else
        SudoRemoveFile "$file"
      fi
    fi
  done
}
function RemoveFile {
  rm -rf "$1" &&
  return
  Error "Could not delete '$1'"
}
function SudoRemoveFile {
  echo "Removing '$1' requires root privileges."
  sudo rm -rf "$1" &&
  return
  Error "Could not delete '$1'"
}

function DeleteScripts {
  if [[ -f "$setup_script" ]]; then
    Ask "Delete affinity linux setup script?" && RemoveFile "$setup_script"
  fi; if [[ -f "$uninstall_script" ]] then
    Ask "Delete affinity linux uninstall script?" && RemoveFile "$uninstall_script"
  fi
}

function Error {
  echo "${bold}ERROR${normal}: $1. If this is an issue, please report it."
  exit 1
}

function Ask {
  while true; do
    read -p "$* [y/n]: " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
    esac
  done
}

# Running functions
CheckFiles
if [[ ${files[*]} == "" ]]; then
  echo "No files found marked for deletion."
fi
DeleteScripts
