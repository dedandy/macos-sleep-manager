#!/bin/bash
# install.sh v4.3 - Intelligent Wizard

CYAN='\033[1;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   macOS Sleep Manager v4.3 - WIZARD    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"

# --- STEP 1: ANALISI INTELLIGENTE ---
echo -e "\n${BLUE}[1/6] Analisi sistema e applicazioni...${NC}"

W_DB=("WhatsApp" "Telegram" "Signal" "Spotify" "Music" "Slack" "Messages" "Mail")
H_DB=("WebStorm" "IntelliJ IDEA" "PyCharm" "PhpStorm" "Docker" "Xcode" "Visual Studio Code" "Adobe Photoshop" "Adobe Premiere Pro" "DaVinci Resolve" "Figma" "TablePlus" "Google Chrome" "Firefox")

DETECTED_W=""
DETECTED_H=""

for app in "${W_DB[@]}"; do
    if [ -d "/Applications/$app.app" ]; then DETECTED_W="${DETECTED_W}${DETECTED_W:+|}$app"; fi
done

for app in "${H_DB[@]}"; do
    if [ -d "/Applications/$app.app" ]; then DETECTED_H="${DETECTED_H}${DETECTED_H:+|}$app"; fi
done

echo -e "   - Trovate in Whitelist: ${YELLOW}${DETECTED_W:-Nessuna}${NC}"
echo -e "   - Trovate in Heavy Apps: ${YELLOW}${DETECTED_H:-Nessuna}${NC}"

# --- STEP 2: COPIA FILE ---
echo -e "\n${BLUE}[2/6] Installazione script...${NC}"
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp config_editor "$HOME/.sleepmanager_editor"
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" "$HOME/.sleepmanager_editor"

# --- STEP 3: WIZARD STRATEGIA ENERGETICA ---
echo -e "\n${BLUE}[3/6] Configurazione Energetica (pmset)...${NC}"
echo -e "Scegli la strategia per la batteria:"
echo -e " 1) ${YELLOW}STANDARD${NC} (Risveglio istantaneo)"
echo -e " 2) ${YELLOW}ULTRA${NC}    (Ibernazione totale, consumo zero)"
echo -e " 3) ${YELLOW}HYBRID${NC}   (Bilanciato - Consigliato) ⭐"
read -p "Opzione [3]: " p_mode
p_mode=${p_mode:-3}

case $p_mode in
  1) sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 86400 ;;
  2) sudo pmset -a hibernatemode 25 powernap 0 tcpkeepalive 0 ;;
  3) sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 900 standbydelaylow 300 powernap 0 ;;
esac

# --- STEP 4: SOGLIA CPU ---
echo -e "\n${BLUE}[4/6] Configurazione Sensibilità...${NC}"
read -p "Soglia CPU per chiusura app (Default 1.0%): " p_cpu
p_cpu=${p_cpu:-1.0}

# Scrittura Config Finale
cat <<EOF > "$HOME/.sleepmanager.conf"
# macOS Sleep Manager Config v4.3
ENABLE_NOTIFICATIONS="true"
SAFE_QUIT_MODE="true"
CPU_THRESHOLD="$p_cpu"
WHITELIST="$DETECTED_W"
HEAVY_APPS="$DETECTED_H"
EOF

# --- STEP 5: PERMESSI E FIRMA ---
echo -e "\n${BLUE}[5/6] Sblocco sicurezza macOS...${NC}"
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null

# --- STEP 6: ALIAS E AGGIORNAMENTO ---
RC_FILE="$HOME/.zshrc"; [[ "$(basename "$SHELL")" == "bash" ]] && RC_FILE="$HOME/.bashrc"
if ! grep -q "alias sleeplog=" "$RC_FILE"; then
    echo -e "\nalias sleeplog=\"~/.sleeplog\"\nalias sleepconf=\"~/.sleepmanager_editor\"" >> "$RC_FILE"
fi

brew services restart sleepwatcher
echo -e "\n${GREEN}✓ INSTALLAZIONE COMPLETATA!${NC}"
echo -e "------------------------------------------------"
echo -e "1. Esegui: ${CYAN}source $RC_FILE${NC}"
echo -e "2. Assicurati che ${CYAN}$(which sleepwatcher)${NC} sia in 'Accesso completo al disco'"
echo -e "3. Usa ${YELLOW}sleepconf${NC} per modificare le liste in ogni momento."