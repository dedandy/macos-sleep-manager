#!/bin/bash
echo "Disinstallazione macOS Sleep Manager..."
brew services stop sleepwatcher
sudo pmset -a hibernatemode 3 powernap 1
rm -f "$HOME/.sleep" "$HOME/.wakeup" "$HOME/.sleeplog" "$HOME/.sleepmanager.conf"
rm -f "$HOME/.sleeplog_history" "$HOME/.sleep_killed_apps" "$HOME/.sleep_pending_apps"
echo "Rimozione completata. Ripristinate impostazioni Apple."