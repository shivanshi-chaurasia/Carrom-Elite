import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elite_finance/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: CarromLotteryApp()));

    // Let the initial mock load delay happen and rebuild
    await tester.pumpAndSettle();

    // Verify that the login title is displayed.
    expect(find.text('Login'), findsWidgets);
  });
}
