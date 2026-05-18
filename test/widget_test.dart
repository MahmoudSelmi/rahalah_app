import 'package:flutter_test/flutter_test.dart';
import 'package:rahalah_app/main.dart';

void main() {
  testWidgets('RahalahApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RahalahApp());
    expect(find.byType(RahalahApp), findsOneWidget);
  });
}