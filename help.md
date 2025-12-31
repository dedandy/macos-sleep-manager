---

### 2. `help.md` (Il Manuale Tecnico Dettagliato)
Questo file è fondamentale per capire "sotto il cofano" come lavora la versione 4.5.

```markdown
# 📖 Manuale Tecnico v4.5 - Deep Freeze Edition

Benvenuto nella documentazione dettagliata di macOS Sleep Manager. Questa guida spiega le logiche avanzate utilizzate per abbattere il consumo energetico.

---

## ⚡️ Logica Energetica (Deep Freeze a 2 Ore)
La versione 4.5 introduce un sistema di ibernazione dinamica. 
1. **Fase 1 (0-120 min)**: Il Mac entra in `hibernatemode 3`. La RAM è alimentata, il risveglio è istantaneo.
2. **Fase 2 (> 120 min)**: Il timer `standbydelayhigh` scatta. Il Mac salva la RAM sul disco e si spegne completamente. In questa fase il consumo è virtualmente **0%**.

**Perché abbiamo disattivato il TCPKeepAlive?**
Di default, macOS si sveglia ogni 15-30 minuti per controllare email e notifiche (Dark Wakes). Disattivando questa funzione tramite lo script `sleep`, eliminiamo circa 40-50 micro-risvegli notturni, risparmiando fino al 5-8% di batteria al giorno.

---

## 🔍 Gestione dei Processi
### Super Whitelist di Sistema
A differenza delle versioni precedenti, la v4.5 non tenta più di chiudere i processi `root` (come `configd`, `tccd`, `airportd`). Uccidere questi processi causa instabilità. Lo script ora si concentra esclusivamente sui processi dell'utente (`ps -u $USER`), garantendo la stabilità del sistema operativo.

### Congelamento (SIGSTOP/SIGCONT)
Alcune app (Sicurezza, Driver Mouse) non possono essere chiuse senza causare fastidi all'utente. 
- **Allo Sleep**: Viene inviato un segnale `SIGSTOP`. Il processo rimane in RAM ma non consuma cicli CPU.
- **Al Wake**: Viene inviato un segnale `SIGCONT`. L'app riprende a funzionare istantaneamente.

---

## 📊 Parametri di Configurazione (`.sleepmanager.conf`)

| Parametro | Descrizione |
| :--- | :--- |
| `CPU_THRESHOLD` | % massima di CPU permessa. Se un'app utente la supera allo sleep, viene chiusa. |
| `WHITELIST` | Elenco di app che non devono mai essere toccate (es. Spotify per ascoltare musica con coperchio chiuso). |
| `HEAVY_APPS` | App "pesanti" (Docker, Chrome, IDE) che vengono sempre chiuse allo sleep e riaperte solo se il Mac è sotto carica. |

---

## 🔐 Sicurezza e Permessi
Affinché il sistema funzioni, `sleepwatcher` deve avere i permessi necessari.
1. **Accesso disco**: Vai in `Impostazioni di Sistema > Privacy > Accesso completo al disco` e abilita `sleepwatcher`.
2. **Firma digitale**: Se gli script non vengono eseguiti, lancia:
   `sudo codesign --force --deep --sign - $(which sleepwatcher)`

---

## 📈 Interpretazione dei Log
Eseguendo `sleeplog`, potresti vedere:
- `DELTA: 0% (PERFETTO)`: Il sistema è entrato correttamente in Deep Freeze e non ha perso carica.
- `DELTA: -1% / -2%`: Normale se il Mac è rimasto in standby leggero per poco tempo.
- `[FREEZE]`: Indica che un driver o un'app di sicurezza è stata sospesa correttamente.
- `[POSTPONE]`: Indica che un'app pesante non è stata riaperta al risveglio perché sei a batteria (Eco-Wake).

---