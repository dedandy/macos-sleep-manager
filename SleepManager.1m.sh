#!/bin/bash
# <bitbar.title>macOS Sleep Manager Monitor</bitbar.title>
# <bitbar.version>v4.9.4</bitbar.version>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

CONF_FILE="$HOME/.sleepmanager.conf"
LOG_FILE="$HOME/.sleeplog_history"
EDITOR_AUTO="$HOME/.config_editor_auto"
RESTORE_SCRIPT="$HOME/.sleepmanager_restore"
VERSION_FILE="$HOME/.sleepmanager_version"

# Carica configurazione
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
else
    echo "⚠️ Config mancante"
    echo "---"
    echo "Esegui: ~/.sleepmanager_install | terminal=true"
    exit 0
fi
[ -f "$VERSION_FILE" ] && source "$VERSION_FILE"

# --- STATO BARRA ---
LAST_DELTA=$(grep "DELTA:" "$LOG_FILE" 2>/dev/null | tail -1 | grep -o "\-[0-9]*%" | sed 's/-//' || echo "—")
if [ "$LAST_DELTA" = "0%" ]; then
    echo "🔋 Perfect | color=darkgreen"
else
    echo "🔋 -$LAST_DELTA | color=blue"
fi
echo "---"
if [ -n "$SM_VERSION" ]; then
    echo "Versione: v$SM_VERSION | color=gray size=11"
    echo "---"
fi

# --- DASHBOARD ---
echo "📊 Ultimi Eventi | size=13 color=#00D9FF"
if [ -f "$LOG_FILE" ]; then
    tail -n 6 "$LOG_FILE" | grep -E "ACTION:|KILL" | sed 's/ACTION: //' | sed 's/\[KILL\]/🔪/' | while read -r line; do
        echo "-- $line | font=Menlo size=11"
    done
else
    echo "-- Nessun log disponibile | color=gray"
fi
echo "---"

# --- WHITELIST ---
echo "🛡️ Whitelist (Protette) | color=#00FF88"
if [ -z "$WHITELIST" ]; then
    echo "-- (vuota) | color=gray"
else
    IFS='|' read -ra APPS <<< "$WHITELIST"
    for app in "${APPS[@]}"; do
        [ -z "$app" ] && continue
        REMOVE_CMD="perl -pi -e 's/(^|\\|)\\Q${app}\\E(?=\\||\$)//g; s/^\\|//; s/\\|\\|/\\|/g; s/\\|\$//' \"$CONF_FILE\""
        echo "-- ✓ $app | shell=/bin/bash param1=-c param2='$REMOVE_CMD' terminal=false refresh=true"
    done
fi
# FIX CRITICO: Usa /bin/bash esplicito e passa l'argomento correttamente
echo "-- ➕ Aggiungi App... | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=WHITELIST terminal=false refresh=true"

echo "---"

# --- HEAVY APPS ---
echo "🌑 Heavy Apps (Kill allo Sleep) | color=#FF9500"
if [ -z "$HEAVY_APPS" ]; then
    echo "-- (vuota) | color=gray"
else
    IFS='|' read -ra APPS_H <<< "$HEAVY_APPS"
    for app in "${APPS_H[@]}"; do
        [ -z "$app" ] && continue
        REMOVE_CMD="perl -pi -e 's/(^|\\|)\\Q${app}\\E(?=\\||\$)//g; s/^\\|//; s/\\|\\|/\\|/g; s/\\|\$//' \"$CONF_FILE\""
        echo "-- ⚡ $app | shell=/bin/bash param1=-c param2='$REMOVE_CMD' terminal=false refresh=true"
    done
fi
echo "-- ➕ Aggiungi App... | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=HEAVY_APPS terminal=false refresh=true"

echo "---"

# --- RESTORE APPS ---
echo "🔁 Restore Apps (Wake/Login) | color=#6FE0FF"
if [ -z "$RESTORE_APPS" ]; then
    echo "-- (vuota) | color=gray"
