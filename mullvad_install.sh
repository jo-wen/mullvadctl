#!/usr/bin/env bash
##
# josht
##
# installs mullvad stuff into whatever dir its in.
# built for use with pacman
##

# auth
function auth {
  if [ "$EUID" -ne 0 ]; then
   echo -e "need rootygooty"
   exit 1
  fi
}

# install the following:
# - curl
# - jq
# - openresolv
# - wireguard
#
function install_reqs {
  pacman -Syu curl jq openresolv wireguard-tools
}

# check for commands
function check_depends {
  echo -e "\n## checking system and pacman"
  if ! command -v curl jq wg &> /dev/null; then
   echo -e "\nmissing a dependency"
  fi

  # check pacman and ask to install
  if ! pacman -Qk curl jq openresolv wireguard-tools; then
    echo -e "\nmissing pacman packages"
    read -p "install missing packages [y/anything else]" yn
    if "$yn" == "y"; then
      install_reqs
    fi
  fi
}

function dl_script {
  # safety?
  set -e

  # downlaod configs and signatures
  echo -e "\n## dl mullvad-wg.sh"
  curl -o mullvad-wg.sh https://raw.githubusercontent.com/mullvad/mullvad-wg.sh/main/mullvad-wg.sh
  echo -e "\n## dl mullvad-wg.sh.asc"
  curl -o mullvad-wg.sh.asc https://raw.githubusercontent.com/mullvad/mullvad-wg.sh/main/mullvad-wg.sh.asc
  echo -e "\n## dl mullvad-code-signing.asc"
  curl -o mullvad-code-signing.asc https://mullvad.net/media/mullvad-code-signing.asc

  # verify signatures
  echo -e "\n## importing mullvad-code-signing.asc"
  gpg --import mullvad-code-signing.asc
  echo -e "\n## verifying mullvad-wg.sh.asc"
  gpg --verify mullvad-wg.sh.asc
}

# install conf files using mullvad script.
# conf files live in /etc/wireguard/ root only perms
function install_configs {
  set -e
  echo -e "\n## installing configs"
  ./mullvad-wg.sh
}

# main
auth
check_depends
dl_script
install_configs
