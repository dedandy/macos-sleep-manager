#!/bin/bash
echo "Rimozione macOS Sleep Manager v4.2..."
brew services stop sleepwatcher
# Ripristino valori Apple standard
sudo pmset -a hibernatemode 3 standby 1 powernap 1 tcpkeepalive 1
rm -f "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" "$HOME/.sleepmanager_editor" "$HOME/.sleepmanager.conf"
rm -f "$HOME/.sleeplog_history" "$HOME/.sleep_killed_apps" "$HOME/.sleep_pending_apps"
echo "Disinstallazione completata. Sistema ripristinato."