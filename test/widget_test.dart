import 'package:flutter_test/flutter_test.dart';

import 'package:mod3_kel04/main.dart';

void main() {
  testWidgets('app shows the countries screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CountryApp());

    expect(find.text('Daftar Negara'), findsOneWidget);
  });
}
