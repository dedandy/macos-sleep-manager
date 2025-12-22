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
echo "╔════════════════════════════════════════╗"
echo -e "${NC}"
echo ""

# Funzione per stampare step
print_step() {
  echo -e "${BLUE}[STEP]${NC} $1"
}

# Funzione per stampare successo
print_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

# Funzione per stampare errore
print_error() {
  echo -e "${RED}[✗]${NC} $1"
}

# Funzione per stampare warning
print_warning() {
  echo -e "${YELLOW}[!]${NC} $1"
}

# Verifica di essere nella directory corretta
if [ ! -f "sleep" ] || [ ! -f "wakeup" ] || [ ! -f "sleeplog" ]; then
  print_error "File mancanti! Assicurati di essere nella directory del repository."
  echo "Dovrebbero essere presenti: sleep, wakeup, sleeplog"
  exit 1
fi

print_success "File trovati nel repository"
echo ""

# Step 1: Verifica Homebrew
print_step "Verifica installazione Homebrew..."
if ! command -v brew &> /dev/null; then
  print_error "Homebrew non trovato!"
  echo ""
  echo "Installa Homebrew prima di continuare:"
  echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  exit 1
fi
print_success "Homebrew installato"
echo ""

# Step 2: Installa sleepwatcher
print_step "Controllo sleepwatcher..."
if ! brew list sleepwatcher &> /dev/null; then
  print_warning "sleepwatcher non trovato, procedo con l'installazione..."
  brew install sleepwatcher
  if [ $? -eq 0 ]; then
    print_success "sleepwatcher installato"
  else
    print_error "Errore nell'installazione di sleepwatcher"
    exit 1
  fi
else
  print_success "sleepwatcher già installato"
fi
echo ""

# Step 3: Copia gli script
print_step "Copia degli script nella home directory..."

# Backup di eventuali script esistenti
if [ -f "$HOME/.sleep" ]; then
  print_warning "Backup di ~/.sleep esistente in ~/.sleep.backup"
  cp "$HOME/.sleep" "$HOME/.sleep.backup"
fi
if [ -f "$HOME/.wakeup" ]; then
  print_warning "Backup di ~/.wakeup esistente in ~/.wakeup.backup"
  cp "$HOME/.wakeup" "$HOME/.wakeup.backup"
fi
if [ -f "$HOME/.sleeplog" ]; then
  print_warning "Backup di ~/.sleeplog esistente in ~/.sleeplog.backup"
  cp "$HOME/.sleeplog" "$HOME/.sleeplog.backup"
fi

# Copia i nuovi script
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"

# Rendi eseguibili
chmod +x "$HOME/.sleep"
chmod +x "$HOME/.wakeup"
chmod +x "$HOME/.sleeplog"

print_success "Script copiati e resi eseguibili"
echo ""

# Step 4: Configura alias per sleeplog
print_step "Configurazione alias per sleeplog..."

# Determina quale shell config usare
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then
  SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
  SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
  SHELL_CONFIG="$HOME/.bash_profile"
fi

if [ -n "$SHELL_CONFIG" ]; then
  # Verifica se l'alias esiste già
  if grep -q "alias sleeplog=" "$SHELL_CONFIG"; then
    print_warning "Alias sleeplog già presente in $SHELL_CONFIG"
  else
    echo "" >> "$SHELL_CONFIG"
    echo "# macOS Smart Sleep Manager" >> "$SHELL_CONFIG"
    echo "alias sleeplog=\"~/.sleeplog\"" >> "$SHELL_CONFIG"
    print_success "Alias aggiunto a $SHELL_CONFIG"
  fi
else
  print_warning "File di configurazione shell non trovato"
  echo "Aggiungi manualmente: alias sleeplog=\"~/.sleeplog\""
fi
echo ""

# Step 5: Avvia sleepwatcher
print_step "Avvio servizio sleepwatcher..."

# Prima di tutto, killa eventuali istanze manuali in esecuzione
MANUAL_PROCESSES=$(pgrep -f "sleepwatcher" | grep -v "grep" | wc -l | tr -d ' ')
if [ "$MANUAL_PROCESSES" -gt 0 ]; then
  print_warning "Trovate $MANUAL_PROCESSES istanze di sleepwatcher in esecuzione"
  print_step "Chiusura di tutte le istanze esistenti..."
  pkill -9 sleepwatcher
  sleep 2
  print_success "Istanze manuali chiuse"
fi

# Rimuovi eventuali LaunchAgents duplicati
if [ -f "$HOME/Library/LaunchAgents/com.bernhard-baehr.sleepwatcher.plist" ]; then
  print_warning "Trovato LaunchAgent duplicato, rimozione..."
  launchctl unload "$HOME/Library/LaunchAgents/com.bernhard-baehr.sleepwatcher.plist" 2>/dev/null
  rm "$HOME/Library/LaunchAgents/com.bernhard-baehr.sleepwatcher.plist"
  print_success "LaunchAgent duplicato rimosso"
