#!/bin/bash
# MASTER_INSTALL v4.9.8 - "The Clean Slate"

CYAN='\033[1;36m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'
clear
echo -e "${CYAN}Generazione pacchetto v4.6.1 in corso...${NC}"

# --- 1. GENERAZIONE SELECTOR.SCPT (Senza virgolette bash conflittuali) ---
cat << 'EOF' > selector.scpt
POSIX path of (choose file with prompt "Seleziona l'applicazione:" of directory "/Applications")
EOF

# --- 2. GENERAZIONE CONFIG_EDITOR_AUTO ---
cat << 'EOF' > config_editor_auto
#!/bin/bash
CONF_FILE="$HOME/.sleepmanager.conf"
LIST_TYPE=$1 
SCPT_FILE="$HOME/.selector.scpt"

FILE_PATH=$(osascript "$SCPT_FILE" 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0
APP_NAME=$(basename "$FILE_PATH" .app)

if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
    CURRENT_VAL=${!LIST_TYPE}
    [[ "$CURRENT_VAL" == *"$APP_NAME"* ]] && exit 0
    [ -z "$CURRENT_VAL" ] && NEW_VAL="$APP_NAME" || NEW_VAL="$CURRENT_VAL|$APP_NAME"
    sed -i.bak "s|^$LIST_TYPE=.*|$LIST_TYPE=\"$NEW_VAL\"|" "$CONF_FILE"
    rm "${CONF_FILE}.bak"
fi
EOF

# --- 3. AGGIORNAMENTO INSTALL.SH ---
# Prendo il tuo install.sh e mi assicuro che copi tutto
cat << 'EOF' > install.sh
#!/bin/bash
# install.sh v4.6.1
CYAN='\033[1;36m'; BLUE='\033[0;34m'; GREEN='\033[0;32m'; NC='\033[0m'
echo -e "${BLUE}[1/2] Copia componenti...${NC}"
cp sleep "$HOME/.sleep"
cp wakeup "$HOME/.wakeup"
cp sleeplog "$HOME/.sleeplog"
cp restore_apps.sh "$HOME/.sleepmanager_restore"
cp version.sh "$HOME/.sleepmanager_version"
cp config_editor "$HOME/.sleepmanager_editor"
cp config_editor_auto "$HOME/.config_editor_auto"
cp selector.scpt "$HOME/.selector.scpt"
cp install.sh "$HOME/.sleepmanager_install"

chmod +x "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" \
         "$HOME/.sleepmanager_restore" "$HOME/.sleepmanager_editor" "$HOME/.config_editor_auto" "$HOME/.sleepmanager_version" \
         "$HOME/.sleepmanager_install"

echo -e "${BLUE}[2/2] Configurazione Kernel...${NC}"
sudo pmset -a tcpkeepalive 0 proximitywake 0 standby 1 standbydelayhigh 3600
sudo codesign --force --deep --sign - $(which sleepwatcher) 2>/dev/null
brew services restart sleepwatcher

echo -e "${BLUE}[3/3] Setup ripristino app al login...${NC}"
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
echo -e "${GREEN}✓ Installazione completata con successo.${NC}"
EOF

# --- 4. ESECUZIONE FINALE ---
chmod +x selector.scpt config_editor_auto install.sh
./install.sh

echo -e "\n${GREEN}OPERAZIONE COMPLETATA.${NC}"
echo -e "Ora prova a lanciare nel terminale: ${CYAN}osascript ~/.selector.scpt${NC}"
