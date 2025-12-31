#!/bin/bash
# install.sh v4.5 - Deep Freeze Edition

# --- DEFINIZIONE COLORI PER L'INTERFACCIA ---
CYAN='\033[1;36m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   macOS Sleep Manager v4.5 - WIZARD    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"

# --- STEP 1: SCANSIONE APPLICAZIONI (Deep Scan) ---
# Questa sezione analizza la cartella Applicazioni per catalogare Whitelist e Heavy Apps
echo -e "\n${BLUE}[1/6] Analisi sistema e applicazioni...${NC}"
ALL_APPS=$(ls /Applications | sed 's/\.app//g')
DETECTED_W=""
DETECTED_H=""

while read -r app; do
    [ -z "$app" ] && continue
    # Selettore Heavy Apps (Browser, IDE, Cloud, Grafica)
    if [[ "$app" =~ (Chrome|Firefox|Edge|Opera|WebStorm|IntelliJ|PyCharm|Xcode|Code|Adobe|Resolve|Final|Docker|Teams|ChatGPT|OneDrive|Google\ Drive|Dropbox|Creative) ]]; then
        DETECTED_H="${DETECTED_H}${DETECTED_H:+|}$app"
    # Selettore Whitelist (Messaggistica, Musica, Mail)
    elif [[ "$app" =~ (WhatsApp|Telegram|Signal|Slack|Spotify|Music|Mail|Messages|Discord) ]]; then
        DETECTED_W="${DETECTED_W}${DETECTED_W:+|}$app"
    fi
done <<< "$ALL_APPS"

# --- STEP 2: COPIA DEI FILE NELLA HOME ---
# Copiamo gli script operativi rendendoli eseguibili
echo -e "${BLUE}[2/6] Installazione script operativi...${NC}"
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp config_editor "$HOME/.sleepmanager_editor"
chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" "$HOME/.sleepmanager_editor"

# --- STEP 3: CONFIGURAZIONE PMSET (DEEP FREEZE) ---
# QUESTA È LA SEZIONE CHE CERCAVI: Qui gestiamo il risparmio energetico del kernel
echo -e "${BLUE}[3/6] Ottimizzazione Risparmio Energetico (Deep Freeze)...${NC}"

# Abilitiamo lo standby (ibernazione)
sudo pmset -a standby 1

# Impostiamo il ritardo a 7200 secondi (2 ore)
# Dopo 2 ore di sleep, il Mac passerà in ibernazione totale (consumo quasi 0)
sudo pmset -a standbydelayhigh 7200
sudo pmset -a standbydelaylow 7200

# Modalità 3 (Ibrida): RAM alimentata inizialmente, poi salvata su disco
sudo pmset -a hibernatemode 3

# Disattiviamo funzioni che "svegliano" il Mac inutilmente (Dark Wakes)
sudo pmset -a powernap 0
sudo pmset -a proximitywake 0
sudo pmset -a tcpkeepalive 0 # Fondamentale per evitare cali di batteria durante lo sleep

# --- STEP 4: CONFIGURAZIONE SOGLIA CPU ---
# Chiediamo all'utente la sensibilità per le app sconosciute
echo -e "\n${BLUE}[4/6] Configurazione Sensibilità...${NC}"
read -p "Soglia CPU per chiusura app (Default 1.0%): " p_cpu
p_cpu=${p_cpu:-1.0}

# Creazione del file di configurazione definitivo
cat <<EOF > "$HOME/.sleepmanager.conf"
# macOS Sleep Manager Config v4.5
ENABLE_NOTIFICATIONS="true"
SAFE_QUIT_MODE="true"
CPU_THRESHOLD="$p_cpu"
WHITELIST="$DETECTED_W"
HEAVY_APPS="$DETECTED_H"
EOF

# --- STEP 5: FIRMA DIGITALE (CODESIGN) ---
# Necessario per sbloccare i permessi di Privacy su macOS
echo -e "${BLUE}[5/6] Sblocco sicurezza macOS (Codesign)...${NC}"
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null

# --- STEP 6: CONFIGURAZIONE ALIAS DELLA SHELL ---
# Aggiungiamo i comandi rapidi a .zshrc o .bashrc
echo -e "${BLUE}[6/6] Configurazione comandi rapidi (Alias)...${NC}"
RC_FILE="$HOME/.zshrc"
[[ "$(basename "$SHELL")" == "bash" ]] && RC_FILE="$HOME/.bashrc"
touch "$RC_FILE"

if ! grep -q "alias sleeplog=" "$RC_FILE"; then
    echo -e "\nalias sleeplog=\"~/.sleeplog\"" >> "$RC_FILE"
    echo "alias sleepconf=\"~/.sleepmanager_editor\"" >> "$RC_FILE"
fi

# Riavvio del servizio per applicare le modifiche
brew services restart sleepwatcher

echo -e "\n${GREEN}✓ INSTALLAZIONE COMPLETATA CON SUCCESSO!${NC}"
echo -e "------------------------------------------------"
echo -e "1. Esegui: ${CYAN}source $RC_FILE${NC} per attivare i comandi."
echo -e "2. Verifica 'Accesso completo al disco' per sleepwatcher."
echo -e "3. Goditi il tuo Mac in Deep Freeze (Ibernazione a 2 ore attivo).${NC}"