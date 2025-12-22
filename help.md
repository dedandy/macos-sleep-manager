# 🔋 macOS Smart Sleep Manager - Documentazione

Sistema intelligente di gestione energetica per macOS che chiude automaticamente le app ad alto consumo quando il Mac va in sleep (a batteria), gestisce il ripristino condizionale al risveglio e ottimizza i parametri di sistema (pmset).

## 📋 Indice

- [Caratteristiche](#-caratteristiche)
- [Requisiti](#-requisiti)
- [Installazione](#-installazione)
- [Configurazione Avanzata](#-configurazione-avanzata)
- [Logica Eco-Wake e Smart-Wait](#-logica-eco-wake-e-smart-wait-nuovo)
- [Utilizzo](#-utilizzo)
- [Comandi sleeplog](#-comandi-sleeplog)
- [File di sistema](#-file-di-sistema)
- [Risoluzione problemi](#-risoluzione-problemi)
- [Disinstallazione](#-disinstallazione)

## ✨ Caratteristiche

- ✅ **Completamente automatico**: nessuna lista hardcoded di app da chiudere.
- ✅ **Soglia CPU Dinamica**: chiude solo le app che superano una certa % di CPU al momento dello sleep.
- ✅ **Eco-Wake (Smart Wait)**: Al risveglio a batteria, le app pesanti vengono messe in "attesa" per non consumare energia.
- ✅ **Auto-Resume**: Se colleghi l'alimentatore entro 5 minuti dal risveglio, le app in attesa si aprono automaticamente.
- ✅ **Ultra-Saver Mode**: Opzione per attivare ibernazione profonda (`hibernatemode 25`) e disattivare PowerNap.
- ✅ **Protegge sistema**: whitelist di app critiche (Finder, System) mai toccate.
- ✅ **Logging dettagliato**: traccia completa di sleep, wake, app killate e app posticipate.
- ✅ **Solo su batteria**: logica ottimizzata per intervenire solo quando serve.

## 🔧 Requisiti

- macOS (testato su versioni recenti, Apple Silicon e Intel)
- [Homebrew](https://brew.sh/)
- sleepwatcher (`brew install sleepwatcher` - gestito dall'installer)

## 📦 Installazione

### Installazione Automatica (Consigliata) 🚀

1.  Apri il terminale nella cartella del progetto.
2.  Esegui lo script:
    ```bash
    chmod +x install.sh
    ./install.sh
    ```
3.  Segui le istruzioni a schermo per configurare:
    * **Soglia CPU**: (Default 1.0%) Sensibilità per chiudere le app.
    * **Ultra-Saver**: (Sì/No) Per attivare il massimo risparmio energetico notturno.

L'installer configurerà automaticamente i servizi, i permessi e gli alias necessari.

## ⚙️ Configurazione Avanzata

Dopo l'installazione, puoi personalizzare il comportamento modificando direttamente i file nella tua Home.

### 1. Modificare la soglia CPU
File: `~/.sleep`
```bash
CPU_THRESHOLD=1.0  # Cambia questo valore