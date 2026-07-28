import 'package:flutter_test/flutter_test.dart';
import 'package:naoo_mobile/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NaooMobileApp());
    expect(find.text('NAOO.MOBILE'), findsOneWidget);
  });
}
