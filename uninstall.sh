#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "⚠️  DISINSTALLAZIONE SLEEP MANAGER v4.0"
echo "Verranno rimossi script, log, servizi e configurazioni."
echo "Vuoi procedere? [y/N]"
read -r confirm
if [[ ! "$confirm" =~ ^[yY] ]]; then exit 0; fi

# Stop Servizi
brew services stop sleepwatcher
pkill sleepwatcher

# Ripristino Apple Defaults
echo "Ripristino pmset..."
sudo pmset -a hibernatemode 3
sudo pmset -a powernap 1
sudo pmset -a tcpkeepalive 1

# Rimozione File
echo "Rimozione file..."
rm -f "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog"
rm -f "$HOME/.sleeplog_history" "$HOME/.sleep_killed_apps" "$HOME/.sleep_pending_apps"
rm -f "$HOME/.sleep.backup"

# Rimozione Config
echo "Vuoi rimuovere anche il file di configurazione (~/.sleepmanager.conf)? [y/N]"
read -r rm_conf
if [[ "$rm_conf" =~ ^[yY] ]]; then
    rm -f "$HOME/.sleepmanager.conf"
    echo "Configurazione rimossa."
else
    echo "Configurazione mantenuta."
fi

echo -e "${GREEN}✓ Disinstallazione completata.${NC}"