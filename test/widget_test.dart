import 'package:flutter_test/flutter_test.dart';
import 'package:universtree/main.dart';

void main() {
  testWidgets('Universtree app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UniverstreeApp());
    await tester.pumpAndSettle();
    expect(find.text('UNIVERSTREE'), findsOneWidget);
  });
}
