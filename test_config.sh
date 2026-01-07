#!/bin/bash
# test_config.sh - Test di caricamento configurazione

CONF_FILE="$HOME/.sleepmanager.conf"
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[1;36m'
NC='\033[0m'

echo -e "${CYAN}=== Test Caricamento Config ===${NC}\n"

# 1. Verifica esistenza
if [ ! -f "$CONF_FILE" ]; then
    echo -e "${RED}✗ File non trovato: $CONF_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✓ File trovato${NC}"
echo ""

# 2. Mostra contenuto raw
echo -e "${CYAN}Contenuto raw del file:${NC}"
cat "$CONF_FILE"
echo ""

# 3. Test caricamento con source
echo -e "${CYAN}Test caricamento variabili:${NC}"
source "$CONF_FILE"

echo -e "  ENABLE_NOTIFICATIONS = '$ENABLE_NOTIFICATIONS'"
echo -e "  SAFE_QUIT_MODE = '$SAFE_QUIT_MODE'"
echo -e "  CPU_THRESHOLD = '$CPU_THRESHOLD'"
echo -e "  WHITELIST = '$WHITELIST'"
echo -e "  HEAVY_APPS = '$HEAVY_APPS'"
echo ""

# 4. Verifica variabili popolate
ERRORS=0

if [ -z "$ENABLE_NOTIFICATIONS" ]; then
    echo -e "${RED}✗ ENABLE_NOTIFICATIONS vuoto${NC}"
    ((ERRORS++))
fi

if [ -z "$SAFE_QUIT_MODE" ]; then
    echo -e "${RED}✗ SAFE_QUIT_MODE vuoto${NC}"
    ((ERRORS++))
fi

if [ -z "$CPU_THRESHOLD" ]; then
    echo -e "${RED}✗ CPU_THRESHOLD vuoto${NC}"
    ((ERRORS++))
fi

# Whitelist e Heavy possono essere vuoti, ma devono esistere come variabile
if [ -z "${WHITELIST+x}" ]; then
    echo -e "${RED}✗ WHITELIST non definito${NC}"
    ((ERRORS++))
fi

if [ -z "${HEAVY_APPS+x}" ]; then
    echo -e "${RED}✗ HEAVY_APPS non definito${NC}"
    ((ERRORS++))
fi

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Tutte le variabili sono caricate correttamente${NC}"
else
    echo -e "${RED}✗ $ERRORS errori trovati${NC}"
    echo ""
    echo -e "${CYAN}Soluzione:${NC}"
    echo -e "  Riesegui l'installer: ${CYAN}~/.sleepmanager_install${NC}"
fi

echo ""

# 5. Test parsing liste
if [ -n "$WHITELIST" ]; then
    echo -e "${CYAN}App in Whitelist:${NC}"
    IFS='|' read -ra APPS <<< "$WHITELIST"
    for app in "${APPS[@]}"; do
        echo -e "  • $app"
    done
fi

if [ -n "$HEAVY_APPS" ]; then
    echo ""
    echo -e "${CYAN}Heavy Apps:${NC}"
    IFS='|' read -ra APPS <<< "$HEAVY_APPS"
    for app in "${APPS[@]}"; do
        echo -e "  • $app"
    done
fi