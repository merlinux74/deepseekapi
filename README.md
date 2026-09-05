# 🚀 DeepSeek API Status Monitor

![Dart](https://img.shields.io/badge/language-Dart-0175C2?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=flat-square&logo=flutter)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Android%20%7C%20iOS-lightgrey?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

> **Monitor in tempo reale per le fasce orarie scontate delle API DeepSeek.**

Un'applicazione Flutter che mostra istantaneamente se le API di DeepSeek sono in fascia **Off-Peak** (sconto 50%) o **Peak** (tariffa piena), utilizzando il fuso orario italiano (Europe/Rome) con gestione automatica di ora legale e solare.

---

## 📖 Perché questo progetto

DeepSeek offre tariffe scontate del 50% in determinati orari e giorni della settimana. Questo strumento ti permette di **verificare con un colpo d'occhio** se in questo momento puoi risparmiare, senza dover fare calcoli manuali.

**Ideale per:**
- Sviluppatori che integrano le API DeepSeek e vogliono ottimizzare i costi.
- Team che pianificano batch di richieste nelle fasce più convenienti.
- Chiunque voglia monitorare il costo delle chiamate API in tempo reale.

---

## ✨ Funzionalità

- **🟢 Indicatore visivo in tempo reale**:
  - Verde = sconto 50% attivo (Off-Peak)
  - Rosso = tariffa piena (Peak)
- **⏰ Aggiornamento automatico ogni secondo**.
- **📅 Rilevazione automatica**:
  - Weekend (sabato e domenica): sconto 50% 24 ore su 24.
  - Feriali (lunedì-venerdì): fascia Peak dalle 03:00 alle 06:00 e dalle 08:00 alle 12:00 (ora italiana), il resto è Off-Peak.
- **🌍 Fuso orario corretto**: utilizza il database IANA `Europe/Rome` con gestione automatica di ora legale/solare.
- **🎨 Interfaccia chiara e moderna** con tema scuro, progettata per un'esperienza utente intuitiva.

---

## 📱 Screenshot

> *Aggiungi qui gli screenshot della tua app. Puoi farli dopo aver eseguito l'applicazione.*

| Stato Off-Peak (verde) | Stato Peak (rosso) |
|------------------------|--------------------|
| ![Off-Peak](screenshots/off-peak.png) | ![Peak](screenshots/peak.png) |

---

## 🛠️ Tecnologie utilizzate

- [Flutter](https://flutter.dev) – Framework UI multipiattaforma
- [timezone](https://pub.dev/packages/timezone) – Gestione fusi orari e database IANA
- [intl](https://pub.dev/packages/intl) – Formattazione di data e ora in italiano
- [tzdata](https://pub.dev/packages/tzdata) – Dati aggiornati per i fusi orari

---

## 🚀 Come eseguire il progetto

### Prerequisiti

- Flutter SDK (versione 3.22 o superiore)
- Un editor (Android Studio, VS Code, Xcode)
- Un emulatore o dispositivo fisico per la piattaforma desiderata

### Installazione e avvio

```bash
# 1. Clona il repository
git clone https://github.com/merlinux74/deepseekapi.git
cd deepseekapi

# 2. Scarica le dipendenze
flutter pub get

# 3. Esegui l'app (scegli la piattaforma)
flutter run

# Per avviarlo su una piattaforma specifica (es. macOS):
flutter run -d macos

# Su Windows:
flutter run -d windows

# Su Android:
flutter run -d android