fi

# Verifica se è già in esecuzione tramite brew services
if brew services list | grep sleepwatcher | grep -q "started"; then
  print_warning "sleepwatcher già in esecuzione, riavvio per applicare nuova configurazione..."
  brew services restart sleepwatcher
else
  brew services start sleepwatcher
fi

sleep 2

# Verifica che sia partito correttamente E che ce ne sia solo UNO
RUNNING_COUNT=$(pgrep -f "sleepwatcher" | wc -l | tr -d ' ')
if [ "$RUNNING_COUNT" -eq 1 ]; then
  print_success "sleepwatcher avviato correttamente (1 istanza attiva)"
  pgrep -fl sleepwatcher >> /dev/null
elif [ "$RUNNING_COUNT" -gt 1 ]; then
  print_error "ATTENZIONE: Rilevate $RUNNING_COUNT istanze di sleepwatcher!"
  echo "Questo causerà doppia esecuzione degli script."
  echo "Esegui: pkill sleepwatcher && brew services restart sleepwatcher"
  exit 1
else
  print_error "Errore nell'avvio di sleepwatcher"
  echo "Prova manualmente: brew services start sleepwatcher"
  exit 1
fi
echo ""

# Step 6: Personalizzazione (opzionale)
echo -e "${CYAN}═══════════════════════════════════════${NC}"
print_step "Personalizzazione Script"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""
echo "Vuoi configurare le opzioni degli script (Soglia CPU)? [y/N]"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo ""
  echo "Soglia CPU attuale: 1.0%"
  echo "Inserisci nuova soglia CPU (0.5-5.0) o premi INVIO per mantenere 1.0:"
  read -r cpu_threshold
  
  if [ -n "$cpu_threshold" ]; then
    # Valida input
    if [[ $cpu_threshold =~ ^[0-9]+\.?[0-9]*$ ]]; then
      sed -i.bak "s/CPU_THRESHOLD=.*/CPU_THRESHOLD=$cpu_threshold/" "$HOME/.sleep"
      rm "$HOME/.sleep.bak"
      print_success "Soglia CPU impostata a $cpu_threshold%"
    else
      print_warning "Valore non valido, mantenuta soglia 1.0%"
    fi
  fi
fi

# Step 7: Configurazione Sistema (PMSET)
echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
print_step "Configurazione Sistema (Risparmio Energetico)"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""
echo "Vuoi applicare la configurazione 'Ultra-Saver'?"
echo "   • Ibernazione profonda (hibernatemode 25)"
echo "   • Disattiva Power Nap e TCP KeepAlive"
echo "   • MASSIMO risparmio batteria, risveglio leggermente più lento."
echo ""
echo "Richiede password di amministratore (sudo)."
echo "Procedere? [y/N]"
read -r pmset_response

if [[ "$pmset_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo ""
  print_warning "Richiesta permessi di root per modificare pmset..."
  
  # Ibernazione
  if sudo pmset -a hibernatemode 25; then
    print_success "Hibernatemode impostato a 25 (Deep Sleep)"
  else
    print_error "Fallito impostazione hibernatemode"
  fi
  
  # Power Nap
  if sudo pmset -a powernap 0; then
    print_success "Power Nap disattivato"
  fi
  
  # TCP KeepAlive
  if sudo pmset -a tcpkeepalive 0; then
    print_success "TCP KeepAlive disattivato (Stop notifiche in sleep)"
  fi
  
  echo ""
  echo "Nota: Per ripristinare i valori predefiniti in futuro, usa:"
  echo "sudo pmset -a hibernatemode 3; sudo pmset -a powernap 1; sudo pmset -a tcpkeepalive 1"
else
  print_success "Configurazione sistema saltata."
fi

# Riepilogo finale
echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ INSTALLAZIONE E CONFIGURAZIONE COMPLETATA!${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""
echo "📁 File installati:"
echo "   ~/.sleep       → Script sleep"
echo "   ~/.wakeup      → Script wakeup"
echo "   ~/.sleeplog    → Visualizzatore log"
echo ""
echo "🔧 Stato Sistema:"
echo "   Service        → sleepwatcher (Attivo)"
if [[ "$pmset_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
echo "   Risparmio      → ULTRA (Ibernazione 25)"
else
echo "   Risparmio      → STANDARD"
fi
echo ""
echo "🚀 Prossimi passi:"
echo "   1. Assicurati di aver modificato il file 'wakeup' nella cartella sorgente"
echo "      con 'sleep 10' prima di aver lanciato questo script!"
echo "   2. Ricarica la shell: source $SHELL_CONFIG"
echo "   3. Stacca l'alimentatore e chiudi il coperchio per testare."
echo ""