# 📖 Documentazione Tecnica Avanzata - macOS Sleep Manager v4.3.1

Questa guida fornisce una panoramica completa sul funzionamento interno del sistema, analizzando come ogni componente interagisca con macOS per ottimizzare il risparmio energetico e la gestione dei processi.

---

## 🤖 Logica di Classificazione (Auto-Discovery v4.3.1)
Dalla versione 4.3, l'installer esegue una **scansione euristica profonda** della cartella `/Applications`. Non cerca solo nomi esatti, ma utilizza "pattern" per identificare app simili (es. intercetta "ChatGPT Atlas" perché riconosce la parola "ChatGPT").

### 1. Whitelist (Le "Intoccabili")
* **Definizione**: Applicazioni che devono rimanere attive durante la sospensione per non interrompere flussi di dati o servizi essenziali.
* **Comportamento**: Lo script `sleep` le esclude totalmente dai controlli. Anche se queste app consumano risorse elevate, il sistema le ignora per garantire la continuità (es. download in corso o musica).
* **Categorie intercettate**: Messaggistica (WhatsApp, Telegram, Slack), Musica (Spotify, Music), Mail e Discord.

### 2. Heavy Apps (Le "Energivore")
* **Definizione**: Applicazioni che impediscono al Mac di entrare in sonno profondo o che drenano molta batteria al risveglio (Power Nap / Background Task).
* **Comportamento**: Vengono chiuse **sempre** durante la fase di `sleep`. 
* **Eco-Wake**: Al risveglio (`wakeup`), lo script controlla la fonte di alimentazione:
    * **A Batteria**: Le app restano chiuse e vengono messe in una "lista d'attesa".
    * **A Corrente**: Le app vengono riaperte istantaneamente.
* **Categorie intercettate**: Browser (Chrome, Edge), IDE (WebStorm, Xcode), Cloud (OneDrive, Google Drive, Dropbox), Grafica (Adobe, Resolve) e strumenti di collaborazione (Teams).

---

## ⚙️ Parametri di Configurazione (`.sleepmanager.conf`)

Tutti i parametri sono gestibili graficamente tramite il comando `sleepconf`.

| Parametro | Descrizione Dettagliata |
| :--- | :--- |
| `ENABLE_NOTIFICATIONS` | Abilita i banner di sistema. Ti avvisa quando un'app viene chiusa o quando il ripristino di un'app "Heavy" viene posticipato per salvare batteria. |
| `SAFE_QUIT_MODE` | Se attivo, il sistema simula la pressione di `CMD+Q`. Se l'app non si chiude entro 3 secondi (magari per un documento non salvato), lo script forza la chiusura per non bloccare lo sleep. |
| `CPU_THRESHOLD` | La "sensibilità" del sistema. Se un'app sconosciuta (non in lista) usa più di questa % di CPU, viene chiusa per evitare che il Mac scaldi nella borsa. |
| `WHITELIST` | Elenco dinamico separato dal simbolo `|`. Puoi aggiungere app manualmente dall'editor `sleepconf`. |
| `HEAVY_APPS` | Elenco delle app soggette alla chiusura sistematica. L'editor permette di aggiungere nuovi elementi senza sovrascrivere quelli rilevati dall'installer. |

---

## ⚡️ Cicli Operativi e Automazione

### Fase di Sospensione (`.sleep`)
Il sistema analizza i processi attivi e confronta i consumi CPU con la `CPU_THRESHOLD`. Se un'app è "pesante" o inclusa nella lista `HEAVY_APPS`, viene terminata e il suo nome salvato in un file temporaneo di sessione.

### Fase di Risveglio (`.wakeup`)
Lo script verifica lo stato della batteria. Se rileva il collegamento alla rete elettrica, riapre tutto. Se sei in mobilità, protegge la carica residua posticipando l'apertura dei software più pesanti.

---

## 🔋 Strategie Energetiche (pmset)
Durante l'installazione puoi scegliere tra tre profili che modificano il comportamento del kernel macOS:
1.  **Standard**: Il Mac resta pronto a scattare. Risveglio immediato, ma consumo minimo costante.
2.  **Ultra**: Ibernazione profonda. Il Mac è praticamente spento. Consumo zero, ma richiede circa 10-15 secondi per riaccendersi.
3.  **Hybrid (Consigliato)**: Il sistema resta in standby leggero per i primi 15 minuti, poi se non torni, passa automaticamente all'ibernazione totale.

---

## 🔐 Sicurezza e Permessi (TCC)
macOS è molto restrittivo. Per far funzionare il sistema:
1.  **Firma Digitale**: L'installer firma il software (`codesign`) per evitare che macOS lo blocchi.
2.  **Accesso Disco**: È obbligatorio aggiungere `sleepwatcher` (che trovi in `/opt/homebrew/sbin/`) nella lista **Privacy e Sicurezza > Accesso completo al disco**. Senza questo, i log rimarranno fermi a date vecchie.

---

## 🛠 Comandi Rapidi
- `sleeplog`: Apre la dashboard smart con l'esito dell'ultimo sleep/wake.
- `sleepconf`: Apre l'editor per aggiungere app o cambiare la sensibilità CPU.
- `sleeplog help`: Mostra i comandi per vedere lo storico completo o pulire i log.