else
    IFS='|' read -ra APPS_R <<< "$RESTORE_APPS"
    for app in "${APPS_R[@]}"; do
        [ -z "$app" ] && continue
        proc_name="$app"
        if [ "$app" = "Visual Studio Code" ]; then proc_name="Code"; fi
        if pgrep -x "$proc_name" >/dev/null 2>&1; then
            status="🟢"
        else
            status="⚪️"
        fi
        REMOVE_CMD="perl -pi -e 's/(^|\\|)\\Q${app}\\E(?=\\||\$)//g; s/^\\|//; s/\\|\\|/\\|/g; s/\\|\$//' \"$CONF_FILE\""
        echo "-- $status $app | shell=/bin/bash param1=-c param2='$REMOVE_CMD' terminal=false refresh=true"
    done
fi
echo "-- ➕ Aggiungi App... | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=RESTORE_APPS terminal=false refresh=true"
echo "-- 🔢 Max Tab Terminal: ${RESTORE_TERMINAL_MAX:-6} | color=gray"
echo "-- Imposta 4 | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^RESTORE_TERMINAL_MAX=.*/RESTORE_TERMINAL_MAX=4/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "-- Imposta 6 | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^RESTORE_TERMINAL_MAX=.*/RESTORE_TERMINAL_MAX=6/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "-- Imposta 8 | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^RESTORE_TERMINAL_MAX=.*/RESTORE_TERMINAL_MAX=8/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"

echo "---"

# --- IMPOSTAZIONI ---
echo "⚙️ Impostazioni | color=#5AC8FA"

# Toggle Notifiche
if [ "$ENABLE_NOTIFICATIONS" = "true" ]; then
    CMD_NOTIF="sed -i.bak 's/ENABLE_NOTIFICATIONS=true/ENABLE_NOTIFICATIONS=false/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ✅ Notifiche Attive | shell=/bin/bash param1=-c param2='$CMD_NOTIF' terminal=false refresh=true"
else
    CMD_NOTIF="sed -i.bak 's/ENABLE_NOTIFICATIONS=false/ENABLE_NOTIFICATIONS=true/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ❌ Notifiche Disattivate | shell=/bin/bash param1=-c param2='$CMD_NOTIF' terminal=false refresh=true"
fi

# Toggle Safe Quit
if [ "$SAFE_QUIT_MODE" = "true" ]; then
    CMD_SAFE="sed -i.bak 's/SAFE_QUIT_MODE=true/SAFE_QUIT_MODE=false/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ✅ Chiusura Sicura | shell=/bin/bash param1=-c param2='$CMD_SAFE' terminal=false refresh=true"
else
    CMD_SAFE="sed -i.bak 's/SAFE_QUIT_MODE=false/SAFE_QUIT_MODE=true/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ❌ Chiusura Forzata | shell=/bin/bash param1=-c param2='$CMD_SAFE' terminal=false refresh=true"
fi

if [ "$TOGGLE_BLUETOOTH_ON_SLEEP" = "true" ]; then
    CMD_BT="sed -i.bak 's/^TOGGLE_BLUETOOTH_ON_SLEEP=true/TOGGLE_BLUETOOTH_ON_SLEEP=false/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ✅ Bluetooth OFF on Sleep | shell=/bin/bash param1=-c param2='$CMD_BT' terminal=false refresh=true"
else
    CMD_BT="sed -i.bak 's/^TOGGLE_BLUETOOTH_ON_SLEEP=false/TOGGLE_BLUETOOTH_ON_SLEEP=true/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ❌ Bluetooth OFF on Sleep | shell=/bin/bash param1=-c param2='$CMD_BT' terminal=false refresh=true"
fi

if [ "$AGGRESSIVE_POWER_PROFILE" = "true" ]; then
    CMD_PWR="sed -i.bak 's/^AGGRESSIVE_POWER_PROFILE=true/AGGRESSIVE_POWER_PROFILE=false/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ✅ Aggressive Power Profile | shell=/bin/bash param1=-c param2='$CMD_PWR' terminal=false refresh=true"
