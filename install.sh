#!/bin/bash
# install.sh v4.3 - Intelligent Auto-Discovery

CYAN='\033[1;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   macOS Sleep Manager v4.3 - AI SCAN   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"

# --- MOTORE DI CLASSIFICAZIONE ---
echo -e "${BLUE}[1/6] Analisi applicazioni installate...${NC}"

# Database Conoscenze
W_DB=("WhatsApp" "Telegram" "Signal" "Spotify" "Music" "Slack" "Messages")
H_DB=("WebStorm" "IntelliJ IDEA" "PyCharm" "PhpStorm" "Docker" "Xcode" "Visual Studio Code" "Adobe Photoshop" "Adobe Premiere Pro" "DaVinci Resolve" "Figma" "TablePlus")

DETECTED_W=""
DETECTED_H=""

# Scansione Whitelist
for app in "${W_DB[@]}"; do
    if [ -d "/Applications/$app.app" ]; then DETECTED_W="${DETECTED_W}${DETECTED_W:+|}$app"; fi
done

# Scansione Heavy Apps
for app in "${H_DB[@]}"; do
    if [ -d "/Applications/$app.app" ]; then DETECTED_H="${DETECTED_H}${DETECTED_H:+|}$app"; fi
done

echo -e "   - Whitelist rilevata: ${YELLOW}${DETECTED_W:-Nessuna}${NC}"
echo -e "   - Heavy Apps rilevate: ${YELLOW}${DETECTED_H:-Nessuna}${NC}"

# --- INSTALLAZIONE ---
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp config_editor "$HOME/.sleepmanager_editor"
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" "$HOME/.sleepmanager_editor"

# Creazione Config con i dati rilevati
cat <<EOF > "$HOME/.sleepmanager.conf"
# macOS Sleep Manager Config
ENABLE_NOTIFICATIONS="true"
SAFE_QUIT_MODE="true"
CPU_THRESHOLD="1.0"
WHITELIST="$DETECTED_W"
HEAVY_APPS="$DETECTED_H"
EOF

# --- STRATEGIA ENERGETICA ---
echo -e "\n${BLUE}[2/6] Strategia Energetica...${NC}"
echo "1) STANDARD  2) ULTRA  3) HYBRID (Default)"
read -p "Scegli [3]: " p_mode
case ${p_mode:-3} in
  1) sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 86400 ;;
  2) sudo pmset -a hibernatemode 25 powernap 0 tcpkeepalive 0 ;;
  3) sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 900 standbydelaylow 300 powernap 0 ;;
esac

# --- FIX PERMESSI & ALIAS ---
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null
RC_FILE="$HOME/.zshrc"; [[ "$(basename "$SHELL")" == "bash" ]] && RC_FILE="$HOME/.bashrc"
if ! grep -q "alias sleeplog=" "$RC_FILE"; then
    echo -e "\nalias sleeplog=\"~/.sleeplog\"\nalias sleepconf=\"~/.sleepmanager_editor\"" >> "$RC_FILE"
fi

brew services restart sleepwatcher
echo -e "\n${GREEN}✓ INSTALLAZIONE COMPLETATA!${NC} (Usa 'source $RC_FILE')"