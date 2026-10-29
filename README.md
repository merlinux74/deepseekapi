# 🚀 DeepSeek API Pricing Monitor

![Dart](https://img.shields.io/badge/language-Dart-0175C2?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?style=flat-square&logo=flutter)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Windows%20%7C%20Linux%20%7C%20Android%20%7C%20iOS-lightgrey?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

> **Monitor in tempo reale delle fasce tariffarie delle API DeepSeek.**

Un'applicazione Flutter che mostra istantaneamente se le API di DeepSeek sono in fascia
**Off-Peak** (sconto 50%) o **Peak** (tariffa piena), con la tabella prezzi aggiornata.
Le fasce sono calcolate in **UTC** (come da specifica DeepSeek) e mostrate anche
convertite nel fuso orario italiano (Europe/Rome), con gestione automatica di
ora legale e solare.

---

## 📖 Perché questo progetto

DeepSeek offre tariffe scontate del 50% in determinati orari e giorni della settimana.
Questo strumento ti permette di **verificare con un colpo d'occhio** se in questo
momento puoi risparmiare, senza dover fare calcoli manuali.

**Ideale per:**
- Sviluppatori che integrano le API DeepSeek e vogliono ottimizzare i costi.
- Team che pianificano batch di richieste nelle fasce più convenienti.
- Chiunque voglia monitorare il costo delle chiamate API in tempo reale.

---

## ✨ Funzionalità

- **🟢 Indicatore visivo in tempo reale**:
  - Verde = sconto 50% attivo (Off-Peak)
  - Rosso = tariffa piena (Peak)
- **💵 Tabella prezzi** per `deepseek-flash` e `deepseek-v4-pro`, con evidenza
  della tariffa attualmente applicata.
- **⏳ Countdown** al prossimo cambio di tariffa.
- **⏰ Aggiornamento automatico ogni secondo**.
- **📅 Rilevazione automatica**:
  - Weekend (sabato e domenica): sconto 50% 24 ore su 24.
  - Festività pubbliche cinesi: sconto 50% tutto il giorno.
  - Feriali: fascia Peak `01:00–04:00` e `06:00–10:00` **UTC**.
- **🌍 Fuso orario corretto**: calcolo sempre in UTC, visualizzazione in
  `Europe/Rome` con gestione automatica di ora legale/solare, più orologio UTC.
- **🎨 Interfaccia chiara e moderna** con tema scuro, pensata per un monitor full-screen.

---

## 📊 Dati di riferimento

Fonte: <https://api-docs.deepseek.com/quick_start/pricing/>

- **Peak**: `01:00–04:00` e `06:00–10:00` **UTC**, dal lunedì al venerdì.
- **Off-peak**: tutte le altre ore, weekend interi e festività pubbliche cinesi.
- Le tariffe off-peak sono esattamente la metà di quelle peak.
- I prezzi sono in **USD per 1M token**.

> ⚠️ **Nota importante**: le fasce Peak sono definite in **UTC**, non in ora locale.
> In Italia diventano `02:00–05:00` e `07:00–11:00` con l'ora solare (CET) e
> `03:00–06:00` e `08:00–12:00` con l'ora legale (CEST). L'app calcola sempre in UTC
> e mostra la conversione locale corrente, così resta corretta tutto l'anno.

### Modelli e prezzi (USD / 1M token)

| Modello | Input cache hit (off/peak) | Input cache miss (off/peak) | Output (off/peak) |
|---|---|---|---|
| `deepseek-flash` (V4.1-Flash-1017) | $0.003 / $0.006 | $0.15 / $0.30 | $0.60 / $1.20 |
| `deepseek-v4-pro` (V4-Pro-0813) | $0.022 / $0.044 | $0.66 / $1.32 | $1.98 / $3.96 |

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
```

---

## 🔧 Manutenzione

I dati tariffari sono in `lib/main.dart`:

- **Festività cinesi**: `_chinesePublicHolidays`. Va esteso quando vengono
  pubblicati i calendari dei nuovi anni.
- **Prezzi**: costante `_models`.
- **Fasce Peak**: costante `_peakRangesUtc` (sempre espresse in UTC).

## 🧪 Test

```bash
flutter test
```

## 📄 Licenza

Distribuito sotto licenza MIT.
