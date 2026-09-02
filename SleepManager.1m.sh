#!/bin/bash
# <bitbar.title>macOS Sleep Manager Monitor</bitbar.title>
# <bitbar.version>v4.9.15</bitbar.version>
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>

CONF_FILE="$HOME/.sleepmanager.conf"
LOG_FILE="$HOME/.sleeplog_history"
EDITOR_AUTO="$HOME/.config_editor_auto"
RESTORE_SCRIPT="$HOME/.sleepmanager_restore"
VERSION_FILE="$HOME/.sleepmanager_version"
QUICKLAUNCH="$HOME/.quicklaunch"

if [ ! -f "$CONF_FILE" ]; then
    echo "⚠️ Config mancante"
    echo "---"
    echo "Esegui ~/.sleepmanager_install | terminal=true"
    exit 0
fi

source "$CONF_FILE"
[ -f "$VERSION_FILE" ] && source "$VERSION_FILE"

# Conta elementi lista separati da barra verticale.
count_apps() {
    [ -z "$1" ] && echo 0 || awk -F'|' '{print NF}' <<< "$1"
}

# Mostra lista compatta, senza duplicare tutte le azioni per ogni app.
show_list() {
    local label="$1"
    local variable="$2"
    local value="$3"
    local count
    count="$(count_apps "$value")"
    echo "-- $label ($count) | color=gray"
    echo "--- ✏️ Modifica | shell=/bin/bash param1=\"$EDITOR_AUTO\" param2=$variable terminal=true refresh=true"
}

LAST_DELTA=$(grep 'DELTA:' "$LOG_FILE" 2>/dev/null | tail -1 | sed -E 's/.*DELTA([^:]*): -?([0-9]+)%.*/\2%/' || true)
[ -z "$LAST_DELTA" ] && LAST_DELTA="—"
[ "$LAST_DELTA" = "0%" ] && STATUS_COLOR="darkgreen" || STATUS_COLOR="blue"

echo "🔋 -$LAST_DELTA | color=$STATUS_COLOR"
echo "---"
[ -n "$SM_VERSION" ] && echo "v$SM_VERSION | color=gray size=11"
echo "-- Sessioni: ${PRESERVE_APP_SESSIONS:-true} | color=gray size=11"
echo "-- Standby: ${STANDBY_DELAY_MINUTES:-15}m | color=gray size=11"
echo "---"

echo "⚡ Azioni rapide | color=#FFD60A size=13"
echo "-- 🚀 Avvia quick launch | shell=\"$QUICKLAUNCH\" terminal=false refresh=true color=#30D158"
echo "-- 💤 Sleep ora | shell=/usr/bin/pmset param1=sleepnow terminal=false refresh=false color=#FF453A"
echo "---"

echo "📋 Liste app | color=#7FDBFF size=13"
show_list "🛡️ Whitelist" "WHITELIST" "$WHITELIST"
show_list "🌑 Heavy Apps" "HEAVY_APPS" "$HEAVY_APPS"
show_list "💣 Force Kill" "FORCE_SLEEP_KILL_APPS" "$FORCE_SLEEP_KILL_APPS"
show_list "🔁 Restore Apps" "RESTORE_APPS" "$RESTORE_APPS"
show_list "🚀 Quick Launch" "QUICK_LAUNCH_APPS" "$QUICK_LAUNCH_APPS"
echo "---"

echo "📊 Log e report | color=#00D9FF size=13"
echo "-- Ultima sessione | shell=\"$HOME/.sleeplog\" param1=last terminal=true"
echo "-- Oggi | shell=\"$HOME/.sleeplog\" param1=today terminal=true"
echo "-- Ieri | shell=\"$HOME/.sleeplog\" param1=yesterday terminal=true"
echo "-- Settimana | shell=\"$HOME/.sleeplog\" param1=week terminal=true"
echo "-- Batteria settimana | shell=\"$HOME/.sleeplog\" param1=battery param2=week terminal=true"
echo "-- App settimana | shell=\"$HOME/.sleeplog\" param1=apps param2=week terminal=true"
echo "-- Kill settimana | shell=\"$HOME/.sleeplog\" param1=kills param2=week terminal=true"
echo "---"

echo "⚙️ Impostazioni | color=#5AC8FA size=13"
[ "$ENABLE_NOTIFICATIONS" = "true" ] && NOTIF_VALUE="false" || NOTIF_VALUE="true"
echo "-- Notifiche: $ENABLE_NOTIFICATIONS | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^ENABLE_NOTIFICATIONS=.*/ENABLE_NOTIFICATIONS=$NOTIF_VALUE/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
[ "$SAFE_QUIT_MODE" = "true" ] && SAFE_VALUE="false" || SAFE_VALUE="true"
echo "-- Chiusura sicura: $SAFE_QUIT_MODE | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^SAFE_QUIT_MODE=.*/SAFE_QUIT_MODE=$SAFE_VALUE/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
[ "$PRESERVE_APP_SESSIONS" = "true" ] && PRESERVE_VALUE="false" || PRESERVE_VALUE="true"
echo "-- Preserva sessioni: $PRESERVE_APP_SESSIONS | shell=/bin/bash param1=-c param2=\"sed -i.bak 's/^PRESERVE_APP_SESSIONS=.*/PRESERVE_APP_SESSIONS=$PRESERVE_VALUE/' '$CONF_FILE' && rm -f '${CONF_FILE}.bak'\" terminal=false refresh=true"
echo "-- Editor completo | shell=$HOME/.sleepmanager_editor terminal=true"
echo "-- Ripristina app ora | shell=\"$RESTORE_SCRIPT\" param1=--manual terminal=true"
