import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:deepseekapi/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it_IT', null);
    tz.initializeTimeZones();
  });

  testWidgets('Mostra intestazione e tabella prezzi DeepSeek',
      (WidgetTester tester) async {
    // Simula un monitor full-screen invece del viewport di test (800x600),
    // altrimenti il layout va in overflow.
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('🚀 DeepSeek API Pricing'), findsOneWidget);
    expect(find.text('deepseek-flash'), findsOneWidget);
    expect(find.text('deepseek-v4-pro'), findsOneWidget);
    expect(find.text('DeepSeek-V4.1-Flash-1017'), findsOneWidget);
    expect(find.text('DeepSeek-V4-Pro-0813'), findsOneWidget);
    // Il testo delle regole è in un RichText: lo si ispeziona direttamente.
    final richTexts = tester
        .widgetList<RichText>(find.byType(RichText))
        .map((w) => w.text.toPlainText())
        .join('\n');
    expect(richTexts.contains('Regole tariffarie DeepSeek'), isTrue);
    expect(richTexts.contains('01:00–04:00 e 06:00–10:00 UTC'), isTrue);
    expect(richTexts.contains('off-peak'), isTrue);  });
}
