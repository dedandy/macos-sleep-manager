#!/bin/bash
# install.sh v4.5.1 - Hard Freeze Edition

CYAN='\033[1;36m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'

clear
echo -e "${CYAN}install.sh v4.5.1 - Configurazione Hard Freeze${NC}"

# --- STEP 1: Deep Scan (Invariato) ---
echo -e "${BLUE}[1/6] Analisi Applicazioni...${NC}"
ALL_APPS=$(ls /Applications | sed 's/\.app//g')
DETECTED_W=""; DETECTED_H=""
while read -r app; do
    [ -z "$app" ] && continue
    if [[ "$app" =~ (Chrome|Firefox|Edge|WebStorm|IntelliJ|Xcode|Docker|Teams|ChatGPT|OneDrive|Dropbox) ]]; then
        DETECTED_H="${DETECTED_H}${DETECTED_H:+|}$app"
    elif [[ "$app" =~ (WhatsApp|Telegram|Spotify|Music|Mail|Messages) ]]; then
        DETECTED_W="${DETECTED_W}${DETECTED_W:+|}$app"
    fi
done <<< "$ALL_APPS"

# --- STEP 2: Copia file ---
cp sleep wakeup sleeplog config_editor $HOME/
chmod +x $HOME/sleep $HOME/wakeup $HOME/sleeplog $HOME/config_editor

# --- STEP 3: Il Cuore Energetico (MODIFICATO) ---
# --- SEZIONE PMSET v4.5.2 ---
echo -e "${BLUE}[3/6] Configurazione Standby Intelligente...${NC}"
sudo pmset -a standby 1
sudo pmset -a standbydelayhigh 3600 # Entra in Deep Sleep dopo 1 ora (60 min)
sudo pmset -a standbydelaylow 1800  # Se la batteria è già bassa, entra dopo 30 min
sudo pmset -a hibernatemode 3        # Permette risveglio rapido se entro l'ora
sudo pmset -a powernap 0
sudo pmset -a tcpkeepalive 0        # Impedisce i risvegli Wi-Fi (la chiave del successo!)
sudo pmset -a proximitywake 0
sudo pmset -a ttyskeepawake 0

# --- STEP 4-6: Config e Alias ---
[ ! -f "$HOME/.sleepmanager.conf" ] && cat <<EOF > "$HOME/.sleepmanager.conf"
ENABLE_NOTIFICATIONS="true"
SAFE_QUIT_MODE="true"
CPU_THRESHOLD="1.0"
WHITELIST="$DETECTED_W"
HEAVY_APPS="$DETECTED_H"
EOF

sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null
brew services restart sleepwatcher
echo -e "${GREEN}✓ Sistema pronto. Ibernazione forzata a 2 ore.${NC}"