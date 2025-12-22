# 🔋 macOS Smart Sleep Manager - Documentazione Tecnica v3.1

Sistema avanzato di gestione energetica per macOS. Combina automazione dei processi (sleepwatcher) con ottimizzazione del kernel (pmset) per massimizzare l'autonomia.

## 📋 Indice

- [Caratteristiche](#-caratteristiche)
- [Requisiti](#-requisiti)
- [Installazione e Auto-Config](#-installazione-e-auto-config)
- [Modalità di Sospensione (PMSET)](#-modalità-di-sospensione-pmset)
- [Logica Eco-Wake e Sync](#-logica-eco-wake-e-sync)
- [Configurazione Avanzata](#-configurazione-avanzata)
- [Comandi sleeplog](#-comandi-sleeplog)
- [File di sistema](#-file-di-sistema)
- [Disinstallazione](#-disinstallazione)

## ✨ Caratteristiche

- ✅ **Smart CPU Killer**: Chiude le app sopra una soglia di CPU definita (default 1.0%).
- ✅ **Auto-Discovery**: L'installer rileva le app pesanti installate (Adobe, Docker, IDE, ecc.).
- ✅ **Full Sync**: Le app pesanti vengono terminate forzatamente allo sleep e messe in attesa al risveglio (se a batteria).
- ✅ **Smart-Wait**: Monitoraggio background post-risveglio (5 min) per riapertura ritardata su connessione AC.
- ✅ **Hybrid Sleep**: Gestione a doppio stadio (Sleep -> Ibernazione).

## 🔧 Requisiti

- macOS (Intel o Apple Silicon)
- Homebrew
- Pacchetto `sleepwatcher` (installato automaticamente)

## 📦 Installazione e Auto-Config

```bash
chmod +x install.sh
./install.sh
```

## ⚙️ Configurazione Avanzata

Dopo l'installazione, puoi personalizzare il comportamento modificando direttamente i file nella tua Home.

### 1. Modificare la soglia CPU
File: `~/.sleep`
```bash
CPU_THRESHOLD=1.0  # Cambia questo valore
```