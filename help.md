# 🔋 macOS Smart Sleep Manager

Sistema intelligente di gestione energetica per macOS che chiude automaticamente le app ad alto consumo quando il Mac va in sleep (a batteria) e le riapre al risveglio.

## 📋 Indice

- [Caratteristiche](#-caratteristiche)
- [Requisiti](#-requisiti)
- [Installazione](#-installazione)
- [Configurazione](#-configurazione)
- [Utilizzo](#-utilizzo)
- [Comandi sleeplog](#-comandi-sleeplog)
- [File di sistema](#-file-di-sistema)
- [Risoluzione problemi](#-risoluzione-problemi)

## ✨ Caratteristiche

- ✅ **Completamente automatico**: nessuna lista hardcoded di app
- ✅ **Intelligente**: chiude solo app sopra soglia CPU configurabile
- ✅ **Preserva workflow**: riapre automaticamente le app al risveglio
- ✅ **Protegge sistema**: whitelist di app critiche mai toccate
- ✅ **Logging dettagliato**: traccia completa di tutte le operazioni
- ✅ **Futureproof**: funziona con qualsiasi app, anche quelle non ancora installate
- ✅ **Solo su batteria**: non interferisce quando collegato alla corrente

## 🔧 Requisiti

- macOS (testato su versioni recenti)
- [Homebrew](https://brew.sh/)
- sleepwatcher (`brew install sleepwatcher`)

## 📦 Installazione

### Installazione automatica (consigliata) 🚀

```bash
# Clona il repository
git clone <tuo-repo-privato>
cd macos-sleep-manager

# Esegui lo script di installazione
chmod +x install.sh
./install.sh
```

Lo script si occuperà di:
- ✅ Verificare/installare sleepwatcher
- ✅ Copiare gli script nella home
- ✅ Configurare i permessi
- ✅ Aggiungere l'alias sleeplog
- ✅ Avviare il servizio sleepwatcher
- ✅ Permettere personalizzazione interattiva

### Installazione manuale

Se preferisci installare manualmente o vuoi capire meglio il processo:

#### 1. Installa sleepwatcher

[sleepwatcher](https://www.bernhard-baehr.de/) è un daemon che monitora gli eventi di sleep/wake del Mac ed esegue script personalizzati.

```bash
brew install sleepwatcher
```

#### 2. Clona/scarica gli script

```bash
# Clona questo repository
git clone <tuo-repo-privato>
cd macos-sleep-manager
```

#### 3. Copia gli script nella home

```bash
cp sleep ~/.sleep
cp wakeup ~/.wakeup
cp sleeplog ~/.sleeplog

chmod +x ~/.sleep
chmod +x ~/.wakeup
chmod +x ~/.sleeplog
```

#### 4. Configura l'alias per sleeplog

```bash
echo 'alias sleeplog="~/.sleeplog"' >> ~/.zshrc
source ~/.zshrc
```

#### 5. Configura sleepwatcher come servizio

sleepwatcher cerca automaticamente i file `~/.sleep` e `~/.wakeup` e li esegue agli eventi corrispondenti.

```bash
# Avvia sleepwatcher come servizio (si avvierà automaticamente al boot)
brew services start sleepwatcher

# Verifica che sia attivo
brew services list | grep sleepwatcher
# Dovrebbe mostrare "started"
```

**Come funziona sleepwatcher:**
- Monitora gli eventi di sistema (sleep/wake)
- Quando il Mac va in sleep → esegue `~/.sleep`
- Quando il Mac si risveglia → esegue `~/.wakeup`
- Funziona come servizio di sistema (daemon)
- Si avvia automaticamente al login

#### 6. Testa il sistema

```bash
# Simula sleep (chiudi lo schermo)
# Apri alcune app, poi chiudi lo schermo del Mac

# Al risveglio, controlla i log
sleeplog
```

## ⚙️ Configurazione

### Ottimizzazione consumi in standby 🔋

Se vuoi ridurre **drasticamente** il consumo in sleep (target: <0.5% in 12 ore), segui queste ottimizzazioni:

#### 1. Abbassa la soglia CPU (più aggressivo)

```bash
# Modifica ~/.sleep
nano ~/.sleep

# Cambia CPU_THRESHOLD da 1.0 a 0.3
CPU_THRESHOLD=0.3
```

Questo chiuderà **molte più app**, anche quelle quasi ferme.

#### 2. Abilita ibernazione profonda (consigliato)

macOS di default usa `hibernatemode 3` (RAM attiva + backup su disco). Per consumo quasi zero:

```bash
# Verifica modalità attuale
pmset -g | grep hibernatemode

# Imposta ibernazione completa (RAM scritta su disco e spenta)
sudo pmset -a hibernatemode 25

# ATTENZIONE: Il risveglio sarà più lento (10-30 secondi)
```

**Modalità disponibili:**
- `0` = Sleep normale (RAM sempre alimentata) - **consumo alto**
- `3` = Sleep + backup RAM (default MacBook) - **consumo medio** ⬅️ Default
- `25` = Ibernazione completa (RAM su disco) - **consumo quasi zero** ⬅️ Consigliato

**Per tornare al default:**
```bash
sudo pmset -a hibernatemode 3
```

#### 3. Disabilita Power Nap (processi in background)

Power Nap sveglia periodicamente il Mac per controllare email, aggiornamenti, ecc.

```bash
# Disabilita Power Nap
sudo pmset -a powernap 0

# Verifica
pmset -g | grep powernap
```

#### 4. Chiudi più app manualmente

Alcune app consumano molto anche "ferme":

```bash
# Aggiungi queste a PROTECTED_APPS per NON proteggerle (così vengono chiuse):
# - Rimuovi "Terminal" se non ti serve
# - Rimuovi "Activity Monitor"

# Oppure abbassa semplicemente la soglia a 0.3 (punto 1)
```

#### 5. Configurazione completa "Ultra risparmio"

```bash
# Copia-incolla questo per massimo risparmio:

# Ibernazione completa
sudo pmset -a hibernatemode 25

# Disabilita Power Nap
sudo pmset -a powernap 0

# Abbassa soglia CPU a 0.3%
sed -i.bak 's/CPU_THRESHOLD=1.0/CPU_THRESHOLD=0.3/' ~/.sleep

# Riavvia sleepwatcher
brew services restart sleepwatcher

echo "✅ Configurazione ultra-risparmio attivata!"
echo "⚠️  Risveglio sarà più lento (~20-30 secondi)"
```

#### Risultati attesi

| Configurazione | Consumo 12h | Risveglio |
|----------------|-------------|-----------|
| **Default macOS** | ~5-8% | Immediato |
| **Script default** | ~2% | Immediato |
| **+ hibernatemode 25** | ~0.3-0.5% | +20-30s |
| **+ CPU 0.3 + no powernap** | ~0.1-0.3% | +20-30s |

#### Per tornare alla configurazione normale

```bash
# Ripristina impostazioni standard
sudo pmset -a hibernatemode 3
sudo pmset -a powernap 1
sed -i.bak 's/CPU_THRESHOLD=0.3/CPU_THRESHOLD=1.0/' ~/.sleep
brew services restart sleepwatcher
```

### Script `sleep` - Opzioni principali

#### Soglia CPU

Modifica la soglia di CPU per decidere quali app chiudere:

```bash
# Nel file ~/.sleep, riga ~13
CPU_THRESHOLD=1.0   # Default: 1% CPU
```

**Valori consigliati:**
- `0.5` - Molto aggressivo (chiude quasi tutto)
- `1.0` - Bilanciato (default, consigliato)
- `2.0` - Conservativo (solo veri vampiri energetici)
- `5.0` - Molto conservativo (solo app molto attive)

#### App protette

Due categorie di app protette nel file `~/.sleep`:

**1. CRITICAL_APPS** - NON MODIFICARE
App di sistema che causerebbero crash se chiuse:
```bash
declare -a CRITICAL_APPS=(
  "Finder"
  "Dock"
  "SystemUIServer"
  "WindowServer"
  "loginwindow"
)
```

**2. PROTECTED_APPS** - PERSONALIZZA QUI
App che vuoi mantenere sempre aperte:
```bash
declare -a PROTECTED_APPS=(
  "Terminal"
  "iTerm"
  "Activity Monitor"
  # "Safari"           # decommentare per proteggere Safari
  # "Mail"             # decommentare per proteggere Mail
  # "Spotify"          # decommentare per proteggere Spotify
  # "1Password"        # esempio: password manager
  # "Little Snitch"    # esempio: firewall
)
```

**Per proteggere un'app:** rimuovi il `#` davanti al nome  
**Per permettere il kill:** aggiungi `#` davanti al nome o rimuovila dalla lista

### Script `wakeup` - Opzioni

#### Delay iniziale

```bash
# Nel file ~/.wakeup, riga ~8
sleep 3   # Secondi di attesa prima di riaprire le app
```

Aumenta se le app non si riaprono correttamente (es. `sleep 5`).

#### App da non riaprire

Anche se chiuse, alcune app possono non essere riaperte:

```bash
# Nel file ~/.wakeup, dopo riga ~27
case "$APP" in
  "Finder"|"System Settings"|"Calendar"|"Reminders"|"Spotlight") 
    SKIPPED=$((SKIPPED + 1))
    continue 
    ;;
  "Docker")  # aggiungi qui app che NON vuoi riaprire mai
    SKIPPED=$((SKIPPED + 1))
    continue
    ;;
esac
```

## 🚀 Utilizzo

Gli script funzionano **automaticamente** grazie a sleepwatcher, che monitora gli eventi di sleep/wake del sistema:

**sleepwatcher** è configurato come servizio di sistema (via Homebrew) e:
- Si avvia automaticamente al boot
- Monitora continuamente il sistema
- Esegue `~/.sleep` quando il Mac va in sleep
- Esegue `~/.wakeup` quando il Mac si risveglia
- Non richiede alcuna interazione manuale

### Flusso automatico

1. **Chiudi lo schermo** del Mac (a batteria)
2. sleepwatcher rileva l'evento → esegue `~/.sleep`
3. Lo script `sleep` valuta tutte le app aperte
4. Chiude quelle sopra la soglia CPU
5. **Apri lo schermo**
6. sleepwatcher rileva l'evento → esegue `~/.wakeup`
7. Lo script `wakeup` riapre le app chiuse

### Flusso operativo

```
[Mac va in sleep (schermo chiuso)]
       ↓
[sleepwatcher rileva evento]
       ↓
[Esegue ~/.sleep]
       ↓
[Verifica: a batteria?] → NO → [Esci]
       ↓ SÌ
[Scansiona tutte le app]
       ↓
[Per ogni app non protetta:]
       ↓
[CPU > soglia?] → NO → [Mantieni aperta]
       ↓ SÌ
[Chiudi app (gentile → forzato)]
       ↓
[Salva in apps_killed]
       ↓
[Log statistiche]

[Mac si risveglia (schermo aperto)]
       ↓
[sleepwatcher rileva evento]
       ↓
[Esegue ~/.wakeup]
       ↓
[Attendi 3 secondi]
       ↓
[Leggi apps_killed]
       ↓
[Per ogni app chiusa:]
       ↓
[Già aperta?] → SÌ → [Salta]
       ↓ NO
[Riapri app]
       ↓
[Log statistiche]
```

## 📊 Comandi sleeplog

### Visualizzazione base

```bash
# Mostra ultime 50 righe del log
sleeplog

# Mostra ultime N righe
sleeplog recent 100
sleeplog recent 200
```

### Statistiche

```bash
# Statistiche complete
sleeplog stats

# Output esempio:
# 📊 STATISTICHE GLOBALI
# Sessioni Sleep: 45
# Sessioni Wake: 45
# 
# 🔥 Top 10 app più chiuse:
#    23 volte: Google Chrome
#    18 volte: Slack
#    15 volte: Docker
# ...
```

### Filtra per data

```bash
# Attività di oggi
sleeplog today

# Mostra solo le attività della data corrente
```

### Cerca app specifica

```bash
# Storia completa di un'app
sleeplog app "Google Chrome"
sleeplog app Spotify
sleeplog app Docker

# Output esempio:
# 🔍 Storia di: Google Chrome
# ⚡ Chiudo Google Chrome (CPU: 2.3%)
# 🔄 Riapro Google Chrome
# ✓ Mantengo Google Chrome (CPU: 0.5%)
# 
# Chiusa: 23 volte
# Mantenuta: 12 volte
# Riaperta: 23 volte
```

### Sessioni recenti

```bash
# Ultime 3 sessioni sleep/wake complete
sleeplog sessions

# Ultime N sessioni
sleeplog sessions 5
sleeplog sessions 10
```

### Gestione log

```bash
# Visualizza log completo con paginazione
sleeplog full

# Pulisci log vecchi (mantiene ultime 100 righe)
sleeplog clean
```

### Help

```bash
sleeplog help
sleeplog --help
sleeplog -h
```

## 📁 File di sistema

### File creati automaticamente

| File | Percorso | Descrizione |
|------|----------|-------------|
| **Log principale** | `~/.sleep_log` | Traccia completa di tutte le operazioni |
| **App aperte** | `~/.sleep_apps` | Lista app aperte al momento dello sleep |
| **App chiuse** | `~/.sleep_apps_killed` | Lista app effettivamente chiuse (da riaprire) |

### Struttura log

```
==== SLEEP 2024-12-21 14:30:15 ====
✓ Mantengo Safari (CPU: 0.3%)
⚡ Chiudo Google Chrome (CPU: 2.1%)
⚡ Chiudo Slack (CPU: 1.5%)
   ⚠️  Kill forzato
✓ Mantengo Terminal (CPU: 0.1%)
📊 Controllate: 15 | Chiuse: 2 | Mantenute: 11 | Saltate (sistema): 2

==== WAKE 2024-12-21 16:45:22 ====
🔄 Riapro Google Chrome
🔄 Riapro Slack
⏭️  Terminal già aperta
📊 Riaperte: 2 | Saltate: 1 | Fallite: 0 | Wake completato
```

### Emoji utilizzate

- ⚡ App chiusa
- ✓ App mantenuta aperta
- ⚠️ Kill forzato (dopo fallimento quit gentile)
- 🔄 App riaperta
- ⏭️ App saltata (già aperta)
- ❌ Errore
- 📊 Statistiche sessione
- 🔋 Batteria

## 🐛 Risoluzione problemi

### Comandi di diagnostica rapida

Prima di tutto, verifica lo stato del sistema:

```bash
# Verifica quante istanze di sleepwatcher sono attive (DEVE essere 1)
pgrep -fl sleepwatcher

# Verifica stato del servizio
brew services list | grep sleepwatcher

# Verifica che gli script esistano e siano eseguibili
ls -la ~/.sleep ~/.wakeup ~/.sleeplog

# Controlla gli ultimi log
sleeplog recent 20
```

### Problema: Doppia esecuzione degli script

**Sintomo:** Nel log vedi righe duplicate tipo:
```
==== SLEEP 2025-12-21 19:31:02 ====
==== SLEEP 2025-12-21 19:31:02 ====
```

**Diagnosi:**
```bash
# Conta quante istanze di sleepwatcher sono attive
pgrep -fl sleepwatcher
# Se vedi 2 o più righe → HAI IL PROBLEMA
```

**Causa:** Hai avviato sleepwatcher manualmente E come servizio Homebrew.

**Soluzione:**
```bash
# 1. Killa TUTTE le istanze
pkill sleepwatcher

# 2. Aspetta che si chiudano
sleep 2

# 3. Riavvia SOLO tramite Homebrew
brew services restart sleepwatcher

# 4. Verifica che ce ne sia UNA SOLA
pgrep -fl sleepwatcher
# Output atteso: una sola riga tipo:
# 12345 /opt/homebrew/opt/sleepwatcher/sbin/sleepwatcher -V -s ...

# 5. Se il problema persiste, rimuovi LaunchAgents duplicati
rm ~/Library/LaunchAgents/com.bernhard-baehr.sleepwatcher.plist 2>/dev/null
launchctl unload ~/Library/LaunchAgents/com.bernhard-baehr.sleepwatcher.plist 2>/dev/null
brew services restart sleepwatcher
```

### Problema: Errore AppleScript "Indice non valido"

**Sintomo:** Nel log vedi:
```
execution error: System Events ha trovato un errore: Impossibile ottenere every process whose background only = false. Indice non valido. (-1719)
```

**Causa:** AppleScript viene eseguito troppo velocemente durante il sleep/wake.

**Soluzione:** Lo script moderno (v2) ha già un sistema di retry integrato. Assicurati di usare la versione aggiornata:
```bash
# Verifica versione (deve contenere "RETRY" e "MAX_RETRIES")
grep -A 5 "RETRY=0" ~/.sleep
```

Se non vedi queste righe, aggiorna lo script dalla repo.

### Le app non vengono chiuse

**Verifica 1:** Sei a batteria?
```bash
pmset -g batt
# Deve mostrare "Battery Power"
```

**Verifica 2:** Le app superano la soglia CPU?
```bash
# Controlla CPU delle app
ps -Ao %cpu,comm | grep "Nome App"
```

**Verifica 3:** L'app è protetta?
```bash
# Controlla PROTECTED_APPS in ~/.sleep
cat ~/.sleep | grep -A 20 "PROTECTED_APPS"
```

**Soluzione:** Abbassa la soglia CPU o rimuovi l'app da PROTECTED_APPS

### Le app non vengono riaperte

**Verifica 1:** Sono state effettivamente chiuse?
```bash
cat ~/.sleep_apps_killed
```

**Verifica 2:** Controlla errori nel log
```bash
sleeplog | grep "❌"
```

**Soluzione:** Aumenta il delay nello script wakeup (`sleep 5` invece di `sleep 3`)

### sleepwatcher non parte

```bash
# Verifica stato servizio
brew services list | grep sleepwatcher

# Dovrebbe mostrare "started" - se mostra "stopped":
brew services start sleepwatcher

# Se mostra "error":
brew services restart sleepwatcher

# Controlla log di sleepwatcher
tail -f /usr/local/var/log/sleepwatcher.log

# Controlla log di sistema
log show --predicate 'process == "sleepwatcher"' --last 1h
```

**sleepwatcher non esegue gli script:**
- Verifica che i file siano in `~/.sleep` e `~/.wakeup` (sleepwatcher cerca questi path esatti)
- Verifica che siano eseguibili: `chmod +x ~/.sleep ~/.wakeup`
- Riavvia il servizio: `brew services restart sleepwatcher`

### Script non vengono eseguiti

**Verifica permessi:**
```bash
ls -la ~/.sleep ~/.wakeup
# Devono avere -rwxr-xr-x (eseguibili)
```

**Correggi permessi:**
```bash
chmod +x ~/.sleep ~/.wakeup ~/.sleeplog
```

### Troppo/poco aggressivo

**Troppo aggressivo (chiude troppe app):**
- Aumenta `CPU_THRESHOLD` (es. da `1.0` a `2.0`)
- Aggiungi app a `PROTECTED_APPS`

**Troppo poco aggressivo (non chiude abbastanza):**
- Diminuisci `CPU_THRESHOLD` (es. da `1.0` a `0.5`)
- Verifica che le app consumino effettivamente CPU

### Debugging avanzato

**Test manuale degli script:**
```bash
# Simula sleep manualmente (ATTENZIONE: chiuderà app!)
~/.sleep

# Controlla cosa è stato chiuso
cat ~/.sleep_apps_killed

# Controlla il log
tail -20 ~/.sleep_log

# Simula wake
~/.wakeup

# Verifica cosa è stato riaperto
sleeplog recent 10
```

**Abilita output verboso (debug mode):**
```bash
# Apri lo script sleep
nano ~/.sleep

# Aggiungi questa riga SUBITO dopo #!/bin/bash
set -x  # Debug mode

# Salva e esci (Ctrl+X, Y, Enter)

# Ora esegui manualmente
~/.sleep 2>&1 | tee /tmp/sleep_debug.log

# Analizza l'output
cat /tmp/sleep_debug.log

# RICORDA: Rimuovi "set -x" dopo il debug!
```

**Monitoraggio in tempo reale:**
```bash
# In un terminale, monitora il log in tempo reale
tail -f ~/.sleep_log

# In un altro terminale, chiudi lo schermo
# Vedrai l'attività in tempo reale
```

**Verifica completa del sistema:**
```bash
#!/bin/bash
echo "=== DIAGNOSTICA SLEEP MANAGER ==="
echo ""
echo "1. Processi sleepwatcher attivi:"
pgrep -fl sleepwatcher
echo ""
echo "2. Servizio Homebrew:"
brew services list | grep sleepwatcher
echo ""
echo "3. Script installati:"
ls -lh ~/.sleep ~/.wakeup ~/.sleeplog
echo ""
echo "4. File di log:"
ls -lh ~/.sleep_log ~/.sleep_apps ~/.sleep_apps_killed 2>/dev/null || echo "File di log non ancora creati"
echo ""
echo "5. Ultimi eventi:"
tail -10 ~/.sleep_log 2>/dev/null || echo "Log ancora vuoto"
echo ""
echo "6. Stato batteria:"
pmset -g batt | grep -E "Battery|AC Power"
```

Copia questo script, salvalo come `~/diagnose_sleep.sh`, rendilo eseguibile con `chmod +x ~/diagnose_sleep.sh` ed eseguilo per una diagnostica completa.

### Reset completo

### Reset completo

Se qualcosa è andato storto e vuoi ricominciare da zero:

```bash
# 1. Ferma e rimuovi tutto
brew services stop sleepwatcher
pkill sleepwatcher
rm ~/Library/LaunchAgents/com.bernhard-baehr.sleepwatcher.plist 2>/dev/null
launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.sleepwatcher.plist 2>/dev/null

# 2. Rimuovi gli script (BACKUP prima se hai personalizzazioni!)
rm ~/.sleep ~/.wakeup ~/.sleeplog

# 3. Pulisci i log (OPZIONALE - perdi lo storico!)
rm ~/.sleep_log ~/.sleep_apps ~/.sleep_apps_killed

# 4. Reinstalla da zero
cd ~/path/to/macos-sleep-manager
./install.sh

# 5. Verifica
pgrep -fl sleepwatcher  # Deve mostrare 1 solo processo
brew services list | grep sleepwatcher  # Deve essere "started"
```

## 📝 Note

- Gli script funzionano **solo a batteria** per non interferire durante l'uso normale
- **sleepwatcher** gestisce automaticamente l'esecuzione degli script agli eventi sleep/wake
- Il servizio sleepwatcher si avvia automaticamente al boot del sistema
- La chiusura è **gentile** (quit) seguita da **forzata** (kill -9) se necessario
- Il sistema è **completamente automatico**: nessuna manutenzione richiesta
- Compatibile con **qualsiasi app**, presente o futura
- **Privacy-safe**: tutto locale, nessun dato inviato online

## 🔗 Link utili

- [sleepwatcher homepage](https://www.bernhard-baehr.de/)
- [sleepwatcher su Homebrew](https://formulae.brew.sh/formula/sleepwatcher)

## 🤝 Contributi

Per miglioramenti o bug, apri una issue o pull request.

## 📄 Licenza

Uso personale.