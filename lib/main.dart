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

// ---------------------------------------------------------------------------
// FONTE DATI: https://api-docs.deepseek.com/quick_start/pricing/
//
// Off-peak rates are half of the peak rates. Peak hours are 01:00 - 04:00 and
// 06:00 - 10:00 UTC, Monday through Friday, excluding Chinese public holidays.
// All other hours are off-peak, including weekends and Chinese public holidays.
// ---------------------------------------------------------------------------

/// Fasce peak espresse in UTC (l'ora UTC non è soggetta all'ora legale,
/// quindi questa è l'unica rappresentazione stabile della regola DeepSeek).
class _UtcPeakRange {
  const _UtcPeakRange(this.startHour, this.endHour);
  final int startHour;
  final int endHour;

  bool contains(int utcHour) => utcHour >= startHour && utcHour < endHour;
}

const List<_UtcPeakRange> _peakRangesUtc = [
  _UtcPeakRange(1, 4),
  _UtcPeakRange(6, 10),
];

/// Festività pubbliche cinesi (off-peak tutto il giorno).
/// Elenco indicativo: aggiungere qui gli anni futuri quando pubblicati.
const Set<String> _chinesePublicHolidays = {
  // 2024
  '2024-01-01',
  '2024-02-10', '2024-02-11', '2024-02-12', '2024-02-13', '2024-02-14',
  '2024-02-15', '2024-02-16', '2024-02-17',
  '2024-04-04', '2024-04-05', '2024-04-06',
  '2024-05-01', '2024-05-02', '2024-05-03', '2024-05-04', '2024-05-05',
  '2024-06-10',
  '2024-09-15', '2024-09-16', '2024-09-17',
  '2024-10-01', '2024-10-02', '2024-10-03', '2024-10-04', '2024-10-05',
  '2024-10-06', '2024-10-07',
  // 2025
  '2025-01-01',
  '2025-01-28', '2025-01-29', '2025-01-30', '2025-01-31',
  '2025-02-01', '2025-02-02', '2025-02-03', '2025-02-04',
  '2025-04-04', '2025-04-05', '2025-04-06',
  '2025-05-01', '2025-05-02', '2025-05-03', '2025-05-04', '2025-05-05',
  '2025-05-31', '2025-06-01', '2025-06-02',
  '2025-10-01', '2025-10-02', '2025-10-03', '2025-10-04', '2025-10-05',
  '2025-10-06', '2025-10-07', '2025-10-08',
  // 2026
  '2026-01-01',
  '2026-02-15', '2026-02-16', '2026-02-17', '2026-02-18', '2026-02-19',
  '2026-02-20', '2026-02-21', '2026-02-22',
  '2026-04-04', '2026-04-05', '2026-04-06',
  '2026-05-01', '2026-05-02', '2026-05-03', '2026-05-04', '2026-05-05',
  '2026-06-19', '2026-06-20', '2026-06-21',
  '2026-09-25', '2026-09-26', '2026-09-27',
  '2026-10-01', '2026-10-02', '2026-10-03', '2026-10-04', '2026-10-05',
  '2026-10-06', '2026-10-07',
};

/// Prezzi in USD per 1M token (fonte: pagina "Models & Pricing").
class _ModelPricing {
  const _ModelPricing({
    required this.name,
    required this.version,
    required this.cacheHitPeak,
    required this.cacheHitOffPeak,
    required this.cacheMissPeak,
    required this.cacheMissOffPeak,
    required this.outputPeak,
    required this.outputOffPeak,
  });

  final String name;
  final String version;
  final double cacheHitPeak;
  final double cacheHitOffPeak;
  final double cacheMissPeak;
  final double cacheMissOffPeak;
  final double outputPeak;
  final double outputOffPeak;
}

