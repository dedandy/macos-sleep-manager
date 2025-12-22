# 📖 Manuale Tecnico v4.0

## Architettura del Sistema

La versione 4.0 introduce una separazione tra **Logica** e **Configurazione**.

1.  **Logic Layer (`~/.sleep`, `~/.wakeup`):** Script di esecuzione che contengono l'intelligenza. Non dovrebbero essere modificati dall'utente.
2.  **Config Layer (`~/.sleepmanager.conf`):** File di testo semplice (variabili BASH) caricato dinamicamente dagli script.

## Funzionalità Avanzate

### Graceful Quit (Chiusura Sicura)
Invece di usare subito `kill -9` (che può corrompere file), lo script v4.0 esegue:
1.  Invia comando AppleScript `quit app "Nome"` (equivalente a CMD+Q).
2.  Attende fino a 3 secondi controllando se il processo termina.
3.  Solo se l'app è bloccata, esegue `pkill`.

Puoi disabilitarlo impostando `SAFE_QUIT_MODE=false` nel config per uno spegnimento istantaneo (ma rischioso).

### Notifiche
Il sistema usa `osascript` per mostrare banner nativi macOS (in alto a destra) quando:
* App vengono posticipate (Icona ⏳).
* App vengono ripristinate (Icona ✅).
* Viene rilevata corrente dopo un'attesa (Icona ⚡️).

### Whitelist
Oltre alle app di sistema, puoi aggiungere app personali che non devono MAI essere chiuse (es. Music player) modificando la variabile `WHITELIST` nel file `.conf`.

## Struttura File

| File | Percorso | Descrizione |
| :--- | :--- | :--- |
| **Config** | `~/.sleepmanager.conf` | **Tutte le tue impostazioni.** |
| Script Sleep | `~/.sleep` | Logica di chiusura. |
| Script Wake | `~/.wakeup` | Logica di apertura. |
| Log | `~/.sleeplog_history` | Storico eventi. |

## FAQ

**Le notifiche mi danno fastidio.**
Apri `~/.sleepmanager.conf` e imposta `ENABLE_NOTIFICATIONS=false`.

**Ho installato un nuovo gioco pesante.**
Apri `~/.sleepmanager.conf` e aggiungilo alla riga `HEAVY_APPS` (separato da `|`).