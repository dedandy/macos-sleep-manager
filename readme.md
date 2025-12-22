# 🔋 macOS Smart Sleep Manager v2.0

> **Il gestore di sospensione definitivo per il tuo Mac.**
> Risparmia batteria chiudendo le app pesanti quando chiudi il coperchio, e decide intelligentemente se riaprirle in base a se hai collegato l'alimentatore.

---

## ✨ Cosa c'è di nuovo? (Smart-Wait Logic)

Oltre a risparmiare batteria, ora il sistema è **intelligente**:

1.  **Chiusura:** Quando chiudi il coperchio, le app che consumano CPU (es. Chrome, Photoshop) vengono chiuse.
2.  **Risveglio a Corrente ⚡️:** Se riapri il Mac con il cavo collegato, tutto si riapre subito.
3.  **Risveglio a Batteria 🔋:** Le app pesanti **NON** vengono riaperte per non scaricare la batteria.
    * *La magia:* Il sistema rimane in attesa per **5 minuti**.
    * Se colleghi l'alimentatore entro questo tempo, le app in attesa si apriranno automaticamente!

---

## 🚀 Installazione Rapida

1.  Apri il Terminale nella cartella del progetto.
2.  Esegui il comando:
    ```bash
    ./install.sh
    ```
3.  Segui le istruzioni a schermo. Ti verrà chiesto se vuoi attivare la modalità **Ultra-Saver** (ibernazione profonda) e quale soglia di CPU usare.

---

## 🛠 Funzionalità Principali

* **Ultra-Saver Mode:** (Opzionale) Disattiva completamente il Mac durante la notte (ibernazione profonda) per consumo 0%.
* **Eco-Wake:** Se sei in giro senza caricatore, evita di riaprire app inutilmente pesanti.
* **Auto-Resume:** Se colleghi la corrente dopo il risveglio, il tuo lavoro torna come prima.
* **Monitoraggio:** Un log dettagliato ti dice sempre cosa è successo mentre il Mac dormiva.

---

## 📝 Come controllare cosa succede

Vuoi sapere se un'app è stata chiusa o posticipata? Usa il comando:

```bash
sleeplog
```

[Docs](./help.md)