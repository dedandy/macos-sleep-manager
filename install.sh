#!/bin/bash
# install.sh v4.2 - Interactive Wizard

CYAN='\033[1;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   macOS Sleep Manager Installer v4.2  ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"

# 1. Copia file e Editor
echo -e "\n${BLUE}[1/6] Installazione script e utility...${NC}"
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp config_editor "$HOME/.sleepmanager_editor"
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" "$HOME/.sleepmanager_editor"

# 2. Configurazione Iniziale
[ ! -f "$HOME/.sleepmanager.conf" ] && cp config.template "$HOME/.sleepmanager.conf"

# 3. Wizard Interattivo
echo -e "\n${BLUE}[2/6] Personalizzazione Energetica...${NC}"
echo -e "Scegli la strategia per la batteria:"
echo -e " 1) ${YELLOW}STANDARD${NC} (Risveglio istantaneo, risparmio base)"
echo -e " 2) ${YELLOW}ULTRA${NC}    (Ibernazione totale, consumo zero, risveglio lento)"
echo -e " 3) ${YELLOW}HYBRID${NC}   (Il meglio di entrambi - Consigliato) ⭐"
read -p "Opzione [3]: " p_mode
p_mode=${p_mode:-3}

case $p_mode in
  1) sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 86400 ;;
  2) sudo pmset -a hibernatemode 25 powernap 0 tcpkeepalive 0 ;;
  3) sudo pmset -a hibernatemode 3 standby 1 standbydelayhigh 900 standbydelaylow 300 powernap 0 ;;
esac

read -p "Soglia CPU per chiusura app (Default 1.0%): " p_cpu
p_cpu=${p_cpu:-1.0}
sed -i.bak "s/^CPU_THRESHOLD=.*/CPU_THRESHOLD=\"$p_cpu\"/" "$HOME/.sleepmanager.conf"
rm "$HOME/.sleepmanager.conf.bak" 2>/dev/null

# 4. Firma Digitale (Auto-Fix Privacy)
echo -e "\n${BLUE}[3/6] Autorizzazione Servizi (Firma Digitale)...${NC}"
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null

# 5. Configurazione Alias
echo -e "${BLUE}[4/6] Configurazione Shell...${NC}"
RC_FILE="$HOME/.zshrc"
[[ "$(basename "$SHELL")" == "bash" ]] && RC_FILE="$HOME/.bashrc"
touch "$RC_FILE"

if ! grep -q "alias sleeplog=" "$RC_FILE"; then
    echo -e "\nalias sleeplog=\"~/.sleeplog\"" >> "$RC_FILE"
    echo "alias sleepconf=\"~/.sleepmanager_editor\"" >> "$RC_FILE"
fi

# 6. Avvio Servizio
echo -e "${BLUE}[5/6] Riavvio Sleepwatcher...${NC}"
brew services restart sleepwatcher

echo -e "\n${GREEN}✓ INSTALLAZIONE COMPLETATA CON SUCCESSO!${NC}"
echo -e "------------------------------------------------"
echo -e "1. Esegui: ${CYAN}source $RC_FILE${NC}"
echo -e "2. Importante: Aggiungi ${CYAN}$(which sleepwatcher)${NC} in Privacy > Accesso disco"
echo -e "3. Comandi disponibili: ${YELLOW}sleeplog${NC} e ${YELLOW}sleepconf${NC}"