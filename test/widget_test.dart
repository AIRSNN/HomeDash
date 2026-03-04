import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homedash/app.dart';

void main() {
  testWidgets('DashboardPage yuklenme testi', (WidgetTester tester) async {
    // Uygulamayı oluştur ve frame tetikle
    await tester.pumpWidget(const MadamApp());

    // DashboardPage yüklendiğini doğrula
    expect(find.text('HomeDash (MADAM)'), findsOneWidget);
  });
}