else
    CMD_PWR="sed -i.bak 's/^AGGRESSIVE_POWER_PROFILE=false/AGGRESSIVE_POWER_PROFILE=true/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ❌ Aggressive Power Profile | shell=/bin/bash param1=-c param2='$CMD_PWR' terminal=false refresh=true"
fi

if [ "$SHOW_STANDBY_ALERT" = "true" ]; then
    CMD_ALERT="sed -i.bak 's/^SHOW_STANDBY_ALERT=true/SHOW_STANDBY_ALERT=false/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ✅ Standby Alert | shell=/bin/bash param1=-c param2='$CMD_ALERT' terminal=false refresh=true"
else
    CMD_ALERT="sed -i.bak 's/^SHOW_STANDBY_ALERT=false/SHOW_STANDBY_ALERT=true/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
    echo "-- ❌ Standby Alert | shell=/bin/bash param1=-c param2='$CMD_ALERT' terminal=false refresh=true"
fi

echo "-- Soglia CPU: $CPU_THRESHOLD% | color=gray"
echo "-- Standby Delay: ${STANDBY_DELAY_MINUTES:-60}m | color=gray"
echo "-- Imposta 15m | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^STANDBY_DELAY_MINUTES=.*/STANDBY_DELAY_MINUTES=15/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "-- Imposta 30m | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^STANDBY_DELAY_MINUTES=.*/STANDBY_DELAY_MINUTES=30/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "-- Imposta 60m | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^STANDBY_DELAY_MINUTES=.*/STANDBY_DELAY_MINUTES=60/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "-- Imposta 120m | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^STANDBY_DELAY_MINUTES=.*/STANDBY_DELAY_MINUTES=120/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "---"

# --- FORCE SLEEP KILL ---
echo "🚫 Force Kill Apps | color=#FF3B30"
if [ -z "$FORCE_SLEEP_KILL_APPS" ]; then
    echo "-- (vuota) | color=gray"
else
    IFS='|' read -ra APPS_F <<< "$FORCE_SLEEP_KILL_APPS"
    for app in "${APPS_F[@]}"; do
        [ -z "$app" ] && continue
        REMOVE_CMD="perl -pi -e 's/(^|\\|)\\Q${app}\\E(?=\\||\$)//g; s/^\\|//; s/\\|\\|/\\|/g; s/\\|\$//' \"$CONF_FILE\""
        echo "-- 🧨 $app | shell=/bin/bash param1=-c param2='$REMOVE_CMD' terminal=false refresh=true"
    done
fi
echo "-- ➕ Aggiungi App... | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=FORCE_SLEEP_KILL_APPS terminal=false refresh=true"

echo "---"

# --- COMANDI ---
echo "🔧 Strumenti"
echo "⚙️ Configurazione Avanzata | shell=$HOME/.sleepmanager_editor terminal=true"
# echo "-- 📜 Apri Log Completo | shell=open param1=\"$LOG_FILE\" terminal=false"
echo "📜 Visualizza Log Completi | shell=open terminal=false param1=-e param2=\"$LOG_FILE\""

if [ -x "$HOME/.sleeplog" ]; then
    echo "-- 📊 Statistiche Uso | shell=/bin/bash param1=-lc param2=\"\\\"$HOME/.sleeplog\\\" stats\" terminal=true refresh=false"
else
    echo "-- 📊 Statistiche Uso (manca ~/.sleeplog) | color=orange"
fi
echo "-- 🔁 Ripristina App Ora | shell=\"$RESTORE_SCRIPT\" param1=--manual terminal=true refresh=false"
echo "-- 🔄 Reinstalla Sistema | shell=\"$HOME/.sleepmanager_install\" terminal=true refresh=false color=orange"
echo "-- 🐛 Debug Log GUI | shell=open param1=\"$HOME/.sleepmanager_gui.log\" terminal=false color=gray"
