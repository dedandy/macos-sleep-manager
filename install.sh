#!/bin/bash
# install.sh v4.2

CYAN='\033[1;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}Installazione macOS Sleep Manager v4.2...${NC}"

# 1. Copia file e Editor
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp config_editor "$HOME/.sleepmanager_editor"
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" "$HOME/.sleepmanager_editor"

# 2. Config Template
[ ! -f "$HOME/.sleepmanager.conf" ] && cp config.template "$HOME/.sleepmanager.conf"

# 3. Firma Digitale (Auto-Fix Privacy)
echo -e "${BLUE}Tento auto-firma per permessi Privacy...${NC}"
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null

# 4. Alias
RC_FILE="$HOME/.zshrc"
[[ "$(basename "$SHELL")" == "bash" ]] && RC_FILE="$HOME/.bashrc"
touch "$RC_FILE"

if ! grep -q "alias sleeplog=" "$RC_FILE"; then
    echo -e "\nalias sleeplog=\"~/.sleeplog\"" >> "$RC_FILE"
    echo "alias sleepconf=\"~/.sleepmanager_editor\"" >> "$RC_FILE"
fi

brew services restart sleepwatcher

echo -e "${GREEN}✓ Installazione completata.${NC}"
echo -e "Usa ${YELLOW}sleepconf${NC} per configurare e ${YELLOW}sleeplog${NC} per i log."