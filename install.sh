#!/bin/bash

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Banner
echo -e "${CYAN}"
echo "╔════════════════════════════════════════╗"
echo "║   macOS Smart Sleep Manager Installer ║"
echo "║      v3.1 - Full Sync Version         ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Funzioni utility
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# Check file
if [ ! -f "sleep" ] || [ ! -f "wakeup" ] || [ ! -f "sleeplog" ]; then
  print_error "File mancanti! Assicurati di essere nella directory corretta."
  exit 1
fi

print_success "File trovati"

# Step 1-2: Homebrew & Sleepwatcher
print_step "Verifica prerequisiti..."
if ! command -v brew &> /dev/null; then
  print_error "Serve Homebrew! Installa brew prima."
  exit 1
fi

if ! brew list sleepwatcher &> /dev/null; then
  brew install sleepwatcher
else
  print_success "sleepwatcher già installato"
fi

# Step 3: Copia Script
print_step "Installazione script..."
# Backup
[ -f "$HOME/.sleep" ] && cp "$HOME/.sleep" "$HOME/.sleep.bak"
[ -f "$HOME/.wakeup" ] && cp "$HOME/.wakeup" "$HOME/.wakeup.bak"

cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog"

# Step 4: Alias
print_step "Configurazione Alias..."
SHELL_CONFIG=""
[ -f "$HOME/.zshrc" ] && SHELL_CONFIG="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && SHELL_CONFIG="$HOME/.bashrc"
if [ -n "$SHELL_CONFIG" ]; then
  if ! grep -q "alias sleeplog=" "$SHELL_CONFIG"; then
    echo -e "\nalias sleeplog=\"~/.sleeplog\"" >> "$SHELL_CONFIG"
  fi
fi

# Step 5: Servizio
print_step "Riavvio Servizio..."
pkill -9 sleepwatcher 2>/dev/null
brew services restart sleepwatcher
sleep 2

# Step 6: CPU Threshold
echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
print_step "Configurazione Sensibilità"
echo "Premi INVIO per default (1.0%) o scrivi un valore:"
read -r cpu
if [[ $cpu =~ ^[0-9]+\.?[0-9]*$ ]]; then
  sed -i.bak "s/CPU_THRESHOLD=.*/CPU_THRESHOLD=$cpu/" "$HOME/.sleep"
  rm "$HOME/.sleep.bak" 2>/dev/null
  print_success "Soglia impostata a $cpu%"
fi

# Step 7: Modalità PMSET
echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
print_step "Strategia di Risparmio"
echo " [1] Standard (Apple Default)"
echo " [2] Ultra Saver (Ibernazione immediata)"
echo " [3] Hybrid Smart (15m Sleep -> Ibernazione) ⭐"
read -r mode

print_warning "Richiesta password sudo per impostazioni energetiche..."
case $mode in
  2) sudo pmset -a hibernatemode 25; sudo pmset -a powernap 0 ;;
  3) sudo pmset -a hibernatemode 3; sudo pmset -a standby 1; sudo pmset -a standbydelayhigh 900; sudo pmset -a standbydelaylow 300; sudo pmset -a powernap 0 ;;
  *) sudo pmset -a hibernatemode 3; sudo pmset -a standbydelayhigh 86400; sudo pmset -a powernap 1 ;;
esac

# Step 8: AUTO-CONFIGURAZIONE APP (Il cuore della modifica)
echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
print_step "Configurazione App Pesanti (Sync Sleep/Wake)"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo "Scansiono le app per creare la lista 'Always Kill' & 'Eco Wake'..."

KNOWN_APPS=(
    "Google Chrome" "Firefox" "Microsoft Edge" "Brave Browser" "Arc"
    "Adobe Photoshop" "Adobe Premiere Pro" "Adobe Illustrator" "Adobe After Effects" "Adobe Lightroom Classic"
    "DaVinci Resolve" "Final Cut Pro" "Logic Pro" "Pro Tools" "Ableton Live"
    "Blender" "Unity" "Unreal Editor" "Cinema 4D"
    "Docker" "Xcode" "Android Studio" "IntelliJ IDEA" "Visual Studio Code"
    "Slack" "Microsoft Teams" "Discord" "Spotify"
)

DETECTED=""
COUNT=0

for app in "${KNOWN_APPS[@]}"; do
    if [ -d "/Applications/$app.app" ] || [ -d "$HOME/Applications/$app.app" ]; then
        if [ -z "$DETECTED" ]; then DETECTED="$app"; else DETECTED="$DETECTED|$app"; fi
        echo -e "   • Trovata: ${YELLOW}$app${NC}"
        ((COUNT++))
    fi
done

echo ""
echo "Vuoi aggiungere altre app manualmente? (separale con virgola):"
read -r manual
if [ -n "$manual" ]; then
    manual_fmt=$(echo "$manual" | sed 's/, /|/g' | sed 's/,/|/g')
    if [ -z "$DETECTED" ]; then DETECTED="$manual_fmt"; else DETECTED="$DETECTED|$manual_fmt"; fi
fi

if [ -z "$DETECTED" ]; then DETECTED="PlaceholderApp"; fi

# --- MAGIA: Scrive la configurazione in ENTRAMBI i file ---

# 1. Aggiorna WAKEUP (Per non riaprirle a batteria)
sed -i.bak "s/^HEAVY_APPS_SKIP=.*/HEAVY_APPS_SKIP=\"$DETECTED\"/" "$HOME/.wakeup"
rm "$HOME/.wakeup.bak" 2>/dev/null

# 2. Aggiorna SLEEP (Per ucciderle sempre)
sed -i.bak "s/^ALWAYS_KILL_LIST=.*/ALWAYS_KILL_LIST=\"$DETECTED\"/" "$HOME/.sleep"
rm "$HOME/.sleep.bak" 2>/dev/null
# ----------------------------------------------------------

print_success "Configurazione sincronizzata su sleep e wakeup!"
echo ""
echo -e "${GREEN}✓ TUTTO PRONTO!${NC}"
echo "Lista app gestite: $DETECTED"
echo "Ricarica la shell: source $SHELL_CONFIG"
echo ""