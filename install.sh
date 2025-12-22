#!/bin/bash

# Colori
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔════════════════════════════════════════╗"
echo "║   macOS Sleep Manager Installer v4.0  ║"
echo "║        Professional Edition           ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

# 1. Check e Copy Script
echo -e "${BLUE}[STEP 1] Copia file di sistema...${NC}"
if [ ! -f "sleep" ] || [ ! -f "config.template" ]; then
    echo -e "${RED}Errore: File mancanti nella cartella.${NC}"; exit 1
fi

cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog"
echo -e "${GREEN}✓ Script installati.${NC}"

# 2. Configurazione
echo -e "\n${BLUE}[STEP 2] Gestione Configurazione...${NC}"
CONF_PATH="$HOME/.sleepmanager.conf"

if [ ! -f "$CONF_PATH" ]; then
    cp config.template "$CONF_PATH"
    echo "Creato nuovo file di configurazione in: $CONF_PATH"
else
    echo "File di configurazione esistente trovato. Lo mantengo."
    # Qui potremmo fare un merge intelligente, ma per sicurezza non sovrascriviamo
fi

# 3. Auto-Discovery App
echo -e "\n${BLUE}[STEP 3] Scansione App Pesanti...${NC}"
KNOWN_APPS=("Google Chrome" "Firefox" "Adobe Photoshop" "Adobe Premiere Pro" "DaVinci Resolve" "Docker" "Spotify" "Slack" "Microsoft Teams" "Discord" "Xcode" "IntelliJ IDEA" "Visual Studio Code" "Blender" "Unity")
DETECTED=""
COUNT=0

for app in "${KNOWN_APPS[@]}"; do
    if [ -d "/Applications/$app.app" ] || [ -d "$HOME/Applications/$app.app" ]; then
        if [ -z "$DETECTED" ]; then DETECTED="$app"; else DETECTED="$DETECTED|$app"; fi
        ((COUNT++))
    fi
done

echo -e "Rilevate ${YELLOW}$COUNT${NC} app pesanti ($DETECTED)."
echo "Aggiorno la configurazione..."

# Aggiorna SOLO la riga HEAVY_APPS nel file .conf
sed -i.bak "s/^HEAVY_APPS=.*/HEAVY_APPS=\"$DETECTED\"/" "$CONF_PATH"
rm "$CONF_PATH.bak" 2>/dev/null
echo -e "${GREEN}✓ Configurazione aggiornata.${NC}"

# 4. Homebrew & Sleepwatcher
echo -e "\n${BLUE}[STEP 4] Servizi...${NC}"
if ! command -v brew &> /dev/null; then echo "Homebrew mancante!"; exit 1; fi
if ! brew list sleepwatcher &> /dev/null; then brew install sleepwatcher; fi

pkill -9 sleepwatcher 2>/dev/null
brew services restart sleepwatcher
sleep 2

# 5. PMSET (Hybrid)
echo -e "\n${BLUE}[STEP 5] Ottimizzazione Energetica...${NC}"
echo "Scegli modalità:"
echo " [1] Standard (Apple Default)"
echo " [2] Ultra Saver (Ibernazione immediata)"
echo " [3] Hybrid Smart (Consigliata v4.0) ⭐"
read -r mode

echo "Richiesta password sudo..."
case $mode in
  2) sudo pmset -a hibernatemode 25; sudo pmset -a powernap 0 ;;
  3) sudo pmset -a hibernatemode 3; sudo pmset -a standby 1; sudo pmset -a standbydelayhigh 900; sudo pmset -a standbydelaylow 300; sudo pmset -a powernap 0 ;;
  *) sudo pmset -a hibernatemode 3; sudo pmset -a standbydelayhigh 86400 ;;
esac

# 6. Alias
SHELL_CONFIG=""
[ -f "$HOME/.zshrc" ] && SHELL_CONFIG="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && SHELL_CONFIG="$HOME/.bashrc"
if [ -n "$SHELL_CONFIG" ]; then
  if ! grep -q "alias sleeplog=" "$SHELL_CONFIG"; then
    echo -e "\nalias sleeplog=\"~/.sleeplog\"" >> "$SHELL_CONFIG"
  fi
fi

echo -e "\n${GREEN}✓ INSTALLAZIONE v4.0 COMPLETATA!${NC}"
echo "File config: $CONF_PATH"
echo "Esegui 'source $SHELL_CONFIG' per finire."