# 📖 Documentazione Tecnica macOS Sleep Manager v4.4

## 🔋 Monitoraggio Batteria (Delta)
Il sistema registra la carica alla chiusura (`~/.sleep_batt_start`) e calcola la differenza (Delta) al risveglio. 
- **Verde**: Consumo 0% (Ottimizzazione perfetta).
- **Giallo/Rosso**: Consumo rilevato (considera di passare a modalità ULTRA).

## ⚙️ Parametri Configurazione
- `CPU_THRESHOLD`: Soglia % per chiudere app sconosciute.
- `SAFE_QUIT_MODE`: Prova CMD+Q prima del kill forzato.
- `WHITELIST`: App che non vengono mai chiuse.
- `HEAVY_APPS`: App sempre chiuse in sleep e riaperte solo se alimentati (Eco-Wake).

## 📊 Dashboard Colorata (`sleeplog`)
- `sleeplog today`: Log delle ultime 24 ore.
- `sleeplog stats`: Calcola l'efficienza media e il totale delle app killate.
- `sleeplog clear`: Pulisce la cronologia dei log.

## 🔐 Manutenzione e Sblocco
Se i log sono fermi, forza i permessi con:
`sudo codesign --force --deep --sign - $(which sleepwatcher)`
Assicurati che `sleepwatcher` sia in 'Accesso completo al disco'.