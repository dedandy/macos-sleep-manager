# Manuale operativo - macOS Sleep Manager

Manuale pratico per installare, configurare, usare e diagnosticare macOS Sleep Manager.

## Cosa fa

Sleep Manager collega due hook di sistema agli eventi del Mac:

- `sleep` registra batteria e uso attivo, salva le impostazioni `pmset`, riduce i dark wake e gestisce i processi configurati.
- `wakeup` registra la batteria al ritorno, calcola la perdita durante lo sleep, ripristina il profilo e riapre le app.
- `sleeplog` legge lo storico e produce viste sintetiche.
- `SleepManager.1m.sh` costruisce il menu SwiftBar.
- `restore_apps.sh` riapre app e directory Terminal al wake/login.

Configurazione unica:

~~~~text
~/.sleepmanager.conf
~~~~

## Installazione

Prerequisiti:

~~~~bash
brew install sleepwatcher
~~~~

Installazione o aggiornamento:

~~~~bash
chmod +x install.sh
./install.sh
source ~/.zshrc
~~~~

L'installer copia gli script nella home, crea il file di configurazione, configura `pmset`, riavvia `sleepwatcher`, installa il LaunchAgent di ripristino e preserva i valori già impostati durante gli upgrade.

Verifica:

~~~~bash
./diagnostic.sh
./test_config.sh
cat ~/.sleepmanager.conf
~~~~

Per aggiornare usa `./install.sh`. Per un normale upgrade non usare `uninstall.sh`: rimuove log e configurazione.

## Uso quotidiano

### Log

~~~~bash
sleeplog
sleeplog last
sleeplog today
sleeplog yesterday
sleeplog week
sleeplog stats
sleeplog stats today
sleeplog battery today
sleeplog battery week
sleeplog apps week
sleeplog kills week
~~~~

Significato:

- `BATT`: percentuale rilevata.
- `AWAKE`: minuti trascorsi dal wake precedente.
- `USED`: consumo durante uso attivo.
- `DELTA`: consumo durante sleep.
- `apps`: conteggio raggruppato di kill, restore, postpone e preserve.
- `kills`: conteggio delle app terminate, mantenendo il nome completo.

Se una batteria aumenta durante il periodo osservato, il consumo viene mostrato come zero: la carica non è consumo.

### Quick launch

~~~~bash
quicklaunch
~~~~

Avvia tutte le app in `QUICK_LAUNCH_APPS`, saltando quelle già attive.

### Ripristino app

~~~~bash
~/.sleepmanager_restore --manual
~~~~

Il ripristino automatico avviene al wake e al login. Le app già aperte non vengono riaperte. Le directory Terminal vengono ricreate solo se Terminal non ha finestre aperte, fino a `RESTORE_TERMINAL_MAX`.

## Configurazione

Modifica da terminale:

~~~~bash
sleepconf
~~~~

Modifica manuale:

~~~~bash
$EDITOR ~/.sleepmanager.conf
~~~~

Liste app usano `|`:

~~~~bash
WHITELIST="Music|Spotify|IINA"
HEAVY_APPS="Google Chrome|Firefox"
FORCE_SLEEP_KILL_APPS="WhatsApp|Google Chrome"
RESTORE_APPS="Google Chrome|Visual Studio Code|Terminal"
QUICK_LAUNCH_APPS="Safari|Notes"
~~~~

### Opzioni

| Chiave | Funzione | Consiglio |
| --- | --- | --- |
| `ENABLE_NOTIFICATIONS` | Notifiche operative | `true` |
| `SAFE_QUIT_MODE` | Chiusura controllata invece di kill immediato | `true` |
| `CPU_THRESHOLD` | Soglia CPU per modalità aggressiva | `1.0` |
| `STANDBY_DELAY_MINUTES` | Ritardo prima dello standby profondo | `10-15` |
| `PRESERVE_APP_SESSIONS` | Mantiene vive le sessioni normali | `true` |
| `DISABLE_DARKWAKE_FEATURES` | Disabilita servizi di dark wake | `true` |
| `FORCE_SLEEP_KILL_APPS` | Kill sempre eseguito allo sleep | lista minima |
| `WHITELIST` | App protette dalla chiusura aggressiva | app affidabili |
| `HEAVY_APPS` | App pesanti gestite al ciclo sleep/wake | browser/editor |
| `RESTORE_APPS` | App da riaprire al wake/login | app di lavoro |
| `QUICK_LAUNCH_APPS` | App lanciate insieme | app frequenti |
| `RESTORE_TERMINAL_MAX` | Numero massimo tab Terminal | `6` |
| `LOG_ASSERTIONS` | Snapshot di assertion e log power | `true` |
| `TOGGLE_BLUETOOTH_ON_SLEEP` | Bluetooth off allo sleep; richiede `blueutil` | `false` |
| `AGGRESSIVE_POWER_PROFILE` | `disksleep` e `autopoweroff` aggressivi | `false` |
| `SHOW_STANDBY_ALERT` | Promemoria su alimentazione/USB | `true` |

Ordine pratico per le liste:

1. Metti in `FORCE_SLEEP_KILL_APPS` solo app che impediscono davvero lo sleep.
2. Usa `WHITELIST` per app da non chiudere nella modalità aggressiva.
3. Usa `HEAVY_APPS` per browser/editor pesanti.
4. Usa `RESTORE_APPS` per il tuo ambiente di lavoro.
5. Usa `QUICK_LAUNCH_APPS` solo per app che vuoi aprire insieme.

