import 'package:cool_snake/app/app.dart';
import 'package:cool_snake/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test: menu navigation and screens',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.init();

    await tester.pumpWidget(CoolSnakeApp(storage: storage));
    // Verify splash screen appears initially
    expect(find.text('COOL SNAKES'), findsOneWidget);
    expect(find.textContaining('LOADING...'), findsOneWidget);

    // Fast-forward past bootup splash sequence
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    // Verify Main Menu is rendered
    expect(find.text('COOL SNAKE'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('SPEED'), findsOneWidget);
    expect(find.text('HIGH SCORE'), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('ABOUT'), findsOneWidget);

    // Tap SPEED
    await tester.tap(find.text('SPEED'));
    await tester.pumpAndSettle();
    expect(find.text('SLOW'), findsOneWidget);
    expect(find.text('NORMAL'), findsOneWidget);
    expect(find.text('FAST'), findsOneWidget);

    // Return back to menu
    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
    expect(find.text('COOL SNAKE'), findsOneWidget);

    // Tap HIGH SCORE
    await tester.tap(find.text('HIGH SCORE'));
    await tester.pumpAndSettle();
    expect(find.text('HIGH SCORES'), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
    expect(find.text('2.'), findsOneWidget);
    expect(find.text('3.'), findsOneWidget);
    expect(find.text('MAX POSSIBLE'), findsOneWidget);
    expect(find.text('019960'), findsOneWidget);

    // Return back to menu
    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();

    // Tap SETTINGS
    await tester.tap(find.text('SETTINGS'));
    await tester.pumpAndSettle();
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('SOUND'), findsOneWidget);
    expect(find.text('HAPTICS'), findsOneWidget);
    expect(find.text('BOUNDS'), findsOneWidget);
    expect(find.text('WRAP'), findsOneWidget);
    expect(find.text('CONTROLS'), findsOneWidget);
    expect(find.text('LCD FX'), findsOneWidget);

    // Toggle BOUNDS to BORDER
    await tester.tap(find.text('BOUNDS'));
    await tester.pumpAndSettle();
    expect(find.text('BORDER'), findsOneWidget);

    // Return back to menu
    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();

    // Tap ABOUT
    await tester.tap(find.text('ABOUT'));
    await tester.pumpAndSettle();
    expect(find.textContaining('RULES:'), findsOneWidget);

    // Return back to menu
    await tester.tap(find.text('BACK'));
    await tester.pumpAndSettle();
  });
}
