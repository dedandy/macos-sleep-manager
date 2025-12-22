#!/bin/bash

# Colori per output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
echo "╔════════════════════════════════════════╗"
echo "║   macOS Smart Sleep Manager Installer ║"
echo "║             v2.1 Hybrid               ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# Funzioni di utilità
print_step() { echo -e "${BLUE}[STEP]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# Verifica file
if [ ! -f "sleep" ] || [ ! -f "wakeup" ] || [ ! -f "sleeplog" ]; then
  print_error "File mancanti! Assicurati di essere nella directory del repository."
  exit 1
fi

print_success "File trovati nel repository"
echo ""

# Step 1: Verifica Homebrew
print_step "Verifica installazione Homebrew..."
if ! command -v brew &> /dev/null; then
  print_error "Homebrew non trovato! Installalo prima di continuare."
  exit 1
fi
print_success "Homebrew installato"
echo ""

# Step 2: Installa sleepwatcher
print_step "Controllo sleepwatcher..."
if ! brew list sleepwatcher &> /dev/null; then
  print_warning "Installazione sleepwatcher..."
  brew install sleepwatcher
else
  print_success "sleepwatcher già installato"
fi
echo ""

# Step 3: Copia gli script
print_step "Copia degli script nella home directory..."

# Backup
for file in ".sleep" ".wakeup" ".sleeplog"; do
  if [ -f "$HOME/$file" ]; then
    cp "$HOME/$file" "$HOME/$file.backup"
  fi
done

# Copia
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"

# Permessi
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog"

print_success "Script copiati e resi eseguibili"
echo ""

# Step 4: Alias
print_step "Configurazione alias..."
SHELL_CONFIG=""
[ -f "$HOME/.zshrc" ] && SHELL_CONFIG="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && SHELL_CONFIG="$HOME/.bashrc"

if [ -n "$SHELL_CONFIG" ]; then
  if ! grep -q "alias sleeplog=" "$SHELL_CONFIG"; then
    echo "" >> "$SHELL_CONFIG"
    echo "# macOS Smart Sleep Manager" >> "$SHELL_CONFIG"
    echo "alias sleeplog=\"~/.sleeplog\"" >> "$SHELL_CONFIG"
    print_success "Alias aggiunto a $SHELL_CONFIG"
  else
    print_success "Alias già presente"
  fi
fi
echo ""

# Step 5: Riavvio Servizio
print_step "Riavvio servizio sleepwatcher..."
pkill -9 sleepwatcher 2>/dev/null
brew services restart sleepwatcher
sleep 2
if pgrep -f "sleepwatcher" > /dev/null; then
    print_success "Servizio attivo."
else
    print_error "Errore avvio servizio."
fi
echo ""

# Step 6: Personalizzazione CPU
echo -e "${CYAN}═══════════════════════════════════════${NC}"
print_step "Configurazione Soglia CPU"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo "Premi INVIO per mantenere il default (1.0%) o scrivi un numero (es. 0.5):"
read -r cpu_threshold
if [[ $cpu_threshold =~ ^[0-9]+\.?[0-9]*$ ]]; then
  sed -i.bak "s/CPU_THRESHOLD=.*/CPU_THRESHOLD=$cpu_threshold/" "$HOME/.sleep"
  rm "$HOME/.sleep.bak" 2>/dev/null
  print_success "Soglia impostata a $cpu_threshold%"
fi

# Step 7: Configurazione PMSET (La parte importante)
echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
print_step "Configurazione Modalità Sospensione"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""
echo "Scegli la modalità di risparmio energetico:"
echo ""
echo "  [1] STANDARD (Default Apple)"
echo "      - Sonno leggero. Risveglio istantaneo."
echo "      - Consumo moderato durante la notte."
echo ""
echo "  [2] ULTRA SAVER (Ibernazione Immediata)"
echo "      - Spegne tutto subito."
echo "      - Risparmio massimo, ma risveglio lento (10-15 sec)."
echo ""
echo "  [3] IBRIDA / SMART (Consigliata) ⭐"
echo "      - Primi 15 min: Sonno leggero (risveglio istantaneo)."
echo "      - Dopo 15 min: Ibernazione profonda (risparmio massimo)."
echo "      - Il meglio dei due mondi."
echo ""
echo "Inserisci il numero (1, 2 o 3):"
read -r sleep_mode

echo ""
print_warning "Richiesta permessi di root per modificare le impostazioni..."

case $sleep_mode in
  2)
    # ULTRA
    sudo pmset -a hibernatemode 25
    sudo pmset -a powernap 0
    sudo pmset -a tcpkeepalive 0
    print_success "Modalità ULTRA attivata (hibernatemode 25)"
    ;;
  3)
    # IBRIDA (Quella che hai chiesto)
    # hibernatemode 3 = Safe Sleep (RAM + Disk)
    # standby 1 = Abilita la transizione automatica
    # standbydelayhigh 900 = 15 minuti (900 sec) se batteria > 50%
    # standbydelaylow 300 = 5 minuti (300 sec) se batteria < 50%
    
    sudo pmset -a hibernatemode 3
    sudo pmset -a standby 1
    sudo pmset -a standbydelayhigh 900
    sudo pmset -a standbydelaylow 300
    sudo pmset -a powernap 0
    sudo pmset -a tcpkeepalive 0
    
    print_success "Modalità IBRIDA attivata:"
    echo "    - Standby Delay: 15 min (Batt Alta) / 5 min (Batt Bassa)"
    echo "    - PowerNap: Disattivato"
    ;;
  *)
    # STANDARD
    sudo pmset -a hibernatemode 3
    sudo pmset -a standby 1
    sudo pmset -a standbydelayhigh 86400
    sudo pmset -a powernap 1
    sudo pmset -a tcpkeepalive 1
    print_success "Modalità STANDARD ripristinata"
    ;;
esac

echo ""
echo -e "${GREEN}✓ INSTALLAZIONE COMPLETATA!${NC}"
echo "Ricarica la shell: source $SHELL_CONFIG"
echo ""