Il force-kill ha priorità sulla preservazione delle sessioni.

## SwiftBar

Installa SwiftBar, poi:

~~~~bash
mkdir -p ~/SwiftBar-Plugins
cp SleepManager.1m.sh ~/SwiftBar-Plugins/
~~~~

Il menu mostra:

- stato batteria e ultimo delta sleep;
- azioni rapide: quick launch e sleep immediato;
- una voce `Modifica` per ogni lista app;
- report: ultima sessione, oggi, ieri, settimana, batteria, app e kill;
- toggle per notifiche, chiusura sicura e preservazione sessioni;
- editor completo, log e ripristino manuale.

Se non appare:

~~~~bash
ls -l ~/SwiftBar-Plugins/SleepManager.1m.sh
bash -n ~/SwiftBar-Plugins/SleepManager.1m.sh
~/SwiftBar-Plugins/SleepManager.1m.sh
~~~~

Preferire un file reale, non un symlink.

## Diagnosi consumo batteria

Prima raccogli dati:

~~~~bash
pmset -g custom
pmset -g assertions
pmset -g log | tail -n 100
sleeplog battery week
sleeplog apps week
sleeplog kills week
~~~~

Cerca nel log:

- `DarkWake` frequenti;
- `Wake from` ripetuti;
- `ExternalMedia`;
- dispositivi USB, hub, dock o monitor;
- assertion di rete;
- wake da `UserActivity`, coperchio o alimentazione.

Test consigliato per una notte:

1. carica il Mac;
2. scollega hub, dischi e dock;
3. lascia `LOG_ASSERTIONS=true`;
4. chiudi il coperchio;
5. al mattino esegui `sleeplog battery today`;
6. confronta con `pmset -g log`.

Per assenze lunghe, non lasciare periferiche USB collegate e usa `STANDBY_DELAY_MINUTES=10` o `15`. Cambia una sola impostazione alla volta.

## Diagnostica installazione

~~~~bash
./diagnostic.sh
~~~~

Controlla:

- file installati ed eseguibili;
- valori di configurazione;
- sintassi di `config_editor_auto`;
- `tcpkeepalive` e `standby`;
- servizio `sleepwatcher`;
- file picker AppleScript.

Controlli manuali:

~~~~bash
brew services list | grep sleepwatcher
launchctl list | grep com.sleepmanager.restore
ls -l ~/.sleep ~/.wakeup ~/.sleeplog
~~~~

Full Disk Access e permessi Automation possono impedire hook, apertura app e lettura dati.

## File creati

| Scopo | Percorso |
| --- | --- |
| Hook sleep | `~/.sleep` |
| Hook wake | `~/.wakeup` |
| Viewer log | `~/.sleeplog` |
| Editor | `~/.sleepmanager_editor` |
| Editor liste | `~/.config_editor_auto` |
| Restore | `~/.sleepmanager_restore` |
| Quick launch | `~/.quicklaunch` |
| Config | `~/.sleepmanager.conf` |
| Storico | `~/.sleeplog_history` |
| Diagnostica | `~/.sleepmanager_diagnose` |
| Snapshot batteria | `~/.sleep_batt_start` |
| Info wake | `~/.wake_batt_info` |
| App killate | `~/.sleep_killed_apps` |
| Directory Terminal | `~/.sleepmanager_terminal_dirs` |
| LaunchAgent | `~/Library/LaunchAgents/com.sleepmanager.restore.plist` |

## FAQ

### La menubar è vuota

Controlla file, permessi, sintassi e avvio manuale:

~~~~bash
ls -l ~/SwiftBar-Plugins/SleepManager.1m.sh
bash -n ~/SwiftBar-Plugins/SleepManager.1m.sh
~/SwiftBar-Plugins/SleepManager.1m.sh
~~~~

### I log non si aggiornano

Verifica `sleepwatcher`, Full Disk Access, eseguibilità degli hook e:

~~~~bash
tail -n 100 ~/.sleeplog_history
~~~~

### Le app non si ripristinano

Verifica `RESTORE_APPS`, LaunchAgent e permessi Automation. Prova:

~~~~bash
~/.sleepmanager_restore --manual
~~~~

### Il Mac perde batteria chiuso

Controlla `pmset -g log`, assertion e dispositivi esterni. Non assumere che il Mac sia rimasto sempre in deep sleep: `DarkWake` e wake ripetuti possono consumare batteria.

### Ho perso la configurazione dopo un aggiornamento

Cerca il backup:

~~~~bash
ls -t ~/.sleepmanager.conf.backup-* | head -1
~~~~

L'installer crea un backup prima di aggiornare il file.

## Disinstallazione

~~~~bash
./uninstall.sh
~~~~

La disinstallazione ferma `sleepwatcher`, rimuove hook, configurazione, log e LaunchAgent, quindi applica il profilo power predefinito dallo script. Salva prima i file che vuoi conservare.

## Sviluppo

Controllo sintassi:

~~~~bash
for file in sleep wakeup sleeplog SleepManager.1m.sh install.sh diagnostic.sh config_editor config_editor_auto quicklaunch restore_apps.sh test_config.sh; do
    bash -n "$file" || exit 1
done
~~~~

Poi:

~~~~bash
./test_config.sh
git diff --check
~~~~

I test sintattici non sostituiscono un ciclo reale sleep/wake su macOS.
