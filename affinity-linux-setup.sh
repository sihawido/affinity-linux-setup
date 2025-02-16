if [[ $USER == "root" ]]; then
  echo "Please do not run as root."
  exit 1
fi

# Useful variables
wine_install_path="$HOME/.local/share/affinity-wine"
wine_version="affinity-photo3-wine9.13-part3"
# Defining text styles for readablity
bold=$(tput bold); normal=$(tput sgr0)
# Supported distros
supported_apt=("debian" "ubuntu" "linuxmint" "pop")
supported_dnf=("fedora" "ultramarine" "nobara")
supported_arch=("arch" "endeavouros")
# Required packages
req_apt=("bison" "dctrl-tools" "flex" "fontforge-nox" "freeglut3-dev" "gcc-mingw-w64-i686" "gcc-mingw-w64-x86-64" "gettext" "icoutils" "imagemagick" "libasound2-dev" "libcapi20-dev" "libcups2-dev" "libdbus-1-dev" "libfontconfig-dev" "libfreetype-dev" "libgettextpo-dev" "libgl-dev" "libglu1-mesa-dev" "libgnutls28-dev" "libgphoto2-dev" "libgstreamer-plugins-base1.0-dev" "libkrb5-dev" "libldap2-dev" "libncurses-dev" "libopenal-dev" "libosmesa6-dev" "libpcap0.8-dev" "libpcsclite-dev" "libpulse-dev" "librsvg2-bin" "libsdl2-dev" "libssl-dev" "libudev-dev" "libunwind-dev" "libusb-1.0-0-dev" "libv4l-dev" "libvulkan-dev" "libwayland-dev" "libx11-dev" "libxcomposite-dev" "libxcursor-dev" "libxext-dev" "libxfixes-dev" "libxi-dev" "libxinerama-dev" "libxkbfile-dev" "libxkbregistry-dev" "libxml-libxml-perl" "libxmu-dev" "libxrandr-dev" "libxrender-dev" "libxt-dev" "libxxf86dga-dev" "libxxf86vm-dev" "libz-mingw-w64-dev" "lzma" "ocl-icd-opencl-dev" "pkg-config" "quilt" "sharutils" "unicode-idna" "unixodbc-dev" "unzip" "git" "winetricks" "coreutils")

req_dnf=("dnf" "install" "alsa-lib-devel" "audiofile-devel" "autoconf" "bison" "chrpath" "cups-devel" "dbus-devel" "desktop-file-utils" "flex" "fontconfig-devel" "fontforge" "freeglut-devel" "freetype-devel" "gcc" "gettext-devel" "giflib-devel" "gnutls-devel" "gsm-devel" "gstreamer1-devel" "gstreamer1-plugins-base-devel" "icoutils" "libappstream-glib" "libgphoto2-devel" "libieee1284-devel" "libpcap-devel" "librsvg2" "librsvg2-devel" "libstdc++-devel" "libv4l-devel" "libX11-devel" "libXcomposite-devel" "libXcursor-devel" "libXext-devel" "libXi-devel" "libXinerama-devel" "libXmu-devel" "libXrandr-devel" "libXrender-devel" "libXxf86dga-devel" "libXxf86vm-devel" "make" "mesa-libGL-devel" "mesa-libGLU-devel" "mesa-libOSMesa-devel" "mingw32-FAudio" "mingw32-gcc" "mingw32-lcms2" "mingw32-libpng" "mingw32-libtiff" "mingw32-libxml2" "mingw32-libxslt" "mingw32-vkd3d" "mingw32-vulkan-headers" "mingw64-FAudio" "mingw64-gcc" "mingw64-lcms2" "mingw64-libpng" "mingw64-libtiff" "mingw64-libxml2" "mingw64-libxslt" "mingw64-vkd3d" "mingw64-vulkan-headers" "mingw64-zlib" "mpg123-devel" "ocl-icd-devel" "opencl-headers" "openldap-devel" "perl-generators" "pulseaudio-libs-devel" "sane-backends-devel" "SDL2-devel" "systemd-devel" "unixODBC-devel" "wine-mono" "git" "winetricks" "coreutils")

