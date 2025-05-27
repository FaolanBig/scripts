#!/bin/bash

# instert GSLT (token) here
GSLT="YOUR-GSLT"

cd ~/cs2-ds/game/bin/linuxsteamrt64

./cs2 -dedicated \
+map de_dust2 \
+sv_setsteamaccount "$GSLT" \
+game_mode 1 +game_type 0 \
+sv_maxplayers 12
