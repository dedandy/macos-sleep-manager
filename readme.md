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

### 1. Installa sleepwatcher

[sleepwatcher](https://www.bernhard-baehr.de/) è un daemon che monitora gli eventi di sleep/wake del Mac ed esegue script personalizzati.

```bash
brew install sleepwatcher
```

### 2. Clona/scarica gli script

```bash
# Clona questo repository
git clone <tuo-repo-privato>
cd <nome-repo>

# Oppure scarica i file manualmente
```

### 3. Copia gli script nella home

```bash
cp sleep ~/.sleep
cp wakeup ~/.wakeup
cp sleeplog ~/.sleeplog

chmod +x ~/.sleep
chmod +x ~/.wakeup
chmod +x ~/.sleeplog
```

### 4. Configura l'alias per sleeplog

```bash
echo 'alias sleeplog="~/.sleeplog"' >> ~/.zshrc
source ~/.zshrc
```

### 5. Configura sleepwatcher come servizio

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

### 6. Testa il sistema

```bash
# Simula sleep (chiudi lo schermo)
# Apri alcune app, poi chiudi lo schermo del Mac

# Al risveglio, controlla i log
sleeplog
```

## ⚙️ Configurazione

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

### Debugging

**Abilita output verboso:**
```bash
# Aggiungi all'inizio di ~/.sleep
set -x  # Debug mode

# Esegui manualmente
~/.sleep

# Disabilita dopo test
# (rimuovi la riga set -x)
```

**Testa manualmente gli script:**
```bash
# Simula sleep
~/.sleep

# Controlla cosa è stato chiuso
cat ~/.sleep_apps_killed

# Simula wake
~/.wakeup

# Controlla log
sleeplog recent 50
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