#!/bin/bash
# install.sh v4.9.23 - Auto-configuration con scrittura diretta
CYAN='\033[1;36m'; BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
CONF_FILE="$HOME/.sleepmanager.conf"
VERSION_FILE="$HOME/.sleepmanager_version"
LOCAL_VERSION_FILE="$(dirname "$0")/version.sh"

echo -e "${BLUE}[1/4] Copia componenti...${NC}"
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp restore_apps.sh "$HOME/.sleepmanager_restore"
cp "$LOCAL_VERSION_FILE" "$VERSION_FILE"
cp config_editor "$HOME/.sleepmanager_editor"
cp config_editor_auto "$HOME/.config_editor_auto"
cp install.sh "$HOME/.sleepmanager_install"
cp quicklaunch "$HOME/.quicklaunch"

chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" \
         "$HOME/.sleepmanager_restore" "$HOME/.sleepmanager_editor" "$HOME/.config_editor_auto" "$VERSION_FILE" \
         "$HOME/.sleepmanager_install" "$HOME/.quicklaunch"

echo -e "${BLUE}[2/4] Scansione applicazioni...${NC}"

WHITELIST_APPS=()
HEAVY_APPS_LIST=()

# Whitelist: App che devono restare sempre aperte
for app in "Music" "Spotify" "Messages" "Mail" "IINA" "VLC" "Transmission" "qBittorrent"; do
    if [ -d "/Applications/$app.app" ]; then
        WHITELIST_APPS+=("$app")
        echo -e "  ${GREEN}✓${NC} Whitelist: $app"
    fi
done

# Heavy Apps: Browser e app pesanti
for app in "Google Chrome" "Firefox" "Safari" "Brave Browser" "Arc" "Adobe Photoshop" "Adobe Lightroom" "Final Cut Pro" "Logic Pro" "Xcode"; do
    if [ -d "/Applications/$app.app" ]; then
        HEAVY_APPS_LIST+=("$app")
        echo -e "  ${YELLOW}⚡${NC} Heavy App: $app"
    fi
done

# Crea le stringhe separate da pipe
WHITELIST_STR=$(IFS="|"; echo "${WHITELIST_APPS[*]}")
HEAVY_STR=$(IFS="|"; echo "${HEAVY_APPS_LIST[*]}")

echo -e "${BLUE}[3/4] Creazione configurazione...${NC}"

# Se esiste già una configurazione, preserva i valori utente durante l'upgrade
if [ -f "$CONF_FILE" ]; then
    CONF_BACKUP="${CONF_FILE}.backup-$(date '+%Y%m%d-%H%M%S')"
    cp "$CONF_FILE" "$CONF_BACKUP"
    echo -e "${CYAN}📦 Backup config: $CONF_BACKUP${NC}"
    source "$CONF_FILE"
fi

# Merge: mantiene la config esistente, usa default solo per chiavi nuove/mancanti
ENABLE_NOTIFICATIONS_VAL="${ENABLE_NOTIFICATIONS:-true}"
SAFE_QUIT_MODE_VAL="${SAFE_QUIT_MODE:-true}"
CPU_THRESHOLD_VAL="${CPU_THRESHOLD:-1.0}"
STANDBY_DELAY_MINUTES_VAL="${STANDBY_DELAY_MINUTES:-15}"
PRESERVE_APP_SESSIONS_VAL="${PRESERVE_APP_SESSIONS:-true}"
DISABLE_DARKWAKE_FEATURES_VAL="${DISABLE_DARKWAKE_FEATURES:-true}"
FORCE_SLEEP_KILL_APPS_VAL="${FORCE_SLEEP_KILL_APPS:-WhatsApp|Google Chrome}"
WHITELIST_VAL="${WHITELIST-$WHITELIST_STR}"
HEAVY_APPS_VAL="${HEAVY_APPS-$HEAVY_STR}"
RESTORE_APPS_VAL="${RESTORE_APPS:-Google Chrome|Visual Studio Code|WebStorm|Microsoft Teams|WireGuard|Docker|Terminal}"
QUICK_LAUNCH_APPS_VAL="${QUICK_LAUNCH_APPS:-Safari|Notes}"
RESTORE_TERMINAL_MAX_VAL="${RESTORE_TERMINAL_MAX:-6}"
LOG_ASSERTIONS_VAL="${LOG_ASSERTIONS:-true}"
TOGGLE_BLUETOOTH_ON_SLEEP_VAL="${TOGGLE_BLUETOOTH_ON_SLEEP:-false}"
AGGRESSIVE_POWER_PROFILE_VAL="${AGGRESSIVE_POWER_PROFILE:-false}"
SHOW_STANDBY_ALERT_VAL="${SHOW_STANDBY_ALERT:-true}"

# SCRITTURA DIRETTA del file config (non usa sed)
cat > "$CONF_FILE" << EOF
# macOS Sleep Manager v4.9.23 - Auto-Generated Config
# Generato il: $(date '+%Y-%m-%d %H:%M:%S')

