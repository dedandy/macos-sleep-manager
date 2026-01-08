#!/bin/bash
# <bitbar.title>macOS Sleep Manager Monitor</bitbar.title>
# <bitbar.version>v4.7.2</bitbar.version>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

CONF_FILE="$HOME/.sleepmanager.conf"
LOG_FILE="$HOME/.sleeplog_history"
EDITOR_AUTO="$HOME/.config_editor_auto"

# Carica configurazione
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
else
    echo "⚠️ Config mancante"
    echo "---"
    echo "Esegui: ~/.sleepmanager_install | terminal=true"
    exit 0
fi

# --- STATO BARRA ---
LAST_DELTA=$(grep "DELTA:" "$LOG_FILE" 2>/dev/null | tail -1 | grep -o "\-[0-9]*%" | sed 's/-//' || echo "—")
if [ "$LAST_DELTA" = "0%" ]; then
    echo "🔋 Perfect | color=darkgreen"
else
    echo "🔋 -$LAST_DELTA | color=blue"
fi
echo "---"

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
        # Comando di rimozione con escape corretto
        REMOVE_CMD="sed -i.bak \"s/\b${app}\b//;s/||/|/g;s/^\|//;s/\|$//\" \"$CONF_FILE\" && rm -f \"${CONF_FILE}.bak\""
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
        REMOVE_CMD="sed -i.bak \"s/\b${app}\b//;s/||/|/g;s/^\|//;s/\|$//\" \"$CONF_FILE\" && rm -f \"${CONF_FILE}.bak\""
        echo "-- ⚡ $app | shell=/bin/bash param1=-c param2='$REMOVE_CMD' terminal=false refresh=true"
    done
fi
echo "-- ➕ Aggiungi App... | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=HEAVY_APPS terminal=false refresh=true"

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

echo "-- Soglia CPU: $CPU_THRESHOLD% | color=gray"

echo "---"

# --- COMANDI ---
echo "🔧 Strumenti"
echo "⚙️ Configurazione Avanzata | shell=$HOME/.sleepmanager_editor terminal=true"
# echo "-- 📜 Apri Log Completo | shell=open param1=\"$LOG_FILE\" terminal=false"
echo "📜 Visualizza Log Completi | shell=open terminal=false param1=-e param2=\"$LOG_FILE\""

echo "-- 📊 Statistiche Uso | shell=\"$HOME/.sleeplog\" param1=stats terminal=true refresh=false"
# echo "-- 📊 Statistiche Uso | shell=$HOME/.sleeplog terminal=true param1=stats"
echo "-- 🔄 Reinstalla Sistema | shell=\"$HOME/.sleepmanager_install\" terminal=true refresh=false color=orange"
echo "-- 🐛 Debug Log GUI | shell=open param1=\"$HOME/.sleepmanager_gui.log\" terminal=false color=gray"