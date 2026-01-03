#!/bin/bash
# uninstall.sh v4.5.2
echo "Disinstallazione e ripristino parametri originali..."
brew services stop sleepwatcher
# Valori standard Apple: standby a 24 ore (86400), rete attiva
sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 86400 standbydelaylow 86400 powernap 1 tcpkeepalive 1 proximitywake 1 ttyskeepawake 1
rm -f "$HOME/sleep" "$HOME/wakeup" "$HOME/sleeplog" "$HOME/config_editor" "$HOME/.sleepmanager.conf"
rm -f "$HOME/.sleeplog_history" "$HOME/.sleep_batt_start" "$HOME/.sleep_killed_apps"
echo "Sistema ripristinato ai valori di fabbrica."