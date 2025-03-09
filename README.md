# Affinity Linux Setup
A shell based on the [Affinity Wine Documentation](https://affinity.liz.pet/) by wanesty. Allows you install and use the Affinity software suite by Serif on Linux.

## What it does
- Checks if dependencies are installed.
- Installs [Rum](https://gitlab.com/xkero/rum) and [launch-affinity](https://github.com/sihawido/affinity-linux-setup/blob/main/launch-affinity) to `~/.local/bin/`
- Downloads, compiles and installs [ElementalWarrior's fork of Wine](https://gitlab.winehq.org/ElementalWarrior/wine) to `/opt/wines/`.
- Creates a Wineprefix with dependencies in `~/.local/share/wine-affinity`.
- Installs [DXVK](https://github.com/doitsujin/dxvk) and [VKD3D](https://github.com/HansKristian-Work/vkd3d-proton) using Winetricks.
- Lets you start the installer executable.
- Creates .desktop shortcuts.

## Instructions
1. Get a `Windows/System32/WinMetadata` folder from a Windows install or a VM.
2. Download the installer executable from Affinity.
3. Inside a terminal, run
```bash
curl -Os https://raw.githubusercontent.com/sihawido/affinity-linux-setup/main/affinity-linux-setup.sh && bash affinity-linux-setup.sh
```
> **Warning**: Always be careful when running scripts from the Internet.
4. Follow every step in the terminal (y - stands for yes, n - stands for no).
5. Launch the Affinity software using your DE or by typing `launch-affinity` in the terminal.

## Notes
- To scale the apps you can run `rum "affinity-photo3-wine9.13-part3" "$HOME/.local/share/affinity-wine" winecfg`, go to the 'Graphics' tab in the opened window and change the 'dpi' under 'Screen resolution' to something higher.

## Uninstalling
1. Inside a terminal, run
```bash
curl -Os https://raw.githubusercontent.com/sihawido/affinity-linux-setup/main/affinity-linux-uninstall.sh && bash affinity-linux-uninstall.sh
```
2. Remove the installed dependencies, listed in `missing_packages.txt`, using your package manager.
