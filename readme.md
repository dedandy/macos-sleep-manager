# 🔋 macOS Smart Sleep Manager v3.1

> **Il gestore di sospensione definitivo per il tuo Mac.**
> Risparmia batteria chiudendo le app pesanti quando chiudi il coperchio, e decide intelligentemente se riaprirle in base a se hai collegato l'alimentatore.

---

## ✨ Cosa c'è di nuovo in v3.1?

### 🧠 Auto-Configurazione Intelligente
L'installer ora **scansiona le tue applicazioni**. Rileva automaticamente se usi Chrome, Photoshop, Docker, ecc. e le configura per essere chiuse e riaperte nel modo più efficiente, senza che tu debba scrivere nulla a mano.

### ⭐ Modalità Ibrida (Hybrid Sleep)
Il meglio dei due mondi:
* **Primi 15 minuti:** Il Mac dorme leggero (si sveglia all'istante). Perfetto per pause brevi.
* **Dopo 15 minuti:** Il Mac passa automaticamente in ibernazione profonda (spegne tutto). Perfetto per la notte.

### ⚡️ Eco-Wake & Smart-Wait
* **Sveglia a Batteria 🔋:** Le app pesanti rimangono chiuse per non uccidere la tua autonomia.
* **La Magia:** Se attacchi la presa di corrente entro **5 minuti** dal risveglio, le app che erano in attesa si riaprono da sole!

---

## 🚀 Installazione (Facilissima)

1.  Apri il Terminale nella cartella del progetto.
2.  Esegui il comando:
    ```bash
    ./install.sh
    ```
3.  Segui le istruzioni a schermo. Ti verrà chiesto di:
    * Scegliere la strategia di risparmio (consigliamo la **3 - Hybrid**).
    * Confermare le app pesanti rilevate automaticamente.

---

## 🛠 Funzionalità Principali

* **Smart App Killer:** Chiude le app che consumano troppa CPU quando chiudi il coperchio.
* **Sync Totale:** Le app pesanti vengono terminate forzatamente allo sleep per garantire che non consumino batteria al risveglio.
* **Auto-Resume:** Se colleghi la corrente dopo il risveglio, il tuo lavoro torna come prima.
* **Monitoraggio:** Un log dettagliato ti dice sempre cosa è successo.

---

## 📝 Come controllare cosa succede

Vuoi sapere se un'app è stata chiusa o posticipata? Usa il comando:

```bash
sleeplog
```

[Docs](./help.md)