# mullvadctl

tools to make using mullvad on an unsupported system easier (written with arch/pacman in mind)

## table of contents

- [install](#install)
- [usage](#usage)

## install

to install clone this repo to any location and run the mullvad_install.sh script.
```
git clone https://github.com/jo-wen/mullvadctl.git
cd mullvadctl
sudo ./mullvad_install.sh
```
this script checks that you have the correct dependencies and (using pacman) checks for the packages.
will install packages for you but by default that line is commented out.
installs the official mullvad-wg.sh script along with some signature files.
checks that the download is verifiable using gpg and the signatures.


## usage

- first time use (or you want to refresh the configs)
```
sudo ./mullvadctl.sh -i
```

- start a random connection
```
sudo ./mullvadctl.sh
```

- bring down a connection without starting a new connection
```
sudo ./mullvadctl.sh -d
```
