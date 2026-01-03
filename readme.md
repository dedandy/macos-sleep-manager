# 🔋 macOS Sleep Manager v4.5.2 "Final Polish"

**macOS Sleep Manager** è un'utility avanzata per ottimizzare il risparmio energetico dei MacBook. Progettata per eliminare il drenaggio della batteria durante la sospensione, trasforma la gestione del sonno di macOS in un sistema a risparmio garantito.

## ✨ Novità della v4.5.2
- **Smart Deep Freeze**: Bilanciamento automatico tra risveglio istantaneo (entro 60 min) e ibernazione totale (dopo 1 ora).
- **Zero Dark Wakes**: Disabilitazione completa di `tcpkeepalive` durante lo sleep per impedire al Wi-Fi di consumare energia a coperchio chiuso.
- **Hard Assertion Clean**: Chiusura forzata dei processi di sistema rimasti appesi (stampa, update) che impediscono lo standby profondo.
- **Logica "Freeze"**: Driver e servizi di sicurezza vengono sospesi (SIGSTOP) anziché terminati, garantendo stabilità al riavvio.

## 🚀 Installazione
1. Clona il repository.
2. Esegui l'installer:
   ```bash
   chmod +x install.sh
   ./install.sh