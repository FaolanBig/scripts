#!/bin/bash

# Voraussetzungen
sudo apt update
sudo apt install -y lib32gcc-s1 lib32stdc++6 curl wget unzip tar screen

# Neuen Benutzer anlegen
sudo adduser --disabled-password --gecos "" cs2server

# SteamCMD herunterladen und entpacken
sudo -u cs2server bash <<EOF
cd ~
mkdir -p steamcmd && cd steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz

./steamcmd.sh +login anonymous +force_install_dir ~/cs2-ds +app_update 730 validate +quit
EOF

echo "installation complete"
echo "➡ now create a GSLT under https://steamcommunity.com/dev/managegameservers"
echo "➡ then change the file start_cs2.sh with your creds"