req_pacman=("alsa-lib" "alsa-plugins" "autoconf" "bison" "cups" "desktop-file-utils" "flex" "fontconfig" "freetype2" "gcc-libs" "gettext" "gnutls" "gst-plugins-bad" "gst-plugins-base" "gst-plugins-base-libs" "gst-plugins-good" "gst-plugins-ugly" "libcups" "libgphoto2" "libpcap" "libpulse" "libunwind" "libxcomposite" "libxcursor" "libxi" "libxinerama" "libxkbcommon" "libxrandr" "libxxf86vm" "mesa" "mesa-libgl" "mingw-w64-gcc" "opencl-headers" "opencl-icd-loader" "pcsclite" "perl" "samba" "sane" "sdl2" "unixodbc" "v4l-utils" "vulkan-headers" "vulkan-icd-loader" "wayland" "wine-gecko" "wine-mono" "git" "winetricks" "coreutils")

function CheckTempDir () {
  if [[ -d "temp/" ]]; then
    echo "\"temp\" directory found inside current directory. It needs to be removed or renamed for this script to work."
    Ask "Move \"temp/\" to trash?" && gio trash "temp" --force && return
    exit 1
  fi
}

# Checking OS compatability
function get_release {
  os_release="$(cat /etc/os-release)"
  echo "$(echo $os_release | sed "s/.* $1=//g" | sed "s/$1=\"//g" |  sed "s/ .*//g" | sed "s/\"//g")"
}
function CheckOS {
  OS="$(get_release ID)"; OS_name="$(get_release NAME)"
  if [[ ${supported_dnf[*]} =~ "$OS" ]]; then pm_install="dnf install"; pm="dnf"
  elif [[ ${supported_apt[*]} =~ "$OS" ]]; then pm_install="apt install"; pm="apt"
  elif [[ ${supported_arch[*]} =~ "$OS" ]]; then pm_install="pacman -S"; pm="pacman"
  else echo "$OS_name is not currently supported. Please open an issue to support it."; exit 1; fi
}

# Checking if required packages are installed
function CheckDependencies {
  installed_packages=($($pm list --installed))
  missing_packages=()
  if [[ $pm == "apt" ]]; then req_packages=("${req_apt[@]}")
  elif [[ $pm == "dnf" ]]; then req_packages=("${req_dnf[@]}")
  elif [[ $pm == "pacman" ]]; then req_packages=("${req_pacman[@]}")
  else Error "Unrecognized package manager"; fi
  
  for package in ${req_packages[@]}; do
    if [[ ${installed_packages[@]} != *$package* ]]; then
      missing_packages+=("$package")
    fi
  done
  
  if [[ $missing_packages != "" ]]; then
    echo "${bold}Run this command to install missing dependencies:${normal}"
    echo "sudo $pm_install ${missing_packages[@]}"
    
    if [[ ! -f "missing_packages.txt" ]]; then
      echo "${bold}Also printing missing packages to missing_packages.txt${normal} (in case you want to uninstall them later)." 
      echo ${missing_packages[@]} > "missing_packages.txt"
    fi
    exit 1
  fi
  echo Dependencies found.
}

function CheckRum {
  if [[  ! -f "$HOME/.local/bin/rum" ]]; then
    Ask "Install Rum?" && InstallRum
  else
    echo "Found existing installation of Rum."
    Ask "Reinstall Rum?" && InstallRum
  fi
}
function InstallRum {
  mkdir "temp" &&
  git clone "https://gitlab.com/xkero/rum" "temp/" 1>& /dev/null &&
  mkdir --parents "$HOME/.local/bin" &&
  cp "temp/rum" "$HOME/.local/bin" &&
  rm -rf "temp" &&
  chmod +x "$HOME/.local/bin/rum" &&
  return
  Error "Could not install Rum"
}

function CheckWine {
  if [[ -d "/opt/wines/$wine_version" ]]; then
    echo "Found installation of ElementalWarrior's Wine."
    Ask "Reinstall ElementalWarrior's Wine?" && InstallWine
  else
    Ask "Install ElementalWarrior's Wine?" && InstallWine
  fi
}
function InstallWine {
  # Checking and downloading wine
  while :; do
    if [[ -d "temp_wineinstall/" ]]; then
      Ask "Reuse previous download of ElementalWarrior's Wine?" && break
    fi
    declare -i available_space="$(df -P . | tail -1 | awk '{print $4}')"
    if (( available_space < 625000 )); then
      echo "Not enough available space on disk. Quitting"
      exit 1
    fi
    rm -rf "temp_wineinstall/" &&
    mkdir "temp_wineinstall" &&
    echo "Downloading... (this might take a while)" &&
    git clone "https://gitlab.winehq.org/ElementalWarrior/wine.git" "temp_wineinstall/" &&
    break
    Error "Could not download ElementalWarrior's Wine"
  done
  # Checking for previous installs
  if [[ -d "/opt/wines/$wine_version" ]]; then
    while :; do
      Ask "Deleting previous installation of ElementalWarrior's Wine will require sudo. Proceed?" &&
      echo "Deleting previous installation of ElementalWarrior's Wine..." &&
      sudo rm -rf "/opt/wines/$wine_version" &&
      break
      Error "Failed to delete previous installation of ElementalWarrior's Wine"
    done
  fi
  # Compiling and installing wine
  while :; do
    init_dir="$PWD" &&
    threads="$(nproc --all)" &&
    cd "temp_wineinstall/" &&
    git switch $wine_version 1>& /dev/null &&
    mkdir -p "winewow64-build/" "wine-install/" &&
    cd "winewow64-build/" &&
    echo "Configuring..." &&
    ../configure --prefix="$init_dir/temp_wineinstall/wine-install" --enable-archs=i386,x86_64 1>& /dev/null &&
    echo "Compiling... (this might take a while)" &&
    make --jobs $threads 1>& /dev/null &&
    echo "Installing..." &&
    make install --jobs $threads 1>& /dev/null &&
    cd "$init_dir" &&
    echo "Note: This step requires root privileges as it copies ElementalWarrior's Wine to ${bold}/opt/wines${normal}." &&
    Ask "Proceed?" && # Asking because sudo can time out
    sudo mkdir -p "/opt/wines" &&
    sudo cp -r "temp_wineinstall/wine-install" "/opt/wines/$wine_version" &&
    sudo ln -sf "/opt/wines/$wine_version/bin/wine" "/opt/wines/$wine_version/bin/wine64" &&
    break
    Error "Failed to compile ElementalWarrior's Wine"
  done
}

function CheckWineprefix {
  if [[ -d "$wine_install_path" ]]; then
    echo "Found existing Wineprefix for Affinity."
    Ask "Delete existing Wineprefix and set up a new one?" && Wineprefix
  else
    Ask "Create Wineprefix?" && Wineprefix
  fi
}
function Wineprefix {
  if [[ -d "$wine_install_path" ]]; then
    echo "Deleting existing Wineprefix..."
    rm -rf "$wine_install_path"
  fi
  mkdir "$wine_install_path" &&
  chown $USER "$wine_install_path" -R &&
  chmod 755 "$wine_install_path" -R &&
  echo "Initializing Wineprefix..." &&
  echo y | rum "$wine_version" "$wine_install_path" wineboot --init 1>& /dev/null &&
  echo "Installing .NET and fonts... (this might take a while)" &&
  rum "$wine_version" "$wine_install_path" winetricks --unattended dotnet48 corefonts allfonts 1>& /dev/null &&
  rum "$wine_version" "$wine_install_path" wine winecfg -v win11 1>& /dev/null &&
  return
  Error "Failed to configure Wineprefix"
}

function CheckWinMetadata {
  if [[ -d "$wine_install_path/drive_c/windows/system32/WinMetadata" ]]; then
    echo "Found WinMetadata in existing Wineprefix."
    Ask "Reinstall WinMetadata?" && WinMetadata
  else
    Ask "Install WinMetadata?" && WinMetadata
  fi
}

function WinMetadata {
  while :; do
    echo "Enter path to the 'WinMetadata' directory:"
    read -i "$PWD/" -e winmd_path
    winmd_path=${winmd_path%"/"} # in case path ends with "/" (test -d doesnt work if that is the case)
    winmd_path="$(echo "$winmd_path" | sed "s|\~\/|$HOME\/|g")" # in case path begins with ~/
    if [[ -d "$winmd_path" ]]; then
      cp -rf "$winmd_path" "$wine_install_path/drive_c/windows/system32/" &&
      break
      Error "Failed to copy WinMetadata"
    else
      echo "Invalid directory."; echo
    fi
  done
}

