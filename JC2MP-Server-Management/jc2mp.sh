#!/bin/bash
#
# JC2-MP server managing script which simplifies server installation,
# update and administration. It uses GNU Screen which should be
# installed on your system in order to use it.
#
# Copyright (c) 2014 Andrejs Mivreniks <gim@fastmail.fm>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

jc2mp_steamid="261140"
#jc2mp_steamid="261140 -beta publicbeta"

steamcmd_dir="$HOME/.steamcmd"
jc2mp_server_dir="$HOME/jc2mp-server"
session_name="jc2mp"
config_file="$HOME/.config/jc2mp-server-manager/server-manager.conf"

RED="\033[1;31m"
GREEN="\033[1;32m"
WHITE="\033[1;37m"
NC="\033[0m"

if [ -f "$config_file" ]; then
  source $config_file
fi
if [ -z "$EDITOR" ]; then
  EDITOR="nano"
fi
if [ -z "$(command -v $EDITOR)" ]; then
  EDITOR="vi"
fi
if [ -z "$(command -v screen)" ]; then
  echo -e "${RED}Looks like you don't have GNU Screen installed.${NC}"
  echo -e "${RED}You won't be able to start manage your server!${NC}"
fi

installSteamcmd() {
  if [ -s "$steamcmd_dir/steamcmd.sh" ]; then
    $steamcmd_dir/steamcmd.sh +login anonymous +force_install_dir $jc2mp_server_dir +app_update $jc2mp_steamid validate +quit
  else
    mkdir -p "$steamcmd_dir"
    cd "$steamcmd_dir"
    wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
    tar -xvzf steamcmd_linux.tar.gz > /dev/null 2>&1
    rm steamcmd_linux.tar.gz
  fi
}

updateServer() {
  $steamcmd_dir/steamcmd.sh +login anonymous +force_install_dir $jc2mp_server_dir +app_update $jc2mp_steamid +quit
  if [ ! -f "$jc2mp_server_dir/libstdc++.so.6" ]; then
    ln -s $steamcmd_dir/linux32/libstdc++.so.6 $jc2mp_server_dir/libstdc++.so.6
  fi
  if [ -n "$(screen -ls $session_name | grep $session_name)" ]; then
    echo -en "${WHITE}Would you like to restart server now? [y/N] ${NC}"; read answer
    case $answer in
      [yY]*)
        stopServer
        startServer
        showStatus
        ;;
    esac
  fi
}

changeOptions() {
  cd "$jc2mp_server_dir"
  cp default_config.lua config.lua

  echo -en "${WHITE}Max players (5000) = ${NC}"; read max_players
  echo -en "${WHITE}Port (7777) = ${NC}"; read bind_port
  echo -en "${WHITE}Server name ('JC2-MP Server') = ${NC}"; read name
  echo -en "${WHITE}Description ('No description available.') = ${NC}"; read description
  if [ -n "$max_players" ]; then
    sed -i "s/MaxPlayers.*/MaxPlayers = $max_players,/g" config.lua
  fi
  if [ -n "$bind_port" ]; then
    sed -i "s/BindPort.*/BindPort = $bind_port,/g" config.lua
  fi
  if [ -n "$name" ]; then
    sed -i "s/Name.*/Name = \"$name\",/g" config.lua
  fi
  if [ -n "$description" ]; then
    sed -i "s/Description.*/Description = \"$description\",/g" config.lua;
  fi

  echo -e "${WHITE}New configuration applied!${NC}"
  
}

startServer() {
  echo -e "${WHITE}Starting server...${NC}"
  cd "$jc2mp_server_dir"
  screen -dmS $session_name ./Jcmp-Server
}

stopServer() {
  echo -e "${WHITE}Stopping server...${NC}"
  screen -S $session_name -X quit
  while [ -n "$(screen -ls $session_name | grep $session_name)" ]; do
    sleep 1
  done
}

showStatus() {
  if [ -n "$(screen -ls $session_name | grep $session_name)" ]; then
    echo -e "${WHITE}Server status:${GREEN} up${NC}"
  else
    echo -e "${WHITE}Server status:${RED} down${NC}"
  fi
}

cmdLoop() {
  echo -e "${WHITE}Welcome to the JC2-MP server management tool!${NC}"
  echo -e "${WHITE}You can terminate this script safely, it won't stop the server.${NC}"
  echo -e "${WHITE}Script can be launched only when you need to manage your server.${NC}"
  echo -e "${WHITE}Type 'help' for list of available commands.${NC}"
  showStatus
  while true; do
    echo -en "${GREEN}>> ${NC}"; read cmd
    case $cmd in
      "start")
        startServer
        showStatus
        ;;

      "stop")
        stopServer
        showStatus
        ;;

      "restart")
        stopServer
        startServer
        showStatus
        ;;

      "update")
        installSteamcmd
        updateServer
        ;;

      "config")
        changeOptions
        ;;

      "editconfig")
        ${EDITOR} $jc2mp_server_dir/config.lua
        ;;

      "status")
        showStatus
        ;;

      "send "*)
        echo -e "${WHITE}Sending:${NC} ${cmd#* }"
        screen -S jc2mp -X stuff "${cmd#* }
"
        ;;

      "console")
        screen -x $session_name
        ;;

      "help")
        echo -e "${WHITE}start       - start JC2-MP server${NC}"
        echo -e "${WHITE}stop        - stop server${NC}"
        echo -e "${WHITE}restart     - restart server${NC}"
        echo -e "${WHITE}status      - show server status${NC}"
        #echo -e "${WHITE}config      - basic server config editor${NC}"
        echo -e "${WHITE}editconfig  - open 'config.lua' using ${EDITOR}${NC}"
        echo -e "${WHITE}send [text] - sends text to the server console (http://wiki.jc-mp.com/Server/Console)${NC}"
        echo -e "${WHITE}console     - open server console ${RED}[!]${WHITE}(press ctrl+a and then ctrl+d to exit without terminating the server)${NC}"
        echo -e "${WHITE}update      - validates/updates the server${NC}"
        echo -e "${WHITE}exit        - exit from the current command line${NC}"
        ;;

      "exit")
        exit 0;;

      *)
        echo -e "${WHITE}Unknown command! Type 'help' for the list of commands.${NC}"
    esac
  done
}

main() {
  if [ ! -f "$config_file" ]; then
    echo -e "${WHITE}Looks like you're running this script for the first time.${NC}"
    echo -e "${WHITE}Do you want to install JC2-MP server now? [Y/n]${NC}"
    echo -en "${GREEN}>> ${NC}"; read answer
    case $answer in
      [nN]*)
        exit 0;;
    esac

    echo -e "${WHITE}Where do you want your server to be installed?${NC}" 
    echo -e "${WHITE}Press Enter to use '$jc2mp_server_dir' or specify your own ABSOLUTE path${NC}"
    echo -en "${GREEN}>> ${NC}"; read answer
    if [ -n "$answer" ]; then
      $jc2mp_server_dir = $answer
    fi

    # Write script configuration
    mkdir -p ${config_file%/*}
    echo "jc2mp_server_dir=$jc2mp_server_dir" > $config_file

    # First install process
    echo -e "${WHITE}Installing steamcmd...${NC}"
    installSteamcmd
    echo -e "${WHITE}Installing JC2-MP server...${NC}"
    updateServer
    changeOptions
    echo ""
  fi
  cmdLoop
}
main
# vim:set ts=2 sw=2 et:

