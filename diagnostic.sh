#!/bin/bash
# diagnostic.sh - Verifica l'installazione di Sleep Manager

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${CYAN}=== Sleep Manager Diagnostic ===${NC}\n"

# 1. Verifica file principali
echo -e "${CYAN}[1] File Principali${NC}"
files=(
    "$HOME/.sleepmanager.conf"
    "$HOME/.sleep"
    "$HOME/.wakeup"
    "$HOME/.sleeplog"
    "$HOME/.sleepmanager_editor"
    "$HOME/.config_editor_auto"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        if [ -x "$file" ]; then
            echo -e "  ${GREEN}✓${NC} $file (eseguibile)"
        else
            echo -e "  ${YELLOW}⚠${NC} $file (non eseguibile)"
        fi
    else
        echo -e "  ${RED}✗${NC} $file (mancante)"
    fi
done

echo ""

# 2. Verifica contenuto config
echo -e "${CYAN}[2] Contenuto Configurazione${NC}"
if [ -f "$HOME/.sleepmanager.conf" ]; then
    source "$HOME/.sleepmanager.conf"
    echo -e "  ${CYAN}WHITELIST:${NC} '$WHITELIST'"
    echo -e "  ${CYAN}HEAVY_APPS:${NC} '$HEAVY_APPS'"
    echo -e "  ${CYAN}CPU_THRESHOLD:${NC} $CPU_THRESHOLD"
    echo -e "  ${CYAN}NOTIFICATIONS:${NC} $ENABLE_NOTIFICATIONS"
    echo -e "  ${CYAN}SAFE_QUIT:${NC} $SAFE_QUIT_MODE"
else
    echo -e "  ${RED}✗ File di config mancante!${NC}"
fi

echo ""

# 3. Test script config_editor_auto
echo -e "${CYAN}[3] Test config_editor_auto${NC}"
if [ -x "$HOME/.config_editor_auto" ]; then
    echo -e "  ${GREEN}✓${NC} Script eseguibile"
    
    # Test sintassi
    bash -n "$HOME/.config_editor_auto" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Sintassi corretta"
    else
        echo -e "  ${RED}✗${NC} Errori di sintassi"
    fi
else
    echo -e "  ${RED}✗${NC} Script non eseguibile o mancante"
    echo -e "  ${YELLOW}Soluzione:${NC} chmod +x ~/.config_editor_auto"
fi

echo ""

# 4. Verifica pmset
echo -e "${CYAN}[4] Configurazione Kernel${NC}"
TCPKA=$(pmset -g | grep tcpkeepalive | awk '{print $2}')
STANDBY=$(pmset -g | grep "standby " | awk '{print $2}')
echo -e "  tcpkeepalive: $TCPKA (dovrebbe essere 0)"
echo -e "  standby: $STANDBY (dovrebbe essere 1)"

echo ""

# 5. Verifica sleepwatcher
echo -e "${CYAN}[5] Sleepwatcher Service${NC}"
if brew services list | grep -q "sleepwatcher.*started"; then
    echo -e "  ${GREEN}✓${NC} Servizio attivo"
else
    echo -e "  ${RED}✗${NC} Servizio non attivo"
    echo -e "  ${YELLOW}Soluzione:${NC} brew services restart sleepwatcher"
fi

echo ""

# 6. Test apertura file picker
echo -e "${CYAN}[6] Test AppleScript (File Picker)${NC}"
echo -e "  Prova ad aprire il file picker? (y/n)"
read -r response
if [ "$response" = "y" ]; then
    FILE_PATH=$(osascript 2>/dev/null <<'EOF'
        tell application "Finder"
            activate
            try
                set selectedFile to choose file with prompt "TEST - Seleziona un'app qualsiasi" of type {"com.apple.application-bundle"} default location (path to applications folder)
                return POSIX path of selectedFile
            on error
                return ""
            end try
        end tell
EOF
    )
    
    if [ -n "$FILE_PATH" ]; then
        echo -e "  ${GREEN}✓${NC} File picker funzionante"
        echo -e "  ${CYAN}Hai selezionato:${NC} $FILE_PATH"
    else
        echo -e "  ${YELLOW}⚠${NC} Test annullato dall'utente"
    fi
fi

echo ""
echo -e "${CYAN}=== Fine Diagnostica ===${NC}"
echo ""
echo -e "Se ci sono errori:"
echo -e "1. Esegui: ${YELLOW}chmod +x ~/.config_editor_auto ~/.sleepmanager_editor${NC}"
echo -e "2. Reinstalla: ${YELLOW}~/.sleepmanager_install${NC}"
echo -e "3. Riavvia SwiftBar"