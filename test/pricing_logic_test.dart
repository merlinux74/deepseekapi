import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Regola DeepSeek: peak 01:00-04:00 e 06:00-10:00 UTC, lun-ven.
bool isPeak(tz.TZDateTime u) {
  if (u.weekday == DateTime.saturday || u.weekday == DateTime.sunday) return false;
  final h = u.hour;
  return (h >= 1 && h < 4) || (h >= 6 && h < 10);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final utc = tz.UTC;
  final rome = tz.getLocation('Europe/Rome');

  test('peak in UTC (lun-ven)', () {
    // Mercoledì 2025-03-05
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 5, 0, 59)), isFalse);
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 5, 1, 0)), isTrue);
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 5, 3, 59)), isTrue);
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 5, 4, 0)), isFalse);
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 5, 5, 59)), isFalse);
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 5, 6, 0)), isTrue);
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 5, 9, 59)), isTrue);
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 5, 10, 0)), isFalse);
  });

  test('weekend sempre off-peak', () {
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 8, 2, 0)), isFalse); // sabato
    expect(isPeak(tz.TZDateTime(utc, 2025, 3, 9, 7, 0)), isFalse); // domenica
  });

  test('conversione orario locale: CET vs CEST', () {
    // Inverno (CET, UTC+1): peak 01-04 UTC -> 02:00-05:00 locali
    final winter = tz.TZDateTime.from(tz.TZDateTime(utc, 2025, 1, 15, 1), rome);
    expect(winter.hour, 2);
    // Estate (CEST, UTC+2): peak 01-04 UTC -> 03:00-06:00 locali
    final summer = tz.TZDateTime.from(tz.TZDateTime(utc, 2025, 7, 15, 1), rome);
    expect(summer.hour, 3);
  });
}
