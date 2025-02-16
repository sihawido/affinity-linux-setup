if [[ $USER == "root" ]]; then
  echo "Please do not run as root."
  exit 1
fi

# Useful variables
wine_install_path="$HOME/.local/share/affinity-wine"
wine_version="affinity-photo3-wine9.13-part3"
# Defining text styles for readablity
bold=$(tput bold); normal=$(tput sgr0)

function CheckRum {
  if [[  -f "$HOME/.local/bin/rum" ]]; then
    echo "Found installation of Rum."
    Ask "Delete Rum?" && RemoveRum
  fi
}
function RemoveRum {
  rm -f "$HOME/.local/bin/rum" &&
  return
  Error "Could not delete Rum"
}

function CheckWine {
  if [[ -d "temp_wineinstall" ]]; then
    echo "Found download of ElementalWarrior's Wine."
    Ask "Delete ElementalWarrior's Wine?" && RemoveDownload
  fi
  if [[ -d "/opt/wines/$wine_version" ]]; then
    echo "Found installation of ElementalWarrior's Wine."
    Ask "Delete ElementalWarrior's Wine?" && RemoveWine
  fi
}
function RemoveDownload {
  rm -rf "temp_wineinstall/" &&
  break
  Error "Could not delete 'temp_wineinstall'"
}
function RemoveWine {
  echo "Deleting '/opt/wines/$wine_version' requires root privileges." &&
  sudo rm -rf "/opt/wines/$wine_version" &&
  return
  Error "Could not delete ElementalWarrior's Wine"
}

function CheckWineprefix {
  if [[ -d "$wine_install_path" ]]; then
    Ask "Delete the Affinity Wineprefix?" && RemoveWineprefix
  fi
}
function RemoveWineprefix {
  rm -rf "$wine_install_path" &&
  return
  Error "Failed to delete Wineprefix"
}

function CheckShortcuts {
    shortcuts=("Affinity Photo 2.desktop" "Affinity Designer 2.desktop" "Affinity Publisher 2.desktop")
    IFS=""
    for shortcut in ${shortcuts[@]}; do
        if [[ -f "$HOME/.local/share/applications/$shortcut" ]]; then
            while :; do
                echo "Deleting '$shortcut'..." &&
                rm "$HOME/.local/share/applications/$shortcut" &&
                break
                Error "Could not delete $shortcut"
            done
        fi
    done
    unset IFS
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
      [Nn]*) echo "Skipping..." ; return 1 ;;
    esac
  done
}

# Running functions
CheckRum
CheckWine
CheckWineprefix
CheckShortcuts
echo; echo "${bold}All Done!${normal}"
