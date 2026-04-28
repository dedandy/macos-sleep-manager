#!/bin/bash
# <bitbar.title>macOS Sleep Manager Monitor</bitbar.title>
# <bitbar.version>v4.9.12</bitbar.version>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

CONF_FILE="$HOME/.sleepmanager.conf"
LOG_FILE="$HOME/.sleeplog_history"
EDITOR_AUTO="$HOME/.config_editor_auto"
RESTORE_SCRIPT="$HOME/.sleepmanager_restore"
VERSION_FILE="$HOME/.sleepmanager_version"
QUICKLAUNCH="$HOME/.quicklaunch"

[ -f "$CONF_FILE" ] && source "$CONF_FILE" || {
    echo "⚠️ Config mancante"
    echo "---"
    echo "Esegui: ~/.sleepmanager_install | terminal=true"
    exit 0
}
[ -f "$VERSION_FILE" ] && source "$VERSION_FILE"

count_apps() { [ -z "$1" ] && echo 0 || awk -F'|' '{print NF}' <<< "$1"; }

WHITELIST_COUNT="$(count_apps "$WHITELIST")"
HEAVY_COUNT="$(count_apps "$HEAVY_APPS")"
RESTORE_COUNT="$(count_apps "$RESTORE_APPS")"
QUICK_COUNT="$(count_apps "$QUICK_LAUNCH_APPS")"

# --- HEADER ---
LAST_DELTA=$(grep "DELTA:" "$LOG_FILE" 2>/dev/null | tail -1 | grep -o "\-[0-9]*%" | sed 's/-//' || echo "—")
[ "$LAST_DELTA" = "0%" ] && STATUS_COLOR="darkgreen" || STATUS_COLOR="blue"
echo "🔋 -$LAST_DELTA | color=$STATUS_COLOR"
echo "---"
[ -n "$SM_VERSION" ] && echo "v$SM_VERSION | color=gray size=11"
echo "---"

# --- QUICK ACTIONS ---
echo "⚡ AZIONI RAPIDE | color=#FFD60A size=13"
echo "-- 🚀 Avvia Tutte | shell=\"$QUICKLAUNCH\" terminal=false refresh=true color=#30D158"
echo "--- 💤 Sleep Ora | shell=/usr/bin/pmset param1=sleepnow terminal=false refresh=false color=#FF453A"
echo "-- 🔄 Refresh | shell=/bin/bash param1=-c param2='true' terminal=false refresh=true"
echo "---"

# --- LISTE APP (AGGREGATE) ---
echo "🧩 Gestione Liste | color=#7FDBFF"
echo "-- Seleziona lista + azione | color=gray size=11"
echo "-- 🛡️ Whitelist ($WHITELIST_COUNT)"
echo "--- ➕ Da Aperte | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=WHITELIST param3=add_running terminal=false refresh=true"
echo "--- ➕ Da App | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=WHITELIST param3=add_file terminal=false refresh=true"
echo "--- ♻️ Reset | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=WHITELIST param3=reset_file terminal=false refresh=true"
echo "--- 🧹 Svuota | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=WHITELIST param3=reset_empty terminal=false refresh=true"
echo "-- 🌑 Heavy ($HEAVY_COUNT)"
echo "--- ➕ Da Aperte | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=HEAVY_APPS param3=add_running terminal=false refresh=true"
echo "--- ➕ Da App | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=HEAVY_APPS param3=add_file terminal=false refresh=true"
echo "--- ♻️ Reset | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=HEAVY_APPS param3=reset_file terminal=false refresh=true"
echo "--- 🧹 Svuota | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=HEAVY_APPS param3=reset_empty terminal=false refresh=true"
echo "-- 🔁 Restore ($RESTORE_COUNT)"
echo "--- ➕ Da Aperte | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=RESTORE_APPS param3=add_running terminal=false refresh=true"
echo "--- ➕ Da App | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=RESTORE_APPS param3=add_file terminal=false refresh=true"
echo "--- ♻️ Reset | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=RESTORE_APPS param3=reset_file terminal=false refresh=true"
echo "--- 🧹 Svuota | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=RESTORE_APPS param3=reset_empty terminal=false refresh=true"
echo "-- 🚀 Quick Launch ($QUICK_COUNT)"
echo "--- ➕ Da Aperte | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=QUICK_LAUNCH_APPS param3=add_running terminal=false refresh=true"
echo "--- ➕ Da App | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=QUICK_LAUNCH_APPS param3=add_file terminal=false refresh=true"
echo "--- ♻️ Reset | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=QUICK_LAUNCH_APPS param3=reset_file terminal=false refresh=true"
echo "--- 🧹 Svuota | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=QUICK_LAUNCH_APPS param3=reset_empty terminal=false refresh=true"
echo "---"

