#!/bin/bash

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${RED}"
echo "╔════════════════════════════════════════╗"
echo "║      macOS Sleep Manager UNINSTALL     ║"
echo "║    Rimozione completa dal sistema      ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

echo "⚠️  Attenzione: Questo script rimuoverà:"
echo "   - I file ~/.sleep, ~/.wakeup, ~/.sleeplog"
echo "   - I log storici"
echo "   - Il servizio sleepwatcher"
echo "   - Le ottimizzazioni energetiche (ripristinando i default Apple)"
echo ""
echo "Sei sicuro di voler procedere? [y/N]"
read -r confirm

if [[ ! "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Operazione annullata."
    exit 0
fi

echo ""

# 1. Stop Servizi
echo -e "${CYAN}[1/5] Arresto servizi...${NC}"
if command -v brew &> /dev/null; then
    brew services stop sleepwatcher
fi
pkill sleepwatcher
echo "Servizi arrestati."

# 2. Ripristino PMSET (Risparmio Energetico)
echo -e "${CYAN}[2/5] Ripristino impostazioni energetiche Apple (richiede password)...${NC}"
echo "Ripristino: hibernatemode 3, powernap 1, tcpkeepalive 1"
sudo pmset -a hibernatemode 3
sudo pmset -a powernap 1
sudo pmset -a tcpkeepalive 1
echo "Impostazioni energetiche ripristinate ai valori di fabbrica."

# 3. Rimozione File
echo -e "${CYAN}[3/5] Rimozione file script e log...${NC}"
rm -f "$HOME/.sleep"
rm -f "$HOME/.wakeup"
rm -f "$HOME/.sleeplog"
rm -f "$HOME/.sleeplog_history"
rm -f "$HOME/.sleep_killed_apps"
rm -f "$HOME/.sleep_pending_apps"
rm -f "$HOME/.sleep.backup"
rm -f "$HOME/.wakeup.backup"
echo "File rimossi."

# 4. Pulizia Alias dalla Shell
echo -e "${CYAN}[4/5] Pulizia configurazione shell...${NC}"
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then SHELL_CONFIG="$HOME/.zshrc"; fi
if [ -f "$HOME/.bashrc" ]; then SHELL_CONFIG="$HOME/.bashrc"; fi

if [ -n "$SHELL_CONFIG" ]; then
    # Crea backup
    cp "$SHELL_CONFIG" "${SHELL_CONFIG}.bak_sleepmanager"
    
    # Rimuove le righe aggiunte dall'installer
    # Nota: Questo metodo è conservativo. Se l'utente ha modificato le righe, potrebbe non trovarle.
    sed -i '' '/# macOS Smart Sleep Manager/d' "$SHELL_CONFIG"
    sed -i '' '/alias sleeplog=/d' "$SHELL_CONFIG"
    
    echo "Alias rimosso da $SHELL_CONFIG (Backup salvato in ${SHELL_CONFIG}.bak_sleepmanager)"
else
    echo "Nessun file di configurazione shell trovato, salto questo passaggio."
fi

# 5. Rimozione pacchetto (Opzionale)
echo -e "${CYAN}[5/5] Vuoi disinstallare anche il pacchetto 'sleepwatcher' via brew? [y/N]${NC}"
read -r remove_brew
if [[ "$remove_brew" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    brew uninstall sleepwatcher
    echo "Pacchetto sleepwatcher rimosso."
else
    echo "Pacchetto sleepwatcher mantenuto."
fi

echo ""
echo -e "${GREEN}✅ Disinstallazione completata con successo!${NC}"
echo "Il tuo Mac è tornato alle condizioni originali."