#!/usr/bin/env bash
##
# josht
# @jo-wen
##
# start wireguard/mullvad (get a wg connection)
##

# need sudo because all wireguard stuff is root eyes only
function auth {
  if [ "$EUID" -ne 0 ]; then
   echo -e "need rootygooty"
   exit 1
  fi
}

# some var
MULLVAD_CONF_DIR="/etc/wireguard/"

# check if wg is connected
# exit if yes

# this verifies acct, sets up config files and dirs.
# conf files live in /etc/wireguard/ all root only perms.
function install_configs {
  set -e
  echo -e "\n## installing configs"
  ./mullvad-wg.sh
}

# display_stats
function display_stats {
  echo -e "\n## check with mullvad"
  curl -s https://am.i.mullvad.net/json | jq .

  echo -e "\n## wg output"
  wg
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
}

# connect to a specific country
function connect_to {
  # country codes
  declare -A countries
  countries["albania"]="al"
  countries["austria"]="at"
  countries["aus"]="au"
  countries["australia"]="au"
  countries["belgium"]="be"
  countries["bulgaria"]="bg"
  countries["brazil"]="br"
  countries["canada"]="ca"
  countries["swiss"]="ch"
  countries["switzerland"]="ch"
  countries["colombia"]="co"
  countries["czech"]="cz"
  countries["germany"]="de"
  countries["deutschland"]="de"
  countries["denmark"]="dk"
  countries["estonia"]="ee"
  countries["spain"]="es"
  countries["finland"]="fi"
  countries["france"]="fr"
  countries["uk"]="gb"
  countries["greece"]="gr"
  countries["china"]="hk"
  countries["hongkong"]="hk"
  countries["croatia"]="hr"
  # hu bud had no working configs but assuming thats hungary-budapest
  countries["ireland"]="ie"
  countries["israel"]="il"
  countries["italy"]="it"
  countries["japan"]="jp"
  countries["latvia"]="lv"
  countries["mexico"]="mx"
  countries["netherlands"]="nl"
  countries["norway"]="no"
  countries["newzealand"]="nz"
  countries["nz"]="nz"
  countries["poland"]="pl"
  countries["portugal"]="pt"
  countries["romania"]="ro"
  countries["serbia"]="rs"
  countries["sweden"]="se"
  countries["singapore"]="sg"
  countries["slovakia"]="sk"
  countries["ukraine"]="ua"
  countries["usa"]="us"
  countries["us"]="us"
  countries["southafrica"]="za"
  countries["africa"]="za"

  # country input, needs to match one of the above countries
  country="$1"

  # if the country name exists as a key in the array
  if [ "${countries[$country]}" ]; then
    # make array of conf files that match the country key value
    conf_files=($(find "$MULLVAD_CONF_DIR" -maxdepth 1 -type f -name "${countries["$country"]}"\*))
    # choose a conf at random within the conf file array
    country_conf="${conf_files[1 + RANDOM % ${#conf_files[@]}]}"

    # connect
    echo -e "\n## connecting to $country_conf"
    wg-quick up "$country_conf"
  else
    echo -e "\n## cant find $country"
    echo -e "\n### countries ###"
    echo -e "${countries}"
  fi
}

# list all available countries
function list_countries {

  declare -A list_country
  list_country["albania"]="al"
  list_country["austria"]="at"
  list_country["aus"]="au"
  list_country["australia"]="au"
  list_country["belgium"]="be"
  list_country["bulgaria"]="bg"
  list_country["brazil"]="br"
  list_country["canada"]="ca"
  list_country["swiss"]="ch"
  list_country["switzerland"]="ch"
  list_country["colombia"]="co"
  list_country["czech"]="cz"
  list_country["germany"]="de"
  list_country["deutschland"]="de"
  list_country["denmark"]="dk"
  list_country["estonia"]="ee"
  list_country["spain"]="es"
  list_country["finland"]="fi"
  list_country["france"]="fr"
  list_country["uk"]="gb"
  list_country["greece"]="gr"
  list_country["china"]="hk"
  list_country["hongkong"]="hk"
  list_country["croatia"]="hr"
  # hu bud had no working configs but assuming thats hungary-budapest
  list_country["ireland"]="ie"
  list_country["israel"]="il"
  list_country["italy"]="it"
  list_country["japan"]="jp"
  list_country["latvia"]="lv"
  list_country["mexico"]="mx"
  list_country["netherlands"]="nl"
  list_country["norway"]="no"
  list_country["newzealand"]="nz"
  list_country["nz"]="nz"
  list_country["portugal"]="pt"
  list_country["romania"]="ro"
  list_country["serbia"]="rs"
  list_country["sweden"]="se"
  list_country["singapore"]="sg"
  list_country["slovakia"]="sk"
  list_country["ukraine"]="ua"
  list_country["usa"]="us"
  list_country["us"]="us"
  list_country["southafrica"]="za"
  list_country["africa"]="za"

  echo -e "\n## available countries"
  echo -e "$(echo "${!list_country[@]}" | tr ' ' '\n' | sort)"
  # for i in "${!list_country[@]}"; do
    # echo -e "$i"
  # done
}

# check wg for connection and take it down
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
    echo -e "Usage:"
    echo -e "sudo ./mullvadctl.sh -l"
    echo -e "sudo ./mullvadctl.sh -c japan"
    echo
    echo -e "default behavior: bring down current connection, bring up new random connection"
    echo
    echo -e "Options:"
    echo -e "  -h,      this help"
    echo -e "  -l,      list countries"
    echo -e "  -s,      display connection information"
    echo -e "  -i,      install/refresh config files"
    echo -e "  -d,      take down connection"
    echo -e "  -c,      connect to specific country"
    exit 0
}

# main
while getopts ":hilc:ds" opt; do
  case "$opt" in
    h)
      display_help
      exit
      ;;
    i)
      auth
      down
      install_configs
      exit
      ;;
    l)
      list_countries
      exit
      ;;
    d)
      auth
      down
      exit
      ;;
    c)
      auth
      country="$OPTARG"
      down
      connect_to "$country"
      display_stats
      exit
      ;;
    s)
      display_stats
      exit
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

auth;
down;
connect;
display_stats