# --- DASHBOARD ---
echo "📊 Ultimi Eventi | size=13 color=#00D9FF"
if [ -f "$LOG_FILE" ]; then
    tail -n 5 "$LOG_FILE" | grep -E "ACTION:" | sed 's/ACTION: //' | while read -r line; do
        echo "-- $line | font=Menlo size=11"
    done
else
    echo "-- Nessun log | color=gray"
fi
echo "---"

# --- LISTE DETTAGLIATE ---
echo "📋 Whitelist 🛡️ | color=#00FF88"
if [ -n "$WHITELIST" ]; then
    IFS='|' read -ra APPS <<< "$WHITELIST"
    for app in "${APPS[@]}"; do
        [ -z "$app" ] && continue
        REMOVE="perl -pi -e 's/(^|\|)\Q${app}\E(?=|\||$)//g; s/^\|//; s/\|\|/\|/g; s/\|$//' \"$CONF_FILE\""
        echo "-- ✓ $app | shell=/bin/bash param1=-c param2='$REMOVE' terminal=false refresh=true"
    done
else
    echo "-- (vuota) | color=gray"
fi

echo "---"
echo "📋 Heavy Apps 🌑 | color=#FF9500"
if [ -n "$HEAVY_APPS" ]; then
    IFS='|' read -ra APPS <<< "$HEAVY_APPS"
    for app in "${APPS[@]}"; do
        [ -z "$app" ] && continue
        REMOVE="perl -pi -e 's/(^|\|)\Q${app}\E(?=|\||$)//g; s/^\|//; s/\|\|/\|/g; s/\|$//' \"$CONF_FILE\""
        echo "-- ⚡ $app | shell=/bin/bash param1=-c param2='$REMOVE' terminal=false refresh=true"
    done
else
    echo "-- (vuota) | color=gray"
fi

echo "---"
echo "📋 Restore 🔁 | color=#6FE0FF"
if [ -n "$RESTORE_APPS" ]; then
    IFS='|' read -ra APPS <<< "$RESTORE_APPS"
    for app in "${APPS[@]}"; do
        [ -z "$app" ] && continue
        proc_name="$app"
        [ "$app" = "Visual Studio Code" ] && proc_name="Code"
        pgrep -x "$proc_name" >/dev/null 2>&1 && status="🟢" || status="⚪️"
        REMOVE="perl -pi -e 's/(^|\|)\Q${app}\E(?=|\||$)//g; s/^\|//; s/\|\|/\|/g; s/\|$//' \"$CONF_FILE\""
        echo "-- $status $app | shell=/bin/bash param1=-c param2='$REMOVE' terminal=false refresh=true"
    done
else
    echo "-- (vuota) | color=gray"
fi

echo "---"
echo "📋 Quick Launch 🚀 | color=#BF5AF2"
if [ -n "$QUICK_LAUNCH_APPS" ]; then
    IFS='|' read -ra APPS <<< "$QUICK_LAUNCH_APPS"
    for app in "${APPS[@]}"; do
        [ -z "$app" ] && continue
        REMOVE="perl -pi -e 's/(^|\|)\Q${app}\E(?=|\||$)//g; s/^\|//; s/\|\|/\|/g; s/\|$//' \"$CONF_FILE\""
        echo "-- ▶ $app | shell=/bin/bash param1=-c param2='open -a \"$app\"' terminal=false refresh=false"
        echo "-- ✕ $app | shell=/bin/bash param1=-c param2='$REMOVE' terminal=false refresh=true"
    done
