---

### 2. `help.md`

```markdown
# 📖 Manuale Tecnico v4.6.1 - Deep Sleep & Full Transparency

Questa guida spiega le logiche avanzate utilizzate dalla versione 4.6.1 per abbattere il consumo energetico e fornire una visibilità totale sull'uso della batteria.

---

## ⚡️ Ciclo Energetico Smart
Il sistema bilancia risveglio istantaneo e risparmio estremo:
1. **Sleep Rapido (0-60 min)**: Il Mac resta in `hibernatemode 3`. La RAM è alimentata, il risveglio è immediato.
2. **Deep Freeze (> 60 min)**: Superata l'ora, il sistema passa in **Standby Profondo**. La RAM viene scritta su disco e spenta. Al risveglio apparirà una barra di caricamento: segnale che la batteria è stata preservata al 100%.

**Perché disattivare il TCPKeepAlive?**
macOS si sveglia solitamente ogni 15-30 minuti per controllare email e notifiche (Dark Wakes). Disattivandolo, eliminiamo questi micro-risvegli, risolvendo cali tipici del 5-10% a notte.

---

## 🕵️‍♂️ Monitoraggio della Veglia (Novità v4.6)
Per risolvere il mistero dei cali di batteria "improvvisi", il sistema ora registra:
- **AWAKE TIME**: Quanto tempo il Mac è stato utilizzato tra l'ultima apertura e l'ultima chiusura.
- **USED BATTERY**: Quanta percentuale di carica è stata consumata durante l'uso attivo.
- **DELTA SLEEP**: La perdita reale avvenuta esclusivamente mentre il coperchio era chiuso.

---

## 🔍 Gestione dei Processi
### Super Whitelist di Sistema
Lo script ignora i processi `root` critici e si concentra esclusivamente sui processi dell'utente (`ps -u $USER`), evitando di entrare in conflitto con il kernel di macOS e garantendo stabilità.

### Congelamento (SIGSTOP/SIGCONT)
App di sicurezza e Driver (es. Malwarebytes, Logi Options) non vengono chiusi ma "congelati":
- **Allo Sleep**: Il processo viene sospeso. Rimane in RAM ma non consuma cicli CPU.
- **Al Wake**: Il processo viene riattivato istantaneamente senza dover essere ricaricato.

---

## 📊 Interpretazione dei Log (`sleeplog`)
- **Verde**: `DELTA SLEEP: 0% (PERFETTO)` - L'ibernazione è scattata e il consumo è stato nullo.
- **Ciano**: `TEMPO ACCESO` - Indica i minuti di utilizzo reale.
- **Giallo**: `USO` - La batteria consumata mentre usavi il Mac o prima del Deep Freeze.

## 🔐 Sicurezza e Permessi
Affinché il sistema funzioni, `sleepwatcher` deve avere l'**Accesso completo al disco** (Privacy e Sicurezza). In caso di problemi di esecuzione, l'installer applica automaticamente la firma digitale:
`sudo codesign --force --deep --sign - $(which sleepwatcher)`