#!/bin/bash
# install.sh v4.3.1 - Deep Scan & Wizard

CYAN='\033[1;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   macOS Sleep Manager v4.3.1 - DEEP    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"

# --- STEP 1: SCANSIONE INTELLIGENTE DEL DISCO ---
echo -e "\n${BLUE}[1/6] Analisi profonda delle applicazioni...${NC}"

# Recupera TUTTE le app in Applications
ALL_APPS=$(ls /Applications | sed 's/\.app//g')

DETECTED_W=""
DETECTED_H=""

while read -r app; do
    [ -z "$app" ] && continue
    
    # LOGICA HEAVY APPS (Browser, IDE, Cloud, Grafica, Electron pesanti)
    if [[ "$app" =~ (Chrome|Firefox|Edge|Opera|WebStorm|IntelliJ|PyCharm|Xcode|Code|Adobe|Resolve|Final|Docker|Teams|ChatGPT|OneDrive|Google\ Drive|Dropbox|Creative|TablePlus) ]]; then
        DETECTED_H="${DETECTED_H}${DETECTED_H:+|}$app"
    
    # LOGICA WHITELIST (Messaggistica, Musica, Mail)
    elif [[ "$app" =~ (WhatsApp|Telegram|Signal|Slack|Spotify|Music|Mail|Messages|Discord) ]]; then
        DETECTED_W="${DETECTED_W}${DETECTED_W:+|}$app"
    fi
done <<< "$ALL_APPS"

echo -e "   - Trovate in Whitelist: ${YELLOW}${DETECTED_W:-Nessuna}${NC}"
echo -e "   - Trovate in Heavy Apps: ${YELLOW}${DETECTED_H:-Nessuna}${NC}"

# --- STEP 2: INSTALLAZIONE FILE ---
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp config_editor "$HOME/.sleepmanager_editor"
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" "$HOME/.sleepmanager_editor"

# --- STEP 3: WIZARD ENERGETICO ---
echo -e "\n${BLUE}[3/6] Strategia Batteria...${NC}"
echo -e " 1) STANDARD  2) ULTRA  3) HYBRID (Consigliato)"
read -p "Opzione [3]: " p_mode
case ${p_mode:-3} in
  1) sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 86400 ;;
  2) sudo pmset -a hibernatemode 25 powernap 0 tcpkeepalive 0 ;;
  3) sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 900 standbydelaylow 300 powernap 0 ;;
esac

# --- STEP 4: SOGLIA CPU ---
read -p "Soglia CPU per chiusura app (Default 1.0%): " p_cpu
p_cpu=${p_cpu:-1.0}

# Scrittura Config
cat <<EOF > "$HOME/.sleepmanager.conf"
# macOS Sleep Manager Config v4.3.1
ENABLE_NOTIFICATIONS="true"
SAFE_QUIT_MODE="true"
CPU_THRESHOLD="$p_cpu"
WHITELIST="$DETECTED_W"
HEAVY_APPS="$DETECTED_H"
EOF

# --- STEP 5: SICUREZZA & ALIAS ---
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null
RC_FILE="$HOME/.zshrc"; [[ "$(basename "$SHELL")" == "bash" ]] && RC_FILE="$HOME/.bashrc"
if ! grep -q "alias sleeplog=" "$RC_FILE"; then
    echo -e "\nalias sleeplog=\"~/.sleeplog\"\nalias sleepconf=\"~/.sleepmanager_editor\"" >> "$RC_FILE"
fi

brew services restart sleepwatcher
echo -e "\n${GREEN}✓ INSTALLAZIONE COMPLETATA!${NC} (Esegui 'source $RC_FILE')"