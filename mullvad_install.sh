#!/bin/bash
##
# josht
##
# installs mullvad stuff into whatever dir its in.
# if first time running go uncomment the requirements line
##

# install the following:
# - curl
# - jq
# - openresolv
# - wireguard
#
# requirements: uncomment to install
# sudo pacman -Syu curl jq openresolv wireguard-tools
#
# check the right commands exist in the system
function check_depends {
  echo -e "\n## checking system and pacman"
  if ! command -v curl jq wg &> /dev/null; then
   echo -e "\nmissing a dependency"
  fi

  # might as well check pacman too while we're here
  if ! pacman -Qk curl jq openresolv wireguard-tools; then
    echo -e "\nmissing pacman packages"
  fi
}

function get_configs {
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

check_depends
get_configs
