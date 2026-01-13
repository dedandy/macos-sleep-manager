#!/bin/bash
# restore_apps.sh - reopen key apps and restore Terminal working directories

CONF_FILE="$HOME/.sleepmanager.conf"
VERSION_FILE="$HOME/.sleepmanager_version"
TERMINAL_DIRS_FILE="$HOME/.sleepmanager_terminal_dirs"
LAST_RUN_FILE="$HOME/.sleepmanager_restore_last"

[ -f "$CONF_FILE" ] && source "$CONF_FILE"
[ -f "$VERSION_FILE" ] && source "$VERSION_FILE"

now_ts=$(date +%s)
last_ts=$(cat "$LAST_RUN_FILE" 2>/dev/null || echo 0)
if [ $((now_ts - last_ts)) -lt 120 ]; then
    exit 0
fi
echo "$now_ts" > "$LAST_RUN_FILE"

is_running() {
    pgrep -x "$1" >/dev/null 2>&1
}

open_if_not_running() {
    local app_name="$1"
    local proc_name="$2"
    if ! is_running "$proc_name"; then
        open -ga "$app_name"
    fi
}

get_proc_name() {
    case "$1" in
        "Visual Studio Code") echo "Code" ;;
        *) echo "$1" ;;
    esac
}

restore_list="${RESTORE_APPS:-Google Chrome|Visual Studio Code|WebStorm|Microsoft Teams|WireGuard|Docker}"
IFS='|' read -r -a apps <<< "$restore_list"
for app in "${apps[@]}"; do
    [ -z "$app" ] && continue
    proc_name=$(get_proc_name "$app")
    open_if_not_running "$app" "$proc_name"
done

terminal_running=false
if is_running "Terminal"; then
    terminal_running=true
fi

terminal_windows=0
if [ "$terminal_running" = true ]; then
    terminal_windows=$(osascript -e 'tell application "Terminal" to count windows' 2>/dev/null | tr -d ' ')
fi

if [ "$terminal_running" = false ]; then
    open -ga "Terminal"
fi

if [ "$terminal_windows" -eq 0 ] && [ -s "$TERMINAL_DIRS_FILE" ]; then
    max_tabs="${RESTORE_TERMINAL_MAX:-6}"
    osascript -e 'tell application "Terminal" to activate'
    sort -u "$TERMINAL_DIRS_FILE" | head -n "$max_tabs" | while IFS= read -r dir; do
        [ -d "$dir" ] || continue
        escaped_dir=${dir//\"/\\\"}
        osascript -e "tell application \"Terminal\" to do script \"cd \\\"$escaped_dir\\\"\""
    done
fi
