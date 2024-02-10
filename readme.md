# mullvadctl

tools to make mullvad easier to use on unsupported systems (written with arch/pacman in mind)


## install

```
git clone https://github.com/jo-wen/mullvadctl.git
cd mullvadctl
sudo ./mullvad_install.sh
```
**mullvad_install.sh** checks that you have the correct dependencies and (using pacman) checks for packages.
asks to install packages with pacman if you are missing any.
installs the official mullvad-wg.sh script along with some signature files.
checks that the download is verifiable using gpg and the signatures.
runs **mullvad-wg.sh** to install mullvad configs into /etc/wireguard/.


## usage

refresh configs (runs mullvad-wg.sh)
```
sudo ./mullvadctl.sh -i
```

brings down current connection and starts a new random connection
```
sudo ./mullvadctl.sh
```

brings down current connection and starts a new connection based on country given.
this is matching the config name to the country and choosing one of the matches at random.
```
sudo ./mullvadctl.sh -c japan
sudo ./mullvadctl.sh -c germany
sudo ./mullvadctl.sh -c brazil
```

bring down a connection
```
sudo ./mullvadctl.sh -d
```

check connection status
```
./mullvadctl.sh -s
```

list the available countries (this is hard coded at the moment)
```
./mullvadctl.sh -l
```

aliased to mvc on my systems
```
sudo mvc
mvc -l
mvc -h
sudo mvc -d
sudo mvc -c canada
```
