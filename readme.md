# 🔋 macOS Smart Sleep Manager

> **Risparmia il massimo della batteria quando chiudi il coperchio del Mac, ritrovando le tue app pronte quando lo riapri.**

Hai notato che il tuo Mac consuma batteria anche quando è chiuso nello zaino? O che si sveglia caldo?
Questo tool risolve il problema. Chiude automaticamente le applicazioni pesanti (come Chrome, Spotify, ecc.) quando il Mac va in stop e le riapre *magicamente* quando lo svegli.

In più, ora include una **Modalità Ultra-Saver** per azzerare quasi completamente il consumo notturno.

---

## ✨ Perché usarlo?

1.  **Batteria Infinita:** Impedisce alle app di consumare energia mentre non usi il computer.
2.  **Zero Surriscaldamenti:** Il Mac non si sveglierà nello zaino per colpa di qualche sito web aperto.
3.  **Ripristino Intelligente:** Quando riapri il coperchio, le app che stavi usando si riaprono da sole.
4.  **Installazione Facile:** Fa tutto da solo, ti basta rispondere a un paio di domande.

---

## 🚀 Installazione (Facilissima)

Non serve essere programmatori. Segui questi passi:

1.  Scarica questo progetto (clicca su **Code** > **Download ZIP** ed estrai la cartella, oppure usa `git clone`).
2.  Apri l'app **Terminale** sul tuo Mac.
3.  Trascina il file `install.sh` dentro la finestra del Terminale e premi **Invio**.

🎉 **Fatto!** L'installazione partirà e ti guiderà passo-passo.

### Durante l'installazione ti verrà chiesto:
* **Soglia CPU:** Puoi lasciare il valore predefinito (premi Invio). Serve a decidere quali app chiudere.
* **Modalità Ultra-Saver (NUOVO):** Ti chiederà se vuoi attivare l'ibernazione profonda.
    * ✅ **Consigliato (Sì):** Il Mac consumerà pochissimo (quasi 0%), ma impiegherà qualche secondo in più a svegliarsi (vedrai una barra di caricamento grigia).
    * ❌ **No:** Il Mac si sveglia istantaneamente, ma consuma un po' di più (standard Apple).

---

## 🛠 Come funziona?

Tutto avviene in automatico:

1.  **Quando chiudi il Mac:**
    * Lo script controlla quali app stanno usando troppa CPU.
    * Chiude queste app "mangia-batteria".
    * (Opzionale) Attiva l'ibernazione profonda per spegnere completamente l'hardware.

2.  **Quando riapri il Mac:**
    * Il sistema si sveglia.
    * Lo script aspetta qualche secondo che il Mac sia "pronto".
    * Riapre automaticamente tutte le app che aveva chiuso, rimettendoti operativo.

---

## ❓ Problemi comuni

**Le app non si riaprono subito?**
È normale attendere circa **10-15 secondi** dopo aver fatto il login. Abbiamo aumentato leggermente il tempo di attesa per assicurarci che il Mac sia ben sveglio prima di lanciare i programmi, evitando errori.

**Voglio cambiare impostazioni**
Ti basta **rilanciare il file `install.sh`**! Sovrascriverà le vecchie impostazioni con quelle nuove che sceglierai.

**Come disinstallare?**
Se decidi di rimuoverlo, esegui questi comandi nel Terminale:
```bash
brew services stop sleepwatcher
brew uninstall sleepwatcher
rm ~/.sleep ~/.wakeup ~/.sleeplog



[Docs](./help.md)