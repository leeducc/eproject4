






import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_desktop/main.dart';
import 'package:mobile_desktop/core/providers/theme_provider.dart';
import 'package:mobile_desktop/core/providers/font_size_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    
    await tester.pumpWidget(EnglishStudyApp(
      initialThemeMode: ThemeMode.system,
      initialFontSizeLevel: FontSizeLevel.medium,
    ));

    
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
