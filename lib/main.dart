import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  // Inizializza Flutter (necessario per chiamate asincrone prima di runApp)
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza i dati di formattazione per il locale italiano
  await initializeDateFormatting('it_IT', null);

  // Inizializza i dati dei fusi orari
  tz.initializeTimeZones();

  // Blocca l'app in orizzontale e nasconde le barre di sistema per
  // un'esperienza da "monitor informativo" a tutto schermo.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepSeek Status - Fullscreen Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0b1120),
        cardColor: const Color(0xFF1e293b),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22c55e),
          error: Color(0xFFef4444),
        ),
      ),
      home: const StatusPage(),
    );
  }
}

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  // Variabili di stato
  String _dateTimeString = 'Caricamento...';
  String _statusText = 'Verifica in corso...';
  String _statusSubText = 'Caricamento...';
  String _badgeText = '--';
  Color _statusColor = Colors.grey;
  IconData _statusIcon = Icons.hourglass_empty;
  bool _isOffPeak = false;
  late tz.Location _romeLocation;

  // Formatter per data (creato una volta sola, dopo l'inizializzazione)
  late final DateFormat _dateFormatter;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Inizializza il formatter (ora i dati di locale sono pronti)
    _dateFormatter = DateFormat('EEEE d MMMM yyyy', 'it_IT');
    _romeLocation = tz.getLocation('Europe/Rome');
    _updateStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateStatus() {
    final now = tz.TZDateTime.now(_romeLocation);
    final dayOfWeek = now.weekday; // 1 = lunedì, 7 = domenica
    final hour = now.hour;
    final minute = now.minute;
    final second = now.second;

    // Formatta data
    final dateStr = _dateFormatter.format(now);
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';

    setState(() {
      _dateTimeString = '$dateStr  •  $timeStr';

      // --- LOGICA OFF-PEAK / PEAK ---
      bool isOffPeak;
      String statusLabel;
      String subText;
      IconData icon;
      String badge;
      Color statusColor;

      final isWeekend = (dayOfWeek == 6 || dayOfWeek == 7); // sabato o domenica

      if (isWeekend) {
        isOffPeak = true;
        statusLabel = 'OFF-PEAK';
        subText = 'Sconto 50% attivo tutto il weekend!';
        icon = Icons.check_circle;
        badge = 'Sconto 50% attivo';
        statusColor = const Color(0xFF22c55e);
      } else {
        // Feriali: fasce peak 3-6 e 8-12 (ora italiana)
        final isPeakMorning = (hour >= 3 && hour < 6);
        final isPeakLate = (hour >= 8 && hour < 12);

        if (isPeakMorning || isPeakLate) {
          isOffPeak = false;
          statusLabel = 'PEAK  •  TARIFFA PIENA';
          subText = 'In questo momento si applicano i prezzi interi.';
          icon = Icons.cancel;
          badge = 'Tariffa piena';
          statusColor = const Color(0xFFef4444);
        } else {
          isOffPeak = true;
          statusLabel = 'OFF-PEAK';
          subText = 'Sconto del 50% applicato automaticamente!';
          icon = Icons.check_circle;
          badge = 'Sconto 50% attivo';
          statusColor = const Color(0xFF22c55e);
        }
      }

      _isOffPeak = isOffPeak;
      _statusText = statusLabel;
      _statusSubText = subText;
      _statusIcon = icon;
      _badgeText = badge;
      _statusColor = statusColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sfondo pieno schermo
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Scala i testi in base alla dimensione reale dello schermo,
            // così su un monitor grande tutto resta ben leggibile e riempie
            // lo schermo senza lasciare spazi vuoti.
            final mw = constraints.maxWidth;
            final mh = constraints.maxHeight;
            final minScreen = mw < mh ? mw : mh;
            final w = mw;

            // Scala i testi in base alla dimensione reale dello schermo.
            final titleSize = (w * 0.03).clamp(28.0, 72.0);
            final subtitleSize = (w * 0.016).clamp(15.0, 32.0);
            final clockSize = (w * 0.05).clamp(60.0, 220.0).toDouble();
            final statusSize = (w * 0.03).clamp(30.0, 96.0);
            final bodySize = (w * 0.014).clamp(14.0, 28.0);
            final spacing = (minScreen * 0.02).clamp(10.0, 44.0);
            final radius = (minScreen * 0.02).clamp(8.0, 26.0).toDouble();

            return SingleChildScrollView(
              padding: EdgeInsets.all(spacing),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: mh - spacing * 2),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---- Intestazione ----
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '🚀 DeepSeek API',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFf1f5f9),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: spacing * 1.4, vertical: spacing * 0.4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1e293b),
                              borderRadius: BorderRadius.circular(radius * 0.7),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Text(
                              '€ Tariffa scontata / piena',
                              style: TextStyle(fontSize: subtitleSize, color: const Color(0xFF94a3b8)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing * 2),

                      // ---- Data + Orologio gigante ----
                      Container(
                        padding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing * 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0f172a),
                          borderRadius: BorderRadius.circular(radius * 2),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _dateTimeString,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: clockSize,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                                color: const Color(0xFFf1f5f9),
                              ),
                            ),
                            SizedBox(height: spacing * 0.3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('⏰ ', style: TextStyle(color: Color(0xFF64748b))),
                                Text(
                                  'Ora italiana · Europe/Rome',
                                  style: TextStyle(fontSize: subtitleSize, color: const Color(0xFF64748b)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing * 2),

                      // ---- Stato attuale (grande casella colorata) ----
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.all(spacing * 1.5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(radius * 2),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _isOffPeak
                                  ? [const Color(0xFF22c55e).withValues(alpha: 0.35), const Color(0xFF0f172a)]
                                  : [const Color(0xFFef4444).withValues(alpha: 0.35), const Color(0xFF0f172a)],
                            ),
                            border: Border.all(
                              color: _isOffPeak ? const Color(0xFF22c55e) : const Color(0xFFef4444),
                              width: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_statusIcon, size: statusSize * 1.6, color: _statusColor),
                              SizedBox(height: spacing),
                              Text(
                                _statusText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: statusSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                  color: _statusColor,
                                ),
                              ),
                              SizedBox(height: spacing * 0.5),
                              Text(
                                _statusSubText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: bodySize * 1.3,
                                  color: const Color(0xFFe2e8f0),
                                ),
                              ),
                              SizedBox(height: spacing),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: spacing * 2, vertical: spacing * 0.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0f172a),
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: const Color(0xFF334155)),
                                ),
                                child: Text(
                                  _isOffPeak ? '✅ $_badgeText' : '❌ $_badgeText',
                                  style: TextStyle(
                                    fontSize: bodySize * 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: _statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: spacing * 2),

                      // ---- Regole sconto ----
                      Container(
                        padding: EdgeInsets.all(spacing * 1.2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e293b),
                          borderRadius: BorderRadius.circular(radius * 2),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📋 Regole sconto 50% (Off-Peak):',
                              style: TextStyle(
                                fontSize: bodySize * 1.3,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFf1f5f9),
                              ),
                            ),
                            SizedBox(height: spacing * 0.6),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: bodySize,
                                  color: const Color(0xFFcbd5e1),
                                  height: 1.6,
                                ),
                                children: [
                                  TextSpan(text: '• '),
                                  TextSpan(
                                    text: 'Weekend (Sabato & Domenica)',
                                    style: TextStyle(
                                      color: const Color(0xFFfacc15),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: ': sconto '),
                                  TextSpan(
                                    text: 'ATTIVO 24h',
                                    style: TextStyle(
                                      color: const Color(0xFF4ade80),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(text: '.\n'),
                                  TextSpan(text: '• '),
                                  TextSpan(
                                    text: 'Feriali (Lun-Ven)',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  TextSpan(text: ': '),
                                  TextSpan(
                                    text: 'Tariffa piena',
                                    style: TextStyle(
                                      color: const Color(0xFFf87171),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: ' dalle '),
                                  const TextSpan(text: '03:00', style: TextStyle(fontWeight: FontWeight.w700)),
                                  TextSpan(text: ' alle '),
                                  const TextSpan(text: '06:00', style: TextStyle(fontWeight: FontWeight.w700)),
                                  TextSpan(text: ' e dalle '),
                                  const TextSpan(text: '08:00', style: TextStyle(fontWeight: FontWeight.w700)),
                                  TextSpan(text: ' alle '),
                                  const TextSpan(text: '12:00', style: TextStyle(fontWeight: FontWeight.w700)),
                                  TextSpan(text: ' (ora italiana).\n'),
                                  TextSpan(text: '• Tutti gli altri orari feriali: sconto '),
                                  TextSpan(
                                    text: 'ATTIVO 50%',
                                    style: TextStyle(
                                      color: const Color(0xFF4ade80),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing),

                      // ---- Piè di pagina ----
                      Text(
                        'Aggiornamento automatico ogni secondo · Dati in tempo reale · Monitor full-screen',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: bodySize * 0.9, color: const Color(0xFF64748b)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