# --- IMPOSTAZIONI GENERALI ---
ENABLE_NOTIFICATIONS=$ENABLE_NOTIFICATIONS_VAL
SAFE_QUIT_MODE=$SAFE_QUIT_MODE_VAL
CPU_THRESHOLD=$CPU_THRESHOLD_VAL

# Ritardo Deep Sleep (minuti)
STANDBY_DELAY_MINUTES=$STANDBY_DELAY_MINUTES_VAL

# Preserva sessioni app allo sleep
PRESERVE_APP_SESSIONS=$PRESERVE_APP_SESSIONS_VAL

# Dark wake controls (true/false)
DISABLE_DARKWAKE_FEATURES=$DISABLE_DARKWAKE_FEATURES_VAL

# Force-kill apps on sleep to prevent dark wake
FORCE_SLEEP_KILL_APPS="$FORCE_SLEEP_KILL_APPS_VAL"

# --- LISTE APPLICAZIONI ---
# Whitelist: App protette dalla chiusura automatica
WHITELIST="$WHITELIST_VAL"

# Heavy Apps: Chiuse allo sleep, riaperte solo se c'è corrente
HEAVY_APPS="$HEAVY_APPS_VAL"

# Restore Apps: Riaperte al wake/login se non sono in esecuzione
RESTORE_APPS="$RESTORE_APPS_VAL"

# Quick Launch Apps: avviate con un comando
QUICK_LAUNCH_APPS="$QUICK_LAUNCH_APPS_VAL"

# Restore Terminal: massimo numero di tab da ripristinare
RESTORE_TERMINAL_MAX=$RESTORE_TERMINAL_MAX_VAL

# Diagnostic logging for sleep/wake (true/false)
LOG_ASSERTIONS=$LOG_ASSERTIONS_VAL

# Bluetooth toggle on sleep/wake (true/false)
TOGGLE_BLUETOOTH_ON_SLEEP=$TOGGLE_BLUETOOTH_ON_SLEEP_VAL

# Aggressive power profile (true/false)
AGGRESSIVE_POWER_PROFILE=$AGGRESSIVE_POWER_PROFILE_VAL

# Show alert on sleep (true/false)
SHOW_STANDBY_ALERT=$SHOW_STANDBY_ALERT_VAL
EOF

# Verifica che il file sia stato scritto correttamente
if [ -f "$CONF_FILE" ] && [ -s "$CONF_FILE" ]; then
    echo -e "${GREEN}✓ Configurazione creata: $CONF_FILE${NC}"
    echo -e "${CYAN}📋 Contenuto:${NC}"
    echo -e "${YELLOW}WHITELIST:${NC} $WHITELIST_VAL"
    echo -e "${YELLOW}HEAVY_APPS:${NC} $HEAVY_APPS_VAL"
else
    echo -e "${RED}✗ Errore nella creazione del config!${NC}"
    exit 1
fi

echo -e "${BLUE}[4/4] Configurazione Kernel...${NC}"
sudo pmset -a tcpkeepalive 0 proximitywake 0 standby 1 standbydelayhigh 3600
echo 'sleepmanager ALL=(root) NOPASSWD: /usr/bin/pmset *' | sudo tee /etc/sudoers.d/sleepmanager >/dev/null 2>&1
sudo chmod 644 /etc/sudoers.d/sleepmanager
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null
brew services restart sleepwatcher

echo -e "${BLUE}[5/5] Setup ripristino app al login...${NC}"
RESTORE_AGENT="$HOME/Library/LaunchAgents/com.sleepmanager.restore.plist"
cat > "$RESTORE_AGENT" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.sleepmanager.restore</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$HOME/.sleepmanager_restore</string>
        <string>--login</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
launchctl unload "$RESTORE_AGENT" >/dev/null 2>&1
launchctl load "$RESTORE_AGENT" >/dev/null 2>&1

echo -e "${BLUE}[6/6] Verifica alias...${NC}"
if ! grep -q "alias sleeplog=" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOFZSH'

# macOS Sleep Manager v4.7
alias sleeplog='~/.sleeplog'
alias sleepconf='~/.sleepmanager_editor'
alias quicklaunch='~/.quicklaunch'
EOFZSH
    echo -e "${YELLOW}⚠️  Aggiunti alias a .zshrc. Esegui: source ~/.zshrc${NC}"
fi

echo ""
echo -e "${GREEN}✅ Installazione completata!${NC}"
echo -e "${CYAN}📊 Riepilogo:${NC}"
echo -e "  • Whitelist: ${GREEN}${#WHITELIST_APPS[@]} app${NC}"
echo -e "  • Heavy Apps: ${YELLOW}${#HEAVY_APPS_LIST[@]} app${NC}"
echo ""
echo -e "Verifica la configurazione con:"
echo -e "  ${CYAN}cat ~/.sleepmanager.conf${NC}"
echo ""
echo -e "Gestisci le app con:"
echo -e "  ${CYAN}sleepconf${NC} (terminale) o ${GREEN}SwiftBar${NC} (GUI)"
