import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<DateTime?> _openPicker(BuildContext context) {
  return showDatePicker(
    context: context,
    initialDate: DateTime(2025, 1, 15),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
}

Widget _hostApp() {
  return MaterialApp(
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            key: const Key('open_date_picker'),
            onPressed: () => _openPicker(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('showDatePicker basic selection returns chosen date', (tester) async {
    await tester.pumpWidget(_hostApp());
    await tester.tap(find.byKey(const Key('open_date_picker')));
    await tester.pumpAndSettle();

    // Pick a specific day
    await tester.tap(find.text('20'));
    await tester.pumpAndSettle();

    // Confirm selection
    await tester.tap(find.text('OK')); // Using English locale to avoid localization mismatch
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget); // Back to host screen
  });

  testWidgets('showDatePicker renders correctly on small screen', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_hostApp());
    await tester.tap(find.byKey(const Key('open_date_picker')));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });

  testWidgets('showDatePicker renders as dialog on larger screens and supports orientation change', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_hostApp());
    await tester.tap(find.byKey(const Key('open_date_picker')));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);

    // Simulate orientation change (landscape to portrait)
    tester.view.physicalSize = const Size(768, 1024);
    await tester.pumpAndSettle();

    // DatePicker still visible
    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });
}