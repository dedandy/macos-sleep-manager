#!/bin/bash
# install.sh v4.6.1
CYAN='\033[1;36m'; BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'
echo -e "${BLUE}[1/2] Copia componenti...${NC}"
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp config_editor "$HOME/.sleepmanager_editor"
cp config_editor_auto "$HOME/.config_editor_auto"
cp selector.scpt "$HOME/.selector.scpt"
cp install.sh "$HOME/.sleepmanager_install"

chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" \
         "$HOME/.sleepmanager_editor" "$HOME/.config_editor_auto" \
         "$HOME/.sleepmanager_install"

echo -e "${BLUE}[2/2] Configurazione Kernel...${NC}"
sudo pmset -a tcpkeepalive 0 proximitywake 0 standby 1 standbydelayhigh 3600
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null
brew services restart sleepwatcher
echo -e "${GREEN}✓ Installazione completata con successo.${NC}"