function InstallDXVK_VKD3D () {
  while :; do
    echo "Installing DXVK..." &&
    rum "$wine_version" "$wine_install_path" winetricks --unattended  dxvk 1>& /dev/null &&
    break
    Error "Failed to install DXVK"
  done
  while :; do
    echo "Installing VKD3D..." &&
    rum "$wine_version" "$wine_install_path" winetricks --unattended  vkd3d 1>& /dev/null &&
    rum "$wine_version" "$wine_install_path" winetricks --unattended  renderer=vulkan 1>& /dev/null &&
    break
    Error "Failed to install VKD3D"
  done
}

function StartExecutable {
  while :; do
    echo "Enter path to the affinity installer executable:"
    read -i "$PWD/" -e installer_path
    installer_path=${installer_path%"/"} # in case path ends with "/" (test -d doesnt work if that is the case)
    readlink -f "installer_path=$installer_path" # In case the path includes ~
    if [[ -f "$(echo $installer_path)" ]]; then
      rum "$wine_version" "$wine_install_path" wine "$installer_path" 1>& /dev/null &&
      break
      Error "Failed to start installer"
    else
      echo "Invalid file."; echo
    fi
  done
}

function CheckShortcuts {
  # Affinity Photo
  if [[ -f "$wine_install_path/drive_c/Program Files/Affinity/Photo 2/Photo.exe" ]]; then
    Photo2Shortcut
  fi
  if [[ -f "$wine_install_path/drive_c/Program Files/Affinity/Designer 2/Designer.exe" ]]; then
    Designer2Shortcut
  fi
  if [[ -f "$wine_install_path/drive_c/Program Files/Affinity/Publisher 2/Publisher.exe" ]]; then
    Publisher2Shortcut
  fi
}

function Photo2Shortcut {
  echo "Creating a .desktop shortcut for Affinity Photo 2."
  wget -q "https://raw.githubusercontent.com/sihawido/affinity-linux-setup/main/Affinity Photo 2.desktop" -P "temp/" &&
  sed "s|<HOME>|$HOME|g" -i "temp/Affinity Photo 2.desktop" &&
  cp -f "temp/Affinity Photo 2.desktop" "$HOME/.local/share/applications/" &&
  rm -r "temp/" &&
  return
  Error "Failed to create a .desktop shortcut for Affinity Photo 2."
}
function Designer2Shortcut {
  echo "Creating a .desktop shortcut for Affinity Designer 2."
  wget -q "https://raw.githubusercontent.com/sihawido/affinity-linux-setup/main/Affinity Designer 2.desktop" -P "temp/" &&
  sed "s|<HOME>|$HOME|g" -i "temp/Affinity Designer 2.desktop" &&
  cp -f "temp/Affinity Designer 2.desktop" "$HOME/.local/share/applications/" &&
  rm -r "temp/" &&
  return
  Error "Failed to create a .desktop shortcut for Affinity  2."
}
function Publisher2Shortcut {
  echo "Creating a .desktop shortcut for Affinity Publisher 2."
  wget -q "https://raw.githubusercontent.com/sihawido/affinity-linux-setup/main/Affinity Publisher 2.desktop" -P "temp/" &&
  sed "s|<HOME>|$HOME|g" -i "temp/Affinity Publisher 2.desktop" &&
  cp -f "temp/Affinity Publisher 2.desktop" "$HOME/.local/share/applications/" &&
  rm -r "temp/" &&
  return
  Error "Failed to create a .desktop shortcut for Affinity  2"
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
CheckOS
CheckDependencies
CheckTempDir
CheckRum
CheckWine
CheckWineprefix
CheckWinMetadata
Ask "Set up DXVK and VKD3D? (results in better performance and a bit less flickering)" && InstallDXVK_VKD3D
declare -i counter=0
while :; do
    if (( counter == 0 )); then question="Start the Affinity installer executable?"
    else question="Run another installer?"; fi

    if Ask "$question"; then
        StartExecutable
        counter+=1
    else
        break
    fi
done
CheckShortcuts
echo "${bold}All Done!${normal}"
