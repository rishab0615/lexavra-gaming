import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Basic Flutter widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Lexavra Gaming'))),
    );

    expect(find.text('Lexavra Gaming'), findsOneWidget);
  });
}
