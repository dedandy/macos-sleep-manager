#!/bin/bash
# uninstall.sh v4.6

echo -e "\033[1;31mRimozione macOS Sleep Manager e ripristino totale...\033[0m"

# 1. Ferma il servizio
brew services stop sleepwatcher

# 2. Ripristino parametri originali Apple (Standby lungo e rete attiva)
sudo pmset -a hibernatemode 3
sudo pmset -a standby 1
sudo pmset -a standbydelayhigh 86400
sudo pmset -a standbydelaylow 86400
sudo pmset -a powernap 1
sudo pmset -a tcpkeepalive 1
sudo pmset -a proximitywake 1
sudo pmset -a ttyskeepawake 1

# 3. Rimozione file eseguibili e config
rm -f "$HOME/.sleep"
rm -f "$HOME/.wakeup"
rm -f "$HOME/.sleeplog"
rm -f "$HOME/.sleepmanager_editor"
rm -f "$HOME/.sleepmanager.conf"
rm -f "$HOME/.config_editor_auto"
rm -f "$HOME/.sleepmanager_restore"
rm -f "$HOME/.sleepmanager_version"
# rm -f "$HOME/.selector.scpt"

# 4. Pulizia file temporanei e log
rm -f "$HOME/.sleeplog_history"
rm -f "$HOME/.sleep_batt_start"
rm -f "$HOME/.wake_batt_info"        # File v4.6
rm -f "$HOME/.sleep_killed_apps"
rm -f "$HOME/.sleep_pending_apps"
rm -f "$HOME/.sleepmanager_terminal_dirs"

# 5. Rimozione launch agent di ripristino
RESTORE_AGENT="$HOME/Library/LaunchAgents/com.sleepmanager.restore.plist"
launchctl unload "$RESTORE_AGENT" >/dev/null 2>&1
rm -f "$RESTORE_AGENT"

echo "Disinstallazione completata. Il Mac è tornato alle impostazioni di fabbrica."
