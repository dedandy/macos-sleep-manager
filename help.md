# Manuale Tecnico - macOS Sleep Manager

Questa guida raccoglie tutte le opzioni disponibili, gli snippet di uso da terminale e le note operative per la versione corrente.

## Obiettivo

- Ridurre il consumo in standby con deep sleep e zero dark wakes.
- Tracciare i cicli sleep/wake e separare il consumo reale da quello in standby.
- Gestire processi problematici, heavy apps e whitelist.
- Ripristinare le app principali al wake e al login (best effort).

## Architettura (sintesi)

- `sleep`: eseguito all'evento di sleep, applica ottimizzazioni e logga il consumo.
- `wakeup`: eseguito al wake, ripristina rete/processi e logga la sessione.
- `sleeplog`: visualizza le statistiche e l'ultimo storico.
- `~/.sleepmanager.conf`: unica fonte di configurazione.

## Configurazione Completa

File attivo:

```bash
~/.sleepmanager.conf
```

Opzioni principali:

```bash
ENABLE_NOTIFICATIONS=true
SAFE_QUIT_MODE=true
CPU_THRESHOLD=1.0
STANDBY_DELAY_MINUTES=60
DISABLE_DARKWAKE_FEATURES=true
WHITELIST="App A|App B"
HEAVY_APPS="App A|App B"
RESTORE_APPS="Google Chrome|Visual Studio Code|WebStorm|Microsoft Teams|WireGuard|Docker|Terminal"
RESTORE_TERMINAL_MAX=6
LOG_ASSERTIONS=true
```

Dettagli:

- `ENABLE_NOTIFICATIONS`: abilita/disabilita notifiche (se previste dagli script).
- `SAFE_QUIT_MODE`: chiusura controllata vs forzata dei processi.
- `CPU_THRESHOLD`: soglia CPU (percento) oltre la quale un processo puo' essere chiuso allo sleep.
- `STANDBY_DELAY_MINUTES`: minuti di standby prima dell'hibernation profonda.
- `DISABLE_DARKWAKE_FEATURES`: disabilita powernap/womp/ttyskeepawake/sleepservices durante lo sleep.
- `WHITELIST`: app sempre protette dalla chiusura.
- `HEAVY_APPS`: app chiuse allo sleep e riaperte al wake solo se su alimentazione.
- `RESTORE_APPS`: app riaperte al wake e al login se non sono gia' in esecuzione.
- `RESTORE_TERMINAL_MAX`: numero massimo di tab ripristinate nel Terminale.
- `LOG_ASSERTIONS`: aggiunge snapshot e top assertions ai log.

## Restore Apps (Wake/Login)

Il ripristino usa `~/.sleepmanager_restore`.

- Se Terminale e' gia' aperto con almeno una finestra, non crea nuovi tab.
- Se Terminale non ha finestre aperte, ripristina fino a `RESTORE_TERMINAL_MAX` directory.

Esecuzione manuale:

```bash
~/.sleepmanager_restore --manual
```

## Uso da Terminale

Installazione:

```bash
./install.sh
```

Reinstall/Upgrade pulito:

```bash
./uninstall.sh && ./install.sh
```

Log rapido:

```bash
sleeplog
sleeplog stats
sleeplog stats today
```

Opzioni avanzate:

```bash
sleeplog last
sleeplog today
sleeplog yesterday
sleeplog week
sleeplog battery [last|today|yesterday|week]
sleeplog apps [last|today|yesterday|week]
sleeplog kills [last|today|yesterday|week]
```

Verifica config:

```bash
./test_config.sh
cat ~/.sleepmanager.conf
```

Snapshot pmset (prima/dopo):

```bash
pmset -g custom
```

## SwiftBar

Per la menubar:

```bash
cp SleepManager.1m.sh ~/SwiftBar-Plugins/
```

Se usi un symlink e il menu non appare, preferisci il file reale nella cartella plugin.

Dal menu SwiftBar puoi impostare `STANDBY_DELAY_MINUTES` con i preset 15/30/60/120 minuti.

## Log Format

I log principali sono in:

```bash
~/.sleeplog_history
```

Esempi di righe:

```text
ACTION: SLEEP | BATT: 78% | AWAKE: 43m | USED: -6%
ACTION: WAKE | BATT: 72% | DELTA: -0% (SLEEP LOSS)
```

- `AWAKE`: minuti di uso attivo tra wake e sleep.
- `USED`: batteria consumata durante uso attivo.
- `DELTA`: perdita reale in standby.

## Legenda Colori (SwiftBar)

- Verde: `DELTA SLEEP 0%` (sleep perfetto, nessuna perdita).
- Blu: perdita in standby rilevata (es. `-3%`).
- Ciano: blocco "Ultimi Eventi".
- Arancione: heavy apps.
- Verde chiaro: whitelist protette.
- Grigio: valori informativi o non disponibili.

## Percorsi Installati

| Scopo | Path |
| --- | --- |
| Hook sleep | `~/.sleep` |
| Hook wake | `~/.wakeup` |
| Viewer log | `~/.sleeplog` |
| Editor config | `~/.sleepmanager_editor` |
| Helper editor | `~/.config_editor_auto` |
| Restore script | `~/.sleepmanager_restore` |
| Config | `~/.sleepmanager.conf` |
| Storico log | `~/.sleeplog_history` |
| Batteria sleep | `~/.sleep_batt_start` |
| Info wake | `~/.wake_batt_info` |
| Lista kill | `~/.sleep_killed_apps` |
| Cache dirs | `~/.sleepmanager_terminal_dirs` |
| LaunchAgent | `~/Library/LaunchAgents/com.sleepmanager.restore.plist` |

## FAQ

**La menubar e' vuota**

- Usa un file reale (no symlink) dentro `~/SwiftBar-Plugins`.
- Esegui lo script manualmente per vedere eventuali errori:
  ```bash
  ~/SwiftBar-Plugins/SleepManager.1m.sh
  ```

**Le app non si ripristinano**

- Verifica `RESTORE_APPS` in `~/.sleepmanager.conf`.
- Controlla il LaunchAgent:
  ```bash
  launchctl list | grep com.sleepmanager.restore
  ```

**I log non si aggiornano**

- Controlla permessi Full Disk Access a `sleepwatcher`.
- Verifica che `~/.sleep` e `~/.wakeup` siano eseguibili.

## Troubleshooting

- Se i log non si aggiornano, verifica i permessi di `sleepwatcher`.
- Se le app non si ripristinano, controlla `RESTORE_APPS` e il LaunchAgent.

LaunchAgent:

```bash
launchctl list | grep com.sleepmanager.restore
```

## Disinstallazione

```bash
./uninstall.sh
```

## Note su Sicurezza e Permessi

Concedi Full Disk Access a `sleepwatcher` per garantire l'accesso ai log e ai trigger di sistema.
