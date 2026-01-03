---

### 2. `help.md` (Manuale Tecnico e Risoluzione Problemi)

```markdown
# 📖 Guida Tecnica v4.5.2 - Deep Sleep & Hard Freeze

Questa guida spiega come il sistema interagisce con il kernel di macOS per ottenere un consumo dello 0% durante le lunghe sessioni di sleep.

---

## ⚡️ Ciclo Energetico Smart
Per evitare la fastidiosa barra di caricamento nelle brevi pause, la v4.5.2 usa una logica temporizzata:
1. **Sleep Rapido (0-60 min)**: Il Mac resta in `hibernatemode 3`. La RAM è alimentata, il risveglio è immediato.
2. **Deep Freeze (> 60 min)**: Superata l'ora, il sistema passa automaticamente in **Standby Profondo**. La RAM viene scritta su disco e spenta. Al risveglio apparirà una barra di caricamento: questo è il segnale che la batteria è stata preservata al 100%.

## 🔍 Logiche di Intervento
### Isolamento di Rete
Il comando `tcpkeepalive 0` inserito nello script `sleep` è cruciale. Impedisce a macOS di svegliarsi silenziosamente ogni 15 minuti per controllare email o notifiche, una delle cause primarie del drenaggio notturno.

### Pulizia delle "Assersioni"
Alcuni processi (es. `cupsd` per la stampa o `softwareupdated`) possono creare "Assersioni" che dicono al kernel di non entrare mai in Deep Sleep. Lo script `sleep` ora pulisce forzatamente questi blocchi prima di ogni sospensione.

### Sospensione vs Chiusura
- **App Utente**: Se superano la soglia CPU o sono in `HEAVY_APPS`, vengono chiuse (`pkill -9`).
- **Driver e Sicurezza**: Processi come Malwarebytes o agenti Logitech vengono "congelati" (`SIGSTOP`). Questo impedisce loro di consumare energia senza causare il crash dell'app.

---

## 📊 Interpretazione dei Log
Eseguendo `sleeplog`, potresti leggere:
- `DELTA: 0% (PERFETTO)`: Il sistema è entrato in ibernazione totale. Il consumo è nullo.
- `[FREEZE]`: Un processo è stato sospeso correttamente.
- `[POSTPONE]`: Un'app pesante è rimasta chiusa al risveglio perché sei a batteria (Eco-Wake).

## 🔐 Sicurezza e Manutenzione
Se i log smettono di aggiornarsi, assicurati che `sleepwatcher` abbia l'**Accesso completo al disco** nelle Impostazioni di Sistema. In caso di instabilità, usa `./uninstall.sh` per riportare il Mac ai valori originali Apple.