const List<_ModelPricing> _models = [
  _ModelPricing(
    name: 'deepseek-flash',
    version: 'DeepSeek-V4.1-Flash-1017',
    cacheHitPeak: 0.006,
    cacheHitOffPeak: 0.003,
    cacheMissPeak: 0.30,
    cacheMissOffPeak: 0.15,
    outputPeak: 1.20,
    outputOffPeak: 0.60,
  ),
  _ModelPricing(
    name: 'deepseek-v4-pro',
    version: 'DeepSeek-V4-Pro-0813',
    cacheHitPeak: 0.044,
    cacheHitOffPeak: 0.022,
    cacheMissPeak: 1.32,
    cacheMissOffPeak: 0.66,
    outputPeak: 3.96,
    outputOffPeak: 1.98,
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DeepSeek Pricing Monitor - Fullscreen',
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
  String _utcTimeString = '--:--:-- UTC';
  String _statusText = 'Verifica in corso...';
  String _statusSubText = 'Caricamento...';
  String _badgeText = '--';
  String _nextChangeText = '';
  Color _statusColor = Colors.grey;
  IconData _statusIcon = Icons.hourglass_empty;
  bool _isOffPeak = false;
  late tz.Location _romeLocation;
  late tz.Location _utcLocation;

  // Formatter per data (creato una volta sola, dopo l'inizializzazione)
  late final DateFormat _dateFormatter;
  late final DateFormat _peakFormatter;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Inizializza il formatter (ora i dati di locale sono pronti)
    _dateFormatter = DateFormat('EEEE d MMMM yyyy', 'it_IT');
    _peakFormatter = DateFormat('HH:mm');
    _romeLocation = tz.getLocation('Europe/Rome');
    // tz.UTC è la location a offset fisso 0 fornita dal pacchetto.
    _utcLocation = tz.UTC;
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

  /// Restituisce true se l'istante indicato ricade in una fascia peak.
  bool _isPeakAt(tz.TZDateTime utcNow) {
    // Weekend => sempre off-peak (sabato = 6, domenica = 7)
    if (utcNow.weekday == DateTime.saturday || utcNow.weekday == DateTime.sunday) {
      return false;
    }

    // Festività pubbliche cinesi => off-peak tutto il giorno
    final dayKey = DateFormat('yyyy-MM-dd').format(utcNow);
    if (_chinesePublicHolidays.contains(dayKey)) return false;

    return _peakRangesUtc.any((r) => r.contains(utcNow.hour));
  }

  /// Trova il prossimo cambio di tariffa (in minuti da adesso).
  Duration _timeUntilNextChange(tz.TZDateTime utcNow) {
    final currentlyPeak = _isPeakAt(utcNow);
    for (var minutes = 1; minutes <= 60 * 24 * 8; minutes++) {
      final probe = utcNow.add(Duration(minutes: minutes));
      if (_isPeakAt(probe) != currentlyPeak) {
        return Duration(minutes: minutes);
      }
    }
    return Duration.zero;
  }

  /// Converte una fascia peak UTC nell'orario locale italiano corrente,
  /// gestendo automaticamente CET/CEST.
  String _peakRangesLocalLabel(tz.TZDateTime nowUtc) {
    return _peakRangesUtc.map((r) {
      final startUtc = tz.TZDateTime(
          _utcLocation, nowUtc.year, nowUtc.month, nowUtc.day, r.startHour);
      final endUtc = tz.TZDateTime(
          _utcLocation, nowUtc.year, nowUtc.month, nowUtc.day, r.endHour);
      final startLocal = tz.TZDateTime.from(startUtc, _romeLocation);
      final endLocal = tz.TZDateTime.from(endUtc, _romeLocation);
      return '${_peakFormatter.format(startLocal)}–${_peakFormatter.format(endLocal)}';
    }).join(' e ');
  }

  void _updateStatus() {
    final now = tz.TZDateTime.now(_romeLocation);
    final nowUtc = tz.TZDateTime.now(_utcLocation);

    final dateStr = _dateFormatter.format(now);
    final timeStr = DateFormat('HH:mm:ss').format(now);

    final isPeak = _isPeakAt(nowUtc);
    final isOffPeak = !isPeak;

    final String statusLabel;
    final String subText;
    final IconData icon;
    final String badge;
    final Color statusColor;

    if (isPeak) {
      statusLabel = 'PEAK  •  TARIFFA PIENA';
      subText = 'In questo momento si applicano i prezzi pieni (100%).';
      icon = Icons.cancel;
      badge = 'Tariffa piena';
      statusColor = const Color(0xFFef4444);
    } else {
      statusLabel = 'OFF-PEAK  •  SCONTO 50%';
      subText = 'Prezzi dimezzati applicati automaticamente.';
      icon = Icons.check_circle;
      badge = 'Sconto 50% attivo';
      statusColor = const Color(0xFF22c55e);
    }

    // Prossimo cambio di tariffa
    final untilChange = _timeUntilNextChange(nowUtc);
    final h = untilChange.inHours;
    final m = untilChange.inMinutes % 60;
    final s = untilChange.inSeconds % 60;
    final nextLabel = isPeak
        ? 'Inizio sconto tra'
        : 'Fine sconto tra';
    final nextChangeText =
        '$nextLabel ${h}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';

    setState(() {
      _dateTimeString = '$dateStr  •  $timeStr';
      _utcTimeString = '${DateFormat('HH:mm:ss').format(nowUtc)} UTC';
      _isOffPeak = isOffPeak;
      _statusText = statusLabel;
      _statusSubText = subText;
      _statusIcon = icon;
      _badgeText = badge;
      _statusColor = statusColor;
      _nextChangeText = nextChangeText;
    });
  }

  String _money(double v) => '\$${v.toStringAsFixed(v < 0.1 ? 3 : 2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

            final titleSize = (w * 0.026).clamp(24.0, 60.0);
            final subtitleSize = (w * 0.013).clamp(13.0, 26.0);
            final clockSize = (w * 0.045).clamp(52.0, 190.0).toDouble();
            final statusSize = (w * 0.026).clamp(26.0, 80.0);
            final bodySize = (w * 0.012).clamp(12.0, 24.0);
            final spacing = (minScreen * 0.016).clamp(8.0, 34.0);
            final radius = (minScreen * 0.018).clamp(8.0, 24.0).toDouble();

            final peakLabel = _peakRangesLocalLabel(tz.TZDateTime.now(_utcLocation));

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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '🚀 DeepSeek API Pricing',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: titleSize,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFf1f5f9),
                              ),
                            ),
                          ),
                          SizedBox(width: spacing),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: spacing * 1.2, vertical: spacing * 0.35),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1e293b),
                                borderRadius: BorderRadius.circular(radius * 0.7),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Text(
                                'Peak = 01–04 & 06–10 UTC · Lun–Ven',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: subtitleSize,
                                    color: const Color(0xFF94a3b8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing * 1.4),

                      // ---- Data + Orologio gigante ----
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: spacing * 0.9, horizontal: spacing * 1.6),
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
                                letterSpacing: 3,
                                color: const Color(0xFFf1f5f9),
                              ),
                            ),
                            SizedBox(height: spacing * 0.25),
                            Text(
                              '⏰ Ora italiana (Europe/Rome)  ·  $_utcTimeString',
                              style: TextStyle(
                                  fontSize: subtitleSize, color: const Color(0xFF64748b)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing * 1.4),

                      // ---- Stato attuale ----
                      Container(
                        padding: EdgeInsets.all(spacing * 1.2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius * 2),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isOffPeak
                                ? [
                                    const Color(0xFF22c55e).withValues(alpha: 0.35),
                                    const Color(0xFF0f172a)
                                  ]
                                : [
                                    const Color(0xFFef4444).withValues(alpha: 0.35),
                                    const Color(0xFF0f172a)
                                  ],
                          ),
                          border: Border.all(
                            color: _isOffPeak
                                ? const Color(0xFF22c55e)
                                : const Color(0xFFef4444),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(_statusIcon, size: statusSize * 1.1, color: _statusColor),
                            SizedBox(height: spacing * 0.6),
                            Text(
                              _statusText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: statusSize,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: _statusColor,
                              ),
                            ),
                            SizedBox(height: spacing * 0.35),
                            Text(
                              _statusSubText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: bodySize * 1.25, color: const Color(0xFFe2e8f0)),
                            ),
                            SizedBox(height: spacing * 0.5),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: spacing,
                              runSpacing: spacing * 0.4,
                              children: [
                                _pill(
                                  _isOffPeak ? '✅ $_badgeText' : '❌ $_badgeText',
                                  _statusColor,
                                  bodySize,
                                  spacing,
                                  radius,
                                ),
                                _pill(
                                  _nextChangeText,
                                  const Color(0xFF38bdf8),
                                  bodySize,
                                  spacing,
                                  radius,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing * 1.2),

                      // ---- Tabella prezzi ----
                      _pricingTable(
                        spacing: spacing,
                        radius: radius,
                        bodySize: bodySize,
                        isOffPeak: _isOffPeak,
                      ),
                      SizedBox(height: spacing * 1.2),

                      // ---- Regole ----
                      Container(
                        padding: EdgeInsets.all(spacing * 1.1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1e293b),
                          borderRadius: BorderRadius.circular(radius * 2),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📋 Regole tariffarie DeepSeek',
                              style: TextStyle(
                                fontSize: bodySize * 1.3,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFf1f5f9),
                              ),
                            ),
                            SizedBox(height: spacing * 0.5),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: bodySize,
                                  color: const Color(0xFFcbd5e1),
                                  height: 1.55,
                                ),
                                children: [
                                  const TextSpan(text: '• '),
                                  const TextSpan(
                                    text: 'Peak (tariffa piena)',
                                    style: TextStyle(
                                      color: Color(0xFFf87171),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(
                                      text: ': 01:00–04:00 e 06:00–10:00 UTC, lun–ven.\n'),
                                  const TextSpan(text: '• '),
                                  const TextSpan(
                                    text: 'Off-peak (sconto 50%)',
                                    style: TextStyle(
                                      color: Color(0xFF4ade80),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(
                                      text:
                                          ': tutti gli altri orari, weekend interi e festività cinesi.\n'),
                                  TextSpan(text: '• Ora locale italiana oggi (Europe/Rome): peak '),
                                  TextSpan(
                                    text: peakLabel,
                                    style: const TextStyle(
                                      color: Color(0xFFfacc15),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const TextSpan(
                                      text: ' — l\'orario locale cambia con l\'ora legale.\n'),
                                  const TextSpan(
                                      text:
                                          '• Prezzi in USD per 1M token. Fonte: api-docs.deepseek.com/quick_start/pricing'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: spacing * 0.8),

                      Text(
                        'Aggiornamento automatico ogni secondo · Dati in tempo reale · Monitor full-screen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: bodySize * 0.85, color: const Color(0xFF64748b)),
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

  Widget _pill(String text, Color color, double bodySize, double spacing, double radius) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing * 1.6, vertical: spacing * 0.4),
      decoration: BoxDecoration(
        color: const Color(0xFF0f172a),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: bodySize * 1.1,
          fontWeight: FontWeight.w700,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _pricingTable({
    required double spacing,
    required double radius,
    required double bodySize,
    required bool isOffPeak,
  }) {
    final headerStyle = TextStyle(
      fontSize: bodySize * 1.05,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF94a3b8),
    );
    final cellStyle = TextStyle(
      fontSize: bodySize,
      color: const Color(0xFFe2e8f0),
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    const offColor = Color(0xFF4ade80);
    const peakColor = Color(0xFFf87171);

    Widget priceCell(double offPeak, double peak, {bool bold = false}) {
      return RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          style: cellStyle.copyWith(fontWeight: bold ? FontWeight.w700 : FontWeight.w500),
          children: [
            TextSpan(
              text: _money(isOffPeak ? offPeak : peak),
              style: TextStyle(color: isOffPeak ? offColor : peakColor),
            ),
            TextSpan(
              text: '  (${_money(offPeak)} / ${_money(peak)})',
              style: TextStyle(fontSize: bodySize * 0.8, color: const Color(0xFF64748b)),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(spacing * 1.1),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(radius * 2),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💵 Prezzi per 1M token (USD) · off-peak / peak',
            style: TextStyle(
              fontSize: bodySize * 1.3,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFf1f5f9),
            ),
          ),
          SizedBox(height: spacing * 0.6),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.2),
              1: FlexColumnWidth(1.6),
              2: FlexColumnWidth(1.6),
              3: FlexColumnWidth(1.6),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing * 0.3),
                    child: Text('Modello', style: headerStyle),
                  ),
                  Text('Input (cache hit)', textAlign: TextAlign.right, style: headerStyle),
                  Text('Input (cache miss)', textAlign: TextAlign.right, style: headerStyle),
                  Text('Output', textAlign: TextAlign.right, style: headerStyle),
                ],
              ),
              for (final m in _models)
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: spacing * 0.4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: cellStyle.copyWith(
                                fontWeight: FontWeight.w700, fontSize: bodySize * 1.05),
                          ),
                          Text(
                            m.version,
                            style: cellStyle.copyWith(
                                fontSize: bodySize * 0.75, color: const Color(0xFF64748b)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: spacing * 0.4),
                      child: priceCell(m.cacheHitOffPeak, m.cacheHitPeak),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: spacing * 0.4),
                      child: priceCell(m.cacheMissOffPeak, m.cacheMissPeak),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: spacing * 0.4),
                      child: priceCell(m.outputOffPeak, m.outputPeak, bold: true),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
