# 📖 Documentazione Tecnica Avanzata - macOS Sleep Manager v4.2

Questa guida dettaglia il funzionamento interno, le variabili di configurazione e le procedure di risoluzione problemi del sistema.

---

## 🏗 Architettura del Sistema

Il software si basa su tre componenti principali:
1.  **Daemon (`sleepwatcher`)**: Un servizio di background che monitora i segnali del kernel relativi allo stato del display (Sleep/Wake).
2.  **Logic Engine (`.sleep` & `.wakeup`)**: Script Bash che eseguono l'analisi dei processi e la gestione energetica.
3.  **Config Layer (`.sleepmanager.conf`)**: Un file di configurazione centralizzato che separa le preferenze dell'utente dalla logica di esecuzione.

---

## ⚙️ Configurazione Dettagliata (`~/.sleepmanager.conf`)

Il file di configurazione viene caricato all'avvio di ogni ciclo di sospensione o risveglio.

| Variabile | Valore Default | Descrizione |
| :--- | :--- | :--- |
| `ENABLE_NOTIFICATIONS` | `true` | Se `true`, invia notifiche native macOS tramite AppleScript durante il risveglio. |
| `SAFE_QUIT_MODE` | `true` | Se `true`, tenta una chiusura gentile (CMD+Q) e attende 3s prima di forzare il `kill`. |
| `CPU_THRESHOLD` | `1.0` | Soglia di utilizzo CPU (%). Ogni app sopra questo valore viene terminata allo sleep. |
| `WHITELIST` | `"Music\|Spotify"` | Regex delle app che non devono MAI essere chiuse, anche se superano la soglia CPU. |
| `HEAVY_APPS` | (Auto-detected) | Lista di app "energivore" che vengono chiuse sempre allo sleep e riaperte solo se il Mac è alimentato (Eco-Wake). |

---

## 📝 Editor di Configurazione (`sleepconf`)
Per facilitare la personalizzazione, è stato introdotto un editor interattivo.
- **Comando**: `sleepconf`
- **Funzione**: Permette di modificare i parametri booleani (true/false) con un click e inserire nuovi valori per CPU e liste senza editare manualmente il file di testo. 
- **Sicurezza**: L'editor crea automaticamente una copia di backup durante la scrittura per evitare la corruzione del file `.conf`.

---

## ⚡️ Logica di Funzionamento

### Fase di Sospensione (`.sleep`)
1.  **Inizializzazione Log**: Viene creato un nuovo marcatore `==== SLEEP ====` nel file `.sleeplog_history`.
2.  **Scansione Processi**: Esegue `ps -r -A` per ottenere la lista processi ordinata per consumo.
3.  **Filtro**: Ignora l'intestazione, i processi di sistema (kernel, windowserver, ecc.) e la whitelist.
4.  **Decisione**: 
    - Se l'app è in `HEAVY_APPS`, viene segnata per la chiusura.
    - Se l'app consuma più di `CPU_THRESHOLD`, viene segnata per la chiusura.
5.  **Esecuzione**: L'app viene chiusa e il suo nome salvato in `~/.sleep_killed_apps`.

### Fase di Risveglio (`.wakeup`)
1.  **Check Alimentazione**: Verifica tramite `pmset -g batt` se il Mac è a batteria o corrente.
2.  **Ripristino Differenziato**:
    - **AC Power**: Tutte le app in lista vengono riaperte immediatamente.
    - **Battery Power**: Le app in `HEAVY_APPS` vengono spostate in `~/.sleep_pending_apps` e l'utente riceve una notifica di "Eco-Wake".
3.  **Smart-Wait**: Un processo in background monitora per 5 minuti lo stato dell'alimentazione. Se il cavo viene collegato, le app in sospeso vengono caricate automaticamente.

---

## 🛠 Dashboard e Log (`sleeplog`)

Il comando `sleeplog` agisce come un parser intelligente del file `~/.sleeplog_history`.

- **Dashboard (Default)**: Utilizza `tail -r` e `awk` per isolare solo l'ultima sessione compresa tra i marcatori `====`.
- **Opzioni CLI**:
    - `all`: Output grezzo dell'intero file log.
    - `recent [n]`: Ultime `n` righe del log.
    - `clear`: Svuota il file e inserisce un marcatore di reset.

---

## Strategie Energetiche (scelte in install.sh)
1. **Standard**: Mantiene la RAM alimentata. Il Mac si sveglia subito, ma consuma un po' di batteria durante la notte.
2. **Ultra**: Scrive la RAM sul disco e spegne tutto. Consumo zero, ma il risveglio richiede 10-15 secondi.
3. **Hybrid**: Mantiene la RAM per i primi 15 minuti, poi passa all'ibernazione se non lo usi. È il compromesso perfetto.

## Utility
- `sleeplog`: Dashboard minima dell'attività.
- `sleepconf`: Editor grafico per cambiare parametri senza usare il terminale.

## 🔐 Sicurezza e Permessi (TCC & Codesign)

macOS protegge l'accesso ai processi e al disco tramite il framework TCC. 

### Perché serve la firma (`codesign`)?
I binari installati tramite Homebrew spesso non hanno una firma valida per le policy di sicurezza locali. L'installer v4.2 esegue:
`sudo codesign --force --deep --sign - $(which sleepwatcher)`
Questo comando applica una "firma ad-hoc" che permette a macOS di identificare univocamente il processo e salvarlo stabilmente nella lista **Accesso completo al disco**.

### Procedura di sblocco manuale:
Se il log non si aggiorna:
1. Aprire `Impostazioni di Sistema` > `Privacy e Sicurezza` > `Accesso completo al disco`.
2. Verificare la presenza di `sleepwatcher` (percorso: `/opt/homebrew/sbin/sleepwatcher`).
3. Se assente, aggiungere manualmente il Terminale e `/bin/zsh`.

---

## 🧪 Manutenzione e Debug

**Visualizzare i log in tempo reale:**
`tail -f ~/.sleeplog_history`

**Verificare se il servizio è in ascolto:**
`brew services list`

**Testare la logica di chiusura senza chiudere il Mac:**
`~/.sleep && sleeplog`