else
    echo "-- (vuota) | color=gray"
fi

echo "---"

# --- IMPOSTAZIONI ---
echo "⚙️ Impostazioni | color=#5AC8FA"

# Toggle Notifiche
[ "$ENABLE_NOTIFICATIONS" = "true" ] && CMD_NOTIF="sed -i.bak 's/ENABLE_NOTIFICATIONS=true/ENABLE_NOTIFICATIONS=false/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'" || CMD_NOTIF="sed -i.bak 's/ENABLE_NOTIFICATIONS=false/ENABLE_NOTIFICATIONS=true/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
[ "$ENABLE_NOTIFICATIONS" = "true" ] && echo "-- ✅ Notifiche | shell=/bin/bash param1=-c param2='$CMD_NOTIF' terminal=false refresh=true" || echo "-- ❌ Notifiche | shell=/bin/bash param1=-c param2='$CMD_NOTIF' terminal=false refresh=true"

# Toggle Safe Quit
[ "$SAFE_QUIT_MODE" = "true" ] && CMD_SAFE="sed -i.bak 's/SAFE_QUIT_MODE=true/SAFE_QUIT_MODE=false/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'" || CMD_SAFE="sed -i.bak 's/SAFE_QUIT_MODE=false/SAFE_QUIT_MODE=true/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'"
[ "$SAFE_QUIT_MODE" = "true" ] && echo "-- ✅ Chiusura Sicura | shell=/bin/bash param1=-c param2='$CMD_SAFE' terminal=false refresh=true" || echo "-- ⚡ Chiusura Forzata | shell=/bin/bash param1=-c param2='$CMD_SAFE' terminal=false refresh=true"

# Standby Delay
echo "-- ⏱️ Standby: ${STANDBY_DELAY_MINUTES:-60}m | color=gray"
echo "--- 15m | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^STANDBY_DELAY_MINUTES=.*/STANDBY_DELAY_MINUTES=15/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "--- 30m | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^STANDBY_DELAY_MINUTES=.*/STANDBY_DELAY_MINUTES=30/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "--- 60m | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^STANDBY_DELAY_MINUTES=.*/STANDBY_DELAY_MINUTES=60/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "--- 120m | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^STANDBY_DELAY_MINUTES=.*/STANDBY_DELAY_MINUTES=120/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"

# Max Terminal Tabs
echo "-- 🔢 Max Terminal: ${RESTORE_TERMINAL_MAX:-6} | color=gray"
echo "--- 4 tab | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^RESTORE_TERMINAL_MAX=.*/RESTORE_TERMINAL_MAX=4/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "--- 6 tab | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^RESTORE_TERMINAL_MAX=.*/RESTORE_TERMINAL_MAX=6/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "--- 8 tab | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^RESTORE_TERMINAL_MAX=.*/RESTORE_TERMINAL_MAX=8/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "---"

# --- STRUMENTI ---
echo "🔧 Strumenti | color=#FF9F0A"
echo "⚙️ Editor Completo | shell=$HOME/.sleepmanager_editor terminal=true"
echo "📜 Apri Log | shell=open terminal=false param1=-e param2=\"$LOG_FILE\""
echo "-- 📊 Statistiche | shell=/bin/bash param1=-lc param2=\"\\\"$HOME/.sleeplog\\\" stats\" terminal=true"
echo "-- 🔁 Restore Ora | shell=\"$RESTORE_SCRIPT\" param1=--manual terminal=true"
echo "-- 🔄 Reinstalla | shell=\"$HOME/.sleepmanager_install\" terminal=true color=orange"
echo "-- 📖 Guida | shell=open terminal=false param1=\"$HOME/help.md\""