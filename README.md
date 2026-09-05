# 🚀 DeepSeek API Status Monitor

![Dart](https://img.shields.io/badge/language-Dart-0175C2?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=flat-square&logo=flutter)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Android%20%7C%20iOS-lightgrey?style=flat-square)

Un'applicazione Flutter che mostra in **tempo reale** se le API di DeepSeek sono in fascia **Off-Peak** (sconto 50%) o **Peak** (tariffa piena), utilizzando il fuso orario italiano (Europe/Rome) e gestendo automaticamente ora legale e solare.

---

## 📖 A cosa serve

DeepSeek applica tariffe scontate del 50% in determinati orari e giorni della settimana. Questo strumento ti permette di **verificare istantaneamente** se in questo momento puoi usufruire dello sconto, senza dover calcolare manualmente le fasce orarie.

**Utile per:**
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

| Stato Off-Peak (verde) | Stato Peak (rosso) |
|------------------------|--------------------|
| *<inserisci qui uno screenshot dell'app in verde>* | *<inserisci qui uno screenshot dell'app in rosso>* |

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
- Android Studio / Xcode / Visual Studio Code (a seconda della piattaforma)
- Un emulatore o dispositivo fisico

### Installazione

```bash
# 1. Clona il repository
git clone https://github.com/tuo-username/deepseek-api-status.git
cd deepseek-api-status

# 2. Scarica le dipendenze
flutter pub get

# 3. Esegui l'app
flutter run

# Per avviarlo su una piattaforma specifica (es. macOS):
flutter run -d macos
