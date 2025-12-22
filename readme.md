# 🔋 macOS Sleep Manager v4.0 (Pro Edition)

> **Risparmio batteria intelligente, configurazione centralizzata e sicurezza dei dati.**

Il sistema definitivo per gestire il consumo del Mac in sleep mode. Chiude le app pesanti quando chiudi il coperchio e le riapre intelligentemente al risveglio, proteggendo i tuoi dati.

---

## 🔥 Novità v4.0

* **⚙️ Configurazione Separata:** Tutte le impostazioni sono ora nel file `~/.sleepmanager.conf`. Gli script rimangono puliti e aggiornabili.
* **🛡️ Chiusura Sicura (Graceful Quit):** Il sistema prova a chiudere le app gentilmente (salvando i dati) prima di forzare la chiusura.
* **🔔 Notifiche Native:** Ricevi avvisi a schermo quando le app vengono messe in pausa risparmio energetico o ripristinate.
* **🔌 Smart-Wait v2:** Rilevamento più preciso dell'alimentazione post-risveglio.

---

## 🚀 Installazione

1.  Scarica la cartella.
2.  Apri il terminale ed esegui:
    ```bash
    ./install.sh
    ```
3.  Segui la procedura guidata per la modalità Ibrida.

---

## 🛠 Come personalizzare

Dopo l'installazione, non toccare gli script! Modifica semplicemente il file di configurazione:

```bash
nano ~/.sleepmanager.conf