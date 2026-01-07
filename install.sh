#!/bin/bash
# install.sh v4.6 - Full Transparency Edition

CYAN='\033[1;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   macOS Sleep Manager v4.6 - WIZARD    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"

# --- STEP 1: DEEP SCAN ---
echo -e "\n${BLUE}[1/6] Analisi sistema e applicazioni...${NC}"
ALL_APPS=$(ls /Applications | sed 's/\.app//g')
DETECTED_W=""
DETECTED_H=""

while read -r app; do
    [ -z "$app" ] && continue
    if [[ "$app" =~ (Chrome|Firefox|Edge|Opera|WebStorm|IntelliJ|PyCharm|Xcode|Code|Adobe|Resolve|Final|Docker|Teams|ChatGPT|OneDrive|Google\ Drive|Dropbox|Creative) ]]; then
        DETECTED_H="${DETECTED_H}${DETECTED_H:+|}$app"
    elif [[ "$app" =~ (WhatsApp|Telegram|Signal|Slack|Spotify|Music|Mail|Messages|Discord) ]]; then
        DETECTED_W="${DETECTED_W}${DETECTED_W:+|}$app"
    fi
done <<< "$ALL_APPS"

# --- STEP 2: COPIA FILE ---
echo -e "${BLUE}[2/6] Installazione script...${NC}"
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp config_editor "$HOME/.sleepmanager_editor"
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" "$HOME/.sleepmanager_editor"

# --- STEP 3: CONFIGURAZIONE KERNEL (HARD FREEZE) ---
echo -e "${BLUE}[3/6] Configurazione Risparmio Energetico...${NC}"
sudo pmset -a standby 1
sudo pmset -a standbydelayhigh 3600 # Deep Sleep dopo 1 ora
sudo pmset -a standbydelaylow 1800
sudo pmset -a hibernatemode 3        # Risveglio rapido entro l'ora, ibernazione dopo
sudo pmset -a powernap 0
sudo pmset -a tcpkeepalive 0        # Blocca i consumi Wi-Fi notturni
sudo pmset -a proximitywake 0
sudo pmset -a ttyskeepawake 0

# --- STEP 4: CONFIGURAZIONE SOGLIA CPU ---
[ ! -f "$HOME/.sleepmanager.conf" ] && cat <<EOF > "$HOME/.sleepmanager.conf"
ENABLE_NOTIFICATIONS="true"
SAFE_QUIT_MODE="true"
CPU_THRESHOLD="1.0"
WHITELIST="$DETECTED_W"
HEAVY_APPS="$DETECTED_H"
EOF

# --- STEP 5: SICUREZZA ---
echo -e "${BLUE}[5/6] Firma digitale e permessi...${NC}"
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null

# --- STEP 6: ALIAS ---
RC_FILE="$HOME/.zshrc"
[[ "$(basename "$SHELL")" == "bash" ]] && RC_FILE="$HOME/.bashrc"
if ! grep -q "alias sleeplog=" "$RC_FILE"; then
    echo -e "\nalias sleeplog=\"~/.sleeplog\"" >> "$RC_FILE"
    echo "alias sleepconf=\"~/.sleepmanager_editor\"" >> "$RC_FILE"
fi

brew services restart sleepwatcher

echo -e "\n${GREEN}✓ VERSIONE 4.6 INSTALLATA!${NC}"
echo -e "Ora il sistema traccerà anche i consumi a schermo acceso."