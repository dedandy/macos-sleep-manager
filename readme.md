# 🔋 macOS Sleep Manager v4.5 "Deep Freeze"

**macOS Sleep Manager** è un'utility avanzata per la gestione energetica dei MacBook, progettata per eliminare il drenaggio della batteria durante la sospensione. Attraverso l'automazione del kernel e la gestione intelligente dei processi, permette di mantenere la carica quasi invariata anche dopo giorni di inattività.

## ✨ Caratteristiche della v4.5 "Deep Freeze"
- **Deep Freeze Automatica**: Dopo 2 ore di sleep, il sistema passa automaticamente in ibernazione totale (standby profondo), azzerando il consumo della RAM.
- **Isolamento di Rete (Dark Wake Block)**: Disabilita `tcpkeepalive` durante lo sleep per impedire al Mac di connettersi al Wi-Fi a coperchio chiuso.
- **Super Whitelist**: Protegge i demoni critici di macOS, evitando loop di riavvio che consumano energia.
- **Process Congelation**: I servizi di sicurezza e i driver (es. Malwarebytes, Logitech) vengono "congelati" (SIGSTOP) anziché chiusi brutalmente.
- **Dashboard Statistica**: Log colorati con calcolo automatico del Delta Batteria (%) e monitoraggio dell'efficienza.

## 🚀 Installazione Rapida
1. Clona il repository.
2. Assicurati di avere `sleepwatcher` installato tramite Brew:
   ```bash
   brew install sleepwatcher