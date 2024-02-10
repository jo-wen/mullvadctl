#!/bin/bash
##
# josht
# @jo-wen
##
# start wireguard/mullvad (get a wg connection)
##

# need sudo because all wireguard stuff is root eyes only
if [ "$EUID" -ne 0 ]; then
  echo -e "need rootygooty"
  exit 1
fi

# some var
MULLVAD_CONF_DIR="/etc/wireguard/"

# check if wg is connected
# exit if yes

# run mullvad-wg.sh
# this verifies acct, sets up config files and dirs.
# this needs root (it prompts) because it installs wireguard configs
# to /etc/wireguard/ all root only perms.
function mullvad-wg {
  set -e
  echo -e "\n## installing configs"
  ./mullvad-wg.sh
}

# choose a random config
function choose_random_config {
  set -e
  files=($(find "$MULLVAD_CONF_DIR" -maxdepth 1 -type f -name '*.conf'))

  # errors if no conf files
  if [ "${#files[@]}" -eq 0 ]; then
    echo -e "no conf files"
    return 1
  fi

  # echo -e "picking random conf"
  random_index=$((RANDOM % ${#files[@]}))
  random_conf="${files[$random_index]}"

  echo -e "$random_conf"
}


# connect using a random conf.
# verify/show connection with mullvad api.
# show wg details.
function connect {
  set -e
  echo -e "\n## connecting"
  wg-quick up "$(choose_random_config)"

  echo -e "\n## check with mullvad"
  curl -s https://am.i.mullvad.net/json | jq .

  echo -e "\n## wg output"
  wg
}

# check wg for connection and take down if there is one already
function down {
  if [[ $(wg | grep "peer") ]]; then
    echo -e "\n## dropping current wg connection"
    # conf is too fragile here but this is easy
    conf=$(wg | grep interface | awk '{print $2}')
    wg-quick down "$conf"
  fi
}


# help menu
function display_help {
    echo -e "Usage: sudo $0 [options]"
    echo -e "default behavior: bring down current connection, bring up new random connection"
    echo -e "Options:"
    echo -e "  -h, --help     this"
    echo -e "  -i, --install  install/refresh config files"
    echo -e "  -d, --down     take down connection"
    exit 0
}

# main
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            display_help
            ;;
        -i|--install)
            mullvad-wg
            exit 0
            ;;
        -d|--down)
            down
            exit 0
            ;;
        *)
            break
            ;;
    esac
    shift
done

down;
connect
